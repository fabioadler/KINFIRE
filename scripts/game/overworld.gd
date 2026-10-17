class_name Overworld
extends World
## Mundo aberto procedural e infinito, gerado em chunks (estilo Minecraft).
## Os chunks são criados ao redor do jogador e descartados quando ficam longe.
## Quanto mais longe do acampamento inicial, mais perigosa a região.

const CHUNK := OverworldGen.CHUNK
const LOAD_RADIUS := 1        ## chunks carregados ao redor do jogador (3x3)
const UNLOAD_RADIUS := 2
const DAY_LENGTH := 360.0     ## segundos por dia completo
const SHEET := preload("res://assets/sprites/overworld/roguelike_sheet.png")
const DUNGEON_NAMES := ["Cripta Esquecida", "Catacumbas de Varn", "Mina Abandonada", "Covil das Sombras", "Santuário Profanado",
	"Ruínas de Ashkar", "Caverna dos Ecos", "Masmorra de Kinfire", "Tumba do Rei Cinzento", "Fosso das Almas", "Gruta Rubra", "Cofre dos Anões"]

@onready var props: TileMapLayer = $Entities/Props

var og: OverworldGen
var chunks := {}              ## Vector2i -> {"solid": PackedByteArray, "biome": PackedByteArray, "nodes": Array}
var explored_cells := {}      ## Vector2i (chunk) -> PackedByteArray
var _queue: Array[Vector2i] = []
var _astar_dirty := true
var _astar_timer := 0.0
var _player_chunk := Vector2i(999999, 999999)
var _tiles := {}              ## "x,y,mod" -> [coords, alt]
var _src: TileSetAtlasSource
var _ground_src: TileSetAtlasSource
var _time := 0.3


func _setup_map() -> void:
	og = OverworldGen.new(Game.world_seed)
	_time = Game.world_time
	_build_tileset()
	var start := world_to_cell(_start_position())
	var sc := _chunk_of(start)
	for dy in range(-LOAD_RADIUS, LOAD_RADIUS + 1):
		for dx in range(-LOAD_RADIUS, LOAD_RADIUS + 1):
			_generate_chunk(sc + Vector2i(dx, dy))
	_player_chunk = sc
	_rebuild_astar()


func _start_position() -> Vector2:
	if Game.overworld_pos != Vector2.INF:
		return Game.overworld_pos
	return Vector2(TILE * 0.5, TILE * 2.5)


func respawn_position() -> Vector2:
	return Game.respawn_pos if Game.respawn_pos != Vector2.INF else Vector2(TILE * 0.5, TILE * 2.5)


func _intro() -> void:
	Game.play_music("res://assets/audio/music_dungeon.ogg")
	var diff: Dictionary = Game.hero.difficulty_data()
	hud.show_message("Mundo de Kinfire", UIKit.GOLD, 3.0)
	hud.show_message("Dificuldade: %s%s" % [diff.name, "  •  HARDCORE" if Game.hero.hardcore else ""], diff.color, 3.0)
	if Game.overworld_pos == Vector2.INF:
		hud.show_message("Explore o mundo. Quanto mais longe do acampamento, mais perigoso.", Color(0.8, 0.8, 0.8), 5.0)


func _spawn_content() -> void:
	# Acampamento inicial (área segura): fogueira, mercador e tendas
	var fire := Interactable.create(self, Interactable.Kind.CAMPFIRE, Vector2(TILE * 0.5, TILE * 0.5))
	fire.label = "Acampamento"
	_register_waypoint("Acampamento", fire.global_position)
	if Game.respawn_pos == Vector2.INF:
		Game.respawn_pos = fire.global_position + Vector2(0, 24)
	Interactable.create(self, Interactable.Kind.MERCHANT, Vector2(TILE * 4.5, TILE * -1.5))
	for t in [Vector2i(-5, -4), Vector2i(3, -5), Vector2i(-2, 4)]:
		_place_tent(t)


func _place_tent(c: Vector2i) -> void:
	var tent := [[Vector2i(46, 10), Vector2i(47, 10)], [Vector2i(46, 11), Vector2i(47, 11)]]
	for y in 2:
		for x in 2:
			var cc := c + Vector2i(x, y)
			props.set_cell(cc, 0, tent[y][x], _alt(tent[y][x], Color.WHITE, y == 1, y == 0))
			if y == 1:
				_set_solid(cc, true)


# ------------------------------------------------------------------ CONSULTAS DO MUNDO

func level() -> int:
	return level_at(player.global_position) if player else 1


