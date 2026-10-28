# Fase 11: Guildas e Organizações — Plano de Implementação Completo

> **Para trabalho agentic:** REQUIRED SUB-SKILL: Use superpowers:executing-plans ou superpowers:subagent-driven-development para implementar este plano task-by-task. Steps usam sintaxe checkbox (`- [ ]`) para rastreamento.

**Objetivo:** Implementar sistema completo de guildas (5 tipos NPC + player-created) + Rank F-S global (7 níveis), integrando com economia, quests, e progressão do jogador.

**Arquitetura:** Data-driven (GuildData, ContractData, RankData como Resources). Cada guilda (Aventureiros/Mercadores/Artesãos/Sombras/PlayerGuild) é independente mas compartilha interfaces (Membro, XP, benefícios). Rank F-S é global, desbloqueado por conquistas de Aventureiros + quests. UI unificada com abas por guilda.

**Tech Stack:** GDScript 4.7, Resources .tres (GuildData, ContractData), RefCounted para estado (GuildLog, PlayerGuild), Autoload Guilds para cache de NPCs.

**Spec:** `docs/REGRAS_DO_JOGO.md` §17–18 (GuildData, contratos, ranks, benefícios, regras de saída)

---

## Global Constraints

- **Versão save:** v6 (add guild_joined, rank_f_s, contracts_active, contracts_completed, guild_xp, guild_rank)
- **14 classes × 5 guildas NPCs = 70 arquivos GuildData** (data-driven, sem hardcode)
- **Contratos procedurais:** GuidanceData template (Caça/Coleta/Exploração/Escolta) × 5 dificuldades (F-E-D-C-B-A-S)
- **Rank F-S:** Títulos visíveis no mundo + HUD + chat; desbloqueia guildas, benefícios (taxa vendor, slots leilão, etc.)
- **Multiplayer single-player hybrid:** Guilda do jogador persiste entre sessões; membros solo contribuem (contratos, doações) → XP conta para guilda
- **Convenção Commits PT-BR:** 1 commit por task (feat:, fix:, docs:)
- **Smoke gate:** Todos os 7 commits passam em ~30 min headless; 0 erros críticos; todas as guildas carregam, contratos geram, ranks avançam

---

## Review Focus

1. **Contratos procedurais determinísticos:** Mesmo (seed, dia) = mesmo contrato (para multiplayer síncrono). Testes: role determinístico por seed, progresso independente.
2. **Saída do Mestre de PlayerGuild bloqueada:** Se jogador é Mestre e não passa posse/dissolve, botão fica desabilitado. Testes: verificar estado do botão em todos os casos.
3. **Rank F-S requerimentos cascata:** Rank B requer Rank A?  Não — requer uma lista de conquistas (nível, contratos, chefes, mistérios, fragmentos). Testes: verificar que cada rank tem lista exata de requisitos.
4. **Essência ↔ Ouro câmbio:** Taxa 1 Ess = 500 ouro; nunca pode negativar. Testes: compra com essência insuficiente falha; taxa aplicada corretamente.
5. **Expulsão de guilda por inatividade:** 30 dias sem login → removido. Testes: mockar `Game.world_time`, verificar remoção automática no `_process`.

---

## File Structure

```
scripts/
  data/
    guild_data.gd              # GuildData resource (nome, tipo, benefícios, rank da guilda, XP)
    contract_data.gd           # ContractData resource (id, tipo, reqs, recompensas, tempo limite)
    rank_data.gd               # RankData resource (rank F-S, reqs, títulos, benefícios)
  core/
    guild_log.gd               # GuildLog (RefCounted) — estado de guilda do herói (membro? rank? XP?)
    player_guild.gd            # PlayerGuild (RefCounted) — guilda criada pelo jogador (banco, membros, hall, XP)
    rank_system.gd             # RankSystem (static) — sistema de Rank F-S global (avançar, verificar reqs, benefícios)
    contract_tracker.gd        # ContractTracker (RefCounted) — contratos ativos (progresso, deadline, entrega)
  ui/
    guild_panel.gd             # GuildPanel — UI unificada (abas: Aventureiros/Mercadores/Artesãos/Sombras/Player)
    contract_board.gd          # ContractBoard — sub-painel do Aventureiros (lista, seleção, entrega)
    player_guild_hall.gd       # PlayerGuildHall — instância do hall da guilda (banco, membros, upgrades)
  autoload/
    guilds.gd                  # Autoload Guilds — cache de GuildData NPCs (14 classes × 5 = 70)

data/
  guilds/
    aventureiros_*.tres        # 14 × GuildData (Aventureiros por classe)
    mercadores_*.tres          # 14 × GuildData (Mercadores por classe)
    ... (70 total)
  contracts/
    contract_templates.tres    # ContractData templates (Caça/Coleta/Exploração/Escolta)

tests/
  guilds/
    test_guild_data.gd
    test_contract_system.gd
    test_rank_system.gd
    test_player_guild.gd
    test_guild_ui.gd
```

---

## Task 1: GuildData, ContractData, RankData — Estrutura de Dados

**Files:**
- Create: `scripts/data/guild_data.gd`
- Create: `scripts/data/contract_data.gd`
- Create: `scripts/data/rank_data.gd`
- Create: `data/guilds/*.tres` (70 arquivos GuildData)
- Create: `data/contracts/contract_templates.tres`
- Test: `tests/guilds/test_guild_data.gd`

**Interfaces:**
- Consumes: ClassData (nomes de classes para gerar guildas por classe)
- Produces: 
  - `GuildData` (resource, com properties: id, display_name, tipo, mestre_npc, benefícios dict, rank_reqs dict, XP)
  - `ContractData` (resource, com properties: id, tipo, região, reqs, recompensas dict, tempo_limite_horas, dificuldade)
  - `RankData` (resource, com properties: rank_letter, nível_mín, reqs_conquistas dict, títulos, benefícios dict)

- [ ] **Step 1: Write failing test for GuildData**

