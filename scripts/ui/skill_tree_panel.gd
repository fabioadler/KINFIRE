class_name SkillTreePanel
extends PanelContainer
## Painel da Arvore de Habilidades (Fase 10.4)
## Mostra nós conectados, permite gastar pontos de árvore.

## Preloads para type hints funcionarem em parse time
const SkillTreeData := preload("res://scripts/data/skill_tree_data.gd")
const SkillNodeData := preload("res://scripts/data/skill_node_data.gd")

var hud: HUD
var hero: Hero
var _tree: SkillTreeData
var _canvas: Control
var _points_label: Label
var _nodes_ui: Dictionary = {}  # node_id -> {container, btn, line_paths}
var _selected_node: SkillNodeData = null
var _tooltip: Control = null
var _h_scroll: HScrollBar
var _v_scroll: VScrollBar
var _drag_offset := Vector2.ZERO
var _dragging := false


func setup(p_hud: HUD, p_hero: Hero) -> void:
	hud = p_hud
	hero = p_hero
	
	add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	var w := UIKit.window_panel("Arvore de Habilidades", Vector2(760, 520), func(): hud.toggle_skill_tree())
	add_child(w.panel)
	var body: VBoxContainer = w.body
	
	# Header com pontos
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	body.add_child(header)
	
	var icon := SpritePreview.new()
	icon.custom_minimum_size = Vector2(48, 48)
	icon.set_sprite(hero.cls.icon, hero.tint * hero.race.tint)
	header.add_child(icon)
	
	var title := UIKit.label("[font_size=24][color=#e8c060]%s[/color][/font_size]" % hero.cls.display_name, 24)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(title)
	
	_points_label = UIKit.label("", 18, Color(1, 0.9, 0.4), true)
	_points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_points_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_points_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(_points_label)
	
	# Canvas com scroll
	var scroll_container := ScrollContainer.new()
	scroll_container.custom_minimum_size = Vector2(740, 440)
	scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	body.add_child(scroll_container)
	
	_canvas = Control.new()
	_canvas.custom_minimum_size = Vector2(1500, 800)  # Area grande para a árvore
	_canvas.mouse_filter = Control.MOUSE_FILTER_PASS
	scroll_container.add_child(_canvas)
	
	# Carrega a árvore da classe
	_tree = DB.get_skill_tree(hero.cls.id)
	if not _tree:
		var msg := UIKit.label("Arvore de habilidades não disponível para %s" % hero.cls.display_name, 16, UIKit.TEXT_DIM, true)
		msg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		msg.size_flags_vertical = Control.SIZE_EXPAND_FILL
		msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		msg.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_canvas.add_child(msg)
		return
	
	# Cria UI dos nós
	_build_tree_ui()
	
	# Conecta sinais
	hero.stats_changed.connect(_update_points)
	_update_points()
	
	# Centraliza no primeiro nó disponível ou desbloqueado
	call_deferred("_center_on_start")


func _build_tree_ui() -> void:
	# Limpa UI anterior
	for child in _canvas.get_children():
		child.queue_free()
	_nodes_ui.clear()
	
	if not _tree:
		return
	
	# Calcula layout dos nós (algoritmo simples: colunas por profundidade)
	var depths: Dictionary = _calculate_depths()
	var columns: Dictionary = {}
	for node_id in depths:
		var d: int = depths[node_id]
		if not columns.has(d):
			columns[d] = []
		columns[d].append(node_id)
	
	var max_depth := 0
	for d in columns.keys():
		if d > max_depth:
			max_depth = d
	
	# Posiciona nós
	var col_spacing := 280.0
	var row_spacing := 140.0
	var start_x := 100.0
	var start_y := 400.0  # Centro vertical
	
	for d in range(max_depth + 1):
		if not columns.has(d):
			continue
		var nodes_in_col: Array[StringName] = []
		for n in columns[d]:
			nodes_in_col.append(StringName(n))
		var col_x: float = start_x + d * col_spacing
		var total_h: float = (nodes_in_col.size() - 1) * row_spacing
		var col_start_y: float = start_y - total_h * 0.5
		
		for i in range(nodes_in_col.size()):
			var node_id := nodes_in_col[i]
			var node := _tree.get_node(node_id)
			if not node:
				continue
			var y := col_start_y + i * row_spacing
			_create_node_ui(node, Vector2(col_x, y))
	
	# Desenha linhas de conexão (feito no _draw do canvas)
	_canvas.queue_redraw()


