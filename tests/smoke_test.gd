extends Node
## Teste de fumaça automatizado. Execute com:
##   godot --headless --path . -- --smoke
## Percorre menus, cria um herói de cada classe, usa todas as habilidades,
## mexe no inventário e desce um nível. Erros aparecem no console.


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_run.call_deferred()


## Salva screenshot se SMOKE_SHOTS apontar para uma pasta
func _shot(shot_name: String) -> void:
	var dir := OS.get_environment("SMOKE_SHOTS")
	if dir == "" or DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(dir.path_join(shot_name + ".png"))


func _wait(t: float) -> void:
	await get_tree().create_timer(t, true, false, true).timeout


func _run() -> void:
	print("[smoke] migracao v3 -> v4")
	var v3_save := {"version": 3, "depth": 2, "hero": {"name": "Velho", "race": "humano", "class": "guerreiro", "level": 5},
		"world_seed": 7, "world_time": 0.5, "in_dungeon": false}
	var v4_save: Dictionary = Game._migrate(v3_save)
	assert(int(v4_save.version) == 4)
	assert(v4_save.phase == Game.PHASE_CREATED)
	assert(int(v4_save.ignorance) == 0)
	assert(v4_save.hero.level == 5 and v4_save.world_seed == 7)  # nada perdido
	print("[smoke] aldeao do prologo")
	var villager := Hero.create_villager()
	assert(villager.level == 0 and villager.cls.id == &"aldeao")
	assert(villager.xp_to_next() == 20)
	assert(villager.skill_bar[0] == &"golpe_de_lenhador")
	villager.add_xp(20)
	assert(villager.level == 1 and villager.unspent_points == 1)
	print("[smoke] menu principal")
	await _wait(2.5)
	await _shot("01_menu")
	var menu := get_tree().current_scene
	menu._on_credits()
	await _wait(1.5)
	await _shot("01b_creditos")
	menu._on_options()
	await _wait(0.5)
	await _shot("01c_opcoes")
	Game.change_scene(Game.CHARACTER_CREATION)
	await _wait(1.5)
	await _shot("02_criacao")
	var cc := get_tree().current_scene
	cc._randomize()
	await _wait(0.5)
	await _shot("02b_criacao_aleatorio")
	print("[smoke] criação de personagem ok")
	await _test_prologue()
	await _test_dialogue()
	await _test_overworld()

	for i in DB.classes.size():
		var cls: ClassData = DB.classes[i]
		var race: RaceData = DB.races[i % DB.races.size()]
		var h := Hero.create("Teste", race, cls, ["m", "f"][i % 2], Color.WHITE, {"str": 14, "dex": 14, "con": 14, "int": 12, "wis": 12, "cha": 10}, {"con": 1}, DB.BACKGROUNDS.keys()[i % DB.BACKGROUNDS.size()], i % 4, false)
		h.level = 10
		h.refresh_skill_bar()
		Game.hero = h
		Game.depth = 3 if i == 0 else 1
		Game.in_dungeon = true
		Game.dungeon_level = 1 + i % 3
		Game.dungeon_name = "Masmorra de Teste"
		Game.change_scene(Game.WORLD)
		await _wait(1.5)
		var world: World = get_tree().get_first_node_in_group("world")
		assert(world != null)
		var p := world.player
		if i == 0 or i == 4 or i == 9:
			await _shot("03_jogo_%d" % i)
		print("[smoke] %s/%s em jogo — inimigos: %d" % [race.display_name, cls.display_name, get_tree().get_nodes_in_group("enemies").size()])
		for s in cls.skills:
			p.cooldowns.clear()
			p.resource = p.max_resource
			p.state = Player.State.IDLE
			var target := p.global_position + Vector2(40, 0)
			var e := _nearest_enemy(world, p.global_position)
			if e:
				p.global_position = world.last_free_point(e.global_position, e.global_position + Vector2(20, 0))
				target = e.hit_center()
			var slot := h.skill_bar.find(s.id)
			if slot < 0:
				h.assign_skill(2, s.id)
				slot = 2
			print("[smoke]   skill ", s.id)
			p._request_cast(slot, target)
			await _wait(0.7)
			if (i == 4 or i == 5 or i == 9) and s == cls.skills[4]:
				await _shot("04_combate_%d" % i)
		if h.racial_skill():
			p.cooldowns.clear()
			p._request_cast(Player.RACIAL_SLOT, p.global_position + Vector2(30, 0))
			await _wait(0.4)
		print("[smoke]   pocao/inventario")
		p.use_potion()
		p.add_buff("damage", 0.3, 2.0, "Teste", Color.RED)
		# Inventário e equipamento
		for k in 8:
			h.inventory.add(DB.roll_item(5, 0.5, cls))
		for it in h.inventory.items.duplicate():
			if h.equip_problem(it) == "":
				world.hud.inventory.equip_from_inventory(it)
				break
		var hud := world.hud
		hud.toggle_inventory()
		hud.toggle_character()
		hud.toggle_skills()
		await _wait(0.3)
		if i == 0:
			await _shot("05_paineis")
			_report_wide(hud.skills, 0)
			hud.toggle_skills()
			await _wait(0.2)
			await _shot("05b_inventario")
			hud.toggle_skills()
			if OS.get_environment("SMOKE_QUICK") != "":
				get_tree().quit()
		if not h.inventory.items.is_empty():
			hud.inventory.equip_from_inventory(h.inventory.items[0])
		hud.inventory._sell_junk()
		h.add_xp(5000)
		h.spend_point("str")
		await _wait(0.3)
		hud.toggle_inventory()
		hud.toggle_character()
		hud.toggle_skills()
		print("[smoke]   loot")
		# Mata inimigos para gerar loot
		for k in 3:
			LootDrop.drop_item(world, p.global_position + Vector2(0, 20), DB.roll_item(5, 0.8))
		for e in world.enemies_near(p.global_position, 99999.0).slice(0, 12):
			e.take_damage(999999.0, true, p.global_position, 50.0)
		await _wait(1.0)
		if i == 0:
			await _shot("06_loot")
		for n in get_tree().get_nodes_in_group("interactables"):
			if n is LootDrop:
				n.interact(p)
				break
		for n in get_tree().get_nodes_in_group("interactables"):
			if n is Interactable and n.kind in [Interactable.Kind.CHEST, Interactable.Kind.SHRINE]:
				n.interact(p)
		await _wait(0.5)
		print("[smoke]   morte")
		# Dano e morte (desativa passivas que evitam a morte)
		p.cheat_death_cd = 999.0
		p.auto_dodge_cd = 999.0
		p._invuln = 0.0
		p.take_damage(999999.0)
		if not p.is_dead():
			p._die()
		await _wait(0.6)
		world.respawn_player()
		if hud._death_layer:
			hud._death_layer.queue_free()
			hud._death_layer = null
		hud.toggle_pause()
		await _wait(0.3)
		hud.toggle_pause()
		Game.save_game()

	print("[smoke] descendo")
	Game.descend()
	await _wait(1.5)
	assert(Game.load_game())
	Game.quit_to_menu()
	await _wait(1.5)
	print("[smoke] SMOKE OK")
	get_tree().quit()


