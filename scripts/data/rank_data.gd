extends Resource
class_name RankData

@export var id: StringName
@export var display_name: String
@export var nivel_rank: int
@export var reputacao_necessaria: int
@export var beneficios: Dictionary = {}
@export var titulo: String = ""
@export var descricao: String = ""

func _init() -> void:
	resource_name = "RankData"
