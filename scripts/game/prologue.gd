class_name Prologue
extends World
## Prólogo: a Reminiscência de Vale Cinzento (REGRAS §13, MECANICAS §11, LORE §9).
## Vila de tutorial handcrafted: casa do jogador, clareira com fogueira,
## campo de treino com espantalho e floresta rala ao norte (além do portão de névoa).
## O Cinzento (Silhueta) guia os passos do tutorial; ao nível 1, o espelho chama.

signal tutorial_step_done(step: int)

enum TutStep { MOVE, ATTACK, COLLECT, EQUIP, POTION, CAMPFIRE, DONE }

const MAP_W := 56
const MAP_H := 44

# Layout (células) — tudo determinístico, nada de RNG
const FOREST := Rect2i(10, 3, 36, 15)       ## floresta rala ao norte
const GATE := Rect2i(25, 17, 6, 8)         ## corredor da névoa (floresta ↔ clareira)
const CLEARING := Rect2i(16, 24, 25, 17)   ## clareira central da vila
const HOUSE_RING := Rect2i(21, 33, 8, 7)   ## paredes da casa
const HOUSE := Rect2i(22, 34, 6, 5)        ## interior da casa
const DOOR := Vector2i(24, 39)             ## porta da casa (sul)
const TRAINING := Rect2i(42, 26, 12, 11)   ## campo de treino (leste)
const TRAINING_PATH := Rect2i(40, 30, 3, 2) ## passagem clareira ↔ campo

const START_CELL := Vector2i(24, 36)       ## onde o aldeão acorda (dentro da casa)
const MIRROR_CELL := Vector2i(26, 34)      ## espelho antigo (parede norte da casa)
const CAMPFIRE_CELL := Vector2i(28, 32)    ## fogueira central da vila
const SCARECROW_CELL := Vector2i(47, 31)   ## espantalho de treino
const CHEST_CELLS := [Vector2i(44, 28), Vector2i(50, 34), Vector2i(52, 27)]

# Tutorial
const MOVE_DIST := 90.0                    ## distância andada para concluir o passo 1
const GATE_ROW := 20                       ## linha do portão de névoa
const WOLF_CELLS := [Vector2i(18, 7), Vector2i(28, 5), Vector2i(36, 9)]
## Para onde o Cinzento se move em cada passo
const CINZENTO_ANCHORS := [
	Vector2i(26, 36),  ## MOVE — dentro da casa
	Vector2i(45, 30),  ## ATTACK — junto ao espantalho
	Vector2i(46, 32),  ## COLLECT — onde cai a espada
	Vector2i(44, 33),  ## EQUIP
	Vector2i(25, 34),  ## POTION — caminho até a fogueira
	Vector2i(27, 33),  ## CAMPFIRE
]
const CINZENTO_LINES := [
	"As pernas primeiro. Tudo o mais vem andando atrás.",
	"Madeira não revida. A madeira é mais honesta que a maioria do que você vai enfrentar.",
	"Ferro de verdade para mãos de verdade. Apanhe.",
	"Uma arma na mão vale mais que dez promessas no bolso. Vista-a.",
	"Você vai se machucar. Todos se machucam. Aprenda a carregar a cura.",
	"Fogo é memória que aquece as mãos. Acenda — e o sonho vai guardar você.",
]

var tut_step: TutStep = TutStep.MOVE
var _moved := 0.0
var _last_player_pos := Vector2.ZERO
var _cinzento: Cinzento
var _espantalho: Enemy
var _mirror_used := false
var _gate_wall: StaticBody2D
var _gate_fog: Array[Polygon2D] = []
var _gate_t := 0.0
var _level1_seen := false


func _ready() -> void:
	super()
	_setup_tutorial()


func _setup_map() -> void:
	gen.width = MAP_W
	gen.height = MAP_H
	gen.grid = PackedByteArray()
	gen.grid.resize(MAP_W * MAP_H)
	gen.grid.fill(DungeonGenerator.SOLID)
	gen.rooms.clear()
	_carve_rect(CLEARING)
	_carve_rect(FOREST)
	_carve_rect(TRAINING)
	_carve_rect(TRAINING_PATH)
	_carve_rect(GATE)
	# Floresta rala: árvores sólidas espalhadas de forma determinística
	for x in range(FOREST.position.x, FOREST.position.x + FOREST.size.x):
		for y in range(FOREST.position.y, FOREST.position.y + FOREST.size.y):
			if (x * 13 + y * 7) % 5 == 0:
				gen.set_cell(Vector2i(x, y), DungeonGenerator.SOLID)
	# Casa: paredes, interior e porta
	for x in range(HOUSE_RING.position.x, HOUSE_RING.position.x + HOUSE_RING.size.x):
		for y in range(HOUSE_RING.position.y, HOUSE_RING.position.y + HOUSE_RING.size.y):
			gen.set_cell(Vector2i(x, y), DungeonGenerator.SOLID)
	_carve_rect(HOUSE)
	gen.set_cell(DOOR, DungeonGenerator.FLOOR)
	# Registros de sala (uso geral do World)
	gen.rooms = [HOUSE, CLEARING, TRAINING, FOREST]
	gen.start_room = HOUSE
	explored.resize(gen.width * gen.height)
	explored.fill(0)
	_build_tiles()
	_build_astar()


