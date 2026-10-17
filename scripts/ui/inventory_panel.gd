class_name InventoryPanel
extends PanelContainer
## Inventário estilo Diablo: equipamento + grade com itens de tamanhos variados.
## Clique esquerdo pega/solta (troca), clique direito equipa/desequipa,
## soltar fora do painel joga o item no chão.

const CELL := 40

var hud: HUD
var hero: Hero
var held: Item          ## Item "na mão" do cursor
var _grid_view: Control
var _equip_views := {}
var _gold_label: Label
var _stats_label: RichTextLabel
var _tooltip: PanelContainer
var _tooltip_text: RichTextLabel


func setup(p_hud: HUD, p_hero: Hero) -> void:
	hud = p_hud
	hero = p_hero
	var w := UIKit.window_panel("Inventário", Vector2(CELL * hero.inventory.cols + 24, 0), func(): hud.toggle_inventory())
	add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	add_child(w.panel)
	var body: VBoxContainer = w.body

	# Equipamento em formato de "boneco" (paper doll)
	var doll := Control.new()
	doll.custom_minimum_size = Vector2(CELL * 7.5, CELL * 5.3)
	doll.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	body.add_child(doll)
	var layout := {
		"helm": Rect2(2.75, 0.0, 2.0, 1.6), "amulet": Rect2(5.0, 0.3, 1.1, 1.1),
		"weapon": Rect2(0.2, 1.3, 2.0, 2.8), "chest": Rect2(2.6, 1.8, 2.3, 2.3), "offhand": Rect2(5.3, 1.3, 2.0, 2.8),
		"ring": Rect2(0.6, 4.2, 1.1, 1.1), "boots": Rect2(2.75, 4.2, 2.0, 1.1),
	}
	for s in DB.EQUIP_SLOTS:
		var r: Rect2 = layout[s]
		var v := _EquipView.new()
		v.panel = self
		v.slot = s
		v.position = r.position * CELL
		v.size = r.size * CELL
		v.custom_minimum_size = r.size * CELL
		doll.add_child(v)
		_equip_views[s] = v

	_stats_label = UIKit.rich()
	body.add_child(_stats_label)
	body.add_child(UIKit.separator())

	_grid_view = _GridView.new()
	_grid_view.panel = self
	_grid_view.custom_minimum_size = Vector2(hero.inventory.cols * CELL, hero.inventory.rows * CELL)
	body.add_child(_grid_view)

	var bottom := HBoxContainer.new()
	body.add_child(bottom)
	_gold_label = UIKit.label("", 18, Color(1, 0.85, 0.3), true)
	_gold_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(_gold_label)
	bottom.add_child(UIKit.button("Vender Comuns e Mágicos", _sell_junk))
	var hint := UIKit.label("Clique: mover • Direito: equipar • Shift+Direito: vender", 12, UIKit.TEXT_DIM)
	body.add_child(hint)

	_tooltip = PanelContainer.new()
	_tooltip.add_theme_stylebox_override("panel", UIKit.box(Color(0.02, 0.015, 0.01, 0.97), UIKit.GOLD_DIM, 2, 3))
	_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tooltip.visible = false
	_tooltip.top_level = true
	_tooltip.z_index = 100
	_tooltip_text = UIKit.rich()
	_tooltip_text.custom_minimum_size = Vector2(300, 0)
	_tooltip.add_child(_tooltip_text)
	add_child(_tooltip)

	hero.inventory.changed.connect(refresh)
	hero.stats_changed.connect(refresh)
	hero.gold_changed.connect(func(_g): refresh())
	refresh()


func refresh() -> void:
	_gold_label.text = "Ouro: %d" % hero.gold
	_stats_label.text = "[center][color=#bbbbbb]DPS:[/color] [color=#ffffff]%.1f[/color]    [color=#bbbbbb]Armadura:[/color] [color=#ffffff]%d[/color]    [color=#bbbbbb]Vida:[/color] [color=#ffffff]%d[/color][/center]" % [hero.dps_estimate(), hero.armor(), hero.max_hp()]
	_grid_view.queue_redraw()
	for v in _equip_views.values():
		v.queue_redraw()