## Nível da região: cresce com a distância do acampamento
func level_at(p: Vector2) -> int:
	var d := OverworldGen.danger(world_to_cell(p))
	return clampi(1 + int(d * 0.9), 1, 60)


func biome_at_pos(p: Vector2) -> String:
	return og.biome_at(world_to_cell(p))


func region_name() -> String:
	var b: String = biome_at_pos(player.global_position) if player else "planicie"
	if Vector2(world_to_cell(player.global_position)).length() < OverworldGen.SAFE_RADIUS:
		return "Acampamento (área segura)"
	return "%s — Nível %d" % [OverworldGen.BIOMES[b].name, level()]


func time_label() -> String:
	var hours := fmod(_time, 1.0) * 24.0
	return "Dia %d — %02d:%02d" % [int(_time) + 1, int(hours), int(fmod(hours, 1.0) * 60)]


func is_floor(c: Vector2i) -> bool:
	var ch: Variant = chunks.get(_chunk_of(c))
	if ch == null:
		return false
	return ch.solid[_local_index(c)] == 0


func is_explored(c: Vector2i) -> bool:
	var e: Variant = explored_cells.get(_chunk_of(c))
	return e != null and e[_local_index(c)] == 1


func _set_explored(c: Vector2i) -> void:
	var k := _chunk_of(c)
	if not explored_cells.has(k):
		var arr := PackedByteArray()
		arr.resize(CHUNK * CHUNK)
		explored_cells[k] = arr
	explored_cells[k][_local_index(c)] = 1


func minimap_color(c: Vector2i) -> Color:
	if not is_explored(c):
		return Color(0, 0, 0, 0)
	var ch: Variant = chunks.get(_chunk_of(c))
	var b: String
	var wet := false
	if ch != null:
		b = OverworldGen.BIOME_IDS[ch.biome[_local_index(c)]]
		wet = ch.liquid[_local_index(c)] == 1
	else:
		b = og.biome_at(c)
		wet = og.liquid_at(c, b)
	if wet:
		return Color(0.95, 0.4, 0.1) if b == "vulcanico" else Color(0.25, 0.5, 0.85)
	var col: Color = OverworldGen.BIOMES[b].map
	if ch != null and ch.solid[_local_index(c)] == 1:
		col = col.darkened(0.35)
	return col


func points_of_interest() -> Array:
	var out := []
	for n in get_tree().get_nodes_in_group("interactables"):
		if n is Interactable and is_explored(world_to_cell(n.global_position)):
			match n.kind:
				Interactable.Kind.DUNGEON_ENTRANCE: out.append({"pos": n.global_position, "color": Color(0.75, 0.4, 1.0)})
				Interactable.Kind.CAMPFIRE: out.append({"pos": n.global_position, "color": Color(1, 0.6, 0.2)})
				Interactable.Kind.MERCHANT: out.append({"pos": n.global_position, "color": Color(1, 0.9, 0.4)})
	return out


func _apply_brightness() -> void:
	_update_daylight()


func _update_daylight() -> void:
	var b: float = Game.settings.brightness
	var h := fmod(_time, 1.0)
	# 0.0 = meia-noite, 0.5 = meio-dia
	var day := clampf(0.5 - 0.5 * cos(h * TAU), 0.0, 1.0)
	var night := Color(0.22, 0.24, 0.42)
	var noon := Color(0.8, 0.78, 0.74)
	var dusk := Color(0.95, 0.6, 0.45)
	var c := night.lerp(noon, smoothstep(0.15, 0.6, day))
	if day > 0.15 and day < 0.45:
		c = c.lerp(dusk, 0.35 * (1.0 - absf(day - 0.3) / 0.15))
	canvas_modulate.color = Color(c.r * b, c.g * b, c.b * b, 1.0)
	if player:
		player.light.energy = lerpf(1.6, 0.12, day)


# ------------------------------------------------------------------ LOOP / STREAMING

func _process(delta: float) -> void:
	super._process(delta)
	_time += delta / DAY_LENGTH
	Game.world_time = _time
	_update_daylight()
	if player == null:
		return
	var pc := _chunk_of(world_to_cell(player.global_position))
	if pc != _player_chunk:
		_player_chunk = pc
		for dy in range(-LOAD_RADIUS, LOAD_RADIUS + 1):
			for dx in range(-LOAD_RADIUS, LOAD_RADIUS + 1):
				var k := pc + Vector2i(dx, dy)
				if not chunks.has(k) and not _queue.has(k):
					_queue.append(k)
		for k in chunks.keys():
			if maxi(absi(k.x - pc.x), absi(k.y - pc.y)) > UNLOAD_RADIUS:
				_unload_chunk(k)
	# Gera no máximo um chunk por frame (evita travadas)
	if not _queue.is_empty():
		_generate_chunk(_queue.pop_front())
	_astar_timer -= delta
	if _astar_dirty and _astar_timer <= 0.0 and _queue.is_empty():
		_rebuild_astar()


