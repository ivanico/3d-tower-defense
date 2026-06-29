# Epic 02 — Combat

> Prerequisite: Epic 01 complete and all its acceptance criteria verified.
> Goal: Tower auto-fires real 3D projectiles at enemies. Enemies take damage
> and die. XP is awarded. Object pooling replaces `queue_free()` for
> projectiles and enemies. Damage flows entirely through the
> Hitbox/Hurtbox/HealthComponent chain set up in Epic 01 — no new ad-hoc
> damage paths.
> Completed epic delivers: a full damage loop — tower shoots real 3D
> projectiles, enemies die, XP bar fills, level-up draft stub triggers.
>
> **Before any of the combat tasks below**: do Task 02-00 first. Epic 01
> shipped (correctly, for that stage) with a capsule enemy and a box tower.
> Task 02-00 swaps in one real model each for those two, so you're not
> staring at primitives for the next several epics, and so the camera/scale
> decisions made in Epic 01 get checked against real proportions before more
> systems get built on top. It's a one-time setup step, not part of the
> combat work itself — everything from Task 02-01 onward assumes it's done.

---

## Task 02-00 — Swap In One Real Model Each for Tower & Baseline Enemy

**Files**: `res://resources/towers/tower_default.tres`,
`res://resources/enemies/chap1_enemy_01.tres`
**Ref**: `assets.md` Section 1 (scale table), Section 2

> **Why now, and why this isn't "doing Epic 06 early"**: the camera
> pitch/distance/height and arena sizing you tuned by eye in Epic 01 were
> judged against a capsule and a box. Real Meshy models won't have the same
> proportions, so there's a real risk those decisions look wrong once actual
> art goes in — exactly the kind of rework this 3D rebuild exists to avoid.
> This task is one rough, **unanimated**, static-pose mesh each for the
> tower and `chap1_enemy_01` — no animation states, no VFX, no lighting
> polish. Those remain genuinely Epic 06's job. This task only exists to
> validate scale/camera against something real and to stop you looking at
> primitives for five more epics.

- [ ] Generate one rough `tower_default.glb` and one rough
	  `chap1_enemy_01.glb` via Meshy, per `assets.md` Section 2's filenames
	  and Section 1's scale table. A single static pose is enough — do not
	  invest in rigging/animation clips yet; that's Epic 06, and doing it
	  now risks wasted effort if the model needs revision later.
- [ ] Update `tower_default.tres`'s `model_path` and `chap1_enemy_01.tres`'s
	  `model_path` (currently empty string from Epic 01) to point at the
	  real `.glb` files.
- [ ] In `tower.gd`/`enemy.gd`'s `_ready()`, replace the primitive
	  `MeshInstance3D`/`CollisionShape3D` setup built in Epic 01: instance
	  the `.glb` scene via `load(definition.model_path).instantiate()` as a
	  child, remove the `CapsuleMesh`/`BoxMesh` placeholder. Resize/replace
	  `CollisionShape3D` to roughly match the real model's actual footprint
	  — it won't exactly match the old placeholder dimensions, and that's
	  fine; eyeball a reasonable fit, exact collision tuning isn't a
	  blocker here.
- [ ] Re-check the camera rig's `camera_distance`/`camera_height`/
	  `camera_pitch_degrees` and the arena's size (both from Epic 01)
	  against the real model's actual on-screen scale. Adjust if the real
	  model's proportions don't match what the primitives implied — this is
	  the explicit check this task exists to force.
- [ ] Leave `chap1_enemy_02` and `chap1_boss_01` as primitives for now —
	  they aren't built until Epic 04, and that epic notes where the same
	  swap-in approach applies to them if you want it.

**Acceptance criteria**:
- [ ] Running the project shows a real (static, unanimated) tower model and
	  real (static, unanimated) enemy model — no `CapsuleMesh`/`BoxMesh`
	  remaining on either — correctly lit and casting shadows under the
	  fixed camera.
