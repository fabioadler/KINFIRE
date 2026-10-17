# Kinfire

RPG de ação 2D top-down em Godot 4.7: 14 raças e 14 classes inspiradas em D&D / Baldur's Gate e combate estilo Diablo 3.

Criado por [MichaelDCA](https://github.com/MichaelDouglasCA) e [fabioadler](https://github.com/fabioadler).

## Como jogar

Abra o projeto no Godot 4.7 e aperte **F5**.

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
| Inventário / Personagem / Habilidades | I / C / K |
| Mostrar itens no chão | Alt |
| Menu / fechar painéis | Esc |

## Mundo aberto procedural

O jogo começa em um **mundo aberto infinito**, gerado proceduralmente em chunks de 32×32 células, como no Minecraft. Cada partida tem uma semente diferente.

- **7 biomas** definidos por ruído de temperatura, umidade e corrupção:

  | Bioma | Destaques |
  |---|---|
  | Planícies | Começo da jornada |
  | Floresta Sussurrante | Árvores densas |
  | Areias Escaldantes | Cactos |
  | Tundra Congelada | Pinheiros nevados e lagos gelados |
  | Pântano Pútrido | Muita água turva e vitórias-régias |
  | Ermos Vulcânicos | Lava |
  | Terras Corrompidas | Lápides e árvores mortas |

- **Lagos e rios** são gerados por ruído, com margens desenhadas automaticamente.
- **Dificuldade por distância:** o nível da região cresce conforme você se afasta do acampamento inicial.
- **Acampamento inicial** (área segura), com fogueira e o Mercador Bartolomeu, que vende armas, armaduras e joias misteriosas e compra seu lixo.
- **Fogueiras** espalhadas pelo mundo: acenda para definir o ponto de renascimento e usar a viagem rápida entre fogueiras descobertas.
- **Entradas de masmorra** espalhadas pelo mapa, cada uma com nome e nível próprios. Dentro, a masmorra procedural tem andares, chefe a cada 3 andares e uma escada de volta ao mundo aberto.
- **Baús e santuários** no mundo; os já usados ficam salvos e não reaparecem.
- **Chefes de mundo** raros nas regiões distantes: Ogro, Putrefato e Azkhar.
- **Ciclo de dia e noite:** um dia dura 6 minutos e a noite escurece o mundo.
- **Minimapa** com biomas, água, fogueiras, masmorras, mercador e inimigos.

## Inimigos (36 tipos)

Cada monstro tem habitats: masmorra e/ou biomas. Entre os novos estão Ratazana, Morcego Vampírico, Aranha Gigante, Lobo Sombrio, Arqueiro Bandido, Cavaleiro Renegado, Mago Renegado, Anão Saqueador, Homem-Lagarto, Lesma Ácida, Lesminha, Abóbora Maldita, Médico da Peste, Anjo Caído, Espectro, Caranguejo Infernal, Ciclope Errante e Cultista do Deserto. Eles se somam aos 14 da masmorra e aos 3 chefes.

## Raças (biologia e passivas)

| Raça | Atributos | Passiva |
|---|---|---|
| Humano | +1 em tudo | +10% XP e ouro |
| Alto Elfo | +2 INT, +1 DES | +15% recurso máximo, 20% de resistência mágica |
| Elfo da Floresta | +2 DES, +1 CON | +10% de velocidade, esquiva automática a cada 10s |
| Drow | +2 DES, +1 INT | +15% de dano contra inimigos atordoados, lentos ou confusos |
| Anão da Montanha | +2 CON, +2 FOR, −1 DES | Imune a empurrões, +10% de armadura |
| Anão das Colinas | +2 CON, +1 SAB | Regeneração fora de combate dobrada, 25% de resistência a veneno |
| Halfling | +2 DES | 5% de chance de crítico dobrado, corpo menor |
| Meio-Orc | +2 FOR, +1 CON | Sobrevive a um golpe fatal (recarga de 2 min) |
| Tiefling | +2 INT, +1 FOR | 25% de resistência a fogo, devolve 10% do dano como fogo |
| Draconato | +2 FOR, +1 INT | Sopro de fogo em cone (R) que ignora armadura, imune a fogo |
| Gnomo | +2 INT | −10% de tempo de recarga |
| Meio-Elfo | +2 CAR, +1 em dois à escolha | Equipa itens até 3 níveis acima do seu |
| Tabaxi | +2 DES | 5 acertos seguidos dão +40% de velocidade de movimento e de ataque |
| Golias | +2 FOR, +2 CON, −1 INT | Inventário 30% maior, armas de duas mãos 10% mais rápidas |

## Classes (recurso e estilo)

| Classe | Recurso | Mecânica |
|---|---|---|
| Bárbaro | Fúria | Gera ao bater e ao apanhar, esvazia fora de combate. Salto, turbilhão, grito de medo |
| Feiticeiro | Mana | Regeneração alta. Fogo, gelo e corrente de relâmpagos |
| Ladino | Energia | Recarrega 4× mais rápido após 2s sem gastar. Venenos e esquivas |
| Guerreiro | Vigor | Bloqueio com escudo. Golpes táticos |
| Paladino | Fé | Gera ao bater e ao bloquear. Auras e dano sagrado |
| Necromante | Essência | Ganha quando inimigos morrem. Esqueletos, golem, maldição explosiva |
| Caçador | Concentração | Só regenera parado. Arco, lobo companheiro, armadilhas |
| Monge | Chi | Todo 3º golpe causa dano dobrado e atordoa. Curas rápidas |
| Bruxo | Pacto | As magias custam vida. Roubo de vida de 10%, diabretes |
| Druida | Espírito | Forma de Lobo (velocidade e crítico) e Forma de Urso (armadura e dano) |
| Clérigo | Mana | 15% do dano causado vira cura. Armadura pesada |
| Bardo | Inspiração | Zonas de som: inimigos confusos atacam uns aos outros |
| Mago | Carga Arcana | Gera com o ataque básico. Teleporte, raio perfurante, dobra temporal |
| Lâmina Arcana | Fluxo | Golpes reduzem a recarga das magias, e as magias encantam a lâmina |

Cada classe tem 6 habilidades e uma **proficiência de armas**. Um Mago não consegue equipar o machado de duas mãos do Bárbaro.

## Outros sistemas

- **Criação de personagem:**
  - Raça, classe, sexo, cor e nome (com gerador por raça).
  - Compra de pontos do D&D 5e e prévia das estatísticas.
  - Antecedente (Soldado, Acólito, Criminoso, Sábio, Nobre…).
  - Dificuldade: Normal, Difícil, Pesadelo ou Inferno.
  - Modo Hardcore.
  - Botão "Aleatório".
- **Equipamento estilo Diablo:**
  - 7 espaços (elmo, amuleto, arma, armadura, mão secundária, anel, botas).
  - 4 raridades e afixos aleatórios, incluindo resistências e roubo de vida.
  - Nível necessário para equipar e armas de duas mãos.
- **Inimigos:**
  - 14 monstros animados com elementos.
  - Elites com contorno azul.
  - Efeitos de status: atordoamento, lentidão, confusão, medo e maldição.
  - 3 chefes em rodízio a cada 3 profundidades: Ogro, Putrefato e Azkhar.
- **Masmorra:** procedural, com minimapa, baús (e Mímicos), santuários, armadilhas de espinhos e escadas.
- **Opções:**
  - Áudio.
  - Vídeo: tela cheia, resolução, VSync, FPS máximo, escala da interface, brilho e contador de FPS.
  - Jogabilidade: números de dano, tremor de tela, zoom da câmera, barras de vida, nomes de itens, clique para mover, densidade de monstros, minimapa e salvamento automático.
  - Controles remapeáveis.

## Arquitetura

A ficha de RPG (dados) fica separada da física do jogo (ação):

```
data/                    Custom Resources (.tres), editáveis no Inspector
  races/*.tres           RaceData   — bônus, resistências, passivas, sprite
  classes/*.tres         ClassData  — dado de vida, recurso, proficiências, habilidades
  skills/<classe>/*.tres SkillData  — 15 tipos (golpe, projétil, raio, invocação, transformação...)
  enemies/*.tres         EnemyData  — comportamento, elemento, sprite
  index.json             Ordem de carregamento das listas
scripts/
  core/hero.gd           Ficha do herói (atributos, cálculos, equipamento, save)
  items/                 Item e InventoryGrid (grade w×h)
  combat/                SkillExecutor, Projectile, efeitos
  game/                  Player, Enemy, Minion, loot, objetos
                         World (masmorra) e Overworld (mundo aberto em chunks) + geradores
  ui/                    HUD, inventário, ficha, habilidades, opções, prévia animada
  menus/                 Menu principal e criação de personagem
  autoload/              DB (dados, sprites, itens), Game (estado, save, opções), Sfx
shaders/                 Globos de vida, flash de dano, névoa do menu
tests/smoke_test.gd      Teste automatizado
```

Para criar uma raça ou classe nova, crie o `.tres` (clique direito no FileSystem → New Resource → RaceData/ClassData), preencha no Inspector e adicione o id em `data/index.json`.

## Teste automatizado

```
godot --headless --path . -- --smoke
```

O teste passa pelos menus, pelos créditos e pelas opções, cria um herói de cada classe, usa todas as habilidades e a habilidade racial, equipa itens, mata inimigos, abre baús, morre, ressuscita, salva e desce um nível. Para salvar screenshots, defina a variável `SMOKE_SHOTS=<pasta>` e rode sem `--headless`.

## Créditos dos assets

- Personagens, monstros e masmorra: [0x72 — DungeonTileset II](https://0x72.itch.io/dungeontileset-ii) (CC0)
- Ícones: [Henrique Lazarini (7Soul1) — 496 RPG Icons](https://opengameart.org/content/496-pixel-art-icons-for-medievalfantasy-rpg) (CC0)
- Tiles, mundo aberto, UI e sons: [Kenney](https://kenney.nl): Roguelike RPG Pack, Tiny Dungeon, UI Pack RPG Expansion, RPG Audio e Impact Sounds (CC0)
- Música: "Cave Theme" (OpenGameArt, CC0) e "Dark Ambience Loop" de Iwan Gabovitch (CC-BY 3.0)
- Fontes: Cinzel e Alegreya (SIL Open Font License)

As licenças estão em `assets/licenses/`.