func _chunk_of(c: Vector2i) -> Vector2i:
	return Vector2i(floori(c.x / float(CHUNK)), floori(c.y / float(CHUNK)))


func _local_index(c: Vector2i) -> int:
	var lx := posmod(c.x, CHUNK)
	var ly := posmod(c.y, CHUNK)
	return ly * CHUNK + lx


func _set_solid(c: Vector2i, v: bool) -> void:
	var ch: Variant = chunks.get(_chunk_of(c))
	if ch != null:
		ch.solid[_local_index(c)] = 1 if v else 0
		_astar_dirty = true


# ------------------------------------------------------------------ TILESET

func _build_tileset() -> void:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 1)
	ts.set_physics_layer_collision_mask(0, 0)
	_src = TileSetAtlasSource.new()
	_src.texture = SHEET
	_src.texture_region_size = Vector2i(TILE, TILE)
	_src.separation = Vector2i(1, 1)
	ts.add_source(_src, 0)
	floor_layer.tile_set = ts
	wall_layer.tile_set = ts
	props.tile_set = ts


## Retorna o id da tile alternativa para (coords, tonalidade, sólida, topo de árvore)
func _alt(coords: Vector2i, mod: Color, solid: bool, is_top := false) -> int:
	var key := "%d,%d,%s,%s,%s" % [coords.x, coords.y, mod.to_html(), solid, is_top]
	if _tiles.has(key):
		return _tiles[key]
	if not _src.has_tile(coords):
		_src.create_tile(coords)
	var alt := _src.create_alternative_tile(coords)
	var td := _src.get_tile_data(coords, alt)
	td.modulate = mod
	if solid:
		td.add_collision_polygon(0)
		var r := 6.0 if not is_top else 8.0
		td.set_collision_polygon_points(0, 0, PackedVector2Array([Vector2(-r, -r), Vector2(r, -r), Vector2(r, r), Vector2(-r, r)]))
	if is_top:
		# A copa da árvore ordena junto com o tronco (célula de baixo)
		td.y_sort_origin = TILE
	_tiles[key] = alt
	return alt


# ------------------------------------------------------------------ GERAÇÃO DE CHUNK

func _generate_chunk(k: Vector2i) -> void:
	if chunks.has(k):
		return
	var solid := PackedByteArray()
	solid.resize(CHUNK * CHUNK)
	var biomes := PackedByteArray()
	biomes.resize(CHUNK * CHUNK)
	var liquid := PackedByteArray()
	liquid.resize(CHUNK * CHUNK)
	var data := {"solid": solid, "biome": biomes, "liquid": liquid, "nodes": []}
	chunks[k] = data
	var origin := k * CHUNK
	for ly in CHUNK:
		for lx in CHUNK:
			var c := origin + Vector2i(lx, ly)
			var i := ly * CHUNK + lx
			var b := og.biome_at(c)
			biomes[i] = OverworldGen.BIOME_IDS.find(b)
			var info: Dictionary = OverworldGen.BIOMES[b]
			if og.liquid_at(c, b):
				solid[i] = 1
				liquid[i] = 1
				_paint_liquid(c, b)
				continue
			# Clareira de terra batida no acampamento
			if Vector2(c).length() < 6.0:
				floor_layer.set_cell(c, 0, Vector2i(6, 0), _alt(Vector2i(6, 0), Color(0.78, 0.68, 0.6), false))
				continue
			var g := og.ground_variant(c, b)
			floor_layer.set_cell(c, 0, g, _alt(g, info.mod, false))
			var p := og.prop_at(c, b)
			if p != "":
				var pd: Dictionary = OverworldGen.PROPS[p]
				props.set_cell(c, 0, pd.base, _alt(pd.base, Color.WHITE, pd.solid))
				if pd.has("top"):
					props.set_cell(c + Vector2i.UP, 0, pd.top, _alt(pd.top, Color.WHITE, false, true))
				if pd.solid:
					solid[i] = 1
	_spawn_chunk_content(k, data)
	_astar_dirty = true
	_astar_timer = 0.3


