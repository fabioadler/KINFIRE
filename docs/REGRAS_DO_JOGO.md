# REGRAS DO JOGO — KINFIRE (Documento Canônico)

> **O que o jogador pode e não pode.** Como cada sistema funciona por dentro: `MECANICAS.md`. História: `LORE.md`.
> **Canonicidade:** em caso de conflito entre este doc e o código, este doc vence; o código é corrigido no commit seguinte.
> **Auditoria Fase 0.2 (2026-10-25): concluída.** Todos os `[VERIFICAR]` foram conferidos contra o código: itens confirmados ganharam `✓`; divergências foram registradas na §16 e corrigidas no código no commit seguinte.

---

## 1. Atributos e criação de personagem

- **6 atributos:** FOR (força), DES (destreza), CON (constituição), INT (inteligência), SAB (sabedoria), CAR (carisma).
- **Compra de pontos (D&D 5e):** 27 pontos; custos 8=0, 9–13=1, 14=2, 15=3; mínimo 8, máximo 15 antes de bônus raciais.
- **Bônus raciais** aplicam-se após a compra (ex.: Anão da Montanha +2 CON +2 FOR −1 DES). ✓ conferido em `data/races/*.tres`
- **Modificador** = `(valor − 10) / 2` (arredondado para baixo).
- **Antecedente:** escolhido na criação (Soldado, Acólito, Criminoso, Sábio, Nobre, Forasteiro, Artesão de Guilda, Herói do Povo); dá item inicial + ganho narrativo (diálogos com tag). ✓ 8 antecedentes em `db.gd`
- **Fluxo obrigatório (prólogo):** raça → classe → distribuição de pontos → nome. Nenhum passo é pulável; gerador "Aleatório" existe.
- **Nomes:** gerador por raça; nome manual limitado a 16 caracteres.

## 2. Progressão

- **Nível máximo: 60** (limitado pela escala de `danger()` do mundo).
- **XP:** monstro dá XP base × multiplicador de raridade (§6); missões dão XP fixo por ato (§10).
  - **Regra canônica:** XP para o próximo nível = `20 × nível^1.5` (níveis 1–60). ✓ (código legado usava `80 × nível^1.6` — corrigido na Fase 0.4)
- **Ao subir de nível:** +HP, +recurso e +1 ponto de atributo a cada 4 níveis (1, 5, 9, 13…). ✓ (código legado dava +1 por nível — corrigido na Fase 0.4)
- **Habilidades:** 6 por classe, desbloqueadas por nível de classe; slot de 4 equipáveis + racial. ✓ (84 skills / 14 classes em `data/skills/`)
- **Ignorância:** o herói começa com `ignorance = 10` (após o prólogo); decai ao completar passos de tutorial, missões e primeiros-diálogos; nunca sobe. Afeta apenas textos de diálogo (nunca atributos).

## 3. Combate

- **Dano de arma** = base do item × (1 + (atributo relevante − 10) × 0.05) × bônus de raridade (aplicado na geração do item). ✓ conferido em `hero.gd` (`damage_multiplier`)
- **Crítico:** chance base por raça/classe/afixos (ex.: Halfling 5% de chance dobrada); dano crítico padrão ×2.
- **Esquiva (dodge):** consumível com i-frames curtos; cancela a recuperação do ataque; recharge 0.8s.
- **Bloqueio:** classes com escudo reduzem X% do dano frontal; Paladino gera Fé ao bloquear.
- **Status effects:** atordoar (2s), lentidão (40%, 5s), confusão (ataca aliados, 6s), medo (foge, 4s), maldição (+dano recebido), veneno (DoT 5s), fogo (DoT + visual). ✓ stun/lentidão/confusão/medo/maldição confirmados em `skill_executor.gd`; veneno/fogo como DoT — cobertura completa conferida na Fase 3.
- **Elementos e resistências:** Fogo, Gelo, Raio, Sagrado, Sombrio, Veneno. Resistências vêm de raça (ex.: Draconato imune a fogo), afixos e santuários. Vulnerabilidades: mortos-vivos levam ×1.5 de Sagrado, demônios ×1.5 Sagrado e −25% Sombrio? **Regra canônica:** demônios são imunes a Sombrio e fracos a Sagrado (lore: não têm laço).
- **Knockback:** padrão; imune: Anões da Montanha, afixo TELÚRICO, chefes.
- **Elite+ não pode ser empurrado para fora da arena de chefe.**

## 4. Recursos de classe

Definidos por classe (Fúria, Mana, Energia, Vigor, Fé, Essência, Concentração, Chi, Pacto, Espírito, Inspiração, Carga Arcana, Fluxo). Regras de gasto/regeneração são propriedade do `ClassData` (`resource_max`, `resource_regen`). ✓ conferido em `hero.gd`/`class_data.gd` Regra transversal: nenhuma classe fica sem recurso em repouso por mais de 10s (evita "esperar mana").