func _calculate_depths() -> Dictionary:
	"""Calcula profundidade (coluna) de cada nó baseado em pré-requisitos."""
	var depths: Dictionary[StringName, int] = {}
	var visited: Dictionary[StringName, bool] = {}
	var stack: Array[Dictionary] = []
	
	# Começa dos nós raiz (sem pré-requisitos)
	for n in _tree.nodes:
		if n.requires.is_empty():
			stack.append({"node_id": n.id, "depth": 0})
	
	while stack.size() > 0:
		var item: Dictionary = stack.pop_back()
		var node_id: StringName = item.node_id
		var depth: int = item.depth
		
		if visited.has(node_id):
			# Atualiza para a maior profundidade (nós podem ter múltiplos caminhos)
			depths[node_id] = max(depths[node_id], depth)
			continue
		visited[node_id] = true
		depths[node_id] = depth
		
		var node := _tree.get_node(node_id)
		if not node:
			continue
		
		for dep_id in node.requires:
			stack.append({"node_id": dep_id, "depth": depth - 1})
		
		# Visita dependentes
		for dep in _tree.get_dependent_nodes(node_id):
			stack.append({"node_id": dep.id, "depth": depth + 1})
	
	return depths


func _create_node_ui(node: SkillNodeData, pos: Vector2) -> void:
	var container := Control.new()
	container.name = "Node_%s" % node.id
	container.position = pos
	container.custom_minimum_size = Vector2(72, 72)
	_canvas.add_child(container)
	
	# Botão do nó
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(64, 64)
	btn.position = Vector2(4, 4)
	btn.flat = true
	btn.focus_mode = Control.FOCUS_NONE
	container.add_child(btn)
	
	# Ícone
	var icon := SpritePreview.new()
	icon.custom_minimum_size = Vector2(48, 48)
	icon.position = Vector2(8, 8)
	icon.set_sprite(node.icon, Color.WHITE)
	btn.add_child(icon)
	
	# Estado visual
	var is_unlocked := node.id in hero.tree_unlocked
	var is_available := node.is_available(hero.tree_unlocked)
	var rank := hero.get_tree_node_rank(node.id)
	var rank_lbl: Label = null
	
	_update_node_visual(btn, icon, is_unlocked, is_available, rank, node.max_rank)
	
	# Tooltip e click
	btn.mouse_entered.connect(func(): _show_tooltip(node, btn))
	btn.mouse_exited.connect(func(): _hide_tooltip())
	btn.pressed.connect(func(): _on_node_pressed(node))
	
	# Label do rank (se desbloqueado)
	if is_unlocked:
		rank_lbl = Label.new()
		rank_lbl.text = "%d/%d" % [rank, node.max_rank]
		rank_lbl.custom_minimum_size = Vector2(64, 20)
		rank_lbl.position = Vector2(0, 52)
		rank_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rank_lbl.add_theme_font_size_override("font_size", 12)
		rank_lbl.add_theme_color_override("font_color", Color(1, 1, 0.5))
		container.add_child(rank_lbl)
	
	_nodes_ui[node.id] = {
		"container": container,
		"button": btn,
		"icon": icon,
		"pos": pos,
		"node": node,
		"rank_label": rank_lbl
	}


func _update_node_visual(btn: Button, icon: SpritePreview, unlocked: bool, available: bool, rank: int, max_rank: int) -> void:
	var style_normal := StyleBoxFlat.new()
	style_normal.corner_radius_top_left = 32
	style_normal.corner_radius_top_right = 32
	style_normal.corner_radius_bottom_left = 32
	style_normal.corner_radius_bottom_right = 32
	style_normal.border_width_left = 3
	style_normal.border_width_right = 3
	style_normal.border_width_top = 3
	style_normal.border_width_bottom = 3
	
	if unlocked:
		# Verde - comprado
		style_normal.bg_color = Color(0.1, 0.25, 0.1, 0.95)
		style_normal.border_color = Color(0.3, 1, 0.3)
		icon.modulate = Color.WHITE
		btn.disabled = rank >= max_rank
	elif available:
		# Dourado - disponível
		style_normal.bg_color = Color(0.3, 0.2, 0.05, 0.95)
		style_normal.border_color = Color(1, 0.85, 0.2)
		icon.modulate = Color.WHITE
		btn.disabled = false
	else:
		# Cinza - bloqueado
		style_normal.bg_color = Color(0.15, 0.15, 0.15, 0.9)
		style_normal.border_color = Color(0.4, 0.4, 0.4)
		icon.modulate = Color(0.5, 0.5, 0.5)
		btn.disabled = true
	
	btn.add_theme_stylebox_override("normal", style_normal)
	btn.add_theme_stylebox_override("hover", style_normal)
	btn.add_theme_stylebox_override("pressed", style_normal)
	btn.add_theme_stylebox_override("disabled", style_normal)
	btn.add_theme_stylebox_override("focus", style_normal)


