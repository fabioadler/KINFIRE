class_name Hero
extends RefCounted
## Ficha do personagem (dados puros, sem física). O nó Player apenas lê daqui.

signal stats_changed
signal leveled_up(new_level: int)
signal gold_changed(amount: int)
signal xp_changed

const MAX_LEVEL := 30
const SKILL_SLOTS := 6
const BASE_MOVE_SPEED := 72.0

var hero_name: String = "Herói"
var race: RaceData
var cls: ClassData
var sex: String = "m"
var tint: Color = Color.WHITE
var background: String = "soldado"
var difficulty: int = 0
var hardcore := false
var base_abilities := {"str": 10, "dex": 10, "con": 10, "int": 10, "wis": 10, "cha": 10}
## +1 escolhidos na criação (Meio-Elfo)
var free_bonus := {}
var level: int = 1
var xp: int = 0
var gold: int = 0
var unspent_points: int = 0
var inventory: InventoryGrid
var equipment := {}
## Ids das habilidades em cada slot: [LMB, RMB, 1, 2, 3, 4]
var skill_bar: Array = [&"", &"", &"", &"", &"", &""]
var kills: int = 0
var deepest: int = 1
var play_time: float = 0.0
## Modificadores temporários (buffs): {"damage": 0.3, ...}
var temp := {}


func _init() -> void:
	for s in DB.EQUIP_SLOTS:
		equipment[s] = null


static func create(p_name: String, p_race: RaceData, p_cls: ClassData, p_sex: String, p_tint: Color, abilities: Dictionary,
		p_free_bonus: Dictionary = {}, p_background: String = "soldado", p_difficulty: int = 0, p_hardcore := false) -> Hero:
	var h := Hero.new()
	h.hero_name = p_name
	h.race = p_race
	h.cls = p_cls
	h.sex = p_sex
	h.tint = p_tint
	h.base_abilities = abilities.duplicate()
	h.free_bonus = p_free_bonus.duplicate()
	h.background = p_background
	h.difficulty = p_difficulty
	h.hardcore = p_hardcore
	h._make_inventory()
	h.equipment.weapon = DB.create_item(p_cls.starting_weapon, 1, Item.Rarity.COMMON)
	if p_cls.starting_offhand != &"":
		h.equipment.offhand = DB.create_item(p_cls.starting_offhand, 1, Item.Rarity.COMMON)
	h.equipment.chest = DB.create_item(&"leather" if p_cls.base_armor < 12 else &"plate", 1, Item.Rarity.COMMON)
	h.inventory.add(DB.create_item(&"wood_sword", 1, Item.Rarity.COMMON))
	if p_background == "nobre":
		h.gold = 100
	h.refresh_skill_bar()
	return h


func _make_inventory() -> void:
	inventory = InventoryGrid.new(10 + race.extra_inventory_cols, 6)


## Nome-base do sprite animado
func sprite_base() -> String:
	return race.sprite_f if sex == "f" else race.sprite_m


func background_data() -> Dictionary:
	return DB.BACKGROUNDS.get(background, DB.BACKGROUNDS.soldado)


func bg_stat(key: String) -> float:
	return float(background_data().stats.get(key, 0.0))


func difficulty_data() -> Dictionary:
	return DB.DIFFICULTIES[clampi(difficulty, 0, DB.DIFFICULTIES.size() - 1)]


# ------------------------------------------------------------ ATRIBUTOS

func item_stat(key: String) -> float:
	var total := 0.0
	for s in DB.EQUIP_SLOTS:
		var it: Item = equipment[s]
		if it:
			total += it.stat(key)
	return total


func ability(a: String) -> int:
	return int(base_abilities.get(a, 10)) + int(race.ability_bonus.get(a, 0)) + int(free_bonus.get(a, 0)) + int(item_stat(a))


func mod(a: String) -> int:
	return DB.ability_mod(ability(a))


func max_hp() -> float:
	var con := ability("con")
	var per_level := cls.hit_die + maxi(mod("con"), 0) * 2
	return cls.base_hp + race.bonus_hp + con * 3 + (level - 1) * per_level + item_stat("life") + bg_stat("life")


func max_resource() -> float:
	var bonus := 0.0
	if cls.primary_ability in ["int", "wis", "cha"]:
		bonus = maxf(mod(cls.primary_ability), 0) * 5.0
	return (cls.resource_max + bonus) * race.resource_max_mult


func resource_regen() -> float:
	var r := cls.resource_regen
	if r > 0:
		r = (r + maxf(mod("wis"), 0) * 0.5 + item_stat("resource_regen") + bg_stat("resource_regen")) * race.resource_regen_mult
	return r


func armor() -> float:
	var a: float = float(cls.base_armor) + maxf(mod("dex"), 0) * 2.0 + item_stat("armor") + bg_stat("armor") + float(temp.get("armor", 0.0))
	for s in DB.EQUIP_SLOTS:
		var it: Item = equipment[s]
		if it:
			a += it.armor
	return a * race.armor_mult


