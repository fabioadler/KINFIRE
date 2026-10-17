class_name HUD
extends CanvasLayer
## Interface em jogo estilo Diablo 3: globos, barra de habilidades, XP, alvo, minimapa e painéis.

const ORB_SHADER := preload("res://shaders/orb.gdshader")

var world: World
var player: Player
var hero: Hero

var _root: Control
var _hp_orb: ColorRect
var _res_orb: ColorRect
var _hp_text: Label
var _res_text: Label
var _slots: Array[SkillSlot] = []
var _potion_slot: SkillSlot
var _xp_bar: ProgressBar
var _xp_text: Label
var _target_box: PanelContainer
var _target_name: Label
var _target_bar: ProgressBar
var _location: Label
var _gold: Label
var _messages: VBoxContainer
var _buff_row: HBoxContainer
var _hover_label: Label
var _vignette: ColorRect
var _held_icon: TextureRect
var _points_hint: Button

var inventory: InventoryPanel
var character: CharacterPanel
var skills: SkillsPanel
var _pause_layer: Control
var _death_layer: Control
var _popup: Control


func setup(p_world: World, p_player: Player) -> void:
	world = p_world
	player = p_player
	hero = p_player.hero
	_build()


func _build() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_vignette = ColorRect.new()
	_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vignette.color = Color(0.6, 0, 0, 0)
	_root.add_child(_vignette)

	_build_bottom_bar()
	_build_top()

	_messages = VBoxContainer.new()
	_messages.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_messages.position = Vector2(-300, 120)
	_messages.custom_minimum_size = Vector2(600, 0)
	_messages.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_messages.alignment = BoxContainer.ALIGNMENT_BEGIN
	_root.add_child(_messages)

	_hover_label = UIKit.label("", 18, Color.WHITE, true)
	_hover_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_hover_label.add_theme_constant_override("outline_size", 5)
	_hover_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_hover_label)

	inventory = InventoryPanel.new()
	inventory.setup(self, hero)
	inventory.visible = false
	_root.add_child(inventory)
	character = CharacterPanel.new()
	character.setup(self, hero)
	character.visible = false
	_root.add_child(character)
	skills = SkillsPanel.new()
	skills.setup(self, hero)
	skills.visible = false
	_root.add_child(skills)

	_held_icon = TextureRect.new()
	_held_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_held_icon.custom_minimum_size = Vector2(40, 40)
	_held_icon.size = Vector2(40, 40)
	_held_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_held_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_held_icon.z_index = 90
	_root.add_child(_held_icon)

	get_viewport().size_changed.connect(_layout)
	_layout()


