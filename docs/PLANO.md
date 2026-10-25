# PLANO KINFIRE — Documento Mestre de Progresso

> **Função:** acompanhar e atualizar o progresso do desenvolvimento do jogo KINFIRE (Godot 4.7).
> **Regra de ouro:** todo commit atualiza a seção *Progresso* deste arquivo.
> **Localização canônica:** `docs/PLANO.md` no repositório (desde a Fase 0.3). O espelho em `/home/f/.opencode/plan/PLANO_KINFIRE.md` é atualizado a cada commit.

---

## 1. Decisões tomadas (autorizadas pelo usuário — "Pode decidir")

| # | Tema | Decisão | Justificativa |
|---|---|---|---|
| D1 | `ui-ux-pro-max-cli` | CLI não existe no ambiente. Fase de UI/UX avança com critério próprio (audit manual + checklist do `MECANICAS.md` §9). Integração da CLI fica como tarefa **opcional/bloqueada**: se o usuário instalar, rodamos audit e comparamos. | Não bloquear o projeto por ferramenta indisponível. |
| D2 | Escopo da economia | **Completo recomendado:** múltiplos mercadores por território, estoque rotativo diário, preços por oferta/demanda, reputação por raça, casa de leilões. Crafting/coleta fica no **backlog** (v2). | Economia é requisito central do usuário; crafting dobraria o escopo. |
| D3 | Local dos arquivos | Plano em `/home/f/.opencode/plan/` (regra do harness); REGRAS/MECANICAS/LORE viram `docs/*.md` no repo na Fase 0. Docs perto do código para não se perderem. | Rastreabilidade e versionamento. |
| D4 | Ordem das fases | 0 Higiene → 1 Prólogo → 2 Diálogos/Territórios → 3 Raridade/Loot → 4 Quests → 5 Economia → 6 UI/UX → 7 Polimento. Raridade antes de quests porque recompensas de quest dependem de tabelas de loot. | Dependências técnicas. |
| D5 | Prólogo | Cena dedicada `prologue.tscn` (aldeão, tutorial guiado) → ao nível 1, fluxo raça → classe → atributos → nome → acampamento racial. | Fiel ao requisito narrativo do usuário. |
| D6 | Commits | Conventional Commits (`feat:`, `docs:`, `fix:`, `chore:`, `refactor:`, `test:`), 1 commit por unidade de funcionalidade, atualizando sempre este plano. | Histórico legível e revertível. |
| D7 | Direção visual da UI (pedido do usuário) | **HUD, interface do player e menus modernos e agradáveis.** Especificação completa em `MECANICAS.md` §9: tema dark-fantasy premium (painéis de vidro escuro, acento dourado/brasa, blur, cantos arredondados), micro-interações, cooldown radial, tooltips ricos, navegação por teclado, acessibilidade. Os **design tokens entram na Fase 1** (tarefa 1.0) para que todo painel novo já nasça moderno; a aplicação completa é a Fase 6. | UI moderna é prioridade do usuário; tokens cedo evitam retrabalho nos ~10 painéis novos. |
| D8 | Profundidade do lore (pedido do usuário) | `LORE.md` extenso e rico: cosmogonia, eras, Sete Chamas, Véu da Discórdia, demônios, os 14 territórios com cultura e curiosidades, 20+ missões principais, 8 cadeias de mistério, finais e uma seção de efêmera (provérbios, festivais, livros, superstições). Lore alimenta diálogos, quests e itens do jogo. | O usuário pediu investimento forte em lore para prender o jogador até o final. |
| D9 | Renderização premium (pedido do usuário) | Pedido incluía *ray tracing* e *DLSS 5* — **não aplicáveis a um jogo 2D pixel-art em Godot 4** (RT é 3D; DLSS é SDK proprietário NVIDIA sem integração no Godot; "DLSS 5" não existe — o SDK atual é o DLSS 4). Entregamos o **intento** (iluminação premium, nitidez/escala modernas) com o equivalente 2D real, especificado em `MECANICAS.md` §14: sombras dinâmicas reais (`PointLight2D` + `LightOccluder2D`, PCF13), normal maps, bloom/glow, color grading por hora do dia, **relógio na HUD**, clima/partículas por bioma e **FSR 2.2** + MSAA como upscalers. Virou a **Fase 7 — Luz, Sombra e Atmósfera**. | Rigor técnico: prometer RT/DLSS num jogo 2D seria fake; entregar sombras 2D reais + FSR é o caminho honesto e bonito. |
| D10 | Som (pedido do usuário: "faça o que for melhor") | **Áudio adaptativo** — spec em `MECANICAS.md` §15: música em camadas (base → +percussão em combate → +camada noturna), ambientes por bioma com crossfade, cues posicionais de ameaças fora de tela (o som é radar), reverb de masmorra, ducking de música durante diálogo, assinatura sonora por raridade (Campeão+ tem "sting" ao spawnar). Luz/sombra/som sempre como **mecânica** (noite = mortos-vivos; fogueira = seguro e reconfortante; escuridão = perigo real), não só estética. | Experiência: o jogador deve "sentir" a noite antes de vê-la no relógio. |

