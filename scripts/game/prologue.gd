class_name Prologue
extends World
## Prólogo: a Reminiscência de Vale Cinzento (REGRAS §13, MECANICAS §11, LORE §9).
## Vila de tutorial handcrafted: casa do jogador, clareira com fogueira,
## campo de treino com espantalho e floresta rala ao norte (além do portão de névoa).

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
const CAMPFIRE_CELL := Vector2i(28, 32)    ## fogueira central da vila
const SCARECROW_CELL := Vector2i(47, 31)   ## espantalho de treino
const CHEST_CELLS := [Vector2i(44, 28), Vector2i(50, 34), Vector2i(52, 27)]


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
	# Fogueira central da vila
	Interactable.create(self, Interactable.Kind.CAMPFIRE, cell_to_world(CAMPFIRE_CELL))
	# Espantalho de treino (passivo — nunca agride)
	spawn_enemy(DB.get_enemy(&"espantalho"), cell_to_world(SCARECROW_CELL), false)
	# Baús didáticos
	for c in CHEST_CELLS:
		Interactable.create(self, Interactable.Kind.CHEST, cell_to_world(c))
	# Decoração: caixotes e detalhes da vila
	for d in [Vector2i(43, 27), Vector2i(51, 33), Vector2i(23, 32), Vector2i(30, 34)]:
		var s := Sprite2D.new()
		s.texture = DB.dt2_texture("crate")
		s.position = cell_to_world(d)
		decals.add_child(s)


func _intro() -> void:
	Game.play_music("res://assets/audio/music_menu.ogg")
	hud.show_message("Reminiscência", UIKit.GOLD, 3.0)
	hud.show_message("Um sonho que já foi casa.", UIKit.TEXT_DIM, 4.0)


func _apply_brightness() -> void:
	## Tom quente e levemente irreal — é uma memória, não um lugar.
	var b: float = Game.settings.brightness
	var c := Color(0.52, 0.48, 0.46)
	canvas_modulate.color = Color(c.r * b, c.g * b, c.b * b, 1.0)


func _start_position() -> Vector2:
	return cell_to_world(START_CELL)


func respawn_position() -> Vector2:
	return cell_to_world(START_CELL)


func level() -> int:
	return 1


func region_name() -> String:
	return "Reminiscência de Vale Cinzento"
