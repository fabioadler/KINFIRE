# Graph Report - KINFIRE  (2026-10-26)

## Corpus Check
- 300 files · ~113,748 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1648 nodes · 2566 edges · 335 communities (75 shown, 260 thin omitted)
- Extraction: 82% EXTRACTED · 17% INFERRED · 0% AMBIGUOUS · INFERRED: 449 edges (avg confidence: 0.84)
- Token cost: 17,800 input · 20,600 output

## Community Hubs (Navigation)
- Game Systems Core
- Story & Quest Narrative
- Enemy System & Bestiary
- Audio & Music Engine
- NPC Dialogue System
- Races & Character Creation
- UI Components & Panels
- Enemy Index Registry
- Classes & Skills (Physical)
- NPCs & Races Data
- Data Index - Classes/Races
- Data Index - Quests
- Game Flow & Save/Load
- Combat FX & Visual Effects
- Cleric & Druid Skills (Holy/Nature)
- Enemy AI & Player Combat
- Scene Structure (Overworld/World)
- Hunter Skills & Mechanics
- Main Menu UI
- Classes & Skills (Magic/Holy)
- README - Game Systems
- Item System & Properties
- Hero & Inventory Core
- Warrior Skills & Mechanics
- World Generation & Spawning
- Main Menu Scene & Logic
- Game State & Quest Tracking
- Game Entities (Enemy/Player/World)
- Character Creation UI
- README - Races
- Character Creation Logic
- Territories & Quest Objectives
- Scene Nodes (Enemy/Player)
- Quest Log & Progression
- Arcane Blade Skills (Lâmina Arcana)
- README - Classes
- Weather & Wind Systems
- Inventory Grid Logic
- HUD & Unified Panels
- README - World & Dungeons
- Territory NPCs & Races DB
- Character Creation Flow
- Mage Skills & Arcane Magic
- Item Generation & Loot Tables
- Lore & Mechanics Docs (PT)
- Deep Lore (Kinfire/Maldrach)
- Mechanics & Design Docs
- Market & Vendor Economy
- Auction House & Time
- Status Effects & Damage
- Character Creation UI Helpers
- README - Data Architecture
- Overworld Day/Night & Territories
- HUD Buffs & Vitals
- Lore - Ignorância & Véu
- README - Biomes
- DB Loader & Loot Tables
- Warlock Skills (Bruxo)
- Racial Skill - Dragon Breath
- Mechanics - Essence & Rarity
- Economy - Auction & Reputation
- Character Creation Scene
- Overworld Generation & Weather
- Loot Drop System
- Prologue & Cinzento Events
- Lore - Endings & Truth Fragments
- Design Tokens & HUD
- Tutorial & Progression
- DB Sprite & Texture Assets
- Campfire & Rest System
- World Hazard Zones
- HUD Clock & Minimap
- Enemy & Boss Database
- SFX Pool & Sounds
- Damage Numbers
- Trade Panel UI
- Mechanics - Loot by Rarity
- Mechanics - Clock & Light
- Mechanics - Save Migration
- Rules - Attributes & Combat
- Audio & SFX Autoloads
- Core Autoloads (DB/Game)
- Dialogue Database
- Icon & Tile Database
- NPC Database
- Enemy Teleport & World Utils
- Player Buffs & Timers
- Inventory Serialization
- Character Panel & Sprite Preview
- Dialogue Box & HUD
- Pause & Options
- Cinzento Dialogue Choice
- Audio Thunder
- Audio Sting
- Ability Mod DB
- Equip Slots DB
- Game Process Autoload
- Fragmentos Game State
- Dungeon State
- Key Name DB
- Phase Enum
- Damage Number Process
- FX Shape Process
- Light FX Flicker
- Light FX Shadow Candidates
- Projectile Draw
- Skill Executor
- Class Hit Die
- Class Primary Ability
- Class Resource Label
- Class Skills Data
- Dialogue Choice Condition
- Dialogue Choice Effects
- Dialogue Choice Next ID
- Dialogue Choice Text
- Dialogue Data Nodes
- Dialogue Start ID
- Dialogue Node Choices
- Dialogue Node ID
- Dialogue Page Count
- Dialogue Page Method
- Enemy Behavior Enum
- Enemy Habitats
- Enemy Unique Drop
- Loot Guaranteed
- Loot Unique Chance
- NPC Dialogue ID
- NPC Race ID
- Quest Is Final
- Quest Is Main
- Quest Next
- Quest Prerequisites
- Quest Rewards
- Quest Stage Objectives
- Quest Stage Objective Text
- Quest Objective Type
- Quest Reward Fragment
- Quest Reward Item Rarity
- Race Ability Bonus
- Race Trait Name
- Skill Damage Mult
- Skill Element
- Skill Kind Enum
- Territory Capital Name
- Territory Level Modifier
- Territory Race ID
- Vendor Base Value
- Vendor Race
- Vendor Specialties
- Vendor Stock For
- Cinzento Voice
- Dungeon Carve Corridor
- Dungeon Carve Line
- Dungeon Carve Rect
- Dungeon Farthest Room
- Dungeon Generate
- Dungeon Is Floor
- Dungeon Random Floor
- Dungeon Remove Thin Walls
- Dungeon Set Cell
- Enemy Begin Windup
- Enemy Die
- Enemy Has Affix
- Enemy Is Boss
- Enemy Is CC
- Enemy Reset Attack CD
- Enemy Roll Affixes
- Enemy Setup
- Enemy Windup Time
- Interactable Animate Chest
- Interactable Display Name
- Interactable Hover Check
- Interactable Interact
- Interactable Texture
- Interactable Persist
- Interactable Shrines
- Loot Avoid Label Overlap
- Loot Hover Check
- Loot Interact
- Loot Spawn
- Minion Spawn
- Minion Take Damage
- NPC Display Name
- NPC Hover Check
- NPC Interact
- Overworld Alt
- Overworld Biome At Pos
- Overworld Build Tileset
- Overworld Gen Rand
- Overworld Is Night
- Overworld Level
- Overworld Level At
- Overworld Region Name
- Overworld Register Waypoint
- Overworld Setup Map
- Overworld Spawn Content
- Overworld Travel To
- Player Add Buff
- Player Die
- Player Revive
- Player Setup
- Player Start Dash
- Prologue Apply Brightness
- Prologue Intro
- Prologue On Campfire Lit
- Prologue Setup Map
- Prologue Setup Tutorial
- Prologue Spawn Content
- Territories Capital Of
- Territories Fits
- Territories Place Capital
- Weather Make Emitter
- Weather Make Texture
- World Apply Atmos
- World Apply Brightness
- World Apply Glow
- World Cell To World
- World Get Enemy At
- World Get Interactable At
- World Gold Amount
- World Intro
- World Is Explored
- World Is Floor
- World Item Level
- World Level
- World Loot Bonus
- World Minimap Color
- World Minions Near
- World On Campfire Lit
- World On Mirror
- World On Player Died
- World Points Of Interest
- World Rebuild Buckets
- World Region Name
- World Respawn Player
- World Respawn Position
- World Setup Map
- World Setup Post
- World Shake
- World Start Position
- World To Cell
- Inventory Grid Cols
- Inventory Grid Init
- Inventory Grid Rows
- Item Base ID
- Item Category
- Item Icon
- Item Rarity
- Item Sprite
- Item Stat
- Point Buy Total
- Character Race
- Main Menu Ember Ramp
- Main Menu Vignette Shader
- Buff Chip Draw
- Buff Chip Expire
- Inventory Equip View Input
- Inventory Grid Cell At

## God Nodes (most connected - your core abstractions)
1. `SkillData` - 70 edges
2. `Smoke Test Script` - 45 edges
3. `Kinfire` - 42 edges
4. `EnemyData` - 39 edges
5. `Enemies` - 38 edges
6. `QuestData` - 35 edges
7. `Quests` - 32 edges
8. `QuestObjective` - 29 edges
9. `QuestStage` - 27 edges
10. `QuestRewards` - 27 edges

## Surprising Connections (you probably didn't know these)
- `EnemyData` --references--> `LootTableData`  [INFERRED]
  data/enemies/abobora_maldita.tres → scripts/data/loot_table_data.gd
- `QuestObjective` --references--> `NpcData Script Class`  [INFERRED]
  data/quests/ato1_1.tres → scripts/data/npc_data.gd
