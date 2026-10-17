extends Control
## Criação de personagem estilo Baldur's Gate: raça, classe, aparência, nome,
## atributos por compra de pontos (D&D 5e), antecedente, dificuldade e modo Hardcore.

const POINT_BUY_TOTAL := 27
const COST := {8: 0, 9: 1, 10: 2, 11: 3, 12: 4, 13: 5, 14: 7, 15: 9}
const TINTS := [
	Color(1, 1, 1), Color(1.0, 0.86, 0.75), Color(0.8, 0.65, 0.5), Color(0.85, 0.95, 1.0),
	Color(0.85, 1.0, 0.85), Color(1.0, 0.8, 0.85), Color(0.8, 0.75, 1.0), Color(1.0, 0.95, 0.65),
]
const NAMES := {
	"default": ["Aldric", "Thalia", "Kael", "Seraphine", "Isolde", "Garrick", "Brienne", "Orin", "Vesper", "Mirela"],
	"elf": ["Aelar", "Lyra", "Faelar", "Sylvaris", "Elowen", "Thaeris", "Naivara", "Galinndan", "Shava", "Ilyana"],
	"dwarf": ["Borin", "Dagna", "Thorgar", "Helja", "Brottor", "Vistra", "Rurik", "Eldeth", "Dorn", "Kildrak"],
	"orc": ["Grommash", "Shura", "Thokk", "Baggi", "Ront", "Emen", "Kansif", "Volen", "Dench", "Engong"],
	"chort": ["Zariel", "Malphas", "Nyx", "Akmenos", "Orianna", "Kallista", "Damakos", "Ekemon", "Morthos", "Rieta"],
	"lizard": ["Arjhan", "Sora", "Kriv", "Biri", "Medrash", "Harann", "Nadarr", "Thava", "Rhogar", "Daar"],
	"wizzard": ["Fonkin", "Nissa", "Boddynock", "Zook", "Ellyjobell", "Orryn", "Bimpnottin", "Wrenn", "Glim", "Tana"],
	"goblin": ["Miau", "Garra", "Bigode", "Cinza", "Ventania", "Pulo", "Sombra", "Brasa", "Neblina", "Raio"],
	"ogre": ["Aukan", "Kuori", "Gae-Al", "Thalai", "Vaunea", "Keothi", "Manneo", "Eglath", "Ilikan", "Nalla"],
}

var race: RaceData
var cls: ClassData
var sex := "m"
var tint_idx := 0
var scores := {"str": 8, "dex": 8, "con": 8, "int": 8, "wis": 8, "cha": 8}
var free_bonus := {}
var background := "soldado"
var difficulty := 0
var hardcore := false
var _running := false

var _race_buttons := {}
var _class_buttons := {}
var _preview: SpritePreview
var _name_edit: LineEdit
var _points_label: Label
var _ability_rows := {}
var _info: RichTextLabel
var _stats_preview: RichTextLabel
var _free_box: VBoxContainer
var _free_options: Array[OptionButton] = []
var _bg_desc: Label
var _diff_desc: Label
var _sex_btn: Button
var _start_btn: Button
var _swatches: Array[Button] = []


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	race = DB.races[0]
	cls = DB.classes[0]

	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.02, 0.015)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 14)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)
	root.add_child(UIKit.title("Criação de Personagem", 30))

	var cols := HBoxContainer.new()
	cols.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cols.add_theme_constant_override("separation", 12)
	root.add_child(cols)
	cols.add_child(_build_left())
	cols.add_child(_build_center())
	cols.add_child(_build_right())

	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 12)
	root.add_child(bottom)
	bottom.add_child(UIKit.button("Voltar", func(): Game.change_scene(Game.MAIN_MENU), 160))
	bottom.add_child(UIKit.button("Aleatório", _randomize, 160))
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(sp)
	_start_btn = UIKit.button("Iniciar Aventura", _on_start, 240)
	_start_btn.add_theme_font_size_override("font_size", 20)
	bottom.add_child(_start_btn)

	_apply_recommended()
	_refresh()