- [ ] The real models' on-screen scale relative to each other and the arena
	  looks reasonable (tower roughly enemy-sized or slightly larger, per
	  `assets.md`'s scale table) — if it doesn't, the camera/arena values
	  get adjusted right here, not left mismatched for Epic 06 to discover.
- [ ] Every piece of Epic 01 behavior that worked against primitives
	  (movement, melee-range trigger, HP/wave labels) still works
	  identically against the real models — confirms the component pattern
	  genuinely doesn't care what mesh is attached.

---

## Task 02-01 — Projectile Scene & Script

**File**: `res://scenes/spells/Projectile.tscn`
**Ref**: `components.md` Section 6, `mechanics.md` Section 1 (Verticality
Rules), Section 5

- [ ] Create `Projectile.tscn` with root `Area3D`.
- [ ] Add children:
  - `MeshInstance3D` — small `CapsuleMesh` or `SphereMesh` placeholder (the
	real Meshy-sourced bolt model/primitive comes in via `assets.md`, but a
	primitive is fine indefinitely for a projectile this small — see
	`assets.md` Section 3).
  - `CollisionShape3D` — `SphereShape3D` radius 0.15.
  - `HitboxComponent` (from Epic 01) — now fully wired (see Task 02-02).
  - `VisibleOnScreenNotifier3D`.
- [ ] Create `projectile.gd`:
  - Vars: `speed: float = 14.0`, `_direction: Vector3`, `_hits: int = 0`,
	`pierce_count: int = 0`.
  - `initialize(start_pos: Vector3, target_pos: Vector3, spell:
	SpellDefinition)`:
	- Set `global_position = start_pos`.
	- Set `HitboxComponent.damage = spell.damage *
	  GameState.tower_damage_multiplier`.
	- Set `HitboxComponent.damage_type = spell.damage_type`.
	- Set `pierce_count = spell.pierce_count` (default 0 if field unused at
	  v1 — pierce is a **[LATER]** stat per `mechanics.md`, but the field can
	  exist now harmlessly).
	- Compute `_direction = (target_pos - start_pos).normalized()`.
	- Orient the mesh to face `_direction` (`look_at` or equivalent).
	- Reset `_hits = 0`.
  - `_physics_process(delta)`: `global_position += _direction * speed *
	delta`. Held at a fixed height (chest-height offset) per
	`mechanics.md` Verticality Rules — straight-line travel, no arc.
  - `_on_area_entered(area)`: if `area` is a `HurtboxComponent` belonging to a
	node in group `"enemies"`: that hurtbox's owner takes the hit (the
	`HurtboxComponent` itself does the damage math, per Epic 01's component
	contract — this script just increments `_hits` and decides whether to
	release).
	Increment `_hits`. If `_hits > pierce_count`: call
	`ObjectPool.release(self)`.
  - `_on_screen_exited()`: call `ObjectPool.release(self)`.
- [ ] Wire `HitboxComponent`'s `Area3D` to monitor layer `"enemies"`, and the
	  projectile's own collision layer to `"projectiles"` (define these
	  physics layers now in Project Settings if not already named).

**Acceptance criteria**:
- [ ] Calling `projectile.initialize(tower_pos, enemy_pos, test_spell)` then
	  letting `_physics_process` run moves the projectile visibly from tower
	  to enemy in a straight 3D line.
- [ ] On reaching an enemy's `HurtboxComponent`, the enemy's HP visibly drops
	  by the expected damage amount (verified via print or HP bar from
	  Epic 01).
- [ ] The projectile releases to the pool (not `queue_free()`) after exactly
	  `pierce_count + 1` hits.

---

## Task 02-02 — Hurtbox/Hitbox Damage Wiring

**File**: `res://scripts/components/hurtbox_component.gd`,
`res://scripts/components/hitbox_component.gd`
**Ref**: `components.md` Section 4, `mechanics.md` Section 5