func physical_reduction() -> float:
	var a := armor()
	var dr := a / (a + 60.0 + level * 8.0)
	return clampf(1.0 - (1.0 - dr) * (1.0 - race.physical_resist), 0.0, 0.85)


## Resistência total contra um elemento (0..1)
func resist(element: String) -> float:
	match element:
		"physical":
			return physical_reduction()
		"fire":
			if race.fire_resist >= 1.0:
				return 1.0
			return clampf(race.fire_resist + item_stat("fire_resist") + race.magic_resist + item_stat("magic_resist"), 0.0, 0.75)
		"ice":
			return clampf(race.ice_resist + item_stat("ice_resist") + race.magic_resist + item_stat("magic_resist"), 0.0, 0.75)
		"poison":
			return clampf(race.poison_resist + item_stat("poison_resist") + race.magic_resist * 0.5, 0.0, 0.75)
	return clampf(race.magic_resist + item_stat("magic_resist"), 0.0, 0.75)


func weapon_damage() -> Vector2:
	var w: Item = equipment.weapon
	if w == null:
		return Vector2(1, 3)
	return Vector2(w.min_damage, w.max_damage)


func damage_multiplier() -> float:
	var primary := ability(cls.primary_ability)
	return (1.0 + (primary - 10) * 0.05) * (1.0 + item_stat("damage_pct") + float(temp.get("damage", 0.0)))


func attack_speed() -> float:
	var w: Item = equipment.weapon
	var base := w.attack_speed if w else 1.0
	var bonus := item_stat("attack_speed") + float(temp.get("attack_speed", 0.0))
	if w and w.two_handed:
		bonus += race.two_hand_speed
	return base * (1.0 + bonus)


func crit_chance() -> float:
	return clampf(0.05 + maxf(mod("dex"), 0) * 0.01 + race.crit_chance_bonus + item_stat("crit_chance") + bg_stat("crit_chance") + float(temp.get("crit", 0.0)), 0.0, 0.75)


func crit_damage() -> float:
	return 0.5 + item_stat("crit_damage")


func move_speed() -> float:
	return BASE_MOVE_SPEED * race.move_speed_mult * (1.0 + item_stat("move_speed") + bg_stat("move_speed") + float(temp.get("speed", 0.0)))


func gold_find() -> float:
	return race.gold_find + item_stat("gold_find") + maxf(mod("cha"), 0) * 0.03 + bg_stat("gold_find")


func xp_multiplier() -> float:
	return (1.0 + race.xp_bonus + bg_stat("xp_bonus")) * difficulty_data().xp


func cooldown_mult() -> float:
	return 1.0 - clampf(item_stat("cdr") + race.cooldown_reduction, 0.0, 0.5)


func life_on_hit() -> float:
	return item_stat("life_on_hit")


func lifesteal() -> float:
	return cls.lifesteal + item_stat("lifesteal") + float(temp.get("lifesteal", 0.0))


func block_chance() -> float:
	var off: Item = equipment.offhand
	if off == null or off.category != "shield":
		return 0.0
	return clampf(cls.block_chance + off.block, 0.0, 0.5)


func sell_multiplier() -> float:
	return 1.0 + bg_stat("sell_bonus")


func dps_estimate() -> float:
	var w := weapon_damage()
	var avg := (w.x + w.y) * 0.5 * damage_multiplier()
	return avg * attack_speed() * (1.0 + crit_chance() * crit_damage())


## Retorna [dano, foi_critico]
func roll_damage(mult: float) -> Array:
	var w := weapon_damage()
	var dmg := randf_range(w.x, w.y) * mult * damage_multiplier()
	var crit := randf() < crit_chance()
	if crit:
		dmg *= 1.0 + crit_damage()
		if randf() < race.double_crit_chance:
			dmg *= 2.0
	return [maxf(dmg, 1.0), crit]


# ------------------------------------------------------------ PROGRESSÃO

func xp_to_next() -> int:
	return int(80 * pow(level, 1.6))


func add_xp(amount: int) -> void:
	if level >= MAX_LEVEL:
		return
	xp += int(amount * xp_multiplier())
	while xp >= xp_to_next() and level < MAX_LEVEL:
		xp -= xp_to_next()
		level += 1
		unspent_points += 2 if level % 4 == 0 else 1
		refresh_skill_bar()
		leveled_up.emit(level)
	xp_changed.emit()
	stats_changed.emit()


func add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)


func spend_point(a: String) -> void:
	if unspent_points <= 0:
		return
	unspent_points -= 1
	base_abilities[a] = int(base_abilities[a]) + 1
	stats_changed.emit()


func unlocked_skills() -> Array[SkillData]:
	var out: Array[SkillData] = []
	for s in cls.skills:
		if s.unlock_level <= level:
			out.append(s)
	return out