func _test_prologue() -> void:
	print("[smoke] prologo")
	Game.delete_save()
	Game.new_prologue()
	await _wait(2.5)
	var pro: Prologue = get_tree().current_scene
	assert(pro is Prologue)
	assert(Game.phase == Game.PHASE_PROLOGUE)
	assert(Game.hero.level == 0 and Game.hero.cls.id == &"aldeao")
	assert(pro._gate_wall != null)
	print("[smoke]   prologo carregou — passo %d" % pro.tut_step)
	# Passo 1: mover
	pro._moved = Prologue.MOVE_DIST
	await _wait(0.3)
	assert(pro.tut_step == Prologue.TutStep.ATTACK)
	# Passo 2: atacar — espantalho cai e solta a Espada de Treino
	pro._espantalho.take_damage(999999.0, true, Vector2.ZERO, 0.0)
	await _wait(0.5)
	assert(pro.tut_step == Prologue.TutStep.COLLECT)
	# Passo 3: coletar a Espada de Treino
	var sword: Item = null
	for n in get_tree().get_nodes_in_group("interactables"):
		if n is LootDrop and n.item and n.item.base_id == &"wood_sword":
			sword = n.item
			n.interact(pro.player)
			break
	assert(sword != null)
	await _wait(0.3)
	assert(pro.tut_step == Prologue.TutStep.EQUIP)
	print("[smoke]   atacar/coletar ok")
	# Passo 4: equipar
	pro.hud.inventory.equip_from_inventory(sword)
	await _wait(0.3)
	assert(pro.tut_step == Prologue.TutStep.POTION)
	assert(Game.hero.equipment.weapon != null)
	# Passo 5: poção
	pro.player.potion_cd = 0.1
	await _wait(0.3)
	assert(pro.tut_step == Prologue.TutStep.CAMPFIRE)
	# Passo 6: fogueira — portão de névoa abre e lobos surgem na floresta
	var fire: Interactable = null
	for n in get_tree().get_nodes_in_group("interactables"):
		if n is Interactable and n.kind == Interactable.Kind.CAMPFIRE:
			fire = n
			break
	assert(fire != null)
	fire.interact(pro.player)
	await _wait(0.3)
	assert(pro.tut_step == Prologue.TutStep.DONE)
	print("[smoke]   tutorial completo — portao aberto")
	# As duas lutas: lobos dão XP para alcançar o nível 1
	var wolves := 0
	for e in pro.enemies_near(pro.player.global_position, 99999.0):
		if e.data.id == &"lobo_sombrio":
			wolves += 1
	assert(wolves >= 3)
	for e in pro.enemies_near(pro.player.global_position, 99999.0):
		if e.data.id == &"lobo_sombrio":
			e.take_damage(999999.0, true, Vector2.ZERO, 0.0)
	await _wait(1.0)
	assert(Game.hero.level == 1)
	assert(pro._level1_seen)
	print("[smoke]   nivel 1 alcancado (%d lobos)" % wolves)
	# Save v4 do prólogo sobrevive a um roundtrip
	Game.save_game()
	assert(Game.load_game())
	assert(Game.phase == Game.PHASE_PROLOGUE and Game.hero.level == 1)
	# Espelho: nível 1 + tutorial completo → cutscene → criação (MECANICAS §11)
	var mirror: Interactable = null
	for n in get_tree().get_nodes_in_group("interactables"):
		if n is Interactable and n.kind == Interactable.Kind.MIRROR:
			mirror = n
			break
	assert(mirror != null)
	mirror.interact(pro.player)
	await _wait(5.0)
	var cc := get_tree().current_scene
	assert(cc != null and cc.has_method("_on_start") and cc.has_method("_on_next"))
	assert(Game.phase == Game.PHASE_PROLOGUE)
	print("[smoke]   espelho -> criacao de personagem")
	# Wizard sequencial: raça → classe → atributos (27 pts) → nome — todos obrigatórios
	cc._randomize()
	assert(cc._step == 0 and cc._can_continue())
	cc._on_next()
	assert(cc._step == 1 and cc._can_continue())
	cc._on_next()
	assert(cc._step == 2 and cc._can_continue())
	cc._on_next()
	assert(cc._step == 3 and cc._can_continue())
	cc._on_next()  # passo final = _on_start → finish_prologue
	await _wait(3.0)
	assert(Game.phase == Game.PHASE_CREATED)
	assert(Game.ignorance == 10)
	assert(Game.hero.level == 1 and Game.hero.cls.id != &"aldeao")
	var ow := get_tree().get_first_node_in_group("world")
	assert(ow != null and ow.has_method("travel_to"))
	assert(Game.awakened_from_prologue == false)  # diálogo de despertar consumido pela 1.5
	print("[smoke]   wizard concluido — %s %s acorda no acampamento" % [Game.hero.race.display_name, Game.hero.cls.display_name])
	# 2.2: diálogo ramificado real do despertar, via DialogueBox/UI (motor)
	var box: DialogueBox = ow.hud._dialogue_box
	assert(box != null and box.engine.current != null)
	box.engine.advance()  # acorda: página 2
	box.engine.advance()  # -> escolhas (ignorância 10 > 5: versão leiga, 2 visíveis)
	assert(box.engine.visible_choices().size() == 2)
	box.engine.choose(0)  # "O que é este lugar?" -> ignorancia -1
	assert(Game.ignorance == 9 and box.engine.current.id == &"lugar")
	box.engine.advance()  # lugar: 1 página -> escolhas
	box.engine.choose(0)  # "…e o que aconteceu comigo?"
	assert(box.engine.current.id == &"aconteceu")
	box.engine.advance()  # aconteceu: página 2
	box.engine.advance()  # -> escolhas
	box.engine.choose(0)  # "E agora?" -> adeus
	assert(box.engine.current.id == &"adeus")
	box.engine.advance()  # adeus: 1 página -> escolhas
	box.engine.choose(0)  # "(Partir)" -> encerra + flag
	assert(box.engine.current == null)
	assert(bool(Game.flags.get("cinzento_primeiro_dialogo", false)))
	await _wait(1.0)
	assert(ow.hud._dialogue_box == null)  # caixa fechou e se libertou
	print("[smoke]   dialogo de despertar concluido (ignorancia %d)" % Game.ignorance)
	print("[smoke] prologo ok")


