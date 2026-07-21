# Restructure — Scene-per-object folders (match the reference project)

> **Do this BEFORE starting Epic 04.** Goal: reorganize the project (built
> through Epic 03) to match `PROJECT_STRUCTURE_TEMPLATE.md` — including
> **one scene + folder per enemy type** (`chap1_enemy_01/`, `chap1_enemy_02/`,
> `chap1_boss_01/`), exactly like the reference's `basic_enemy/` / `ghost_enemy/`.
>
> **"Works like before" here means: the MECHANICS don't break and don't change**
> — same damage math, same wave scaling, same pooling, same targeting, same
> boss behavior. The *structure* changes on purpose. This is a rearchitecture of
> the enemy layer (generic `Enemy.tscn` → one scene per type), done so behavior
> comes out identical.
>
> Read-and-refactor task against the **real Godot project**. Work on a branch.
> Verify the game plays identically after every phase.

---

## 1. The one sub-decision (already made — veto if you disagree)

Going scene-per-enemy-type raises one question: where do each enemy's **stats**
(hp, speed, damage, xp…) live?

- **CHOSEN — co-located `.tres` in each enemy folder.** Each enemy folder holds
  its scene + script + its `EnemyDefinition` `.tres`; the scene reads stats from
  that `.tres` at spawn, exactly as today. This keeps mechanics **byte-identical**
  (nothing about damage/scaling changes) and keeps your `Constants` balance-scaling
  and the `components.md` cheat sheet working. It also matches the reference's
  spirit — the reference bundles each object's asset (its `.png`) in the folder;
  here the per-enemy asset is its `.tres`.
- Alternative (NOT chosen): pure-reference style — stats as exported overrides on
  the scene, delete `EnemyDefinition`/`.tres` entirely. This deletes your
  balance-tuning subsystem for no mechanical benefit. Only do this if you
  explicitly want it.

Everything below uses the co-located `.tres` choice.

---

## 2. Target `res://` tree

```
res://
├── autoloads/                         # TRUE globals only (see §5)
│   ├── constants.gd                   # Constants   (singleton names unchanged)
│   ├── event_bus.gd                   # EventBus    (the reference's one signal bus)
│   ├── game_state.gd                  # GameState
│   ├── meta_manager.gd                # MetaManager
│   ├── spell_registry.gd              # SpellRegistry
│   ├── object_pool.gd                 # ObjectPool
│   └── audio_manager.gd               # AudioManager
│
├── scenes/
│   ├── main/
│   │   └── game_world.tscn / .gd      # run root; hosts the manager Nodes
│   │
│   ├── manager/                       # run-scoped systems (Node children of GameWorld)
│   │   ├── wave_manager.tscn / .gd
│   │   └── draft_manager.tscn / .gd
│   │
│   ├── component/                     # FLAT reusable component SCENES (§4)
│   │   ├── health_component.tscn / .gd
│   │   ├── hurtbox_component.tscn / .gd
│   │   ├── hitbox_component.tscn / .gd
│   │   ├── move_to_target_component.tscn / .gd
│   │   ├── targeting_component.tscn / .gd
│   │   ├── cooldown_component.tscn / .gd
│   │   ├── hit_flash_component.tscn / .gd
│   │   ├── death_fx_component.tscn / .gd
│   │   └── boss_heavy_attack_component.tscn / .gd   # NEW in Epic 04
│   │
│   ├── game_object/                   # ONE FOLDER PER SCENE
│   │   ├── tower/
│   │   │   └── tower.tscn / .gd
│   │   ├── standard_bolt/
│   │   │   └── standard_bolt.tscn / .gd
│   │   ├── arc_projectile/            # (added when a spell needs unique arc behavior)
│   │   │   └── arc_projectile.tscn / .gd
│   │   ├── camera_rig/
│   │   │   └── camera_rig.tscn / .gd
│   │   ├── enemy/                      # SHARED enemy script, chapter-agnostic
│   │   │   └── enemy.gd                # class_name Enemy — reused by every enemy/boss scene in every chapter, not copied
│   │   └── chap1/                      # enemies grouped by chapter (chap2/ later)
│   │       ├── chap1_enemy_01/
│   │       │   ├── chap1_enemy_01.tscn # script = res://scenes/game_object/enemy/enemy.gd
│   │       │   └── chap1_enemy_01.tres # its EnemyDefinition, co-located
│   │       ├── chap1_enemy_02/         # created in Epic 04 (reuses enemy.gd)
│   │       │   ├── chap1_enemy_02.tscn / .tres
│   │       └── chap1_boss_01/          # created in Epic 04
│   │           └── chap1_boss_01.tscn / .tres
│   │
│   └── ui/                            # flat, snake_case
│       ├── world_map.tscn / .gd
│       ├── tower_garage.tscn / .gd
│       ├── spell_codex.tscn / .gd
│       ├── victory_screen.tscn / .gd
│       ├── defeat_screen.tscn / .gd
│       ├── hud.tscn / .gd
│       ├── draft_ui.tscn / .gd
│       ├── draft_card.tscn / .gd
│       ├── synergy_banner.tscn / .gd
│       ├── tag_row_widget.tscn / .gd
│       └── damage_number_3d.tscn / .gd
│
├── scripts/                           # flat global helpers (class_name'd)
│   ├── combat_utils.gd
│   └── weighted_table.gd
│
├── resources/                         # shared/base data (definitions live here)
│   ├── enemies/enemy_definition.gd    # base class ONLY; the .tres instances move into each enemy folder
│   ├── spells/  (spell_definition.gd + spell_*.tres)
│   ├── upgrades/(stat_upgrade_definition.gd + upgrade_*.tres)
│   ├── towers/  (tower_definition.gd + tower_ancient_tower.tres)
│   └── chapters/(chapter_definition.gd + chapter_01.tres)
│
└── assets/
	├── models/                        # .glb stay here (NOT bundled per game_object
	│                                   # folder — see §3), organized instead as
	│                                   # towers/<tower_id>/ and chap<N>/ (assets.md §2)
	├── materials/  audio/  ui/  fonts/
```

