# Kinfire

**v0.3** — RPG de ação 2D top-down em **Godot 4.7** (Flatpak).  
14 raças × 14 classes × 84 skills, inspirado em **D&D 5e / Baldur's Gate** + combate **estilo Diablo 3** (itens com afixos, raridades, build diversity).

Criado por [MichaelDCA](https://github.com/MichaelDouglasCA) e [fabioadler](https://github.com/fabioadler).

---

## Como jogar (PT-BR)

Abra o projeto no Godot 4.7 (Flatpak) e aperte **F5**.

| Ação | Controle (remapeável em Opções → Controles) |
|---|---|
| Andar | WASD ou clique esquerdo no chão |
| Atacar | Clique esquerdo no inimigo (segure para continuar) |
| Atacar parado | Shift + clique esquerdo |
| Habilidade secundária | Clique direito |
| Habilidades | 1, 2, 3, 4 |
| Habilidade racial (Draconato) | R |
| Esquiva (cancela a recuperação do ataque) | Espaço |
| Poção de vida | Q |
| Inventário / Personagem / Habilidades / Missões | I / C / K / J |
| Mostrar itens no chão | Alt |
| Menu / fechar painéis | Esc |

---

## Mundo aberto procedural infinito

O jogo começa em um **mundo aberto infinito**, gerado em **chunks 32×32** determinísticos por semente (estilo Minecraft). Cada partida = semente única.

### 7 Biomas (temperatura + umidade + corrupção via Voronoi)

| Bioma | Visual | Dificuldade base |
|---|---|---|
| **Planícies** | Grama, rios, vilas | 1–5 |
| **Floresta Sussurrante** | Árvores densas, folhas ao vento | 2–8 |
| **Areias Escaldantes** | Dunas, cactos, oásis | 2–10 |
| **Tundra Congelada** | Pinheiros, neve, lagos gelados | 3–12 |
| **Pântano Pútrido** | Água turva, vitórias-régias, névoa | 3–15 |
| **Ermos Vulcânicos** | Lava, cinzas, rochas | 4–18 |
| **Terras Corrompidas** | Lápides, árvores mortas, nevoa roxa | 5–25 |

- **Rios e lagos** gerados por ruído, com margens automáticas.
- **14 Territórios raciais** (Voronoi por semente + raça do jogador): cada raça tem sua **Capital** (14 no total) — zona segura, líder + 3 comuns, reputação + economia própria.
- **Nível da região** = distância do Vale do Centro (0,0) + modificador do território (1–60).
- **Fogueiras** = respawn, cura total, viagem rápida, dormir até 06:00.
- **Masmorras** procedurais (12 nomes, andares, chefe a cada 3, escada de volta).
- **Baús, santuários, chefes de mundo** (Ogro, Putrefato, Azkhar + 10 raros).
- **Ciclo dia/noite** (360s = 6 min real): 06:00 vendors re-estocam; 21:00–05:00 noite (undead +50% spawn, aggro +10%); 00:00 autosave.
- **Minimapa** redondo: biomas, água, fogueiras, masmorras, mercador, inimigos, waypoints.

---

## Inimigos: Raridades & Afixos (Fase 3)

36 tipos de monstro base, cada um com habitats (dungeon + biomas). **Raridade por pack** (determinístico por chunk + dificuldade):

| Raridade | Chance | HP | Dano | XP/Ouro | Drops | Afixos |
|---|---|---|---|---|---|---|
| Comum | base | ×1 | ×1 | ×1 | 10% item Comum | — |
| **Elite** | 8% + 1%/nível | ×2.5 | ×1.3 | ×3 | ≥1 Mágico + ouro | 0 |
| **Campeão** | 2% | ×5 | ×1.8 | ×6 | ≥1 Raro + 20% Lendário + 50% Essência | 1–2 |
| **Lendário** | 0,3% | ×10 | ×2.5 | ×15 | ≥1 Lendário/Único + ≥1 Essência | 2–3 |
| Chefe | roteirizado | ×20–30 | tabelado | ×25 | ≥2 itens (≥1 Raro+) + Essência ×2 + único | — |

**Afixos (Campeão 1–2, Lendário 2–3):**  
FURIOSO · ESCUDO ARCANO · TELÚRICO (imune knockback) · VENENOSO · FANTASMA (20% esquiva) · MESTRE-DE-ENXAME · ARDENTE · CAMPEÃO-DAS-SOMBRAS.

**Visual feedback:** contorno colorido (azul/roxo/amarelo), aura pulsante Campeão+, **beam visível de longe + sting sonoro no spawn Lendário**, kill anunciado na HUD.

**Elementais & resistências (REGRAS §3):** Fogo, Gelo, Raio, Sagrado, Sombrio, Veneno.  
- **Mortos-vivos** (esqueleto, zumbi, fantasma, putrefato, necromante, lobo sombrio, wogol, espantalho, abóbora maldita, médico da peste): **fraqueza a Sagrado (×1.5)**.  
- **Demônios** (anjo caído, chort, diabrete, caranguejo infernal, azkhar, mímico): **imunes a Sombrio, fracos a Sagrado (×1.5)**.

---

## Itens estilo Diablo (Fase 3)

- **7 slots:** elmo, amuleto, arma, armadura, mão secundária, anel, botas (duas mãos = arma + secundária).
- **4 raridades:** Comum (0 afixos) → Mágico (1–2) → Raro (3–4) → Lendário (5 afixos + nome único).
- **Valor de venda** = `(5 + nível×3) × (1 + raridade×2)` × demanda × reputação. Vendor compra a **40%**.
- **Identificação:** Raro+ já identificado (sem minigame).
- **Proficiência:** por classe (Mago não empunha machado 2M do Bárbaro; Meio-Elfo equipa até 3 níveis acima).
- **Essência:** moeda "dura" só de Campeão/Lendário/Chefe — lances especiais na Casa de Leilões.

---

## Economia & Mercado (Fase 5)

- **Oferta/demanda por categoria:** vender reduz preço pago em **3%/item** (clamp 0.6–1.5, recupera 5%/dia); comprar eleva preço e reduz estoque.
- **Rotas comerciais:** cada território paga mais pelo que **não produz** (especialidades do `VendorData`).
- **Reputação 0–4** (Estranho → Conhecido → Respeitado → Honrado → Laço): descontos **0 / 5 / 10 / 15 / 20%**. Ganha-se por quests/favores; nunca decai.
- **Casa de Leilões:** 6 slots/dia de itens Raro+ rotativos; lance mínimo sobe **10%/lance rival**; Essência aceita em lances especiais. Determinístico por (semente, dia).

---

## Quests & Narrativa (Fase 4)

- **20 quests principais** (3 Atos, ordem fixa, não abandonáveis).
- **8 Cadeias de Mistério** → cada uma rende **1 Fragmento da Verdade**.
- **Final Dourado** destravado com 8 Fragmentos (caminho alternativo na quest final "O Fogo dos Laços").
- **Quest Log (J):** tracker lateral, painel com progresso, aviso de nova missão, autoflow (flag→next, REACH, KILL, wildcard `any:capital_*_lider`).
- **Recompensa padrão:** XP = `40 × nível_quest × ato` + ouro + item (raridade mínima = ato: Mágico/Raro/Lendário).

---

## Vento Global & Navegação (Fase 7.4)

- **WindField** estático: value-noise determinístico (ticks de 10s, base por bioma, Corrompidas erráticas, override de áreas seguras).
- **Navegação:** ventania = ±10% velocidade, custo de rota ±5%.
- **Projéteis físicos:** flecha desvia conforme `wind_mass` (leve = desvia mais).
- **Calmaria de Campeões:** registro global, raio 320px, suga vento + cue de perigo (partículas + som).
- **Fogueira:** shader `wind_sway` curva a chama + sufoca na ventania (partículas diminuem).
- **Skill "Ler o Vento" (Caçador):** flechas retas + vetor no minimapa.
- **Forecast/presságio:** previsão diária por (semente, dia).

---

## Som Adaptativo (Fase 7.5) — **o jogador sente a noite antes de vê-la no relógio**

**Autoload `Audio` (MECANICAS §15):**

| Camada | Quando | Crossfade |
|---|---|---|
| **BASE** | Mundo aberto (bioma/território: `mus_overworld`) | 3s |
| **COMBATE** | Aggro (fade-in 1.5s / fade-out 4s) | 3s |
| **NOITE** | 21:00–05:30 (pad grave) | 3s |
| **CHEFE** | Variação intensa | 3s |
| **DESCANSO** | Perto de fogueira acesa (crackle) | 3s |

- **Ambiência por bioma** (crossfade 3s): vento (Planícies), folhas+pássaros (Floresta), areia+abutres (Areias), vento gelado (Tundra), gorgolejo (Pântano), rumble lava (Vulcânico), drone dissonante+sinos (Corrompidas), drips+ping (Masmorra).
- **16 WAVs 16-bit 22050 Hz procedurais** (determinísticos, loop suavizado).
- **Bus `Ambience` controlado por `WindField.strength`**: calmaria −7dB… ventania +3dB (a ambiência **É** o vento).
- **Reverb fake de masmorra:** AudioEffectReverb (room 0.8, wet 0.35) + low-pass 2.5 kHz nos buses SFX/Ambience.
- **Ducking:** diálogo −6dB na música; fogueira à noite −3dB na ambiência.
- **Sting de spawn:** Campeão (coral grave), Lendário (sino+coral).
- **Buses `Ambience`/`UI` + sliders** nas Opções → Áudio.

---

## Clima & Partículas Ambientais (Fase 7.6)

- **Weather** estático: chuva **determinística por (semente, dia)** (~20% dos dias, `rain_on`/`forecast`).
- **WeatherLayer** (node do Overworld): 7 emissores **GPUParticles2D com texturas procedurais** (sem assets externos):
  - Por bioma: folhas, neve, cinzas, esporos, poeira.
  - **Vagalumes noturnos** (Planícies/Floresta): `self_modulate >1` **florescem no glow HDR 2D** + voam contra o vento (turbulence).
  - **Chuva** 220 gotas + som ambiente `rain_loop.wav` (bus Ambience, fade 3s).
- **Névoa volumétrica fake** (`fog_drift.gdshader`): 2 ColorRects CanvasLayer 2, value-noise parallax, **vento empurra a névoa**, mais densa à noite (0.12→0.22), verde pântano / roxa Corrompidas.
- **Relâmpago:** flash branco-azulado >1 (floresce no glow, CanvasLayer 3) + **trovão** `thunder.wav` procedural com atraso realista 0.3–1.1s (`Audio.play_thunder`).

---

## Vídeo: FSR 2.2 + MSAA + Presets (Fase 7.7)

API nativa do viewport raiz (`scaling_3d_mode/scale/fsr_sharpness/msaa_2d`):

| Preset | Sombras | FSR 2.2 | MSAA | Glow | Partículas |
|---|---|---|---|---|---|
| **Baixo** | Desligadas | Desempenho (0.5×) | Desligado | ❌ | 50% |
| **Médio** | PCF5 | Equilibrado (0.67×) | 2× | ✅ | 75% |
| **Alto** | PCF13 | Qualidade (0.77×) | 4× | ✅ | 100% |

- **FSR 2.2:** escalas nativas [Desligado 1.0, Qualidade 0.77, Equilibrado 0.67, Desempenho 0.5] + `fsr_sharpness 0.4`.
- **MSAA:** `msaa_2d` 2×/4× no viewport.
- **Filtro textura:** `nearest` (pixel-art nítida) ou `linear`.
- **`Game.particle_mult()`**: 0.5 / 0.75 / 1.0 → multiplica emissores (`WeatherLayer`, `Fx.burst`).
- **Glow reativo em runtime:** signal `Game.quality_changed` → `World._apply_glow()` lê `settings.glow` (liga/desliga `environment.glow_enabled` sem recarregar cena).
- **Página Vídeo das Opções:** dropdown "Preset de Qualidade" (aplica combinação + reconstrói painel), dropdowns FSR/MSAA/Filtro/Partículas, checkbox "Brilho/Glow", botão restaurar desta aba.

---

## Raças (14) — Biologia + Passivas

| Raça | Atributos | Passiva |
|---|---|---|
| Humano | +1 tudo | +10% XP/OURO |
| Alto Elfo | +2 INT, +1 DES | +15% recurso máx, 20% resist mágica |
| Elfo da Floresta | +2 DES, +1 CON | +10% vel, esquiva auto 10s |
| Drow | +2 DES, +1 INT | +15% dmg vs CC (atord/lento/confusão) |
| Anão da Montanha | +2 CON, +2 FOR, −1 DES | Imune empurrão, +10% armadura |
| Anão das Colinas | +2 CON, +1 SAB | Regen fora 2×, 25% resist veneno |
| Halfling | +2 DES | Crit 5% dobrado, hitbox menor |
| Meio-Orc | +2 FOR, +1 CON | Sobrevive 1 golpe fatal (CD 2min) |
| Tiefling | +2 INT, +1 FOR | 25% resist fogo, espinhos fogo 10% |
| Draconato | +2 FOR, +1 INT | Sopro fogo cone (R), imune fogo |
| Gnomo | +2 INT | −10% cooldown |
| Meio-Elfo | +2 CAR, +1 escolha | Equipa +3 níveis |
| Tabaxi | +2 DES | 5 acertos → +40% vel/aspd |
| Golias | +2 FOR, +2 CON, −1 INT | Inv 30% maior, 2M 10% mais rápido |

---

## Classes (14) — Recurso + Estilo (84 skills)

| Classe | Recurso | Mecânica-chave |
|---|---|---|
| **Bárbaro** | Fúria | Gera batendo/apanhando; Salto, Turbilhão, Grito |
| **Feiticeiro** | Mana | Regen alta; Fogo/Gelo/Raio; Meteoro/Nevaca |
| **Ladino** | Energia | Recarrega 4× após 2s ocioso; Venenos/Esquivas |
| **Guerreiro** | Vigor | Bloqueio com escudo; Golpes táticos |
| **Paladino** | Fé | Gera batendo/bloqueando; Auras + Sagrado |
| **Necromante** | Essência | Ganha em mortes; Esqueletos, Golem, Maldição |
| **Caçador** | Concentração | Regen só parado; Arco, Lobo, Armadilhas |
| **Monge** | Chi | Todo 3º golpe = ×2 dmg + stun; Curas |
| **Bruxo** | Pacto | Magias custam vida; Roubo 10%, Diabretes |
| **Druida** | Espírito | Forma Lobo (vel/crit) / Urso (arm/dmg); Terremoto |
| **Clérigo** | Mana | 15% dmg→cura; Armadura pesada |
| **Bardo** | Inspiração | Zonas de som: inimigos confusos se atacam |
| **Mago** | Carga Arcana | Gera no ataque básico; Teleporte, Raio, Dobra Temporal |
| **Lâmina Arcana** | Fluxo | Golpes reduzem CD magias; Magias encantam lâmina |

**Proficiências de arma** por classe impedem equipar itens fora do arquétipo.

---

## HUD & UI Modernas (Fases 6–7)

- **HUD unificada:** barras HP/recurso segmentadas, **anel XP**, chips (ouro/essência/reputação), **minimapa redondo**, cooldown radial (1–4 + racial), tracker recolhível (J).
- **Painel Unificado (I/C/K/J):** Personagem / Inventário (grade w×h) / Habilidades / Missões na mesma janela.
- **Micro-interações:** `pop_in`/`pop_out` em TODA janela (UnifiedPanel + popups); reabrir cancela fechamento; ESC fecha.
- **Target box** com afixos visíveis; **damage numbers** coloridos por elemento; **kill announce** de Lendário.

---

## Gráficos & Iluminação (Fases 7.2–7.3)

- **Sombras dinâmicas 2D:** tile occlusion + PCF5 (Suaves) / PCF13 (Nítidas) + orçamento 8 luzes / 720px raio + tremulação fogueira (`FIRE` mode).
- **Pós-processo HDR 2D (WorldEnvironment):** Glow/Bloom (threshold 1.05, energias >1 florescem), **Rim light** nos sprites, **Vinheta + temperatura de cor por bioma** (CanvasLayer 2 entre mundo e HUD).
- **Lanterna do jogador** à noite; luz sagrada atravessa paredes; luz sombria não projeta sombra (tema LORE).

---

## Prólogo (Fase 1)

Jogador = **Aldeão nível 0** (ataque básico, sem classe/raça). XP acelerado → nível 1 em ~5 min (2 lutas + coleta + equipar). Itens do tutorial **não saem da Reminiscência** ("o que pertence ao sonho fica no sonho"). Ao nível 1: cutscene espelho → criação obrigatória → acampamento da raça escolhida.

---

## Dificuldades (Diablo-style)

| Modo | HP Inimigos | Dano Inimigos | Bônus Loot | XP | Morte (ouro) |
|---|---|---|---|---|---|
| Normal | ×1.0 | ×1.0 | — | ×1.0 | −10% |
| Difícil | ×1.6 | ×1.35 | +8% raridade | ×1.25 | −20% |
| Pesadelo | ×2.5 | ×1.8 | +16% raridade | ×1.6 | −30% |
| Inferno | ×4.0 | ×2.5 | +28% raridade | ×2.0 | −30% + Elite+ ganha +1 afixo |

Hardcore = toggle sobre qualquer dificuldade (morte = save vira lápide somente leitura).

---

## Progressão (REGRAS §2)

- **XP próximo nível:** `20 × nível^1.5` (níveis 1–60). Nível máx = 9999 (monstros limitados a 60).
- **Subir nível:** +HP (`hit_die + CON`/nível), +recurso (atributo primário), **+1 ponto de atributo a cada 4 níveis** (1, 5, 9, 13…).
- **Habilidades:** 6 por classe, desbloqueadas por nível; 4 slots equipáveis + racial.
- **Ignorância:** começa em 10 (pós-prólogo); decai ao completar tutorial/quests/primeiros-diálogos; afeta **só textos de diálogo**.

---

## Save & Migração

- `user://kinfire_save.json` + `user://kinfire_settings.cfg`.
- **Versão atual: 4** (prólogo/quests/reputação/fragmentos/territórios).
- Migrações encadeadas v1→v2→v3→v4 preservam saves antigos.
- Autosave: fogueira, 00:00, entrar/sair masmorra, concluir quest.

---

## Arquitetura (data-driven, decoupled)

```
data/                      Custom Resources (.tres) — editáveis no Inspector
  races/*.tres             RaceData      — bônus, resistências, passivas, sprite
  classes/*.tres           ClassData     — hit_die, recurso, proficiências, skills
  skills/<classe>/*.tres   SkillData     — 15 tipos (golpe, projétil, raio, invocação, transformação...)
  enemies/*.tres           EnemyData     — comportamento, elemento, elemental_type, sprite, habitats
  vendors/*.tres           VendorData    — estoque base, especialidades, rotas
  quests/*.tres            QuestData     — objetivos, recompensas, fragmentos
  index.json               Ordem de carregamento das listas
scripts/
  core/                    Hero, Item, InventoryGrid, QuestLog, Market, WindField, Weather, LightFx, DB
  items/                   Item, afixos, roll de raridade
  combat/                  SkillExecutor, Projectile, efeitos, Fx
  game/                    Player, Enemy, Minion, LootDrop, World (masmorra), Overworld (chunks)
  ui/                      HUD, UnifiedPanel, DialogueBox, OptionsPanel, anim. prévia
  menus/                   MainMenu, CharacterCreation
  autoload/                Game (estado, save, opções, signals), Audio, Sfx, DB
shaders/                   hit_flash, wind_sway, fog_drift, atmosphere, globo_vida
tests/smoke_test.gd        Teste automatizado de ponta a ponta
```

**Boas práticas obrigatórias:**
- GDScript tipado 100% (sem `Variant` desnecessário).
- Zero números mágicos — constantes nomeadas ou fórmulas em 1 lugar (`REGRAS_DO_JOGO.md`).
- Data-driven: diálogos, quests, loot, vendors, territórios em `.tres`/JSON.
- Decoupling por **signals** — lógica de jogo NÃO referencia UI.
- 1 arquivo = 1 responsabilidade; extrai quando cresce.
- Save versionado com migração — nunca quebrar saves antigos.

---

## Teste automatizado (smoke)

```bash
# Flatpak Godot 4.7 (headless)
flatpak run org.godotengine.Godot --headless --path . -- --smoke
```

Percorre: menus → créditos → opções → criação de herói de **cada classe** → usa **todas as 6 skills + racial** → equipa itens → mata inimigos → abre baús → morre → ressuscita → salva → desce 1 nível de masmorra → **SMOKE OK** (200 asserts, 0 erros).

Para screenshots: `SMOKE_SHOTS=/pasta flatpak run org.godotengine.Godot --path . -- --smoke` (sem `--headless`).

---

## Notas de versão v0.3 (2026-10-26)

### Fases implementadas
- **Fase 0–1:** Projeto Godot 4.7, criação personagem (14 raças/classes, compra pontos D&D), prólogo aldeão nível 0.
- **Fase 2:** Masmorra procedural, 14 classes/84 skills, inventário grade, loot Diablo-style (4 raridades, afixos), 3 chefes rotativos.
- **Fase 3:** Raridades de monstros (Elite/Campeão/Lendário + afixos), beam visual, sting sonoro, kill announce, LootTable por inimigo.
- **Fase 4:** Quest log (20 principais + 8 mistérios), Fragmentos da Verdade, Final Dourado, tracker HUD, autoflow.
- **Fase 5:** 14 territórios + capitais, reputação 5 tiers, mercado dinâmico (oferta/demanda/rotas), Casa de Leilões determinística.
- **Fase 6:** HUD moderna, painel unificado, micro-interações pop_in/pop_out, relógio dia/noite, salvar/carregar.
- **Fase 7.1–7.3:** Sombras PCF5/PCF13, glow HDR/rim light/vinheta bioma, WindField global (navegação/projéteis/calmaria/skill).
- **Fase 7.4:** Vento coerente + forecast/presságio + shader fogueira + skill "Ler o Vento".
- **Fase 7.5:** Autoload Audio (5 camadas música + 7 biomas ambiência + 16 WAVs procedurais), bus Ambience vento, reverb masmorra, ducking, fogueira, sting.
- **Fase 7.6:** Weather estático (chuva determinística), WeatherLayer (emissores por bioma + vagalumes HDR + chuva), névoa parallax, relâmpago+trovão procedural.
- **Fase 7.7:** FSR 2.2 nativo + MSAA 2×/4× + presets Baixo/Médio/Alto, `particle_mult()`, glow reativo runtime.
- **Fase 8.1–8.2:** Smoke cobre 7 áreas (quests/economia/diálogo/prólogo/raridades/luz/som); balanceamento REGRAS (undead/demon resist, noite bônus, XP/attr/difficulty/vendor/rep/sell/raridade).

### Próximos (v2 / backlog)
- Crafting & coleta · Caravanas com escolta · Montarias · Pets de combate não-ladino · Localization EN · New Game+ · Conquista de masmorras · Hardcore ranking local.

---

## Créditos dos assets

- **Personagens, monstros, masmorra:** [0x72 — DungeonTileset II](https://0x72.itch.io/dungeontileset-ii) (CC0)
- **Ícones:** [Henrique Lazarini (7Soul1) — 496 RPG Icons](https://opengameart.org/content/496-pixel-art-icons-for-medievalfantasy-rpg) (CC0)
- **Tiles mundo, UI, sons:** [Kenney](https://kenney.nl): Roguelike RPG Pack, Tiny Dungeon, UI Pack RPG Expansion, RPG Audio, Impact Sounds (CC0)
- **Música:** "Cave Theme" (OpenGameArt, CC0) + "Dark Ambience Loop" Iwan Gabovitch (CC-BY 3.0)
- **Fontes:** Cinzel, Alegreya (SIL OFL)

Licenças completas em `assets/licenses/`.

---

## Licença

MIT — veja `LICENSE` (exceto assets com suas licenças próprias em `assets/licenses/`).