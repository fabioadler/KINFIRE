# KINFIRE Lore System — Knowledge Graph

## 📊 Graph Structure

**Nodes:** 15 (Guardiões, Sistemas, Locations, Story)  
**Edges:** 14 (Connections, Contains, Requires)  
**Communities:** 3

### Communities

1. **Seven Guardians (7 nodes)**
   - Mira, Ashara, Lorelyn, Theron, Kael, Khalid, Pyros
   - All connected via Bonds system

2. **Core Systems (2 nodes)**
   - Brasa (Ember progression)
   - Bonds (Guardian collection)

3. **Story & Antagonists (6 nodes)**
   - Ithariel (8th Guardian)
   - Kinfire (Dungeon)
   - Véu da Discórdia (Antagonist)
   - Maldrach (Boss)
   - Gray Ending
   - Gold Ending

## 🔗 Key Relationships

### Bonds System
- Connects all 7 Guardians
- Includes Ithariel (8th)
- Triggers Gold Ending

### Brasa System
- Triggers in Kinfire dungeon
- Scales from 0-7
- Required for progression

### Story Paths
- **Gray Ending:** Sealed by Ithariel
- **Gold Ending:** Requires full Bonds + Kinfire completion

### Antagonist Chain
- Véu da Discórdia created by Maldrach
- Maldrach contained in Kinfire dungeon

## 💡 Key Insights

1. **7+1 Guardian Architecture**
   - 7 collectible Guardians unlock Gold path
   - 8th Guardian (Ithariel) gates final choice

2. **Dual System Progression**
   - Bonds: Narrative/Quest progression
   - Brasa: Zone-based mechanical progression
   - Both required for full experience

3. **Branching Story**
   - Gray Ending: Solo path (Ithariel + player)
   - Gold Ending: Collective path (all Guardians + player)

4. **Three-Layer Antagonist**
   - Véu: Rewriter (mechanism)
   - Maldrach: Absence (force)
   - Kinfire Dungeon: Final confrontation (location)

## 📋 Implementation Checklist

✅ 7 Guardian NPCs created  
✅ 7 Guardian Dialogues created  
✅ Ithariel reveal (Act 3)  
✅ Brasa System (0-7 progression)  
✅ Bonds System (7 Guardians tracked)  
✅ Kinfire Dungeon (territory)  
✅ Véu Narrative (antagonist context)  
✅ Two Endings (Gray + Gold)  
✅ UI Indicators (Brasa + Bonds)  
✅ Runtime Integration (autoload)  

## 🎮 Player Journey Map

```
Start (Act 1-2)
  ↓
misterio_1..7 (Collect Fragments)
  ├─→ Find 7 Guardians (Bonds progression)
  └─→ Learn about Véu/Kinfire
  ↓
misterio_8 (Ithariel Reveal)
  ├─→ Gray Path: Skip Guardians → Sealed Ending
  └─→ Gold Path: Collect all → Rekindle Ending
  ↓
ato3_1..7 (Kinfire Approach)
  ↓
ato3_8 (Final Confrontation)
  ├─→ Defeat Maldrach
  ├─→ Brasa 7/7 (Gold path)
  └─→ Choose Ending
```

## 📈 Metrics

| Metric | Value |
|--------|-------|
| Guardian Nodes | 7 |
| System Nodes | 2 |
| Story Nodes | 6 |
| Total Nodes | 15 |
| Total Edges | 14 |
| Communities | 3 |
| Implementation Status | 100% |

---

**Graph generated:** 2026-10-28  
**Status:** Complete & Production-Ready
