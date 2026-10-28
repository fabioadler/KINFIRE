class_name LoreInitializer
extends Node

var lore_manager: LoreSystemManager
var brasa_zone_manager: BrasaZoneManager
var guardian_spawner: GuardianSpawner

func _ready() -> void:
	# Initialize all lore systems
	lore_manager = LoreSystemManager.new()
	brasa_zone_manager = BrasaZoneManager.new()
	guardian_spawner = GuardianSpawner.new()
	
	add_child(lore_manager)
	add_child(brasa_zone_manager)
	add_child(guardian_spawner)
	
	brasa_zone_manager.set_lore_manager(lore_manager)
	
	# Connect quest log to Bonds system
	if Game.quest_log:
		Game.quest_log.quest_completed.connect(_on_quest_completed)
	
	print("✅ Lore system initialized: Brasa, Bonds, Guardiões ready")

func _on_quest_completed(quest_id: StringName) -> void:
	# Route quest to Guardian spawn
	var quest_to_guardian = {
		&"misterio_1": &"mira_pe_leve",
		&"misterio_2": &"ashara_sussurra_magia",
		&"misterio_3": &"lorelyn_espelho_agua",
		&"misterio_4": &"theron_pedra_ressoante",
		&"misterio_5": &"kael_abismo",
		&"misterio_6": &"khalid_areias_douradas",
		&"misterio_7": &"pyros_chama_ardente",
	}
	
	if quest_id in quest_to_guardian:
		var guardian_id = quest_to_guardian[quest_id]
		guardian_spawner.spawn_guardian(guardian_id)
		print("🔥 Guardian spawned: {0}".format([guardian_id]))
	
	# Trigger Ithariel reveal check
	if quest_id == &"misterio_7":
		Game.flags.set("misterio_7_complete")
		print("⛓️ Ithariel reveal unlocked!")
	
	# Check if all bonds collected
	if lore_manager.has_all_bonds():
		Game.flags.set("bonds_complete")
		print("🔥 All Bonds collected! ato3_1 unlocked!")
