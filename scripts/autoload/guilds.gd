extends Node

var guild_cache: Dictionary = {}

func _ready() -> void:
	_preload_guild_data()

func _preload_guild_data() -> void:
	# Gera 56 guildas dinamicamente (14 classes × 4 tipos)
	var classes = ["humano", "barbaro", "alto_elfo", "elfo_floresta", "drow",
		"anao_montanha", "anao_colinas", "halfling", "meio_orc", "tiefling",
		"draconato", "gnomo", "meio_elfo", "tabaxi"]
	var tipos_map = {
		"aventureiros": GuildData.Type.AVENTUREIROS,
		"mercadores": GuildData.Type.MERCADORES,
		"artesaos": GuildData.Type.ARTESAOS,
		"sombras": GuildData.Type.SOMBRAS
	}
	
	for cls in classes:
		for tipo_str in tipos_map.keys():
			var guild = GuildData.new()
			guild.id = StringName("%s_%s" % [tipo_str, cls])
			guild.display_name = "Guilda %s" % tipo_str
			guild.tipo = tipos_map[tipo_str]
			guild.mestre_npc = StringName("npc_%s" % tipo_str)
			guild.beneficios = {}
			guild_cache[guild.id] = guild

func guild(guild_id: StringName) -> GuildData:
	return guild_cache.get(guild_id)

func get_player_guild(hero: Hero) -> PlayerGuild:
	if hero.player_guild_id != &"":
		return Game.player_guilds.get(hero.player_guild_id) if Game.player_guilds else null
	return null
