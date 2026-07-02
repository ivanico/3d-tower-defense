# Tower's Last Stand (3D) — Project Overview

> This is the master reference file. Read this first before touching any other file.
> This is a **full restart**. The previous version of this project was built in 2D
> (sprites faking a 3D look). That approach is abandoned — lighting and shadows
> faked in 2D never looked right. This version is a **real 3D Godot project**:
> real meshes, real lights, real shadows, real 3D collision. The camera is locked
> at a fixed angle so it *plays* like Archero / a top-down tower-defense, but
> under the hood everything is genuine 3D, the same way Archero itself is built.

---

## What We Are Building

A mobile tower-defense roguelite for Android and iOS, built in Godot 4.x, in **3D**.

The player owns a collection of towers (their "heroes"). They pick one and enter a
chapter. The tower sits fixed in the center of a 3D arena. Waves of enemies walk in
from all sides across the ground. The tower auto-attacks. Between waves and on
level-up, the player drafts one of three random upgrade cards — spells or stat
boosts. Tags on cards accumulate and unlock synergy bonuses. After the run,
materials are spent in the meta layer to star up towers and rank up spells.

Core loop: **draft → fight → draft → fight → boss → result → meta upgrade → repeat.**

Think: Archero's camera, animation, and lighting approach + Tower Survivors'
auto-attack/draft loop, in a Warcraft 3 "Tower Defense reimagined as a roguelite"
frame.

---

## Why 3D, and How "2.5D" Actually Works

Archero is not 2D sprites. It is a real 3D game with:
- Real 3D character/enemy models, real skeletal animation.
- Real-time lighting and real-time (or baked) shadows.
- A **camera that never rotates** — fixed angle, fixed-ish distance, tracks the
  action area. This is what makes a full 3D game *feel* like a 2D/top-down game.
- Gameplay logic that is mostly **2D in spirit** (flat ground, 8-directional or
  free movement on a plane) even though the renderer is fully 3D.

We copy this exactly:
- **Real `Node3D` scene tree.** `CharacterBody3D` for tower and enemies,
  `MeshInstance3D` + `AnimationPlayer`/`AnimationTree` for visuals,
  `Area3D` + real 3D collision shapes for hitboxes/ranges, `DirectionalLight3D` +
  `WorldEnvironment` for lighting, real shadow maps.
- **Camera is fixed.** One `Camera3D`, locked rotation, positioned at a top-down
  angle (start at **60° pitch from horizontal**, the same angle noted in Archero
  references — tune by eye once art is in). It does not orbit, it does not follow
  rotation input. It may follow the tower position smoothly (the tower doesn't
  move, so in practice the camera barely moves either — mostly static per arena).
- **Movement plane is flat ground (X/Z), Y is up.** Ground-based enemies keep
  `position.y` constant (resting on the ground plane). Flying enemies and arcing
  projectiles are the only things that use real `Y` height — see Section
  "Verticality Rules" below.
- **All physics is real Godot 3D physics.** `Vector3` everywhere for position/
  movement. No faking 3D math with `Vector2`. Collision shapes are real
  `CollisionShape3D` (capsules, spheres, boxes) on real physics layers.

### Verticality Rules (when Y actually matters)

| Case | Y behavior |
|---|---|
| Ground enemies (chapter 1 baseline, "heavy" enemies, etc.) | `position.y` fixed at ground height (0, or mesh-specific offset). Pure X/Z movement. |
| Flying enemy type | Has a real target height (e.g. `flight_height = 1.2`), hovers there with a gentle bob, still moves on X/Z toward the tower. |
| Tower projectiles (default bolt) | Travels in a straight 3D line at a fixed height (roughly chest-height of target), simple `Vector3` velocity. No arc needed for the default shot. |
| AoE / siege / arcing projectiles | Travel along a real parabolic arc (`Y` rises then falls) computed from start point to target point — this is what makes siege/bomb-type spells feel distinct in 3D. |
| Camera | Fixed pitch and yaw, never rotates with input. May lerp position slightly for screen shake / boss intro framing, nothing else. |

---

## Reference Files

