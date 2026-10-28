class_name UIKitModern
extends Node
## UIKit Moderno — Componentes reutilizáveis com design system premium
## Fase 13: Sistema visual coeso dark fantasy

# Paleta Premium
const GOLD = Color("#d4af37")
const GOLD_DARK = Color("#c4a860")
const GOLD_DIM = Color("#6b5d3f")
const RED = Color("#e74c3c")
const RED_DARK = Color("#c0392b")
const BLUE = Color("#3498db")
const BLUE_DARK = Color("#2980b9")
const GREEN = Color("#2ecc71")
const GREEN_DARK = Color("#27ae60")
const PURPLE = Color("#9b59b6")
const PURPLE_DARK = Color("#8e44ad")

const BG_PRIMARY = Color("#0d0804")
const BG_PANEL = Color("#1a1410")
const BG_HOVER = Color("#2a241a")
const TEXT_PRIMARY = Color("#e8e8e8")
const TEXT_SECONDARY = Color("#b0a080")
const TEXT_DISABLED = Color("#6b6050")
const BORDER = Color("#3d352b")
const BORDER_ACTIVE = GOLD

# Raridades
const RARITY_COLORS = {
	0: Color("#7f8c8d"),  # Comum
	1: GREEN,              # Incomum
	2: BLUE,               # Raro
	3: PURPLE,             # Épico
	4: RED,                # Lendário
	5: Color("#f39c12"),   # Único
}

# Animações
const ANIM_SPEED_FAST = 0.15
const ANIM_SPEED_NORMAL = 0.3
const ANIM_SPEED_SLOW = 0.6


# COMPONENTES ESTÁTICOS

static func modern_button(text: String, callback: Callable = Callable(), width: int = 120, height: int = 40) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(width, height)
	btn.add_theme_font_size_override("font_size", 14)
	
	# Estilo moderno
	var style_normal := StyleBoxFlat.new()
	style_normal.bg_color = BG_PANEL
	style_normal.border_color = BORDER
	style_normal.set_border_enabled_all(true)
	style_normal.set_border_width_all(1)
	style_normal.corner_radius_top_left = 6
	style_normal.corner_radius_top_right = 6
	style_normal.corner_radius_bottom_left = 6
	style_normal.corner_radius_bottom_right = 6
	
	var style_hover := StyleBoxFlat.new()
	style_hover.bg_color = BG_HOVER
	style_hover.border_color = BORDER_ACTIVE
	style_hover.set_border_enabled_all(true)
	style_hover.set_border_width_all(2)
	style_hover.corner_radius_top_left = 6
	style_hover.corner_radius_top_right = 6
	style_hover.corner_radius_bottom_left = 6
	style_hover.corner_radius_bottom_right = 6
	
	var style_pressed := StyleBoxFlat.new()
	style_pressed.bg_color = BG_PRIMARY
	style_pressed.border_color = BORDER_ACTIVE
	style_pressed.set_border_enabled_all(true)
	style_pressed.set_border_width_all(2)
	style_pressed.corner_radius_top_left = 6
	style_pressed.corner_radius_top_right = 6
	style_pressed.corner_radius_bottom_left = 6
	style_pressed.corner_radius_bottom_right = 6
	
	btn.add_theme_stylebox_override("normal", style_normal)
	btn.add_theme_stylebox_override("hover", style_hover)
	btn.add_theme_stylebox_override("pressed", style_pressed)
	btn.add_theme_color_override("font_color", TEXT_PRIMARY)
	btn.add_theme_color_override("font_hover_color", GOLD)
	btn.add_theme_color_override("font_pressed_color", GOLD)
	
	if callback:
		btn.pressed.connect(callback)
	
	return btn


static func modern_label(text: String, size: int = 14, color: Color = TEXT_PRIMARY, bold: bool = false) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", color)
	if bold:
		lbl.add_theme_font_override("font", load("res://assets/fonts/bold.tres"))
	return lbl


static func modern_panel(title: String = "", bg_color: Color = BG_PANEL, border_color: Color = BORDER) -> PanelContainer:
	var panel := PanelContainer.new()
	
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_enabled_all(true)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.set_expand_margin_all(12)
	
	panel.add_theme_stylebox_override("panel", style)
	
	if title:
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 8)
		panel.add_child(v)
		
		var title_lbl := modern_label(title, 18, GOLD, true)
		v.add_child(title_lbl)
		
		var separator := HSeparator.new()
		separator.modulate = GOLD_DIM
		v.add_child(separator)
	
	return panel


static func modern_input(placeholder: String = "", width: int = 200) -> LineEdit:
	var input := LineEdit.new()
	input.placeholder_text = placeholder
	input.custom_minimum_size = Vector2(width, 36)
	input.add_theme_font_size_override("font_size", 14)
	
	var style := StyleBoxFlat.new()
	style.bg_color = BG_PANEL
	style.border_color = BORDER
	style.set_border_enabled_all(true)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.set_expand_margin_all(8)
	
	var style_focus := StyleBoxFlat.new()
	style_focus.bg_color = BG_PANEL
	style_focus.border_color = BORDER_ACTIVE
	style_focus.set_border_enabled_all(true)
	style_focus.set_border_width_all(2)
	style_focus.corner_radius_top_left = 6
	style_focus.corner_radius_top_right = 6
	style_focus.corner_radius_bottom_left = 6
	style_focus.corner_radius_bottom_right = 6
	style_focus.set_expand_margin_all(8)
	
	input.add_theme_stylebox_override("normal", style)
	input.add_theme_stylebox_override("focus", style_focus)
	input.add_theme_color_override("font_color", TEXT_PRIMARY)
	input.add_theme_color_override("caret_color", GOLD)
	input.add_theme_color_override("placeholder_text_color", TEXT_DISABLED)
	
	return input