## 2. Estado atual do repositório (revisão — 2026-10-24)

**Existe (commit `956f698` "Jogo Base"):** mundo aberto procedural infinito (chunks 32×32, 7 biomas, dificuldade por distância, dia/noite), masmorras procedurais com chefes a cada 3 andares, 36 inimigos por habitat com elites binários e 3 chefes de mundo, 14 raças/14 classes/84 habilidades em `.tres`, itens com 4 raridades + afixos estilo Diablo, criação de personagem completa (point-buy D&D, antecedente, dificuldade, hardcore), 1 mercador fixo, save/load v3, opções completas com remapeamento, minimapa, smoke test.

**Falta (requisitos do usuário):** docs (regras/plano/mecânicas), prólogo-tutorial como aldeão, sistema de diálogo/NPCs, territórios raciais, sistema de quests com história completa, raridades de monstro multi-nível com drops específicos, economia/mercado real, audit de UI/UX.

**Problemas de higiene:** ~~`.gitignore`, `.editorconfig`, `.gitattributes`, `icon.svg` deletados; `.godot/` untracked~~ — **resolvidos na Fase 0.1** (restaurados; `.godot/` ignorado).

## 3. Fases

### Fase 0 — Higiene e Fundação (commits 1–3) — `status: PRONTA`
- [x] 0.1 `chore: restore .gitignore, .editorconfig, .gitattributes e icon.svg` — restaurados via `git checkout`; `.godot/` já ignorado; árvore limpa (restauração = estado do commit base, sem commit necessário)
- [x] 0.2 `docs: adicionar REGRAS_DO_JOGO, MECANICAS e LORE canônicos` — copiados para `docs/`; auditoria dos `[VERIFICAR]` concluída (ver `REGRAS_DO_JOGO.md` §16): 8 itens confirmados, 4 divergências registradas
- [x] 0.3 `docs: plano de progresso versionado` — este arquivo em `docs/PLANO.md` (fonte de verdade a partir de agora)
- [x] 0.4 `fix: alinhar fórmulas de progressão e morte às regras canônicas` — XP `20×nível^1.5`, nível máx 60, pontos +1 a cada 4 níveis, penalidade de morte por dificuldade (`REGRAS_DO_JOGO.md` §2/§5); smoke test OK
- **Aceitação:** `git status` limpo (só `.godot/` ignorado); `godot --headless -- --smoke` passa; docs sem pendências `[VERIFICAR]`. **✅ Fase concluída.**

