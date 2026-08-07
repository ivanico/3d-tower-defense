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
| The tower's base HP/damage/fire-rate/range | `tower_ancient_tower.tres` (or the relevant tower's `.tres`) | Yes |
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
│   │   ├── standard_bolt/
│   │   │   └── standard_bolt.tscn  # generic straight-line projectile (spells.md archetype #2)
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
│   │   ├── spell_<archetype>_<school>.tres  # the 20 catalog spells (spells.md §4)
│   ├── upgrades/
│   │   ├── stat_upgrade_definition.gd
│   │   ├── upgrade_damage.tres
│   │   ├── upgrade_fire_rate.tres
│   │   └── upgrade_max_hp.tres
│   ├── towers/
│   │   ├── tower_definition.gd
│   │   └── tower_ancient_tower.tres
│   ├── enemies/                    # base class only; per-enemy .tres live in each enemy folder
│   │   └── enemy_definition.gd
│   └── chapters/
│       ├── chapter_definition.gd
│       └── chapter_01.tres
└── assets/
    ├── models/                     # .glb from Meshy: towers/<tower_id>/, chap<N>/ — see assets.md
    ├── materials/
    ├── audio/
    ├── ui/                         # per-screen/shared subfolders — full tree in ui_assets.md
    └── fonts/
```

> **Extend later by:** for a new **enemy type**, copy an enemy folder under
> `scenes/game_object/chap<N>/` (scene + co-located `.tres`), retune the `.tres`,
> and register the scene with `WaveManager`'s `WeightedTable` — reusing the
> shared `enemy.gd` (`class_name Enemy`) rather than copying it (a duplicate
> `class_name` would clash). For a **spell** that only differs in numbers, drop a
> `.tres` into `resources/spells/` and reuse the generic `projectile`/`aoe_zone`
> scenes; a spell needing *unique behavior* graduates to its own `game_object/`
> folder. Models: drop a `.glb` into `assets/models/chap<N>/` (enemies/arenas)
> or `assets/models/towers/<tower_id>/` (towers) and point the `.tres`
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
enum SpellCategory  { PROJECTILE, PASSIVE, ORB, AOE_AREA }
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

The directory scan itself lives in **`res://scripts/resource_dir.gd`**
(`ResourceDir.load_all(path)`), shared with `TowerRegistry` — **do not copy that
loop into a registry.** It is `preload()`ed rather than reached for as a global
`class_name`, for the usual global-class-cache reason.

---

### `TowerRegistry.gd`
**What it does**: Loads every `TowerDefinition` `.tres` from `resources/towers/`
at startup via the same `ResourceDir` scan, sorted by `sort_order` — that
ordering is what the garage grid shows, and it is explicit so renaming a resource
cannot silently reshuffle the grid. Exposes `get_by_id()`, `get_unlocked()`,
`is_playable(id)` (exists as content **and** owned by the player), and
`get_preview_model(id, star)`.

`get_preview_model()` resolves the raw `.glb` by ID convention
(`assets/models/towers/<id>/<id>_lvl<star>.glb`). It exists specifically so the
garage never reaches for `star_level_scenes` — those are gameplay scenes and
`tower.gd._ready()` calls `GameState.start_run()`.

**Location**: `res://autoloads/tower_registry.gd` · **Autoload order**: 6

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
- **Used by**: `standard_bolt.tscn`, `Arcprojectile.tscn`, the spell archetype scenes (`chain_bolt`, `line_aoe_bolt`, `aoe_area`).

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
tower's unique passive hook — see `tower_ancient_tower.tres` for the v1 instance).
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

### `standard_bolt.tscn` / `Arcprojectile.tscn`
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

> **Changing how the UI looks? Read `ui_tuning.md` instead of this section.**
> It is the practical guide: which file to open, which exported knob to change,
> and the traps (icon canvas fill, sub-pixel outlines, non-9-sliceable art).
> This section explains how the layer is *wired* and why; that one explains how
> to *tune* it without touching code.

Same shape as the original design's UI layer (`HUD`, `DraftUI`, `DraftCard`,
`SynergyBanner`, `TagRowWidget`), unchanged in spirit since UI is a 2D
`CanvasLayer` concern regardless of whether the game world is 2D or 3D.

### Reusable widgets (`scenes/ui/widget/<name>/<name>.tscn`)