func _build_bottom_bar() -> void:
	var bar := PanelContainer.new()
	bar.name = "BottomBar"
	bar.add_theme_stylebox_override("panel", UIKit.box(Color(0.05, 0.035, 0.03, 0.92), UIKit.GOLD_DIM, 2, 6))
	_root.add_child(bar)
	var v := VBoxContainer.new()
	bar.add_child(v)

	_buff_row = HBoxContainer.new()
	_buff_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_buff_row.custom_minimum_size.y = 0
	v.add_child(_buff_row)

	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 6)
	h.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(h)

	_potion_slot = SkillSlot.new(-1, Game.key_name("potion"))
	_potion_slot.is_potion = true
	_potion_slot.player = player
	_potion_slot.clicked.connect(func(_s): player.use_potion())
	h.add_child(_potion_slot)
	h.add_child(_spacer(10))
	var keys := ["LMB", "RMB", Game.key_name("skill_1"), Game.key_name("skill_2"), Game.key_name("skill_3"), Game.key_name("skill_4")]
	for i in 6:
		var s := SkillSlot.new(i, keys[i])
		s.player = player
		s.clicked.connect(func(_s): toggle_skills())
		_slots.append(s)
		h.add_child(s)
	if hero.racial_skill():
		var rs := SkillSlot.new(Player.RACIAL_SLOT, Game.key_name("racial"))
		rs.player = player
		h.add_child(_spacer(6))
		h.add_child(rs)
	h.add_child(_spacer(10))
	for b in [["I", toggle_inventory, "Inventário (I)"], ["C", toggle_character, "Personagem (C)"], ["K", toggle_skills, "Habilidades (K)"], ["≡", toggle_pause, "Menu (Esc)"]]:
		var btn := Button.new()
		btn.text = b[0]
		btn.tooltip_text = b[2]
		btn.custom_minimum_size = Vector2(34, 52)
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(b[1])
		h.add_child(btn)

	var xp_row := Control.new()
	xp_row.custom_minimum_size = Vector2(0, 14)
	v.add_child(xp_row)
	_xp_bar = ProgressBar.new()
	_xp_bar.show_percentage = false
	_xp_bar.set_anchors_preset(Control.PRESET_FULL_RECT)
	_xp_bar.add_theme_stylebox_override("background", UIKit.box(Color(0.02, 0.02, 0.02), Color(0.2, 0.15, 0.1), 1, 2))
	var fill := UIKit.box(Color(0.75, 0.55, 0.15), Color(0.75, 0.55, 0.15), 0, 2)
	fill.content_margin_top = 0
	fill.content_margin_bottom = 0
	_xp_bar.add_theme_stylebox_override("fill", fill)
	xp_row.add_child(_xp_bar)
	_xp_text = UIKit.label("", 11, Color.WHITE)
	_xp_text.set_anchors_preset(Control.PRESET_FULL_RECT)
	_xp_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_xp_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_xp_text.add_theme_color_override("font_outline_color", Color.BLACK)
	_xp_text.add_theme_constant_override("outline_size", 3)
	xp_row.add_child(_xp_text)

	_hp_orb = _make_orb(Color(0.8, 0.05, 0.05))
	_res_orb = _make_orb(hero.cls.resource_color)
	_hp_text = _orb_label(_hp_orb)
	_res_text = _orb_label(_res_orb)
	_hp_orb.tooltip_text = "Vida"
	_res_orb.tooltip_text = hero.cls.resource_label

	_points_hint = Button.new()
	_points_hint.text = "+ Pontos de atributo"
	_points_hint.focus_mode = Control.FOCUS_NONE
	_points_hint.add_theme_color_override("font_color", Color(0.5, 1, 0.5))
	_points_hint.pressed.connect(toggle_character)
	_root.add_child(_points_hint)


func _spacer(w: int) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(w, 0)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


func _make_orb(color: Color) -> ColorRect:
	var orb := ColorRect.new()
	orb.custom_minimum_size = Vector2(120, 120)
	orb.size = Vector2(120, 120)
	var mat := ShaderMaterial.new()
	mat.shader = ORB_SHADER
	mat.set_shader_parameter("liquid_color", color)
	orb.material = mat
	orb.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(orb)
	return orb


func _orb_label(orb: Control) -> Label:
	var l := UIKit.label("", 14, Color.WHITE, true)
	l.set_anchors_preset(Control.PRESET_FULL_RECT)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 4)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	orb.add_child(l)
	return l