# ------------------------------------------------------------------ COLUNA ESQUERDA

func _build_left() -> Control:
	var tabs := TabContainer.new()
	tabs.custom_minimum_size = Vector2(250, 0)

	var race_scroll := _scroll("Raça (%d)" % DB.races.size())
	tabs.add_child(race_scroll)
	var rg := GridContainer.new()
	rg.columns = 1
	rg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	race_scroll.add_child(rg)
	for r in DB.races:
		var b := _choice_button(r.display_name, DB.dt2_texture(r.sprite_m + "_idle_anim_f0"))
		b.pressed.connect(func():
			race = r
			if sex == "f" and r.sprite_f == r.sprite_m:
				sex = "m"
			free_bonus.clear()
			_name_edit.text = _random_name()
			_refresh()
		)
		rg.add_child(b)
		_race_buttons[r.id] = b

	var class_scroll := _scroll("Classe (%d)" % DB.classes.size())
	tabs.add_child(class_scroll)
	var cg := GridContainer.new()
	cg.columns = 1
	cg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	class_scroll.add_child(cg)
	for c in DB.classes:
		var b := _choice_button(c.display_name, DB.icon(c.icon))
		b.pressed.connect(func():
			cls = c
			_apply_recommended()
			_refresh()
		)
		cg.add_child(b)
		_class_buttons[c.id] = b
	return tabs


func _scroll(title_text: String) -> ScrollContainer:
	var s := ScrollContainer.new()
	s.name = title_text
	s.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	return s


func _choice_button(text: String, icon: Texture2D) -> Button:
	var b := Button.new()
	b.text = text
	b.toggle_mode = true
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(0, 34)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.add_theme_font_size_override("font_size", 15)
	b.clip_text = true
	if icon:
		b.icon = icon
		b.add_theme_constant_override("icon_max_width", 22)
	b.pressed.connect(func(): Sfx.play(&"click", -6.0))
	return b


# ------------------------------------------------------------------ CENTRO

func _build_center() -> Control:
	var p := PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	p.add_child(v)

	var name_row := HBoxContainer.new()
	name_row.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(name_row)
	_name_edit = LineEdit.new()
	_name_edit.placeholder_text = "Nome do herói"
	_name_edit.max_length = 18
	_name_edit.custom_minimum_size = Vector2(240, 38)
	_name_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_row.add_child(_name_edit)
	var dice := Button.new()
	dice.text = "🎲"
	dice.tooltip_text = "Nome aleatório"
	dice.custom_minimum_size = Vector2(42, 38)
	dice.pressed.connect(func(): _name_edit.text = _random_name())
	name_row.add_child(dice)

	var stage := Panel.new()
	stage.custom_minimum_size = Vector2(0, 210)
	stage.add_theme_stylebox_override("panel", UIKit.box(Color(0.07, 0.05, 0.04), UIKit.GOLD_DIM, 2, 8))
	v.add_child(stage)
	var floor_tex := TextureRect.new()
	floor_tex.texture = _floor_strip()
	floor_tex.stretch_mode = TextureRect.STRETCH_TILE
	floor_tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	floor_tex.set_anchors_preset(Control.PRESET_FULL_RECT)
	floor_tex.offset_left = 4
	floor_tex.offset_right = -4
	floor_tex.offset_top = 4
	floor_tex.offset_bottom = -4
	floor_tex.modulate = Color(0.5, 0.45, 0.45)
	stage.add_child(floor_tex)
	_preview = SpritePreview.new()
	_preview.set_anchors_preset(Control.PRESET_FULL_RECT)
	_preview.offset_top = 10
	_preview.offset_bottom = -10
	stage.add_child(_preview)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 6)
	v.add_child(row)
	_sex_btn = Button.new()
	_sex_btn.focus_mode = Control.FOCUS_NONE
	_sex_btn.custom_minimum_size = Vector2(130, 32)
	_sex_btn.pressed.connect(func():
		sex = "f" if sex == "m" else "m"
		Sfx.play(&"click", -6.0)
		_refresh()
	)
	row.add_child(_sex_btn)
	var run_btn := Button.new()
	run_btn.text = "Animação"
	run_btn.focus_mode = Control.FOCUS_NONE
	run_btn.custom_minimum_size = Vector2(110, 32)
	run_btn.pressed.connect(func():
		_running = not _running
		_preview.animation = "run" if _running else "idle"
	)
	row.add_child(run_btn)
	for i in TINTS.size():
		var sw := Button.new()
		sw.custom_minimum_size = Vector2(26, 26)
		sw.focus_mode = Control.FOCUS_NONE
		sw.tooltip_text = "Tom de pele/cor"
		var sb := UIKit.box(TINTS[i] * Color(0.85, 0.85, 0.85), UIKit.GOLD_DIM, 2, 13)
		sw.add_theme_stylebox_override("normal", sb)
		sw.add_theme_stylebox_override("hover", UIKit.box(TINTS[i], UIKit.GOLD, 2, 13))
		sw.add_theme_stylebox_override("pressed", UIKit.box(TINTS[i], Color.WHITE, 3, 13))
		sw.pressed.connect(func():
			tint_idx = i
			Sfx.play(&"click", -8.0)
			_refresh()
		)
		row.add_child(sw)
		_swatches.append(sw)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(scroll)
	_info = UIKit.rich()
	_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_info)
	return p


