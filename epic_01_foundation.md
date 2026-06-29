# Epic 01 — Foundation

> Goal: A running Godot 4 project in **real 3D**, with a fixed-angle camera, a
> static tower placeholder (a 3D primitive, not a sprite), one enemy that
> walks toward it across a flat ground plane, real-time lighting, and a wave
> timer counting down.
> No real models yet (placeholders are primitive meshes — capsules, boxes —
> not flat colored rectangles, since we need to confirm 3D depth/shadows work
> from day one). No combat yet.
> Completed epic delivers: Claude Code can run the project and see a 3D
> capsule enemy walking across a lit, shadowed ground plane toward a 3D box
> tower, viewed through the fixed Archero-style camera.

---

## Task 01-01 — Create Godot 4 Project (3D)

**Overview**: Set up the project at the engine-settings level so every later
task builds on correct foundations — wrong renderer or wrong project settings
here cascades into pain later (this is exactly what happened with the
abandoned 2D version's lighting problems).

- [ ] Create a new Godot 4 project named `TowersLastStand3D`.
- [ ] Set display resolution: Width = 1080, Height = 1920 (portrait — this is
      the UI canvas size; the 3D viewport renders independently and is framed
      by the camera, not by this resolution directly).
- [ ] Set Stretch Mode to `canvas_items`, Stretch Aspect to `keep`.
- [ ] Set renderer to **Mobile** (Project > Rendering > Renderer). Confirm in
      `project.godot` that `rendering/renderer/rendering_method` is set to
      `mobile`.
- [ ] Set Physics > 3D > Default Gravity to `9.8` (standard).
- [ ] Create the full folder structure exactly as listed in `components.md`
      Section 1.
- [ ] Set the main scene to `res://scenes/main/GameWorld.tscn` (create it as
      an empty `Node3D` scene for now).

**Acceptance criteria**:
- [ ] Project opens in Godot with no errors.
- [ ] `project.godot` shows `rendering/renderer/rendering_method="mobile"`.
- [ ] Folder structure matches `components.md` Section 1 exactly.

---

## Task 01-02 — Constants Autoload

**File**: `res://autoloads/Constants.gd`
**Ref**: `components.md` Section 2

- [ ] Create `Constants.gd` with `class_name Constants`.
- [ ] Add every enum and const listed in `components.md` Section 2 exactly
      (including `CAMERA_PITCH_DEGREES`).
- [ ] Add `Constants` as the first Autoload in Project Settings > Autoload.

**Acceptance criteria**:
- [ ] `Constants.GamePhase.WAVE` and similar enum references resolve with no
      errors from any other script.
- [ ] `Constants.CAMERA_PITCH_DEGREES` returns `60.0`.

---

## Task 01-03 — EventBus Autoload

**File**: `res://autoloads/EventBus.gd`
**Ref**: `components.md` Section 3

- [ ] Create `EventBus.gd` as a `Node` script.
- [ ] Declare every signal listed in `components.md` Section 3's `EventBus`
      entry, grouped exactly as listed (Combat/XP/Wave/Draft/Synergy/Meta).
- [ ] Add `EventBus` as Autoload (order 2).

**Acceptance criteria**:
- [ ] Calling `EventBus.emit_signal("wave_started", 1)` from a test script
      produces no error.
- [ ] Every signal name in `components.md` Section 3 exists on `EventBus`.

---

## Task 01-04 — GameState Autoload

**File**: `res://autoloads/GameState.gd`
**Ref**: `components.md` Section 3

- [ ] Create `GameState.gd`. Declare all variables and signals listed in
      `components.md` Section 3's `GameState` entry.
- [ ] Implement `start_run(tower_def)`, `gain_xp(amount)`,
      `take_damage(amount)`, `heal(amount)`, `add_tag(tag)`,
      `apply_card(card)` (stub — full implementation in Epic 03),
      `end_run(victory)`, `reset()` — matching the behavior described in
      `mechanics.md` Sections 2, 4, 6, 7.
- [ ] `_apply_synergy_bonus(tag, level)` can be a stub that just prints for
      now (real implementation in Epic 03 once tags actually exist on cards).
- [ ] Add `GameState` as Autoload (order 3).

**Acceptance criteria**:
- [ ] Calling `GameState.start_run(null)` sets `phase` to `WAVE` and emits
      `phase_changed` without error.
- [ ] Calling `GameState.take_damage(50)` reduces `tower_hp` by 50 and emits
      `hp_changed`.
- [ ] Calling `GameState.gain_xp(1000)` (an amount guaranteed to exceed
      `run_xp_to_next`) increments `run_level` and emits `EventBus.level_up`.

---

## Task 01-05 — MetaManager Autoload (Stub)

**File**: `res://autoloads/MetaManager.gd`
**Ref**: `components.md` Section 3

- [ ] Create `MetaManager.gd`. Declare `owned_towers`, `tower_stars`,
      `spell_ranks`, `materials`, `energy`, `premium_currency`,
      `selected_tower_id`.
- [ ] Implement `save()`/`load()` as stubs (print only — full implementation
      Epic 05).
- [ ] Implement `spend_energy() -> bool` and `restore_energy(amount)` per
      `mechanics.md` Section 11.
- [ ] Defaults: `energy = 5`.
- [ ] Add as Autoload (order 4).

**Acceptance criteria**:
- [ ] `MetaManager.spend_energy()` returns `true` and decrements `energy`
      when `energy > 0`, returns `false` and does not decrement otherwise.

---

## Task 01-06 — SpellRegistry Autoload (Stub)

**File**: `res://autoloads/SpellRegistry.gd`
**Ref**: `components.md` Section 3

- [ ] Create `SpellRegistry.gd`. Declare `all_spells: Array`,
      `all_stat_upgrades: Array`.
- [ ] `_ready()` is a stub — arrays stay empty until Epic 03 creates the
      actual `.tres` resource files.
- [ ] Implement `get_all_cards() -> Array`: returns
      `all_spells + all_stat_upgrades`.
- [ ] Add as Autoload (order 5).

**Acceptance criteria**:
- [ ] `SpellRegistry.get_all_cards()` returns an empty array with no error
      (resources don't exist yet — that's expected at this stage).

---

## Task 01-07 — WaveManager Autoload (Stub)

**File**: `res://autoloads/WaveManager.gd`
**Ref**: `components.md` Section 3, `mechanics.md` Section 3

- [ ] Create `WaveManager.gd`. Declare `_active_enemies: Array`,
      `_trickle_timer: Timer`, `_enemy_container: Node3D`.
- [ ] Implement `start_wave(wave_number)`:
  - Clear `_active_enemies`.
  - Spawn 3 placeholder enemies (hardcode the placeholder enemy scene from
    Task 01-15 for now — real `EnemyDefinition`-driven spawning is Epic 02+)
    at random points on the arena's outer edge (see Task 01-16 for the spawn
    geometry helper).
  - Emit `EventBus.wave_started(wave_number)`.