- [ ] Complete `hitbox_component.gd`: exports `damage: float`,
	  `damage_type: int`. No behavior beyond carrying these values — confirm
	  it still has no `if` branches per-spell (data only).
- [ ] Complete `hurtbox_component.gd`:
  - `_ready()`: connect own `area_entered` to `_on_area_entered`.
  - `_on_area_entered(area)`: if `area` does not have a `damage` property
	(i.e. isn't a `HitboxComponent`), return.
  - Call `CombatUtils.calculate_damage(area.damage, area.damage_type,
	armor_type)`.
  - Call sibling `HealthComponent.damage(final_amount)`.
  - Show/update the owner's HP bar if one exists (see Task 02-09).

**Acceptance criteria**:
- [ ] A `HitboxComponent` with `damage = 50`, `damage_type = NORMAL`
	  overlapping a `HurtboxComponent` with `armor_type = UNARMORED` reduces
	  that hurtbox's sibling `HealthComponent.current_health` by exactly 50.
- [ ] The same hitbox against `armor_type = HEAVY` reduces health by 35 (per
	  the 0.7× table entry in `project.md`).

---

## Task 02-03 — AoEZone Scene & Script

**File**: `res://scenes/spells/AoEZone.tscn`
**Ref**: `components.md` Section 6, `mechanics.md` Section 1, Section 5

- [ ] Create `AoEZone.tscn` with root `Area3D`.
- [ ] Add children:
  - `MeshInstance3D` — flattened `CylinderMesh` or `SphereMesh` (squashed),
	semi-transparent orange placeholder material, radius set at runtime.
  - `CollisionShape3D` — `CylinderShape3D` or `SphereShape3D`, radius set at
	runtime.
- [ ] Create `aoe_zone.gd`:
  - `initialize(pos: Vector3, radius: float, spell: SpellDefinition)`:
	- Set `global_position = pos` (ground height).
	- Set up a `HitboxComponent`-equivalent damage value
	  (`damage = spell.damage * GameState.tower_damage_multiplier`,
	  `damage_type = spell.damage_type`) — an `AoEZone` can either contain a
	  child `HitboxComponent` it configures, or implement the same
	  `damage`/`damage_type` properties directly and call
	  `CombatUtils.calculate_damage()` itself against every overlapping
	  `HurtboxComponent`. Pick one approach and keep it consistent with how
	  `Projectile.tscn` does it (prefer reusing `HitboxComponent` so there is
	  only one source of truth for "what counts as a hit").
	- Scale the `CollisionShape3D` to `radius`.
  - `_ready()`: call `_apply_damage()` once, then start a 0.3-second one-shot
	`Timer` that calls `ObjectPool.release(self)` on timeout.
  - `_apply_damage()`: `get_overlapping_areas()` or
	`get_overlapping_bodies()` (whichever matches how `HurtboxComponent`s are
	structured — they're `Area3D`s per Epic 01, so use
	`get_overlapping_areas()`), filter for `HurtboxComponent`s belonging to
	group `"enemies"`, apply damage to each.

**Acceptance criteria**:
- [ ] Calling `aoe_zone.initialize(enemy_cluster_center, 2.0, test_aoe_spell)`
	  damages every enemy within a 2-meter radius of that point, and does not
	  damage an enemy standing 3 meters away.
- [ ] The zone releases to the pool 0.3 seconds after spawning.

---

## Task 02-04 — Tower Fires Spells (Real Implementation)

**File**: `res://scenes/tower/Tower.tscn` / `tower.gd`
**Ref**: `mechanics.md` Section 2, Section 8

- [ ] Replace the Epic 01 `_fire_spell()` stub:
  - If `spell.spell_category == SpellCategory.PROJECTILE`: call
	`_fire_projectile(spell)`.
  - If `spell.spell_category == SpellCategory.AOE_BURST`: call
	`_fire_aoe(spell)`.
  - If `spell.spell_category == SpellCategory.PASSIVE`: call
	`_fire_passive(spell)` (stub — passives apply as standing buffs, not
	on-fire actions; real handling depends on the specific passive spell, see
	Task 02-06).
- [ ] Implement `_fire_projectile(spell)`:
  - Call `TargetingComponent.get_target()`. If null, return.
  - Get a projectile from pool:
	`ObjectPool.get(preload("res://scenes/spells/Projectile.tscn"))`.
  - Add to `ProjectileContainer` if not already parented.
  - Call `proj.initialize(global_position, target.global_position, spell)`.
- [ ] Implement `_fire_aoe(spell)`: same shape, targeting the chosen target's
	  position and using `spell.aoe_radius`.
- [ ] Each active spell gets its own `CooldownComponent` child (instanced
	  when the spell is added via `add_spell()` — stub this method now,
	  added properly when drafting exists in Epic 03; for now, hardcode
	  adding the tower's `starting_spell_id` spell on `_ready()`).
- [ ] In `_physics_process`, tick every active spell's `CooldownComponent`
	  and fire when ready.

**Acceptance criteria**:
- [ ] With one test `SpellDefinition` (projectile category) assigned as the
	  tower's starting spell, the tower fires a projectile at the closest
	  enemy in range once per cooldown, with no manual triggering needed.
- [ ] Firing at an enemy outside `TargetingComponent.range` does not happen
	  (no target found, `_fire_projectile` returns early).

---

## Task 02-05 — TargetingComponent Real Implementation

**File**: `res://scripts/components/targeting_component.gd`
**Ref**: `components.md` Section 4

- [ ] Complete the skeleton from Epic 01:
  - A sibling `Area3D` ("range trigger") connects `body_entered`/
	`body_exited` to `_on_range_entered`/`_on_range_exited`.
  - `_on_range_entered(body)`: if `body` in group `"enemies"`, append to
	`_enemies_in_range`.
  - `_on_range_exited(body)`: remove from `_enemies_in_range`.
  - `get_target() -> Node3D`: `match mode:` — `TargetMode.CLOSEST` returns
	the nearest entry in `_enemies_in_range` by `global_position` distance;
	returns `null` if the list is empty.

**Acceptance criteria**:
- [ ] An enemy entering the tower's `AttackRangeArea` appears in
	  `_enemies_in_range`; leaving removes it.
- [ ] `get_target()` returns the genuinely closest of 3 enemies placed at
	  different distances within range (verify with a test scene with 3
	  enemies at known distances).

---

## Task 02-06 — Enemy Takes Damage & Dies (Real Implementation)

**File**: `res://scripts/components/health_component.gd`,
`res://scripts/components/death_fx_component.gd`, `res://scenes/enemies/Enemy.tscn`
**Ref**: `mechanics.md` Section 3, Section 9

- [ ] Confirm `HealthComponent.damage()` (built in Epic 01) correctly emits
	  `died` exactly once when health crosses to ≤0 (not on every subsequent
	  hit while already dead — guard against double-emit).
- [ ] In `enemy.gd`, connect `HealthComponent.died` →
	  `EventBus.emit_signal("enemy_died", self, global_position)` and
	  `EventBus.emit_signal("xp_gained", definition.xp_value)`.
- [ ] Complete `death_fx_component.gd`: on `died`, play a placeholder death
	  reaction (simple scale-down tween is fine without real animations yet),
	  then call `ObjectPool.release(owner)` — replacing Epic 01's temporary
	  `queue_free()`.
- [ ] Add an HP bar above each enemy (`Label3D` showing a simple bar via a
	  `ProgressBar`-on-a-`SubViewport` setup, OR simplest v1 option: a flat
	  `Sprite3D`/`MeshInstance3D` bar billboard scaled by HP fraction — pick
	  the simplest approach that reads correctly under the fixed camera;
	  avoid over-engineering this for v1). Show only when `current_health <
	  max_health`.

**Acceptance criteria**:
- [ ] An enemy reduced to 0 HP plays its (placeholder) death reaction exactly
	  once, then disappears via pool release (confirm via
	  `ObjectPool` internal counters that no node count growth occurs over
	  repeated kills).
- [ ] `WaveManager._active_enemies` correctly drops the dead enemy and emits
	  `wave_cleared` when it was the last one.
- [ ] HP bar appears above an enemy after its first hit and updates as it
	  takes more damage.

---

## Task 02-07 — XP & Level-Up Stub

**File**: `res://autoloads/GameState.gd`
**Ref**: `mechanics.md` Section 7

- [ ] Connect `EventBus.xp_gained` in `GameState._ready()`.
- [ ] `_on_xp_gained(amount)`: add to `run_xp`, emit `xp_bar_updated`. If
	  `run_xp >= run_xp_to_next`: increment `run_level`, roll over remainder,
	  scale `run_xp_to_next *= Constants.XP_LEVEL_SCALE_PER_LEVEL`, emit
	  `EventBus.level_up(run_level)`,
	  call `DraftManager.open_draft("level_up")` (still a stub from Epic 01
	  — just emits `draft_opened`, real draft UI is Epic 03).
- [ ] Set initial `run_xp_to_next = Constants.XP_PER_LEVEL_BASE` in
	  `start_run()`.

**Acceptance criteria**:
- [ ] Killing enough placeholder enemies (or directly calling
	  `GameState.gain_xp()` in a test) triggers exactly one `level_up` emit
	  per threshold crossed, even if a single XP gain crosses multiple
	  thresholds at once (loop the level-up check, don't just check once).

---

## Task 02-08 — HUD XP/HP Bars (Real Implementation)

**File**: `res://scenes/ui/HUD.tscn` + `HUD.gd`
**Ref**: `mechanics.md` Section 10

- [ ] In `HUD.tscn`, replace the Epic 01 placeholder Labels with:
  - `XPBar` (`ProgressBar`), `LevelLabel`, `HPBar` (`ProgressBar`, styled
	red/green), `HPLabel`, `WaveLabel`.
- [ ] `HUD.gd`: connect to `GameState.hp_changed`, `GameState.xp_bar_updated`,
	  tween bar values smoothly rather than snapping.
- [ ] Connect `EventBus.wave_started` → update `WaveLabel`.

**Acceptance criteria**:
- [ ] HP bar visibly animates downward when the tower takes damage (not an
	  instant jump).
- [ ] XP bar visibly fills and resets correctly on level-up.

---

## Task 02-09 — Object Pool for Enemies (Full Wiring)

**File**: `res://autoloads/WaveManager.gd`, `res://scenes/enemies/Enemy.tscn`
**Ref**: `mechanics.md` Section 9

- [ ] Preload and pool the enemy scene in `GameWorld._ready()`:
	  `ObjectPool.preload_pool(Enemy_scene, 15)`.
- [ ] In `WaveManager._spawn_enemy(definition)`:
  - Get from pool: `var e = ObjectPool.get(Enemy_scene)`.
  - Set `e.definition = definition`, call a `reset()` method on `e` that
	re-applies stats from the (possibly different) definition, resets HP,
	clears attacking state, re-enables collision.
  - Set position, add to `EnemyContainer` if not already parented, enable
	collision shapes.
  - Append to `_active_enemies`.
- [ ] Add `reset()` to `enemy.gd`: re-reads `definition`, resets
	  `HealthComponent`, clears `_is_attacking`, hides HP bar.

**Acceptance criteria**:
- [ ] Running 3+ waves back to back shows no growth in total scene-tree node
	  count beyond the pool's pre-allocated size (check Godot's remote node
	  count or a manual counter).
- [ ] A pooled-and-reused enemy correctly shows full HP and the right stats
	  for whatever `definition` it was just assigned, even if the previous
	  occupant had different stats.

---

## Task 02-10 — Tower Takes Damage

**File**: `res://scenes/enemies/Enemy.tscn`/`enemy.gd`,
`res://scenes/tower/Tower.tscn`/`tower.gd`
**Ref**: `mechanics.md` Section 2

- [ ] In `enemy.gd`, on `MeleeRangeArea` entering the tower: start ticking the
	  enemy's attack `CooldownComponent`. On cooldown ready: call
	  `EventBus.emit_signal("tower_damaged", definition.base_damage)` and
	  directly call the tower's `HurtboxComponent` damage path (reuse the
	  same `CombatUtils.calculate_damage()` call — tower damage type from
	  enemies is `NORMAL` for all v1 enemies).
- [ ] `GameState.take_damage(amount)` (built in Epic 01) emits `hp_changed`
	  → HUD updates (confirmed working from Task 02-08).
- [ ] Confirm `EventBus.tower_died` fires when tower HP hits 0 (from Epic
	  01's `HealthComponent` — should already work; this task is the
	  integration check).

**Acceptance criteria**:
- [ ] HP bar visibly decreases as an enemy in melee range repeatedly hits the
	  tower on its cooldown (not every physics frame).
- [ ] Tower HP reaching 0 fires `tower_died` exactly once.

---

## Task 02-11 — Game Over Stub

**File**: `res://scenes/main/GameWorld.gd`

- [ ] On `EventBus.tower_died`:
  - Call `WaveManager.clear_all_enemies()`.
  - Pause: `get_tree().paused = true`.
  - Show a simple `Label` (CanvasLayer, always-process) in screen center:
	"GAME OVER — Tap to retry".
  - On tap: unpause, `GameState.reset()`,
	`get_tree().reload_current_scene()`.
- [ ] Full DefeatScreen scene comes in Epic 04.

**Acceptance criteria**:
- [ ] Reducing the tower to 0 HP (e.g. via a debug call) pauses the game,
	  shows the label, and tapping it correctly resets and reloads.

---

## Task 02-12 — Wave Clear & Next Wave Stub

**File**: `res://scenes/main/GameWorld.gd`

- [ ] On `_on_wave_cleared(wave_number)`:
  - If `wave_number >= Constants.TOTAL_WAVES`: stub boss trigger (print
	"BOSS TIME" — real boss wiring Epic 04).
  - Else: increment `GameState.wave_number`, brief 1-second pause, call
	`WaveManager.start_wave(GameState.wave_number)`.
- [ ] Draft will be inserted here in Epic 03 — for now go straight to next
	  wave after 1 second.

**Acceptance criteria**:
- [ ] Clearing wave 1 (all enemies dead) automatically starts wave 2 after a
	  visible 1-second pause, with no manual trigger needed.

---

## Task 02-13 — Integration Test

- [ ] Run the project.
- [ ] Verify: tower fires real 3D projectiles (visible travel, correct
	  direction) at enemies, viewed through the fixed camera.
- [ ] Verify: enemies lose HP and die after enough hits; HP bar appears on
	  first hit.
- [ ] Verify: XP bar fills as enemies die; level counter increments;
	  `draft_opened` prints/fires in Output.
- [ ] Verify: HP bar decreases when enemies reach and attack the tower.
- [ ] Verify: when tower HP hits 0, game pauses and "GAME OVER" label
	  appears.
- [ ] Verify: wave clears when all enemies are dead and next wave spawns
	  after 1 second.
- [ ] Verify: no `queue_free()` calls remain on pooled projectiles or
	  enemies — search the codebase to confirm.
- [ ] Check Godot Profiler: physics process time stays reasonable with 15
	  active enemies (note the actual number — strict ms targets are Epic
	  08's job, but flag anything that looks obviously wrong now, e.g.
	  >16ms physics frame with this small a scene).
- [ ] Confirm shadows and lighting still render correctly with multiple
	  projectiles/enemies/effects active simultaneously (no z-fighting,
	  no obviously broken shadow artifacts).
- [ ] Fix all errors before moving to Epic 03.