- `SkillData` --referenced_by--> `ClassData`  [EXTRACTED]
  data/skills/aldeano/golpe_de_lenhador.tres → scripts/data/class_data.gd
- `Bárbaro` --semantically_similar_to--> `Guerreiro`  [INFERRED] [semantically similar]
  data/classes/barbaro.tres → data/classes/guerreiro.tres
- `Bárbaro` --semantically_similar_to--> `Paladino`  [INFERRED] [semantically similar]
  data/classes/barbaro.tres → data/classes/paladino.tres

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Kinfire Race Roster (14 races)** — readme_race_system, readme_humano, readme_alto_elfo, readme_elfo_da_floresta, readme_drow, readme_anao_da_montanha, readme_anao_das_colinas, readme_halfling, readme_meio_orc, readme_tiefling, readme_draconato, readme_gnomo, readme_meio_elfo, readme_tabaxi, readme_golias [EXTRACTED 1.00]
- **Kinfire Class Roster (14 classes)** — readme_class_system, readme_barbaro, readme_feiticeiro, readme_ladino, readme_guerreiro, readme_paladino, readme_necromante, readme_cacador, readme_monge, readme_bruxo, readme_druida, readme_clerigo, readme_bardo, readme_mago, readme_lamina_arcana [EXTRACTED 1.00]
- **Kinfire Biome Set (7 biomes)** — readme_biome_system, readme_planicies, readme_floresta_sussurrante, readme_areias_escaldantes, readme_tundra_congelada, readme_pantano_putrido, readme_ermos_vulcanicos, readme_terras_corrompidas [EXTRACTED 1.00]
- **Game Data Categories** — data_index_races, data_index_classes, data_index_enemies, data_index_quests, data_index_vendors [INFERRED 0.85]
- **Act 1 Quests** — data_index_ato1_1, data_index_ato1_2, data_index_ato1_3, data_index_ato1_4, data_index_ato1_5, data_index_ato1_6, data_index_ato1_7 [EXTRACTED 1.00]
- **Act 2 Quests** — data_index_ato2_1, data_index_ato2_2, data_index_ato2_3, data_index_ato2_4, data_index_ato2_5, data_index_ato2_6, data_index_ato2_7, data_index_ato2_8 [EXTRACTED 1.00]
- **Act 3 Quests** — data_index_ato3_1, data_index_ato3_2, data_index_ato3_3, data_index_ato3_4, data_index_ato3_5, data_index_ato3_6, data_index_ato3_7, data_index_ato3_8 [EXTRACTED 1.00]
- **Mystery Quests** — data_index_misterio_1, data_index_misterio_2, data_index_misterio_3, data_index_misterio_4, data_index_misterio_5, data_index_misterio_6, data_index_misterio_7, data_index_misterio_8 [EXTRACTED 1.00]
- **All Classes Implement ClassData** — data_classes_aldeao_aldeao, data_classes_barbaro_barbaro, data_classes_bardo_bardo, data_classes_bruxo_bruxo, data_classes_cacador_cacador, data_classes_clerigo_clerigo, data_classes_druida_druida, data_classes_feiticeiro_feiticeiro, data_classes_guerreiro_guerreiro, data_classes_ladino_ladino, data_classes_lamina_arcana_lamina_arcana, data_classes_mago_mago, data_classes_monge_monge, data_classes_necromante_necromante, data_classes_paladino_paladino [EXTRACTED 1.00]
- **Melee Combat Classes** — data_classes_barbaro_barbaro, data_classes_guerreiro_guerreiro, data_classes_paladino_paladino, data_classes_ladino_ladino, data_classes_monge_monge, data_classes_lamina_arcana_lamina_arcana [INFERRED 0.85]
- **Spellcasting Classes** — data_classes_mago_mago, data_classes_feiticeiro_feiticeiro, data_classes_bruxo_bruxo, data_classes_clerigo_clerigo, data_classes_druida_druida, data_classes_bardo_bardo, data_classes_necromante_necromante, data_classes_lamina_arcana_lamina_arcana [INFERRED 0.85]
- **Acampamento Camp Dialogue Scene** — data_dialogues_bree_cozinheira_bree_cozinheira, data_dialogues_marn_vigia_marn_vigia, data_dialogues_cinzento_acampamento_cinzento_acampamento [INFERRED 0.85]
- **Ignorância Knowledge-Gating Choice Pattern** — data_dialogues_bree_cozinheira_c_p_veu, data_dialogues_bree_cozinheira_c_p_territorios, data_dialogues_bree_cozinheira_c_p_veu_profundo, data_dialogues_marn_vigia_c_p_territorios, data_dialogues_marn_vigia_c_p_patrulha, data_dialogues_cinzento_acampamento_dialoguechoice_sabio, data_dialogues_bree_cozinheira_ignorancia [INFERRED 0.85]
- **Kinfire Core Lore Concepts (Véu, Territórios, Kinfire)** — data_dialogues_bree_cozinheira_veu, data_dialogues_bree_cozinheira_territorios, data_dialogues_bree_cozinheira_kinfire [INFERRED 0.85]
- **Enemy Bestiary (data/enemies, part a-m)** — data_enemies_abobora_maldita_abobora_maldita, data_enemies_anao_saqueador_anao_saqueador, data_enemies_anjo_caido_anjo_caido, data_enemies_aranha_gigante_aranha_gigante, data_enemies_arqueiro_bandido_arqueiro_bandido, data_enemies_azkhar_azkhar, data_enemies_barrento_barrento, data_enemies_caranguejo_infernal_caranguejo_infernal, data_enemies_cavaleiro_renegado_cavaleiro_renegado, data_enemies_chort_chort, data_enemies_ciclope_ciclope, data_enemies_diabrete_diabrete, data_enemies_escorpiao_escorpiao, data_enemies_espantalho_espantalho, data_enemies_esqueleto_esqueleto, data_enemies_fantasma_fantasma, data_enemies_goblin_goblin, data_enemies_guerreiro_orc_guerreiro_orc, data_enemies_homem_lagarto_homem_lagarto, data_enemies_lesma_acida_lesma_acida, data_enemies_lesminha_lesminha, data_enemies_lobo_sombrio_lobo_sombrio, data_enemies_lodo_lodo, data_enemies_mago_renegado_mago_renegado, data_enemies_medico_da_peste_medico_da_peste [EXTRACTED 1.00]
- **Ranged Projectile Attackers (attack_range + attack_cooldown + projectile_color)** — data_enemies_anjo_caido_anjo_caido, data_enemies_arqueiro_bandido_arqueiro_bandido, data_enemies_escorpiao_escorpiao, data_enemies_fantasma_fantasma, data_enemies_mago_renegado_mago_renegado, data_enemies_medico_da_peste_medico_da_peste [INFERRED 0.85]
- **High-Frequency Fodder Enemies (spawn_weight >= 2.0, low XP)** — data_enemies_aranha_gigante_aranha_gigante, data_enemies_diabrete_diabrete, data_enemies_esqueleto_esqueleto, data_enemies_goblin_goblin, data_enemies_lesminha_lesminha, data_enemies_lobo_sombrio_lobo_sombrio, data_enemies_lodo_lodo [INFERRED 0.85]
- **Zombie Variant Family** — data_enemies_zumbi_zumbi, data_enemies_zumbi_gelido_zumbi_gelido, data_enemies_zumbi_miudo_zumbi_miudo [INFERRED 0.85]
- **World Boss Group** — data_enemies_ogro_ogro, data_enemies_putrefato_putrefato [INFERRED 0.95]
- **Ranged Caster Archetype** — data_enemies_necromante_profano_necromante_profano, data_enemies_xama_orc_xama_orc [INFERRED 0.85]
- **NpcData Data-Driven Pattern** — data_npcs_bree_cozinheira_bree_cozinheira, data_npcs_marn_vigia_marn_vigia, scripts_data_npc_data_npcdata [INFERRED 0.75]
- **Seven Flames Relighting Sequence (Act 3)** — data_quests_ato3_1_ato3_1, data_quests_ato3_2_ato3_2, data_quests_ato3_3_ato3_3, data_quests_ato3_4_ato3_4, data_quests_ato3_5_ato3_5, data_quests_ato3_6_ato3_6, data_quests_ato3_7_ato3_7 [INFERRED 0.95]
- **Act 2 Véu Feud-Resolution Quest Pattern** — data_quests_ato2_1_ato2_1, data_quests_ato2_2_ato2_2, data_quests_ato2_3_ato2_3, data_quests_ato2_4_ato2_4, data_quests_ato2_5_ato2_5, data_quests_ato2_6_ato2_6, data_quests_ato2_7_ato2_7 [INFERRED 0.85]
- **Act 1 Truth-Substitution Investigation Arc** — data_quests_ato1_2_ato1_2, data_quests_ato1_3_ato1_3, data_quests_ato1_4_ato1_4, data_quests_ato1_5_ato1_5, data_quests_ato1_6_ato1_6 [INFERRED 0.85]
- **Mistério Quest Chain (chain: misterio)** — data_quests_misterio_1_misterio_1, data_quests_misterio_2_misterio_2, data_quests_misterio_3_misterio_3, data_quests_misterio_4_misterio_4, data_quests_misterio_5_misterio_5, data_quests_misterio_6_misterio_6, data_quests_misterio_7_misterio_7, data_quests_misterio_8_misterio_8 [INFERRED 0.95]
- **Fragmento da Verdade Progression** — data_quests_misterio_1_misterio_1, data_quests_misterio_2_misterio_2, data_quests_misterio_3_misterio_3, data_quests_misterio_4_misterio_4, data_quests_misterio_5_misterio_5, data_quests_misterio_6_misterio_6, data_quests_misterio_7_misterio_7, data_quests_misterio_8_misterio_8, concept_fragmento_da_verdade [INFERRED 0.95]
- **Cinzento Narrative Arc** — data_quests_misterio_6_misterio_6, data_quests_misterio_7_misterio_7, data_quests_misterio_8_misterio_8, concept_cinzento [INFERRED 0.85]
- **Elf Lineage Races** — data_races_alto_elfo_alto_elfo, data_races_elfo_floresta_elfo_floresta, data_races_drow_drow, data_races_meio_elfo_meio_elfo [INFERRED 0.85]
- **Dwarf Lineage Races** — data_races_anao_colinas_anao_colinas, data_races_anao_montanha_anao_montanha [INFERRED 0.95]
- **Human Lineage Races** — data_races_humano_humano, data_races_meio_elfo_meio_elfo, data_races_meio_orc_meio_orc [INFERRED 0.85]
- **Skill Definition Components** — data_skills_aldeano_golpe_de_lenhador_golpe_de_lenhador, data_skills_aldeano_golpe_de_lenhador_melee_arc, data_skills_aldeano_golpe_de_lenhador_physical_element, data_skills_aldeano_golpe_de_lenhador_swing1, data_skills_aldeano_golpe_de_lenhador_s_sword01 [INFERRED 0.75]
- **Barbaro Skill Set** — data_skills_barbaro_furia_berserker_furia_berserker, data_skills_barbaro_golpe_brutal_golpe_brutal, data_skills_barbaro_grito_aterrador_grito_aterrador, data_skills_barbaro_martelo_dos_antigos_martelo_dos_antigos, data_skills_barbaro_salto_furioso_salto_furioso, data_skills_barbaro_turbilhao_turbilhao [INFERRED 0.75]
- **Bard Skill Set** — data_skills_bardo_balada_da_ruina_balada_da_ruina, data_skills_bardo_cancao_da_confusao_cancao_da_confusao, data_skills_bardo_inspiracao_heroica_inspiracao_heroica, data_skills_bardo_nota_cortante_nota_cortante, data_skills_bardo_onda_trovejante_onda_trovejante, data_skills_bardo_sussurros_dissonantes_sussurros_dissonantes [EXTRACTED 1.00]
- **Bard Crowd Control Skills** — data_skills_bardo_balada_da_ruina_balada_da_ruina, data_skills_bardo_cancao_da_confusao_cancao_da_confusao, data_skills_bardo_sussurros_dissonantes_sussurros_dissonantes [INFERRED 0.85]
- **Bard Sonic Attacks** — data_skills_bardo_nota_cortante_nota_cortante, data_skills_bardo_onda_trovejante_onda_trovejante, data_skills_bardo_balada_da_ruina_balada_da_ruina [INFERRED 0.75]
- **Bruxo Skill Set** — data_skills_bruxo_drenar_alma_drenar_alma, data_skills_bruxo_familiar_demoniaco_familiar_demoniaco, data_skills_bruxo_maldicao_da_agonia_maldicao_da_agonia, data_skills_bruxo_portal_infernal_portal_infernal, data_skills_bruxo_raio_sombrio_raio_sombrio, data_skills_bruxo_rajada_mistica_rajada_mistica [INFERRED 0.85]
- **Shadow Element Skills** — data_skills_bruxo_drenar_alma_drenar_alma, data_skills_bruxo_maldicao_da_agonia_maldicao_da_agonia, data_skills_bruxo_raio_sombrio_raio_sombrio, data_skills_bruxo_rajada_mistica_rajada_mistica [EXTRACTED 1.00]
- **SkillData Implementations** — data_skills_bruxo_drenar_alma_drenar_alma, data_skills_bruxo_familiar_demoniaco_familiar_demoniaco, data_skills_bruxo_maldicao_da_agonia_maldicao_da_agonia, data_skills_bruxo_portal_infernal_portal_infernal, data_skills_bruxo_raio_sombrio_raio_sombrio, data_skills_bruxo_rajada_mistica_rajada_mistica [EXTRACTED 1.00]
- **Cacador Complete Skill Set** — data_skills_cacador_armadilha_explosiva_armadilha_explosiva, data_skills_cacador_chamar_lobo_chamar_lobo, data_skills_cacador_chuva_de_flechas_chuva_de_flechas, data_skills_cacador_flecha_rapida_flecha_rapida, data_skills_cacador_ler_o_vento_ler_o_vento, data_skills_cacador_rajada_rajada, data_skills_cacador_tiro_perfurante_tiro_perfurante [INFERRED 0.85]
- **Projectile Skills (Kind.PROJECTILE)** — data_skills_cacador_flecha_rapida_flecha_rapida, data_skills_cacador_rajada_rajada, data_skills_cacador_tiro_perfurante_tiro_perfurante [EXTRACTED 1.00]
- **SkillData Implementations** — data_skills_cacador_armadilha_explosiva_armadilha_explosiva, data_skills_cacador_chamar_lobo_chamar_lobo, data_skills_cacador_chuva_de_flechas_chuva_de_flechas, data_skills_cacador_flecha_rapida_flecha_rapida, data_skills_cacador_ler_o_vento_ler_o_vento, data_skills_cacador_rajada_rajada, data_skills_cacador_tiro_perfurante_tiro_perfurante [EXTRACTED 1.00]
- **Clerigo Complete Skill Set** — data_skills_clerigo_bencao_bencao, data_skills_clerigo_chama_sagrada_chama_sagrada, data_skills_clerigo_coluna_de_luz_coluna_de_luz, data_skills_clerigo_golpe_sagrado_golpe_sagrado, data_skills_clerigo_guardioes_espirituais_guardioes_espirituais, data_skills_clerigo_palavra_de_cura_palavra_de_cura [INFERRED 0.85]
- **Holy Element Skills** — data_skills_clerigo_chama_sagrada_chama_sagrada, data_skills_clerigo_coluna_de_luz_coluna_de_luz, data_skills_clerigo_golpe_sagrado_golpe_sagrado, data_skills_clerigo_guardioes_espirituais_guardioes_espirituais [EXTRACTED 1.00]
- **Support Skills (Buff and Heal)** — data_skills_clerigo_bencao_bencao, data_skills_clerigo_palavra_de_cura_palavra_de_cura [INFERRED 0.75]
- **Druida Complete Skill Set** — data_skills_druida_espinhos_espinhos, data_skills_druida_forma_de_lobo_forma_de_lobo, data_skills_druida_forma_de_urso_forma_de_urso, data_skills_druida_raizes_presas_raizes_presas, data_skills_druida_tempestade_natural_tempestade_natural, data_skills_druida_terremoto_terremoto [INFERRED 0.85]
- **Poison Element Skills** — data_skills_druida_espinhos_espinhos, data_skills_druida_raizes_presas_raizes_presas [EXTRACTED 1.00]
- **Transformation Buff Skills** — data_skills_druida_forma_de_lobo_forma_de_lobo, data_skills_druida_forma_de_urso_forma_de_urso [EXTRACTED 1.00]
- **Feiticeiro Skill Set** — data_skills_feiticeiro_bola_de_fogo_bola_de_fogo, data_skills_feiticeiro_corrente_de_relampagos_corrente_de_relampagos, data_skills_feiticeiro_meteoro_meteoro, data_skills_feiticeiro_nevasca_nevasca, data_skills_feiticeiro_nova_gelida_nova_gelida, data_skills_feiticeiro_raio_de_fogo_raio_de_fogo [INFERRED 0.95]
- **Fire Element Skills** — data_skills_feiticeiro_bola_de_fogo_bola_de_fogo, data_skills_feiticeiro_meteoro_meteoro, data_skills_feiticeiro_raio_de_fogo_raio_de_fogo [INFERRED 0.95]
- **Ice Element Skills** — data_skills_feiticeiro_nevasca_nevasca, data_skills_feiticeiro_nova_gelida_nova_gelida [INFERRED 0.95]
- **Guerreiro Melee Skills** — data_skills_guerreiro_golpe_de_escudo_golpe_de_escudo, data_skills_guerreiro_golpe_executor_golpe_executor, data_skills_guerreiro_golpe_largo_golpe_largo [INFERRED 0.85]
- **All Guerreiro Skills** — data_skills_guerreiro_golpe_de_escudo_golpe_de_escudo, data_skills_guerreiro_golpe_executor_golpe_executor, data_skills_guerreiro_golpe_largo_golpe_largo, data_skills_guerreiro_investida_investida, data_skills_guerreiro_postura_defensiva_postura_defensiva, data_skills_guerreiro_redemoinho_de_aco_redemoinho_de_aco [EXTRACTED 1.00]
- **Ladino Class Skill Set** — data_skills_ladino_apunhalar_apunhalar, data_skills_ladino_bomba_de_fumaca_bomba_de_fumaca, data_skills_ladino_chuva_de_facas_chuva_de_facas, data_skills_ladino_frasco_venenoso_frasco_venenoso, data_skills_ladino_leque_de_laminas_leque_de_laminas, data_skills_ladino_passo_sombrio_passo_sombrio [INFERRED 0.85]
- **Lâmina Arcana Skill Tree** — data_skills_lamina_arcana_corte_arcano_corte_arcano, data_skills_lamina_arcana_danca_das_laminas_danca_das_laminas, data_skills_lamina_arcana_golpe_tempestuoso_golpe_tempestuoso, data_skills_lamina_arcana_lamina_flamejante_lamina_flamejante, data_skills_lamina_arcana_lamina_gelida_lamina_gelida, data_skills_lamina_arcana_passo_nebuloso_passo_nebuloso [EXTRACTED 1.00]
- **Arcane Element Skills** — data_skills_lamina_arcana_corte_arcano_corte_arcano, data_skills_lamina_arcana_danca_das_laminas_danca_das_laminas, data_skills_lamina_arcana_passo_nebuloso_passo_nebuloso [EXTRACTED 1.00]
- **Elemental Blade Skills** — data_skills_lamina_arcana_lamina_flamejante_lamina_flamejante, data_skills_lamina_arcana_lamina_gelida_lamina_gelida, data_skills_lamina_arcana_golpe_tempestuoso_golpe_tempestuoso [INFERRED 0.85]
- **Mage Skill Set** — data_skills_mago_dobra_temporal_dobra_temporal, data_skills_mago_missil_arcano_missil_arcano, data_skills_mago_orbe_desintegrador_orbe_desintegrador, data_skills_mago_raio_arcano_raio_arcano, data_skills_mago_singularidade_singularidade, data_skills_mago_teleporte_teleporte [INFERRED 0.95]
- **Arcane Offensive Skills** — data_skills_mago_missil_arcano_missil_arcano, data_skills_mago_orbe_desintegrador_orbe_desintegrador, data_skills_mago_raio_arcano_raio_arcano, data_skills_mago_singularidade_singularidade [INFERRED 0.85]
- **SkillData Implementations** — data_skills_mago_dobra_temporal_dobra_temporal, data_skills_mago_missil_arcano_missil_arcano, data_skills_mago_orbe_desintegrador_orbe_desintegrador, data_skills_mago_raio_arcano_raio_arcano, data_skills_mago_singularidade_singularidade, data_skills_mago_teleporte_teleporte, scripts_data_skill_data_skilldata [EXTRACTED 1.00]
- **Monk Skill System** — data_skills_monge_chute_voador_chute_voador, data_skills_monge_mil_punhos_mil_punhos, data_skills_monge_onda_de_luz_onda_de_luz, data_skills_monge_palma_explosiva_palma_explosiva, data_skills_monge_punhos_do_trovao_punhos_do_trovao, data_skills_monge_respiracao_celestial_respiracao_celestial [INFERRED 0.85]
- **Necromante Skill Set** — data_skills_necromante_drenar_vida_drenar_vida, data_skills_necromante_erguer_esqueletos_erguer_esqueletos, data_skills_necromante_golem_de_carne_golem_de_carne, data_skills_necromante_lanca_de_ossos_lanca_de_ossos, data_skills_necromante_maldicao_explosiva_maldicao_explosiva, data_skills_necromante_nevoa_da_morte_nevoa_da_morte [INFERRED 0.95]
- **Summoning Skills** — data_skills_necromante_erguer_esqueletos_erguer_esqueletos, data_skills_necromante_golem_de_carne_golem_de_carne [INFERRED 0.95]
- **Shadow Element Skills** — data_skills_necromante_drenar_vida_drenar_vida, data_skills_necromante_maldicao_explosiva_maldicao_explosiva, data_skills_necromante_nevoa_da_morte_nevoa_da_morte [INFERRED 0.85]
- **Paladin Skill Set** — data_skills_paladino_aura_de_consagracao_aura_de_consagracao, data_skills_paladino_cura_divina_cura_divina, data_skills_paladino_escudo_da_fe_escudo_da_fe, data_skills_paladino_golpe_justo_golpe_justo, data_skills_paladino_martelo_abencoado_martelo_abencoado, data_skills_paladino_punho_dos_ceus_punho_dos_ceus [INFERRED 0.95]
- **Holy Element Skills** — data_skills_paladino_aura_de_consagracao_aura_de_consagracao, data_skills_paladino_golpe_justo_golpe_justo, data_skills_paladino_martelo_abencoado_martelo_abencoado, data_skills_paladino_punho_dos_ceus_punho_dos_ceus [INFERRED 0.95]
- **Damage Skills** — data_skills_paladino_aura_de_consagracao_aura_de_consagracao, data_skills_paladino_golpe_justo_golpe_justo, data_skills_paladino_martelo_abencoado_martelo_abencoado, data_skills_paladino_punho_dos_ceus_punho_dos_ceus [INFERRED 0.85]
- **Sopro Dracônico Skill Definition** — data_skills_racial_sopro_draconico_sopro_draconico, data_skills_racial_sopro_draconico_skill_data, data_skills_racial_sopro_draconico_fire_element, data_skills_racial_sopro_draconico_cone_attack, data_skills_racial_sopro_draconico_armor_ignore, data_skills_racial_sopro_draconico_knockback, data_skills_racial_sopro_draconico_explode_sound [EXTRACTED 1.00]
- **TerritoryData Schema Implementers** — data_territories_alto_elfo_alto_elfo, data_territories_anao_colinas_anao_colinas, data_territories_anao_montanha_anao_montanha, data_territories_draconato_draconato, data_territories_drow_drow, data_territories_elfo_floresta_elfo_floresta, data_territories_gnomo_gnomo, data_territories_golias_golias, data_territories_halfling_halfling, data_territories_humano_humano, data_territories_meio_elfo_meio_elfo, data_territories_meio_orc_meio_orc, data_territories_tabaxi_tabaxi, data_territories_tiefling_tiefling [EXTRACTED 1.00]
- **Floresta Biome Territories** — data_territories_alto_elfo_alto_elfo, data_territories_elfo_floresta_elfo_floresta, data_territories_tabaxi_tabaxi [INFERRED 0.85]
- **Planície Biome Territories** — data_territories_anao_colinas_anao_colinas, data_territories_halfling_halfling, data_territories_humano_humano, data_territories_meio_elfo_meio_elfo [INFERRED 0.85]
- **All Vendors Implement VendorData Script** — data_vendors_alto_elfo, data_vendors_anao_colinas, data_vendors_anao_montanha, data_vendors_draconato, data_vendors_drow, data_vendors_elfo_floresta, data_vendors_gnomo, data_vendors_golias, data_vendors_halfling, data_vendors_humano, data_vendors_meio_elfo, data_vendors_meio_orc, data_vendors_tabaxi, data_vendors_tiefling [EXTRACTED 1.00]
- **Magic-Focused Vendors (Orb/Staff/Book Specialties)** — data_vendors_alto_elfo, data_vendors_drow, data_vendors_tiefling, data_vendors_gnomo, data_vendors_meio_elfo [INFERRED 0.85]
- **Melee-Weapon-Focused Vendors (Axe/Mace/Sword/Spear/Fist Specialties)** — data_vendors_anao_colinas, data_vendors_anao_montanha, data_vendors_draconato, data_vendors_golias, data_vendors_halfling, data_vendors_meio_orc [INFERRED 0.85]
- **Documentação canônica do KINFIRE** — docs_lore_lore, docs_mecanicas_mecanicas, docs_regras_do_jogo_regras_do_jogo, docs_plano_plano [EXTRACTED 1.00]
- **Fluxo do Final Dourado (Laço-Vivo, mistérios, fragmentos)** — docs_lore_laco_vivo, docs_lore_ignorancia, docs_lore_os_oito_misterios, docs_lore_fragmentos_da_verdade, docs_lore_final_dourado, docs_lore_fenda [EXTRACTED 0.95]
- **Sistema de economia e mercado (vendor, demanda, reputação, leilão, essência)** — docs_mecanicas_vendor_data, docs_mecanicas_preco_dinamico, docs_mecanicas_reputacao, docs_mecanicas_casa_de_leiloes, docs_regras_do_jogo_economia, docs_regras_do_jogo_essencia, docs_lore_essencia [EXTRACTED 0.95]
- **Shared Level Scene Structure** — scenes_game_overworld_overworld, scenes_game_prologue_prologue, scenes_game_world_world [INFERRED 0.85]
- **Shared Character Collision Shape** — scenes_game_enemy_circleshape2d_body, scenes_game_player_circleshape2d_body [INFERRED 0.95]
- **Level CanvasModulate Group** — scenes_game_overworld_canvasmodulate, scenes_game_prologue_canvasmodulate, scenes_game_world_canvasmodulate [INFERRED 0.75]
- **Character Creation Wizard Flow** — scripts_menus_character_creation_buildracelist, scripts_menus_character_creation_buildclasslist, scripts_menus_character_creation_buildattributes, scripts_menus_character_creation_buildnamepage [EXTRACTED 0.95]
- **Main Menu UI Setup** — scripts_menus_main_menu_ready, scripts_menus_main_menu_menubutton, scripts_menus_main_menu_buildsummary, scripts_menus_main_menu_layout [EXTRACTED 0.95]
- **Shared Singleton Dependencies** — scripts_menus_character_creation_game, scripts_menus_character_creation_db, scripts_menus_character_creation_uikit, scripts_menus_main_menu_game, scripts_menus_main_menu_db, scripts_menus_main_menu_uikit [INFERRED 0.85]
- **Global Autoload Singletons** — scripts_autoload_audio_audio, scripts_autoload_db_db, scripts_autoload_game_game, scripts_autoload_sfx_sfx [EXTRACTED 1.00]
- **Adaptive Audio Layer System** — scripts_autoload_audio_set_base, scripts_autoload_audio_set_ambience, scripts_autoload_audio_set_layer, scripts_autoload_audio_sting, scripts_autoload_audio_set_rain, scripts_autoload_audio_play_thunder, scripts_autoload_audio_update_world, scripts_autoload_audio_stop_all [EXTRACTED 0.95]
- **Item Generation Pipeline** — scripts_autoload_db_roll_rarity, scripts_autoload_db_random_base_for, scripts_autoload_db_create_item, scripts_autoload_db_roll_item, scripts_autoload_db_roll_item_of, scripts_autoload_db__build_loot_tables [EXTRACTED 0.95]
- **FxShape Type Enum Participants** — scripts_combat_fx_shape_type, scripts_combat_fx_shape_spawn, scripts_combat_fx_shape_spawn_beam, scripts_combat_fx_shape__draw, scripts_combat_skill_executor_execute [EXTRACTED 1.00]
- **LightFx Flicker Enum Participants** — scripts_combat_light_fx_flicker, scripts_combat_light_fx_register, scripts_combat_light_fx_update, scripts_combat_light_fx__flicker, scripts_combat_fx_make_light [EXTRACTED 1.00]
- **SkillExecutor Skill Kind Handlers** — scripts_combat_skill_executor_execute, scripts_combat_skill_executor__in_cone, scripts_combat_skill_executor__nearest, scripts_combat_skill_executor__repeat_hits, scripts_combat_skill_executor__clamp_target, scripts_combat_skill_executor__apply_status [EXTRACTED 1.00]
- **Dialogue-Driven Quest & Trade Flow** — scripts_core_dialogue_engine_dialogueengine, scripts_core_condition_resolver_conditionresolver, scripts_core_territory_npcs_territorynpcs, scripts_core_quest_log_questlog, scripts_autoload_game_flags, scripts_autoload_game_quests [INFERRED 0.85]
- **Dynamic Economy (supply/demand + auction)** — scripts_core_market_market, scripts_core_auction_auction, scripts_autoload_game_market, scripts_autoload_game_auction, scripts_data_vendor_data__base_value, scripts_autoload_game_reputation [INFERRED 0.85]
- **Seed-Deterministic Daily World State** — scripts_core_weather_weather, scripts_core_wind_field_windfield, scripts_core_market_market_day, scripts_core_weather_world_seed, scripts_core_wind_field_world_seed [INFERRED 0.85]
- **Dialogue System Components** — scripts_data_dialogue_data_dialoguedata, scripts_data_dialogue_node_dialoguenode, scripts_data_dialogue_choice_dialoguechoice [EXTRACTED 1.00]
- **Quest System Components** — scripts_data_quest_data_questdata, scripts_data_quest_stage_queststage, scripts_data_quest_objective_questobjective, scripts_data_quest_rewards_questrewards [EXTRACTED 1.00]
- **Character Progression Data** — scripts_data_class_data_classdata, scripts_data_race_data_racedata, scripts_data_skill_data_skilldata [INFERRED 0.85]
- **Combat Entities (Enemy, Player, Minion)** — scripts_game_enemy_enemy, scripts_game_player_player, scripts_game_minion_minion [INFERRED 0.85]
- **World Interaction System (Interactable, LootDrop, NPC)** — scripts_game_interactable_interactable, scripts_game_loot_drop_lootdrop, scripts_game_npc_npc [INFERRED 0.85]
- **Overworld Generation Pipeline** — scripts_game_overworld_overworld, scripts_game_overworld_gen_overworldgen, scripts_game_territories_territories, scripts_game_weather_layer_weatherlayer [INFERRED 0.85]
- **Inventory Placement Flow** — scripts_items_inventory_grid_find_space, scripts_items_inventory_grid_can_place, scripts_items_inventory_grid_in_bounds, scripts_items_inventory_grid_overlapping [EXTRACTED 1.00]
- **Item Lifecycle Management** — scripts_items_inventory_grid_add, scripts_items_inventory_grid_place, scripts_items_inventory_grid_remove, scripts_items_inventory_grid_load_array [EXTRACTED 1.00]
- **Tooltip Composition** — scripts_items_item_tooltip_bbcode, scripts_items_item_rarity_color, scripts_items_item_is_weapon, scripts_items_item_dps, scripts_items_item_diff, scripts_items_item_required_level, scripts_items_item_sell_value [EXTRACTED 1.00]
- **Character Creation Wizard Flow** — scripts_menus_character_creation_build_race_list, scripts_menus_character_creation_build_class_list, scripts_menus_character_creation_build_attributes, scripts_menus_character_creation_build_name_page, scripts_menus_character_creation_go_step, scripts_menus_character_creation_can_continue, scripts_menus_character_creation_on_next, scripts_menus_character_creation_on_back [EXTRACTED 0.95]
- **Main Menu UI Composition** — scripts_menus_main_menu_ready, scripts_menus_main_menu_build_summary, scripts_menus_main_menu_layout, scripts_menus_main_menu_spawn_walker, scripts_menus_main_menu_process, scripts_menus_main_menu_menu_button [EXTRACTED 0.95]
- **Shared Game Singletons (DB, Game, UIKit, SpritePreview)** — scripts_menus_character_creation_db, scripts_menus_character_creation_game, scripts_menus_character_creation_uikit, scripts_menus_character_creation_spritepreview, scripts_menus_main_menu_db, scripts_menus_main_menu_game, scripts_menus_main_menu_uikit, scripts_menus_main_menu_spritepreview [INFERRED 0.85]
- **HUD Component Suite (Fase 6.1/6.2)** — scripts_ui_hud_hud, scripts_ui_vitals_bar_vitalsbar, scripts_ui_level_badge_levelbadge, scripts_ui_buff_chip_buffchip, scripts_ui_skill_slot_skillslot, scripts_ui_clock_chip_clockchip [INFERRED 0.85]
- **Unified Panel Tab Pages** — scripts_ui_unified_panel_unifiedpanel, scripts_ui_character_panel_characterpanel, scripts_ui_inventory_panel_inventorypanel, scripts_ui_skills_panel_skillspanel, scripts_ui_quest_panel_questpanel [EXTRACTED 1.00]
- **UIKit-Dependent UI Components** — scripts_ui_hud_hud, scripts_ui_character_panel_characterpanel, scripts_ui_clock_chip_clockchip, scripts_ui_dialogue_box_dialoguebox, scripts_ui_inventory_panel_inventorypanel, scripts_ui_level_badge_levelbadge, scripts_ui_minimap_minimap, scripts_ui_options_panel_optionspanel, scripts_ui_quest_panel_questpanel, scripts_ui_skill_slot_skillslot, scripts_ui_skills_panel_skillspanel, scripts_ui_sprite_preview_spritepreview, scripts_ui_trade_panel_tradepanel, scripts_ui_unified_panel_unifiedpanel, scripts_ui_vitals_bar_vitalsbar [EXTRACTED 1.00]
- **Core Smoke Test Phases** — tests_smoke_test_run, tests_smoke_test_test_prologue, tests_smoke_test_test_dialogue, tests_smoke_test_test_overworld [EXTRACTED 1.00]
- **Gameplay Systems Exercised by Smoke Test** — game_autoload, hero_class, db_singleton, overworld_class, prologue_class, dialogue_engine, territories_class, enemy_class, loot_drop_class, quest_log_class, vendor_data_class, market_class, auction_class, hud_class [INFERRED 0.85]
- **Visual & Audio Systems Verified** — vitals_bar_class, level_badge_class, clock_chip_class, minimap_class, unified_panel_class, light_fx_class, audio_class, weather_class, wind_field_class [INFERRED 0.75]