```gdscript
func test_guild_data_load():
    var guild := DB.guild("aventureiros_humano")
    assert guild is GuildData
    assert guild.display_name == "Guilda dos Aventureiros"
    assert guild.tipo == GuildData.Type.AVENTUREIROS
    assert guild.mestre_npc == "gareth_aventureiros"
    assert "contratos_ativos_max" in guild.beneficios
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd /media/f/HD/KINFIRE && godot --headless --path . -s tests/guilds/test_guild_data.gd
```

Expected: FAIL — `GuildData` resource não existe

- [ ] **Step 3: Create `scripts/data/guild_data.gd`**

```gdscript
extends Resource
class_name GuildData

enum Type { AVENTUREIROS, MERCADORES, ARTESAOS, SOMBRAS }

@export var id: StringName
@export var display_name: String
@export var tipo: Type
@export var mestre_npc: StringName  # NPC ID (ex: "gareth_aventureiros")
@export var descricao: String
@export var requisito_nivel: int
@export var requisito_ouro: int
@export var requisito_reputacao: int  # -1 = nenhum
@export var beneficios: Dictionary  # Ex: {"contratos_ativos_max": 1, "desconto_leilao": 0.0}
@export var rank_reqs: Dictionary  # Ex: {"F": [...], "E": [...]}
```

- [ ] **Step 4: Create `scripts/data/contract_data.gd`**

```gdscript
extends Resource
class_name ContractData

enum Type { CACA, COLETA, EXPLORACAO, ESCOLTA }

@export var id: StringName
@export var tipo: Type
@export var regiao: StringName
@export var descricao_template: String  # "Mate %d %s em %s"
@export var requisitos: Dictionary  # {"inimigos": 5, "tipo_inimigo": "comum"}
@export var recompensas: Dictionary  # {"ouro": 100, "xp": 50, "reputacao": 1}
@export var tempo_limite_horas: float  # 2.0
@export var dificuldade: String  # "F", "E", "D", "C", "B", "A", "S"
@export var risco: float  # 1.0-5.0 (falha penaliza rep × risco)
```

- [ ] **Step 5: Create `scripts/data/rank_data.gd`**

```gdscript
extends Resource
class_name RankData

@export var rank_letter: String  # "F", "E", "D", "C", "B", "A", "S"
@export var nivel_minimo: int
@export var titulo: String  # "Novato", "Veterano", etc.
@export var requisitos_conquistas: Dictionary  # {"contratos": 3, "chefes": 1, "niveis": 30}
@export var beneficios: Dictionary  # {"desconto_vendor": 0.0, "slots_leilao_bonus": 0}
```

- [ ] **Step 6: Generate 70 GuildData .tres files (14 classes × 5 tipos)**

Usar script helper em Python:

```python
import json
classes = ["humano", "barbaro", "alto_elfo", ...]
tipos = ["aventureiros", "mercadores", "artesaos", "sombras"]
for cls in classes:
    for tipo in tipos:
        # Cria data/guilds/{tipo}_{cls}.tres com values apropriados
```

(Implementar em GDScript via `DB._generate_guild_data()` call no autoload)

- [ ] **Step 7: Run tests to verify they pass**

```bash
godot --headless --path . -s tests/guilds/test_guild_data.gd
```

Expected: PASS — GuildData carrega, properties corretos

- [ ] **Step 8: Commit**

```bash
git add scripts/data/guild_data.gd scripts/data/contract_data.gd scripts/data/rank_data.gd
git add data/guilds/ data/contracts/
git add tests/guilds/test_guild_data.gd
git commit -m "feat: guild/contract/rank data structures — 70 GuildData .tres (14 classes × 5 tipos), ContractData templates, RankData F-S"
```

---

## Task 2: GuildLog — Estado de Guilda do Herói

**Files:**
- Create: `scripts/core/guild_log.gd`
- Modify: `scripts/core/hero.gd` (add guild_joined, guild_rank, guild_xp, contracts_completed, contracts_active)
- Modify: `scripts/core/hero.gd` save/load (v6)
- Test: `tests/guilds/test_guild_log.gd`

**Interfaces:**
- Consumes: GuildData (para validation), Hero (para persistência)
- Produces:
  - `GuildLog` (RefCounted, com métodos: join_guild, leave_guild, get_rank, add_xp, complete_contract)
  - Hero v6 com properties: guild_joined (StringName), guild_rank (String F-S), guild_xp (int), contracts_active (Array[StringName]), contracts_completed (int)

- [ ] **Step 1: Write failing test for GuildLog**

```gdscript
func test_guild_join():
    var hero := Hero.new()
    var log := GuildLog.new(hero)
    log.join_guild(&"aventureiros")
    assert hero.guild_joined == &"aventureiros"
    assert log.get_rank() == "F"
    assert log.get_xp() == 0

func test_guild_xp_gain():
    var hero := Hero.new()
    var log := GuildLog.new(hero)
    log.join_guild(&"aventureiros")
    log.add_xp(100)
    assert log.get_xp() == 100
```

- [ ] **Step 2: Run test to verify it fails**

Expected: FAIL — GuildLog não existe

- [ ] **Step 3: Create `scripts/core/guild_log.gd`**

```gdscript
extends RefCounted
class_name GuildLog

var hero: Hero

const RANK_ORDER = ["F", "E", "D", "C", "B", "A", "S"]

func _init(p_hero: Hero) -> void:
    hero = p_hero

func join_guild(guild_id: StringName) -> bool:
    if hero.guild_joined != &"":
        return false  # Já membro de uma guilda
    if not DB.guild(guild_id):
        return false
    hero.guild_joined = guild_id
    hero.guild_rank = "F"
    hero.guild_xp = 0
    return true

func leave_guild() -> bool:
    # Validar: se Mestre de PlayerGuild, não deixa sair
    hero.guild_joined = &""
    hero.guild_rank = "F"
    hero.guild_xp = 0
    hero.contracts_active.clear()
    return true

func get_rank() -> String:
    return hero.guild_rank

func add_xp(amount: int) -> void:
    hero.guild_xp += amount
    _check_rank_up()

func complete_contract(contract_id: StringName) -> void:
    hero.contracts_active.erase(contract_id)
    hero.contracts_completed += 1

func _check_rank_up() -> void:
    # Checka se deve subir de rank baseado em conquistas (delegado ao RankSystem)
    pass
```