func _floor_strip() -> Texture2D:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	var sheet := DB.DT2_SHEET.get_image()
	if sheet.is_compressed():
		sheet.decompress()
	sheet.convert(Image.FORMAT_RGBA8)
	for x in 4:
		for y in 4:
			var n := "floor_1" if randf() > 0.25 else "floor_%d" % randi_range(2, 8)
			img.blit_rect(sheet, DB.dt2_rect(n), Vector2i(x * 16, y * 16))
	return ImageTexture.create_from_image(img)


# ------------------------------------------------------------------ DIREITA

func _build_right() -> Control:
	var tabs := TabContainer.new()
	tabs.custom_minimum_size = Vector2(350, 0)

	var attr := VBoxContainer.new()
	attr.name = "Atributos"
	attr.add_theme_constant_override("separation", 4)
	tabs.add_child(attr)
	_points_label = UIKit.label("", 15, UIKit.GOLD, true)
	_points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	attr.add_child(_points_label)
	var hdr := HBoxContainer.new()
	attr.add_child(hdr)
	for t in [["", 118], ["Base", 80], ["Bônus", 42], ["Total", 44], ["Mod", 34]]:
		var l := UIKit.label(t[0], 12, UIKit.TEXT_DIM)
		l.custom_minimum_size.x = t[1]
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hdr.add_child(l)
	for a in DB.ABILITIES:
		var r := HBoxContainer.new()
		attr.add_child(r)
		var n := UIKit.label(DB.ABILITY_NAMES[a], 14, UIKit.TEXT, true)
		n.custom_minimum_size.x = 118
		n.tooltip_text = DB.ABILITY_DESC[a]
		n.mouse_filter = Control.MOUSE_FILTER_PASS
		r.add_child(n)
		var minus := _small_button("−", func(): _change(a, -1))
		r.add_child(minus)
		var base := UIKit.label("", 15, Color.WHITE, true)
		base.custom_minimum_size.x = 26
		base.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		r.add_child(base)
		var plus := _small_button("+", func(): _change(a, 1))
		r.add_child(plus)
		var bonus := UIKit.label("", 14, Color(0.5, 1, 0.5))
		bonus.custom_minimum_size.x = 42
		bonus.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		r.add_child(bonus)
		var total := UIKit.label("", 17, UIKit.GOLD, true)
		total.custom_minimum_size.x = 44
		total.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		r.add_child(total)
		var m := UIKit.label("", 14, UIKit.TEXT_DIM)
		m.custom_minimum_size.x = 34
		m.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		r.add_child(m)
		_ability_rows[a] = {"base": base, "bonus": bonus, "total": total, "mod": m, "minus": minus, "plus": plus, "name": n}
	var btns := HBoxContainer.new()
	btns.alignment = BoxContainer.ALIGNMENT_CENTER
	attr.add_child(btns)
	btns.add_child(UIKit.button("Recomendado", func():
		_apply_recommended()
		_refresh()
	))
	btns.add_child(UIKit.button("Zerar", func():
		for k in scores:
			scores[k] = 8
		_refresh()
	))
	_free_box = VBoxContainer.new()
	attr.add_child(_free_box)
	attr.add_child(UIKit.separator())
	_stats_preview = UIKit.rich()
	attr.add_child(_stats_preview)

	var origin := VBoxContainer.new()
	origin.name = "Origem"
	origin.add_theme_constant_override("separation", 8)
	tabs.add_child(origin)
	origin.add_child(UIKit.label("Antecedente", 17, UIKit.GOLD, true))
	var bg_opt := OptionButton.new()
	bg_opt.focus_mode = Control.FOCUS_NONE
	var keys := DB.BACKGROUNDS.keys()
	for k in keys:
		bg_opt.add_item(DB.BACKGROUNDS[k].name)
	bg_opt.item_selected.connect(func(i: int):
		background = keys[i]
		_refresh()
	)
	origin.add_child(bg_opt)
	_bg_desc = UIKit.label("", 14, UIKit.TEXT_DIM)
	_bg_desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	origin.add_child(_bg_desc)
	origin.add_child(UIKit.separator())
	origin.add_child(UIKit.label("Dificuldade", 17, UIKit.GOLD, true))
	var diff_opt := OptionButton.new()
	diff_opt.focus_mode = Control.FOCUS_NONE
	for d in DB.DIFFICULTIES:
		diff_opt.add_item(d.name)
	diff_opt.item_selected.connect(func(i: int):
		difficulty = i
		_refresh()
	)
	origin.add_child(diff_opt)
	_diff_desc = UIKit.label("", 14, UIKit.TEXT_DIM)
	_diff_desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	origin.add_child(_diff_desc)
	var hc := CheckButton.new()
	hc.text = "Modo Hardcore (morte permanente)"
	hc.focus_mode = Control.FOCUS_NONE
	hc.toggled.connect(func(on: bool):
		hardcore = on
		Sfx.play(&"click")
	)
	origin.add_child(hc)
	origin.add_child(UIKit.separator())
	origin.add_child(UIKit.rich("[color=#999999]Compra de pontos (D&D 5e): cada atributo começa em 8 e vai até 15. Valores altos custam mais. O [color=#e8c060]atributo primário[/color] da classe aumenta seu dano.[/color]"))
	return tabs