func _on_node_pressed(node: SkillNodeData) -> void:
	if hero.tree_points <= 0:
		hud.show_message("Sem pontos de árvore!", Color(1, 0.4, 0.4), 1.5)
		return
	
	if node.id in hero.tree_unlocked:
		var current_rank := hero.get_tree_node_rank(node.id)
		if current_rank >= node.max_rank:
			hud.show_message("Nó no rank máximo!", Color(1, 0.7, 0.3), 1.5)
			return
	
	if not node.is_available(hero.tree_unlocked):
		var req_names: Array = []
		for req_id in node.requires:
			var req_node := _tree.get_node(req_id)
			if req_node:
				req_names.append(req_node.display_name)
		hud.show_message("Pré-requisitos: %s" % ", ".join(req_names), Color(1, 0.5, 0.3), 2.0)
		return
	
	# Compra o nó
	if hero.spend_tree_point(node.id):
		Sfx.play(&"click")
		_update_node_ui(node.id)
		_update_points()
		_canvas.queue_redraw()  # Redesenha linhas
		hud.show_message("%s adquirido! (Rank %d)" % [node.display_name, hero.get_tree_node_rank(node.id)], Color(0.4, 1, 0.4), 1.5)
	else:
		hud.show_message("Não foi possível adquirir", Color(1, 0.3, 0.3), 1.5)


func _update_node_ui(node_id: StringName) -> void:
	if not _nodes_ui.has(node_id):
		return
	var ui: Dictionary = _nodes_ui[node_id]
	var node: SkillNodeData = ui["node"]
	var btn: Button = ui["button"]
	var icon: SpritePreview = ui["icon"]
	var is_unlocked := node_id in hero.tree_unlocked
	var is_available := node.is_available(hero.tree_unlocked)
	var rank := hero.get_tree_node_rank(node_id)
	
	_update_node_visual(btn, icon, is_unlocked, is_available, rank, node.max_rank)
	
	# Atualiza/cria label de rank
	if is_unlocked:
		if not ui["rank_label"]:
			var rank_lbl := Label.new()
			rank_lbl.custom_minimum_size = Vector2(64, 20)
			rank_lbl.position = Vector2(0, 52)
			rank_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			rank_lbl.add_theme_font_size_override("font_size", 12)
			rank_lbl.add_theme_color_override("font_color", Color(1, 1, 0.5))
			ui["container"].add_child(rank_lbl)
			ui["rank_label"] = rank_lbl
		ui["rank_label"].text = "%d/%d" % [rank, node.max_rank]
		ui["rank_label"].visible = true
	elif ui["rank_label"]:
		ui["rank_label"].visible = false


func _update_points() -> void:
	_points_label.text = "Pontos de Arvore: [color=#e8c060]%d[/color]" % hero.tree_points


func _show_tooltip(node: SkillNodeData, btn: Button) -> void:
	if _tooltip:
		_hide_tooltip()
	
	_tooltip = Control.new()
	_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(_tooltip)
	_tooltip.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_tooltip.position = btn.get_global_position() + Vector2(70, -20)
	
	var panel := PanelContainer.new()
	var style := UIKit.box(Color(0.05, 0.05, 0.02, 0.95), Color(0.7, 0.6, 0.2), 1, 8)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)
	_tooltip.add_child(panel)
	
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 4)
	panel.add_child(content)
	
	var name_lbl := UIKit.label("[font_size=16][color=#e8c060]%s[/color][/font_size]" % node.display_name, 16)
	content.add_child(name_lbl)
	
	if node.description != "":
		var desc := UIKit.label(node.description, 14, UIKit.TEXT_DIM, true)
		desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		content.add_child(desc)
	
	var rank := hero.get_tree_node_rank(node.id)
	var max_rank := node.max_rank
	
	if rank > 0:
		var current := UIKit.label("Rank atual: %d/%d" % [rank, max_rank], 14, Color(0.5, 1, 0.5))
		content.add_child(current)
		var effect := node.get_effect_description(rank)
		if effect != "":
			content.add_child(UIKit.label("Efeito: %s" % effect, 13, Color(0.7, 1, 0.7)))
	else:
		var locked := UIKit.label("Bloqueado", 14, Color(0.7, 0.7, 0.7))
		content.add_child(locked)
	
	if not node.requires.is_empty():
		var reqs: Array = []
		for req_id in node.requires:
			var req_node := _tree.get_node(req_id)
			if req_node:
				var req_rank := hero.get_tree_node_rank(req_id)
				var color := "color=#7fff7f" if req_rank > 0 else "color=#ff7f7f"
				reqs.append("[%s]%s[/color] (rank %d)" % [color, req_node.display_name, req_rank])
		content.add_child(UIKit.separator())
		content.add_child(UIKit.label("Requer: %s" % ", ".join(reqs), 13, UIKit.TEXT_DIM))
	
	if rank < max_rank and (rank > 0 or node.is_available(hero.tree_unlocked)):
		var next_rank: int = max(rank + 1, 1)
		var next_effect := node.get_effect_description(next_rank)
		if next_effect != "":
			content.add_child(UIKit.separator())
			content.add_child(UIKit.label("[color=#ffff7f]Próximo rank (%d): %s[/color]" % [next_rank, next_effect], 13))
	
	var cost_lbl := UIKit.label("Custo: 1 ponto de árvore", 13, Color(1, 0.9, 0.4))
	content.add_child(cost_lbl)