## Communities (335 total, 260 thin omitted)

### Community 0 - "Game Systems Core"
Cohesion: 0.05
Nodes (77): Adaptive Audio (Ambience/UI Buses, Biome Ambience, Wind Gain, Sting, Combat Layer, Dialogue Ducking), Auction, Auction House (6 Slots Daily, 1 Essence, Rival Bidding), Audio, BuffChip, ClockChip, Clock & Day/Night Cycle (HUD Chip, Color Grading, Hour Changed Signal, Sleep), ConditionResolver (+69 more)

### Community 1 - "Story & Quest Narrative"
Cohesion: 0.10
Nodes (73): As Chamas (Masmorras-Chama), O Cinzento, Fragmento da Verdade, Os Guardiões, Ithariel, Laço-Vivo, Maldrach, Cadeia Mistério (chain: misterio) (+65 more)

### Community 2 - "Enemy System & Bestiary"
Cohesion: 0.09
Nodes (64): Behavior 0 - Melee Basic, Behavior 1 - Ranged Caster, Behavior 2 - Mimic/Ambush, Behavior 3 - Fast Swarmer, Behavior 4 - Boss Tank, World Boss, Boss Enemy (behavior=4, world_boss), Fire Element (+56 more)

### Community 3 - "Audio & Music Engine"
Cohesion: 0.06
Nodes (48): _amb_duck_db, _apply_amb_bus, _apply_music_bus, _boss_near, _combat_near, _duck_db, _ensure_loop, _fade_stop (+40 more)