func _small_button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(26, 26)
	b.add_theme_font_size_override("font_size", 14)
	b.pressed.connect(cb)
	b.pressed.connect(func(): Sfx.play(&"click", -10.0))
	return b


# ------------------------------------------------------------------ LÓGICA

func _spent() -> int:
	var total := 0
	for a in scores:
		total += COST[scores[a]]
	return total


func _change(a: String, d: int) -> void:
	var nv: int = scores[a] + d
	if nv < 8 or nv > 15:
		return
	var old: int = scores[a]
	scores[a] = nv
	if _spent() > POINT_BUY_TOTAL:
		scores[a] = old
		return
	_refresh()


## Distribui 27 pontos seguindo a prioridade da classe (15, 14, 13, 12, 10, 8)
func _apply_recommended() -> void:
	var order: Array = Array(cls.recommended)
	for a in DB.ABILITIES:
		if not order.has(a):
			order.append(a)
	var arr := [15, 14, 13, 12, 10, 8]
	for i in order.size():
		scores[order[i]] = arr[i]


func _random_name() -> String:
	var key := race.sprite_m.split("_")[0]
	var list: Array = NAMES.get(key, NAMES.default)
	return list.pick_random()


func _randomize() -> void:
	race = DB.races.pick_random()
	cls = DB.classes.pick_random()
	sex = ["m", "f"].pick_random() if race.sprite_f != race.sprite_m else "m"
	tint_idx = randi() % TINTS.size()
	free_bonus.clear()
	_apply_recommended()
	_name_edit.text = _random_name()
	Sfx.play(&"magic", -6.0)
	_refresh()


