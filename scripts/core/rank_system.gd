extends Object
class_name RankSystem

const RANK_REQUIREMENTS = {
	"E": {"contratos": 3},
	"D": {"contratos": 10, "chefes": 1},
	"C": {"contratos": 25, "chefes": 3, "niveis": 30, "misterios": 1},
	"B": {"contratos": 50, "chefes": 6, "niveis": 50, "misterios": 2, "reputacao": 2},
	"A": {"contratos": 100, "chefes": 10, "niveis": 75, "misterios": 4, "fragmentos": 1},
	"S": {"contratos": 200, "chefes": 20, "niveis": 100, "misterios": 8, "fragmentos": 3},
}

static func get_rank(hero: Hero) -> String:
	return hero.rank_f_s if hero.rank_f_s else "F"

static func check_advancement(hero: Hero) -> bool:
	var current_rank = get_rank(hero)
	var rank_order = ["F", "E", "D", "C", "B", "A", "S"]
	var current_idx = rank_order.find(current_rank)
	
	if current_idx >= rank_order.size() - 1:
		return false
	
	var next_rank = rank_order[current_idx + 1]
	var reqs = RANK_REQUIREMENTS.get(next_rank, {})
	
	if reqs.get("contratos", 0) > hero.contracts_completed:
		return false
	
	hero.rank_f_s = next_rank
	return true

static func get_benefits(rank: String) -> Dictionary:
	var benefits = {}
	match rank:
		"F": pass
		"E": benefits["desconto_vendor"] = 0.05
		"D": benefits["desconto_vendor"] = 0.10; benefits["bonus_slots"] = 1
		"C": benefits["desconto_vendor"] = 0.15; benefits["bonus_slots"] = 2
		"B": benefits["desconto_vendor"] = 0.20; benefits["acesso_merchants"] = true
		"A": benefits["desconto_vendor"] = 0.30; benefits["titulo"] = "Campeão"
		"S": benefits["desconto_vendor"] = 0.50; benefits["titulo"] = "Lenda Viva"; benefits["aura"] = true
	return benefits