### Community 4 - "NPC Dialogue System"
Cohesion: 0.06
Nodes (46): Bree Cozinheira Dialogue (DialogueData 'bree_cozinheira'), Bree choice: (Continuar), Bree choice: (Conversar), Bree choice: (Cumprimentar), Bree choice: O acampamento está seguro comigo., Bree choice: O que são os territórios?, Bree choice: O que aconteceu com o mundo?, Bree choice: Fale do Véu. (+38 more)

### Community 5 - "Races & Character Creation"
Cohesion: 0.09
Nodes (42): Race: Alto Elfo, Race: Anão das Colinas, Race: Anão da Montanha, Race: Draconato, Race: Drow, Race: Elfo da Floresta, Race: Gnomo, Race: Golias (+34 more)

### Community 7 - "Enemy Index Registry"
Cohesion: 0.05
Nodes (38): abobora_maldita, anao_saqueador, anjo_caido, aranha_gigante, arqueiro_bandido, azkhar, barrento, caranguejo_infernal (+30 more)

### Community 8 - "Classes & Skills (Physical)"
Cohesion: 0.12
Nodes (37): Aldeão, Bárbaro, Bardo, Ladino, Necromante, Golpe de Lenhador, MELEE_ARC, Physical Element (+29 more)

### Community 9 - "NPCs & Races Data"
Cohesion: 0.08
Nodes (37): Bree (NPC Resource), Marn (NPC Resource), Alto Elfo, Sangue Arcano, Anão das Colinas, Resiliência, Anão da Montanha, Pé Firme (+29 more)