static func modern_progress_bar(max_value: float = 100.0, color: Color = RED) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.max_value = max_value
	bar.value = max_value
	bar.custom_minimum_size = Vector2(200, 16)
	
	# Background
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.1, 0.08, 0.06, 0.8)
	bg_style.border_color = BORDER
	bg_style.set_border_enabled_all(true)
	bg_style.set_border_width_all(1)
	bg_style.corner_radius_top_left = 3
	bg_style.corner_radius_top_right = 3
	bg_style.corner_radius_bottom_left = 3
	bg_style.corner_radius_bottom_right = 3
	
	# Fill com gradiente
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = color
	fill_style.corner_radius_top_left = 2
	fill_style.corner_radius_top_right = 2
	fill_style.corner_radius_bottom_left = 2
	fill_style.corner_radius_bottom_right = 2
	
	bar.add_theme_stylebox_override("background", bg_style)
	bar.add_theme_stylebox_override("fill", fill_style)
	
	return bar


static func modern_badge(text: String, color: Color = GOLD, bg_color: Color = Color(212, 175, 55, 0.15)) -> PanelContainer:
	var badge := PanelContainer.new()
	
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = color
	style.set_border_enabled_all(true)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.set_expand_margin_all(4)
	
	badge.add_theme_stylebox_override("panel", style)
	
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", color)
	badge.add_child(lbl)
	
	return badge


static func modern_tooltip(text: String, width: int = 250) -> PanelContainer:
	var tooltip := PanelContainer.new()
	tooltip.custom_minimum_size = Vector2(width, 0)
	
	var style := StyleBoxFlat.new()
	style.bg_color = BG_PRIMARY
	style.border_color = GOLD_DIM
	style.set_border_enabled_all(true)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.set_expand_margin_all(8)
	
	tooltip.add_theme_stylebox_override("panel", style)
	
	var lbl := Label.new()
	lbl.text = text
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", TEXT_SECONDARY)
	tooltip.add_child(lbl)
	
	return tooltip


static func rarity_color(rarity: int) -> Color:
	return RARITY_COLORS.get(rarity, RARITY_COLORS[0])


static func pop_in(node: Node, duration: float = 0.3) -> Tween:
	node.scale = Vector2(0.8, 0.8)
	node.modulate.a = 0.5
	
	var tw := node.create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_BACK)
	tw.tween_property(node, "scale", Vector2.ONE, duration)
	tw.parallel().tween_property(node, "modulate:a", 1.0, duration)
	
	return tw


static func pop_out(node: Node, duration: float = 0.2) -> Tween:
	var tw := node.create_tween()
	tw.set_ease(Tween.EASE_IN)
	tw.set_trans(Tween.TRANS_BACK)
	tw.tween_property(node, "scale", Vector2(0.8, 0.8), duration)
	tw.parallel().tween_property(node, "modulate:a", 0.5, duration)
	
	return tw


static func lift_hover(node: Node) -> void:
	var original_pos = node.position
	
	node.mouse_entered.connect(func():
		var tw = node.create_tween()
		tw.set_ease(Tween.EASE_OUT)
		tw.set_trans(Tween.TRANS_QUAD)
		tw.tween_property(node, "position", original_pos - Vector2(0, 4), 0.15)
	)
	
	node.mouse_exited.connect(func():
		var tw = node.create_tween()
		tw.set_ease(Tween.EASE_OUT)
		tw.set_trans(Tween.TRANS_QUAD)
		tw.tween_property(node, "position", original_pos, 0.15)
	)


static func pulse(node: Node, scale_to: float = 1.05, duration: float = 2.0) -> Tween:
	var tw := node.create_tween()
	tw.set_loops()
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.set_trans(Tween.TRANS_SINE)
	tw.tween_property(node, "scale", Vector2(scale_to, scale_to), duration / 2.0)
	tw.tween_property(node, "scale", Vector2.ONE, duration / 2.0)
	
	return tw


static func toast(parent: Node, text: String, duration: float = 3.0, color: Color = TEXT_PRIMARY) -> void:
	var toast := modern_label(text, 14, color, true)
	toast.set_anchors_preset(Control.PRESET_CENTER)
	toast.position = Vector2(-300, 200)
	toast.modulate.a = 0.0
	parent.add_child(toast)
	
	var tw := toast.create_tween()
	tw.tween_property(toast, "modulate:a", 1.0, 0.2)
	tw.tween_callback(func(): pass)
	tw.tween_property(toast, "modulate:a", 0.0, 0.2).set_delay(duration)
	tw.tween_callback(func(): toast.queue_free())