| File | Purpose |
|------|---------|
| `mechanics.md` | Every gameplay mechanic, with priority labels and v1-vs-later scope |
| `components.md` | Every Godot scene, script, autoload, and resource — component-based, no monolith scripts |
| `assets.md` | Required assets only: models, materials, UI, audio. Includes the Archero-reference setup guide (camera angle, sizes, proportions). No "how it should look" art direction beyond what's needed to match Archero's *staging*. |
| `epic_01_foundation.md` → `epic_08_polish.md` | Build epics, in order, scrum-style with tasks and acceptance criteria |
| `skills/` | Godot/GDScript reference skills for Claude Code to consult while implementing |

---

## V1 Scope vs. Future Scope

**This matters a lot — read it before starting Epic 01.**

The original (abandoned) version of these docs spec'd 5 towers, 25 spells, 4
chapters, and the full meta layer, all at once. That's the *eventual* shape of
the game, but building all of it before the core loop is fun is how projects
stall. This rebuild's epics target the **smallest possible playable loop**:

- **1 tower** to start (the basic/default one). Code structured so adding tower
  #2–5 later is "add a new `TowerDefinition` resource + a model," not new code.
- **3 spells** at launch (one simple projectile, one AoE, one passive/utility) —
  enough to prove the spell-category system works. Code structured so spell #4
  onward is "add a new `SpellDefinition` resource," not new code.
- **3 stat upgrades** at launch (damage, fire rate, max HP) for the same reason.
- **1 chapter, ~10–20 waves, 2–3 enemy types + 1 boss** to prove wave scaling
  and the boss-fight shape work.
- **Synergy tags**: implement the tag-counting system generically, ship with
  2–3 real tags wired to thresholds (enough to prove the system, not all 9).
- **Full meta layer is still in scope** (towers stars, spell ranks, materials,
  energy) because the loop doesn't make sense without "why am I playing again,"
  but it operates on the *small* v1 data set above.

Every relevant doc below calls out **"Extend later by:"** notes so it's clear
how to scale from 3 spells to 25, or 1 tower to 5, without re-architecting.

---

## Tech Stack

| | Choice | Why |
|---|---|---|
| Engine | Godot 4.x (latest stable 4.x at time of building) | Free, strong 3D mobile support, GDScript is fast to iterate in |
| Renderer | **Mobile** rendering method | This is a real 3D project with real-time lights and shadows on Android/iOS. The Mobile renderer is Godot's renderer built specifically for that case — single-pass forward rendering tuned for tile-based mobile GPUs (Adreno/Mali/Apple GPU). Forward+ is desktop-only-capable hardware; Compatibility is the 2D/legacy/WebGL fallback and is **not** what we want for real-time 3D shadows. If a WebGL/browser build is ever needed later, that's a separate export preset on Compatibility, not the primary target. |
| Language | GDScript 4 | Default, fast iteration, fine for this scope |
| Camera | Fixed-angle `Camera3D`, ~60° pitch, no rotation | Matches Archero's "2.5D" presentation |
| Target platforms | Android first, iOS second | |
| Min Android | API 24 (Android 7.0) | Reasonable device floor for Mobile-renderer 3D |
| Art pipeline | **Meshy AI** generates 3D models directly → imported into Godot as real meshes (`.glb`/`.gltf`) | No render-to-sprite step. Real meshes, real materials, real animation. |
| Shadows | Real-time `DirectionalLight3D` shadow + baked light where possible for performance | Mobile renderer supports this; tune shadow distance/resolution for perf (see `epic_08_polish.md`) |

---

## Asset Strategy

- **Models**: generated with Meshy AI (text/image → 3D model), cleaned up and
  rigged/animated as needed, exported as `.glb`, imported straight into Godot.
  No Blender-render-to-spritesheet step — Godot renders the real mesh every frame.
- **Swap policy**: every model is referenced by a named `.glb` path inside a
  `TowerDefinition`/`EnemyDefinition` resource, never hardcoded in a scene.
  Swapping an asset later means: regenerate with Meshy, export with the same
  filename, drop it in, done. No script changes. (Full detail in `assets.md`.)