### Community 10 - "Data Index - Classes/Races"
Cohesion: 0.09
Nodes (31): alto_elfo, anao_colinas, anao_montanha, barbaro, bardo, bruxo, cacador, Classes (+23 more)

### Community 11 - "Data Index - Quests"
Cohesion: 0.06
Nodes (32): ato1_1, ato1_2, ato1_3, ato1_4, ato1_5, ato1_6, ato1_7, ato2_1 (+24 more)

### Community 12 - "Game Flow & Save/Load"
Cohesion: 0.11
Nodes (28): classes, DIFFICULTIES, get_class_data, _hero_dead, _migrate, change_scene, continue_game, delete_save (+20 more)

### Community 13 - "Combat FX & Visual Effects"
Cohesion: 0.10
Nodes (28): burst, explosion, Fx, light_texture, make_light, _draw, FxShape, spawn (+20 more)

### Community 14 - "Cleric & Druid Skills (Holy/Nature)"
Cohesion: 0.21
Nodes (27): Area Effect Skills, Chaining Hit Mechanics, Earth Element, Holy Element, Lightning Element, Poison Element, Projectile Spread Mechanics, Skill Kind Classification System (+19 more)

### Community 15 - "Enemy AI & Player Combat"
Cohesion: 0.09
Nodes (27): _alert_pack, _chase, _do_attack, _do_windup, _execute_attack, _hit_target, _move_towards, _physics_process (+19 more)