func _carve_rect(r: Rect2i) -> void:
	for x in range(r.position.x, r.position.x + r.size.x):
		for y in range(r.position.y, r.position.y + r.size.y):
			gen.set_cell(Vector2i(x, y), DungeonGenerator.FLOOR)


func _spawn_content() -> void:
	# Espelho antigo da casa — vazio, sem reflexo (o Véu roubou; LORE §9)
	Interactable.create(self, Interactable.Kind.MIRROR, cell_to_world(MIRROR_CELL))
	# Fogueira central da vila
	Interactable.create(self, Interactable.Kind.CAMPFIRE, cell_to_world(CAMPFIRE_CELL))
	# Espantalho de treino (passivo — nunca agride)
	_espantalho = spawn_enemy(DB.get_enemy(&"espantalho"), cell_to_world(SCARECROW_CELL), Enemy.Rarity.COMUM)
	# Baús didáticos
	for c in CHEST_CELLS:
		Interactable.create(self, Interactable.Kind.CHEST, cell_to_world(c))
	# Decoração: caixotes e detalhes da vila
	for d in [Vector2i(43, 27), Vector2i(51, 33), Vector2i(23, 32), Vector2i(30, 34)]:
		var s := Sprite2D.new()
		s.texture = DB.dt2_texture("crate")
		s.position = cell_to_world(d)
		decals.add_child(s)


func _setup_tutorial() -> void:
	_last_player_pos = player.global_position
	_cinzento = Cinzento.new()
	entities.add_child(_cinzento)
	_cinzento.appear_at(cell_to_world(CINZENTO_ANCHORS[0]))
	_whisper("Levante-se, cinza. Este lugar já foi casa — e vai querer ser de novo.")
	_whisper(CINZENTO_LINES[0])
	_build_gate()
	Game.hero.leveled_up.connect(_on_hero_leveled_up)


# ------------------------------------------------------------------ PASSOS

func _process(delta: float) -> void:
	super(delta)
	_gate_t += delta
	# Névoa do portão tremula
	for i in _gate_fog.size():
		_gate_fog[i].modulate.a = 0.45 + sin(_gate_t * 2.2 + i * 1.7) * 0.12
	if player == null or player.is_dead():
		return
	if tut_step == TutStep.MOVE:
		_moved += player.global_position.distance_to(_last_player_pos)
		if _moved >= MOVE_DIST:
			_advance()
	elif tut_step == TutStep.COLLECT:
		if _has_wood_sword():
			_advance()
	elif tut_step == TutStep.EQUIP:
		if Game.hero.equipment.weapon != null:
			_advance()
	elif tut_step == TutStep.POTION:
		if player.potion_cd > 0.0:
			_advance()
	_last_player_pos = player.global_position


func _has_wood_sword() -> bool:
	for it in Game.hero.inventory.items:
		if it is Item and it.base_id == &"wood_sword":
			return true
	return false


func _step_condition_met() -> bool:
	match tut_step:
		TutStep.MOVE: return _moved >= MOVE_DIST
		TutStep.COLLECT: return _has_wood_sword()
		TutStep.EQUIP: return Game.hero.equipment.weapon != null
		TutStep.POTION: return player.potion_cd > 0.0
	return false


func _advance() -> void:
	tut_step += 1
	tutorial_step_done.emit(tut_step)
	Sfx.play(&"levelup", -8.0)
	if tut_step == TutStep.DONE:
		_open_gate()
		return
	_cinzento.appear_at(cell_to_world(CINZENTO_ANCHORS[tut_step]))
	_whisper(CINZENTO_LINES[tut_step])
	# Passos concluídos fora de ordem avançam em cascata
	if _step_condition_met():
		_advance()


func _on_enemy_killed(e: Enemy) -> void:
	super(e)
	if e == _espantalho:
		# O Cinzento deixa ferro de verdade onde o espantalho caiu
		LootDrop.drop_item(self, e.global_position, DB.create_item(&"wood_sword", 1, Item.Rarity.COMMON))
		if tut_step == TutStep.ATTACK:
			_advance()


func _on_campfire_lit(fire: Interactable) -> void:
	player.heal(player.max_hp)
	Game.respawn_pos = fire.global_position + Vector2(0, 20)
	Game.save_game()
	hud.show_message("A brasa te reconhece. Você renascerá aqui.", Color(1, 0.7, 0.3))
	if tut_step == TutStep.CAMPFIRE:
		_advance()