### Fase 1 — Prólogo: O Aldeão (commits 4–9) — `status: PENDENTE`
- [ ] 1.0 `feat: design tokens da UI moderna (tema dark-fantasy premium no UIKit)` — paleta, blur, raios, sombras, fonte Cinzel/Alegreya, estilos de hover/press/foco, sons de UI (spec: `MECANICAS.md` §9). Fundação visual — todo painel novo já nasce moderno.
- [ ] 1.1 `feat: estado de prologo (VillagerState) e fluxo novo-jogo` — herói provisório "Aldeão" (sem raça/classe), save v4 com `phase: prologue|created`
- [ ] 1.2 `feat: cena prologue com vila de tutorial` — mapa pequeno handcrafted: casa, campo de treino, floresta rala, os 3 baús didáticos
- [ ] 1.3 `feat: tutorial guiado com o Silhueta (Cinzento)` — passos: mover → atacar espantalho → coletar drop → equipar → poção → fogueira; gate de saída até concluir
- [ ] 1.4 `feat: transição prologo -> criacao de personagem no nivel 1` — reordenar `character_creation` em raça → classe → atributos → nome (obrigatório, sem pular)
- [ ] 1.5 `feat: despertar no acampamento racial com dialogo de abertura`
- **Aceitação:** fluxo menu → prólogo → nível 1 → criação → acampamento funciona ponta a ponta no smoke test.

### Fase 2 — Diálogos, NPCs e Territórios (commits 9–14) — `status: PENDENTE`
- [ ] 2.1 `feat: DialogueData (resource) e motor de dialogo com nos, escolhas e condicoes`
- [ ] 2.2 `feat: UI de dialogo com retratos e escolhas`
- [ ] 2.3 `feat: NpcNode conversavel e reputacao por raca (5 niveis)` — flag `ignorance` decresce conforme o jogador aprende (diálogos mudam)
- [ ] 2.4 `feat: geracao de territorios raciais procedurais (14 capitais + zona neutra da Kinfire)` — Voronoi procedural sobre o mundo infinito; capital = acampamento ampliado
- [ ] 2.5 `feat: NPCs por territorio com ganho-de-vida por raca` (elfo→chefe da aldeia, humano→guilda, anão→forja, etc., por LORE §6)
- [ ] 2.6 `test: smoke cobre dialogo e territorios`
- **Aceitação:** cada raça tem capital com ≥4 NPCs únicos, diálogo ramificado e economia própria.

### Fase 3 — Raridade de Monstros e Loot (commits 15–18) — `status: PENDENTE`
- [ ] 3.1 `feat: enum de raridade de monstro (Comum/Elite/Campeao/Lendario/Chefe) com visuais e multiplicadores` — substitui `elite: bool` por `rarity: int` (elite vira valor 1; retrocompatível no save)
- [ ] 3.2 `feat: modificadores de Campeao estilo afixo (Furioso, Escudo Arcano, etc.)`
- [ ] 3.3 `feat: LootTableData por (inimigo x raridade) com drops especificos` — essência como moeda rara; lendário/chefe com itens únicos garantidos
- [ ] 3.4 `feat: HUD/minimap/mensagens refletem as novas raridades`
- **Aceitação:** cada raridade é visualmente identificável a primeira vista; drops conferem 100% com `REGRAS_DO_JOGO.md` §8.

### Fase 4 — Sistema de Missões (commits 19–24) — `status: PENDENTE`
- [ ] 4.1 `feat: QuestData (stages, objetivos, pre-requisitos, flags) e QuestLog no Game`
- [ ] 4.2 `feat: UI de quest log + tracker no HUD`
- [ ] 4.3 `feat: cadeia principal Ato 1 (A Estranha)` — ~7 quests
- [ ] 4.4 `feat: cadeia principal Ato 2 (O Tabuleiro)` — ~8 quests de diplomacia entre territórios
- [ ] 4.5 `feat: cadeia principal Ato 3 (A Verdade)` — ~5 quests, revelação dos demônios, cerco à Fenda
- [ ] 4.6 `feat: 8 cadeias de misterio (side) com Fragmentos da Verdade` — 1 Fragmento por cadeia; colecionar todos destrava o final verdadeiro
- **Aceitação:** história principal jogável ponta a ponta; final normal vs. final verdadeiro ambos alcançáveis e testados.