> **Enemies now = folders under `game_object/`.** The generic `Enemy.tscn` is
> gone; each type is its own scene. Spawning picks the right scene instead of
> re-applying a `.tres` to one shared scene (§4).

---

## 3. What stays put (deliberate deviations from the reference)

- **Models stay in `assets/models/`**, referenced by `model_path` in each
  enemy's `.tres` — NOT bundled into the enemy/tower scene folder. This is a
  3D project; the swap-a-`.glb`-without-touching-code policy (`project.md`/
  `assets.md`) and your manual-mesh-drop workflow both depend on models
  staying centralized (as opposed to co-located next to each scene, which is
  where `.tres` data files live). "Centralized" still means organized:
  `assets/models/towers/<tower_id>/` per tower line, `assets/models/chap<N>/`
  per chapter — mirrors `game_object/`'s folder-per-category grouping without
  going all the way to folder-per-scene. (The reference bundled `.png`s
  directly in each scene folder only because it was 2D sprites.)
- **Spells & tower are NOT folder-per-type yet.** There's one tower
  (`tower/` folder) and the 3 v1 spells share the generic `projectile`/
  `arc_projectile`/`aoe_zone` scenes + `.tres` data — same as the reference kept
  simple projectiles generic. When a spell needs *unique behavior* (not just
  different numbers), it graduates to its own folder like the reference's
  `sword_ability/` — that's the extend-later path, not this restructure.
- **Base definition *classes* stay in `resources/`** (`enemy_definition.gd` etc.).
  Only the per-enemy `.tres` *instances* move into their enemy folders.

---

## 4. The actual rearchitecture — generic enemy → per-type scenes

This is the heart of the change. Do it carefully; it's where behavior could
drift if wired wrong.

- [ ] **One scene per enemy type.** For each existing enemy (`chap1_enemy_01`;
	  `chap1_enemy_02`/`chap1_boss_01` are Epic 04), create
	  `game_object/<id>/<id>.tscn`. The fastest correct way: take the current
	  generic `Enemy.tscn` node tree (root `CharacterBody3D` in group
	  `"enemies"` + its instanced component scenes) and save one copy per type.
	  Each copy is structurally identical; they differ only in tuning + which
	  `.tres`/model they use.