### Community 16 - "Scene Structure (Overworld/World)"
Cohesion: 0.11
Nodes (25): CanvasModulate, Decals, Entities, Floor, Fx, Overworld, overworld.gd, Props (+17 more)

### Community 17 - "Hunter Skills & Mechanics"
Cohesion: 0.22
Nodes (23): AOE Target Kind (Kind.AOE_TARGET), Buff Kind (Kind.BUFF), Cooldown Resource Management, Delayed Explosion Mechanic, Fire Element, Multi-Projectile Spread, Physical Element, Pierce Mechanic (+15 more)

### Community 18 - "Main Menu UI"
Cohesion: 0.13
Nodes (23): Hero Class Reference, _make_hero Function, _build_summary, _build_summary Function, DB Singleton Reference, _dungeon_strip, _dungeon_strip Function, _ember_ramp Function (+15 more)

### Community 19 - "Classes & Skills (Magic/Holy)"
Cohesion: 0.24
Nodes (22): Feiticeiro, Monge, Paladino, Bola de Fogo, Corrente de Relâmpagos, Meteoro, Nevasca, Nova Gélida (+14 more)

### Community 20 - "README - Game Systems"
Cohesion: 0.11
Nodes (22): 0x72 DungeonTileset II (CC0), 7Soul1 496 RPG Icons (CC0), Baldur's Gate, Cinzel & Alegreya Fonts (SIL OFL), Day/Night Cycle, Diablo 3, Enemy (scripts/game/), Diablo-style Equipment System (+14 more)