One folder per widget; screens **instance** the widget instead of rebuilding
it, so a texture/scale change inside the widget scene applies everywhere at
once. Each art texture is referenced in exactly ONE widget `.tscn` — swapping
an asset version = changing that single texture reference. Built so far:
`primary_button` (Button + `ui_button_primary.png` stylebox),
`secondary_button` (Button + `ui_button_secondary_v3.png` stylebox),
`currency_pill` (`class_name CurrencyPill`, `@tool` Control. The icon is **not
inside** the pill — it is a sibling declared after it so it paints on top, which
is the only way it can be TALLER than the pill and overhang it top and bottom.
That overhang is the look. `Pill` is a PanelContainer with the
`ui_topbar_pill_bg.png` stylebox; its `margin_left` is driven to `icon_overlap +
text_gap` so the amount always clears the icon. Knobs: `pill_size`, `icon_size`
(keep above `pill_size.y`), `icon_overlap`, `text_gap`, `font_size`, `icon`,
`amount`. `set_amount()` unchanged for screens),
`top_bar` (HBoxContainer instancing two `currency_pill`s: energy =
`icon_currency_energy1.png`, materials = **`icon_currency_materials1.png`** at
`icon_scale = 0.82`. Its height is the ICON's height, not the pill's, because of
that overhang. **The icon PNGs are all 1254×1254 but their artwork fills wildly
different fractions of that canvas** — bolt 47.4%×67.0%, plain gem 57.4%×56.2%,
`materials1` gem 83.1%×81.2% — so identical node sizes do NOT give identical
apparent sizes. `icon_scale` exists to correct for that: 0.82 puts the gem's
drawn height at 0.812×0.82×124 = 83px, matching the bolt's 0.670×124 = 83px.
Measure with `Image.get_used_rect()` before changing an icon; do not eyeball it.
⚠️ `victory_screen.tscn` and `defeat_screen.tscn` still use the *plain*
`icon_currency_materials.png` for their materials-earned label, so the two gems
differ between screens — unify when those screens next get touched),
`play_button` (`class_name PlayButton`, `@tool` Button — the big Play control on
the world map. `ui_play_button_v3.png` as a StyleBoxTexture with two stacked
lines: `play_text` on top, then the energy icon + `xN` cost. **The art is 1905×825
and its gold frame cannot be 9-sliced**, so the whole image stretches: keep
`lock_aspect` on or the corners visibly distort, and content sits inside the
art's interior via `margin_h`/`margin_top`/`margin_bottom` fractions measured off
the blue panel. `cost_amount` is fed from `Constants.ENERGY_COST_PER_RUN`.
Note `_apply()` carries an `_applying` re-entry guard — locking the aspect writes
back to `button_height`, whose setter re-enters `_apply()` and would recurse
until the stack blew),
`nav_button` (`@tool` Button drawn as a shaded tile. Background is **two stacked
NinePatchRects** — the unselected look under the selected one — cross-faded by
`bg_blend`. Not a StyleBoxFlat, because that has a single `bg_color` and cannot do
a gradient at all, and the vertical shading is the whole look. Both patches are
forced to `TEXTURE_FILTER_NEAREST`: the tile texture is six pixels wide and its
centre column stretches across the entire tile, so under the default linear filter
the dark edge colour bleeds hundreds of pixels inward and the tile reads as shaded
left-to-right. Icon, label and badge are
**internal children built in code**, and `_validate_property` strips every
`theme_override_*` from storage, so instancing it into a screen bakes nothing.
Per-entry exports are only `icon_texture`, `label_text` and the badge fields;
colour, tile size, icon scale and font are pushed in by `nav_bar` via
`style_tile()` / `set_content()` so the three tiles cannot drift apart —
**setting colours on an individual button does nothing, they are overwritten on
every layout pass**),
`nav_bar` (`@tool` Control instancing three `nav_button`s. **Order is
Garage · Worldmap · Codex — Worldmap is deliberately in the MIDDLE**, because the
world map is what the game opens on, so it is the home position. `nav_bar.gd`'s
`Nav` enum indexes that same order; keep them in step if you reorder. Screens set
`nav_bar.selected` and the bar does the rest: the selected tile is wider by
`selected_extra_width`, shaded tan instead of grey, shows its `label_text`, and is
disabled so a screen cannot navigate to itself. **Do not set `disabled` on the
buttons from a screen** — that is what `selected` replaced.

It is a plain Control rather than an HBoxContainer because a container will not
let one child be wider or taller than its siblings, and that difference is the
entire design. Tiles are laid out flush and sized to add up to exactly the inner
width, so `selected_extra_width` only redistributes space and never leaves a seam.
A `Panel` added with `INTERNAL_MODE_FRONT` paints the frame behind them, showing
through `frame_side` / `frame_top` / `frame_bottom` — three knobs rather than one
because the bar runs edge to edge (`frame_side = 0`) while its bottom border is
far thicker than its top. Seams are `ColorRect`s added with `INTERNAL_MODE_BACK`
so they paint OVER the tiles, one per internal boundary. They are deliberately not
baked into the tile texture: an edge baked there would also run down the outer
sides of the first and last tile, which breaks edge-to-edge.

Each seam is **snapped to whole device pixels** via `_device_scale()`
(`get_viewport().get_final_transform()`), and `_apply` is re-run on
`Viewport.size_changed` because the design space stays 1080×1920 however the
window is resized, so `resized` never fires for it. Without the snap the two seams
render different widths from identical numbers: 3 units is ~1.4 real pixels, and
the two seams sit symmetrically about the bar's centre so their fractional offsets
are mirror images and round opposite ways — one 2px, one 1px.

**No artwork**; only the three icons are PNGs. The tiles come from
`BarTexture.make_tile()`, two pixels wide and stretched horizontally. Shading is
two bands — a gradient from `*_color_top` to `*_color_split` ending at `*_split`
of the height, then a flat `*_color_bottom` — plus `highlight_height` rows of
`*_highlight_color` at the very top, which is the shine. `*_split = 1.0` collapses
that to one continuous fade, which is what the selected tile uses. **Every default
was sampled off the reference screenshot, not guessed**: grey tiles
`#ddd9cf → #eae8db` over flat `#dedbd4` with an `#f8f8f4` top line, selected
`#c5966e → #edd3b8`. Tiles are square-cornered — the reference has no rounding, so
the radius knob was removed rather than defaulted to 0.

Changing `selected` at runtime tweens position, size, `icon_px`, `label_alpha`
and `bg_blend` over `animation_time` (snapped in the editor, and snapped on
`_ready`, so a freshly loaded screen does not animate itself in). Since each meta screen is its own
scene, screens call **`nav_bar.navigate_to(target, path)`** rather than
`change_scene_to_file` directly — the swap would otherwise kill the tween on its
first frame and nothing would ever be seen. Badges are per-button:
`badge_visible` / `badge_text` / `badge_size` / `badge_anchor` / `badge_offset`,
using `ui_notification_badge.png`),
`hp_bar` / `xp_bar` (TextureProgressBars driven by `value_bar.gd` — one `@tool`
script shared by both widgets, do not duplicate it. The bar is **drawn
procedurally**, not stretched from a texture, which replaced a bitmap approach
that squashed a 1563×235 pill into 740×56 — a 2:1 non-uniform scale that
flattened the round caps into stretched ovals. Three stacked layers, all from
the same generator: `texture_under` = the dark empty track, `texture_progress`
= the coloured fill, `texture_over` = the rim that frames the bar. Because the
fill is clipped horizontally by `value`, a partly-full bar has a **flat right
edge** — that is correct and matches the reference art; only the track keeps
round ends. Inspector properties: `bar_size` (px), `color_top`/`color_bottom`
(fill gradient), `track_color_top`/`track_color_bottom`, `rim_color`,
`rim_width` (px, 0 = no rim), `corner_radius` (px). `scale` is forced to 1 —
**never scale these bars**. `hud.gd` drives `value` 0–100, unchanged.
**`hp_bar` is retired from the in-run HUD** — the tower's health is now
`value_bar_3d` floating over the tower. The scene is kept as the ready-made
red screen-space variant if a 2D health readout is ever wanted back. All the
bar PNGs (`*_bg_*`, `*_fill_*`, `*_pill*`) are unused — the bars have been
fully procedural since the art was retired),
`bar_texture.gd` (**not a widget** — one static `make_capsule()` that rasterises
the rounded-rect capsule, plus a `split` param for a two-band gradient (glossy
top band, flat below — see `value_bar.gd::color_split`) and a `highlight_color`/
`highlight_height` param for a thin bright line blended onto either layer.
Shared by BOTH `value_bar.gd` and `value_bar_3d.gd` so the 2D and 3D bars cannot
drift apart. It lives at `scenes/ui/widget/` root rather than in a widget folder,
same as `value_bar.gd`, because it belongs to no single widget. It is `@tool`
because both its callers are. **Consumers `preload()` it and deliberately do
NOT use a global `class_name`** — see the warning below),
`pause_button` (`@tool` Button, top-left in-run. **Drawn, not art** — there is
no pause-glyph PNG, and a StyleBoxFlat panel plus two Panel bars stays crisp
where a 1200px generated icon would have to be shrunk. Knobs: `button_size`,
`panel_color`, `corner_radius`, `border_color`/`border_width`, `pressed_dim`,
`glyph_color`, `glyph_bar_size`, `glyph_gap`, `glyph_corner_radius`. It only
emits `pressed` — **it deliberately does not touch `get_tree().paused`**, see
the pause note below),
`value_bar_3d` (`@tool` Node3D — a GENERIC floating value bar over a unit, not
health-specific by name or design (only one convenience on it is HP-flavoured,
see below) — used today for the tower's HP and every chapter-1 enemy/boss's HP,
and equally reusable for a future XP/mana/shield bar in 3D space. Billboarded
layers, back to front by `render_priority`: Track → Fill → Value's outline
copies → Value (`Label3D` showing the number, optional via `show_value`). Art
comes from `BarTexture.make_capsule()`, so it matches the HUD bar automatically.
**The bar's own outline is baked into the Track and the Fill is inset inside it
by `rim_width`** — it is deliberately NOT a separate rim quad on top; that was
tried and failed (billboarded sprites all sit at the same depth, `render_priority`
did not reliably hold a separate rim above the fill). Insetting makes the outline
geometrically unreachable regardless of sort order. Keep it that way.
`billboard = BILLBOARD_ENABLED`, **not** `BILLBOARD_FIXED_Y` — the camera is a
fixed pitched perspective camera (see `camera_rig.gd`), which would leave a
fixed-Y bar tilted. The fill does not regenerate its image per hit: it reveals
part of the drawn capsule via `region_rect` and shifts `offset` to stay pinned
left — two floats per update. No `SubViewport`, per the vfx-audio skill.

**The number's outline is a separate, harder problem than the bar's**, solved
after several false starts, all worth knowing before touching `_value`/
`_value_outlines`: (1) Label3D ignores the project's `Theme`, so the font must
be preloaded and assigned explicitly (`VALUE_FONT`) or it silently falls back
to Godot's generic font. (2) that font's `.import` needed
`multichannel_signed_distance_field` turned on — without MSDF, thin diagonal
strokes (the "1" glyph, specifically) render with a broken gap once Label3D
scales the glyph through 3D space, even though the identical font is fine in a
fixed-size 2D Label. (3) Label3D's own `outline_size` is separately broken
**when combined with MSDF** in this Godot build — any outline at all turns the
whole glyph solid black, at every `msdf_pixel_range` tried — so `outline_size`
is never used; `outline_size = 0` always. The outline look instead comes from
`_value_outlines`: flat-colour copies of the same text at the SAME `font_size`
(scaling the whole string, tried first, drifts the letter spacing apart on
multi-digit numbers and reads as smeared shadows, not an outline), each nudged
along `SCREEN_RIGHT`/`SCREEN_UP` — vectors computed to lie truly in the fixed
camera's view-perpendicular plane. Naive world `(0,1,0)`/`(0,-1,0)` offsets are
NOT perpendicular to a pitched camera's view direction, so an "up" copy sits
measurably closer to the camera than the white text and "down" sits farther —
genuinely different depths, not just visually adjacent — which made transparent
-quad sort order between the layers ambiguous and camera-distance-dependent,
surfacing as an intermittent white blob over the number depending on unit
position. `SCREEN_RIGHT`/`SCREEN_UP` fixed it by keeping every layer genuinely
coplanar. (Also tried and reverted: 8 offset directions instead of 4 — more
overlapping layers, same risk, no benefit; `ALPHA_CUT_DISCARD` — moves the quad
from the transparent queue, which respects `render_priority`, into the opaque
queue, which uses hardware depth-test instead, and with no explicit Z
separation between layers that just traded one sorting bug for a worse one.)

`follow_game_state = true` makes it subscribe to `GameState.hp_changed` and
self-prime on its own, which is why the tower scenes needed no script change —
this is the one HP-flavoured convenience the component has. Everything else
that's `false` (every enemy/boss) instead auto-discovers a sibling
`HealthComponent` the same way `hit_flash_component.gd` does and wires itself
to `health_changed`, no per-unit script needed either; a future non-HP bar
with no such sibling just gets a harmless no-op there and calls the public
`set_value(current, max_value)` from whatever drives it instead (same as the
2D XP bar, driven by `GameState.xp_bar_updated`, not a component).

**Look is reusable across scenes via `Bar3DStyle`** (`bar_3d_style.gd`, a
plain `Resource`) instead of copy-pasting the same ~12 property values into
every scene that wants a given look: assign `style` and it's used INSTEAD OF
the matching individual export (assigning it never mutates those exports, so
the Inspector doesn't show misleading "manually set" values). Two presets ship
in `resources/ui/`: `enemy_bar_style.tres` and `boss_bar_style.tres` (same red/
translucent look, different size) — every chapter-1 enemy/boss references one
of these with a single `style = ExtResource(...)` line instead of inline
values, so changing the look is a ONE-file edit. The tower keeps tuning its
own bar inline (no style assigned) since only it wants the green look.
`height_offset`, `show_value`, and `follow_game_state` are deliberately NOT
part of `Bar3DStyle` — they're genuinely per-instance (each unit's own model
height, whether it shows a number, how it gets its value), not "look".),
`chapter_node` (`@tool` Control — **display only, not a Button any more**. Just
the chapter artwork plus a hidden `ui_locked_overlay.png`; exports
`chapter_image`/`locked`. The decorative frame was dropped, the play bar moved out
to the screen-level `play_button`, and the chapter name moved to the world map's
title label — matching the reference layout where the art is a picture and Play is
the control. `ui_chapter_node_frame*.png` is orphaned by this),
`star_row` (5 TextureRects swapped between `ui_star_filled/empty.png` by
`set_stars()`; `Constants.TOWER_MAX_STARS` worth of nodes live in the scene
so they're editor-tunable),
`meta_row` (`class_name MetaRow` — the ONE shared upgrade row for BOTH meta
screens. Layout is horizontal: `HBox` = Icon · Info (NameLabel, StatusSlot
holding either a `star_row` or a RankLabel, StatsRow with two icon+value
chips OR one plain stats line) · Actions (hidden "In Use" CheckButton +
`primary_button` UpgradeButton at a fixed 280×154). Screens call
`set_row_icon/set_title/show_stars|show_rank/set_stat_chip|set_stat_text/
set_upgrade_cost|set_upgrade_maxed/show_select` and connect its
`upgrade_pressed`/`select_pressed` signals — **never build row Controls in
code, and never copy this scene per screen**. Its panel is a
**StyleBoxFlat**, not the panel art — see the sizing rules below).

**Wired screens:** `world_map.tscn` is the home screen and the project's
`main_scene`. Top to bottom: `top_bar` (pills fed from
`MetaManager.energy/materials`), a big `TitleLabel` carrying the chapter name, a
760×760 centred `chapter_node`, the `play_button`, then `nav_bar` with
`selected = WORLDMAP`. The nav bar spans the **full 1080 width, flush to the
bottom edge** (y 1730–1920) on all three meta screens — the tiles are the bar, so
insetting it would leave the strip floating. Background is `bg_worldmap.png`
full-screen.
**Pressing Play** — not the artwork — spends energy and starts the run.
The chapter's picture is data-driven: `ChapterDefinition.map_image` (new
`@export`, set to `chapter_01_image_v2.png` in `chapter_01.tres`), the same
pattern as `TowerDefinition.icon`, so chapter #2 needs no code change.
v1 has one chapter, so `world_map.gd` shows `CHAPTER_IDS[_current_index]`
rather than a grid — **choosing between chapters still needs a carousel plus a
way to move `_current_index`**, which is not built.

