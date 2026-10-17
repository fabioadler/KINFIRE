class_name UIKit
extends RefCounted
## Estilo visual (tema escuro com bordas douradas, estilo Diablo) e helpers de UI.

const FONT_TITLE := preload("res://assets/fonts/Cinzel.ttf")
const FONT_BODY := preload("res://assets/fonts/Alegreya.ttf")

const GOLD := Color(0.86, 0.68, 0.36)
const GOLD_DIM := Color(0.5, 0.38, 0.2)
const TEXT := Color(0.9, 0.85, 0.75)
const TEXT_DIM := Color(0.6, 0.55, 0.48)
const BG := Color(0.06, 0.045, 0.035, 0.96)
const BG_LIGHT := Color(0.12, 0.09, 0.07, 0.96)
const RED := Color(0.75, 0.12, 0.08)


static func install_theme() -> void:
	var t := ThemeDB.get_default_theme()
	ThemeDB.fallback_font = FONT_BODY
	t.default_font = FONT_BODY
	t.default_font_size = 17

	var panel := box(BG, GOLD_DIM, 2, 4)
	panel.shadow_size = 8
	panel.shadow_color = Color(0, 0, 0, 0.6)
	t.set_stylebox("panel", "PanelContainer", panel)
	t.set_stylebox("panel", "Panel", panel)

	var normal := box(Color(0.16, 0.08, 0.06), GOLD_DIM, 2, 3)
	var hover := box(Color(0.3, 0.12, 0.07), GOLD, 2, 3)
	var pressed := box(Color(0.1, 0.05, 0.04), GOLD, 2, 3)
	var disabled := box(Color(0.1, 0.09, 0.08), Color(0.25, 0.22, 0.2), 2, 3)
	for st in [normal, hover, pressed, disabled]:
		st.content_margin_left = 14
		st.content_margin_right = 14
		st.content_margin_top = 6
		st.content_margin_bottom = 6
	t.set_stylebox("normal", "Button", normal)
	t.set_stylebox("hover", "Button", hover)
	t.set_stylebox("pressed", "Button", pressed)
	t.set_stylebox("disabled", "Button", disabled)
	t.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	t.set_stylebox("hover_pressed", "Button", hover)
	t.set_font("font", "Button", FONT_TITLE)
	t.set_font_size("font_size", "Button", 17)
	t.set_color("font_color", "Button", TEXT)
	t.set_color("font_hover_color", "Button", Color(1, 0.92, 0.7))
	t.set_color("font_pressed_color", "Button", GOLD)
	t.set_color("font_disabled_color", "Button", Color(0.4, 0.37, 0.33))
	t.set_color("font_focus_color", "Button", TEXT)

	t.set_color("font_color", "Label", TEXT)
	t.set_color("default_color", "RichTextLabel", TEXT)
	t.set_font("normal_font", "RichTextLabel", FONT_BODY)
	t.set_font("bold_font", "RichTextLabel", FONT_TITLE)
	t.set_font_size("normal_font_size", "RichTextLabel", 16)
	t.set_font_size("bold_font_size", "RichTextLabel", 17)

	var le := box(Color(0.03, 0.02, 0.02), GOLD_DIM, 2, 3)
	le.content_margin_left = 10
	t.set_stylebox("normal", "LineEdit", le)
	t.set_stylebox("focus", "LineEdit", box(Color(0.03, 0.02, 0.02), GOLD, 2, 3))
	t.set_font("font", "LineEdit", FONT_TITLE)
	t.set_color("font_color", "LineEdit", TEXT)

	t.set_stylebox("slider", "HSlider", box(Color(0.03, 0.02, 0.02), GOLD_DIM, 1, 3))
	t.set_stylebox("grabber_area", "HSlider", box(RED, RED, 0, 3))
	t.set_stylebox("grabber_area_highlight", "HSlider", box(Color(0.9, 0.2, 0.1), Color(0.9, 0.2, 0.1), 0, 3))

	t.set_stylebox("panel", "TooltipPanel", box(Color(0.03, 0.02, 0.02, 0.97), GOLD_DIM, 2, 3))
	t.set_color("font_color", "TooltipLabel", TEXT)

	var tab_sel := box(Color(0.25, 0.1, 0.06), GOLD, 2, 3)
	var tab_un := box(Color(0.1, 0.06, 0.05), GOLD_DIM, 2, 3)
	for st in [tab_sel, tab_un]:
		st.content_margin_left = 12
		st.content_margin_right = 12
		st.content_margin_top = 4
		st.content_margin_bottom = 4
	t.set_stylebox("tab_selected", "TabContainer", tab_sel)
	t.set_stylebox("tab_unselected", "TabContainer", tab_un)
	t.set_stylebox("tab_hovered", "TabContainer", tab_sel)
	t.set_stylebox("panel", "TabContainer", box(BG_LIGHT, GOLD_DIM, 2, 3))
	t.set_font("font", "TabContainer", FONT_TITLE)

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.03, 0.02, 0.02, 0.5)
	t.set_stylebox("scroll", "VScrollBar", sb)
	t.set_stylebox("grabber", "VScrollBar", box(GOLD_DIM, GOLD_DIM, 0, 3))
	t.set_stylebox("grabber_highlight", "VScrollBar", box(GOLD, GOLD, 0, 3))
	t.set_stylebox("grabber_pressed", "VScrollBar", box(GOLD, GOLD, 0, 3))


static func box(bg: Color, border: Color, border_w: int = 2, radius: int = 3) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(border_w)
	s.set_corner_radius_all(radius)
	s.content_margin_left = 8
	s.content_margin_right = 8
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	return s


static func label(text: String, size: int = 17, color: Color = TEXT, title_font: bool = false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if title_font:
		l.add_theme_font_override("font", FONT_TITLE)
	return l


static func title(text: String, size: int = 26) -> Label:
	var l := label(text, size, GOLD, true)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	l.add_theme_constant_override("outline_size", 6)
	return l


static func button(text: String, callback: Callable, min_w: int = 0) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(min_w, 40)
	b.pressed.connect(func(): Sfx.play(&"click", -6.0))
	b.pressed.connect(callback)
	b.mouse_entered.connect(func():
		if not b.disabled:
			Sfx.play(&"cloth", -18.0)
	)
	return b


static func rich(text: String = "", fit: bool = true) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = fit
	r.scroll_active = not fit
	r.text = text
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


static func separator() -> Control:
	var c := ColorRect.new()
	c.color = GOLD_DIM
	c.custom_minimum_size = Vector2(0, 1)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


static func icon(icon_name: String, px: int = 32) -> TextureRect:
	var tr := TextureRect.new()
	tr.texture = DB.icon(icon_name)
	tr.custom_minimum_size = Vector2(px, px)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return tr


## Painel modal centralizado com título e botão de fechar
static func window_panel(title_text: String, size: Vector2, on_close: Callable = Callable()) -> Dictionary:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = size
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	panel.add_child(v)
	var header := HBoxContainer.new()
	v.add_child(header)
	var t := title(title_text, 24)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(t)
	if on_close.is_valid():
		var x := Button.new()
		x.text = "✕"
		x.custom_minimum_size = Vector2(34, 34)
		x.pressed.connect(on_close)
		header.add_child(x)
	v.add_child(separator())
	return {"panel": panel, "body": v}