func _build_top() -> void:
	_target_box = PanelContainer.new()
	_target_box.add_theme_stylebox_override("panel", UIKit.box(Color(0.03, 0.02, 0.02, 0.85), UIKit.GOLD_DIM, 1, 3))
	_target_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_target_box.custom_minimum_size = Vector2(380, 0)
	_root.add_child(_target_box)
	var tv := VBoxContainer.new()
	_target_box.add_child(tv)
	_target_name = UIKit.label("", 17, Color.WHITE, true)
	_target_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tv.add_child(_target_name)
	_target_bar = ProgressBar.new()
	_target_bar.show_percentage = false
	_target_bar.custom_minimum_size = Vector2(0, 12)
	_target_bar.add_theme_stylebox_override("background", UIKit.box(Color(0.1, 0.02, 0.02), Color(0.3, 0.1, 0.1), 1, 2))
	var tf := UIKit.box(Color(0.75, 0.08, 0.06), Color(0.75, 0.08, 0.06), 0, 2)
	tf.content_margin_top = 0
	tf.content_margin_bottom = 0
	_target_bar.add_theme_stylebox_override("fill", tf)
	tv.add_child(_target_bar)
	_target_box.visible = false

	var info := VBoxContainer.new()
	info.position = Vector2(16, 12)
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(info)
	_location = UIKit.label("", 18, UIKit.GOLD, true)
	_location.add_theme_color_override("font_outline_color", Color.BLACK)
	_location.add_theme_constant_override("outline_size", 4)
	info.add_child(_location)
	_gold = UIKit.label("", 16, Color(1, 0.85, 0.3), true)
	_gold.add_theme_color_override("font_outline_color", Color.BLACK)
	_gold.add_theme_constant_override("outline_size", 4)
	info.add_child(_gold)

	var mm := Minimap.new(world)
	mm.name = "Minimap"
	_root.add_child(mm)


func _layout() -> void:
	var vs := _root.get_viewport_rect().size
	var bar: Control = _root.get_node("BottomBar")
	bar.reset_size()
	bar.position = Vector2((vs.x - bar.size.x) * 0.5, vs.y - bar.size.y - 6)
	_hp_orb.position = Vector2(bar.position.x - 128, vs.y - 128)
	_res_orb.position = Vector2(bar.position.x + bar.size.x + 8, vs.y - 128)
	_points_hint.position = Vector2(_hp_orb.position.x, _hp_orb.position.y - 40)
	_target_box.reset_size()
	_target_box.position = Vector2((vs.x - _target_box.size.x) * 0.5, 12)
	var mm: Control = _root.get_node("Minimap")
	mm.position = Vector2(vs.x - 190 - 14, 14)
	mm.modulate.a = float(Game.settings.minimap_opacity)
	mm.visible = mm.modulate.a > 0.01
	mm.size = Vector2(190, 190)
	_messages.position = Vector2(vs.x * 0.5 - 300, vs.y * 0.22)
	inventory.reset_size()
	inventory.position = Vector2(vs.x - inventory.size.x - 14, 14)
	character.reset_size()
	character.position = Vector2(14, 56)
	skills.reset_size()
	skills.position = (vs - skills.size) * 0.5 - Vector2(0, 40)


# ------------------------------------------------------------------ LOOP

func _process(delta: float) -> void:
	if player == null:
		return
	(_hp_orb.material as ShaderMaterial).set_shader_parameter("fill", clampf(player.hp / player.max_hp, 0, 1))
	if hero.cls.costs_life:
		(_res_orb.material as ShaderMaterial).set_shader_parameter("fill", clampf(player.hp / player.max_hp, 0, 1))
	else:
		(_res_orb.material as ShaderMaterial).set_shader_parameter("fill", clampf(player.resource / player.max_resource, 0, 1))
	_hp_text.text = "%d" % ceilf(player.hp)
	_res_text.text = "Pacto" if hero.cls.costs_life else "%d" % player.resource
	_xp_bar.max_value = hero.xp_to_next()
	_xp_bar.value = hero.xp
	_xp_text.text = "Nível %d  —  %d / %d XP" % [hero.level, hero.xp, hero.xp_to_next()]
	_location.text = world.region_name()
	var tl := world.time_label()
	_gold.text = ("Ouro: %d" % hero.gold) + (("   •   " + tl) if tl != "" else "")
	if _popup and is_instance_valid(_popup) and world.player.global_position.distance_to(_popup.get_meta("anchor")) > 40.0:
		close_popup()
	_points_hint.visible = hero.unspent_points > 0 and not character.visible
	_vignette.color.a = maxf(_vignette.color.a - delta * 1.5, 0.0)
	if player.hp / player.max_hp < 0.3 and not player.is_dead():
		_vignette.color.a = maxf(_vignette.color.a, 0.08 + sin(Time.get_ticks_msec() * 0.006) * 0.05)

	_update_target()
	_update_buffs()
	# Containers crescem mas não encolhem sozinhos: reajusta painéis abertos
	for p: Control in [inventory, character, skills]:
		if p.visible and not p.size.is_equal_approx(p.get_combined_minimum_size()):
			_layout()
			break
	if inventory.held:
		_held_icon.visible = true
		_held_icon.texture = DB.icon(inventory.held.icon)
		_held_icon.size = Vector2(inventory.held.size) * InventoryPanel.CELL
		_held_icon.position = _root.get_local_mouse_position() - _held_icon.size * 0.5
	else:
		_held_icon.visible = false

	# Atalhos de painéis
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory()
	if Input.is_action_just_pressed("character"):
		toggle_character()
	if Input.is_action_just_pressed("skills"):
		toggle_skills()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if _popup and is_instance_valid(_popup):
			close_popup()
			get_viewport().set_input_as_handled()
			return
		if inventory.visible or character.visible or skills.visible:
			inventory.visible = false
			character.visible = false
			skills.visible = false
			Sfx.play(&"ui_close")
		elif _death_layer == null:
			toggle_pause()
		get_viewport().set_input_as_handled()
		return
	# Soltar item segurado no chão
	if inventory.held and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		inventory.drop_held_to_world()
		get_viewport().set_input_as_handled()


