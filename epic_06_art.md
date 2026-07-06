# Epic 06 — Art

> Prerequisite: Epic 05 complete and tested. The game must be fully playable
> with primitive-mesh placeholders before touching this epic.
> Goal: Replace every remaining primitive placeholder mesh (capsules, boxes,
> planes — still used by `chap1_enemy_02`, `chap1_boss_01`, and the arena
> ground) with real Meshy-generated models, and add real animations to
> every model including `ancient_tower_lvl1`/`chap1_enemy_01` — which already
> have a real static-pose mesh from Epic 02 Task 02-00, but have never
> played an animation. Correct scale and tuned real-time lighting/shadows
> across everything. No `CapsuleMesh`/`BoxMesh`/`PlaneMesh` placeholders
> remain on gameplay objects, and no model is still unanimated.
> Completed epic delivers: the game looks like a finished 3D product, with
> the Archero-style camera/lighting actually paying off.

---

## Task 06-01 — Generate Remaining Models & Animation Clips in Meshy

**Ref**: `assets.md` Sections 1–3

- [ ] Generate (or regenerate, iterating on results) every model still
      missing per `assets.md` Section 2: `chap1/chap1_enemy_02.glb`,
      `chap1/chap1_boss_01.glb` (unless already swapped in during Epic 04), and
      `chap1/arena_chapter_01.glb`.
- [ ] For `towers/ancient_tower/ancient_tower_lvl1.glb` and `chap1/chap1_enemy_01.glb` (already in the
      project since Epic 02 Task 02-00, static-pose only): add the required
      animation clips now — `idle`/`attack` for the tower, `walk`/`attack`/
      `death` for the enemy — either by regenerating in Meshy with animation
      support or rigging/animating the existing mesh in Blender. You do not
      need to regenerate the base mesh if the Epic 02 version is good enough
      — only add what's missing (animation).
- [ ] For every other character/creature model, confirm Meshy's output
      includes (or add via Blender/a rigging step if needed) the required
      animation clips per `assets.md` Section 2 (`walk`/`attack`/`death` for
      enemies; plus `attack_heavy` for the boss).
- [ ] Apply the shared toon/cel shading approach from `assets.md` Section 1
      consistently across all models, including the two from Epic 02 if they
      don't already have it.
- [ ] Confirm each model's scale roughly matches the table in `assets.md`
      Section 1 once imported (adjust import scale in Godot if Meshy's
      native export scale doesn't match — this is normal and expected, not a
      sign of a broken model).

**Acceptance criteria**:
- [ ] All 5 `.glb` files exist in `res://assets/models/` (under `towers/
      ancient_tower/` or `chap1/` as appropriate) with the exact filenames
      from `assets.md`, every one with its full required animation set —
      including `ancient_tower_lvl1`/`chap1_enemy_01`, which previously
      only had a static pose.
- [ ] Each imports into Godot with no import errors, correct embedded
      animations visible in the AnimationPlayer panel, and visually
      reasonable scale relative to each other (boss dramatically larger than
      regular enemies, tower roughly enemy-sized or slightly larger).

---

## Task 06-02 — Wire Models Into Definitions

**File**: `res://resources/towers/tower_ancient_tower.tres`,
`res://resources/enemies/*.tres`

- [ ] Update the remaining `Definition` resources' `model_path` field
      (`chap1_enemy_02`, `chap1_boss_01` — empty string since Epic 04 unless
      already swapped in there; `ancient_tower_lvl1`/`chap1_enemy_01` already
      point at real `.glb` files since Epic 02 Task 02-00, no change needed
      for those two) to point at the real `.glb` paths (`chap1/<id>.glb` or
      `towers/ancient_tower/<id>.glb` per `assets.md` §2).
- [ ] In `tower.gd`/`enemy.gd`'s `_ready()`/`reset()`, confirm the
      mesh-instancing block built in Epic 02 Task 02-00 (instance the
      `.glb` scene via `load(definition.model_path).instantiate()` as a
      child) generically handles every enemy/tower now, including the ones
      whose `model_path` just changed from empty to real this task — there
      should be nothing enemy-type-specific to add here, since this code
      path was already proven generic back in Epic 02.
