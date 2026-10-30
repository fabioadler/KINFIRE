class_name CharacterPanelModern
extends PanelContainer
## Painel de Personagem Moderno - Design premium dark fantasy
## Fase 13: Redesign completo com animações e hierarquia visual

const Hero := preload("res://scripts/core/hero.gd")

var hero: Hero
var hud: Node

var _sections: Dictionary = {}  # Abas: Detalhes, Atributos, Status


func setup(p_hud: Node, p_hero: Hero) -> void:
	hud = p_hud
	hero = p_hero
	hero.stats_changed.connect(_refresh)
	_build()


func _build() -> void:
	add_theme_stylebox_override("panel", UIKitModern.modern_panel("").get_theme_stylebox("panel", "PanelContainer"))
	custom_minimum_size = Vector2(420, 500)
	
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	add_child(v)
	
	# Cabeçalho: Retrato + Nome + Classe/Raça
	var header := _build_header()
	v.add_child(header)
	
	var sep := HSeparator.new()
	sep.modulate = UIKitModern.GOLD_DIM
	v.add_child(sep)
	
	# Tabs: Detalhes / Atributos / Status
	var tabs := TabContainer.new()
	tabs.custom_minimum_size = Vector2(0, 380)
	tabs.add_theme_font_size_override("font_size", 12)
	tabs.add_theme_color_override("font_color", UIKitModern.TEXT_PRIMARY)
	tabs.add_theme_color_override("font_selected_color", UIKitModern.GOLD)
	v.add_child(tabs)
	
	# Aba 1: Detalhes
	var details_scroll := ScrollContainer.new()
	details_scroll.custom_minimum_size = Vector2(0, 0)
	details_scroll.scroll_vertical_enabled = true
	tabs.add_child(details_scroll)
	tabs.set_tab_title(0, "Detalhes")
	
	var details := _build_details()
	details_scroll.add_child(details)
	
	# Aba 2: Atributos
	var attrs_scroll := ScrollContainer.new()
	attrs_scroll.custom_minimum_size = Vector2(0, 0)
	attrs_scroll.scroll_vertical_enabled = true
	tabs.add_child(attrs_scroll)
	tabs.set_tab_title(1, "Atributos")
	
	var attrs := _build_attributes()
	attrs_scroll.add_child(attrs)
	
	# Aba 3: Status
	var status_scroll := ScrollContainer.new()
	status_scroll.custom_minimum_size = Vector2(0, 0)
	status_scroll.scroll_vertical_enabled = true
	tabs.add_child(status_scroll)
	tabs.set_tab_title(2, "Status")
	
	var status := _build_status()
	status_scroll.add_child(status)
	
	_refresh()


func _build_header() -> Control:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 16)
	h.custom_minimum_size = Vector2(0, 100)
	
	# Retrato (placeholder)
	var portrait := ColorRect.new()
	portrait.custom_minimum_size = Vector2(80, 80)
	portrait.color = UIKitModern.BG_HOVER
	portrait.modulate = UIKitModern.rarity_color(3)  # Epico por padrão
	h.add_child(portrait)
	
	# Info: Nome, Classe, Raça
	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 4)
	h.add_child(info)
	
	var name_lbl := UIKitModern.modern_label(hero.hero_name, 18, UIKitModern.GOLD, true)
	info.add_child(name_lbl)
	
	var class_race := UIKitModern.modern_label("%s - %s" % [hero.cls.display_name, hero.race.display_name], 12, UIKitModern.TEXT_SECONDARY)
	info.add_child(class_race)
	
	var level_xp := UIKitModern.modern_label("Nível %d - XP %d" % [hero.level, hero.experience], 11, UIKitModern.GOLD_DIM)
	info.add_child(level_xp)
	
	# Badges de dificuldade
	if hero.hardcore:
		var hc_badge := UIKitModern.modern_badge("☠ Hardcore", UIKitModern.RED)
		info.add_child(hc_badge)
	
	return h