**Victory/defeat screens:** both use `ui_panel_dark_v2.png` as the stats
panel — sized 800×1099 to match the art's 0.73 aspect, with every label and
button positioned inside the panel's interior rect (rule 2/3 above) —
`icon_currency_materials.png` beside the materials-earned label
(label moved to `StatsPanel/MaterialsRow/MaterialsLabel`), and widget
buttons instanced under the original node names (`ContinueButton`/
`RetryButton` = `primary_button`, `MapButton` = `secondary_button`) so
the scripts' typed `Button` refs and signal wiring are unchanged.

### Theme (`resources/theme/ui_theme.tres`)

Registered as `gui/theme/custom` in `project.godot`, so every Control inherits
it. Holds the base font size (30, tuned for the 1080×1920 portrait target) and
the default Label colour + dark outline. **Fonts are not in yet** — this uses
the engine default face; assigning a `.ttf` from `assets/fonts/` to
`default_font` here restyles the whole game at once. Change ordinary text
sizing *here*, not with per-node `theme_override_font_sizes` — those exist only
where a control genuinely differs (titles, HUD readouts).

### Tuning the HUD by hand (no code needed)

Everything is a plain number in the Godot inspector. Open
`scenes/main/game_world.tscn` and pick a node under `HUD`.

Current layout, top to bottom, on the 1080×1920 portrait target:
`PauseButton` (96×96 at 32,32) · `WaveLabel` (centred, y 36) ·
`XPBar` (740×52 at 170,186) with `LevelLabel` **straddling its top edge** ·
`TagRowWidget` (y 268). There is no HP bar here — see `value_bar_3d`.

