class_name UnifiedPanel
extends PanelContainer
## Painel do jogador unificado (Fase 6.2, MECANICAS §9.3): abas
## Personagem | Inventário | Habilidades | Missões em uma só janela.
## Os painéis existentes viram páginas — cada tecla (I/C/K/J) abre direto
## na aba correspondente; abrir outra aba troca, abrir na mesma fecha.

const WIDTH := 760.0
const HEIGHT := 470.0

var panels: Array = []
var current := -1
var _tabs: HBoxContainer
var _tab_buttons: Array[Button] = []
var _body: Control


func _init() -> void:
	add_theme_stylebox_override("panel", UIKit.box(Color(0.04, 0.03, 0.02, 0.97), UIKit.GOLD, 1, 12))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	add_child(v)
	_tabs = HBoxContainer.new()
	_tabs.add_theme_constant_override("separation", 6)
	v.add_child(_tabs)
	v.add_child(UIKit.separator())
	_body = Control.new()
	_body.custom_minimum_size = Vector2(WIDTH, HEIGHT)
	_body.clip_contents = true
	v.add_child(_body)
	visible = false


## Registra um painel existente como página (re-parenting)
func add_page(title: String, panel: Control) -> void:
	var idx := panels.size()
	panels.append({"title": title, "panel": panel})
	panel.visible = false
	_body.add_child(panel)
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	var b := UIKit.button(title, func(): toggle(idx))
	_tab_buttons.append(b)
	_tabs.add_child(b)


func open_tab(idx: int) -> void:
	if idx < 0 or idx >= panels.size():
		return
	current = idx
	for i in panels.size():
		var p: Control = panels[i]["panel"]
		p.visible = (i == idx)
	visible = true
	_refresh_tabs()


func close() -> void:
	current = -1
	visible = false
	for i in panels.size():
		(panels[i]["panel"] as Control).visible = false


func is_open() -> bool:
	return visible


## Comportamento das teclas I/C/K/J: fechado abre na aba; aberto na mesma
## aba fecha; aberto em outra aba troca
func toggle(idx: int, on_open: Callable = Callable()) -> void:
	if not is_open():
		open_tab(idx)
		if on_open.is_valid():
			on_open.call()
	elif current == idx:
		close()
	else:
		open_tab(idx)
		if on_open.is_valid():
			on_open.call()


func _refresh_tabs() -> void:
	for i in _tab_buttons.size():
		# aba ativa com underline dourado (§9.3)
		_tab_buttons[i].modulate = UIKit.ACCENT_GOLD if i == current else UIKit.TEXT_DIM