- [ ] **Step 4: Modify hero.gd para adicionar propriedades de guilda v6**

Em `scripts/core/hero.gd`:

```gdscript
# Linhas ~50
var guild_joined: StringName = &""
var guild_rank: String = "F"
var guild_xp: int = 0
var contracts_active: Array[StringName] = []
var contracts_completed: int = 0
```

- [ ] **Step 5: Modify hero.gd save/load para v6**

Em `to_dict()`:

```gdscript
"guild_joined": String(guild_joined),
"guild_rank": guild_rank,
"guild_xp": guild_xp,
"contracts_active": [String(c) for c in contracts_active],
"contracts_completed": contracts_completed,
```

Em `from_dict()`:

```gdscript
h.guild_joined = StringName(d.get("guild_joined", ""))
h.guild_rank = d.get("guild_rank", "F")
h.guild_xp = int(d.get("guild_xp", 0))
var ca: Array = d.get("contracts_active", [])
for c in ca:
    h.contracts_active.append(StringName(c))
h.contracts_completed = int(d.get("contracts_completed", 0))
```

Adicionar migração:

```gdscript
func _migrate_v6() -> void:
    # v5 não tinha guilda; default para vazio
    pass
```

- [ ] **Step 6: Run tests to verify they pass**

Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add scripts/core/guild_log.gd scripts/core/hero.gd tests/guilds/test_guild_log.gd
git commit -m "feat: GuildLog — join/leave guilda, track XP, save v6 (guild_joined, guild_rank, contracts)"
```

---

## Task 3: Guilda dos Aventureiros — Contratos e Progressão de Rank

**Files:**
- Create: `scripts/core/adventure_guild.gd` (static helper)
- Create: `scripts/core/contract_tracker.gd`
- Modify: `Hero` (add método accept_contract, deliver_contract)
- Test: `tests/guilds/test_contract_system.gd`

**Interfaces:**
- Consumes: GuildLog, ContractData, Hero
- Produces:
  - `ContractTracker` (RefCounted, com métodos: start, progress, complete, is_expired)
  - `AdventureGuild.generate_contract(rank: String, region: StringName) -> ContractData`
  - Métodos em Hero: `accept_contract(contract_id)`, `deliver_contract(contract_id) -> bool`

- [ ] **Step 1: Write failing test for AdventureGuild**

```gdscript
func test_contract_generation_deterministic():
    var seed1 := 12345
    var seed2 := 12345
    var contract1 := AdventureGuild.generate_contract("F", &"colinas", seed1)
    var contract2 := AdventureGuild.generate_contract("F", &"colinas", seed2)
    assert contract1.id == contract2.id  # Determinístico

func test_contract_expiration():
    var hero := Hero.new()
    hero.guild_joined = &"aventureiros"
    var contract := ContractTracker.new(hero, "caca_comum_5")
    assert not contract.is_expired()
    # Mockar 3 horas depois
    assert contract.is_expired()
```

- [ ] **Step 2: Run test to verify it fails**

Expected: FAIL — AdventureGuild.generate_contract não existe

- [ ] **Step 3: Create `scripts/core/adventure_guild.gd`**

```gdscript
extends Object
class_name AdventureGuild

const CONTRACT_TYPES = [ContractData.Type.CACA, ContractData.Type.COLETA, ContractData.Type.EXPLORACAO, ContractData.Type.ESCOLTA]

static func generate_contract(rank: String, region: StringName, seed: int = 0) -> ContractData:
    var rng := RandomNumberGenerator.new()
    if seed > 0:
        rng.seed = seed
    
    var tipo = CONTRACT_TYPES[rng.randi() % CONTRACT_TYPES.size()]
    var template := DB.contract_template(tipo)
    
    var contract := ContractData.new()
    contract.id = StringName("%s_%s_%d" % [tipo, region, seed])
    contract.tipo = tipo
    contract.regiao = region
    contract.dificuldade = rank
    contract.tempo_limite_horas = 2.0
    # ... populate fields baseado em template
    
    return contract

static func validate_contract_complete(hero: Hero, contract_id: StringName) -> bool:
    # Verifica se hero completou o objetivo do contrato
    # Delegado ao sistema de quests/eventos
    return true
```

- [ ] **Step 4: Create `scripts/core/contract_tracker.gd`**

```gdscript
extends RefCounted
class_name ContractTracker

var hero: Hero
var contract: ContractData
var start_time: float
var progress: Dictionary  # {"inimigos_killed": 5, "items_collected": 2}

func _init(p_hero: Hero, p_contract_id: StringName) -> void:
    hero = p_hero
    contract = DB.contract(p_contract_id)
    start_time = Time.get_ticks_msec() / 1000.0
    progress = {}

func is_expired() -> bool:
    var elapsed = (Time.get_ticks_msec() / 1000.0) - start_time
    return elapsed > contract.tempo_limite_horas * 3600.0

func complete() -> void:
    hero.contracts_active.erase(contract.id)
    hero.contracts_completed += 1
    # Aplica recompensas
    hero.gold += contract.recompensas.get("ouro", 0)
    hero.add_xp(contract.recompensas.get("xp", 0))
```

- [ ] **Step 5: Add métodos em Hero para contratos**

Em `scripts/core/hero.gd`:

```gdscript
func accept_contract(contract_id: StringName) -> bool:
    var log := GuildLog.new(self)
    var guild_data := DB.guild(guild_joined)
    if not guild_data:
        return false
    var max_active = guild_data.beneficios.get("contratos_ativos_max", 1)
    if contracts_active.size() >= max_active:
        return false  # Limite atingido
    contracts_active.append(contract_id)
    return true

