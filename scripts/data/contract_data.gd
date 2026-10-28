extends Resource
class_name ContractData

enum Status { DISPONIVEL, ACEITO, COMPLETO, FALHADO }
enum Tipo { COMBATE, COLETA, ESCOLTA, INVESTIGACAO }

@export var id: StringName
@export var titulo: String
@export var descricao: String
@export var tipo_contrato: Tipo
@export var guilda_id: StringName
@export var nivel_recomendado: int
@export var reputacao_recompensa: int
@export var ouro_recompensa: int
@export var experiencia_recompensa: int
@export var requisitos: Dictionary = {}
@export var objetivos: Array[String] = []
@export var duracao_dias: int = 7
@export var localizacao: String = ""

func _init() -> void:
	resource_name = "ContractData"