- [ ] **Script.** Behavior is the same for all regular enemies, so they can
	  **share one `enemy.gd`** (each scene's root just attaches the same script),
	  OR get a thin per-folder script like the reference. Sharing avoids
	  duplicated logic; pick one and be consistent. The boss's scene gets the
	  extra `boss_heavy_attack_component` (as a component scene) attached
	  directly — no more runtime `if is_boss` add; the boss simply has it.
- [ ] **Stats via co-located `.tres`.** Move each `chap1_enemy_*.tres` into its
	  folder. The enemy scene exposes `@export var definition: EnemyDefinition`
	  set (in the `.tscn`) to its co-located `.tres`; `enemy.gd` applies it on
	  spawn exactly as today. Damage/scaling/xp math is untouched → mechanics
	  identical.
- [ ] **Spawning picks scenes, not a shared scene + data.** Update the spawn
	  path so the wave system instances the *correct enemy scene*:
  - `ChapterDefinition.enemy_pool` becomes an `Array[PackedScene]` of enemy
	scenes (or: keep it `Array[EnemyDefinition]` and add a `scene: PackedScene`
	field to `EnemyDefinition` pointing at that enemy's own scene — either works;
	the scene-array is simpler and closer to the reference).
  - `WaveManager` (now a manager Node, §5) picks a scene from the weighted table
	(`enemy_table.pick_item()`) and `scene.instantiate()`s it — a fresh instance
	that is `queue_free()`d on death (see below) — instead of re-applying a
	`.tres` to one shared scene. Keep the current **wave-batch cadence** (spawn
	N per wave → clear → draft → next wave); only *which* scene each spawn
	instantiates changes. Take the reference's `WeightedTable` + `instantiate()`
	(no pooling) — but NOT its continuous per-timer stream; this game stays
	wave-based.
  - Register enemy scenes into the wave's weighted pool with
	`weighted_table.gd`, the same helper the reference used — matching its
	"manual `add_item(scene, weight)`" pattern, gated by wave (difficulty
	gating is later epic work, not this restructure).
- [ ] **Enemies are NOT pooled — they `queue_free()` on death**, using the
	  **existing `DeathFXComponent`** (relocated to `scenes/component/` in
	  Phase 4): on `HealthComponent.died` it runs its shrink tween, then
	  `get_parent().queue_free()` — kept exactly as today. Each wave spawns fresh
	  instances via `scene.instantiate()`. Do NOT convert enemies to
	  `ObjectPool`/`reset()` reuse. `ObjectPool` stays for projectiles and other
	  reusable objects (keyed by `PackedScene.resource_path`); it just isn't used
	  for enemies.
- [ ] **Verify (critical):** side-by-side, each enemy type spawns, moves, takes
	  damage, dies (and `queue_free()`s), and awards XP exactly as before. Wave
	  scaling still multiplies stats the same way. Enemies `queue_free()` on
	  death — they are not pooled.

---

## 5. Managers, components, autoloads (unchanged reasoning from the plan)

### Components → component **scenes** (`scenes/component/`)
Each current `scripts/components/*.gd` becomes a flat component **scene**
(`.tscn` = correct root node type + the **unchanged** script + any shape/child
it needs), instanced into the enemy/tower/projectile scenes and tuned via
**exported-property overrides** — the reference's composition pattern. Preserve
every existing inter-component `NodePath` wiring (e.g. `HitFlashComponent.mesh`,
hurtbox→sibling `HealthComponent`).

### Two managers leave autoload → `scenes/manager/`
`WaveManager` and `DraftManager` are **run-scoped** (only live during a run under
`GameWorld`). They become Node children of `game_world.tscn`, wired by
`@export NodePath`. This is the "manager that controls enemy spawning" setup you
wanted. Remove them from `project.godot` autoloads and convert their global
`WaveManager.x` / `DraftManager.x` call sites to node references (or `EventBus`
signals).

### The other seven STAY autoloads — and why
`Constants` (pure global data), `EventBus` (the one signal bus), `MetaManager`
(save data must outlive the run scene), `AudioManager` (plays across menus + run),
`ObjectPool` / `SpellRegistry` / `GameState` (global services / run-state read
from many call sites). Converting these gains nothing and risks regressions.

### File naming
All files → `snake_case`. **Node names, `class_name`s, and autoload singleton
names stay `PascalCase`** — so renaming touches file paths only, not code
references. Autoload-file renames touch only `project.godot`'s autoload paths.

---

## 6. Migration phases (each independently verifiable)

> After every phase: open in Godot, clear all errors, play a full loop
> (start → clear wave → draft → continue → win/lose), confirm identical. Commit
> per phase.

- [ ] **Phase 0 — Prep.** Branch. Confirm the game builds/plays on `main` as the
	  known-good baseline; note current behavior (waves reached, draft, boss,
	  win/lose) as the comparison target. Move `.uid`/`.import` sidecars with
	  their files or let Godot regenerate them.
- [ ] **Phase 1 — Skeleton.** Create `scenes/game_object/`, `scenes/component/`,
	  `scenes/manager/`; flatten `scripts/utils/` into `scripts/`.
- [ ] **Phase 2 — Move the singular scenes** (tower, projectile, arc_projectile,
	  aoe_zone, camera_rig) into their `game_object/<name>/` folders (snake_case,
	  node names unchanged). Fix all `preload`/`load`/`ExtResource` paths. Verify.
- [ ] **Phase 3 — Screens & UI → `scenes/ui/`** (snake_case); helpers → flat
	  `scripts/`. Fix `change_scene_to_file` and instancing paths. Verify.
- [ ] **Phase 4 — Componentize** (scripts → component scenes). Highest risk;
	  test each component's behavior explicitly. Separable — if it stalls, the
	  game still works after Phases 1–3. Verify.
- [ ] **Phase 5 — Enemy rearchitecture** (§4): generic enemy → per-type scenes,
	  co-located `.tres`, scene-picking spawn path, boss component attached to
	  the boss scene. This is the big one. Verify each enemy type thoroughly.
- [ ] **Phase 6 — Move `WaveManager`/`DraftManager`** into `scenes/manager/` as
	  `GameWorld` children; drop from autoloads; convert their call sites. Verify
	  spawning, draft triggers, boss wave, win/lose.
- [ ] **Phase 7 — (optional) snake_case the autoload files** (project.godot paths
	  only; singleton names unchanged → no code edits).
- [ ] **Phase 8 — Sync the docs** (§7 below), against the real finished tree.
- [ ] **Phase 9 — Full regression** vs. the Phase 0 baseline: same waves, draft,
	  boss, screens, numbers. Any difference = a restructure bug; fix it.

---

## 7. Doc sync (Phase 8 detail — do LAST, against the real tree)

First pass, mechanical: grep `project.md`, `components.md`, `mechanics.md`,
`assets.md`, `epic_01`–`epic_08` and replace old path tokens —
`scenes/tower/` · `scenes/enemies/` · `scenes/spells/` · `scenes/camera/` →
`scenes/game_object/...`; `scripts/components/` → `scenes/component/`;
`scripts/utils/` → `scripts/`; `res://autoloads/WaveManager.gd` /
`DraftManager.gd` → `scenes/manager/...`; PascalCase scene filenames → snake_case.

**`project.md`**
- [ ] Autoloads list: remove WaveManager & DraftManager; note they're run-scoped
	  manager Nodes under `game_world.tscn`; renumber the rest.
- [ ] Folder Structure block → new tree (per-enemy folders under `game_object/`,
	  `component/`, `manager/`, flat `scripts/`). Keep the models-stay note.
- [ ] Update any "generic `Enemy.tscn`, one scene many `.tres`" wording → the
	  new "one scene+folder per enemy type, co-located `.tres`" description.

**`components.md`** (most edits here)
- [ ] Section 1 tree → new tree.
- [ ] Section 3: move WaveManager/DraftManager into a new "Managers
	  (`scenes/manager/`)" subsection; drop their autoload-order lines; renumber.
- [ ] Section 4 header → `Components (scenes/component/)`; note components are now
	  instanced component scenes.
- [ ] Section 6 "Key Scenes": rewrite the `Enemy.tscn` entry from "single generic
	  scene" to "one scene per enemy type under `game_object/<id>/`, each with a
	  co-located `.tres`"; update the "Extend later by" note (adding an enemy =
	  copy a folder + its `.tres`, not just drop a `.tres`).
