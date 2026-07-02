# Tower's Last Stand (3D) — Components Reference

> Every scene, script, autoload, and resource in the project, plus exactly how
> they connect. Engine: Godot 4.x, Mobile renderer, real 3D.
> All code is GDScript 4. Node types are Godot 4 node names (`Node3D`,
> `CharacterBody3D`, `Area3D`, `CollisionShape3D`, etc.).
>
> **Architectural rule** (see `mechanics.md` Section 8): gameplay objects are
> built from small single-purpose components attached as child nodes, not one
> script that does everything. No script in this project should need to exceed
> roughly **150 lines**. If a script is creeping past that, a piece of it
> should split into its own component. This is the direct fix for the old
> project's monolithic `TowerBase.gd`/`EnemyBase.gd` files.

---

## 0. Balance Editing Cheat Sheet (read this first if you just want to tune numbers)

**The rule this whole project follows**: if it's a number a designer would
plausibly want to change while balancing, it lives in a `.tres` file's
exported field or a named constant in `Constants.gd` — never as a bare
literal buried inside a `match` statement or a line of gameplay logic. If you
ever find a balance number that *isn't* editable this way, that's a bug in
the implementation, not an acceptable exception — flag it and pull it out
into `Constants.gd` or the relevant `Definition` resource.

| To change... | Edit... | No code touch needed? |
|---|---|---|
| One spell's damage, cooldown, range, AoE radius | That spell's `.tres` in `resources/spells/` | Yes |
| One stat upgrade's HP/damage/fire-rate bonus, stack limit | That upgrade's `.tres` in `resources/upgrades/` | Yes |
| One enemy's HP, speed, damage, attack cooldown, XP value | That enemy's `.tres` in `resources/enemies/` | Yes |
| The tower's base HP/damage/fire-rate/range | `tower_default.tres` (or the relevant tower's `.tres`) | Yes |
| How fast enemies get tougher wave-to-wave | `Constants.ENEMY_HP_SCALE` / `ENEMY_DMG_SCALE` | Yes |
| How much XP per kill, how much XP to level up, how fast that curve grows | `Constants.XP_PER_KILL_BASE` / `XP_PER_LEVEL_BASE` / `XP_LEVEL_SCALE_PER_LEVEL` | Yes |
| A synergy tag's bonus magnitude (e.g. `[Offense]×3` damage %) | The matching constant in `Constants.gd`'s "Balance tuning constants" block (Section 2) | Yes |
| How many waves per chapter | `Constants.TOTAL_WAVES` or that chapter's `wave_count` field | Yes |
| How much a tower star / spell rank is worth | `Constants.STAR_STAT_BONUS_PER_LEVEL` / `SPELL_RANK_DAMAGE_BONUS_PER_LEVEL` | Yes |
| The cost curve for stars/ranks (materials needed) | `TOWER_STAR_COSTS` / `SPELL_RANK_COSTS` arrays (see `epic_05_meta.md` Task 05-05/05-06) | Yes |
| The damage-type vs armor-type multiplier table | The table in `project.md` "Damage Type vs Armor Table" — `CombatUtils.calculate_damage()` just looks this up | Yes |
| Boss heavy-attack frequency/strength | `Constants.BOSS_HEAVY_ATTACK_EVERY_N` / `_DAMAGE_MULT` / `_TELEGRAPH_SEC` | Yes |
| Camera angle/distance | `camera_rig.tscn`'s exported `camera_pitch_degrees` / `camera_distance` / `camera_height` (Inspector, no script edit) | Yes |

**The one place code-literacy still helps**: `GameState._apply_synergy_bonus()`
contains the `match` statement that *decides which constant applies at which
tag/threshold* — but the actual *values* it plugs in are 100% the named
constants above, never re-typed numbers. Adding a brand-new tag (not just
retuning an existing one) does need a new `match` branch — see
`mechanics.md` Section 6's extension note — but retuning an *existing* tag's
strength never does.

---



