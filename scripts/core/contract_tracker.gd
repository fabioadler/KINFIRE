extends RefCounted
class_name ContractTracker

var hero: Hero
var contract: ContractData
var start_time: float
var progress: Dictionary

func _init(p_hero: Hero, p_contract_id: StringName) -> void:
	hero = p_hero
	contract = ContractData.new()
	contract.id = p_contract_id
	start_time = Time.get_ticks_msec() / 1000.0
	progress = {}

func is_expired() -> bool:
	var elapsed = (Time.get_ticks_msec() / 1000.0) - start_time
	return elapsed > contract.tempo_limite_horas * 3600.0

func complete() -> void:
	hero.contracts_active.erase(contract.id)
	hero.contracts_completed += 1
	if "ouro" in contract.recompensas:
		hero.gold += int(contract.recompensas["ouro"])
	if "xp" in contract.recompensas:
		hero.add_xp(int(contract.recompensas["xp"]))