func _test_dialogue() -> void:
	print("[smoke] dialogo")
	# Herói de teste com ignorância alta (versão "leiga" dos diálogos)
	var hero := Hero.create("Testador", DB.races[0], DB.classes[0], "m", Color.WHITE, {"str": 14, "dex": 12, "con": 14, "int": 10, "wis": 10, "cha": 10})
	Game.hero = hero
	Game.ignorance = 10
	Game.reputation = {}
	Game.flags = {}
	var gold_before := hero.gold
	# Grafo: raiz (2 páginas) -> escolhas condicionais -> nó final sem escolhas
	var n_root := DialogueNode.new()
	n_root.id = &"raiz"
	n_root.pages = PackedStringArray(["Primeira página.", "Segunda página."])
	var c_ignorante := DialogueChoice.new()
	c_ignorante.text = "O que é uma guilda?"
	c_ignorante.next_id = &"explica"
	c_ignorante.condition = "ignorancia > 5"
	c_ignorante.effects = "ignorancia -1\nflag perguntou_guilda\ngold 25\nrep humano +1"
	var c_sabido := DialogueChoice.new()
	c_sabido.text = "Sigo meu caminho."
	c_sabido.condition = "ignorancia <= 5"
	n_root.choices = [c_ignorante, c_sabido]
	var n_explica := DialogueNode.new()
	n_explica.id = &"explica"
	n_explica.text = "É onde gente de ofício se junta — e onde memória vira salário."
	var d := DialogueData.new()
	d.id = &"teste"
	d.portrait = "k:121"
	d.start_id = &"raiz"
	d.nodes = [n_root, n_explica]
	# Motor: paginação
	var eng := DialogueEngine.new()
	# Lambdas capturam locais POR VALOR: mutações (append/índice) são visíveis
	# fora, mas rebinding (x = ...) não — por isso o estado vai num Dictionary.
	var st := {"pages": [], "choices": [], "ended": false}
	eng.page_shown.connect(func(t: String, portrait: String): st["pages"].append([t, portrait]))
	eng.choices_shown.connect(func(cs: Array): st["choices"] = cs)
	eng.dialogue_ended.connect(func(): st["ended"] = true)
	eng.start(d)
	assert(st["pages"].size() == 1 and st["pages"][0][0] == "Primeira página." and st["pages"][0][1] == "k:121")
	eng.advance()
	assert(st["pages"].size() == 2 and st["pages"][1][0] == "Segunda página.")
	# Escolhas: ignorância 10 > 5 -> só a versão leiga é visível
	eng.advance()
	assert(st["choices"].size() == 1 and st["choices"][0].text == "O que é uma guilda?")
	# Efeitos: ignorância, flag, ouro, reputação
	eng.choose(0)
	assert(Game.ignorance == 9)
	assert(bool(Game.flags.get("perguntou_guilda", false)))
	assert(hero.gold == gold_before + 25)
	assert(int(Game.reputation.get(&"humano", 0)) == 1)
	assert(st["pages"].size() == 3 and st["pages"][2][0] == "É onde gente de ofício se junta — e onde memória vira salário.")
	# Nó sem escolhas: advance na única página encerra
	assert(not st["ended"])
	eng.advance()
	assert(st["ended"])
	# Condições do resolver: raca/classe/item/nivel/negacao/AND
	assert(ConditionResolver.eval("raca = %s" % hero.race.id))
	assert(ConditionResolver.eval("classe = %s" % hero.cls.id))
	assert(not ConditionResolver.eval("raca = %s" % hero.race.id + ", !flag perguntou_guilda"))
	assert(ConditionResolver.eval("flag perguntou_guilda, ignorancia <= 9"))
	assert(ConditionResolver.eval("nivel >= 1, item wood_sword"))
	assert(not ConditionResolver.eval("item espada_inexistente"))
	assert(ConditionResolver.eval(""))
	print("[smoke] dialogo ok")