```
res://
├── autoloads/                      # true globals (snake_case files; PascalCase singletons)
│   ├── constants.gd
│   ├── event_bus.gd
│   ├── game_state.gd
│   ├── meta_manager.gd
│   ├── spell_registry.gd
│   ├── object_pool.gd
│   └── audio_manager.gd
├── scenes/
│   ├── main/
│   │   ├── game_world.tscn          # root scene during a run
│   │   ├── WorldMap.tscn
│   │   ├── TowerGarage.tscn
│   │   ├── SpellCodex.tscn
│   │   ├── DefeatScreen.tscn
│   │   └── VictoryScreen.tscn
│   ├── manager/                    # run-scoped manager Nodes (NOT autoloads)
│   │   ├── wave_manager.tscn / .gd
│   │   └── draft_manager.tscn / .gd
│   ├── component/                  # reusable component scenes (node + unchanged script)
│   │   ├── health_component.tscn / .gd
│   │   ├── hurtbox_component.tscn / .gd
│   │   ├── hitbox_component.tscn / .gd
│   │   ├── move_to_target_component.tscn / .gd
│   │   ├── targeting_component.tscn / .gd
│   │   ├── cooldown_component.tscn / .gd
│   │   ├── hit_flash_component.tscn / .gd
│   │   └── death_fx_component.tscn / .gd
│   ├── game_object/                # one folder per scene
│   │   ├── tower/
│   │   │   └── tower.tscn          # single tower scene, driven by TowerDefinition
│   │   ├── projectile/
│   │   │   └── projectile.tscn     # generic straight-line projectile
│   │   ├── aoe_zone/
│   │   │   └── aoe_zone.tscn       # generic ground-targeted AoE burst
│   │   ├── camera_rig/
│   │   │   └── camera_rig.tscn     # fixed-angle Camera3D rig
│   │   └── chap1/                  # enemies grouped by chapter
│   │       └── chap1_enemy_01/     # one scene + folder per enemy type
│   │           ├── chap1_enemy_01.tscn
│   │           ├── enemy.gd        # shared enemy script (class_name Enemy)
│   │           └── chap1_enemy_01.tres   # co-located EnemyDefinition
│   └── ui/
│       ├── HUD.tscn
│       ├── draft_ui.tscn
│       ├── draft_card.tscn
│       ├── synergy_banner.tscn
│       ├── tag_row_widget.tscn
│       └── DamageNumber3D.tscn
├── scripts/                        # flat global helpers
│   ├── combat_utils.gd
│   └── weighted_table.gd
├── resources/
│   ├── spells/
│   │   ├── spell_definition.gd     # base Resource class
│   │   ├── spell_basic_bolt.tres
│   │   ├── spell_basic_aoe.tres
│   │   └── spell_basic_passive.tres
│   ├── upgrades/
│   │   ├── stat_upgrade_definition.gd
│   │   ├── upgrade_damage.tres
│   │   ├── upgrade_fire_rate.tres
│   │   └── upgrade_max_hp.tres
│   ├── towers/
│   │   ├── tower_definition.gd
│   │   └── tower_default.tres
│   ├── enemies/                    # base class only; per-enemy .tres live in each enemy folder
│   │   └── enemy_definition.gd
│   └── chapters/
│       ├── chapter_definition.gd
│       └── chapter_01.tres
└── assets/
    ├── models/                     # .glb from Meshy, organized per assets.md
    ├── materials/
    ├── audio/
    ├── ui/
    └── fonts/
```

> **Extend later by:** for a new **enemy type**, copy an enemy folder under
> `scenes/game_object/chap<N>/` (scene + co-located `.tres`), retune the `.tres`,
> and register the scene with `WaveManager`'s `WeightedTable` — reusing the
> shared `enemy.gd` (`class_name Enemy`) rather than copying it (a duplicate
> `class_name` would clash). For a **spell** that only differs in numbers, drop a
> `.tres` into `resources/spells/` and reuse the generic `projectile`/`aoe_zone`
> scenes; a spell needing *unique behavior* graduates to its own `game_object/`
> folder. Models: drop a `.glb` into `assets/models/` and point the `.tres`
> `model_path` at it. The `tower` stays a single generic scene driven by
> `TowerDefinition`; **enemies are scene-per-type** (one folder each).

---

## 2. Constants & Enums

**File**: `res://autoloads/constants.gd`
**Type**: Autoload (Node script, `class_name Constants`)