- [ ] Implement `stop_wave()`, `clear_all_enemies()` (iterate and
      `queue_free()` for now — pooling comes in Epic 02).
- [ ] Implement `_get_spawn_position() -> Vector3`: returns a random point on
      the arena's outer edge (see Task 01-19 for the arena's actual
      dimensions once placed).
- [ ] Implement `_on_enemy_died(enemy, position)`: removes from
      `_active_enemies`; if empty, emits `EventBus.wave_cleared(...)`.
- [ ] Connect to `EventBus.enemy_died` in `_ready()`.
- [ ] Add as Autoload (order 6).

**Acceptance criteria**:
- [ ] `WaveManager.start_wave(1)` spawns 3 enemy nodes inside
      `_enemy_container` at distinct positions on the arena edge.
- [ ] `EventBus.wave_started` fires exactly once per call.

---

## Task 01-08 — DraftManager Autoload (Stub)

**File**: `res://autoloads/DraftManager.gd`

- [ ] Create `DraftManager.gd`. Stub `open_draft()` (emits
      `EventBus.draft_opened`) and `select_card(card)` (emits
      `EventBus.draft_closed`). Full implementation in Epic 03.
- [ ] Add as Autoload (order 7).

**Acceptance criteria**:
- [ ] Calling `DraftManager.open_draft()` emits `draft_opened` with no error.