func _hide_tooltip() -> void:
	if _tooltip:
		_tooltip.queue_free()
		_tooltip = null


func _center_on_start() -> void:
	# Tenta centralizar no primeiro nó disponível ou desbloqueado
	var target_pos := Vector2.ZERO
	var found := false
	
	for n in _tree.nodes:
		if n.id in hero.tree_unlocked or n.is_available(hero.tree_unlocked):
			if _nodes_ui.has(n.id):
				target_pos = _nodes_ui[n.id]["container"].position
				found = true
				break
	
	if not found and _nodes_ui.size() > 0:
		# Primeiro nó da árvore
		for n in _tree.nodes:
			if _nodes_ui.has(n.id):
				target_pos = _nodes_ui[n.id]["container"].position
				break
	
	# Centraliza via scroll (aproximado)
	if found or target_pos != Vector2.ZERO:
		# O ScrollContainer não tem API direta, usamos o viewport
		call_deferred("_do_center", target_pos)


func _do_center(target: Vector2) -> void:
	# Implementação simplificada - em produção usaria ScrollContainer scroll
	pass


func _canvas_draw() -> void:
	# Desenha linhas conectando nós
	if not _tree or _nodes_ui.is_empty():
		return
	
	var line_color_locked := Color(0.3, 0.3, 0.3, 0.5)
	var line_color_active := Color(0.5, 0.8, 0.3, 0.8)
	var line_color_available := Color(1, 0.85, 0.2, 0.8)
	
	for node_id in _nodes_ui:
		var ui: Dictionary = _nodes_ui[node_id]
		var node: SkillNodeData = ui["node"]
		var from_pos: Vector2 = ui["pos"] + Vector2(36, 36)  # Centro do nó
		
		for req_id in node.requires:
			if _nodes_ui.has(req_id):
				var req_ui: Dictionary = _nodes_ui[req_id]
				var to_pos: Vector2 = req_ui["pos"] + Vector2(36, 36)
				
				# Cor da linha baseada no estado
				var line_color := line_color_locked
				if req_id in hero.tree_unlocked:
					if node.id in hero.tree_unlocked:
						line_color = line_color_active
					elif node.is_available(hero.tree_unlocked):
						line_color = line_color_available
				
				# Desenha linha curva (bezier simples)
				var mid_x := (from_pos.x + to_pos.x) * 0.5
				var p1 := Vector2(from_pos.x, from_pos.y)
				var p2 := Vector2(mid_x, from_pos.y)
				var p3 := Vector2(mid_x, to_pos.y)
				var p4 := Vector2(to_pos.x, to_pos.y)
				
				# Aproximação com segmentos retos
				var segments := 10
				var prev := p1
				for i in range(1, segments + 1):
					var t := float(i) / segments
					# Bezier cúbica
					var u := 1.0 - t
					var x := u*u*u*p1.x + 3*u*u*t*p2.x + 3*u*t*t*p3.x + t*t*t*p4.x
					var y := u*u*u*p1.y + 3*u*u*t*p2.y + 3*u*t*t*p3.y + t*t*t*p4.y
					var curr := Vector2(x, y)
					_canvas.draw_line(prev, curr, line_color, 2.0)
					prev = curr


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAW:
		_canvas_draw()


func _on_canvas_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_dragging = true
			_drag_offset = event.position
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_dragging = false
	elif event is InputEventMouseMotion and _dragging:
		# Scroll manual arrastando
		var scroll_container := _canvas.get_parent()
		if scroll_container is ScrollContainer:
			scroll_container.scroll_horizontal -= event.relative.x
			scroll_container.scroll_vertical -= event.relative.y


## Atualiza a UI (pontos, estados dos nós)
func refresh() -> void:
	_update_points()
	for node_id in _nodes_ui:
		_update_node_ui(node_id)
	_canvas.queue_redraw()