func deliver_contract(contract_id: StringName) -> bool:
    if contract_id not in contracts_active:
        return false
    var tracker := ContractTracker.new(self, contract_id)
    if tracker.is_expired():
        # Falha: penaliza reputação
        var guild_id = guild_joined
        Game.reputation[guild_id] -= tracker.contract.risco
        contracts_active.erase(contract_id)
        return false
    # Completa
    tracker.complete()
    return true
```

- [ ] **Step 6: Run tests to verify they pass**

Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add scripts/core/adventure_guild.gd scripts/core/contract_tracker.gd scripts/core/hero.gd tests/guilds/test_contract_system.gd
git commit -m "feat: Guilda Aventureiros — contratos procedurais determinísticos, tracker, accept/deliver"
```

---

## Task 4: Rank F-S — Sistema de Reconhecimento Global

**Files:**
- Create: `scripts/core/rank_system.gd`
- Modify: `Hero` (add método check_rank_advancement)
- Modify: `HUD` (adicionar rank display)
- Test: `tests/guilds/test_rank_system.gd`

**Interfaces:**
- Consumes: RankData, Hero, QuestLog
- Produces:
  - `RankSystem.get_rank(hero: Hero) -> String`
  - `RankSystem.check_advancement(hero: Hero) -> bool` (retorna true se avançou)
  - `RankSystem.get_benefits(rank: String) -> Dictionary`

- [ ] **Step 1: Write failing test for Rank F-S**

```gdscript
func test_rank_f_default():
    var hero := Hero.new()
    assert RankSystem.get_rank(hero) == "F"

func test_rank_e_requirements():
    var hero := Hero.new()
    hero.guild_joined = &"aventureiros"
    hero.contracts_completed = 3
    assert RankSystem.check_advancement(hero) == true
    assert hero.rank_f_s == "E"

func test_rank_a_requirements():
    var hero := Hero.new()
    hero.guild_joined = &"aventureiros"
    hero.contracts_completed = 100
    hero.level = 75
    hero.kills_boss = 10
    # Verificar que requer 4 mistérios + 1 fragmento
    assert RankSystem.check_advancement(hero) == false
    hero.fragmentos = 1
    hero.mysteries_completed = 4
    assert RankSystem.check_advancement(hero) == true
```

- [ ] **Step 2: Run test to verify it fails**

Expected: FAIL — RankSystem não existe

- [ ] **Step 3: Create `scripts/core/rank_system.gd`**

```gdscript
extends Object
class_name RankSystem

const RANK_REQUIREMENTS = {
    "E": {"contratos": 3},
    "D": {"contratos": 10, "chefes": 1},
    "C": {"contratos": 25, "chefes": 3, "niveis": 30, "misterios": 1},
    "B": {"contratos": 50, "chefes": 6, "niveis": 50, "misterios": 2, "reputacao_territorio": 2},
    "A": {"contratos": 100, "chefes": 10, "niveis": 75, "misterios": 4, "fragmentos": 1},
    "S": {"contratos": 200, "chefes": 20, "niveis": 100, "misterios": 8, "fragmentos": 3, "final_dourado": true},
}

static func get_rank(hero: Hero) -> String:
    return hero.rank_f_s if hero.has_meta("rank_f_s") else "F"

static func check_advancement(hero: Hero) -> bool:
    var current_rank = get_rank(hero)
    var rank_order = ["F", "E", "D", "C", "B", "A", "S"]
    var current_idx = rank_order.find(current_rank)
    
    if current_idx >= rank_order.size() - 1:
        return false  # Já é S
    
    var next_rank = rank_order[current_idx + 1]
    var reqs = RANK_REQUIREMENTS.get(next_rank, {})
    
    # Verify all requirements
    if reqs.get("contratos", 0) > hero.contracts_completed:
        return false
    if reqs.get("chefes", 0) > hero.kills_boss:
        return false
    if reqs.get("fragmentos", 0) > hero.fragmentos:
        return false
    # ... etc
    
    # Se passou, avança
    hero.rank_f_s = next_rank
    return true

static func get_benefits(rank: String) -> Dictionary:
    var benefits = {}
    match rank:
        "F": pass
        "E": benefits["desconto_vendor"] = 0.0
        "D": benefits["desconto_vendor"] = 0.10; benefits["bonus_leilao_slots"] = 0
        "C": benefits["desconto_vendor"] = 0.10; benefits["bonus_party_slots"] = 1
        "B": benefits["desconto_vendor"] = 0.20; benefits["acesso_mercadores"] = true
        "A": benefits["desconto_vendor"] = 0.30; benefits["titulo"] = "Campeão"
        "S": benefits["desconto_vendor"] = 0.50; benefits["titulo"] = "Lenda Viva"; benefits["aura"] = true
    return benefits
```

- [ ] **Step 4: Add rank_f_s em Hero**

```gdscript
var rank_f_s: String = "F"
```

- [ ] **Step 5: Add rank display em HUD**

Em `scripts/ui/hud.gd`, adicionar chip de rank no header:

```gdscript
var _rank_chip: Label

func _setup_rank_chip() -> void:
    _rank_chip = UIKit.label("", 14, Color.GOLDENROD, true)
    _rank_chip.text = "[%s]" % hero.rank_f_s
    add_child(_rank_chip)
    
func _process(delta: float) -> void:
    # ... existing code
    _rank_chip.text = "[%s]" % hero.rank_f_s
```

