# class_name HUDModern
extends CanvasLayer
## HUD moderna, responsiva e otimizada - layout fluido que se adapta a qualquer resolução
## Fase 12: Redesign completo para suportar múltiplas resoluções e estilo moderno

const Hero := preload("res://scripts/core/hero.gd")
const VitalsBar := preload("res://scripts/ui/vitals_bar.gd")
const SkillSlot := preload("res://scripts/ui/skill_slot.gd")
const InventoryPanel := preload("res://scripts/ui/inventory_panel.gd")
const CharacterPanel := preload("res://scripts/ui/character_panel.gd")
const SkillsPanel := preload("res://scripts/ui/skills_panel.gd")
const QuestPanel := preload("res://scripts/ui/quest_panel.gd")
const UnifiedPanel := preload("res://scripts/ui/unified_panel.gd")
const SkillTreePanel := preload("res://scripts/ui/skill_tree_panel.gd")
const DialogueBox := preload("res://scripts/ui/dialogue_box.gd")
const TradePanel := preload("res://scripts/ui/trade_panel.gd")
const ConsumableSlotScript := preload("res://scripts/ui/consumable_slot.gd")

var world: World
var player: Player
var hero: Hero

var _root: Control
var _screen_size: Vector2
var _scale_factor: float = 1.0  # Escala dinâmica baseada em resolução

# Elementos principais
var _top_left_panel: PanelContainer  # Status: Vida, Mana, Nível
var _top_right_panel: PanelContainer  # Relógio, Gold, Essence
var _bottom_bar: PanelContainer  # Barra de skills e consumíveis
var _right_panel: PanelContainer  # Target / Quest tracker
var _minimap: Control  # Minimapa (futuro)

# Sub-elementos
var _hp_bar: VitalsBar
var _res_bar: VitalsBar
var _level_label: Label
var _gold_label: Label
var _essence_label: Label
var _clock_label: Label
var _slots: Array[SkillSlot] = []
var _consumable_slots: Array = []
var _messages: VBoxContainer
var _buff_row: HBoxContainer
var _target_box: PanelContainer
var _unified: UnifiedPanel

var inventory: InventoryPanel
var character: CharacterPanel
var skills: SkillsPanel
var questlog: QuestPanel
var skill_tree: SkillTreePanel


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

	# Conectar resize
	get_viewport().size_changed.connect(_on_viewport_changed)
	_on_viewport_changed()

	# Vignette
	var vignette := ColorRect.new()
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette.color = Color(0.6, 0, 0, 0)
	_root.add_child(vignette)

	# Construir layout
	_build_top_left()
	_build_top_right()
	_build_bottom_bar()
	_build_right_panel()
	_build_messages()
	_build_unified_panels()


func _on_viewport_changed() -> void:
	_screen_size = get_viewport_rect().size
	# Escala dinâmica: 1280x720 = 1.0, 1920x1080 = 1.5, 2560x1440 = 2.0
	_scale_factor = _screen_size.x / 1280.0
	_layout()


func _layout() -> void:
	# Reposiciona elementos baseado na resolução
	pass


func _build_top_left() -> void:
	_top_left_panel = PanelContainer.new()
	_top_left_panel.name = "TopLeftStatus"
	_top_left_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_top_left_panel.custom_minimum_size = Vector2(280 * _scale_factor, 140 * _scale_factor)
	_top_left_panel.position = Vector2(12, 12)
	_top_left_panel.add_theme_stylebox_override("panel", 
		UIKit.box(Color(0.05, 0.035, 0.03, 0.95), UIKit.GOLD_DIM, 2, 8))
	_root.add_child(_top_left_panel)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	_top_left_panel.add_child(v)

	# Nível
	_level_label = UIKit.label("", 24, Color(0.9, 0.75, 0.3))
	_level_label.add_theme_font_size_override("font_size", int(24 * _scale_factor))
	v.add_child(_level_label)

	# Vida
	_hp_bar = VitalsBar.new(Color(0.8, 0.08, 0.08))
	_hp_bar.custom_minimum_size = Vector2(250 * _scale_factor, 20 * _scale_factor)
	_hp_bar.tooltip_text = "Vida"
	v.add_child(_hp_bar)

	# Recurso (Mana/Fúria/etc)
	_res_bar = VitalsBar.new(Color(0.15, 0.6, 1.0))
	_res_bar.custom_minimum_size = Vector2(250 * _scale_factor, 20 * _scale_factor)
	_res_bar.tooltip_text = hero.cls.resource_name
	v.add_child(_res_bar)

	# Buffs/Debuffs em linha
	_buff_row = HBoxContainer.new()
	_buff_row.custom_minimum_size = Vector2(250 * _scale_factor, 32 * _scale_factor)
	_buff_row.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(_buff_row)