> **Anything overlapping the bar must be a LATER sibling than it.** 2D Controls
> have no depth — they paint in scene-tree order, so a later child draws on top.
> There is no `z_index` to reach for; reorder the nodes. The HUD's order is
> therefore `WaveLabel → XPBar → LevelLabel → TagRowWidget → PauseButton`:
> `LevelLabel` sits *after* `XPBar` precisely because it straddles it. Listed
> before, the bar painted straight over the text.
> (The 3D bar solves the same problem differently — `Sprite3D`/`Label3D` do have
> depth, so `value_bar_3d` orders its four layers with `render_priority`
> 0→3 instead, and the number is 3 so it lands on top.)

| What you want to change | Where | How |
|---|---|---|
| Bar **width / height** | `HUD/XPBar` → **Bar Size** | Type pixels, e.g. `740, 52`. The capsule is redrawn at that exact size, so ends stay perfectly round at any proportions. |
| **Fill** colours | `HUD/XPBar` → **Color Top** / **Color Bottom** | Vertical gradient of the filled part. |
| **Empty track** colours | same node → **Track Color Top** / **Bottom** | The dark bar you see to the right of the fill. |
| The **outline** | same node → **Rim Color** / **Rim Width** | Width in pixels, `0` = no rim. Set Rim Color's alpha to 0 to hide it without losing the width. |
| **How round the corners are** | same node → **Corner Radius** | In pixels. `0` = square, `10` = current, `26` (half the height) = full capsule. |
| Bar **position** | same node → Layout → Transform → **Position** | The bar's top-left corner on screen. Nothing hidden — rect = what you see. |
| **Horizontal centring** | Position **X** | Centred X = (1080 − width) ÷ 2. For 740 wide that's **170**. |
| **Transparency** | **Modulate** → alpha | 1.0 = current (the reference bar is opaque). |
| **Text size** | `WaveLabel` / `LevelLabel` → Theme Overrides → Font Sizes | 40 and 64 currently. |
| **Where the text sits** | `WaveLabel` / `LevelLabel` → Offset **Top / Bottom** | Both span the full 1080 width with `horizontal_alignment = Center`, so only the Y offsets matter — the text self-centres horizontally at any width. |
| **Lv text straddling the bar** | `LevelLabel` → Offset Top **and** Bottom set to the *same* number, `grow_vertical = Both` | The text then centres on that Y line and grows evenly either side, so its top half hangs above the bar and its bottom half covers the bar's upper part — the reference look. Set both to the **bar's top edge** (`186` for a bar at y 186). Move the bar and this number has to move with it. |
| **Pause button** look | `HUD/PauseButton` → Button Size, Panel Color, Corner Radius, Border…, Glyph… | Whole button is drawn from these; no art file to swap. Keep it at or above 80×80 for touch. |
| **Floating HP bar** | `value_bar_3d.tscn` → Bar Size, Pixel Size, Height Offset, colours | Tune it in the WIDGET scene, not per tower — all five star levels instance the same scene. `Editor Preview Fill` lets you judge a part-full bar without running the game. |
| **Floating bar's on-screen size** | `value_bar_3d.tscn` → **Pixel Size** | World size is `bar_size × pixel_size`. `bar_size` is texture resolution, not screen size — changing it alone rescales the bar. |
| **Floating bar's outline** | `value_bar_3d.tscn` → **Rim Width** | The outline is geometrically identical on all four sides (`rim_width × pixel_size` world units each way). What decides how it *looks* is where that width lands on the screen pixel grid. The bar is ~10px tall in the editor preview, so `rim_width` maps to roughly `rim_width × 0.146` screen px. **Aim for the middle of a pixel bucket, not the edge of one:** `7` → 1.02px → a clean 1px line all round (current, matches the reference art). `10` → 1.47px → sits exactly on the 1/2 boundary and comes out **1px vertically, 2px horizontally** — visibly lopsided. `14` → 2.04px → even, but chunky. If you change it, verify by rendering a frame and counting pixels; the texture is symmetric at every value, so inspecting it proves nothing. |
| **HP number straddling its bar** | `value_bar_3d.tscn` → **Value Raise** | In bar heights: `0` centres the number on the bar, **`0.5` centres it on the top edge** (current, matches the reference), `1.0` clears the bar. Expressed in bar heights so it survives changes to `bar_size` / `pixel_size`. |