### Community 21 - "Item System & Properties"
Cohesion: 0.12
Nodes (21): armor, attack_speed, block, _diff, dps, flavor, is_weapon, item_level (+13 more)

### Community 22 - "Hero & Inventory Core"
Cohesion: 0.14
Nodes (20): Auction.place_bid, Hero._make_inventory, Hero.ability, Hero.add_essence, Hero.add_gold, Hero.add_xp, Hero.armor, Hero.create (+12 more)

### Community 23 - "Warrior Skills & Mechanics"
Cohesion: 0.15
Nodes (19): Guerreiro, Golpe de Escudo, Kind Melee (0), Sound Block, Golpe do Executor, Kind Melee (0), Sound Hit Heavy, Golpe Largo (+11 more)

### Community 24 - "World Generation & Spawning"
Cohesion: 0.15
Nodes (19): affixes_for, roll_rarity, _summon_swarm, create, create, biome_at, ground_variant, liquid_at (+11 more)

### Community 25 - "Main Menu Scene & Logic"
Cohesion: 0.18
Nodes (18): MainMenu Node, AUTHORS, _confirm Function, FOG_SHADER, Game Singleton Reference, LOGO Constant, MainMenu Class, _modal Function (+10 more)

### Community 26 - "Game State & Quest Tracking"
Cohesion: 0.17
Nodes (18): Game.flags, ignorance, quest_log, Game.reputation, trade_requested, ConditionResolver._compare, ConditionResolver._eval_one, ConditionResolver._value_id (+10 more)

### Community 27 - "Game Entities (Enemy/Player/World)"
Cohesion: 0.19
Nodes (18): DungeonGenerator, Affix, Enemy, Rarity, State, Interactable, Kind, Kind (+10 more)

### Community 28 - "Character Creation UI"
Cohesion: 0.17
Nodes (18): _apply_recommended, _build_attributes, _build_class_list, _build_name_page, _build_page, _build_race_list, _build_attributes Function, _build_class_list Function (+10 more)

### Community 29 - "README - Races"
Cohesion: 0.12
Nodes (17): Alto Elfo (race), Anao da Montanha (race), Anao das Colinas (race), Character Creation, Draconato (race), Drow (race), Dungeons & Dragons, Elfo da Floresta (race) (+9 more)

### Community 30 - "Character Creation Logic"
Cohesion: 0.16
Nodes (17): _attr_info_text, _bonus_text, _build_free_bonus, _can_continue Function, _cell, _change Function, _class_info_text, COST Constant (+9 more)

### Community 31 - "Territories & Quest Objectives"
Cohesion: 0.23
Nodes (16): Alto Elfo Territory, Anão Colinas Territory, Anão Montanha Territory, Draconato Territory, Drow Territory, Elfo Floresta Territory, Gnomo Territory, Golias Territory (+8 more)

### Community 32 - "Scene Nodes (Enemy/Player)"
Cohesion: 0.12
Nodes (16): CircleShape2D_body, CollisionShape2D, Enemy, enemy.gd, Sprite, Visual, Body, Camera2D (+8 more)

### Community 33 - "Quest Log & Progression"
Cohesion: 0.20
Nodes (16): quest, DB.quest_ids, quests, Game.quests, QuestLog._check_stage, QuestLog._complete, QuestLog._event, QuestLog.is_completed (+8 more)

### Community 34 - "Arcane Blade Skills (Lâmina Arcana)"
Cohesion: 0.22
Nodes (15): Arcane Element, Ice Element, Lightning Element, AoE Kind (7), Basic Attack Kind (0), Blast Kind (2), Mobility Kind (4), Projectile Kind (14) (+7 more)

### Community 35 - "README - Classes"
Cohesion: 0.13
Nodes (15): Barbaro (class), Bardo (class), Bruxo (class), Cacador (class), Class System (14 classes), Clerigo (class), Druida (class), Feiticeiro (class) (+7 more)

### Community 36 - "Weather & Wind Systems"
Cohesion: 0.22
Nodes (14): Weather._day_hash, Weather.forecast, Weather.rain_on, Weather, Weather.world_seed, WindField._rand, WindField.add_calm, WindField.at (+6 more)

### Community 37 - "Inventory Grid Logic"
Cohesion: 0.21
Nodes (14): add, can_place, changed, find_space, in_bounds, item_at, items, load_array (+6 more)

### Community 38 - "HUD & Unified Panels"
Cohesion: 0.27
Nodes (8): CharacterPanel, _build(), HUD, _toggle_unified(), InventoryPanel, QuestPanel, SkillsPanel, UnifiedPanel

### Community 39 - "README - World & Dungeons"
Cohesion: 0.23
Nodes (13): Azkhar (world boss), Campfire System, Distance-Based Difficulty, Procedural Dungeon System, Enemy System (36 enemy types), Mercador Bartolomeu, Ogro (world boss), Overworld (chunk-based open world) (+5 more)

### Community 40 - "Territory NPCs & Races DB"
Cohesion: 0.26
Nodes (12): get_race, races, territories, territory, Hero.from_dict, TerritoryNpcs._commoner_dialogue, TerritoryNpcs._ensure_dialogues, TerritoryNpcs._id (+4 more)

### Community 41 - "Character Creation Flow"
Cohesion: 0.21
Nodes (12): _can_continue, Game Singleton Reference, _go_step, _go_step Function, _on_back, _on_next, _on_start, _on_back Function (+4 more)

### Community 42 - "Mage Skills & Arcane Magic"
Cohesion: 0.47
Nodes (11): Arcane Element, Explode Sound, Mage Skill Kind, Magic Sound, Mago, Dobra Temporal, Míssil Arcano, Orbe Desintegrador (+3 more)

### Community 43 - "Item Generation & Loot Tables"
Cohesion: 0.25
Nodes (11): AFFIXES, BASES, create_item, LEGENDARY_NAMES, PREFIXES, random_base, random_base_for, roll_item (+3 more)

### Community 44 - "Lore & Mechanics Docs (PT)"
Cohesion: 0.20
Nodes (10): Eldara (mundo), Os Oito Mistérios, Os 14 Territórios, Áudio adaptativo (§15), Clima e partículas por bioma, Determinismo por semente (world_seed), Territórios Raciais (Voronoi procedural, 14 capitais), WindField (campo de vento global) (+2 more)

### Community 45 - "Deep Lore (Kinfire/Maldrach)"
Cohesion: 0.24
Nodes (10): Ithariel, o Cinzento, Kinfire (Fogueira dos Laços), Maldrach, o Unificador do Vazio, Masmorras-Chama, Primeira Chama, As Sete Relíquias (Chaves), As Sete Chamas, Os Sete Primeiros Laços (+2 more)

### Community 46 - "Mechanics & Design Docs"
Cohesion: 0.27
Nodes (10): LORE.md — Bíblia Narrativa Canônica, FSR 2.2 + MSAA (escala de vídeo), MECANICAS.md — Documento Técnico Canônico, QuestData (sistema de missões), QuestLog (estado das quests no Game), Sombras dinâmicas 2D (PointLight2D + LightOccluder2D), D8: profundidade do lore, D9: renderização premium (RT/DLSS → equivalentes 2D) (+2 more)

### Community 47 - "Market & Vendor Economy"
Cohesion: 0.40
Nodes (10): vendor, Game.market, Market.buy_price, Market.category_of, Market.demand, Market, Market.natural, Market.new_day (+2 more)

### Community 48 - "Auction House & Time"
Cohesion: 0.31
Nodes (10): Game.auction, Game.world_time, Auction._ensure, Auction._roll, Auction._roll_base, Auction, Auction.min_bid, Auction.slots (+2 more)

### Community 49 - "Status Effects & Damage"
Cohesion: 0.20
Nodes (10): apply_slow, confuse, curse, fear, stun, take_damage, deal_damage, _deliver (+2 more)

### Community 50 - "Character Creation UI Helpers"
Cohesion: 0.29
Nodes (10): _apply_recommended Function, _build_nav_bar, _build_side_panel, _build_nav_bar Function, _build_side_panel Function, cls Variable, _floor_strip, _ready Function (+2 more)