## 5. Morte, renascimento e hardcore

- **Morte:** respawn na última fogueira acesa; HP cheio; perde 10% do ouro carregado (Normal) / 20% (Difícil) / 30% (Pesadelo e Inferno). ✓ (código legado aplicava 10% fixo — corrigido na Fase 0.4)
- **Hardcore:** morte é permanente — o save vira lápide (somente leitura do resumo); sem second chances.
- **Fogueira:** acender define respawn, cura total, salva o jogo, permite dormir até o amanhecer (avança o relógio para 06:00).

## 6. Raridades de monstros e drops (NOVO)

| Raridade | Chance por pack | HP | Dano | XP/Ouro | Drops garantidos |
|---|---|---|---|---|---|
| Comum | — | ×1 | ×1 | ×1 | ouro pequeno; 10% item Comum |
| Elite | 8% +1%/nível | ×2.5 | ×1.3 | ×3 | ≥1 item Mágico + ouro |
| Campeão | 2% | ×5 | ×1.8 | ×6 | ≥1 Raro + chance 20% Lendário + 50% Essência |
| Lendário | 0,3% | ×10 | ×2.5 | ×15 | ≥1 Lendário/Único + ≥1 Essência |
| Chefe | roteirizado | ×20–30 | tabelado | ×25 | ≥2 itens (≥1 Raro+) + Essência ×2 + item único possível |

- **Afixos** (Campeão 1–2; Lendário 2–3): FURIOSO, ESCUDO ARCANO, TELÚRICO, VENENOSO, FANTASMA, MESTRE-DE-ENXAME, ARDENTE, CAMPEÃO-DAS-SOMBRAS (`MECANICAS.md` §5.2).
- **Drop beam** por cor de raridade; Lendário anuncia spawn com sting + beam visível de longe.
- **Dificuldade por região:** nível do monstro = nível da região (`1 + danger×0.9`, máx 60); XP escala com o nível do monstro, não do jogador.
- **Noite (21:00–05:00):** mortos-vivos têm +50% de peso de spawn em biomas sombrios; todos os monstros ganham +10% de agressividade (raio de aggro).

## 7. Dificuldades do jogo

Sistema estilo Diablo (multiplicadores em `db.gd` → `DIFFICULTIES`). ✓ conferido e canônico:

| Modo | HP dos inimigos | Dano dos inimigos | Bônus de loot | XP | Penalidade de morte |
|---|---|---|---|---|---|
| Normal | ×1.0 | ×1.0 | — | ×1.0 | −10% ouro |
| Difícil | ×1.6 | ×1.35 | +8% chance de raridade | ×1.25 | −20% ouro |
| Pesadelo | ×2.5 | ×1.8 | +16% chance de raridade | ×1.6 | −30% ouro |
| Inferno | ×4.0 | ×2.5 | +28% chance de raridade | ×2.0 | −30% ouro; elites+ ganham +1 afixo (regra da §6, aplicada na Fase 3) |

Hardcore é um toggle sobre qualquer dificuldade.

## 8. Itens e equipamento

- **7 slots:** elmo, amuleto, arma, armadura, mão secundária, anel, botas. Armas de duas mãos ocupam arma + mão secundária.
- **Proficiência:** por classe; itens não-proficientes não equipam (Mago não empunha machado de duas mãos do Bárbaro).
- **Raridades de item:** Comum (0 afixos) → Mágico (1–2) → Raro (3–4) → Lendário (5 + nome épico). ✓ conferido em `db.gd` (`n_affixes = [0, 1–2, 3–4, 5]`)
- **Nível necessário:** item até 3 níveis acima equipa só para Meio-Elfo (passiva).
- **Valor de venda** = `(5 + item_level × 3) × (1 + raridade × 2)` × condição × demanda (§9). Vendor compra a 40% do valor.
- **Identificação:** itens Raro+ dropam já identificados (sem minigame de identify — decisão: fricção sem diversão).

## 9. Ouro e essência

- Ouro dropa de monstros (valor base da região × raridade), baús, quests e vendas.
- **Essência:** só de Campeão/Lendário/Chefe; moeda "dura" da economia — usada em lances especiais da casa de leilões e (backlog) re-forja.
- Tudo é visível nos chips da HUD (§MECANICAS 9.2).

## 10. Economia e mercado (NOVO)