- **Materials/shaders**: keep simple — `StandardMaterial3D` with baked-in cel/toon
  shading via a shared toon shader (see `assets.md` Section on shading) rather than
  hand-painted textures. Keeps the Meshy → Godot pipeline fast and consistent.

---

## Game Structure

```
World Map
  └── Chapter Select
        └── Run Start (spend 1 energy, pick tower)
              └── GameWorld (3D arena)
                    ├── Wave 1
                    │     ├── Combat (auto-attack + spells)
                    │     └── Wave Clear → Draft (pick 1 of 3 cards)
                    ├── Wave 2
                    │     ├── Combat
                    │     ├── Level Up mid-wave → Draft (combat pauses)
                    │     └── Wave Clear → Draft
                    ├── ...
                    ├── Final Wave (Boss Wave)
                    │     └── Boss killed → Victory
                    └── Tower dies at any point → Defeat
              └── Result Screen (materials earned, stats)
        └── Tower Garage (upgrade tower stars with materials)
        └── Spell Codex (rank up spells with materials)
```

---

## Core Mechanics Summary

**Tower**: Fixed at arena center. Auto-attacks. Chosen before run. 1 tower at
launch, architected for more.

**Chapters**: 1 chapter at launch (~10–20 waves), architected for more.

**Waves**: Kill-based (wave ends when all enemies dead, not purely on a timer —
fallback timer still exists so a run can never stall forever). Enemies scale per
wave.

**Draft**: 3 random cards offered after each wave clear and on each level-up.
Pick 1. No gold, no shop. Pure draft.

**Spells**: 3 at launch across however many damage-type families we ship with
(start with 2–3 families: e.g. Normal, Magic/AoE, Piercing — see `mechanics.md`).
Each fires independently on its own cooldown. Architected for many more.

**Synergy Tags**: Every card has 1–2 tags. Hitting tag thresholds unlocks passive
bonuses for the run. Generic system, 2–3 real tags wired at launch.

**Meta**: Materials earned from runs. Spent to star up towers and rank up spells.
Stars improve stats and enhance passives. Ranks add new behaviors to spells.

**Monetization**: Energy system (5/day), cosmetic tower skins, tower unlock packs
(time-saving not power), battle pass (later, not v1).

---

## Damage Type vs Armor Table (v1)

Same shape as before, smaller set. Extend the table with new rows/columns when
new damage types or armor types are added — the lookup itself is generic.

| | Unarmored | Heavy |
|---|---|---|
| Normal | 1.0× | 0.7× |
| Magic (AoE) | 1.0× | 1.25× |
| Piercing | 1.5× | 0.4× |

> **Extend later by:** adding new `DamageType` / `ArmorType` enum entries and
> new rows/columns to this table — the damage-calculation code reads the table
> generically (see `mechanics.md` Section 5 and `CombatUtils` in `components.md`),
> so it never needs new branches, only new data.

---

## Synergy Tags (v1)

