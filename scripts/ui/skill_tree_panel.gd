class_name SkillTreePanel
extends PanelContainer
## Painel da Árvore de Habilidades (Fase 10.4)
## Nós clicáveis, conexões visuais, tooltips, sistema de pontos de árvore.

## Preloads para type hints funcionarem em parse time
const SkillTreeDataRes := preload("res://scripts/data/skill_tree_data.gd")
const SkillNodeDataRes := preload("res://scripts/data/skill_node_data.gd")

var hud: HUD
var hero: Hero
var _tree: SkillTreeDataRes
var _canvas: Control
var _points_label: Label = null
var _nodes_ui: Dictionary = {}  # node_id -> {container, btn, icon, pos, node, rank_label}
var _tooltip: Control = null
var _drag_offset := Vector2.ZERO
var _dragging := false
var _bg_rect: ColorRect = null
var _reset_btn: Button = null
var _pulse_tweens: Dictionary = {}  # node_id -> Tween
var _zoom: float = 1.0
var _min_zoom: float = 0.5
var _max_zoom: float = 2.0

# Cores de estado dos nós
const COLOR_LOCKED_BG := Color(0.15, 0.15, 0.15, 0.9)
const COLOR_LOCKED_BORDER := Color(0.4, 0.4, 0.4)
const COLOR_AVAILABLE_BG := Color(0.3, 0.2, 0.05, 0.95)
const COLOR_AVAILABLE_BORDER := Color(1, 0.85, 0.2)
const COLOR_UNLOCKED_BG := Color(0.1, 0.25, 0.1, 0.95)
const COLOR_UNLOCKED_BORDER := Color(0.3, 1, 0.3)
const COLOR_LINE_LOCKED := Color(0.3, 0.3, 0.3, 0.5)
const COLOR_LINE_ACTIVE := Color(0.5, 0.8, 0.3, 0.8)
const COLOR_LINE_AVAILABLE := Color(1, 0.85, 0.2, 0.8)

# Espaçamento do layout
const COL_SPACING := 300.0
const ROW_SPACING := 160.0
const START_X := 120.0
const START_Y := 400.0


func setup(p_hud: HUD, p_hero: Hero) -> void:
	hud = p_hud
	hero = p_hero
	
	add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	var w := UIKit.window_panel("Árvore de Habilidades", Vector2(780, 540), func(): hud.toggle_skill_tree())
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
	
	var title := UIKit.title("%s" % hero.cls.display_name, 24)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(title)
	
	_points_label = Label.new()
	_points_label.text = "Pontos de Árvore: [color=#F0C060]%d[/color]" % hero.tree_points
	_points_label.bbcode_enabled = true
	_points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_points_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_points_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_points_label.add_theme_font_size_override("font_size", 18)
	_points_label.add_theme_color_override("font_color", Color(1, 0.9, 0.4))
	header.add_child(_points_label)

	# Botão de reset de pontos (respec)
	var reset_btn := Button.new()
	reset_btn.text = "Resetar Pontos"
	reset_btn.custom_minimum_size = Vector2(100, 30)
	reset_btn.disabled = hero.tree_unlocked.is_empty()
	reset_btn.add_theme_font_size_override("font_size", 12)
	reset_btn.pressed.connect(func(): _on_respec_tree())
	header.add_child(reset_btn)
	_reset_btn = reset_btn
	
	# Canvas com scroll
	var scroll_container := ScrollContainer.new()
	scroll_container.custom_minimum_size = Vector2(760, 460)
	scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	body.add_child(scroll_container)
	
	_canvas = Control.new()
	_canvas.custom_minimum_size = Vector2(1500, 800)
	_canvas.mouse_filter = Control.MOUSE_FILTER_PASS
	_canvas.draw.connect(_canvas_draw)
	scroll_container.add_child(_canvas)
	
	# Fundo do canvas
	_bg_rect = ColorRect.new()
	_bg_rect.color = Color(0.05, 0.04, 0.03, 0.9)
	_bg_rect.custom_minimum_size = Vector2(1500, 800)
	_canvas.add_child(_bg_rect)
	
	# Carrega a árvore da classe
	_tree = DB.get_skill_tree(hero.cls.id)
	if not _tree:
		var msg := UIKit.label("Árvore de habilidades não disponível para %s" % hero.cls.display_name, 16, UIKit.TEXT_DIM, true)
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
		if child != _bg_rect:
			child.queue_free()
	_nodes_ui.clear()
	
	if not _tree:
		return
	
	# Calcula layout dos nós (colunas por profundidade)
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
	for d in range(max_depth + 1):
		if not columns.has(d):
			continue
		var nodes_in_col: Array[StringName] = []
		for n in columns[d]:
			nodes_in_col.append(StringName(n))
		var col_x: float = START_X + d * COL_SPACING
		var total_h: float = (nodes_in_col.size() - 1) * ROW_SPACING
		var col_start_y: float = START_Y - total_h * 0.5
		
		for i in range(nodes_in_col.size()):
			var node_id := nodes_in_col[i]
			var node := _tree.get_node(node_id)
			if not node:
				continue
			var y := col_start_y + i * ROW_SPACING
			_create_node_ui(node, Vector2(col_x, y))
	
	# Desenha linhas de conexão (feito no _draw do canvas)
	_canvas.queue_redraw()