func _update_target() -> void:
	var mouse := world.get_global_mouse_position()
	var e := world.get_enemy_at(mouse)
	if e == null and world.boss and is_instance_valid(world.boss) and not world.boss.is_dead() and world.boss.state != Enemy.State.IDLE:
		e = world.boss
	if e:
		_target_box.visible = true
		_target_name.text = e.display_name
		_target_name.add_theme_color_override("font_color", Color(1, 0.6, 0.2) if e.is_boss() else (Color(0.45, 0.65, 1.0) if e.elite else Color.WHITE))
		_target_bar.max_value = e.max_hp
		_target_bar.value = e.hp
	else:
		_target_box.visible = false
	# Rótulo de objetos interativos
	var it := world.get_interactable_at(mouse)
	if it and it is Interactable:
		_hover_label.text = (it as Interactable).display_name()
		_hover_label.visible = true
		_hover_label.reset_size()
		_hover_label.position = _root.get_local_mouse_position() + Vector2(-_hover_label.size.x * 0.5, -36)
	else:
		_hover_label.visible = false


func _update_buffs() -> void:
	var names := player.buffs.keys()
	while _buff_row.get_child_count() < names.size():
		var l := UIKit.label("", 13, Color.WHITE, true)
		l.add_theme_color_override("font_outline_color", Color.BLACK)
		l.add_theme_constant_override("outline_size", 3)
		_buff_row.add_child(l)
	for i in _buff_row.get_child_count():
		var l: Label = _buff_row.get_child(i)
		if i < names.size():
			var b: Dictionary = player.buffs[names[i]]
			l.visible = true
			l.text = "%s %ds  " % [names[i], ceili(b.time)]
			l.add_theme_color_override("font_color", b.color)
		else:
			l.visible = false


# ------------------------------------------------------------------ API

func show_message(text: String, color: Color = Color.WHITE, time: float = 2.0) -> void:
	for c in _messages.get_children():
		if c is Label and c.text == text:
			return
	var l := UIKit.label(text, 22, color, true)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 6)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_messages.add_child(l)
	var tw := l.create_tween()
	tw.tween_interval(time)
	tw.tween_property(l, "modulate:a", 0.0, 0.6)
	tw.tween_callback(l.queue_free)
	while _messages.get_child_count() > 5:
		var first := _messages.get_child(0)
		_messages.remove_child(first)
		first.queue_free()


func flash_slot(slot: int) -> void:
	if slot >= 0 and slot < _slots.size():
		_slots[slot].flash()


func damage_vignette() -> void:
	_vignette.color.a = 0.22