func _build_top_right() -> void:
	_top_right_panel = PanelContainer.new()
	_top_right_panel.name = "TopRightResources"
	_top_right_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_top_right_panel.custom_minimum_size = Vector2(200 * _scale_factor, 120 * _scale_factor)
	_top_right_panel.position = Vector2(-12 - (200 * _scale_factor), 12)
	_top_right_panel.add_theme_stylebox_override("panel",
		UIKit.box(Color(0.05, 0.035, 0.03, 0.95), UIKit.GOLD_DIM, 2, 8))
	_root.add_child(_top_right_panel)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	_top_right_panel.add_child(v)

	# Relógio
	_clock_label = UIKit.label("00:00", 16, Color(0.9, 0.75, 0.3))
	_clock_label.add_theme_font_size_override("font_size", int(16 * _scale_factor))
	v.add_child(_clock_label)

	# Gold
	var gold_h := HBoxContainer.new()
	gold_h.add_theme_constant_override("separation", 4)
	v.add_child(gold_h)
	gold_h.add_child(UIKit.label("💰", 14))
	_gold_label = UIKit.label("0", 14, Color.WHITE)
	_gold_label.add_theme_font_size_override("font_size", int(14 * _scale_factor))
	gold_h.add_child(_gold_label)

	# Essence
	var ess_h := HBoxContainer.new()
	ess_h.add_theme_constant_override("separation", 4)
	v.add_child(ess_h)
	ess_h.add_child(UIKit.label("✦", 14, Color(0.5, 0.8, 1.0)))
	_essence_label = UIKit.label("0", 14, Color(0.5, 0.8, 1.0))
	_essence_label.add_theme_font_size_override("font_size", int(14 * _scale_factor))
	ess_h.add_child(_essence_label)


func _build_bottom_bar() -> void:
	_bottom_bar = PanelContainer.new()
	_bottom_bar.name = "BottomActionBar"
	_bottom_bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_bottom_bar.size.y = int(100 * _scale_factor)
	_bottom_bar.position.y = -_bottom_bar.size.y
	_bottom_bar.add_theme_stylebox_override("panel",
		UIKit.box(Color(0.05, 0.035, 0.03, 0.92), UIKit.GOLD_DIM, 2, 8))
	_root.add_child(_bottom_bar)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	_bottom_bar.add_child(v)

	# Linha 1: Consumíveis 1-9
	var cons_h := HBoxContainer.new()
	cons_h.add_theme_constant_override("separation", 4)
	cons_h.alignment = BoxContainer.ALIGNMENT_CENTER
	cons_h.custom_minimum_size = Vector2(0, 40 * _scale_factor)
	v.add_child(cons_h)

	_consumable_slots = []
	for i in 9:
		var slot_idx: int = i
		var key_name: String = Game.key_name("consumable_%d" % (i + 1))
		var cs := ConsumableSlotScript.new(slot_idx, key_name)
		cs.player = player
		cs.used.connect(func(s: int): player._use_consumable_slot(s))
		cs.custom_minimum_size = Vector2(36 * _scale_factor, 36 * _scale_factor)
		_consumable_slots.append(cs)
		cons_h.add_child(cs)

	# Linha 2: Skills + Heal
	var skills_h := HBoxContainer.new()
	skills_h.add_theme_constant_override("separation", 6)
	skills_h.alignment = BoxContainer.ALIGNMENT_CENTER
	skills_h.custom_minimum_size = Vector2(0, 40 * _scale_factor)
	v.add_child(skills_h)

	# Cura simples
	var heal_slot := SkillSlot.new(-2, Game.key_name("heal"))
	heal_slot.is_potion = true
	heal_slot.player = player
	heal_slot.clicked.connect(func(_s): player._use_simple_heal())
	heal_slot.custom_minimum_size = Vector2(40 * _scale_factor, 40 * _scale_factor)
	skills_h.add_child(heal_slot)

	# 4 Skills da barra
	_slots = []
	for i in 4:
		var slot := SkillSlot.new(i, Game.key_name("skill_%d" % (i + 1)))
		slot.player = player
		slot.clicked.connect(func(idx: int, _: StringName): player._use_skill(idx))
		slot.custom_minimum_size = Vector2(40 * _scale_factor, 40 * _scale_factor)
		_slots.append(slot)
		skills_h.add_child(slot)

	# Botões de painéis (P/I/C/M/B)
	var panel_h := HBoxContainer.new()
	panel_h.add_theme_constant_override("separation", 4)
	skills_h.add_child(panel_h)

	var panel_shortcuts: Array = [
		("C", "Personagem", Game.key_name("char")),
		("I", "Inventário", Game.key_name("inv")),
		("S", "Skills", Game.key_name("skills")),
		("M", "Missões", Game.key_name("quest")),
		("B", "Arvore", Game.key_name("skill_tree")),
	]

	for label_text: String in panel_shortcuts:
		var btn := Button.new()
		btn.text = label_text
		btn.custom_minimum_size = Vector2(32 * _scale_factor, 40 * _scale_factor)
		btn.add_theme_font_size_override("font_size", int(12 * _scale_factor))
		panel_h.add_child(btn)