### Community 51 - "README - Data Architecture"
Cohesion: 0.42
Nodes (9): ClassData (.tres), Data/Action Separation (RPG sheet vs game physics), DB Autoload, EnemyData (.tres), data/index.json (load order), Projectile, RaceData (.tres), SkillData (.tres, 15 skill types) (+1 more)

### Community 52 - "Overworld Day/Night & Territories"
Cohesion: 0.25
Nodes (9): _day_color, danger, _process, _rebuild_astar, _update_daylight, near_any_capital, region_level, region_name_at (+1 more)

### Community 53 - "HUD Buffs & Vitals"
Cohesion: 0.31
Nodes (7): BuffChip, _build_bottom_bar(), _process(), LevelBadge, SkillSlot, refresh(), VitalsBar

### Community 54 - "Lore - Ignorância & Véu"
Cohesion: 0.36
Nodes (8): Show, Don't Tell (guia de escrita), Ignorância (mecânica narrativa), Laço-Vivo (jogador), Vale Cinzento, Véu da Discórdia, DialogueData (grafo de diálogo), Ignorância (sistema de diálogo), Ignorância (regra §2)

### Community 55 - "README - Biomes"
Cohesion: 0.25
Nodes (8): Areias Escaldantes (biome), Biome System (7 noise-based biomes), Ermos Vulcanicos (biome), Floresta Sussurrante (biome), Pantano Putrido (biome), Planicies (biome), Terras Corrompidas (biome), Tundra Congelada (biome)

### Community 56 - "DB Loader & Loot Tables"
Cohesion: 0.25
Nodes (8): _build_loot_tables, _load_dir, _ready, get_skill, loot_tables, racial_breath, vendors, villager_class

### Community 57 - "Warlock Skills (Bruxo)"
Cohesion: 1.00
Nodes (7): Bruxo, Drenar Alma, Familiar Demoníaco, Maldição da Agonia, Portal Infernal, Raio Sombrio, Rajada Mística

### Community 58 - "Racial Skill - Dragon Breath"
Cohesion: 0.29
Nodes (7): Armor Ignoring Damage, Cone Attack Pattern, Explode Sound Effect, Fire Element, Knockback Effect, SkillData, Sopro Dracônico

### Community 59 - "Mechanics - Essence & Rarity"
Cohesion: 0.33
Nodes (7): Essência (moeda dos demônios), Afixos de Campeão/Lendário, Rarity (enum de raridade de monstro), Dificuldades do jogo (§7), Ouro e Essência (§9), Morte, renascimento e hardcore (§5), Raridades de monstros e drops (§6)

### Community 60 - "Economy - Auction & Reputation"
Cohesion: 0.33
Nodes (7): Casa de leilões, Preço dinâmico (oferta/demanda), Reputação por raça (tiers), VendorData (estoque rotativo), D2: escopo completo da economia, Economia e mercado (§10), Reputação e descontos (§10/§11)

### Community 61 - "Character Creation Scene"
Cohesion: 0.29
Nodes (7): CharacterCreation Node, CharacterCreation Class, _current_tint, POINT_BUY_TOTAL, _step Variable, STEPS Constant, TINTS Constant

### Community 62 - "Overworld Generation & Weather"
Cohesion: 0.33
Nodes (7): Cinzento, OverworldGen, Overworld, _update_atmos, Territories, configure, WeatherLayer

### Community 63 - "Loot Drop System"
Cohesion: 0.29
Nodes (7): drop_essence, drop_globe, drop_gold, drop_item, _on_enemy_killed, _on_enemy_killed, roll_loot_item

### Community 64 - "Prologue & Cinzento Events"
Cohesion: 0.47
Nodes (6): appear_at, _advance, _on_hero_leveled_up, _on_mirror, _process, _whisper

### Community 65 - "Lore - Endings & Truth Fragments"
Cohesion: 0.40
Nodes (5): A Fenda, Final Cinzento, Final Dourado, Fragmentos da Verdade, Quests e Fragmentos (§12)

### Community 66 - "Design Tokens & HUD"
Cohesion: 0.50
Nodes (4): Design tokens dark-fantasy premium (§9.1), HUD moderna (§9.2), D1: ui-ux-pro-max-cli bloqueado, audit manual, D7: direção visual da UI moderna

### Community 67 - "Tutorial & Progression"
Cohesion: 0.50
Nodes (4): Prólogo/Reminiscência (tutorial), Auditoria Fase 0.2 (§16), Progressão (XP 20×nível^1.5), Prólogo — regras (§13)

### Community 68 - "DB Sprite & Texture Assets"
Cohesion: 0.67
Nodes (4): _decompressed, dt2_texture, frames, sprite

### Community 69 - "Campfire & Rest System"
Cohesion: 0.50
Nodes (4): light_campfire, _offer_sleep, _on_campfire_lit, _sleep_until_dawn

### Community 70 - "World Hazard Zones"
Cohesion: 0.50
Nodes (4): apply_poison, add_fire_zone, add_slow_zone, _process

### Community 71 - "HUD Clock & Minimap"
Cohesion: 0.67
Nodes (4): ClockChip, _build_top(), _layout(), Minimap

### Community 72 - "Enemy & Boss Database"
Cohesion: 0.67
Nodes (3): bosses, enemies, get_enemy

### Community 73 - "SFX Pool & Sounds"
Cohesion: 0.67
Nodes (3): _ready, POOL_SIZE, SOUNDS

### Community 74 - "Damage Numbers"
Cohesion: 0.67
Nodes (3): DamageNumber, spawn, spawn_text

### Community 75 - "Trade Panel UI"
Cohesion: 1.00
Nodes (3): _on_trade_requested(), open_trade(), TradePanel

## Ambiguous Edges - Review These
- `Bree dialogue node: sopa` → `O Véu (The Veil)`  [AMBIGUOUS]
  data/dialogues/bree_cozinheira.tres · relation: conceptually_related_to
- `O Espelho que Mostra o Futuro (ato3_2)` → `Espelho de Miragem`  [AMBIGUOUS]
  data/quests/ato3_2.tres · relation: semantically_similar_to
- `Cooldown Resource Management` → `Chama Sagrada Skill Data`  [AMBIGUOUS]
  data/skills/clerigo/chama_sagrada.tres · relation: references
- `Cooldown Resource Management` → `Golpe Sagrado Skill Data`  [AMBIGUOUS]
  data/skills/clerigo/golpe_sagrado.tres · relation: references
- `Cooldown Resource Management` → `Espinhos Skill Data`  [AMBIGUOUS]
  data/skills/druida/espinhos.tres · relation: references

## Knowledge Gaps
- **591 isolated node(s):** `Godot 4.7`, `Baldur's Gate`, `Minecraft`, `0x72 DungeonTileset II (CC0)`, `7Soul1 496 RPG Icons (CC0)` (+586 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 743 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **260 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What is the exact relationship between `Bree dialogue node: sopa` and `O Véu (The Veil)`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `O Espelho que Mostra o Futuro (ato3_2)` and `Espelho de Miragem`?**
  _Edge tagged AMBIGUOUS (relation: semantically_similar_to) - confidence is low._
- **What is the exact relationship between `Cooldown Resource Management` and `Chama Sagrada Skill Data`?**
  _Edge tagged AMBIGUOUS (relation: references) - confidence is low._
- **What is the exact relationship between `Cooldown Resource Management` and `Golpe Sagrado Skill Data`?**
  _Edge tagged AMBIGUOUS (relation: references) - confidence is low._
- **What is the exact relationship between `Cooldown Resource Management` and `Espinhos Skill Data`?**
  _Edge tagged AMBIGUOUS (relation: references) - confidence is low._
- **Why does `SkillData` connect `Classes & Skills (Physical)` to `Story & Quest Narrative`, `Arcane Blade Skills (Lâmina Arcana)`, `NPCs & Races Data`, `Mage Skills & Arcane Magic`, `Cleric & Druid Skills (Holy/Nature)`, `Hunter Skills & Mechanics`, `Warrior Skills & Mechanics`, `Warlock Skills (Bruxo)`?**
  _High betweenness centrality (0.046) - this node is a cross-community bridge._
- **Why does `RaceData` connect `NPCs & Races Data` to `Races & Character Creation`?**
  _High betweenness centrality (0.026) - this node is a cross-community bridge._