**Never set `scale` on these bars.** Scaling a bar non-uniformly is what
flattened the round caps into stretched ovals; `value_bar.gd` keeps scale at
1 and redraws the capsule instead. Change `bar_size`, not scale.

**Do not add generated properties back into the .tscn.** `value_bar.gd`,
`pause_button.gd` and `value_bar_3d.gd` are `@tool` scripts that build their
own textures and styleboxes. Left alone, the editor serialises those into
whatever scene instances the widget, and the stale baked copy then silently
wins over the widget's own settings — that is how `game_world.tscn` reached
**1.45 MB** of `PackedByteArray`. Two defences are in place and must stay:
`_validate_property()` strips `PROPERTY_USAGE_STORAGE` from the generated
properties, and any node the script draws into is added as an **internal
child** (`Node.INTERNAL_MODE_BACK`), which Godot never serialises. The scene
is 3.3 KB now and stays byte-identical across editor reopens.

> ⚠️ **Close `game_world.tscn` in the editor before asking for changes to it.**
> Godot writes its whole in-memory copy on save, so an open scene will silently
> overwrite edits made to the file — that produced a HUD with new bar sizes at
> stale positions, overlapping and off-centre.

### Who is allowed to pause

`get_tree().paused` has **four** writers and they must not fight:

| Source | Where | When |
|---|---|---|
| Draft | `game_world.gd:_on_phase_changed` | phase → DRAFT pauses, → WAVE resumes |
| Victory | `game_world.gd:_on_boss_died` | after `end_run(true)` |
| Defeat | `game_world.gd:_on_tower_died` | after `end_run(false)` |
| Player | `hud.gd:_on_pause_pressed` | **only while phase == WAVE** |