```gdscript
enum GamePhase      { WAVE, DRAFT, BOSS, DEFEAT, VICTORY }
enum DamageType     { NORMAL, MAGIC, PIERCING }
enum ArmorType      { UNARMORED, HEAVY }
enum SpellCategory  { PROJECTILE, AOE_BURST, PASSIVE }
enum TargetMode     { CLOSEST }
enum CardRarity     { COMMON, RARE, EPIC }
enum SynergyTag     { OFFENSE, ARMOR, UTILITY }
enum MaterialType   { STANDARD }

const TOTAL_WAVES:              int   = 12     # v1 chapter length, tune in playtesting
const WAVE_DURATION_MAX:        float = 30.0   # fallback if kill-based clear stalls
const DRAFT_CARDS_SHOWN:        int   = 3
const ENEMY_HP_SCALE:           float = 1.12
const ENEMY_DMG_SCALE:          float = 1.08
const XP_PER_KILL_BASE:         int   = 10
const XP_PER_LEVEL_BASE:        int   = 100
const MAX_SPELL_SLOTS:          int   = 6      # smaller than the old 12 — v1 has fewer spells
const SYNERGY_THRESHOLD_LOW:    int   = 3
const SYNERGY_THRESHOLD_HIGH:   int   = 5
const TOWER_MAX_STARS:          int   = 5
const SPELL_MAX_RANK:           int   = 5
const MAX_ENERGY:               int   = 5
const CAMERA_PITCH_DEGREES:     float = 60.0

# --- Balance tuning constants ---
# Every number a designer would want to tweak while balancing lives here,
# named, with a comment — never as a bare literal inside a .gd script's
# logic (e.g. never `tower_damage_multiplier *= 1.10` written directly in
# GameState.gd — that line should read
# `tower_damage_multiplier *= OFFENSE_TIER1_DAMAGE_MULT` instead, with the
# 1.10 living here). See `mechanics.md` Section 6 and Section 7 for where
# each of these is consumed.
const XP_LEVEL_SCALE_PER_LEVEL: float = 1.2    # run_xp_to_next *= this, each level
const STAR_STAT_BONUS_PER_LEVEL: float = 0.10  # +10% HP/damage per star above 1
const SPELL_RANK_DAMAGE_BONUS_PER_LEVEL: float = 0.08  # +8% damage per rank above 1

# [Offense] synergy tag
const OFFENSE_TIER1_DAMAGE_MULT:    float = 1.10  # ×3 threshold
const OFFENSE_TIER2_BONUS_SHOT_N:   int   = 10     # ×5 threshold: bonus shot every Nth attack

# [Armor] synergy tag
const ARMOR_TIER1_DAMAGE_REDUCTION: float = 0.15  # ×3 threshold, tower-incoming only
const ARMOR_TIER2_REGEN_PERCENT:    float = 0.01  # ×5 threshold: % max HP per tick
const ARMOR_TIER2_REGEN_INTERVAL:   float = 5.0   # seconds per regen tick

# [Utility] synergy tag
const UTILITY_TIER1_COOLDOWN_MULT:  float = 0.90  # ×3 threshold (lower = faster)
# UTILITY ×5 (4-card draft) is [LATER] — see mechanics.md Section 4/6, no
# constant needed yet since nothing reads it this epic.

# Boss heavy-attack (Epic 04)
const BOSS_HEAVY_ATTACK_EVERY_N:    int   = 4    # every Nth regular attack is the heavy one
const BOSS_HEAVY_ATTACK_DAMAGE_MULT: float = 2.5
const BOSS_HEAVY_ATTACK_TELEGRAPH_SEC: float = 0.5
```

> **Extend later by:** adding enum entries (`DamageType.SIEGE`, `SynergyTag.FIRE`,
> etc.) and any new constants. Never remove or renumber existing enum entries
> once `.tres` resources reference them — append only.

---

## 3. Autoload Singletons

### `EventBus.gd`
**What it does**: Global signal bus. No logic, only signal declarations and
`emit_*` convenience wrappers if useful. Every cross-system communication goes
through here instead of direct node references — this is what let the
survival-game reference project (`Project_2d_survival.md`) decouple its
`ExpVial` from its `ExpManager`, and we copy that pattern exactly.

Signals (grouped):
- Combat: `enemy_died(enemy, position)`, `enemy_reached_tower(enemy)`,
  `tower_damaged(amount)`, `tower_healed(amount)`, `tower_died`.