func _process(_delta: float) -> void:
	if held:
		_grid_view.queue_redraw()
	if _tooltip.visible:
		var mp := get_viewport().get_mouse_position()
		var vs := get_viewport_rect().size
		var p := mp + Vector2(18, 10)
		if p.x + _tooltip.size.x > vs.x:
			p.x = mp.x - _tooltip.size.x - 12
		if p.y + _tooltip.size.y > vs.y:
			p.y = vs.y - _tooltip.size.y - 4
		_tooltip.global_position = p


func show_tooltip(it: Item) -> void:
	if it == null or held:
		_tooltip.visible = false
		return
	var cmp: Item = hero.equipment.get(it.slot) if hero.equipment.get(it.slot) != it else null
	_tooltip_text.text = it.tooltip_bbcode(cmp, hero)
	_tooltip.visible = true
	_tooltip.reset_size()


func hide_tooltip() -> void:
	_tooltip.visible = false


func _draw_item(ci: CanvasItem, it: Item, rect: Rect2, dim := false) -> void:
	var c := it.rarity_color()
	ci.draw_rect(rect.grow(-1), Color(c.r * 0.18, c.g * 0.18, c.b * 0.18, 0.9))
	ci.draw_rect(rect.grow(-1), Color(c, 0.6), false, 1.0)
	var s := minf(rect.size.x, rect.size.y) * 0.8
	var icon_rect := Rect2(rect.get_center() - Vector2(s, s) * 0.5, Vector2(s, s))
	var tint := Color(1, 1, 1, 0.5 if dim else 1.0)
	if hero.equip_problem(it) != "" and it.slot in ["weapon", "offhand"] and not hero.can_use_category(it):
		tint = Color(1, 0.45, 0.45, tint.a)
	ci.draw_texture_rect(DB.icon(it.icon), icon_rect, false, tint)


func drop_held_to_world() -> void:
	if held == null:
		return
	LootDrop.drop_item(hud.world, hud.world.player.global_position, held)
	held = null
	refresh()


func _sell(it: Item) -> void:
	hero.inventory.remove(it)
	hero.add_gold(int(it.sell_value() * hero.sell_multiplier()))
	Sfx.play(&"coins")


func _sell_junk() -> void:
	var to_sell: Array[Item] = []
	for it in hero.inventory.items:
		if it.rarity <= Item.Rarity.MAGIC:
			to_sell.append(it)
	var total := 0
	for it in to_sell:
		total += int(it.sell_value() * hero.sell_multiplier())
		hero.inventory.items.erase(it)
	if total > 0:
		hero.add_gold(total)
		hero.inventory.changed.emit()
		Sfx.play(&"coins")
		hud.show_message("Vendido por %d de ouro" % total, Color(1, 0.85, 0.3))


func equip_from_inventory(it: Item) -> void:
	var problem := hero.equip_problem(it)
	if problem != "":
		hud.show_message(problem, Color(1, 0.5, 0.4))
		return
	hero.inventory.remove(it)
	for old in hero.equip(it):
		if not hero.inventory.add(old):
			LootDrop.drop_item(hud.world, hud.world.player.global_position, old)
	Sfx.play(&"equip")
	hide_tooltip()


# ================================================================== GRADE