> The percentages below are the *design intent*, kept human-readable here.
> The actual editable values live as named constants in `Constants.gd`
> (see `components.md` Section 2's "Balance tuning constants" block and
> Section 0's cheat sheet) — if you retune a number, update it there, and
> update this table to match so the two never silently drift apart.

| Tag | Threshold 1 (×3) | Threshold 2 (×5) |
|-----|----|----|
| [Offense] | All damage +10% (`OFFENSE_TIER1_DAMAGE_MULT`) | Every 10th attack fires a bonus projectile (`OFFENSE_TIER2_BONUS_SHOT_N`) |
| [Armor] | Take 15% less damage (`ARMOR_TIER1_DAMAGE_REDUCTION`) | Regen 1% max HP / 5 sec (`ARMOR_TIER2_REGEN_PERCENT` / `_INTERVAL`) |
| [Utility] | Spell cooldowns −10% (`UTILITY_TIER1_COOLDOWN_MULT`) | Draft shows 4 cards instead of 3 (**[LATER]**, no constant yet — see `mechanics.md` Section 4) |

> **Extend later by:** adding a new tag to the `SynergyTag` enum, a row to this
> table, and a case in `GameState._apply_synergy_bonus()` — see `mechanics.md`
> Section 6 for the full extension pattern. The original (abandoned) design had
> 9 tags ([Fire], [Chain], [Piercing], [Heavy], [Armor], [Offense], [Utility],
> [Gold], [Chaos]) — keep that list as the long-term backlog.

---

## Tower (v1)

[ADDED] Only one tower ships at launch. Base attack and passive are still
defined now so the "tower has personality" hook exists from day one.

| Tower | Base Attack | Passive |
|-------|-------------|---------|
| Default Tower | Single targeted Normal bolt | Every 5th shot fires in a small burst (3-way spread) instead of one bolt |

> **Extend later by:** adding a new `TowerDefinition` resource + a new `.glb`
> model + (optionally) a passive override script. See `components.md` Section
> on Tower for the extension contract.

---

## Epic Summary & Build Order

Work epics in order. Each epic builds on the previous one. Do not start an epic
until all tasks in the prior epic are complete and tested.

| Epic | Description | Deliverable |
|------|-------------|-------------|
| 01 Foundation | 3D project setup, camera rig, constants, autoloads, arena, one enemy walks toward tower | Playable skeleton in real 3D |
| 02 Combat | Tower fires, damage system, enemies die, XP rewards, object pool | Combat works |
| 03 Draft | Draft UI, card selection, spells fire, synergy tags, stat upgrades | Full run loop works |
| 04 Waves | Enemy variety, wave scaling, boss, chapter config, win/lose | Complete run works |
| 05 Meta | World map, tower garage, spell codex, MetaManager, save/load, energy | Full game loop works |
| 06 Art | Meshy models imported, animated, lit, shadowed; VFX particles in 3D | Looks like a game |
| 07 Audio | All SFX and music wired, AudioManager, crossfading | Sounds like a game |
| 08 Polish | Damage numbers, synergy banner, performance, mobile export | Shippable |

---

## Godot Project Settings

```
Display > Window > Size: 1080 × 1920 (portrait — UI canvas only; 3D camera frames the arena independently)
Display > Window > Stretch Mode: canvas_items
Display > Window > Stretch Aspect: keep
Rendering > Renderer: Mobile
Rendering > Textures > VRAM Compression: enabled for mobile export
Physics > 3D > Default Gravity: 9.8 (standard — ground entities snap to floor; flyers ignore gravity via a flag, see mechanics.md)
```

**Autoload order** (set in Project > Project Settings > Autoload):
1. Constants
2. EventBus
3. GameState
4. MetaManager
5. SpellRegistry
6. ObjectPool
7. AudioManager

> `WaveManager` and `DraftManager` are **not** autoloads — they are run-scoped
> manager Nodes under `game_world.tscn` (`scenes/manager/`). Singleton names are
> unchanged; only the autoload *files* are now snake_case.

---

## Folder Structure

```
res://
├── autoloads/                 # true globals only (snake_case files; PascalCase singleton names)
├── scenes/
│   ├── main/                  # game_world.tscn — hosts the manager Nodes
│   ├── manager/               # run-scoped WaveManager / DraftManager nodes (NOT autoloads)
│   ├── component/             # reusable component scenes (health, hurtbox, hitbox, mover, ...)
│   ├── game_object/           # one folder per scene
│   │   ├── tower/
│   │   ├── projectile/
│   │   ├── aoe_zone/
│   │   ├── camera_rig/
│   │   └── chap1/             # enemies grouped by chapter
│   │       └── chap1_enemy_01/   # scene + shared enemy.gd + co-located .tres
│   └── ui/
├── scripts/                   # flat global helpers (combat_utils.gd, weighted_table.gd)
├── resources/
│   ├── spells/
│   ├── towers/
│   ├── enemies/               # base class enemy_definition.gd only; per-enemy .tres live in each enemy folder
│   ├── waves/
│   └── chapters/
└── assets/
    ├── models/             # .glb files from Meshy
    ├── materials/
    ├── audio/
    ├── ui/
    └── fonts/
```

Full file list with node types and script signatures: see `components.md`.
Full asset list: see `assets.md`.
Full mechanic descriptions: see `mechanics.md`.
Full build plan: see `epic_01_foundation.md` through `epic_08_polish.md`.
Godot/GDScript implementation patterns for Claude Code: see `skills/`.