- [ ] Confirm this swap requires **zero changes** to any combat/movement/
      component code for the *newly* swapped models — only the `model_path`
      field changes. This is the explicit test of the "swap an asset without
      touching game logic" promise from `project.md`, now checked a second
      time on different entities than Epic 02's check covered.

**Acceptance criteria**:
- [ ] Running the project now shows real Meshy models in place of every
      remaining primitive placeholder, with all existing combat/movement/
      draft functionality from Epics 02–05 still working unchanged.
- [ ] Deleting and re-pointing `model_path` to a different `.glb` (test with
      a swapped file) requires no script edits, only the resource field
      change — confirm this explicitly as a test.

---

## Task 06-03 — Animation Wiring

**File**: `res://scenes/game_object/tower/tower.tscn`/`tower.gd`,
`res://scenes/game_object/chap1/chap1_enemy_01/chap1_enemy_01.tscn`/`enemy.gd`

- [ ] Tower: play `idle` in `_ready()`. On firing a spell, play `attack`,
      connect `animation_finished` to return to `idle`.
- [ ] Enemy: play `walk` while `MoveToTargetComponent` is actively moving the
      body; switch to `attack` while in the melee-attack state (from Epic
      02's `MeleeRangeArea` logic); on `HealthComponent.died`, play `death`
      via `DeathFXComponent` and connect `animation_finished` →
      `ObjectPool.release(self)` (replacing Epic 02's tween-based placeholder
      death reaction with the real animation).
- [ ] Boss: additionally play `attack_heavy` on the telegraphed heavy-attack
      component's trigger (Epic 04).
- [ ] Sprite-flip equivalent for 3D: rotate the model to face its movement
      direction (`look_at` toward the movement direction on the X/Z plane,
      or set `rotation.y` directly) — this is the 3D equivalent of the 2D
      `flip_h` trick, done properly with real rotation instead of a flip
      hack.

**Acceptance criteria**:
- [ ] Every enemy visibly faces its direction of travel while walking.
- [ ] Death animation completes fully before the enemy disappears (pool
      release fires on `animation_finished`, not immediately on HP reaching
      0).
- [ ] Tower visibly plays an attack animation synced to each shot, returning
      to idle between attacks.
- [ ] Boss visibly plays a distinct heavy-attack animation on its telegraphed
      hits.

---

## Task 06-04 — Lighting & Shadow Tuning

**File**: `res://scenes/main/game_world.tscn`
**Ref**: `assets.md` Section 1, `project.md` Tech Stack

- [ ] Tune the `DirectionalLight3D` angle and the `WorldEnvironment`'s
      ambient light so real character models (not primitives) read clearly
      at the fixed camera angle — shadows should be visible and correctly
      shaped under the new models, not washed out by ambient light or too
      dark to read silhouettes.
- [ ] Confirm shadow quality settings are reasonable for Mobile-renderer
      real-time shadows (this is a first-pass tuning check; the full
      mobile-performance budget pass is `epic_08_polish.md`'s job — don't
      over-invest in shadow resolution here if it costs frame time, just get
      it *correct-looking*, defer *fast* to Epic 08).
- [ ] Confirm the rim-light/toon-shader look (from `assets.md` Section 1)
      reads correctly with real-time shadows now active — these two systems
      (toon shading + real shadows) need to look good together, not fight
      each other (e.g. a shadow that completely flattens the toon rim-light
      effect would be a visual regression to flag and fix here).

**Acceptance criteria**:
- [ ] Real models cast and receive shadows correctly under the fixed camera
      view, with no obvious washing-out or unreadable-silhouette problems.
- [ ] A side-by-side before/after screenshot (primitive placeholders vs real
      models) shows a clear visual upgrade with working shadows in both —
      this is the direct regression check against the original 2D version's
      shadow problems.

---

## Task 06-05 — Arena Model Wiring

**File**: `res://scenes/main/game_world.tscn`

- [ ] Replace the Epic 01 `PlaneMesh` placeholder ground with
      `arena_chapter_01.glb`, instanced as a child, with its own
      `StaticBody3D`/`CollisionShape3D` matching its actual walkable area
      (adjust `WaveManager._get_spawn_position()`'s spawn-ring radius if the
      real arena's edge differs from the placeholder's ~12m assumption).
- [ ] Confirm the camera rig's framing (Epic 01's `camera_distance`/
      `camera_height`) still correctly fits the real arena in frame; retune
      if the real model's actual footprint differs from the placeholder's.