func toggle_inventory() -> void:
	inventory.visible = not inventory.visible
	if not inventory.visible and inventory.held:
		if not hero.inventory.add(inventory.held):
			inventory.drop_held_to_world()
		inventory.held = null
	inventory.hide_tooltip()
	Sfx.play(&"ui_open" if inventory.visible else &"ui_close")
	_layout()


func toggle_character() -> void:
	character.visible = not character.visible
	Sfx.play(&"ui_open" if character.visible else &"ui_close")
	_layout()


func toggle_skills() -> void:
	skills.visible = not skills.visible
	if skills.visible:
		skills.refresh()
	Sfx.play(&"ui_open" if skills.visible else &"ui_close")
	_layout()


# ------------------------------------------------------------------ JANELAS DO MUNDO

func close_popup() -> void:
	if _popup and is_instance_valid(_popup):
		_popup.queue_free()
	_popup = null


func _open_popup(title_text: String, width: float) -> VBoxContainer:
	close_popup()
	var w := UIKit.window_panel(title_text, Vector2(width, 0), close_popup)
	_popup = w.panel
	_popup.set_meta("anchor", world.player.global_position)
	_root.add_child(_popup)
	_popup.reset_size()
	var vs := _root.get_viewport_rect().size
	_popup.position = Vector2((vs.x - width) * 0.5, vs.y * 0.18)
	Sfx.play(&"ui_open")
	return w.body


## Mercador: compra itens misteriosos (aposta estilo Diablo) e vende o lixo
func open_merchant() -> void:
	var body := _open_popup("Mercador Bartolomeu", 460)
	var info := UIKit.rich("[color=#bbbbbb]\"Itens embrulhados, aventureiro! Nunca se sabe o que tem dentro...\"[/color]")
	body.add_child(info)
	var gold_label := UIKit.label("", 18, Color(1, 0.85, 0.3), true)
	body.add_child(gold_label)
	var lvl := maxi(hero.level, world.level())
	var offers := [
		["Arma misteriosa", "weapon", 60 + lvl * 25],
		["Armadura misteriosa", "armor", 50 + lvl * 20],
		["Joia misteriosa", "jewel", 80 + lvl * 30],
	]
	var refresh := func(): gold_label.text = "Seu ouro: %d" % hero.gold
	for o in offers:
		var b := UIKit.button("%s — %d ouro" % [o[0], o[2]], func():
			if hero.gold < o[2]:
				show_message("Ouro insuficiente", Color(1, 0.5, 0.4))
				return
			var it := _merchant_item(o[1], lvl)
			if not hero.inventory.add(it):
				show_message("Inventário cheio", Color(1, 0.5, 0.4))
				return
			hero.add_gold(-int(o[2]))
			Sfx.play(&"coins")
			show_message("Você recebeu: %s" % it.name, it.rarity_color(), 2.5)
			refresh.call()
		, 420)
		b.icon = DB.icon({"weapon": "W_Sword010", "armor": "A_Armour02", "jewel": "Ac_Necklace03"}[o[1]])
		body.add_child(b)
	body.add_child(UIKit.button("Vender todos os itens Comuns e Mágicos", func():
		inventory._sell_junk()
		refresh.call()
	, 420))
	body.add_child(UIKit.button("Fechar", close_popup, 420))
	refresh.call()


func _merchant_item(kind: String, lvl: int) -> Item:
	var bases := []
	for k in DB.BASES:
		var b: Dictionary = DB.BASES[k]
		if k == &"wood_sword":
			continue
		match kind:
			"weapon":
				if b.slot == "weapon" and b.cat in hero.cls.allowed_weapons:
					bases.append(k)
			"armor":
				if b.slot in ["helm", "chest", "boots"] or (b.slot == "offhand" and b.cat in hero.cls.allowed_offhands):
					bases.append(k)
			"jewel":
				if b.slot in ["amulet", "ring"]:
					bases.append(k)
	if bases.is_empty():
		bases = [DB.random_base()]
	return DB.create_item(bases.pick_random(), maxi(1, lvl * 2 - 1), DB.roll_rarity(0.3))


