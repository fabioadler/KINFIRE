class_name DialogueBoxModern
extends Control
## Caixa de Diálogo Moderna - Animações suaves, design premium
## Fase 13: Redesign com efeitos visuais atraentes

var _content: DialogueData
var _engine: DialogueEngine
var _current_page: int = 0

var _bg: PanelContainer
var _portrait: TextureRect
var _name_label: Label
var _text_label: Label
var _choices_container: VBoxContainer
var _page_indicator: Label

var _is_open := false
var _typing := false


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_STOP
	_build()
	hide()


func _build() -> void:
	# Overlay escuro
	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.mouse_filter = MOUSE_FILTER_PASS
	overlay.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed:
			_advance_or_close()
	)
	add_child(overlay)
	
	# Painel principal (rodapé)
	_bg = PanelContainer.new()
	_bg.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_bg.custom_minimum_size = Vector2(0, 280)
	_bg.position.y = -280
	
	var style := StyleBoxFlat.new()
	style.bg_color = UIKitModern.BG_PRIMARY
	style.border_color = UIKitModern.GOLD_DIM
	style.set_border_enabled_all(true)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.set_expand_margin_all(12)
	_bg.add_theme_stylebox_override("panel", style)
	add_child(_bg)
	
	var main_v := VBoxContainer.new()
	main_v.add_theme_constant_override("separation", 12)
	_bg.add_child(main_v)
	
	# Header: Retrato + Nome
	var header_h := HBoxContainer.new()
	header_h.add_theme_constant_override("separation", 12)
	header_h.custom_minimum_size = Vector2(0, 80)
	main_v.add_child(header_h)
	
	_portrait = TextureRect.new()
	_portrait.custom_minimum_size = Vector2(64, 64)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.modulate = UIKitModern.GOLD
	header_h.add_child(_portrait)
	
	var info_v := VBoxContainer.new()
	info_v.add_theme_constant_override("separation", 4)
	header_h.add_child(info_v)
	
	_name_label = UIKitModern.modern_label("???", 18, UIKitModern.GOLD, true)
	info_v.add_child(_name_label)
	
	var spacer := Control.new()
	info_v.add_child(spacer)
	
	# Texto do diálogo
	_text_label = UIKitModern.modern_label("", 14, UIKitModern.TEXT_PRIMARY)
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_text_label.custom_minimum_size = Vector2(700, 60)
	main_v.add_child(_text_label)
	
	# Separador
	var sep := HSeparator.new()
	sep.modulate = UIKitModern.GOLD_DIM
	main_v.add_child(sep)
	
	# Escolhas
	_choices_container = VBoxContainer.new()
	_choices_container.add_theme_constant_override("separation", 6)
	_choices_container.custom_minimum_size = Vector2(0, 80)
	main_v.add_child(_choices_container)
	
	# Indicador de página
	_page_indicator = UIKitModern.modern_label("", 10, UIKitModern.GOLD_DIM)
	main_v.add_child(_page_indicator)
	
	# Conectar inputs
	get_tree().root.gui_input.connect(_on_gui_input)


func open_dialogue(p_content: DialogueData, p_engine: DialogueEngine) -> void:
	_content = p_content
	_engine = p_engine
	_current_page = 0
	_is_open = true
	
	show()
	UIKitModern.pop_in(_bg, 0.4)
	
	_show_page()


func _show_page() -> void:
	if not _content:
		return
	
	var page = _content.pages[_current_page] if _current_page < _content.pages.size() else null
	if not page:
		close()
		return
	
	# Nome do personagem
	_name_label.text = page.speaker if page.speaker else "???"
	
	# Retrato (placeholder com cor)
	_portrait.modulate = UIKitModern.rarity_color(randi() % 6)
	
	# Texto com efeito de máquina de escrever
	_text_label.text = ""
	_typing = true
	_type_text(page.text)
	
	# Escolhas
	_choices_container.clear()
	if page.choices.is_empty():
		# Próxima página ou fechar
		var next_btn := UIKitModern.modern_button("Continuar", _advance_or_close, 150, 36)
		_choices_container.add_child(next_btn)
	else:
		for choice in page.choices:
			var btn := UIKitModern.modern_button(choice.text, func(): _select_choice(choice), 300, 36)
			_choices_container.add_child(btn)
	
	# Indicador
	_page_indicator.text = "Página %d/%d" % [_current_page + 1, _content.pages.size()]


func _type_text(text: String) -> void:
	var delay_per_char = 0.04
	var total_time = text.length() * delay_per_char
	
	var tween = create_tween()
	for i in range(1, text.length() + 1):
		_text_label.text = text.substr(0, i)
		await tween.tween_callback(func(): pass).set_delay(delay_per_char)
	
	_typing = false


func _advance_or_close() -> void:
	if _typing:
		_typing = false
		_text_label.text = _content.pages[_current_page].text if _current_page < _content.pages.size() else ""
		return
	
	_current_page += 1
	if _current_page < _content.pages.size():
		_show_page()
	else:
		close()


func _select_choice(choice: DialogueChoice) -> void:
	if _engine and choice.callback:
		choice.callback.call()
	
	if choice.next_id:
		# Ir para próximo diálogo
		close()
	else:
		close()


func _on_gui_input(event: InputEvent) -> void:
	if not _is_open:
		return
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			_advance_or_close()
		elif event.keycode == KEY_ESCAPE:
			close()


func close() -> void:
	_is_open = false
	_typing = false
	
	if _bg:
		UIKitModern.pop_out(_bg, 0.3)
	
	await get_tree().create_timer(0.3).timeout
	hide()
	_content = null
	_engine = null