func _current_tint() -> Color:
	return TINTS[tint_idx] * race.tint


func _build_free_bonus() -> void:
	for c in _free_box.get_children():
		c.queue_free()
	_free_options.clear()
	if race.free_bonus_choices <= 0:
		return
	_free_box.add_child(UIKit.label("%s: escolha %d atributos para +1" % [race.display_name, race.free_bonus_choices], 13, Color(0.5, 1, 0.5)))
	var row := HBoxContainer.new()
	_free_box.add_child(row)
	var chosen := free_bonus.keys()
	for i in race.free_bonus_choices:
		var o := OptionButton.new()
		o.focus_mode = Control.FOCUS_NONE
		o.custom_minimum_size.x = 150
		for a in DB.ABILITIES:
			o.add_item(DB.ABILITY_NAMES[a])
		var pick: String = chosen[i] if i < chosen.size() else ["con", "dex"][i % 2]
		o.selected = DB.ABILITIES.find(pick)
		o.item_selected.connect(func(_i): _read_free_bonus())
		row.add_child(o)
		_free_options.append(o)
	_read_free_bonus(false)


func _read_free_bonus(refresh := true) -> void:
	free_bonus.clear()
	for o in _free_options:
		var a: String = DB.ABILITIES[o.selected]
		free_bonus[a] = int(free_bonus.get(a, 0)) + 1
	if refresh:
		_refresh_abilities()


func _make_hero() -> Hero:
	var n := _name_edit.text.strip_edges()
	if n == "":
		n = _random_name()
	return Hero.create(n, race, cls, sex, TINTS[tint_idx], scores, free_bonus, background, difficulty, hardcore)


func _refresh() -> void:
	for id in _race_buttons:
		_race_buttons[id].button_pressed = id == race.id
	for id in _class_buttons:
		_class_buttons[id].button_pressed = id == cls.id
	for i in _swatches.size():
		_swatches[i].button_pressed = i == tint_idx
	if _name_edit.text == "":
		_name_edit.text = _random_name()
	var base := race.sprite_f if sex == "f" else race.sprite_m
	_preview.set_sprite(base, _current_tint())
	var w := DB.create_item(cls.starting_weapon, 1, 0)
	_preview.weapon = DB.dt2_texture(w.sprite) if w.sprite != "" else null
	var has_f := race.sprite_f != race.sprite_m
	_sex_btn.text = ("♀ Feminino" if sex == "f" else "♂ Masculino") if has_f else "♂ / ♀"
	_sex_btn.disabled = not has_f
	_build_free_bonus()
	_refresh_abilities()
	var bg: Dictionary = DB.BACKGROUNDS[background]
	_bg_desc.text = bg.desc
	var d: Dictionary = DB.DIFFICULTIES[difficulty]
	_diff_desc.text = "Vida dos monstros ×%.1f, dano ×%.2f. Itens melhores (+%d%%) e +%d%% de experiência." % [d.hp, d.dmg, roundi(d.loot * 100), roundi((d.xp - 1.0) * 100)]
	_diff_desc.add_theme_color_override("font_color", d.color)

	var bonus_txt := ""
	for k in race.ability_bonus:
		var v: int = race.ability_bonus[k]
		bonus_txt += "%s%d %s  " % ["+" if v > 0 else "", v, DB.ABILITY_SHORT[k]]
	var skills_txt := ""
	for s in cls.skills:
		skills_txt += "[img=18x18]%s[/img] %s [color=#888888](nv %d)[/color]   " % [_icon_path(s.icon), s.display_name, s.unlock_level]
	var weapons := PackedStringArray()
	for c in cls.allowed_weapons:
		weapons.append(DB.CATEGORY_NAMES.get(c, c))
	var res_hex := cls.resource_color.to_html(false)
	_info.text = "[font_size=19][color=#e8c060]%s[/color][/font_size]  [color=#80ff80]%s[/color]\n%s\n[color=#e8c060]%s:[/color] %s\n\n[font_size=19][color=#e8c060]%s[/color][/font_size]  [color=#999999]%s[/color]\n%s\n[color=#cccccc]Dado de Vida: d%d  •  Primário: %s  •  Recurso: [color=#%s]%s[/color]  •  Armas: %s[/color]\n\n%s" % [
		race.display_name, bonus_txt, race.description, race.trait_name, race.trait_description,
		cls.display_name, cls.role, cls.description, cls.hit_die, DB.ABILITY_NAMES[cls.primary_ability], res_hex, cls.resource_label,
		", ".join(weapons), skills_txt]


