class_name Minimap
extends Control
## Minimapa centrado no jogador (funciona no mundo aberto e na masmorra).
## Pergunta ao World a cor de cada célula explorada ao redor.

const SCALE := 3.0
const RADIUS := 32      ## células desenhadas em cada direção
var world: World
var _img: Image
var _tex: ImageTexture
var _t := 0.0
var _center := Vector2i.ZERO


func _init(p_world: World) -> void:
	world = p_world
	custom_minimum_size = Vector2(190, 190)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true


func _process(delta: float) -> void:
	_t -= delta
	if _t <= 0.0:
		_t = 0.3
		_rebuild()
	queue_redraw()


func _rebuild() -> void:
	if world.player == null:
		return
	var size_px := RADIUS * 2
	if _img == null:
		_img = Image.create(size_px, size_px, false, Image.FORMAT_RGBA8)
	_center = world.world_to_cell(world.player.global_position)
	for y in size_px:
		for x in size_px:
			_img.set_pixel(x, y, world.minimap_color(_center + Vector2i(x - RADIUS, y - RADIUS)))
	if _tex == null:
		_tex = ImageTexture.create_from_image(_img)
	else:
		_tex.update(_img)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.55))
	if _tex == null or world.player == null:
		return
	# Posição exata do jogador dentro da célula central (rolagem suave)
	var pc := world.player.global_position / World.TILE
	var origin := size * 0.5 - (pc - Vector2(_center - Vector2i(RADIUS, RADIUS))) * SCALE
	draw_set_transform(origin, 0, Vector2(SCALE, SCALE))
	draw_texture(_tex, Vector2.ZERO)
	draw_set_transform(Vector2.ZERO)
	var to_map := func(p: Vector2) -> Vector2: return size * 0.5 + (p / World.TILE - pc) * SCALE
	for poi in world.points_of_interest():
		var mp: Vector2 = to_map.call(poi.pos)
		mp = mp.clamp(Vector2(4, 4), size - Vector2(4, 4))
		draw_circle(mp, 3.5, Color.BLACK)
		draw_circle(mp, 2.6, poi.color)
	for e in world.enemies_near(world.player.global_position, 160.0):
		var col := Color(1, 0.2, 0.2)
		if e.elite:
			col = Color(0.4, 0.6, 1.0)
		if e.is_boss():
			col = Color(1, 0.55, 0.1)
		draw_circle(to_map.call(e.global_position), 2.4 if (e.elite or e.is_boss()) else 1.6, col)
	for m in world.minions_near(world.player.global_position, 160.0):
		draw_circle(to_map.call(m.global_position), 1.6, Color(0.4, 1, 0.6))
	draw_circle(size * 0.5, 3.0, Color(0.3, 1.0, 0.3))
	draw_rect(Rect2(Vector2.ZERO, size), UIKit.GOLD_DIM, false, 2.0)