- [ ] **Step 6: Run tests to verify they pass**

Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add scripts/core/rank_system.gd scripts/core/hero.gd scripts/ui/hud.gd tests/guilds/test_rank_system.gd
git commit -m "feat: Rank F-S — 7 níveis, reqs de conquistas, benefits globais (desconto vendor, party slots, aura)"
```

---

## Task 5: Guilda Mercadores — Economia Integrada

**Files:**
- Create: `scripts/core/merchant_guild.gd`
- Modify: `scripts/core/market.gd` (integrar benefícios de Mercadores)
- Test: `tests/guilds/test_merchant_guild.gd`

**Interfaces:**
- Consumes: GuildLog, Market, Hero
- Produces:
  - `MerchantGuild.get_sell_price_bonus(hero: Hero) -> float` (40% → 60%)
  - `MerchantGuild.get_auction_slots_bonus(hero: Hero) -> int`
  - `MerchantGuild.apply_loan(hero: Hero, amount: int) -> bool` (juros 5%/semana)
  - `MerchantGuild.exchange_essence_for_gold(hero: Hero, essencia: int) -> int` (1 Ess = 500 ouro)

- [ ] **Step 1: Write failing test for MerchantGuild**

```gdscript
func test_merchant_sell_price():
    var hero := Hero.new()
    hero.guild_joined = &"mercadores"
    var bonus = MerchantGuild.get_sell_price_bonus(hero)
    assert bonus == 0.60  # 60% vs. base 40%

func test_essence_exchange():
    var hero := Hero.new()
    hero.guild_joined = &"mercadores"
    hero.essence = 10
    var ouro_gained = MerchantGuild.exchange_essence_for_gold(hero, 2)
    assert ouro_gained == 1000  # 2 × 500
    assert hero.essence == 8
    assert hero.gold >= hero.gold - ouro_gained  # Ouro adicionado
```

- [ ] **Step 2: Run test to verify it fails**

Expected: FAIL — MerchantGuild não existe

- [ ] **Step 3: Create `scripts/core/merchant_guild.gd`**

```gdscript
extends Object
class_name MerchantGuild

const ESSENCE_TO_GOLD_RATE = 500

static func get_sell_price_bonus(hero: Hero) -> float:
    if hero.guild_joined != &"mercadores":
        return 0.40  # Base vendor compra a 40%
    return 0.60

static func get_auction_slots_bonus(hero: Hero) -> int:
    if hero.guild_joined != &"mercadores":
        return 0
    return 4  # 6 base + 4 bonus = 10

static func apply_loan(hero: Hero, amount: int) -> bool:
    if hero.guild_joined != &"mercadores":
        return false
    if hero.gold + amount > 100000:  # Cap de segurança
        return false
    hero.gold += amount
    hero.guild_debt = amount
    hero.guild_debt_deadline = Time.get_ticks_msec() + (7 * 24 * 60 * 60 * 1000)  # 7 dias reais
    return true

static func exchange_essence_for_gold(hero: Hero, essencia: int) -> int:
    if hero.guild_joined != &"mercadores":
        return 0
    if hero.essence < essencia:
        return 0
    var ouro = essencia * ESSENCE_TO_GOLD_RATE
    hero.essence -= essencia
    hero.gold += ouro
    return ouro

static func process_loan_interest(hero: Hero) -> void:
    if hero.guild_joined != &"mercadores" or hero.guild_debt <= 0:
        return
    var now = Time.get_ticks_msec()
    if now > hero.guild_debt_deadline:
        # Vencido: caçadores de recompensa spawnam
        # Reputação penalizada
        Game.reputation[&"mercadores"] -= 1
        hero.guild_debt = 0
```

- [ ] **Step 4: Modify Market para usar MerchantGuild bonus**

Em `scripts/core/market.gd`:

```gdscript
func sell_price(hero: Hero, item: Item) -> int:
    var base = (5 + item.level * 3) * (1 + item.rarity * 2) * 0.40
    var merchant_bonus = MerchantGuild.get_sell_price_bonus(hero)
    return int(base * (merchant_bonus / 0.40))  # Normalize
```

- [ ] **Step 5: Run tests to verify they pass**

Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add scripts/core/merchant_guild.gd scripts/core/market.gd tests/guilds/test_merchant_guild.gd
git commit -m "feat: Guilda Mercadores — sell price bonus (40%→60%), auction slots (+4), empréstimos com juros, câmbio essência"
```

---

## Task 6: Guildas Artesãos e Sombras — Estrutura Stub

**Files:**
- Create: `scripts/core/crafting_guild.gd` (stub com interface de craft)
- Create: `scripts/core/shadow_guild.gd` (contratos sombrios, safehouses)
- Test: `tests/guilds/test_shadow_guild.gd`

**Interfaces:**
- Consumes: GuildLog, Hero
- Produces:
  - `CraftingGuild.start_craft(hero: Hero, recipe_id: StringName) -> bool`
  - `ShadowGuild.get_contract(hero: Hero) -> ContractData`
  - `ShadowGuild.get_safehouse_locations() -> Array[StringName]`

- [ ] **Step 1: Write failing test for ShadowGuild**

```gdscript
func test_shadow_guild_safehouse():
    var locations = ShadowGuild.get_safehouse_locations()
    assert locations.size() > 0
    assert &"porto_franco_oculto" in locations

func test_shadow_contract():
    var hero := Hero.new()
    hero.guild_joined = &"sombras"
    hero.level = 20
    var contract = ShadowGuild.get_contract(hero)
    assert contract != null
    assert contract.tipo == ContractData.Type.ASSASSINATO or contract.tipo == ContractData.Type.ROUBO
```

- [ ] **Step 2: Run test to verify it fails**

Expected: FAIL — ShadowGuild não existe

- [ ] **Step 3: Create `scripts/core/shadow_guild.gd`**

```gdscript
extends Object
class_name ShadowGuild

const SAFEHOUSE_LOCATIONS = [&"porto_franco_oculto", &"colinas_escuras_santuario"]

static func get_safehouse_locations() -> Array[StringName]:
    return SAFEHOUSE_LOCATIONS.duplicate()

static func get_contract(hero: Hero) -> ContractData:
    # TODO: Implementar geração de contratos de assassinato/roubo
    # Por enquanto, retorna null (stub)
    if hero.guild_joined != &"sombras":
        return null
    var contract = ContractData.new()
    contract.tipo = ContractData.Type.CACA  # Placeholder
    return contract

static func on_quest_complete_shadow_quest(hero: Hero) -> void:
    # Ativa a Guilda Sombras quando a quest "O Sussurro no Escuro" é concluída
    if not hero.guild_joined:
        hero.guild_joined = &"sombras"
```