### Fase 5 — Economia e Mercado (commits 25–29) — `status: PENDENTE`
- [ ] 5.1 `feat: VendorData com estoque rotativo diario e especialidades regionais`
- [ ] 5.2 `feat: precos dinamicos por oferta/demanda` — vender em massa derruba o preço; escassez eleva; ciclo pelo dia do mundo
- [ ] 5.3 `feat: desconto por reputacao (0/5/10/15/20%)`
- [ ] 5.4 `feat: casa de leiloes (guilda humana) com itens raros/lendarios rotativos e lances`
- [ ] 5.5 `feat: UI de comercio unificada (comprar/vender/leilao) com tooltips de preço`
- **Aceitação:** dá para lucrar comprando num território e vendendo noutro (rotas comerciais emergentes); fórmulas conferem com `REGRAS_DO_JOGO.md` §10.

### Fase 6 — UI/UX Moderna (commits 30–35) — `status: PENDENTE (CLI ausente — ver D1)`
> Especificação visual completa em `MECANICAS.md` §9. Tokens já aplicados desde a tarefa 1.0; aqui aplicamos em todo o jogo.
- [ ] 6.1 `feat: HUD moderna` — barras de vida/recurso elegantes com segmentos, skill bar com cooldown radial e badge de tecla, anel de XP no emblema de nível, chips de ouro/essência, strip de buffs com anéis de tempo, tracker de quest lateral recolhível, minimapa redondo, barras de inimigo coloridas por raridade
- [ ] 6.2 `feat: interface do player moderna` — painel unificado com abas (Personagem/Inventário/Habilidades/Quests), tooltips ricos, comparador ▲▼ vs equipado, drag & drop, brilho por raridade, atalhos consistentes
- [ ] 6.3 `feat: menu principal moderno` — shader de névoa + partículas de brasa no logo, cards de menu com hover, créditos e opções redesenhados na nova linguagem
- [ ] 6.4 `feat: onboarding visual do prologo` — dicas contextuais, setas-guia, destaque de elementos de UI
- [ ] 6.5 `refactor: micro-interacoes em todos os paineis` — hover lift + glow, press scale, tweens de abrir/fechar (0.18s), foco de teclado visível, sons hover/click
- [ ] 6.6 `chore: (opcional) integrar ui-ux-pro-max-cli quando disponivel e aplicar achados`
- **Aceitação:** checklist de UI/UX do `MECANICAS.md` §9.4 100% verde; navegação por teclado 100% funcional em todos os painéis; aprovação visual do usuário em screenshots.

### Fase 7 — Luz, Sombra, Som, Vento e Atmósfera (commits 37–44) — `status: PENDENTE`
> Spec completa em `MECANICAS.md` §14 (luz/sombra/clima/vento) e §15 (áudio adaptativo). Decisão D9 (ray tracing/DLSS → equivalentes 2D) e D10 (som).
- [ ] 7.1 `feat: relogio na HUD e ciclo dia/noite rico` — chip de relógio HH:MM + arco sol/lua, color grading por keyframes, signal `hour_changed`, dormir na fogueira
- [ ] 7.2 `feat: sombras dinamicas 2D (PointLight2D + LightOccluder2D)` — oclusores em árvores/paredes/tendas, PCF5/PCF13 por preset, lanterna do herói auto no crepúsculo, orçamento de luz
- [ ] 7.3 `feat: materiais e pos-processo 2D` — normal maps nos sprites-chave, bloom/glow (HDR 2D), vinheta/temperatura por bioma
- [ ] 7.4 `feat: sistema de vento global e movimento ambiental` — WindField autoload (coerente semente+tempo), shader `wind_sway` em vegetação/partículas/roupas, desvio de projéteis, navegação afetada, cues de chefe (calmaria), integração com classes (Caçador, Druida) e mistérios
- [ ] 7.5 `feat: som adaptativo por bioma, hora, combate e vento` — camadas de música, ambientes por bioma com crossfade, cues posicionais, reverb, ducking, bus `Ambience` controlado por `WindField.strength`
- [ ] 7.6 `feat: clima e particulas ambientais por bioma` — neve/cinzas/esporos/folhas/vagalumes transportadas pelo vento, névoa parallax no pântano e Terras Corrompidas, chuva determinística + relâmpago com trovão
- [ ] 7.7 `feat: FSR 2.2 + MSAA + presets de qualidade de video` — Opções de Vídeo; meta 60fps com 6 luzes sombreadas + vento Alto
- **Aceitação:** dia completo visível com transições suaves; 06:00 = vendors re-estocam; noite = mortos-vivos +contatos noturnos; vento coerente muda partículas/som/projéteis/vegetação; música muda sozinha ao entrar em combate e à noite; 60fps estáveis no preset Alto.