---

## Task 01-09 — ObjectPool Autoload (Stub)

**File**: `res://autoloads/ObjectPool.gd`
**Ref**: `mechanics.md` Section 9

- [ ] Create `ObjectPool.gd`. Declare `_pools: Dictionary`.
- [ ] Implement `get(scene: PackedScene) -> Node`, `release(node: Node)`,
      `preload_pool(scene: PackedScene, count: int)` per the contract in
      `mechanics.md` Section 9. For 3D nodes, `release()` disables
      `CollisionShape3D` children (not `CollisionShape2D`).
- [ ] Add as Autoload (order 8).

**Acceptance criteria**:
- [ ] `ObjectPool.preload_pool(some_scene, 5)` followed by 5 calls to
      `ObjectPool.get(some_scene)` returns 5 distinct, visible nodes with no
      new instantiation (verify via a print/counter in the test).
- [ ] Calling `ObjectPool.release(node)` on one of those hides it and disables
      its collision shape(s).

---

## Task 01-10 — AudioManager Autoload (Stub)

**File**: `res://autoloads/AudioManager.gd`

- [ ] Create `AudioManager.gd`. Declare `_sfx_pool: Array`,
      `_music_player: AudioStreamPlayer`. Create 8 pooled
      `AudioStreamPlayer` children in `_ready()`. Full implementation Epic 07.
- [ ] Add as Autoload (order 9).

**Acceptance criteria**:
- [ ] Project runs with `AudioManager` present and no errors; 8 player
      children exist under it (check in remote scene tree while running).

---

## Task 01-11 — CombatUtils Script

**File**: `res://scripts/utils/combat_utils.gd`
**Ref**: `mechanics.md` Section 5, `project.md` Damage Type vs Armor Table

- [ ] Create `CombatUtils.gd` as a static-style class (`class_name
      CombatUtils`), no autoload needed — pure functions.
- [ ] Implement `static func calculate_damage(base_amount: float,
      damage_type: int, armor_type: int) -> float`: looks up the multiplier
      from the table in `project.md`, returns `base_amount * multiplier`.
      **No per-enemy or per-spell branches** — table lookup only, per the
      rule in `mechanics.md` Section 5.
- [ ] Implement `static func calculate_wave_hp_scale(wave: int) -> float`:
      `pow(Constants.ENEMY_HP_SCALE, wave - 1)`.
- [ ] Implement `static func calculate_wave_dmg_scale(wave: int) -> float`:
      `pow(Constants.ENEMY_DMG_SCALE, wave - 1)`.

**Acceptance criteria**:
- [ ] `CombatUtils.calculate_damage(100, Constants.DamageType.NORMAL,
      Constants.ArmorType.HEAVY)` returns `70.0` (100 × 0.7 per the table).
- [ ] `CombatUtils.calculate_wave_hp_scale(1)` returns `1.0`.

---

## Task 01-12 — Core Component Scripts (Skeletons)

**Files**: `res://scripts/components/*.gd`
**Ref**: `components.md` Section 4, `mechanics.md` Section 8

Create every component listed in `components.md` Section 4 as its own file.
At this stage they only need enough implementation to support Task 01-15/17
below — full combat wiring is Epic 02.

- [ ] `health_component.gd`: full implementation now (it's simple and other
      components depend on it) — `max_health`, `current_health`, `damage()`,
      `heal()`, `reset()`, signals `health_changed`, `died` (deferred emit).
- [ ] `hurtbox_component.gd`: skeleton — `Area3D`, `armor_type` export, empty
      `_on_area_entered` for now (wired in Epic 02 once `HitboxComponent`
      exists and matters).
- [ ] `hitbox_component.gd`: skeleton — `Area3D`, `damage`/`damage_type`
      exports, no logic yet.