The pause button is hidden outside the WAVE phase (`hud.gd:_on_phase_changed`)
and re-checks the phase before toggling, so it can never resume a draft or
un-pause a defeat screen. `pause_button.tscn` sets `process_mode = 3`
(ALWAYS) — a pause button that stops processing while paused could pause the
game and never let you out.

`game_world.gd:_unhandled_input` restarts the run on `ui_accept` **only once
`run_is_over()`**. It used to test `get_tree().paused` instead, which meant
every pause source restarted the run: since the draft pauses the tree, the
DRAFT auto-pick branch below it was unreachable and pressing Space during a
draft wiped the run instead of picking a card.

### `class_name` is not safe to depend on — `preload()` instead

A global `class_name` resolves only through `.godot/global_script_class_cache.cfg`,
and **only the editor rebuilds that file**. Consequences that have already bitten:

- adding `class_name` to a script that *already existed* does not reliably refresh
  the cache, so the new name stays unresolvable — `CurrencyPill` did exactly this
  and broke `world_map.gd`, `tower_garage.gd` and `spell_codex.gd` with
  `Could not find type "CurrencyPill"`
- headless runs and fresh clones have no cache at all until someone opens the editor

So the UI widgets here are consumed by **`const X := preload("res://…gd")`**, which
resolves at load time with no cache involved (`NavBarScript` in the three meta
screens, `BarTexture` in `value_bar.gd` / `value_bar_3d.gd`). Node references are
typed to their **base** class (`Control`, `HBoxContainer`, `Button`) — the widget
methods resolve dynamically at runtime, exactly as they did before.