- XP: `xp_gained(amount)`, `level_up(new_level)`.
- Wave: `wave_started(wave_number)`, `wave_cleared(wave_number)`,
  `phase_changed(phase)`, `boss_spawned`, `boss_died`.
- Draft: `draft_opened(trigger)`, `draft_closed`, `card_selected(card)`.
- Synergy: `synergy_threshold_reached(tag, level)`.
- Meta: `run_ended(victory)`, `materials_earned(amount)`,
  `tower_upgraded(tower_id, star)`, `spell_ranked_up(spell_id, rank)`.

**Location**: `res://autoloads/event_bus.gd` · **Autoload order**: 2

---

### `GameState.gd`
**What it does**: Single source of truth for the in-progress run — phase, wave
number, level/XP, tower stat totals (base + bonuses from drafted cards/stars),
active spells, tag counts, active synergy flags, run stats (kills, waves
cleared, damage dealt).

Key methods (each does ONE thing — if you find yourself adding unrelated logic
to one of these, it belongs in a new method or a new autoload, not bolted on):
- `start_run(tower_def: TowerDefinition)` — reset run state, apply tower base
  stats, emit `phase_changed`.
- `gain_xp(amount)` — accumulate XP, handle level-up + trigger draft.
- `take_damage(amount)` / `heal(amount)` — tower HP changes, emits
  `hp_changed` / relevant `EventBus` signals.
- `add_tag(tag)` — increment `tag_counts[tag]`, check threshold, call
  `_apply_synergy_bonus()`.
- `apply_card(card)` — dispatch to spell-add or stat-delta logic based on
  card's Resource type.
- `_apply_synergy_bonus(tag, level)` — the one `match` statement allowed to
  grow over time (see `mechanics.md` Section 6); every other piece of game
  logic should read the resulting flags/multipliers from `GameState`, not
  duplicate this `match`.
- `end_run(victory)`, `reset()`.

**Location**: `res://autoloads/game_state.gd` · **Autoload order**: 3

---

### `MetaManager.gd`
**What it does**: Persistent (between-run) player data — owned towers, tower
star levels, spell ranks, materials, energy, premium currency, selected tower.
`save()`/`load()` read/write a `SaveData` resource to `user://savegame.tres`.

**Location**: `res://autoloads/meta_manager.gd` · **Autoload order**: 4

---

### `SpellRegistry.gd`
**What it does**: Loads every `SpellDefinition` and `StatUpgradeDefinition`
`.tres` file from `resources/spells/` and `resources/upgrades/` at startup
(via `DirAccess` directory scan — never a hardcoded list of filenames, so new
`.tres` files are picked up automatically). Exposes `get_all_cards()`,
`get_spells_by_tag(tag)`.

**Location**: `res://autoloads/spell_registry.gd` · **Autoload order**: 5

---

### `WaveManager.gd` (run-scoped manager Node — NOT an autoload)
**What it does**: Spawns enemies each wave by picking an enemy **scene** from a
`WeightedTable` and `instantiate()`-ing it (fresh instance, `queue_free()`d on
death — enemies are **not** pooled) at arena-edge points, tracks
`_active_enemies`, emits `wave_started`/`wave_cleared`, and listens to
`EventBus.start_wave_requested`. Does **not** contain any enemy-type-specific
logic.

**Location**: `res://scenes/manager/wave_manager.gd` — a child Node of
`game_world.tscn` (`class_name WaveManager`), **not** a `project.godot` autoload.

---

### `DraftManager.gd`
**What it does**: Builds the 3-card draft pool (weighted by rarity, filtered
for already-maxed stackables), opens/closes the draft UI flow via
`EventBus`, applies the selected card via `GameState.apply_card()`.

**Location**: `res://scenes/manager/draft_manager.gd` — a child Node of
`game_world.tscn` (`class_name DraftManager`), **not** a `project.godot` autoload.
It reacts to `EventBus.level_up` (open a level-up draft) and `EventBus.run_reset`
(clear state), and requests the next wave via `EventBus.start_wave_requested`.

---

### `ObjectPool.gd`
**What it does**: Generic pool keyed by `PackedScene.resource_path`.
`acquire(scene)`, `release(node)`, `preload_pool(scene, count)`. Used for
projectiles and other reusable objects — the same generic pool, no per-type
pool code. **Enemies are not pooled** — they `queue_free()` on death.