- [ ] `move_to_target_component.gd`: full implementation now — exports
      `speed`, `hold_height`, `gravity_enabled`; in `_physics_process`, moves
      the sibling `CharacterBody3D` toward a `target_position: Vector3` (set
      externally) using `move_and_slide()`. Needed for Task 01-17's enemy
      placeholder.
- [ ] `targeting_component.gd`: skeleton for now (no targets exist until
      Epic 02 combat).
- [ ] `cooldown_component.gd`: full implementation — wraps a `Timer` child,
      `is_ready()`, `consume()`.
- [ ] `hit_flash_component.gd`: skeleton.
- [ ] `death_fx_component.gd`: skeleton — listens to sibling
      `HealthComponent.died`, for now just calls `queue_free()` on the owner
      (pooling wiring is Epic 02).

**Acceptance criteria**:
- [ ] Every file listed exists at the correct path with the correct
      `class_name`.
- [ ] A `HealthComponent` node added to any test scene can take damage, emit
      `died` when it reaches 0, and `reset()` back to full HP.
- [ ] A `MoveToTargetComponent` attached to a `CharacterBody3D` with
      `target_position` set moves that body toward the target at `speed`
      meters/sec, confirmed visually in the editor's 3D viewport.

---

## Task 01-13 — Resource Definition Base Classes

**Files**: `res://resources/**/*.gd`
**Ref**: `components.md` Section 5

- [ ] Create `tower_definition.gd`, `enemy_definition.gd`,
      `spell_definition.gd`, `stat_upgrade_definition.gd`,
      `chapter_definition.gd` — each extending `Resource`, each with exactly
      the `@export` fields listed in `components.md` Section 5.
- [ ] Do not create any `.tres` instances yet for spells/upgrades/chapters
      (those come in Epic 03/04). DO create one placeholder
      `tower_definition.gd`-based `.tres` and one `enemy_definition.gd`-based
      `.tres` now, since Tasks 01-15/17 need something to point at:
  - [ ] `res://resources/towers/tower_default.tres`: `tower_id="default"`,
        `model_path=""` (empty — no real model yet), `base_hp=1000`,
        `base_damage=20`, `base_fire_rate=1.0`, `base_range=8.0`,
        `base_armor=0`.
  - [ ] `res://resources/enemies/chap1_enemy_01.tres`: `enemy_id=
        "chap1_enemy_01"`, `model_path=""`, `base_hp=100`, `base_speed=1.5`,
        `base_damage=10`, `attack_cooldown=1.0`,
        `armor_type=Constants.ArmorType.UNARMORED`, `xp_value=10`.

**Acceptance criteria**:
- [ ] Both `.tres` files load via `load()` with no errors and expose the
      fields above with the correct values.

---

## Task 01-14 — CameraRig Scene & Script

**File**: `res://scenes/camera/CameraRig.tscn`
**Ref**: `mechanics.md` Section 1, `assets.md` Section 1

- [ ] Create `CameraRig.tscn` with root `Node3D`.
- [ ] Add a `Camera3D` child.
- [ ] Create `camera_rig.gd`:
  - `@export var camera_pitch_degrees: float = Constants.CAMERA_PITCH_DEGREES`
  - `@export var camera_distance: float = 10.0`
  - `@export var camera_height: float = 9.0`
  - In `_ready()`: position the `Camera3D` child at
    `Vector3(0, camera_height, camera_distance)` relative to the rig origin,
    and rotate it to pitch down by `camera_pitch_degrees` (use
    `look_at(Vector3.ZERO, Vector3.UP)` pointed at the arena center, or set
    rotation directly — either is fine as long as the resulting pitch matches
    the export value).
  - Implement `shake(duration: float, magnitude: float)`: tweens a small
    local positional offset on the `Camera3D` and back to zero — stub the
    body for now if Tween wiring feels premature, but the method must exist
    (Epic 08 wires real usage).
- [ ] Set `Camera3D.projection` to **Perspective** (the default) — explicitly
      confirm it is NOT Orthogonal, since that would silently recreate the
      spritesheet-render look we're avoiding.

**Acceptance criteria**:
- [ ] Placing `CameraRig.tscn` in a test scene with a 1×1×1 box at the origin
      shows the box from a steep downward angle, camera not rotated/tilted
      sideways (yaw = 0), in the editor's Game view.