func _build_details() -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	v.custom_minimum_size = Vector2(380, 0)
	
	# Vida e Recursos
	var vitals := _detail_row("Vida", "%d / %d" % [hero.hp, hero.max_hp], UIKitModern.RED)
	v.add_child(vitals)
	
	var resources := _detail_row(hero.cls.resource_name, "%d / %d" % [hero.resource, hero.max_resource], UIKitModern.BLUE)
	v.add_child(resources)
	
	# Dano e Defesa
	var dmg := _detail_row("Dano", "%.1f" % hero.attack_power(), UIKitModern.GOLD)
	v.add_child(dmg)
	
	var armor := _detail_row("Armadura", "%d" % hero.armor, UIKitModern.GREEN)
	v.add_child(armor)
	
	# Velocidade e Crítico
	var atk_spd := _detail_row("Vel. Ataque", "%.2f/s" % (1.0 / hero.attack_speed()), UIKitModern.GOLD_DIM)
	v.add_child(atk_spd)
	
	var crit := _detail_row("Crítico", "%.1f%%" % (hero.crit_chance() * 100), UIKitModern.RED)
	v.add_child(crit)
	
	# Gold e Essence
	var gold := _detail_row("Ouro", "%d" % hero.gold, UIKitModern.GOLD)
	v.add_child(gold)
	
	var ess := _detail_row("Essência", "%d" % hero.essence, UIKitModern.PURPLE)
	v.add_child(ess)
	
	return v


func _build_attributes() -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 16)
	v.custom_minimum_size = Vector2(380, 0)
	
	var attrs = ["str", "dex", "con", "int", "wis", "cha"]
	var labels = ["Força", "Agilidade", "Constituição", "Inteligência", "Sabedoria", "Carisma"]
	
	for i in range(attrs.size()):
		var attr_name = attrs[i]
		var display = labels[i]
		var value = hero.base_abilities.get(attr_name, 10)
		var bonus = hero.ability_bonus(attr_name)
		
		var row := _attribute_row(display, value, bonus)
		v.add_child(row)
	
	return v


func _build_status() -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	v.custom_minimum_size = Vector2(380, 0)
	
	# Status ARPG: Força, Agilidade, Mente, Vitalidade
	var status_names = ["forca", "agilidade", "mente", "vitalidade"]
	var display_names = ["Força", "Agilidade", "Mente", "Vitalidade"]
	var colors = [UIKitModern.RED, UIKitModern.GREEN, UIKitModern.BLUE, UIKitModern.PURPLE]
	
	for i in range(status_names.size()):
		var name = status_names[i]
		var display = display_names[i]
		var color = colors[i]
		var value = hero.status.get(name, 10)
		
		var row := _status_row(display, value, color)
		v.add_child(row)
	
	# Pontos disponíveis
	if hero.status_points > 0:
		var sep := HSeparator.new()
		sep.modulate = UIKitModern.GOLD_DIM
		v.add_child(sep)
		
		var points_lbl := UIKitModern.modern_label("Pontos Disponíveis: %d" % hero.status_points, 12, UIKitModern.GOLD, true)
		v.add_child(points_lbl)
		
		var respec_btn := UIKitModern.modern_button("Respeitar Tudo", func(): hero.respec_status(), 200)
		v.add_child(respec_btn)
	
	return v


func _detail_row(label: String, value: String, color: Color) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	h.custom_minimum_size = Vector2(0, 28)
	
	var lbl := UIKitModern.modern_label(label, 12, UIKitModern.TEXT_SECONDARY)
	h.add_child(lbl)
	
	var spacer := Control.new()
	h.add_child(spacer)
	
	var val := UIKitModern.modern_label(value, 12, color, true)
	h.add_child(val)
	
	return h


func _attribute_row(label: String, base: int, bonus: int) -> PanelContainer:
	var panel := UIKitModern.modern_panel()
	
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 8)
	panel.add_child(h)
	
	var lbl := UIKitModern.modern_label(label, 13, UIKitModern.TEXT_PRIMARY, true)
	h.add_child(lbl)
	
	var spacer := Control.new()
	h.add_child(spacer)
	
	var base_lbl := UIKitModern.modern_label(str(base), 12, UIKitModern.TEXT_SECONDARY)
	h.add_child(base_lbl)
	
	if bonus > 0:
		var bonus_lbl := UIKitModern.modern_label("+%d" % bonus, 12, UIKitModern.GREEN, true)
		h.add_child(bonus_lbl)
	
	return panel


func _status_row(label: String, value: int, color: Color) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	h.custom_minimum_size = Vector2(0, 36)
	
	var lbl := UIKitModern.modern_label(label, 12, color, true)
	h.add_child(lbl)
	
	var bar := UIKitModern.modern_progress_bar(100.0, color)
	bar.value = min(value, 100)
	h.add_child(bar)
	
	var val := UIKitModern.modern_label(str(value), 12, color, true)
	h.add_child(val)
	
	return h


func _refresh() -> void:
	queue_redraw()


func cleanup() -> void:
	"""Desconectar signals para evitar memory leak"""
	if hero.stats_changed.is_connected(_refresh):
		hero.stats_changed.disconnect(_refresh)