- [ ] Section 0 cheat-sheet: the "one enemy's stats" row still points at that
	  enemy's `.tres` — now located in its `game_object/<id>/` folder. Fix the path.

**`epic_04`–`epic_08`**
- [x] `epic_04`: rewrote Task 04-01/04-02 to the folder pattern — `chap1_enemy_02`
	  and `chap1_boss_01` each get a `game_object/chap1/<id>/` folder (scene +
	  shared `enemy.gd` + co-located `.tres`), created by copying the
	  `chap1_enemy_01` folder and retuning; the boss scene includes
	  `boss_heavy_attack_component` directly. Task 04-03 now adds a `scene:
	  PackedScene` field to `EnemyDefinition` (option B from §4, since
	  `ChapterDefinition.enemy_pool`/`boss` were already built as
	  `EnemyDefinition`, not `PackedScene`) so `WaveManager` can resolve a
	  definition to its scene.
- [x] `epic_06`/`epic_05`/`epic_07`: fixed stale `res://scenes/main/` refs for
	  `VictoryScreen`/`DefeatScreen`/`WorldMap`/`TowerGarage`/`SpellCodex` →
	  `res://scenes/ui/victory_screen.tscn` etc. (snake_case, moved out of
	  `scenes/main/`, which now only holds `game_world.tscn`). `model_path`/
	  `assets/models/` refs unchanged. The model-swap task still updates
	  `model_path` inside each enemy folder's `.tres`.