func _paint_liquid(c: Vector2i, b: String) -> void:
	if b == "vulcanico":
		floor_layer.set_cell(c, 0, Vector2i(11, 14), _alt(Vector2i(11, 14), Color(1.0, 0.7, 0.5), true))
		return
	var mod := Color.WHITE
	match b:
		"pantano": mod = Color(0.55, 0.75, 0.5)
		"tundra": mod = Color(0.8, 0.95, 1.0)
		"corrompido": mod = Color(0.6, 0.45, 0.75)
	# Bordas de grama na margem (3x3 do lago da folha)
	var up := og.liquid_at(c + Vector2i.UP, og.biome_at(c + Vector2i.UP))
	var down := og.liquid_at(c + Vector2i.DOWN, og.biome_at(c + Vector2i.DOWN))
	var left := og.liquid_at(c + Vector2i.LEFT, og.biome_at(c + Vector2i.LEFT))
	var right := og.liquid_at(c + Vector2i.RIGHT, og.biome_at(c + Vector2i.RIGHT))
	var tx := 3
	var ty := 1
	if b in ["planicie", "floresta", "pantano"]:
		tx = 2 if not left else (4 if not right else 3)
		ty = 0 if not up else (2 if not down else 1)
	var coords := Vector2i(tx, ty) if (b in ["planicie", "floresta", "pantano"]) else Vector2i(0, 0)
	floor_layer.set_cell(c, 0, coords, _alt(coords, mod, true))
	# Vitórias-régias no pântano
	if b == "pantano" and og.rand01(c, 11) < 0.05 and up and down and left and right:
		props.set_cell(c, 0, Vector2i(28, 10), _alt(Vector2i(28, 10), Color.WHITE, false))


func _unload_chunk(k: Vector2i) -> void:
	var data: Dictionary = chunks[k]
	var origin := k * CHUNK
	for ly in CHUNK:
		for lx in CHUNK:
			var c := origin + Vector2i(lx, ly)
			floor_layer.erase_cell(c)
			props.erase_cell(c)
	# Copas de árvores da primeira linha ficam na linha do chunk de cima
	for lx in CHUNK:
		var c := origin + Vector2i(lx, 0)
		var p := og.prop_at(c, og.biome_at(c))
		if p != "" and OverworldGen.PROPS[p].has("top"):
			props.erase_cell(c + Vector2i.UP)
	for n in data.nodes:
		if is_instance_valid(n):
			# Não remove inimigos que estão perseguindo o jogador
			if n is Enemy and (n.state != Enemy.State.IDLE and not n.is_dead()):
				continue
			n.queue_free()
	chunks.erase(k)
	_astar_dirty = true


func _rebuild_astar() -> void:
	_astar_dirty = false
	_astar_timer = 0.5
	if chunks.is_empty():
		return
	var mn := Vector2i(999999, 999999)
	var mx := Vector2i(-999999, -999999)
	for k in chunks:
		mn = Vector2i(mini(mn.x, k.x), mini(mn.y, k.y))
		mx = Vector2i(maxi(mx.x, k.x), maxi(mx.y, k.y))
	astar.region = Rect2i(mn * CHUNK, (mx - mn + Vector2i.ONE) * CHUNK)
	astar.cell_size = Vector2(TILE, TILE)
	astar.offset = Vector2(TILE * 0.5, TILE * 0.5)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar.update()
	astar.fill_solid_region(astar.region, true)
	for k in chunks:
		var solid: PackedByteArray = chunks[k].solid
		var origin: Vector2i = k * CHUNK
		for i in CHUNK * CHUNK:
			if solid[i] == 0:
				astar.set_point_solid(origin + Vector2i(i % CHUNK, i / CHUNK), false)


# ------------------------------------------------------------------ CONTEÚDO DO CHUNK