# ------------------------------------------------------------------ PORTÃO

func _build_gate() -> void:
	_gate_wall = StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(GATE.size.x * TILE, 14.0)
	shape.shape = rect
	_gate_wall.position = cell_to_world(Vector2i(GATE.position.x + GATE.size.x / 2, GATE_ROW + 1))
	_gate_wall.add_child(shape)
	add_child(_gate_wall)
	# Véu visual: faixas de névoa translúcidas
	for i in 3:
		var fog := Polygon2D.new()
		var w := GATE.size.x * float(TILE)
		var mid := cell_to_world(Vector2i(GATE.position.x + GATE.size.x / 2, GATE_ROW + 1))
		fog.polygon = PackedVector2Array([
			Vector2(mid.x - w / 2, mid.y - 14), Vector2(mid.x + w / 2, mid.y - 14),
			Vector2(mid.x + w / 2, mid.y + 14), Vector2(mid.x - w / 2, mid.y + 14),
		])
		fog.color = Color(0.72, 0.7, 0.82, 0.4)
		fog.z_index = 4
		add_child(fog)
		_gate_fog.append(fog)


func _open_gate() -> void:
	var tw := create_tween()
	for f in _gate_fog:
		tw.parallel().tween_property(f, "modulate:a", 0.0, 1.2)
	_cinzento.appear_at(cell_to_world(Vector2i(27, 21)))
	_whisper("A névoa guardava o que você ainda não podia enfrentar. Agora pode.")
	_whisper("Lobos de sombra adiante — restos de uma noite que ninguém lembra. Lute.")
	var wall := _gate_wall
	tw.tween_callback(func():
		if is_instance_valid(wall):
			wall.queue_free()
	)
	_gate_wall = null
	# As duas lutas do prólogo (REGRAS §13)
	for c in WOLF_CELLS:
		spawn_enemy(DB.get_enemy(&"lobo_sombrio"), cell_to_world(c), Enemy.Rarity.COMUM)


func _on_hero_leveled_up(new_level: int) -> void:
	# Nível 1: o reflexo chama (cutscene/criação entram na tarefa 1.4)
	if new_level == 1 and not _level1_seen:
		_level1_seen = true
		_cinzento.appear_at(cell_to_world(Vector2i(25, 36)))
		_whisper("Você não é mais quem era quando acordou. Volte à casa — o espelho espera.")


## Olhar-se no espelho: antes do nível 1, só o vazio; depois, a Reminiscência
## se dobra para dentro de si mesma e devolve não o que você era —
## mas o que você escolhe ser (REGRAS §13, MECANICAS §11).
func _on_mirror(_mirror: Interactable) -> void:
	if _mirror_used:
		return
	if Game.hero.level < 1:
		_whisper("Vidro vazio, como você. A névoa ainda tem algo a ensinar antes disto.")
		return
	if tut_step != TutStep.DONE:
		_whisper("O espelho espera. Termine o que a névoa pediu.")
		return
	_mirror_used = true
	_cinzento.appear_at(player.global_position + Vector2(-24, -10))
	_whisper("...")
	_whisper("Vidro vazio. O Véu levou o reflexo — e guardou, em troca, uma escolha.")
	_whisper("Quem?")
	Sfx.play(&"levelup", -6.0)
	# A memória se dobra para dentro de si mesma
	await get_tree().create_timer(2.4, true, false, true).timeout
	if not is_inside_tree() or player == null or player.is_dead():
		return
	var tw := create_tween()
	tw.tween_property(canvas_modulate, "color", Color(0, 0, 0, 1), 1.2)
	await tw.finished
	Game.change_scene(Game.CHARACTER_CREATION)


# ------------------------------------------------------------------ MUNDO

func _intro() -> void:
	Game.play_music("res://assets/audio/music_menu.ogg")
	hud.show_message("Reminiscência", UIKit.GOLD, 3.0)
	hud.show_message("Um sonho que já foi casa.", UIKit.TEXT_DIM, 4.0)


func _apply_brightness() -> void:
	## Tom quente e levemente irreal — é uma memória, não um lugar.
	var b: float = Game.settings.brightness
	var c := Color(0.52, 0.48, 0.46)
	canvas_modulate.color = Color(c.r * b, c.g * b, c.b * b, 1.0)


func _whisper(text: String) -> void:
	hud.show_message(text, Cinzento.VOICE, 5.0)
	Sfx.play(&"magic", -12.0)


func _start_position() -> Vector2:
	return cell_to_world(START_CELL)


func respawn_position() -> Vector2:
	return cell_to_world(START_CELL)


func level() -> int:
	return 1


func region_name() -> String:
	return "Reminiscência de Vale Cinzento"