**Location**: `res://autoloads/object_pool.gd` · **Autoload order**: 6

---

### `AudioManager.gd`
**What it does**: SFX player pool + 2-player music crossfade. Listens to
`EventBus` for what to play (see `epic_07_audio.md` for the full signal wiring
list). No gameplay logic lives here — purely reactive to events.

**Location**: `res://autoloads/audio_manager.gd` · **Autoload order**: 7

---

## 4. Components (`res://scenes/component/`)

This is the section that most directly replaces the old monolithic
`TowerBase.gd` / `EnemyBase.gd`. Each component below is a small script
attached to a child `Node`/`Node3D`/`Area3D` of whatever scene uses it. A
component reads its own exported config, does its one job, and talks to the
rest of the world only through signals or through calling another component
on the *same* owner node (e.g. `HurtboxComponent` calls its sibling
`HealthComponent.damage()` directly — that's fine, siblings on the same object
can call each other; what we avoid is one script knowing about and managing
unrelated concerns like animation, audio, AND combat AND movement all at once).

### `health_component.gd`
- **What it does**: `class_name HealthComponent extends Node`. Exports
  `max_health: float`. Tracks `current_health`. `damage(amount)` subtracts and
  clamps at 0, emits `health_changed(current, max)`, and if `<= 0` emits
  `died` (deferred, to avoid structural changes mid-physics-step — same
  pattern as the survival-game reference's `check_death()`). `heal(amount)`
  adds and clamps at max, emits `health_changed`. `reset()` restores to max —
  required for pooled objects.
- **Used by**: Tower, every enemy variant (via the generic `chap1_enemy_01.tscn`).

### `hurtbox_component.gd`
- **What it does**: `class_name HurtboxComponent extends Area3D`. Exports
  `armor_type: ArmorType`. On `area_entered` from a `HitboxComponent`: reads
  the hitbox's `damage`/`damage_type`, calls
  `CombatUtils.calculate_damage(damage, damage_type, armor_type)`, passes the
  result to the sibling `HealthComponent.damage()`.
- **Used by**: Tower, every enemy.

### `hitbox_component.gd`
- **What it does**: `class_name HitboxComponent extends Area3D`. Exports
  `damage: float`, `damage_type: DamageType`. Set by whatever spawns it
  (projectile, AoE zone) right before it enters the scene tree. Pure data +
  the `Area3D` shape; no behavior beyond carrying these two values for the
  hurtbox to read.
- **Used by**: `projectile.tscn`, `Arcprojectile.tscn`, `aoe_zone.tscn`.

### `move_to_target_component.gd`
- **What it does**: `class_name MoveToTargetComponent extends Node`. Exports
  `speed: float`, `hold_height: float = 0.0` (0 = ground-bound), `gravity_enabled: bool = true`.
  Each `_physics_process`, computes direction from owner's position to a
  target `Vector3` (tower position, passed in at spawn or fetched from
  `GameState`), moves the sibling `CharacterBody3D` via `move_and_slide()`.
  If `hold_height > 0`, ignores gravity and lerps `position.y` toward
  `hold_height` with a small sine-wave bob (this is the flyer hook described
  as **[LATER]** in `mechanics.md` — the component supports it from day one
  even though no v1 enemy sets `hold_height`).
- **Used by**: every enemy.

### `targeting_component.gd`
- **What it does**: `class_name TargetingComponent extends Node`. Exports
  `range: float`, `mode: TargetMode`. Maintains a list of enemies currently
  inside an `Area3D` range trigger (sibling node), exposes
  `get_target() -> Node3D` which applies the current `mode` (v1: closest only;
  `match mode:` with one case — new modes are new cases, not new
  architecture).
- **Used by**: Tower.

### `cooldown_component.gd`
- **What it does**: `class_name CooldownComponent extends Node`. Exports
  `duration: float`. `tick(delta)` (or just use a Godot `Timer` child — either
  is acceptable, pick `Timer` for anything that doesn't need pause-aware
  custom logic). Exposes `is_ready() -> bool`, `consume()` (resets the timer).
  One instance per spell-on-the-tower and per attack-on-an-enemy — cheap,
  reusable, no special-casing per spell.
- **Used by**: Tower (one per active spell), every enemy (attack cooldown).

### `hit_flash_component.gd`
- **What it does**: `class_name HitFlashComponent extends Node`. Exports
  `mesh: MeshInstance3D`. Listens to sibling `HealthComponent.health_changed`,
  briefly swaps/tweens an emission or albedo shader parameter to white and
  back — same approach as the survival-game reference's shader-based flash,
  adapted from a 2D `CanvasItem` shader to a 3D `StandardMaterial3D`/
  `ShaderMaterial` emission tween.
- **Used by**: every enemy, tower.

### `death_fx_component.gd`
- **What it does**: `class_name DeathFXComponent extends Node`. Listens to
  sibling `HealthComponent.died`, plays a death effect (currently a shrink
  tween), then on completion `queue_free()`s the owner. Enemies are **not**
  pooled — they are freed on death (a death `AnimationPlayer` can replace the
  tween later; the `queue_free()` timing stays).
- **Used by**: every enemy.

> **Extend later by:** adding a new component file for any genuinely new
> behavior (e.g. a `ShieldComponent` for an armored elite, a `BurnComponent`
> for a DoT-applying spell). Attach it only to the things that need it. Never
> add a `has_shield: bool` flag and an `if` branch to `HealthComponent` itself
> — that is exactly the monolith pattern this architecture exists to avoid.

---

## 5. Resource Definitions (data-driven content)

### `tower_definition.gd`
**What it does**: `class_name TowerDefinition extends Resource`. Fields:
`tower_id`, `tower_name`, `model_path` (the `.glb` to instance),
`base_hp`, `base_damage`, `base_fire_rate`, `base_range`, `base_armor`,
`starting_spell_id` (the base-attack spell, fired even with zero drafted
spells), `passive_script` (optional `Script` resource implementing the
tower's unique passive hook — see `tower_default.tres` for the v1 instance).
**One `.tres` per tower.** `tower.tscn` is generic and reads whichever
`TowerDefinition` is assigned.

### `enemy_definition.gd`
**What it does**: `class_name EnemyDefinition extends Resource`. Fields:
`enemy_id` (e.g. `"chap1_enemy_01"`), `model_path`, `base_hp`, `base_speed`,
`base_damage`, `attack_cooldown`, `armor_type`, `xp_value`,
`is_boss: bool = false`, `hold_height: float = 0.0` (flyer hook, 0 for all v1
enemies). **One `.tres` per enemy type.** `chap1_enemy_01.tscn` is generic.

### `spell_definition.gd`
**What it does**: `class_name SpellDefinition extends Resource`. Fields:
`spell_id`, `spell_name`, `description`, `icon`, `rarity`, `spell_category`,
`damage_type`, `tags: Array[SynergyTag]`, `damage`, `cooldown`, `range`,
`aoe_radius` (if applicable), `projectile_scene` (which generic projectile
scene to use — `projectile.tscn` or `Arcprojectile.tscn`).

### `stat_upgrade_definition.gd`
**What it does**: `class_name StatUpgradeDefinition extends Resource`. Fields:
`upgrade_id`, `upgrade_name`, `description`, `icon`, `rarity`,
`tags: Array[SynergyTag]`, `hp_bonus`, `damage_multiplier`,
`fire_rate_multiplier`, `is_stackable`, `stack_max`.

### `chapter_definition.gd`
**What it does**: `class_name ChapterDefinition extends Resource`. Fields:
`chapter_id`, `chapter_name`, `wave_count`, `enemy_pool: Array[EnemyDefinition]`,
`boss: EnemyDefinition`, `arena_model_path`.

> **Extend later by:** every one of these is "add a new `.tres`." None of them
> require touching `tower.tscn`, `chap1_enemy_01.tscn`, or any autoload code.

---

## 6. Key Scenes

### `tower.tscn`
- **Root**: `CharacterBody3D` (static in practice, but `CharacterBody3D` keeps
  the door open for knockback/forced movement later without a node-type
  change), group `"tower"`.
- **Children**: `MeshInstance3D` (model swapped at runtime from
  `TowerDefinition.model_path`), `CollisionShape3D`, `HealthComponent`,
  `HurtboxComponent`, `TargetingComponent` (+ its range `Area3D`),
  `HitFlashComponent`, one `CooldownComponent` instanced per active spell
  (added/removed dynamically as spells are drafted).
- **Script** (`tower.gd`, kept intentionally thin): on `_ready()`, applies the
  assigned `TowerDefinition`'s base stats to `GameState`; on
  `_physics_process()`, ticks each spell's `CooldownComponent` and fires when
  ready by delegating to a small `_fire_spell(spell_def)` that switches on
  `spell_category` to pick `projectile.tscn`/`Arcprojectile.tscn`/AoE/passive
  — and nothing else. All the "how do I take damage," "how do I find a
  target," "how do I flash white" logic lives in the components above, not in
  `tower.gd`.

### `chap1_enemy_01.tscn`
- **Root**: `CharacterBody3D`, group `"enemies"`.
- **Children**: `MeshInstance3D`, `CollisionShape3D`, `AnimationPlayer`,
  `HealthComponent`, `HurtboxComponent`, `MoveToTargetComponent`,
  `CooldownComponent` (attack cooldown), `HitFlashComponent`,
  `DeathFXComponent`, an `Area3D` "melee range" trigger.
- **Script** (`enemy.gd`, thin): on spawn, applies the assigned
  `EnemyDefinition`'s stats to its components; on melee-range trigger enter,
  flips from "moving" to "attacking" state and ticks the attack
  `CooldownComponent`, dealing tower damage on expiry. That's the entire
  script — movement, health, damage-taking, flashing, and dying are all
  delegated.

### `projectile.tscn` / `Arcprojectile.tscn` / `aoe_zone.tscn`
- Generic, reused by every spell of that category. `Arcprojectile.tscn`
  computes a parabolic `Y` path from spawn point to target point (see
  `mechanics.md` Verticality Rules) instead of a straight line — this is the
  only meaningful difference from `projectile.tscn`.

### `camera_rig.tscn`
- `Node3D` root holding the fixed-pitch `Camera3D` child, plus the
  screen-shake helper method (`shake(duration, magnitude)` — tweens a small
  local offset and back). No follow logic needed at v1 since the tower never
  moves; if a future chapter has a moving focal point, the rig is the only
  place that needs to change.

---

## 7. UI Scenes

Same shape as the original design's UI layer (`HUD`, `DraftUI`, `DraftCard`,
`SynergyBanner`, `TagRowWidget`), unchanged in spirit since UI is a 2D
`CanvasLayer` concern regardless of whether the game world is 2D or 3D. One
addition:

### `DamageNumber3D.tscn`
- **What it does**: A pooled `Label3D` (or `Sprite3D` displaying a generated
  number texture — `Label3D` is simpler and fine at this scale) set to
  billboard mode so it always faces the fixed camera. Spawns at a 3D hit
  position, tweens upward and fades, returns to pool. Replaces the old 2D
  `DamageNumber.tscn`'s `Label` root with a `Label3D` root — same
  spawn/tween/pool contract otherwise.

---

## 8. Groups (cross-system lookups without hard references)

| Group | Members | Used by | Why |
|---|---|---|---|
| `"tower"` | `tower.tscn` instance | `chap1_enemy_01.tscn` (melee target), `TargetingComponent` | Enemies and systems find the tower without a hardcoded scene path |
| `"enemies"` | every spawned `chap1_enemy_01.tscn` instance | `TargetingComponent`, `HitboxComponent` collision checks | Targeting/hit systems query this group instead of holding arrays of references that can go stale |

---

## 9. Design Patterns In Use (mirrors the survival-game reference project)

1. **Component Pattern** — Section 4. Direct fix for the old monolith problem.
2. **Signal Bus (`EventBus`)** — systems never hold direct references to each
   other for cross-cutting concerns (audio, UI, meta progression all react to
   signals instead of being called directly).
3. **Groups as Queries** — `"tower"`/`"enemies"` groups instead of stored node
   references, so nothing breaks on scene reload/pooling.
4. **Data-Driven Content via `Resource` files** — `TowerDefinition`,
   `EnemyDefinition`, `SpellDefinition`, etc. New content is new `.tres` +
   new `.glb`, basically never new code.
5. **Object Pooling** — generic pool, no per-type pool code.
6. **Deferred calls for structural changes** — death/release logic deferred to
   avoid "can't change physics state during physics step" errors, same as the
   survival-game reference's `HealthComponent.check_death()`.