- **Preço de compra** = valor base × fator de demanda da categoria × (1 + escassez regional) × (1 − desconto de reputação).
- **Oferta/demanda:** vender N itens de uma categoria reduz o preço pago em 3% por item (recupera 5%/dia); comprar reduz o estoque e eleva o preço. Demanda ∈ [0.6, 1.5].
- **Rotas comerciais:** cada território paga mais pelo que não produz e menos pelo que produz (especialidades do `VendorData`).
- **Reputação (0–4):** Estranho → Conhecido → Respeitado → Honrado → Laço. Descontos 0/5/10/15/20%. Ganha-se por quests e favores; nunca decai (decisão: fricção sem diversão).
- **Casa de leilões:** 6 slots/dia de itens Raro+; lance mínimo sobe 10% por lance rival simulado; essência aceita em lances especiais.
- **Trapaça econômica anti-exploit:** ganho por quest repetível tem XP decrescente (−20% por repetição, mín. 20%).

## 11. Territórios e reputação

- 14 territórios raciais + zona neutra do Vale do Centro (`MECANICAS.md` §3). Dentro de capital: seguro (sem spawn, repel radius).
- Nível da região = distância do Vale do Centro + modificador do território.
- **Atravessar território inimigo em guerra (Ato 1):** guards hostis nas fronteiras até a quest de paz correspondente; após a paz, viram neutros. (Conflito é o estado inicial — não grind de faction genérico.)

## 12. Quests

- Principais (20) sempre disponíveis na ordem dos 3 atos; não podem ser abandonadas.
- Laterais opcionais; **8 cadeias de mistério** rendem 1 **Fragmento da Verdade** cada.
- **Regra do final:** com 8 Fragmentos, a quest final "O Fogo dos Laços" abre o caminho do Final Dourado; sem eles, apenas o Final Cinzento (o jogador é avisado no início da quest final que "há verdades que você ainda não conhece" — sem spoiler do que perdeu).
- Recompensa padrão de quest principal: XP = `40 × nível da quest × ato` + ouro proporcional + 1 item (raridade mínima = ato: Mágico/Raro/Lendário).

## 13. Prólogo (regras)

- O jogador é **Aldeão nível 0** com ataque básico; sem classe/raça até o nível 1.
- XP do prólogo é acelerado (chega ao nível 1 em ~5 minutos de jogo: 2 lutas + coleta + equipar).
- Nada do prólogo carrega para o mundo (itens do tutorial não saem da Reminiscência; o Cinzento explica: "o que pertence ao sonho fica no sonho").
- Ao atingir nível 1: cutscene do espelho sem reflexo → criação obrigatória → acampamento da raça escolhida.

## 14. Luz, noite e horário (regras de jogabilidade)

- 1 dia = 360s reais; relógio na HUD (`MECANICAS.md` §14.1).
- 06:00: vendors re-estocam. 21:00–05:00: noite (spawns §6, lanterna acesa, contatos noturnos de quest). 00:00: autosave ("A Vela Virou").
- Dormir na fogueira: pula para 06:00; buffs de descanso expiram ao dormir.
- Luz sagrada atravessa paredes; luz sombria não projeta sombra (regra temática — curiosidade em LORE §16).

## 15. Save

- `user://kinfire_save.json`, versão atual 3 → v4 com prólogo/quests/reputação/fragmentos/territórios; migrações encadeadas preservam saves antigos.
- Autosave ao: acender fogueira, 00:00, entrar/sair de masmorra, concluir quest.
- 1 slot (decisão: sem multi-slot até demanda).

## 16. Auditoria da Fase 0.2 (RESOLVIDA — 2026-10-25)

**Confirmados no código (nenhuma ação necessária):**
- [x] Bônus raciais em `data/races/*.tres` (§1) — ex.: Anão da Montanha +2 CON +2 FOR −1 DES
- [x] 8 antecedentes em `db.gd` (§1)
- [x] 6 habilidades por classe, 84 skills / 14 classes (§2)
- [x] Fórmula de dano em `hero.gd` → `damage_multiplier()` (§3)
- [x] Status effects stun/lentidão/confusão/medo/maldição em `skill_executor.gd` (§3)
- [x] Recursos de classe (`resource_max`, `resource_regen`) em `ClassData` (§4)
- [x] Afixos por raridade `[0, 1–2, 3–4, 5]` em `db.gd` (§8)
- [x] Multiplicadores de dificuldade em `db.gd` → `DIFFICULTIES` (§7 — tabela acima ajustada ao código real)

**Divergências — doc vence, código corrigido na Fase 0.4:**
- [ ] XP por nível: código `80 × nível^1.6` → canônico `20 × nível^1.5`
- [ ] Nível máximo: código 30 → canônico 60
- [ ] Pontos de atributo: código +1/nível (+2 a cada 4º) → canônico +1 a cada 4 níveis (níveis 1, 5, 9, 13…)
- [ ] Penalidade de morte: código 10% fixo → canônico 10/20/30/30% por dificuldade

**Pendência remanejada:**
- Definir valores-base de ouro por região em `world.gd` (documentar na §9) — junto à Fase 3 (raridade/loot), onde as tabelas de ouro por raridade entram.