func _icon_path(icon_name: String) -> String:
	return "res://assets/icons/%s.png" % icon_name


func _refresh_abilities() -> void:
	var left := POINT_BUY_TOTAL - _spent()
	_points_label.text = "Pontos restantes: %d / %d" % [left, POINT_BUY_TOTAL]
	_points_label.add_theme_color_override("font_color", UIKit.GOLD if left > 0 else Color(0.5, 1, 0.5))
	for a in DB.ABILITIES:
		var row: Dictionary = _ability_rows[a]
		var b: int = int(race.ability_bonus.get(a, 0)) + int(free_bonus.get(a, 0))
		var total: int = scores[a] + b
		var m := DB.ability_mod(total)
		row.base.text = str(scores[a])
		row.bonus.text = ("%+d" % b) if b != 0 else ""
		row.bonus.add_theme_color_override("font_color", Color(0.5, 1, 0.5) if b > 0 else Color(1, 0.5, 0.5))
		row.total.text = str(total)
		row.mod.text = ("+%d" % m) if m >= 0 else str(m)
		var primary: bool = a == cls.primary_ability
		row.name.add_theme_color_override("font_color", UIKit.GOLD if primary else UIKit.TEXT)
		row.minus.disabled = scores[a] <= 8
		var next_cost: int = COST.get(scores[a] + 1, 999) - COST[scores[a]]
		row.plus.disabled = scores[a] >= 15 or next_cost > left
	# Prévia das estatísticas com um herói temporário
	var h := _make_hero()
	var t := "[font_size=13][table=2]"
	t += _cell("Vida", "%d" % h.max_hp())
	t += _cell(cls.resource_label, "%d" % h.max_resource())
	t += _cell("Dano (DPS)", "%.1f" % h.dps_estimate())
	t += _cell("Armadura", "%d" % h.armor())
	t += _cell("Crítico", "%.1f%%" % (h.crit_chance() * 100))
	t += _cell("Velocidade", "%d%%" % roundi(h.move_speed() / Hero.BASE_MOVE_SPEED * 100))
	_stats_preview.text = t + "[/table][/font_size]"


func _cell(label_text: String, value: String) -> String:
	return "[cell][color=#aaaaaa]%s   [/color][/cell][cell][color=#ffffff]%s[/color][/cell]" % [label_text, value]


func _on_start() -> void:
	var h := _make_hero()
	Game.delete_save()
	_start_btn.disabled = true
	Game.new_game(h)