func _test_overworld() -> void:
	var h := Hero.create("Explorador", DB.races[0], DB.classes[3], "m", Color.WHITE, {"str": 15, "dex": 13, "con": 14, "int": 12, "wis": 10, "cha": 8})
	h.level = 8
	h.refresh_skill_bar()
	Game.new_game(h)
	await _wait(2.5)
	var ow: Overworld = get_tree().get_first_node_in_group("world")
	assert(ow != null)
	print("[smoke] mundo aberto: chunks=%d inimigos=%d" % [ow.chunks.size(), get_tree().get_nodes_in_group("enemies").size()])
	# 2.3: NPCs conversáveis — ignorância decai, NPCs lembram (flags), reputação por raça
	Game.ignorance = 10
	var marn: Npc = null
	var bree: Npc = null
	for n in get_tree().get_nodes_in_group("npcs"):
		if n is Npc:
			if n.data.id == &"marn_vigia":
				marn = n
			elif n.data.id == &"bree_cozinheira":
				bree = n
	assert(marn != null and bree != null)
	assert(marn.display_name() == "Marn — Vigia do Acampamento")
	# hover duck-typed: o mundo encontra o NPC como interactable
	assert(ow.get_interactable_at(marn.global_position + Vector2(0, -8)) == marn)
	marn.interact(ow.player)
	var box: DialogueBox = ow.hud._dialogue_box
	assert(box != null and box.engine.current.id == &"inicio")
	# primeira conversa: só "(Cumprimentar)" (flag não setada)
	assert(box.engine.visible_choices().size() == 1)
	box.engine.advance()  # 1 página: advance arma as escolhas
	box.engine.choose(0)
	assert(box.engine.current.id == &"apresentacao" and bool(Game.flags.get("marn_apresentado", false)))
	box.engine.advance()
	box.engine.advance()
	assert(box.engine.visible_choices().size() == 1)  # (Continuar)
	box.engine.choose(0)
	assert(box.engine.current.id == &"menu")
	# ignorância 10: lugar, territórios (leigo), promessa, partir — patrulla fica oculta
	var vc := box.engine.visible_choices()
	assert(vc.size() == 4)
	box.engine.advance()  # menu 1 página -> escolhas
	box.engine.choose(2)  # "O acampamento está seguro comigo."
	assert(bool(Game.flags.get("marn_promessa", false)))
	assert(int(Game.reputation.get(&"humano", 0)) == 1)
	assert(box.engine.current.id == &"promessa")
	box.engine.advance()
	box.engine.choose(1)  # (Partir)
	await _wait(1.2)
	assert(ow.hud._dialogue_box == null)
	# segunda conversa: Marn lembra — "(Falar de novo)"; promessa já feita some do menu
	marn.interact(ow.player)
	box = ow.hud._dialogue_box
	assert(box.engine.visible_choices().size() == 1 and box.engine.visible_choices()[0].text == "(Falar de novo)")
	box.engine.advance()  # 1 página -> escolhas
	box.engine.choose(0)
	assert(box.engine.current.id == &"menu" and box.engine.visible_choices().size() == 3)
	box.engine.advance()  # menu 1 página -> escolhas
	box.engine.choose(1)  # "O que são 'territórios'?" (leigo) -> ignorância decai
	assert(Game.ignorance == 9 and box.engine.current.id == &"territorios")
	box.engine.stop()
	await _wait(1.2)
	assert(ow.hud._dialogue_box == null)
	# Bree: sopa de cortesia (uma única vez, flag-gated)
	bree.interact(ow.player)
	box = ow.hud._dialogue_box
	assert(box.engine.visible_choices().size() == 2)  # sopa + cumprimentar
	box.engine.advance()  # inicio: página 1 -> 2
	box.engine.advance()  # página 2 -> escolhas armadas
	box.engine.choose(0)
	assert(bool(Game.flags.get("bree_sopa", false)) and box.engine.current.id == &"sopa")
	box.engine.advance()
	box.engine.advance()
	box.engine.choose(1)  # (Partir)
	await _wait(1.2)
	assert(ow.hud._dialogue_box == null)
	print("[smoke]   npcs conversam (ignorancia %d, rep humano %d)" % [Game.ignorance, int(Game.reputation.get(&"humano", 0))])
	# 2.4: territórios raciais — 14 capitais, Voronoi determinístico, Vale neutro
	var terr: Territories = ow.territories
	assert(terr != null and terr.capitals.size() == 14)
	# capital do jogador na origem; acampamento promovido a capital
	assert(terr.capital_of(h.race.id) == Vector2.ZERO)
	var camp := ""
	for n in get_tree().get_nodes_in_group("interactables"):
		if n is Interactable and n.kind == Interactable.Kind.CAMPFIRE:
			camp = n.label
	assert(camp == DB.territory(h.race.id).capital_name)
	# espaçamento mínimo garantido + sem líquido + bioma válido
	var races_list: Array = terr.capitals.keys()
	var og := ow.og
	for i in races_list.size():
		var ci: Vector2 = terr.capitals[races_list[i]]
		var biome: String = og.biome_at(Vector2i(roundi(ci.x), roundi(ci.y)))
		assert(not og.liquid_at(Vector2i(roundi(ci.x), roundi(ci.y)), biome))
		for j in range(i + 1, races_list.size()):
			assert(ci.distance_to(terr.capitals[races_list[j]]) >= Territories.CAPITAL_MIN_GAP)
		# a vizinhança da capital pertence ao seu território (nome da capital na HUD)
		assert(terr.region_name_at(Vector2i(roundi(ci.x), roundi(ci.y))).begins_with(DB.territory(races_list[i]).capital_name))
	# Vale do Centro: neutro até o raio, território de alguém depois
	assert(terr.territory_at(Vector2i(30, 0)) == &"")
	assert(terr.territory_at(Vector2i(50, 0)) != &"")
	assert(terr.region_name_at(Vector2i(30, 0)) == "Vale do Centro — a Kinfire apagada" or terr.region_name_at(Vector2i(30, 0)).begins_with(DB.territory(h.race.id).capital_name))
	# determinismo: mesma semente + raça => mesmas capitais
	var terr2 := Territories.new(Game.world_seed, h.race.id)
	for race in terr.capitals:
		assert(terr.capitals[race] == terr2.capitals[race])
	# level_at integra o modificador do território
	assert(ow.level_at(ow.player.global_position) == 1)  # capital: nível 1
	print("[smoke]   territorios ok (%d capitais, gap >= %d)" % [terr.capitals.size(), Territories.CAPITAL_MIN_GAP])
	# 2.5: NPCs por território — líder + gente comum com ganho-de-vida (LORE §X)
	var leader: Npc = null
	var comuns := 0
	for n in get_tree().get_nodes_in_group("npcs"):
		if not n is Npc:
			continue
		if n.data.dialogue_id == &"capital_humano_lider":
			leader = n
		elif n.data.dialogue_id in [&"capital_humano_comum0", &"capital_humano_comum1", &"capital_humano_comum2"]:
			comuns += 1
	assert(leader != null and comuns == 3)
	assert(leader.display_name() == "Guildmaster Eleanor Vane — Líder de Porto Franco")
	leader.interact(ow.player)
	box = ow.hud._dialogue_box
	assert(box.engine.current.id == &"inicio")
	box.engine.advance()  # 1 página -> escolhas
	box.engine.choose(0)  # (Apresentar-se)
	assert(box.engine.current.id == &"apresentacao" and bool(Game.flags.get("capital_humano_apresentado", false)))
	box.engine.advance()  # apresentação: página 2
	box.engine.advance()  # -> escolhas
	box.engine.choose(0)  # (Continuar) -> menu
	assert(box.engine.current.id == &"menu" and box.engine.visible_choices().size() == 5)
	box.engine.advance()  # menu: 1 página -> escolhas
	box.engine.choose(3)  # (Oferecer ajuda ao território)
	assert(bool(Game.flags.get("capital_humano_promessa", false)))
	assert(int(Game.reputation.get(&"humano", 0)) == 2)  # 1 (Marn) + 1 (líder)
	assert(box.engine.current.id == &"promessa")
	box.engine.stop()
	await _wait(1.2)
	assert(ow.hud._dialogue_box == null)
	# território não-jogador: o template gera diálogo coeso a partir do TerritoryData
	TerritoryNpcs.populate(ow, &"drow", ow.player.global_position + Vector2(140, -60))
	var drow: Npc = null
	for n in get_tree().get_nodes_in_group("npcs"):
		if n is Npc and n.data.dialogue_id == &"capital_drow_comum0":
			drow = n
	assert(drow != null)
	drow.interact(ow.player)
	box = ow.hud._dialogue_box
	assert(box.engine.current.id == &"inicio")
	box.engine.advance()  # 1 página -> escolhas
	assert(box.engine.visible_choices().size() == 3)  # trabalho + lugar (leigo) + partir
	box.engine.choose(0)  # "No que você trabalha?"
	assert(box.engine.current.id == &"trabalho")
	assert(box.engine.current.page(0).contains("venenos, seda de aranha-gigante"))  # economia do TerritoryData drow
	box.engine.stop()
	await _wait(1.2)
	assert(ow.hud._dialogue_box == null)
	print("[smoke]   capital povoada (lider + %d comuns, rep humano %d, ignorancia %d)" % [comuns, int(Game.reputation.get(&"humano", 0)), Game.ignorance])
	# 2.6: aceitação da Fase 2 — cada raça com capital, 4 NPCs únicos,
	# diálogo ramificado e economia própria (validação permanente dos templates)
	var races_ok := 0
	for race_res in DB.races:
		var race: RaceData = race_res
		var td: TerritoryData = DB.territory(race.id)
		assert(td != null, "territorio %s ausente" % race.id)
		assert(td.capital_name != "" and td.leader_name != "" and td.economy != "" and td.culture != "",
			"territorio %s com campo vazio" % race.id)
		assert(terr.capital_of(race.id) != Vector2.INF, "capital de %s sem posicao" % race.id)
		TerritoryNpcs._ensure_dialogues(race.id, td)
		for suffix in ["lider", "comum0", "comum1", "comum2"]:
			var dd: DialogueData = DB.dialogue(TerritoryNpcs._id(race.id, suffix))
			assert(dd != null, "dialogo %s/%s nulo" % [race.id, suffix])
			assert(dd.node(dd.start_id) != null, "dialogo %s/%s start quebrado" % [race.id, suffix])
			var has_branch := false
			for n in dd.nodes:
				assert(n.page_count() >= 1, "dialogo %s/%s no %s vazio" % [race.id, suffix, n.id])
				for c in n.choices:
					assert(c.next_id == &"" or dd.node(c.next_id) != null,
						"dialogo %s/%s no %s -> %s inexistente" % [race.id, suffix, n.id, c.next_id])
					if c.condition != "" or c.next_id != &"":
						has_branch = true
			assert(has_branch, "dialogo %s/%s sem ramificacao" % [race.id, suffix])
		races_ok += 1
	assert(races_ok == 14)
	print("[smoke]   aceitacao fase 2: %d racas com capital + 4 NPCs + dialogo ramificado + economia" % races_ok)
	# 3.1: raridades de monstro — multiplicadores, títulos e roll (REGRAS §6)
	var goblin: EnemyData = DB.get_enemy(&"goblin")
	var diff: Dictionary = Game.hero.difficulty_data()
	var base_hp: float = goblin.max_hp * (1.0 + 0.4 * (5 - 1)) * diff.hp
	var e_lend: Enemy = ow.spawn_enemy(goblin, ow.player.global_position + Vector2(2400, 0), Enemy.Rarity.LENDARIO, 5)
	assert(e_lend.rarity == Enemy.Rarity.LENDARIO)
	assert(is_equal_approx(e_lend.max_hp, base_hp * 10.0))
	assert(e_lend.display_name.ends_with(", o Lendário"))
	var e_camp: Enemy = ow.spawn_enemy(goblin, ow.player.global_position + Vector2(2500, 0), Enemy.Rarity.CAMPEAO, 5)
	assert(is_equal_approx(e_camp.max_hp, base_hp * 5.0))
	assert(is_equal_approx(e_camp.damage, goblin.damage * (1.0 + 0.25 * 4.0) * diff.dmg * 1.8))
	assert(e_camp.display_name.begins_with("Campeão "))
	var e_elite: Enemy = ow.spawn_enemy(goblin, ow.player.global_position + Vector2(2600, 0), Enemy.Rarity.ELITE, 5)
	assert(is_equal_approx(e_elite.max_hp, base_hp * 2.5) and e_elite.xp == int(goblin.xp * (1.0 + 0.3 * 4)) * 3)
	var azkhar: EnemyData = DB.get_enemy(&"azkhar")
	var e_chefe: Enemy = ow.spawn_enemy(azkhar, ow.player.global_position + Vector2(2700, 0), Enemy.Rarity.CHEFE, 1)
	assert(e_chefe.is_boss() and e_chefe.rarity == Enemy.Rarity.CHEFE)
	assert(is_equal_approx(e_chefe.max_hp, azkhar.max_hp * diff.hp))  # tabela não multiplica chefe (roteirizado)
	e_lend.queue_free()
	e_camp.queue_free()
	e_elite.queue_free()
	e_chefe.queue_free()
	# roll: distribuição estatística (20k rolagens, nível 1, Normal)
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var counts := [0, 0, 0, 0, 0]
	for i in 20000:
		counts[Enemy.roll_rarity(1, 0.0, rng)] += 1
	assert(counts[Enemy.Rarity.LENDARIO] >= 30 and counts[Enemy.Rarity.LENDARIO] <= 90)     # ~0.3%
	assert(counts[Enemy.Rarity.CAMPEAO] >= 300 and counts[Enemy.Rarity.CAMPEAO] <= 500)    # ~2%
	assert(counts[Enemy.Rarity.ELITE] >= 1500 and counts[Enemy.Rarity.ELITE] <= 2100)      # ~9%
	# bônus de dificuldade (Inferno +28%) aumenta as raridades
	rng.seed = 42
	var raros := 0
	for i in 20000:
		if Enemy.roll_rarity(1, 0.28, rng) >= Enemy.Rarity.ELITE:
			raros += 1
	assert(raros > 6000)  # ~40% vs ~11% sem bônus
	print("[smoke]   raridades ok (elite x2.5, campeao x5, lendario x10; roll distribuido)")
	# 3.2: afixos de Campeão (MECANICAS §5.2) — roll determinístico e efeitos
	var pp := ow.player.global_position
	var rng3 := RandomNumberGenerator.new()
	rng3.seed = 99
	var a1 := Enemy.roll_affixes(rng3, 4)
	assert(a1.size() == 4)
	for i in a1.size():
		assert(a1[i] >= 0 and a1[i] <= Enemy.Affix.CAMPEAO_DAS_SOMBRAS, "afixo fora do enum")
		for j in range(i + 1, a1.size()):
			assert(a1[i] != a1[j], "afixo repetido no roll")
	assert(Enemy.roll_affixes(rng3, 8).size() == 8)  # todos os 8 sem repetição
	# affixes_for: Comum/Chefe sem afixos; Campeão 1–2; Lendário 2–3; Inferno +1 a Elite+
	rng3.seed = 99
	assert(Enemy.affixes_for(Enemy.Rarity.COMUM, rng3).is_empty())
	assert(Enemy.affixes_for(Enemy.Rarity.ELITE, rng3).is_empty())
	assert(Enemy.affixes_for(Enemy.Rarity.ELITE, rng3, true).size() == 1)  # Inferno +1
	assert(Enemy.affixes_for(Enemy.Rarity.CHEFE, rng3, true).is_empty())    # chefe roteirizado
	var sizes := [0, 0, 0, 0, 0]
	for i in 500:
		sizes[Enemy.affixes_for(Enemy.Rarity.CAMPEAO, rng3).size()] += 1
	assert(sizes[0] == 0 and sizes[3] == 0 and sizes[4] == 0 and sizes[1] > 0 and sizes[2] > 0)
	sizes = [0, 0, 0, 0, 0]
	for i in 500:
		sizes[Enemy.affixes_for(Enemy.Rarity.LENDARIO, rng3).size()] += 1
	assert(sizes[0] == 0 and sizes[1] == 0 and sizes[4] == 0 and sizes[2] > 0 and sizes[3] > 0)
	for i in 200:
		var n := Enemy.affixes_for(Enemy.Rarity.LENDARIO, rng3, true).size()
		assert(n == 3 or n == 4)  # Inferno: Lendário 3–4
	# inimigos de teste: longe do jogador para não interferir
	var test_es: Array[Enemy] = []
	# TELÚRICO: knockback ignorado
	var e_ctl: Enemy = ow.spawn_enemy(goblin, pp + Vector2(2800, 0), Enemy.Rarity.COMUM, 5)
	var e_tel: Enemy = ow.spawn_enemy(goblin, pp + Vector2(2900, 0), Enemy.Rarity.COMUM, 5, [Enemy.Affix.TELURICO])
	test_es.append(e_ctl)
	test_es.append(e_tel)
	e_ctl.take_damage(5.0, false, e_ctl.global_position + Vector2(100, 0), 100.0)
	e_tel.take_damage(5.0, false, e_tel.global_position + Vector2(100, 0), 100.0)
	assert(e_ctl._knock.length() > 1.0, "controle deveria sofrer knockback")
	assert(e_tel._knock == Vector2.ZERO, "TELÚRICO imune a knockback")
	assert(e_tel.affix_names() == ["Telúrico"])
	# FURIOSO: recarga de ataque 30% mais rápida
	var e_fur: Enemy = ow.spawn_enemy(goblin, pp + Vector2(3050, -200), Enemy.Rarity.COMUM, 5, [Enemy.Affix.FURIOSO])
	test_es.append(e_fur)
	assert(absf(e_fur._reset_attack_cd(1.0) - 0.7) < 0.001)
	assert(absf(e_ctl._reset_attack_cd(1.0) - 1.0) < 0.001)  # sem afixo: base cheia
	# MESTRE-DE-ENXAME: invoca 3 lacaios COMUM a 50% de HP
	var e_swm: Enemy = ow.spawn_enemy(goblin, pp + Vector2(2950, 200), Enemy.Rarity.COMUM, 5, [Enemy.Affix.MESTRE_DE_ENXAME])
	test_es.append(e_swm)
	e_swm.take_damage(e_swm.max_hp * 0.6, false, Vector2.INF, 0.0)
	# consulta direta ao grupo: o hash espacial só reconstrói a cada frame de física
	var swarm := 0
	for n in get_tree().get_nodes_in_group("enemies"):
		var en := n as Enemy
		if en != null and en.global_position.distance_to(e_swm.global_position) < 100.0:
			swarm += 1
			if not test_es.has(en):
				test_es.append(en)
	assert(swarm >= 4, "enxame deveria ter 3 lacaios + o mestre")
	# ARDENTE: deixa piso em chamas a cada 1,5s
	var e_ard: Enemy = ow.spawn_enemy(goblin, pp + Vector2(3150, 200), Enemy.Rarity.COMUM, 5, [Enemy.Affix.ARDENTE])
	test_es.append(e_ard)
	await _wait(0.2)
	assert(ow.fire_zones.size() >= 1, "ARDENTE deveria criar zona de fogo")
	# VENENOSO: golpe aplica veneno; veneno tica a cada 1s (dano direto)
	var e_ven: Enemy = ow.spawn_enemy(goblin, pp + Vector2(3250, 0), Enemy.Rarity.COMUM, 5, [Enemy.Affix.VENENOSO])
	test_es.append(e_ven)
	e_ven._hit_target(ow.player, 5.0)
	assert(ow.player.is_poisoned(), "VENENOSO deveria envenenar o alvo")
	ow.player._combat_timer = 4.0  # sem regeneração fora de combate no teste
	ow.player.hp = ow.player.max_hp
	ow.player.apply_poison(10.0, 1.5)
	await _wait(1.15)
	assert(ow.player.hp <= ow.player.max_hp - 10.0, "tique de veneno deveria ferir 10")
	# ESCUDO ARCANO: absorve antes do HP e regenera a cada 5s
	var e_esc: Enemy = ow.spawn_enemy(goblin, pp + Vector2(3100, 0), Enemy.Rarity.CAMPEAO, 5, [Enemy.Affix.ESCUDO_ARCANO])
	test_es.append(e_esc)
	var esc_max: float = e_esc.max_hp * 0.1
	assert(is_equal_approx(e_esc._shield, esc_max), "escudo inicial 10% do HP")
	var shield_before: float = e_esc._shield
	var ret_esc := e_esc.take_damage(20.0, false, Vector2.INF, 0.0)
	assert(ret_esc == 0.0 and e_esc.hp == e_esc.max_hp, "escudo absorve antes do HP")
	assert(e_esc._shield < shield_before and e_esc._shield > 0.0)
	await _wait(5.3)
	assert(is_equal_approx(e_esc._shield, esc_max), "escudo regenera a cada 5s")
	# FANTASMA: ~20% de esquiva (100 golpes)
	var e_fan: Enemy = ow.spawn_enemy(goblin, pp + Vector2(3000, 0), Enemy.Rarity.CAMPEAO, 5, [Enemy.Affix.FANTASMA])
	test_es.append(e_fan)
	var esquivas := 0
	for i in 100:
		var hp_antes: float = e_fan.hp
		if e_fan.take_damage(1.0, false, Vector2.INF, 0.0) == 0.0 and e_fan.hp == hp_antes:
			esquivas += 1
	assert(esquivas >= 8 and esquivas <= 32, "FANTASMA ~20%% de esquiva (foi %d)" % esquivas)
	# CAMPEÃO-DAS-SOMBRAS: teleporta para perto do alvo a cada 6s
	var e_shd: Enemy = ow.spawn_enemy(goblin, pp + Vector2(3200, -200), Enemy.Rarity.COMUM, 5, [Enemy.Affix.CAMPEAO_DAS_SOMBRAS])
	test_es.append(e_shd)
	e_shd.state = Enemy.State.CHASE
	assert(e_shd.global_position.distance_to(ow.player.global_position) > 2000.0)
	await _wait(3.5)
	assert(e_shd.global_position.distance_to(ow.player.global_position) < 200.0, "SOMBRAS deveria teleportar")
	for e in test_es:
		if is_instance_valid(e):
			e.queue_free()
	print("[smoke]   afixos ok (roll sem repeticao; furioso/escudo/telurico/venenoso/fantasma/enxame/ardente/sombras)")
	# 3.3: LootTableData por raridade (REGRAS §6) + essência (REGRAS §9)
	assert(DB.loot_tables.size() == 5, "uma tabela de loot por raridade")
	assert(is_equal_approx(DB.loot_tables[Enemy.Rarity.COMUM].item_chance, 0.10))
	assert(DB.loot_tables[Enemy.Rarity.ELITE].guaranteed == [Item.Rarity.MAGIC])
	assert(DB.loot_tables[Enemy.Rarity.CAMPEAO].guaranteed == [Item.Rarity.RARE])
	assert(is_equal_approx(DB.loot_tables[Enemy.Rarity.CAMPEAO].essence_chance, 0.5))
	assert(DB.loot_tables[Enemy.Rarity.LENDARIO].guaranteed == [Item.Rarity.LEGENDARY])
	assert(is_equal_approx(DB.loot_tables[Enemy.Rarity.LENDARIO].essence_chance, 1.0))
	assert(DB.loot_tables[Enemy.Rarity.CHEFE].guaranteed.size() == 2)
	assert(DB.loot_tables[Enemy.Rarity.CHEFE].essence_amount == 2)
	var drops33 := func(kind33: int, pos33: Vector2) -> Array:
		var out := []
		for n33 in ow.entities.get_children():
			var d33 := n33 as LootDrop
			if d33 != null and not d33.is_queued_for_deletion() and d33.kind == kind33 \
					and d33.global_position.distance_to(pos33) < 60.0:
				out.append(d33)
		return out
	var limpar33 := func(pos33: Vector2) -> void:
		for n33 in ow.entities.get_children():
			var d33 := n33 as LootDrop
			if d33 != null and d33.global_position.distance_to(pos33) < 80.0:
				ow.entities.remove_child(n33)
				n33.queue_free()
	var e33: Enemy = ow.spawn_enemy(goblin, pp + Vector2(3400, 0), Enemy.Rarity.COMUM, 5)
	e33.take_damage(99999.0, false, Vector2.INF, 0.0)
	assert(drops33.call(LootDrop.Kind.ESSENCE, e33.global_position).is_empty(), "COMUM nao dropa essencia")
	limpar33.call(e33.global_position)
	e33 = ow.spawn_enemy(goblin, pp + Vector2(3450, 0), Enemy.Rarity.ELITE, 5)
	e33.take_damage(99999.0, false, Vector2.INF, 0.0)
	var tem_magico := false
	for l33 in drops33.call(LootDrop.Kind.ITEM, e33.global_position):
		if (l33 as LootDrop).item.rarity >= Item.Rarity.MAGIC:
			tem_magico = true
	assert(tem_magico, "ELITE garante >=1 item magico")
	assert(drops33.call(LootDrop.Kind.ESSENCE, e33.global_position).is_empty(), "ELITE nao dropa essencia")
	limpar33.call(e33.global_position)
	e33 = ow.spawn_enemy(goblin, pp + Vector2(3500, 0), Enemy.Rarity.CAMPEAO, 5)
	e33.take_damage(99999.0, false, Vector2.INF, 0.0)
	var tem_raro := false
	for l33 in drops33.call(LootDrop.Kind.ITEM, e33.global_position):
		if (l33 as LootDrop).item.rarity >= Item.Rarity.RARE:
			tem_raro = true
	assert(tem_raro, "CAMPEAO garante >=1 item raro")
	limpar33.call(e33.global_position)
	e33 = ow.spawn_enemy(goblin, pp + Vector2(3550, 0), Enemy.Rarity.LENDARIO, 5)
	e33.take_damage(99999.0, false, Vector2.INF, 0.0)
	var tem_lend := false
	for l33 in drops33.call(LootDrop.Kind.ITEM, e33.global_position):
		if (l33 as LootDrop).item.rarity == Item.Rarity.LEGENDARY:
			tem_lend = true
	assert(tem_lend, "LENDARIO garante >=1 item lendario")
	assert(drops33.call(LootDrop.Kind.ESSENCE, e33.global_position).size() == 1, "LENDARIO dropa 1 essencia")
	limpar33.call(e33.global_position)
	e33 = ow.spawn_enemy(azkhar, pp + Vector2(3600, 0), Enemy.Rarity.CHEFE, 1)
	e33.take_damage(999999.0, false, Vector2.INF, 0.0)
	var raros33 := 0
	var lends33 := 0
	for l33 in drops33.call(LootDrop.Kind.ITEM, e33.global_position):
		if (l33 as LootDrop).item.rarity >= Item.Rarity.RARE:
			raros33 += 1
		if (l33 as LootDrop).item.rarity == Item.Rarity.LEGENDARY:
			lends33 += 1
	assert(raros33 >= 2, "CHEFE garante >=2 itens raros+")
	assert(lends33 >= 1, "CHEFE dropa >=1 lendario")
	var ess33: Array = drops33.call(LootDrop.Kind.ESSENCE, e33.global_position)
	assert(ess33.size() == 1 and (ess33[0] as LootDrop).essence == 2, "CHEFE dropa essencia x2")
	limpar33.call(e33.global_position)
	# estatístico: 40 campeões → ~50% dropam essência
	var ess_cont := 0
	for i in 40:
		e33 = ow.spawn_enemy(goblin, pp + Vector2(3650 + i * 4, 0), Enemy.Rarity.CAMPEAO, 5)
		e33.take_damage(99999.0, false, Vector2.INF, 0.0)
		ess_cont += drops33.call(LootDrop.Kind.ESSENCE, e33.global_position).size()
		limpar33.call(e33.global_position)
	assert(ess_cont >= 12 and ess_cont <= 28, "essencia ~50%% em campeoes (foi %d)" % ess_cont)
	# pickup magnético de essência + HUD
	var ess_antes: int = Game.hero.essence
	LootDrop.drop_essence(ow, ow.player.global_position, 3)
	var coletou := false
	for i in 30:
		await _wait(0.1)
		if Game.hero.essence == ess_antes + 3:
			coletou = true
			break
	assert(coletou, "essencia deveria ser coletada pelo ima")
	assert(ow.hud._essence.text.contains(str(ess_antes + 3)), "HUD deveria mostrar a essencia")
	print("[smoke]   loot por raridade ok (5 tabelas; elite magico, campeao raro+50% ess, lendario lendario, chefe raro x2+unico+ess x2; ima e HUD)")
	await _shot("07_mundo_acampamento")
	h.gold = 5000
	ow.hud.open_merchant()
	await _wait(0.4)
	await _shot("08_mercador")
	ow.hud.close_popup()
	# Visita cada bioma (procura uma célula de cada tipo em espiral)
	for biome in OverworldGen.BIOME_IDS:
		var target := _find_biome(ow, biome)
		if target == Vector2i(999999, 999999):
			print("[smoke] bioma não encontrado: ", biome)
			continue
		ow.player.global_position = ow.cell_to_world(target)
		await _wait(1.6)
		# Coloca o jogador num chão livre perto
		for r in 30:
			var c := target + Vector2i(r, 0)
			if ow.is_floor(c):
				ow.player.global_position = ow.cell_to_world(c)
				break
		await _wait(0.8)
		print("[smoke] bioma %s em %s: chunks=%d inimigos=%d nível=%d" % [biome, target, ow.chunks.size(), get_tree().get_nodes_in_group("enemies").size(), ow.level()])
		await _shot("07_bioma_" + biome)
	# Usa uma habilidade e anda um pouco no mundo
	ow.player._request_cast(0, ow.player.global_position + Vector2(20, 0))
	await _wait(0.5)
	# Viagem rápida
	ow.hud.open_waypoints()
	await _wait(0.3)
	await _shot("08b_viagem")
	ow.hud.close_popup()
	# Entra numa masmorra e volta
	var entrance: Interactable = null
	for k in [Vector2i(1, 0)]:
		ow.player.global_position = ow.cell_to_world(k * OverworldGen.CHUNK + Vector2i(16, 16))
	await _wait(2.0)
	for n in get_tree().get_nodes_in_group("interactables"):
		if n is Interactable and n.kind == Interactable.Kind.DUNGEON_ENTRANCE:
			entrance = n
			break
	if entrance:
		print("[smoke] entrando em: ", entrance.display_name())
		entrance.interact(ow.player)
		await _wait(2.5)
		var dw: World = get_tree().get_first_node_in_group("world")
		assert(not dw is Overworld)
		await _shot("09_masmorra")
		for n in get_tree().get_nodes_in_group("interactables"):
			if n is Interactable and n.kind == Interactable.Kind.DUNGEON_EXIT:
				n.interact(dw.player)
				break
		await _wait(2.5)
		assert(get_tree().get_first_node_in_group("world") is Overworld)
		print("[smoke] voltou ao mundo aberto")
	else:
		print("[smoke] ERRO: nenhuma entrada de masmorra encontrada")
	Game.save_game()
	assert(Game.load_game())


func _find_biome(ow: Overworld, biome: String) -> Vector2i:
	for r in range(1, 120):
		for a in 16:
			var ang := a * TAU / 16.0
			var c := Vector2i(Vector2(cos(ang), sin(ang)) * r * 24.0)
			if ow.og.biome_at(c) == biome:
				return c
	return Vector2i(999999, 999999)


func _report_wide(c: Node, depth: int) -> void:
	if c is Control and (c as Control).size.x > 640:
		print("[wide] ", "  ".repeat(depth), c.get_class(), " ", c.name, " ", (c as Control).size, " min=", (c as Control).get_combined_minimum_size())
	for ch in c.get_children():
		_report_wide(ch, depth + 1)


func _nearest_enemy(world: World, pos: Vector2) -> Enemy:
	var best: Enemy
	var bd := INF
	for e in world.enemies_near(pos, 99999.0):
		var d := e.global_position.distance_to(pos)
		if d < bd:
			bd = d
			best = e
	return best