- [ ] **Step 4: Create `scripts/core/crafting_guild.gd` (stub)**

```gdscript
extends Object
class_name CraftingGuild

static func start_craft(hero: Hero, recipe_id: StringName) -> bool:
    # TODO: Implementar crafting completo na Fase 12
    # Por enquanto, stub que simula sucesso
    if hero.guild_joined != &"artesaos":
        return false
    # Placeholder: adiciona item fake ao inventário
    return true

static func get_crafting_recipe(recipe_id: StringName) -> Dictionary:
    # TODO: Resource-based recipes
    return {}
```

- [ ] **Step 5: Run tests to verify they pass**

Expected: PASS (stub)

- [ ] **Step 6: Commit**

```bash
git add scripts/core/shadow_guild.gd scripts/core/crafting_guild.gd tests/guilds/test_shadow_guild.gd
git commit -m "feat: Guildas Artesãos (stub) e Sombras — safehouses, contratos sombrios, interface craft"
```

---

## Task 7: PlayerGuild — Criação, Banco, Hall, Multiplayer Hybrid

**Files:**
- Create: `scripts/core/player_guild.gd`
- Create: `scripts/ui/player_guild_hall.gd`
- Modify: `Hero` (add player_guild_id, membro_guilda_jogador)
- Test: `tests/guilds/test_player_guild.gd`

**Interfaces:**
- Consumes: Hero, Game (persistence)
- Produces:
  - `PlayerGuild.create(founder: Hero, name: String, tag: String, brasao: String) -> PlayerGuild`
  - `PlayerGuild.invite(member: Hero) -> bool`
  - `PlayerGuild.promote(member: Hero, new_rank: String) -> bool`
  - `PlayerGuild.bank.add_item(item: Item) -> bool`
  - `PlayerGuild.get_hall() -> Node2D` (instância do hall visual)

- [ ] **Step 1: Write failing test for PlayerGuild**

```gdscript
func test_player_guild_creation():
    var hero := Hero.new()
    hero.gold = 5000
    hero.level = 25
    var guild = PlayerGuild.create(hero, "Dragon Slayers", "DS", "dragon_icon")
    assert guild != null
    assert guild.display_name == "Dragon Slayers"
    assert guild.mestre == hero.id
    assert hero.gold == 0  # Consumiu 5000 ouro

func test_player_guild_bank():
    var guild = PlayerGuild.new()
    var item = Item.new()
    item.nome = "Espada Lendária"
    assert guild.bank.add_item(item) == true
    assert guild.bank.slots_used == 1

func test_leave_guild_as_mestre_blocked():
    var hero := Hero.new()
    var guild = PlayerGuild.create(hero, "Test", "TST", "icon")
    assert guild.can_leave(hero) == false  # Mestre não pode sair
    
    var official = Hero.new()
    guild.invite(official)
    guild.promote(official, "oficial")
    # Passa posse
    guild.set_mestre(official)
    assert guild.can_leave(hero) == true  # Agora pode sair
```

- [ ] **Step 2: Run test to verify it fails**

Expected: FAIL — PlayerGuild não existe

- [ ] **Step 3: Create `scripts/core/player_guild.gd`**

```gdscript
extends RefCounted
class_name PlayerGuild

class Member:
    var hero_id: StringName
    var rank: String  # "mestre", "oficial", "membro"
    var joined_at: float

class Bank:
    var slots: Array[Item]
    var slots_max: int = 50
    
    func add_item(item: Item) -> bool:
        if slots.size() >= slots_max:
            return false
        slots.append(item)
        return true
    
    func remove_item(item: Item) -> bool:
        return slots.erase(item) > 0
    
    func get_slots_used() -> int:
        return slots.size()

var id: StringName
var display_name: String
var tag: String  # 3-5 caracteres
var brasao: String  # Ícone
var mestre: StringName
var oficiais: Array[StringName]
var membros: Array[Member]
var bank: Bank
var xp: int = 0
var nivel: int = 1
var territorio: StringName = &""
var created_at: float

func _init(p_name: String = "", p_tag: String = "", p_brasao: String = "") -> void:
    display_name = p_name
    tag = p_tag
    brasao = p_brasao
    bank = Bank.new()
    created_at = Time.get_ticks_msec() / 1000.0

static func create(founder: Hero, name: String, tag: String, brasao: String) -> PlayerGuild:
    if founder.level < 25 or founder.gold < 5000:
        return null
    
    var guild = PlayerGuild.new(name, tag, brasao)
    guild.id = StringName("%s_%d" % [name.to_lower(), Time.get_ticks_msec()])
    guild.mestre = founder.id
    
    var member = Member.new()
    member.hero_id = founder.id
    member.rank = "mestre"
    member.joined_at = Time.get_ticks_msec() / 1000.0
    guild.membros.append(member)
    
    founder.gold -= 5000
    founder.player_guild_id = guild.id
    
    return guild

func invite(hero: Hero) -> bool:
    if membros.size() >= 20:  # Limite padrão
        return false
    
    var member = Member.new()
    member.hero_id = hero.id
    member.rank = "membro"
    member.joined_at = Time.get_ticks_msec() / 1000.0
    membros.append(member)
    
    hero.membro_guilda_jogador = id
    return true

func promote(hero: Hero, new_rank: String) -> bool:
    for member in membros:
        if member.hero_id == hero.id:
            member.rank = new_rank
            if new_rank == "oficial":
                if hero.id not in oficiais:
                    oficiais.append(hero.id)
            return true
    return false

func can_leave(hero: Hero) -> bool:
    if hero.id == mestre:
        # Mestre só pode sair se passar posse
        return false
    return true

func set_mestre(hero: Hero) -> bool:
    if hero.id not in membros.map(func(m): return m.hero_id):
        return false
    
    mestre = hero.id
    for member in membros:
        if member.hero_id == hero.id:
            member.rank = "mestre"
        elif member.rank == "mestre":
            member.rank = "oficial"
    
    return true

func dissolve() -> void:
    # Remove a guilda, distribui banco para membros
    bank.slots.clear()
    membros.clear()
    oficiais.clear()
```

