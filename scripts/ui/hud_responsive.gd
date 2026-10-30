# class_name HUDResponsive
extends HUD
## HUD moderna, responsiva e otimizada - extensão da HUD original com layout melhorado
## Fase 12: Redesign para múltiplas resoluções com escala dinâmica

var _screen_size: Vector2
var _scale_factor: float = 1.0


func _build() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	# Vignette
	_vignette = ColorRect.new()
	_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vignette.color = Color(0.6, 0, 0, 0)
	_root.add_child(_vignette)

	# Conectar resize para responsividade
	get_viewport().size_changed.connect(_on_viewport_changed)
	_on_viewport_changed()

	# Construir layout moderno e compacto
	_build_top_status()
	_build_bottom_bar()
	_build_messages_panel()
	_build_unified_panels()

	if not Game.trade_requested.is_connected(_on_trade_requested):
		Game.trade_requested.connect(_on_trade_requested)

	_held_icon = TextureRect.new()
	_held_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_held_icon.custom_minimum_size = Vector2(40, 40)
	_held_icon.size = Vector2(40, 40)
	_held_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_held_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_held_icon.z_index = 90
	_root.add_child(_held_icon)

	_layout()


func _on_viewport_changed() -> void:
	_screen_size = get_viewport_rect().size
	# Escala dinâmica baseada em resolução (1280x720 = 1.0)
	_scale_factor = maxf(minf(_screen_size.x / 1280.0, 2.0), 0.8)
	_layout()


func _layout() -> void:
	# Reposiciona elementos responsivamente
	if is_node_ready():
		pass


func _build_top_status() -> void:
	# Painel superior esquerdo: Status do herói
	var top_left := PanelContainer.new()
	top_left.name = "StatusPanel"
	top_left.set_anchors_preset(Control.PRESET_TOP_LEFT)
	top_left.add_theme_stylebox_override("panel", UIKit.box(Color(0.05, 0.035, 0.03, 0.95), UIKit.GOLD_DIM, 2, 8))
	_root.add_child(top_left)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	top_left.add_child(v)

	# Nível + Experiência em linha
	var level_exp := HBoxContainer.new()
	level_exp.add_theme_constant_override("separation", 12)
	v.add_child(level_exp)

	_badge = LevelBadge.new()
	_badge.custom_minimum_size = Vector2(60 * _scale_factor, 60 * _scale_factor)
	level_exp.add_child(_badge)

	var level_info := VBoxContainer.new()
	level_exp.add_child(level_info)
	_points_hint = Button.new()
	_points_hint.text = "LV %d" % hero.level
	_points_hint.custom_minimum_size = Vector2(80 * _scale_factor, 24 * _scale_factor)
	level_info.add_child(_points_hint)

	# Vida
	_hp_bar = VitalsBar.new(Color(0.8, 0.08, 0.08))
	_hp_bar.custom_minimum_size = Vector2(230 * _scale_factor, 20 * _scale_factor)
	_hp_bar.tooltip_text = "Vida"
	v.add_child(_hp_bar)

	# Recurso
	_res_bar = VitalsBar.new(Color(0.15, 0.6, 1.0))
	_res_bar.custom_minimum_size = Vector2(230 * _scale_factor, 20 * _scale_factor)
	_res_bar.tooltip_text = hero.cls.resource_name
	v.add_child(_res_bar)

	# Buffs/Debuffs
	_buff_row = HBoxContainer.new()
	_buff_row.custom_minimum_size = Vector2(230 * _scale_factor, 32 * _scale_factor)
	_buff_row.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(_buff_row)

	# Gold e Essence em linha
	var resources := HBoxContainer.new()
	resources.add_theme_constant_override("separation", 12)
	v.add_child(resources)

	_gold_chip = PanelContainer.new()
	_gold_chip.custom_minimum_size = Vector2(100 * _scale_factor, 28 * _scale_factor)
	_gold_chip.add_theme_stylebox_override("panel", UIKit.box(Color(0.1, 0.08, 0.05), Color(0.8, 0.7, 0.3), 1, 4))
	resources.add_child(_gold_chip)

	var gold_h := HBoxContainer.new()
	gold_h.add_theme_constant_override("separation", 4)
	_gold_chip.add_child(gold_h)
	gold_h.add_child(UIKit.label("💰", 12))
	_gold = UIKit.label("0", 12, Color.WHITE)
	gold_h.add_child(_gold)

	_essence_chip = PanelContainer.new()
	_essence_chip.custom_minimum_size = Vector2(100 * _scale_factor, 28 * _scale_factor)
	_essence_chip.add_theme_stylebox_override("panel", UIKit.box(Color(0.05, 0.08, 0.1), Color(0.3, 0.6, 1.0), 1, 4))
	resources.add_child(_essence_chip)

	var ess_h := HBoxContainer.new()
	ess_h.add_theme_constant_override("separation", 4)
	_essence_chip.add_child(ess_h)
	ess_h.add_child(UIKit.label("✦", 12, Color(0.5, 0.8, 1.0)))
	_essence = UIKit.label("0", 12, Color(0.5, 0.8, 1.0))
	ess_h.add_child(_essence)

	# Posicionar
	top_left.custom_minimum_size = Vector2(300 * _scale_factor, 220 * _scale_factor)
	top_left.position = Vector2(12, 12)