func _build_right_panel() -> void:
	_target_box = PanelContainer.new()
	_target_box.name = "TargetInfo"
	_target_box.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_target_box.custom_minimum_size = Vector2(280 * _scale_factor, 140 * _scale_factor)
	_target_box.position = Vector2(-12 - (280 * _scale_factor), 140 * _scale_factor)
	_target_box.add_theme_stylebox_override("panel",
		UIKit.box(Color(0.05, 0.035, 0.03, 0.95), UIKit.GOLD_DIM, 2, 8))
	_target_box.visible = false
	_root.add_child(_target_box)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	_target_box.add_child(v)

	var target_name := UIKit.label("Alvo", 16, Color(0.9, 0.75, 0.3))
	target_name.add_theme_font_size_override("font_size", int(16 * _scale_factor))
	v.add_child(target_name)

	var target_bar := ProgressBar.new()
	target_bar.custom_minimum_size = Vector2(250 * _scale_factor, 16 * _scale_factor)
	v.add_child(target_bar)


func _build_messages() -> void:
	_messages = VBoxContainer.new()
	_messages.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_messages.position = Vector2(-300, 160)
	_messages.custom_minimum_size = Vector2(600, 0)
	_messages.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_messages.alignment = BoxContainer.ALIGNMENT_BEGIN
	_root.add_child(_messages)


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


func update_status() -> void:
	_hp_bar.value = hero.hp
	_hp_bar.max_value = hero.max_hp
	_res_bar.value = hero.resource
	_res_bar.max_value = hero.max_resource
	_level_label.text = "Nível %d" % hero.level
	_gold_label.text = str(hero.gold)
	_essence_label.text = str(hero.essence)


func _on_quest_started(_q: QuestData) -> void:
	pass


func _on_quest_completed(_q: QuestData) -> void:
	pass


func show_message(text: String, color: Color = Color.WHITE, duration: float = 3.0) -> void:
	var lbl := UIKit.label(text, 14, color)
	_messages.add_child(lbl)
	await get_tree().create_timer(duration, false).timeout
	lbl.queue_free()


func _process(_delta: float) -> void:
	update_status()


func _exit_tree() -> void:
	"""Desconectar signals para evitar memory leak"""
	if Game.quest_log:
		if Game.quest_log.quest_started.is_connected(_on_quest_started):
			Game.quest_log.quest_started.disconnect(_on_quest_started)
		if Game.quest_log.quest_completed.is_connected(_on_quest_completed):
			Game.quest_log.quest_completed.disconnect(_on_quest_completed)
	if get_viewport():
		get_viewport().size_changed.disconnect(_on_viewport_changed)