Verify by deleting `.godot/global_script_class_cache.cfg` and running the scene: it
must still load. Note the *older* resource classes (`TowerDefinition`,
`CombatUtils`, `SaveData`, …) still use `class_name` and do fail that test — that is
pre-existing and only survives because the editor is always opened first.

### UI art sizing rules (learned the hard way — read before placing art)

The generated UI PNGs are very large and have thick decorative borders, so
they break naive layouts. Three rules:

1. **Never assign a raw icon to `Button.icon`.** The icons are ~1254×1254, and
   a Button's minimum size includes its icon, so one icon inflated a row to
   1641×1662, forced a horizontal scrollbar, and pushed text off the panel.
   Always pair it with `expand_icon = true` **and**
   `theme_override_constants/icon_max_width` (28–30). TextureRects are safe —
   they use `expand_mode = 1` (ignore size) + `custom_minimum_size`.
2. **Match the container to the art's aspect ratio, or don't use the art.**
   `ui_panel_dark_v2` is 1070×1470 (0.73), `ui_button_primary` 1693×929
   (1.82), `ui_button_secondary_v3` 2070×760 (2.72). Stretching a 0.73 panel
   into a 3:1 row strip looks mangled. The victory/defeat panels are sized to
   0.73 exactly, and every button instance keeps its source aspect; the wide
   meta rows use a StyleBoxFlat instead.
3. **These borders cannot be 9-sliced.** The panel frame is ~15% of width /
   12% of height — at source scale a 9-patch corner would be 159 px, far
   bigger than a row. So a textured StyleBox stretches the whole image, which
   means **content margins must clear the border**: on-panel content has to
   sit inside the interior rect (panel rect inset by 14.9% × 12.2%).

`ScrollContainer`s on the meta screens set `horizontal_scroll_mode = 0` so a
too-wide child can never produce a sideways scrollbar again.

**Tower Garage:** `bg_garage.png` BG, `top_bar` fed from `MetaManager`,
`nav_bar` (Garage disabled), then top to bottom a `tower_preview_3d`, the tower's
name, a `star_row`, a stats strip (LEVEL / ATK / HP), a `GridContainer`
of `tower_slot`s, and a Select / Upgrade action bar. **The `meta_row` list this
screen used to be is gone** — `meta_row` is now the codex's alone.

The name **deliberately overlaps the preview** and the stars sit below it, so the
name reads across the tower's base. Sibling order is draw order, so `NameLabel`
has to stay declared after `Preview3D` or the tower covers the text. `bg_garage.png`
is a plain lit backdrop with **no pedestal**, so nothing in the art can intersect
the model.

The stats strip is three **`stat_pill`s on a slightly darker wash** — not a dark
card, which read as a second UI surface floating on the background. Each pill is a
`StyleBoxFlat` drawn in code (no art) with its icon standing proud of the left end,
the same shape as the top bar's currency pills: both extend
**`scenes/ui/widget/pill_base.gd`**, which owns the pill rect, the icon slot and
every geometry knob. Icons are `garage/icon_stat_level.png` (an LV shield),
`icon_stat_atk.png` and `icon_stat_hp.png`; each pill shows the next-star gain as a
green `(+N)` beside the value, so an upgrade is visible before it is paid for.