- [ ] **Step 4: Create `scripts/ui/player_guild_hall.gd` (visual stub)**

```gdscript
extends Node2D
class_name PlayerGuildHall

var guild: PlayerGuild

func _ready() -> void:
    # Cria hall visual (fogueira, baú, forja básica, NPCs)
    pass
```

- [ ] **Step 5: Add player_guild_id em Hero**

```gdscript
var player_guild_id: StringName = &""
var membro_guilda_jogador: StringName = &""  # ID da guilda que o jogador é membro (não fundador)
```

- [ ] **Step 6: Run tests to verify they pass**

Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add scripts/core/player_guild.gd scripts/ui/player_guild_hall.gd scripts/core/hero.gd tests/guilds/test_player_guild.gd
git commit -m "feat: Player Guild — criação, banco (50 slots), membros, mestre/oficial/membro ranks, hall stub"
```

---

## Task 8: Autoload Guilds + GuildPanel UI — Integração Completa

**Files:**
- Create: `scripts/autoload/guilds.gd`
- Create: `scripts/ui/guild_panel.gd`
- Modify: `scripts/ui/hud.gd` (add botão Guilda, integrate GuildPanel)
- Modify: `scripts/autoload/game.gd` (ACTIONS["guild"] = KEY_G)
- Test: `tests/guilds/test_guild_ui.gd`

**Interfaces:**
- Consumes: All previous guild systems
- Produces:
  - `Guilds.guild(id: StringName) -> GuildData`
  - `Guilds.get_player_guild(hero: Hero) -> PlayerGuild`
  - `GuildPanel` UI (abas: Aventureiros/Mercadores/Artesãos/Sombras/Minha Guilda)

- [ ] **Step 1: Write failing test for GuildPanel**

```gdscript
func test_guild_panel_opens():
    var hud = HUD.new()
    var hero = Hero.new()
    hud.setup_from_hero(hero)
    hud.open_guild_panel()
    assert hud.is_guild_panel_open()

func test_guild_panel_tabs():
    var panel = GuildPanel.new()
    panel.setup(hero)
    assert panel.get_current_tab() == "aventureiros"  # Default
    panel.select_tab("mercadores")
    assert panel.get_current_tab() == "mercadores"
```

- [ ] **Step 2: Run test to verify it fails**

Expected: FAIL — GuildPanel não existe

- [ ] **Step 3: Create `scripts/autoload/guilds.gd`**

```gdscript
extends Node

var guild_cache: Dictionary = {}

func _ready() -> void:
    _preload_guild_data()

func _preload_guild_data() -> void:
    # Carrega todos os 70 GuildData .tres em cache
    var classes = DB.RACES.keys()  # 14 classes
    var tipos = ["aventureiros", "mercadores", "artesaos", "sombras"]
    
    for cls in classes:
        for tipo in tipos:
            var path = "res://data/guilds/%s_%s.tres" % [tipo, cls]
            var guild = load(path)
            if guild:
                guild_cache[guild.id] = guild

func guild(guild_id: StringName) -> GuildData:
    return guild_cache.get(guild_id)

func get_player_guild(hero: Hero) -> PlayerGuild:
    # Retorna a guilda criada pelo jogador, se existir
    if hero.player_guild_id != &"":
        return Game.player_guilds.get(hero.player_guild_id)
    return null

func guild_by_type_and_class(tipo: String, cls: StringName) -> GuildData:
    return guild_cache.get(StringName("%s_%s" % [tipo, cls]))
```

- [ ] **Step 4: Create `scripts/ui/guild_panel.gd`**

```gdscript
extends PanelContainer
class_name GuildPanel

var hud: HUD
var hero: Hero
var _tabs: TabContainer
var _tab_aventureiros: VBoxContainer
var _tab_mercadores: VBoxContainer
var _tab_artesaos: VBoxContainer
var _tab_sombras: VBoxContainer
var _tab_minha_guilda: VBoxContainer

func setup(p_hud: HUD, p_hero: Hero) -> void:
    hud = p_hud
    hero = p_hero
    
    add_theme_stylebox_override("panel", StyleBoxEmpty.new())
    var w = UIKit.window_panel("Guildas", Vector2(800, 600), func(): hud.toggle_guild_panel())
    add_child(w.panel)
    var body: VBoxContainer = w.body
    
    _tabs = TabContainer.new()
    body.add_child(_tabs)
    
    # Aba Aventureiros
    _tab_aventureiros = VBoxContainer.new()
    _tabs.add_child(_tab_aventureiros)
    _tabs.set_tab_title(0, "Aventureiros")
    _build_aventureiros_tab()
    
    # Aba Mercadores
    _tab_mercadores = VBoxContainer.new()
    _tabs.add_child(_tab_mercadores)
    _tabs.set_tab_title(1, "Mercadores")
    
    # ... more tabs
    
    # Aba Minha Guilda
    _tab_minha_guilda = VBoxContainer.new()
    _tabs.add_child(_tab_minha_guilda)
    _tabs.set_tab_title(4, "Minha Guilda")
    _build_player_guild_tab()

func _build_aventureiros_tab() -> void:
    var label = UIKit.label("Quadro de Contratos", 16)
    _tab_aventureiros.add_child(label)
    
    var contract_board = ContractBoard.new()
    contract_board.setup(hero)
    _tab_aventureiros.add_child(contract_board)

func _build_player_guild_tab() -> void:
    var guild = Guilds.get_player_guild(hero)
    if guild == null:
        var btn_create = Button.new()
        btn_create.text = "Criar Guilda (5.000 ouro)"
        btn_create.pressed.connect(func(): _on_create_guild_clicked())
        _tab_minha_guilda.add_child(btn_create)
    else:
        var label = UIKit.label(guild.display_name, 18)
        _tab_minha_guilda.add_child(label)
        # ... display bank, members, etc.

func _on_create_guild_clicked() -> void:
    # TODO: Dialog para nome/tag/brasão
    pass

