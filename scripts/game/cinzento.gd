class_name Cinzento
extends Node2D
## O Silhueta — Ithariel, o Cinzento (LORE §8).
## Último Guardião da Kinfire: sombra consciente que guia o Laço-Vivo.
## Nunca diz "eu"; indica, não explica. Sua voz não tem eco — o Véu come o som.

const VOICE := Color(0.68, 0.64, 0.82)  ## pálido, cor de névoa à luz de brasa

var _sprite: AnimatedSprite2D
var _light: PointLight2D
var _t := 0.0


func _ready() -> void:
	z_index = 5
	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = DB.frames("k:121")
	_sprite.play("idle")
	_sprite.position = Vector2(0, -8)
	add_child(_sprite)
	_light = Fx.make_light(Color(0.5, 0.48, 0.68), 0.9, 1.0)
	_light.position = Vector2(0, -8)
	add_child(_light)


func _process(delta: float) -> void:
	_t += delta
	# Flutua; tremula como chama exposta ao vento
	_sprite.position.y = -8.0 + sin(_t * 2.1) * 2.5
	_sprite.modulate.a = 0.7 + sin(_t * 3.1) * 0.12 + sin(_t * 9.7) * 0.05
	_light.energy = 0.75 + sin(_t * 5.3) * 0.15 + sin(_t * 13.7) * 0.08


## Aparece suavemente em uma posição (o Véu não deixa ele "estar" — só chegar)
func appear_at(pos: Vector2) -> void:
	global_position = pos
	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