func _calculate_depths() -> Dictionary:
	"""Calcula profundidade (coluna) de cada nó baseado em pré-requisitos."""
	var depths: Dictionary[StringName, int] = {}
	var visited: Dictionary[StringName, bool] = {}
	var stack: Array[Dictionary] = []
	
	# Começa dos nós raiz (sem pré-requisitos) - profundidade 0 (esquerda)
	for n in _tree.nodes:
		if n.requires.is_empty():
			stack.append({"node_id": n.id, "depth": 0})
	
	while stack.size() > 0:
		var item: Dictionary = stack.pop_back()
		var node_id: StringName = item.node_id
		var depth: int = item.depth
		
		if visited.has(node_id):
			depths[node_id] = max(depths.get(node_id, -2147483647), depth)
			continue
		visited[node_id] = true
		depths[node_id] = depth
		
		var node := _tree.get_node(node_id)
		if not node:
			continue
		
		# PRÉ-REQUISITOS: vão para a ESQUERDA (depth - 1)
		for req_id in node.requires:
			stack.append({"node_id": req_id, "depth": depth - 1})
		
		# DEPENDENTES: vão para a DIREITA (depth + 1)
		for dep in _tree.get_dependent_nodes(node_id):
			stack.append({"node_id": dep.id, "depth": depth + 1})
	
	# Normaliza para começar em 0
	var min_depth := INF
	for d in depths.values():
		if d < min_depth:
			min_depth = d
	if min_depth < 0:
		for k in depths.keys():
			depths[k] -= min_depth
	
	return depths