func _build_bottom_bar() -> void:
	var bar := PanelContainer.new()
	bar.name = "BottomBar"
	bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bar.add_theme_stylebox_override("panel", UIKit.box(Color(0.05, 0.035, 0.03, 0.92), UIKit.GOLD_DIM, 2, 6))
	_root.add_child(bar)

	var v := VBoxContainer.new()
	bar.add_child(v)

	# Linha de buffs
	_buff_row = HBoxContainer.new()
	_buff_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_buff_row.custom_minimum_size.y = 0
	v.add_child(_buff_row)

	# Linha principal: consumíveis + skills + painéis
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 6)
	h.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(h)

	# Consumíveis 1-9 (compacto)
	_consumable_slots = []
	for i in 9:
		var slot_idx: int = i
		var key_name: String = Game.key_name("consumable_%d" % (i + 1))
		var cs := ConsumableSlotScript.new(slot_idx, key_name)
		cs.player = player
		cs.used.connect(func(s: int): player._use_consumable_slot(s))
		_consumable_slots.append(cs)
		h.add_child(cs)

	h.add_child(_spacer(8))

	# Cura simples
	_heal_slot = SkillSlot.new(-2, Game.key_name("heal"))
	_heal_slot.is_potion = true
	_heal_slot.player = player
	_heal_slot.clicked.connect(func(_s): player._use_simple_heal())
	h.add_child(_heal_slot)

	h.add_child(_spacer(8))

	# 4 Skills da barra
	_slots = []
	for i in 4:
		var slot := SkillSlot.new(i, Game.key_name("skill_%d" % (i + 1)))
		slot.player = player
		slot.clicked.connect(func(idx: int, _: StringName): player._use_skill(idx))
		_slots.append(slot)
		h.add_child(slot)

	h.add_child(_spacer(8))

	# Botões de painéis
	_bar_buttons = {}
	var shortcuts: Array = [
		("C", "character", Game.key_name("char")),
		("I", "inventory", Game.key_name("inv")),
		("S", "skills", Game.key_name("skills")),
		("M", "quest_log", Game.key_name("quest")),
		("B", "skill_tree", Game.key_name("skill_tree")),
	]

	for label: String in shortcuts:
		var btn := Button.new()
		btn.text = label
		_bar_buttons[label] = btn
		h.add_child(btn)


func _build_messages_panel() -> void:
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


func _build_unified_panels() -> void:
	inventory = InventoryPanel.new()
	inventory.setup(self, hero)
	character = CharacterPanel.new()
	character.setup(self, hero)
	skills = SkillsPanel.new()
	skills.setup(self, hero)
	questlog = QuestPanel.new()
	questlog.setup(self)
	skill_tree = SkillTreePanel.new()
	skill_tree.setup(self, hero)

	_unified = UnifiedPanel.new()
	_root.add_child(_unified)
	_unified.add_page("Personagem", character)
	_unified.add_page("Inventário", inventory)
	_unified.add_page("Habilidades", skills)
	_unified.add_page("Arvore", skill_tree)
	_unified.add_page("Missões", questlog)

	Game.quest_log.quest_started.connect(_on_quest_started)
	Game.quest_log.quest_completed.connect(_on_quest_completed)


func _spacer(size: int = 8) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(size, 0)
	return c


func refresh_skill_bar() -> void:
	for i in mini(_slots.size(), hero.skill_bar.size()):
		var skill_id := hero.skill_bar[i]
		if skill_id != &"":
			var skill := DB.get_skill(skill_id)
			if skill:
				_slots[i].set_skill(skill, hero)


func _on_quest_started(q: QuestData) -> void:
	pass


func _on_quest_completed(q: QuestData) -> void:
	pass


func _on_trade_requested() -> void:
	pass


func _exit_tree() -> void:
	"""Desconectar signals para evitar memory leak"""
	if Game.trade_requested.is_connected(_on_trade_requested):
		Game.trade_requested.disconnect(_on_trade_requested)
	if Game.quest_log:
		if Game.quest_log.quest_started.is_connected(_on_quest_started):
			Game.quest_log.quest_started.disconnect(_on_quest_started)
		if Game.quest_log.quest_completed.is_connected(_on_quest_completed):
			Game.quest_log.quest_completed.disconnect(_on_quest_completed)
	if get_viewport():
		get_viewport().size_changed.disconnect(_on_viewport_changed)