func _spawn_chunk_content(k: Vector2i, data: Dictionary) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(Vector3i(k.x, k.y, Game.world_seed))
	var center_cell := k * CHUNK + Vector2i(CHUNK / 2, CHUNK / 2)
	var lvl := clampi(1 + int(OverworldGen.danger(center_cell) * 0.9), 1, 60)
	var safe := Vector2(center_cell).length() < OverworldGen.SAFE_RADIUS + 20
	var nodes: Array = data.nodes

	# Entrada de masmorra (garantida no chunk (1,0) para o jogador achar logo)
	if k == Vector2i(1, 0) or (not safe and rng.randf() < 0.14):
		var p := _random_floor(k, rng, 3)
		if p != Vector2.INF:
			var e := Interactable.create(self, Interactable.Kind.DUNGEON_ENTRANCE, p)
			e.dungeon_level = lvl
			e.label = DUNGEON_NAMES[rng.randi() % DUNGEON_NAMES.size()]
			nodes.append(e)
	# Fogueira (ponto de viagem rápida)
	if not safe and rng.randf() < 0.1:
		var p := _random_floor(k, rng, 2)
		if p != Vector2.INF:
			var f := Interactable.create(self, Interactable.Kind.CAMPFIRE, p)
			f.label = "Fogueira — %s" % OverworldGen.BIOMES[og.biome_at(world_to_cell(p))].name
			nodes.append(f)
	if safe:
		return
	# Baús e santuários (lembrados no save para não reaparecer)
	if rng.randf() < 0.3:
		var p := _random_floor(k, rng, 1)
		var pid := "chest:%d,%d" % [k.x, k.y]
		if p != Vector2.INF and not Game.world_opened.has(pid):
			var ch := Interactable.create(self, Interactable.Kind.CHEST, p)
			ch.persist_id = pid
			nodes.append(ch)
	if rng.randf() < 0.1:
		var p := _random_floor(k, rng, 2)
		var pid := "shrine:%d,%d" % [k.x, k.y]
		if p != Vector2.INF and not Game.world_opened.has(pid):
			var sh := Interactable.create(self, Interactable.Kind.SHRINE, p)
			sh.persist_id = pid
			nodes.append(sh)

	# Monstros por bioma
	var density: float = Game.settings.monster_density
	var packs := int(round(rng.randi_range(1, 3) * density))
	for i in packs:
		var p := _random_floor(k, rng, 3)
		if p == Vector2.INF:
			continue
		var biome := og.biome_at(world_to_cell(p))
		var pool := _pool_for(biome, lvl)
		if pool.is_empty():
			continue
		var data_e := _weighted_pick(pool)
		var count := rng.randi_range(2, 4) if data_e.behavior != EnemyData.Behavior.SWARM else rng.randi_range(4, 7)
		var elite_pack := rng.randf() < 0.08 + lvl * 0.01
		for j in count:
			var off := Vector2(rng.randf_range(-24, 24), rng.randf_range(-24, 24))
			var pos := last_free_point(p, p + off)
			var en := spawn_enemy(data_e, pos, elite_pack and j == 0, lvl)
			nodes.append(en)
	# Chefe de mundo (raro, regiões distantes)
	if lvl >= 4 and rng.randf() < 0.025:
		var p := _random_floor(k, rng, 6)
		var biome := og.biome_at(world_to_cell(p)) if p != Vector2.INF else ""
		for e in DB.enemies:
			if e.world_boss and biome in e.habitats and p != Vector2.INF:
				var bb := spawn_enemy(e, p, false, lvl + 2)
				nodes.append(bb)
				break


func _pool_for(biome: String, lvl: int) -> Array[EnemyData]:
	var out: Array[EnemyData] = []
	for e in DB.enemies:
		if e.spawn_weight > 0 and biome in e.habitats and e.min_depth <= lvl + 1:
			out.append(e)
	return out


## Ponto de chão aleatório dentro do chunk (longe das bordas)
func _random_floor(k: Vector2i, rng: RandomNumberGenerator, margin: int) -> Vector2:
	for i in 24:
		var c := k * CHUNK + Vector2i(rng.randi_range(margin, CHUNK - 1 - margin), rng.randi_range(margin, CHUNK - 1 - margin))
		if is_floor(c) and is_floor(c + Vector2i.UP) and is_floor(c + Vector2i.LEFT) and is_floor(c + Vector2i.RIGHT):
			return cell_to_world(c)
	return Vector2.INF


func _register_waypoint(wp_name: String, pos: Vector2) -> void:
	for w in Game.waypoints:
		if Vector2(w.x, w.y).distance_to(pos) < 4.0:
			return
	Game.waypoints.append({"name": wp_name, "x": pos.x, "y": pos.y})


## Acende uma fogueira: vira ponto de renascimento e de viagem rápida
func light_campfire(f: Interactable) -> void:
	_register_waypoint(f.label, f.global_position)
	Game.respawn_pos = f.global_position + Vector2(0, 20)
	player.heal(player.max_hp)
	Game.save_game()


func travel_to(pos: Vector2) -> void:
	Game.overworld_pos = pos + Vector2(0, 20)
	Game.save_game()
	Game.change_scene(Game.OVERWORLD)