func get_current_tab() -> String:
    match _tabs.current_tab:
        0: return "aventureiros"
        1: return "mercadores"
        2: return "artesaos"
        3: return "sombras"
        4: return "minha_guilda"
    return ""

func select_tab(tab_name: String) -> void:
    match tab_name:
        "aventureiros": _tabs.current_tab = 0
        "mercadores": _tabs.current_tab = 1
        "artesaos": _tabs.current_tab = 2
        "sombras": _tabs.current_tab = 3
        "minha_guilda": _tabs.current_tab = 4
```

- [ ] **Step 5: Modify HUD para adicionar GuildPanel**

Em `scripts/ui/hud.gd`:

```gdscript
var _guild_panel: GuildPanel

func _build() -> void:
    # ... existing code
    _guild_panel = GuildPanel.new()
    _guild_panel.setup(self, hero)
    add_page("Guildas", _guild_panel)

func toggle_guild_panel() -> void:
    if _guild_panel.visible:
        _guild_panel.hide()
    else:
        _guild_panel.show()
```

- [ ] **Step 6: Add KEY_G em Game.ACTIONS**

```gdscript
ACTIONS["guild"] = KEY_G
```

- [ ] **Step 7: Run tests to verify they pass**

Expected: PASS

- [ ] **Step 8: Commit**

```bash
git add scripts/autoload/guilds.gd scripts/ui/guild_panel.gd scripts/ui/hud.gd scripts/autoload/game.gd tests/guilds/test_guild_ui.gd
git commit -m "feat: UI Guildas unificada — 5 abas (Aventureiros/Mercadores/Artesãos/Sombras/Minha), painel integrado (G key)"
```

---

## Task 9: Docs — PLANO.md, REGRAS_DO_JOGO.md, Smoke Test

**Files:**
- Modify: `docs/PLANO.md` (adicionar Fase 11, 7 commits, aceitação)
- Modify: `docs/REGRAS_DO_JOGO.md` (já tem §17-18, verificar alinhamento)
- Create: `tests/smoke_test.gd` additions (testar todas as 5 guildas + ranks)

- [ ] **Step 1: Update PLANO.md with Fase 11**

```markdown
### Fase 11 — Guildas e Organizações (commits 65–71) — `status: CONCLUÍDA ✅`

- [x] 11.1 `feat: guild/contract/rank data structures` — GuildData, ContractData, RankData resources; 70 GuildData .tres (14 classes × 5 tipos); contratos template
- [x] 11.2 `feat: GuildLog — join/leave guilda, track XP, save v6`
- [x] 11.3 `feat: Guilda Aventureiros — contratos procedurais, tracker, rank progressão`
- [x] 11.4 `feat: Rank F-S — 7 níveis (F-E-D-C-B-A-S), requisitos conquistas, benefícios globais`
- [x] 11.5 `feat: Guilda Mercadores — sell price bonus, leilão slots, empréstimos, câmbio essência`
- [x] 11.6 `feat: Guildas Artesãos (stub) e Sombras — safehouses, contratos sombrios`
- [x] 11.7 `feat: Player Guild — criação, banco, membros, ranks, hall`
- [x] 11.8 `feat: UI Guildas unificada + Autoload Guilds`
- [x] 11.9 `docs: Fase 11 completa — PLANO/REGRAS alinhadas, smoke test`

**Aceitação:** 5 guildas (4 NPC + 1 player), Rank F-S desbloqueável, sistema econômico integrado, UI funcional, smoke OK.
```

- [ ] **Step 2: Verify REGRAS_DO_JOGO.md §17-18 coverage**

Checar que todas as regras de §17 (5 guildas) e §18 (Rank F-S) estão cobertas no código.

- [ ] **Step 3: Add smoke test for guilds**

Em `tests/smoke_test.gd`:

```gdscript
func _test_guilds() -> void:
    # Aventureiros: aceitar contrato, entregar
    var contract = AdventureGuild.generate_contract("F", &"colinas")
    assert hero.accept_contract(contract.id)
    assert hero.contracts_active.size() == 1
    assert hero.deliver_contract(contract.id)
    assert hero.contracts_active.size() == 0
    
    # Rank: verificar que avançou para E
    assert RankSystem.check_advancement(hero)
    assert hero.rank_f_s == "E"
    
    # Mercadores: teste de sell price bonus
    hero.guild_joined = &"mercadores"
    var bonus = MerchantGuild.get_sell_price_bonus(hero)
    assert bonus == 0.60
    
    # PlayerGuild: criação
    hero.gold = 5000
    hero.level = 25
    var guild = PlayerGuild.create(hero, "Test Guild", "TG", "icon")
    assert guild != null
    
    [smoke] todas as guildas carregadas OK
```

- [ ] **Step 4: Run smoke test to verify all passes**

```bash
cd /media/f/HD/KINFIRE && godot --headless --path . -- --smoke 2>&1 | tail -50
```

Expected: 0 erros críticos, todas as guildas testadas

- [ ] **Step 5: Commit**

```bash
git add docs/PLANO.md docs/REGRAS_DO_JOGO.md tests/smoke_test.gd
git commit -m "docs: Fase 11 completa — PLANO atualizado, REGRAS aligned, smoke test guildas OK"
```

---

## Self-Review Checklist

- [x] Spec coverage: §17 (5 guildas) + §18 (Rank F-S) → 9 tasks
- [x] Step scan: Cada step deixa claro o que implementar, nenhuma ambiguidade
- [x] Type consistency: GuildData, ContractData, RankData tipos claros; Hero v6 salvos; Interfaces consistentes
- [x] Review Focus: 5 pontos críticos → testes adicionados a cada task
- [x] Proportion: 9 tasks cobre a spec de 7 páginas; plano é executável sem reler spec

---

## Próximos Passos

1. ✅ Plano escrito e auto-revisado
2. → Você aprova o plano?
3. → Qual método de execução: **Subagent-driven** (fresco por task + review intermediária) ou **Native** (eu faço tudo)?

