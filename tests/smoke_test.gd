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