- [ ] Changing `camera_pitch_degrees` in the Inspector and re-running visibly
      changes the angle.
- [ ] `Camera3D.projection == Camera3D.PROJECTION_PERSPECTIVE`.

---

## Task 01-15 — Generic Enemy Scene (Placeholder Mesh)

**File**: `res://scenes/enemies/Enemy.tscn`
**Ref**: `components.md` Section 6, `mechanics.md` Section 3

- [ ] Create `Enemy.tscn` with root `CharacterBody3D`, group `"enemies"`.
- [ ] Add children:
  - `MeshInstance3D` with a `CapsuleMesh` (height 1.2, radius 0.3) and a
    plain red `StandardMaterial3D` — this is the 3D placeholder, explicitly
    NOT a flat colored rectangle, since we need to confirm the capsule casts
    and receives a real shadow.
  - `CollisionShape3D` with a matching `CapsuleShape3D`.
  - `HealthComponent`, `MoveToTargetComponent`, `HitFlashComponent` (skeleton
    OK), `DeathFXComponent` (skeleton OK).
  - `MeleeRangeArea` (`Area3D` + `CollisionShape3D`, `SphereShape3D` radius
    1.0).
- [ ] Create `enemy.gd`:
  - `@export var definition: EnemyDefinition`
  - `_ready()`: if `definition` is assigned, set
    `HealthComponent.max_health = definition.base_hp`,
    `MoveToTargetComponent.speed = definition.base_speed`. Set
    `MoveToTargetComponent.target_position` to the tower's position (look up
    the `"tower"` group — tower placeholder doesn't exist until Task 01-17,
    so guard against a null lookup gracefully for now).
  - `_physics_process`: if not in melee range, do nothing extra (movement is
    handled entirely by `MoveToTargetComponent`).
  - `_on_melee_range_body_entered(body)`: if `body` is in group `"tower"`,
    stop movement (set `MoveToTargetComponent` speed to 0 or pause it).

**Acceptance criteria**:
- [ ] Dropping one `Enemy.tscn` instance into a test scene with a flat ground
      plane and a `DirectionalLight3D` shows a red capsule that casts a
      visible shadow on the ground.
- [ ] Setting `target_position` to a point across the ground makes the
      capsule visibly walk there using `move_and_slide()`.

---

## Task 01-16 — Arena Placeholder Scene

**File**: `res://scenes/main/GameWorld.tscn` (arena geometry directly in this
scene for now — a dedicated `Arena.tscn` comes when real models arrive in
Epic 06)

- [ ] In `GameWorld.tscn`, add a ground `MeshInstance3D` using a `PlaneMesh`
      (size roughly 12×12, per `assets.md` Section 1 scale table) with a
      plain green `StandardMaterial3D`, plus a matching `StaticBody3D` +
      `CollisionShape3D` (`BoxShape3D`, thin) so enemies can stand on it.