class _GridView extends Control:
	var panel: InventoryPanel
	var _hover_cell := Vector2i(-1, -1)

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _cell_at(p: Vector2) -> Vector2i:
		return Vector2i(floori(p.x / InventoryPanel.CELL), floori(p.y / InventoryPanel.CELL))

	func _gui_input(event: InputEvent) -> void:
		var inv := panel.hero.inventory
		if event is InputEventMouseMotion:
			_hover_cell = _cell_at(event.position)
			panel.show_tooltip(inv.item_at(_hover_cell))
			queue_redraw()
		elif event is InputEventMouseButton and event.pressed:
			var cell := _cell_at(event.position)
			if event.button_index == MOUSE_BUTTON_LEFT:
				if panel.held == null:
					var it := inv.item_at(cell)
					if it:
						inv.remove(it)
						panel.held = it
						panel.hide_tooltip()
						Sfx.play(&"cloth")
				else:
					var pos := _anchor_for(panel.held, event.position)
					if inv.in_bounds(panel.held, pos):
						var over := inv.overlapping(panel.held, pos)
						if over.size() == 0:
							inv.place(panel.held, pos)
							panel.held = null
							Sfx.play(&"drop")
						elif over.size() == 1:
							var other: Item = over[0]
							inv.remove(other)
							inv.place(panel.held, pos)
							panel.held = other
							Sfx.play(&"drop")
				accept_event()
			elif event.button_index == MOUSE_BUTTON_RIGHT and panel.held == null:
				var it := inv.item_at(cell)
				if it:
					if Input.is_key_pressed(KEY_SHIFT):
						panel._sell(it)
					else:
						panel.equip_from_inventory(it)
				accept_event()

	func _anchor_for(it: Item, mouse: Vector2) -> Vector2i:
		var c := InventoryPanel.CELL
		var top_left := mouse - Vector2(it.size) * c * 0.5
		return Vector2i(roundi(top_left.x / c), roundi(top_left.y / c))

	func _notification(what: int) -> void:
		if what == NOTIFICATION_MOUSE_EXIT:
			_hover_cell = Vector2i(-1, -1)
			panel.hide_tooltip()
			queue_redraw()

	func _draw() -> void:
		var inv := panel.hero.inventory
		var cs := InventoryPanel.CELL
		for x in inv.cols:
			for y in inv.rows:
				var r := Rect2(x * cs, y * cs, cs, cs)
				draw_rect(r.grow(-1), Color(0.08, 0.06, 0.05))
				draw_rect(r.grow(-1), Color(0.22, 0.17, 0.12), false, 1.0)
		for it in inv.items:
			panel._draw_item(self, it, Rect2(Vector2(it.grid_pos) * cs, Vector2(it.size) * cs))
		if panel.held:
			var mouse := get_local_mouse_position()
			if Rect2(Vector2.ZERO, size).has_point(mouse):
				var pos := _anchor_for(panel.held, mouse)
				var ok := inv.in_bounds(panel.held, pos) and inv.overlapping(panel.held, pos).size() <= 1
				draw_rect(Rect2(Vector2(pos) * cs, Vector2(panel.held.size) * cs), Color(0.2, 0.8, 0.2, 0.25) if ok else Color(0.8, 0.1, 0.1, 0.25))


# ================================================================== EQUIPAMENTO

class _EquipView extends Control:
	var panel: InventoryPanel
	var slot := "weapon"

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _gui_input(event: InputEvent) -> void:
		var hero := panel.hero
		if event is InputEventMouseMotion:
			panel.show_tooltip(hero.equipment[slot])
		elif event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if panel.held:
					if panel.held.slot != slot:
						panel.hud.show_message("Este item não vai neste espaço", Color(1, 0.5, 0.4))
					elif hero.equip_problem(panel.held) != "":
						panel.hud.show_message(hero.equip_problem(panel.held), Color(1, 0.5, 0.4))
					else:
						var out := hero.equip(panel.held)
						panel.held = out.pop_front() if not out.is_empty() else null
						for extra in out:
							if not hero.inventory.add(extra):
								LootDrop.drop_item(panel.hud.world, panel.hud.world.player.global_position, extra)
						Sfx.play(&"equip")
				elif hero.equipment[slot]:
					panel.held = hero.unequip(slot)
					panel.hide_tooltip()
					Sfx.play(&"cloth")
			elif event.button_index == MOUSE_BUTTON_RIGHT and panel.held == null and hero.equipment[slot]:
				var it: Item = hero.equipment[slot]
				if hero.inventory.add(it):
					hero.unequip(slot)
					Sfx.play(&"cloth")
				else:
					panel.hud.show_message("Inventário cheio", Color(1, 0.5, 0.4))
			accept_event()
			queue_redraw()

	func _notification(what: int) -> void:
		if what == NOTIFICATION_MOUSE_EXIT:
			panel.hide_tooltip()

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		draw_rect(r, Color(0.05, 0.035, 0.03))
		var highlight := panel.held != null and panel.held.slot == slot
		draw_rect(r, UIKit.GOLD if highlight else UIKit.GOLD_DIM, false, 2.0)
		var it: Item = panel.hero.equipment[slot]
		if it:
			panel._draw_item(self, it, r.grow(-3))
		else:
			var f := UIKit.FONT_BODY
			draw_string(f, Vector2(0, size.y * 0.5 + 5), DB.SLOT_NAMES[slot], HORIZONTAL_ALIGNMENT_CENTER, size.x, 12, Color(0.45, 0.4, 0.35))