### Fase 8 — Polimento e Estabilização (commits 45–47) — `status: PENDENTE`
- [ ] 8.1 `test: smoke test expande para quests, economia, dialogo, prologo, raridades, luz e som`
- [ ] 8.2 `fix: balanceamento pass (numeros conferem com REGRAS_DO_JOGO.md)` — planilha de sanity check de XP/ouro/dano por nível
- [ ] 8.3 `docs: README atualizado com novos sistemas` + notas de versão v0.3
- **Aceitação:** smoke test passa de ponta a ponta 3× seguidas; zero erros no log; save migra de v3 sem perda.

### Backlog (v2 — não prometido)
- Crafting e coleta de recursos • caravanas comerciais com escolta • montarias • pets de combate não-ladino • localization EN • new game+ • conquesta de masmorras ao final • modo hardcore com ranking local

## 4. Boas práticas (obrigatórias em todas as fases)

1. **GDScript com tipagem estática total** — todo `var`, parâmetro e retorno tipado; sem `Variant` sem necessidade.
2. **Zero números mágicos** — constantes nomeadas ou fórmulas em um único lugar (fonte: `REGRAS_DO_JOGO.md`).
3. **Data-driven** — conteúdo (diálogos, quests, loot, vendors, territórios) em Resources `.tres` ou JSON, nunca hardcode em lógica.
4. **Decoupling por signals** — sistemas conversam por sinais; nenhum script referencia UI a partir da lógica de jogo.
5. **Responsabilidade única** — 1 arquivo = 1 papel; extraído quando crescer.
6. **Save versionado com migração** — bump da versão + função `_migrate_v4()` etc.; nunca quebrar saves antigos.
7. **Commits pequenos e semânticos** (ver D6); nunca commit de `.godot/`.
8. **Testes** — todo sistema novo ganha caminho no smoke test; bugs ganham caso de teste antes do fix.
9. **Retrocompatibilidade** — mudanças de schema (ex.: `elite` → `rarity`) preservam o save existente.
10. **Docs primeiro** — regra ou mecânica nova entra no doc canônico antes do código.

## 5. Progresso (atualizar a cada commit)

| Fase | Status | Última atualização |
|---|---|---|
| 0. Higiene e Fundação | ✅ Pronta | 2026-10-25 |
| 1. Prólogo | 🟨 Em andamento (1.0 pronto) | 2026-10-25 |
| 2. Diálogos/Territórios | ⬜ Não iniciada | — |
| 3. Raridade/Loot | ⬜ Não iniciada | — |
| 4. Quests | ⬜ Não iniciada | — |
| 5. Economia | ⬜ Não iniciada | — |
| 6. UI/UX | ⬜ Não iniciada | — |
| 7. Luz/Sombra/Som/Vento | ⬜ Não iniciada | — |
| 8. Polimento | ⬜ Não iniciada | — |

### Registro de commits
| Data | Commit | Fase | Notas |
|---|---|---|---|
| 2026-10-25 | 021fcf7 | 0.2+0.3 | `docs:` REGRAS/MECANICAS/LORE/PLANO em `docs/`; auditoria `[VERIFICAR]` resolvida (8 confirmados, 4 divergências → 0.4) |
| 2026-10-25 | (pendente) | 0.4 | `fix:` XP `20×lvl^1.5`, nível máx 60, pontos a cada 4 níveis, morte por dificuldade — smoke OK |