## Viagem rápida entre fogueiras acesas (estilo waypoint do Diablo)
func open_waypoints() -> void:
	if not world is Overworld:
		return
	var body := _open_popup("Viagem Rápida", 420)
	body.add_child(UIKit.label("Fogueiras descobertas:", 15, UIKit.TEXT_DIM))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(400, mini(Game.waypoints.size(), 6) * 46)
	body.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	for w in Game.waypoints:
		var pos := Vector2(w.x, w.y)
		var here := pos.distance_to(world.player.global_position) < 40.0
		var b := UIKit.button(("%s  (você está aqui)" if here else "%s") % w.name, func(): (world as Overworld).travel_to(pos), 380)
		b.disabled = here
		list.add_child(b)
	body.add_child(UIKit.button("Fechar", close_popup, 400))


func toggle_pause() -> void:
	if _pause_layer:
		_pause_layer.queue_free()
		_pause_layer = null
		get_tree().paused = false
		return
	get_tree().paused = true
	_pause_layer = _overlay(0.6)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause_layer.add_child(center)
	var p := PanelContainer.new()
	center.add_child(p)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	v.custom_minimum_size = Vector2(320, 0)
	p.add_child(v)
	v.add_child(UIKit.title("Pausado", 30))
	v.add_child(UIKit.separator())
	v.add_child(UIKit.button("Continuar", toggle_pause))
	v.add_child(UIKit.button("Opções", func():
		var o := OptionsPanel.new()
		var c2 := CenterContainer.new()
		c2.set_anchors_preset(Control.PRESET_FULL_RECT)
		_pause_layer.add_child(c2)
		c2.add_child(o)
		o.closed.connect(c2.queue_free)
	))
	v.add_child(UIKit.button("Salvar Jogo", func():
		Game.save_game()
		show_message("Jogo salvo", UIKit.GOLD)
	))
	v.add_child(UIKit.button("Salvar e Sair para o Menu", func(): Game.quit_to_menu()))
	v.add_child(UIKit.button("Sair do Jogo", func():
		Game.save_game()
		get_tree().quit()
	))


func show_death_screen() -> void:
	_death_layer = _overlay(0.0)
	var tw := _death_layer.create_tween()
	tw.tween_property(_death_layer, "modulate:a", 1.0, 1.2).from(0.0)
	var bg: ColorRect = _death_layer.get_child(0)
	bg.color = Color(0.25, 0, 0, 0.55)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_death_layer.add_child(center)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	center.add_child(v)
	var t := UIKit.title("VOCÊ MORREU", 56)
	t.add_theme_color_override("font_color", Color(0.85, 0.1, 0.05))
	v.add_child(t)
	var sub := UIKit.label("%s caiu na Profundidade %d." % [hero.hero_name, Game.depth], 18, UIKit.TEXT)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(sub)
	if hero.hardcore:
		var hc := UIKit.label("Modo Hardcore: seu herói se foi para sempre.
Nível %d • %d abates • Profundidade máxima %d" % [hero.level, hero.kills, hero.deepest], 16, Color(1, 0.5, 0.4))
		hc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(hc)
		v.add_child(UIKit.button("Voltar ao Menu", func(): Game.change_scene(Game.MAIN_MENU), 380))
		return
	v.add_child(UIKit.button("Ressuscitar no Ponto de Partida (-10% ouro)", func():
		_death_layer.queue_free()
		_death_layer = null
		world.respawn_player()
	, 380))
	v.add_child(UIKit.button("Sair para o Menu", func(): Game.quit_to_menu(), 380))


func _overlay(alpha: float) -> Control:
	var c := Control.new()
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	c.process_mode = Node.PROCESS_MODE_ALWAYS
	_root.add_child(c)
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, alpha)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	c.add_child(bg)
	return c