`tower_slot` draws **no plate and no unselected border** — the tower art fills the
cell (`icon_fill` 0.92) as in the reference, and the gold `border_color_selected`
is the only thing marking the pick.

**Both the stats strip and the action bar run 0..1080 with square corners.** They
are full-bleed bands, not floating cards; insetting or rounding them makes the
screen read as panels stacked on a wallpaper. The action bar is a light band in the
nav bar's palette holding a **flat "Selected" state label** (not a second chunky
button competing with Upgrade) and a green Upgrade button — both plain
`StyleBoxFlat`s defined in `tower_garage.tscn`, no art.

**`tower_preview_3d` uses ONE fixed camera for every tower and every star level** —
`camera_distance` and `look_height`, nothing measured at runtime. All five
`ancient_tower` glb files are exported into the same normalised box (y −0.957 to
+0.953, identical to four decimals), so per-model framing had nothing to work with;
the auto-framing that used to live here only managed to put the five towers at five
different heights. See "Moving the tower" in `ui_tuning.md`.

The grid is built from **`TowerRegistry.all_towers`**, ordered by
`TowerDefinition.sort_order`. Adding a tower is a new `.tres` in
`res://resources/towers/` — no code change and no scene change. Five
`tower_locked_0N.tres` placeholders currently hold grid positions 2–6 with
`unlocked = false`.

**Two different "selected" ideas live here and must not be conflated:**
`tower_garage.gd`'s `_viewing_id` is which cell is highlighted and shown in 3D;
`MetaManager.selected_tower_id` is which tower actually goes into a run. Tapping a
cell moves only the first, and the Select button commits it to the second.

`TowerDefinition` gained `unlocked` (content exists yet?) and `sort_order` (grid
position). `unlocked` is **not** player progress — that is
`MetaManager.owned_towers`. A cell greys out when either is missing, which
`TowerRegistry.is_playable()` answers in one call.

⚠️ **The preview shows the raw `.glb`, never `star_level_scenes`.**
`tower.gd._ready()` calls `GameState.start_run()`, so instancing a gameplay tower
scene on the garage screen would begin a run.
`TowerRegistry.get_preview_model()` resolves the model by ID convention
(`assets/models/towers/<id>/<id>_lvl<star>.glb`) precisely so nobody reaches for
`star_level_scenes` instead.

Per-star **decoration** follows the same rule. The lvl5 waterfalls were seven
inline `MeshInstance3D`s in `ancient_tower_lvl5.tscn`, so the preview could not
show them without instancing a gameplay scene. They now live in
`ancient_tower_lvl5_fx.tscn`, instanced by both the gameplay tower and
`tower_preview_3d` (which finds it at
`scenes/game_object/tower/<id>/<id>_lvl<star>/<id>_lvl<star>_fx.tscn`, or shows
nothing if absent). One copy of the effect, and adding an effect to a future star
level needs no code.

`tower_slot` desaturates locked icons with `greyscale.gdshader` rather than a grey
copy of the art — `modulate` can only tint or darken, never remove hue. The
padlock reuses `ui_locked_overlay.png`.

`tower_preview_3d`'s `Environment` sits on a `WorldEnvironment` node in the scene, not
assigned to `world_3d` in code: with `own_world_3d` the viewport's `World3D` does
not exist yet while the export setters run, and touching it errors.

**Spell Codex:** same shape as the garage and the **same `meta_row` scene** —
`bg_garage.png` reused as BG (no codex art exists yet; `bg_menu_generic.png`
is still unmade), `top_bar`, `nav_bar` with Codex disabled. Each of the 20
rows shows a rank label instead of stars, one plain stats line instead of
chips, no "In Use" toggle, and its icon comes free from
`SpellRegistry.get_card_icon(spell)` — zero per-spell configuration.

**Draft cards:** `SpellRegistry.get_card_icon(card_data)` resolves icons —
explicit `.tres` `icon` wins, else the assets.md ID convention
(`assets/ui/spells/<school>/icon_spell_<spell_id>.png`,
`assets/ui/upgrades/icon_<upgrade_id>.png`). All 23 cards resolve (two
`.tres` overrides: `upgrade_damage` → `garage/icon_stat_atk.png`,
`upgrade_fire_rate` → `icon_upgrade_fire_rate_v2.png`). `draft_card.gd`
applies the rarity card bg as the panel stylebox (common = base,
rare = `_v2`, epic = `_v3` of `ui_card_bg_*`) and hides the old
RarityBorder strip.
UI art folder tree: see `ui_assets.md`.

One addition:

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
