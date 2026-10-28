extends Resource
class_name GuildData

enum Type { AVENTUREIROS, MERCADORES, ARTESAOS, SOMBRAS }

@export var id: StringName
@export var display_name: String
@export var tipo: Type
@export var mestre_npc: StringName
@export var descricao: String
@export var requisito_nivel: int = 1
@export var requisito_ouro: int = 0
@export var requisito_reputacao: int = -1
@export var beneficios: Dictionary = {}
@export var ranks: Array[RankData] = []

func _init() -> void:
	resource_name = "GuildData"