func _create_node_ui(node: SkillNodeDataRes, pos: Vector2) -> void:
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
	
	# Usa ID do nó para rastrear tween (precisamos achar o node_id pelo btn)
	var node_id: StringName = ""
	for k in _nodes_ui:
		if _nodes_ui[k]["button"] == btn:
			node_id = k
			break
	
	if unlocked:
		# Verde - comprado
		style_normal.bg_color = Color(0.1, 0.25, 0.1, 0.95)
		style_normal.border_color = Color(0.3, 1, 0.3)
		icon.modulate = Color.WHITE
		btn.disabled = rank >= max_rank
		if rank >= max_rank:
			style_normal.bg_color = Color(0.05, 0.15, 0.05, 0.95)
		# Para animações existentes
		if _pulse_tweens.has(node_id) and _pulse_tweens[node_id].is_valid():
			_pulse_tweens[node_id].kill()
			_pulse_tweens.erase(node_id)
		btn.modulate = Color.WHITE
	elif available:
		# Dourado - disponível com pulso sutil na borda
		style_normal.bg_color = Color(0.3, 0.2, 0.05, 0.95)
		style_normal.border_color = Color(1, 0.85, 0.2)
		icon.modulate = Color.WHITE
		btn.disabled = false
		# Animação de pulso contínuo na borda
		if not _pulse_tweens.has(node_id) or not _pulse_tweens[node_id].is_valid():
			var tw := btn.create_tween()
			tw.set_loops()
			# Pulsar a cor da borda entre dourado forte e mais fraco
			tw.tween_property(style_normal, "border_color", Color(1, 0.85, 0.2, 1.0), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			tw.tween_property(style_normal, "border_color", Color(1, 0.7, 0.1, 0.6), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			_pulse_tweens[node_id] = tw
		btn.modulate = Color.WHITE
	else:
		# Cinza - bloqueado
		style_normal.bg_color = Color(0.15, 0.15, 0.15, 0.9)
		style_normal.border_color = Color(0.4, 0.4, 0.4)
		icon.modulate = Color(0.5, 0.5, 0.5)
		btn.disabled = true
		# Para animações
		if _pulse_tweens.has(node_id) and _pulse_tweens[node_id].is_valid():
			_pulse_tweens[node_id].kill()
			_pulse_tweens.erase(node_id)
		btn.modulate = Color.WHITE
	
	btn.add_theme_stylebox_override("normal", style_normal)
	btn.add_theme_stylebox_override("hover", style_normal)
	btn.add_theme_stylebox_override("pressed", style_normal)
	btn.add_theme_stylebox_override("disabled", style_normal)
	btn.add_theme_stylebox_override("focus", style_normal)


func _on_node_pressed(node: SkillNodeDataRes) -> void:
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
		# Animação de compra no nó
		var ui: Dictionary = _nodes_ui[node.id]
		if ui:
			var btn: Button = ui["button"]
			var _icon: SpritePreview = ui["icon"]
			
			# Para pulse tween anterior se existir
			if btn.has_meta("_pulse_tween") and btn.get_meta("_pulse_tween").is_valid():
				btn.get_meta("_pulse_tween").kill()
				btn.remove_meta("_pulse_tween")
			
			# Flash dourado + escala
			btn.modulate = Color(1, 1, 0.3)
			var tw: Tween = btn.create_tween()
			tw.set_parallel(true)
			tw.tween_property(btn, "modulate", Color.WHITE, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tw.tween_property(btn, "scale", Vector2(1.3, 1.3), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tw.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			
			# Partículas simples (círculos expandindo)
			var canvas := _canvas
			for i in range(8):
				var angle := (PI * 2 / 8) * i
				var dir := Vector2(cos(angle), sin(angle))
				var part := ColorRect.new()
				part.color = Color(1, 0.85, 0.2, 0.8)
				part.custom_minimum_size = Vector2(4, 4)
				part.position = btn.get_global_position() + Vector2(32, 32) - canvas.global_position
				canvas.add_child(part)
				var ptw := part.create_tween()
				ptw.set_parallel(true)
				ptw.tween_property(part, "position", part.position + dir * 80, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				ptw.tween_property(part, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				ptw.tween_callback(func(): part.queue_free())
		
		refresh()
		hud.show_message("%s adquirido! (Rank %d)" % [node.display_name, hero.get_tree_node_rank(node.id)], Color(0.4, 1, 0.4), 1.5)
	else:
		hud.show_message("Não foi possível adquirir", Color(1, 0.3, 0.3), 1.5)


func _update_node_ui(node_id: StringName) -> void:
	if not _nodes_ui.has(node_id):
		return
	var ui: Dictionary = _nodes_ui[node_id]
	var node: SkillNodeDataRes = ui["node"]
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
	if _points_label:
		_points_label.text = "Pontos de Árvore: [color=#F0C060]%d[/color]" % hero.tree_points


func _rich_label(text: String, p_size: int = 14, color: Color = Color(1, 0.9, 0.8), p_wrap: bool = false) -> RichTextLabel:
	"""Cria um RichTextLabel com BBCode habilitado para evitar vazamento de tags."""
	var fit_content := not p_wrap
	var lbl := UIKit.rich(text, fit_content)
	lbl.add_theme_font_size_override("normal_font_size", p_size)
	lbl.add_theme_color_override("default_color", color)
	if p_wrap:
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
		lbl.custom_minimum_size = Vector2(260, 0)
	return lbl


func _show_tooltip(node: SkillNodeData, btn: Button) -> void:
	if _tooltip:
		_hide_tooltip()
	
	_tooltip = Control.new()
	_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(_tooltip)
	_tooltip.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_tooltip.position = btn.get_global_position() + Vector2(75, -10)
	
	var panel := PanelContainer.new()
	var style := UIKit.box(Color(0.06, 0.05, 0.03, 0.98), Color(0.7, 0.6, 0.2), 1, 8)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", style)
	_tooltip.add_child(panel)
	
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 6)
	panel.add_child(content)
	
	# Nome do nó (BBCode)
	var name_lbl := _rich_label("[font_size=18][color=#F0C060]%s[/color][/font_size]" % node.display_name, 18)
	content.add_child(name_lbl)
	
	# Descrição
	if node.description != "":
		var desc := _rich_label(node.description, 14, UIKit.TEXT_DIM, true)
		content.add_child(desc)
	
	var rank := hero.get_tree_node_rank(node.id)
	var max_rank := node.max_rank
	
	if rank > 0:
		var current := _rich_label("[color=#8FF88F]Rank atual: %d/%d[/color]" % [rank, max_rank], 14)
		content.add_child(current)
		var effect := node.get_effect_description(rank)
		if effect != "":
			content.add_child(_rich_label("[color=#B0FFB0]Efeito: %s[/color]" % effect, 13))
	else:
		var locked := _rich_label("[color=#A0A0A0]Bloqueado[/color]", 14)
		content.add_child(locked)
	
	if not node.requires.is_empty():
		var reqs: Array = []
		for req_id in node.requires:
			var req_node := _tree.get_node(req_id)
			if req_node:
				var req_rank := hero.get_tree_node_rank(req_id)
				var color := "[color=#7FFF7F]" if req_rank > 0 else "[color=#FF7F7F]"
				reqs.append("%s%s[/color] (rank %d)" % [color, req_node.display_name, req_rank])
		content.add_child(UIKit.separator())
		content.add_child(_rich_label("[color=#9A917F]Requer: %s[/color]" % ", ".join(reqs), 13))
	
	if rank < max_rank and (rank > 0 or node.is_available(hero.tree_unlocked)):
		var next_rank: int = max(rank + 1, 1)
		var next_effect := node.get_effect_description(next_rank)
		if next_effect != "":
			content.add_child(UIKit.separator())
			content.add_child(_rich_label("[color=#FFFF7F]Próximo rank (%d): %s[/color]" % [next_rank, next_effect], 13))
	
	var cost_lbl := _rich_label("[color=#F0E0A0]Custo: 1 ponto de árvore[/color]", 13)
	content.add_child(cost_lbl)


func _on_respec_tree() -> void:
	hero.respec_tree()
	Sfx.play(&"click")
	refresh()
	hud.show_message("Pontos de árvore resetados!", Color(1, 0.9, 0.4), 1.5)


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
	
	if found or target_pos != Vector2.ZERO:
		call_deferred("_do_center", target_pos)


func _do_center(target: Vector2) -> void:
	# Centraliza via scroll (aproximado)
	var scroll_container: ScrollContainer = _canvas.get_parent() as ScrollContainer
	if scroll_container:
		var viewport_size: Vector2 = scroll_container.get_viewport_rect().size
		var offset: Vector2 = target - viewport_size * 0.5
		offset.x = clamp(offset.x, 0, _canvas.custom_minimum_size.x - viewport_size.x)
		offset.y = clamp(offset.y, 0, _canvas.custom_minimum_size.y - viewport_size.y)
		scroll_container.scroll_horizontal = int(offset.x)
		scroll_container.scroll_vertical = int(offset.y)


func _canvas_draw() -> void:
	# Desenha linhas conectando nós
	if not _tree or _nodes_ui.is_empty():
		return
	
	var line_color_locked: Color = COLOR_LINE_LOCKED
	var line_color_active: Color = COLOR_LINE_ACTIVE
	var line_color_available: Color = COLOR_LINE_AVAILABLE
	
	for node_id in _nodes_ui:
		var ui: Dictionary = _nodes_ui[node_id]
		var node: SkillNodeDataRes = ui["node"]
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
				var p1: Vector2 = Vector2(from_pos.x, from_pos.y)
				var p2: Vector2 = Vector2(mid_x, from_pos.y)
				var p3: Vector2 = Vector2(mid_x, to_pos.y)
				var p4: Vector2 = Vector2(to_pos.x, to_pos.y)
				
				# Aproximação com segmentos retos
				var segments := 10
				var prev := p1
				for i in range(1, segments + 1):
					var t := float(i) / segments
					var u := 1.0 - t
					var x := u*u*u*p1.x + 3*u*u*t*p2.x + 3*u*t*t*p3.x + t*t*t*p4.x
					var y := u*u*u*p1.y + 3*u*u*t*p2.y + 3*u*t*t*p3.y + t*t*t*p4.y
					var curr: Vector2 = Vector2(x, y)
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
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			# Zoom com scroll (sem Ctrl)
			var factor := 1.1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 0.9
			_apply_zoom(factor, event.position)
			accept_event()
	elif event is InputEventMouseMotion and _dragging:
		# Scroll manual arrastando
		var scroll_container: ScrollContainer = _canvas.get_parent() as ScrollContainer
		if scroll_container:
			scroll_container.scroll_horizontal -= event.relative.x
			scroll_container.scroll_vertical -= event.relative.y


func _apply_zoom(factor: float, _center: Vector2) -> void:
	var new_zoom: float = clamp(_zoom * factor, _min_zoom, _max_zoom)
	if new_zoom == _zoom:
		return
	_zoom = new_zoom
	_canvas.scale = Vector2(_zoom, _zoom)
	# Ajusta tamanho mínimo do canvas para o zoom
	_canvas.custom_minimum_size = Vector2(1500 * _zoom, 800 * _zoom)
	_canvas.queue_redraw()


## Atualiza a UI (pontos, estados dos nós)
func refresh() -> void:
	_update_points()
	for node_id in _nodes_ui:
		_update_node_ui(node_id)
	if _reset_btn:
		_reset_btn.disabled = hero.tree_unlocked.is_empty()
	_canvas.queue_redraw()


func cleanup() -> void:
	"""Desconectar signals para evitar memory leak"""
	if _canvas.draw.is_connected(_canvas_draw):
		_canvas.draw.disconnect(_canvas_draw)
	if hero.stats_changed.is_connected(_update_points):
		hero.stats_changed.disconnect(_update_points)
	if _tooltip:
		_hide_tooltip()