**Acceptance criteria**:
- [ ] The real arena model fully fills the camera's frame with appropriate
      margin, matching the original placeholder's framing intent.
- [ ] Enemies spawn at the real arena's edge (not floating off the model or
      spawning inside walls).

---

## Task 06-06 — VFX Particle Systems (3D)

**Ref**: `assets.md` Section 3

Create a `GPUParticles3D` subscene for each VFX type:

- [ ] `VFXHitSpark.tscn` — small burst, one-shot, billboarded particles using
      `vfx_hit_spark` texture, tinted by damage type color (reuse the same
      color-by-damage-type lookup pattern from `CombatUtils`, do not
      duplicate the color logic in the VFX script — call into
      `CombatUtils.get_damage_color()` if that helper doesn't exist yet, add
      it now as a small static function alongside the damage table lookup).
- [ ] `VFXDeathBurst.tscn` — dust/debris burst on enemy death.
- [ ] `VFXLevelUpRing.tscn` — expanding ring mesh or particle ring at the
      tower position on level-up, then `queue_free()`.
- [ ] Wiring: `Projectile`/`AoEZone` hit logic → instance `VFXHitSpark` at
      impact position; `DeathFXComponent` → instance `VFXDeathBurst`;
      `GameState`'s level-up handler → instance `VFXLevelUpRing`.

**Acceptance criteria**:
- [ ] Hit sparks appear at the correct 3D impact position and color-match
      the damage type dealt.
- [ ] Death burst plays at the correct position on every enemy kill.
- [ ] Level-up ring expands from the tower's position on level-up.
- [ ] Open the Godot remote scene tree during a busy moment (many hits at
      once) — confirm one-shot VFX nodes do not accumulate; each must free
      itself after playing.

---

## Task 06-07 — HUD/Draft Visual Polish

**File**: `res://scenes/ui/HUD.tscn`, `res://scenes/ui/draft_card.tscn`,
`res://scenes/ui/draft_ui.tscn`

- [ ] Replace placeholder `ColorRect`/plain `ProgressBar` UI with the real
      assets from `assets.md` Section 4 (`ui_hp_bar_*`, `ui_xp_bar_*`,
      `ui_card_bg_*`, spell/upgrade/tag icons).
- [ ] Import and apply the fonts from `assets.md` Section 5.

**Acceptance criteria**:
- [ ] No `ColorRect` placeholders remain in HUD or draft UI.
- [ ] Each of the 3 v1 spells and 3 v1 upgrades shows its correct icon in
      the draft card.

---

## Task 06-08 — Victory/Defeat Screen Polish

**File**: `res://scenes/ui/victory_screen.tscn`,
`res://scenes/ui/defeat_screen.tscn`

- [ ] Replace `ColorRect` backgrounds and plain `Button`s with
      `ui_button_primary`/`ui_button_secondary`/`ui_panel_dark` 9-slice
      assets.
- [ ] Apply display font for titles, sans-serif for stats.

**Acceptance criteria**:
- [ ] Both screens visually match the rest of the polished UI, no leftover
      `ColorRect` placeholders.

---

## Task 06-09 — Integration Test

- [ ] Run the project. Confirm zero `CapsuleMesh`/`BoxMesh`/`PlaneMesh`
      placeholders remain on any gameplay object (UI `ColorRect`s used for
      non-gameplay backgrounds where no real asset applies are fine to flag
      separately, but every character/tower/arena placeholder must be gone).
- [ ] All enemy animations play correctly: `walk` → `attack` → `death`,
      with correct facing-direction rotation throughout.
- [ ] Tower plays `attack` synced to firing, returns to `idle`.
- [ ] Boss plays its distinct heavy-attack animation on schedule.
- [ ] Hit sparks, death bursts, and level-up rings all play correctly and
      clean themselves up.
- [ ] Shadows and lighting read correctly on the real models from multiple
      camera-distance test positions (re-verify Task 06-04's tuning didn't
      regress after the arena swap in Task 06-05).
- [ ] Draft cards show correct spell/upgrade icons and rarity borders.
- [ ] Fix all visual glitches before moving to Epic 07.