- [x] Sanity: no doc still contains `scenes/enemies/`, `scenes/tower/`,
	  `scenes/spells/`, `scenes/camera/`, `scripts/components/`, or
	  `res://scenes/main/` refs to anything other than `game_world`.

---

## 8. After this — adding Epic 04's enemies is "copy a folder"

This is the payoff you were after from the start. To add `chap1_enemy_02`:

1. **Copy** `scenes/game_object/chap1_enemy_01/` → `chap1_enemy_02/`; rename the
   three files.
2. **Retune** its co-located `chap1_enemy_02.tres` (hp 60, speed 2.6, etc. per
   Epic 04) and, for now, its placeholder mesh scale/color so it's visually
   distinct. Later, drop a real `.glb` in `assets/models/` and point the `.tres`
   `model_path` at it.
3. **Register** the new scene with the wave pool in `wave_manager` (an
   `@export PackedScene` + `weighted_table.add_item(scene, weight)`), gated by
   wave if desired — the reference's exact recipe.

Boss (`chap1_boss_01`): same copy-a-folder, plus attach
`boss_heavy_attack_component.tscn` to its scene and scale the mesh up. No other
file needs to know it exists — runtime lookups use the `"enemies"` group.

---

## 9. Golden rules (new structure, carry forward from Epic 04 on)

- **One folder per scene** under `game_object/<name>/` — and enemies ARE
  scene-per-type, **grouped by chapter** (`game_object/chap1/chap1_enemy_01/`;
  `chap2/…` later). Each enemy type is its own folder, file-set named after the
  folder, with its `.tres` co-located — but the enemy **script is shared**
  (`enemy.gd`, `class_name Enemy`): reuse it, don't copy it (a duplicate
  `class_name` clashes). Because it's chapter-agnostic (every chapter's
  enemies and bosses reuse it), it lives in its own neutral
  `game_object/enemy/` folder — same single-generic-script pattern as
  `tower/tower.gd` or `projectile/projectile.gd` — NOT inside any specific
  chapter's or enemy type's folder.
- **Adding an enemy = copy a folder + retune its `.tres` + register the scene**
  with `wave_manager`'s `WeightedTable`, reusing the shared `enemy.gd`. No new
  gameplay code for a plain stat-variant enemy. **Enemies `queue_free()` on
  death — they are not pooled.**
- **Behavior = component scenes instanced + exported overrides**, never a new
  monolith. New behavior = a new component scene attached only to what needs it
  (the boss's heavy-attack is the model for this).
- **Run-scoped systems = manager Nodes** under `game_world.tscn` (`@export
  NodePath`). **Cross-scene globals = autoloads.** Don't autoload a run-scoped
  manager.
- **Runtime discovery via groups** (`"tower"`, `"enemies"`), not stored paths.
- **Cross-system events via `EventBus`**, not manager-to-manager calls.
- **Models stay in `assets/models/`**, referenced by `model_path` in each enemy's
  `.tres` — never bundled into the scene folder — but organized by
  `towers/<tower_id>/` and `chap<N>/` (assets.md §2), not dumped flat.
- **IDs are authored strings in `.tres`** (`enemy_id`, `tower_id`, …); keep
  the id string, the `.tres` filename, and the folder name in agreement
  (e.g. `tower_id="ancient_tower"` ↔ `tower_ancient_tower.tres` ↔
  `assets/models/towers/ancient_tower/`).