## Coloca habilidades recém-desbloqueadas em slots vazios
func refresh_skill_bar() -> void:
	for s in unlocked_skills():
		if skill_bar.has(s.id):
			continue
		for i in SKILL_SLOTS:
			if skill_bar[i] == &"":
				skill_bar[i] = s.id
				break


func skill_in_slot(i: int) -> SkillData:
	if i < 0 or i >= skill_bar.size() or skill_bar[i] == &"":
		return null
	return DB.get_skill(cls, skill_bar[i])


func racial_skill() -> SkillData:
	return DB.racial_breath if race.breath_element != "" else null


func assign_skill(slot: int, id: StringName) -> void:
	var prev := skill_bar.find(id)
	if prev >= 0:
		skill_bar[prev] = skill_bar[slot]
	skill_bar[slot] = id
	stats_changed.emit()


# ------------------------------------------------------------ EQUIPAMENTO

func can_use_category(it: Item) -> bool:
	if it.slot == "weapon":
		return it.category in cls.allowed_weapons
	if it.slot == "offhand":
		return it.category in cls.allowed_offhands
	return true


## "" se pode equipar, senão o motivo
func equip_problem(it: Item) -> String:
	if level + race.item_level_leeway < it.required_level():
		return "Nível insuficiente (requer %d)" % it.required_level()
	if not can_use_category(it):
		return "%s não sabe usar %s" % [cls.display_name, DB.CATEGORY_NAMES.get(it.category, "isso")]
	if it.slot == "offhand":
		var w: Item = equipment.weapon
		if w and w.two_handed and not (w.category == "bow" and it.category == "quiver"):
			return "Sua arma é de duas mãos"
	return ""


## Equipa um item; retorna os itens que saíram (0, 1 ou 2)
func equip(it: Item) -> Array[Item]:
	var out: Array[Item] = []
	var old: Item = equipment[it.slot]
	if old:
		out.append(old)
	equipment[it.slot] = it
	# Arma de duas mãos libera a mão secundária (exceto arco + aljava)
	if it.slot == "weapon" and it.two_handed and equipment.offhand:
		var off: Item = equipment.offhand
		if not (it.category == "bow" and off.category == "quiver"):
			out.append(off)
			equipment.offhand = null
	stats_changed.emit()
	return out


func unequip(slot: String) -> Item:
	var old: Item = equipment[slot]
	equipment[slot] = null
	stats_changed.emit()
	return old


# ------------------------------------------------------------ SAVE

func to_dict() -> Dictionary:
	var eq := {}
	for s in DB.EQUIP_SLOTS:
		eq[s] = equipment[s].to_dict() if equipment[s] else null
	var bar := []
	for id in skill_bar:
		bar.append(String(id))
	return {
		"name": hero_name, "race": String(race.id), "class": String(cls.id), "sex": sex, "tint": tint.to_html(),
		"background": background, "difficulty": difficulty, "hardcore": hardcore, "free_bonus": free_bonus,
		"abilities": base_abilities, "level": level, "xp": xp, "gold": gold, "points": unspent_points,
		"inventory": inventory.to_array(), "equipment": eq, "skill_bar": bar, "kills": kills,
		"deepest": deepest, "play_time": play_time,
	}


static func from_dict(d: Dictionary) -> Hero:
	var h := Hero.new()
	h.hero_name = d.get("name", "Herói")
	h.race = DB.get_race(StringName(d.get("race", "humano")))
	h.cls = DB.get_class_data(StringName(d.get("class", "guerreiro")))
	h.sex = d.get("sex", "m")
	h.tint = Color.html(d.get("tint", "ffffffff"))
	h.background = d.get("background", "soldado")
	h.difficulty = int(d.get("difficulty", 0))
	h.hardcore = d.get("hardcore", false)
	h.free_bonus = d.get("free_bonus", {})
	var ab: Dictionary = d.get("abilities", {})
	for a in DB.ABILITIES:
		h.base_abilities[a] = int(ab.get(a, 10))
	h.level = int(d.get("level", 1))
	h.xp = int(d.get("xp", 0))
	h.gold = int(d.get("gold", 0))
	h.unspent_points = int(d.get("points", 0))
	h.kills = int(d.get("kills", 0))
	h.deepest = int(d.get("deepest", 1))
	h.play_time = float(d.get("play_time", 0.0))
	h._make_inventory()
	h.inventory.load_array(d.get("inventory", []))
	var eq: Dictionary = d.get("equipment", {})
	for s in DB.EQUIP_SLOTS:
		if eq.get(s) is Dictionary:
			h.equipment[s] = Item.from_dict(eq[s])
	var bar: Array = d.get("skill_bar", [])
	for i in mini(bar.size(), SKILL_SLOTS):
		h.skill_bar[i] = StringName(bar[i])
	h.refresh_skill_bar()
	return h