- [ ] Add one `DirectionalLight3D`, angled to clearly show shadows (this is
      the explicit test for "did we actually fix the shadow problem from the
      2D version" — confirm shadows render correctly here before moving on).
      Enable shadows on the light (`shadow_enabled = true`).
- [ ] Add a `WorldEnvironment` with a basic `Environment` resource (default
      sky, ambient light low-to-moderate so shadows remain visible and
      readable).
- [ ] Implement `_get_spawn_position() -> Vector3` in `WaveManager.gd` now
      that arena size is known: return a random point on the arena's outer
      edge (e.g. a ring at radius ~5.5–6m from center, matching the ~12m
      arena width).

**Acceptance criteria**:
- [ ] Running the project shows a lit ground plane with a clearly visible,
      correctly-shaped shadow cast by any object placed on it (test with a
      temporary box).
- [ ] No console errors about missing `Environment` or light setup.

---

## Task 01-17 — Tower Placeholder Scene

**File**: `res://scenes/tower/Tower.tscn`
**Ref**: `components.md` Section 6, `mechanics.md` Section 2

- [ ] Create `Tower.tscn` with root `CharacterBody3D`, group `"tower"`.
- [ ] Add children:
  - `MeshInstance3D` with a `BoxMesh` (size roughly 1×1.6×1, per the scale
    table in `assets.md`) and a plain blue `StandardMaterial3D`.
  - `CollisionShape3D` with a matching `BoxShape3D`.
  - `HealthComponent`, `TargetingComponent` (skeleton OK — no real targeting
    logic until Epic 02), `HitFlashComponent` (skeleton OK).
  - `AttackRangeArea` (`Area3D` + `CollisionShape3D`, `SphereShape3D` radius
    8.0, matching `base_range` from `tower_default.tres`).
- [ ] Create `tower.gd`:
  - `@export var definition: TowerDefinition`
  - `_ready()`: if `definition` is assigned, set
    `HealthComponent.max_health = definition.base_hp`. Apply to
    `GameState` via `GameState.start_run(definition)`.
  - Stub `_fire_spell()` — prints only, real wiring is Epic 02.

**Acceptance criteria**:
- [ ] Placing `Tower.tscn` at the arena center alongside the ground plane and
      camera rig shows a blue box, lit and shadowed correctly, viewed through
      the fixed camera angle.
- [ ] `Tower.tscn` is in group `"tower"` (verify via
      `get_tree().get_nodes_in_group("tower")` returning it).

---

## Task 01-18 — GameWorld Wiring

**File**: `res://scenes/main/GameWorld.tscn` + `GameWorld.gd`
**Ref**: `components.md` Section 6

- [ ] Add children to `GameWorld.tscn`:
  - `CameraRig` (instance of Task 01-14's scene), positioned to frame the
    arena.
  - `TowerNode` (instance of `Tower.tscn`), at `Vector3.ZERO`, with
    `definition` set to `tower_default.tres`.
  - `EnemyContainer` (`Node3D`).
  - `HUD` (`CanvasLayer`) — empty `Label` children for now: `WaveLabel`,
    `HPLabel`.
- [ ] Create `GameWorld.gd`:
  - `_ready()`:
    - Give `WaveManager` a reference to `EnemyContainer`.
    - Call `WaveManager.start_wave(1)`.
    - Connect `EventBus.wave_cleared`, `EventBus.tower_died`.
  - `_on_wave_cleared(wave_number)`: print only for now (real draft wiring
    Epic 03).
  - `_on_tower_died()`: print "GAME OVER" for now.
  - `_process(delta)`: update `HPLabel`/`WaveLabel` text from `GameState`.
- [ ] For each spawned enemy in `WaveManager._spawn_enemy()` (implement this
      now, called from `start_wave`): instance `Enemy.tscn`, assign
      `chap1_enemy_01.tres` as its `definition`, set position to
      `_get_spawn_position()`, add to `EnemyContainer`.

**Acceptance criteria**:
- [ ] Running the project shows: lit ground plane, blue tower box at center,
      3 red capsule enemies spawned at the arena edge, all visible through
      the fixed camera with correct shadows.
- [ ] HP and Wave labels are visible and show real values pulled from
      `GameState`.

---

## Task 01-19 — Integration Test

- [ ] Run the project.
- [ ] Verify: 3 red capsule enemies spawn at the arena edge and walk toward
      the blue tower box at center, on the ground plane (no floating, no
      sinking into the ground).
- [ ] Verify: shadows are visible and correctly shaped under the tower and
      each enemy — this is the explicit regression check against the old 2D
      version's shadow problems.
- [ ] Verify: the camera never rotates and shows the whole arena in frame at
      the configured pitch.
- [ ] Verify: when an enemy reaches the tower's `MeleeRangeArea`, it stops
      moving (combat itself is Epic 02, but the trigger must fire — check the
      Output panel or a temporary print).
- [ ] Verify: HP label and Wave label are visible on screen and show correct
      starting values (`tower_hp = 1000`, `wave = 1`).
- [ ] Open the Godot profiler — confirm no errors/warnings about missing
      nodes, missing autoloads, or null references during a 30-second run.
- [ ] Fix all errors before moving to Epic 02.
