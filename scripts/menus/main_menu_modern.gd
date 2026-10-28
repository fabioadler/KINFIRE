class_name MainMenuModern
extends Control
## Menu Principal Moderno — Design premium dark fantasy com animações
## Fase 13: Redesign completo do menu de início

var _logo: Control
var _buttons_container: VBoxContainer
var _background: CanvasLayer

var _is_transitioning := false


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build()
	_animate_in()


func _build() -> void:
	# Background animado
	_background = CanvasLayer.new()
	_background.layer = -1
	add_child(_background)
	
	var bg_rect := ColorRect.new()
	bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_rect.color = UIKitModern.BG_PRIMARY
	_background.add_child(bg_rect)
	
	# Logo no centro superior
	_logo = Control.new()
	_logo.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_logo.custom_minimum_size = Vector2(0, 180)
	_logo.position.y = 60
	add_child(_logo)
	
	var logo_lbl = UIKitModern.modern_label("KINFIRE", 72, UIKitModern.GOLD, true)
	logo_lbl.set_anchors_preset(Control.PRESET_CENTER)
	_logo.add_child(logo_lbl)
	
	var subtitle = UIKitModern.modern_label("Um chamado para Eldara", 18, UIKitModern.GOLD_DIM)
	subtitle.set_anchors_preset(Control.PRESET_CENTER)
	subtitle.position.y = 60
	_logo.add_child(subtitle)
	
	# Botões centralizados
	_buttons_container = VBoxContainer.new()
	_buttons_container.set_anchors_preset(Control.PRESET_CENTER)
	_buttons_container.add_theme_constant_override("separation", 16)
	_buttons_container.position.y = 150
	add_child(_buttons_container)
	
	# Novo Jogo
	var new_btn = UIKitModern.modern_button("Novo Jogo", func(): _start_new_game(), 280, 50)
	_buttons_container.add_child(new_btn)
	
	# Continuar
	var continue_btn = UIKitModern.modern_button("Continuar", func(): _continue_game(), 280, 50)
	if not _has_save():
		continue_btn.disabled = true
	_buttons_container.add_child(continue_btn)
	
	# Opções
	var options_btn = UIKitModern.modern_button("Opções", func(): _open_options(), 280, 50)
	_buttons_container.add_child(options_btn)
	
	# Créditos
	var credits_btn = UIKitModern.modern_button("Créditos", func(): _open_credits(), 280, 50)
	_buttons_container.add_child(credits_btn)
	
	# Sair
	var quit_btn = UIKitModern.modern_button("Sair", func(): get_tree().quit(), 280, 50)
	_buttons_container.add_child(quit_btn)


func _animate_in() -> void:
	# Logo pulse in
	_logo.modulate.a = 0.0
	var tween1 = create_tween()
	tween1.set_ease(Tween.EASE_OUT)
	tween1.set_trans(Tween.TRANS_CUBIC)
	tween1.tween_property(_logo, "modulate:a", 1.0, 0.6)
	
	# Botões slide in
	_buttons_container.modulate.a = 0.0
	_buttons_container.position.x = 100
	var tween2 = create_tween()
	tween2.set_ease(Tween.EASE_OUT)
	tween2.set_trans(Tween.TRANS_CUBIC)
	tween2.set_delay(0.3)
	tween2.tween_property(_buttons_container, "modulate:a", 1.0, 0.6)
	tween2.parallel().tween_property(_buttons_container, "position:x", 0, 0.6)
	
	# Hover animado nos botões
	for btn in _buttons_container.get_children():
		if btn is Button:
			UIKitModern.lift_hover(btn)


func _start_new_game() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func(): 
		Game.new_prologue()
		get_tree().change_scene_to_file("res://scenes/game/prologue.tscn")
	)


func _continue_game() -> void:
	if _is_transitioning or not _has_save():
		return
	_is_transitioning = true
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func():
		Game.load_game()
		if Game.hero.level == 0:
			get_tree().change_scene_to_file("res://scenes/game/prologue.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/game/overworld.tscn")
	)


func _open_options() -> void:
	# Placeholder
	UIKitModern.toast(self, "Opções não implementadas neste menu", 2.0, UIKitModern.GOLD_DIM)


func _open_credits() -> void:
	# Placeholder
	UIKitModern.toast(self, "Créditos não implementados neste menu", 2.0, UIKitModern.GOLD_DIM)


func _has_save() -> bool:
	return FileAccess.file_exists("user://save_kinfire.json")
