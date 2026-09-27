# Epic 06 — Art

> Prerequisite: Epic 05 complete and tested. The game must be fully playable
> with primitive-mesh placeholders before touching this epic.
> Goal: Replace every remaining primitive placeholder mesh (capsules, boxes,
> planes — still used by `chap1_enemy_02`, `chap1_boss_01`, and the arena
> ground) with real Meshy-generated models, and add real animations to
> every model including `ancient_tower_lvl1`/`chap1_enemy_01` — which already
> have a real static-pose mesh from Epic 02 Task 02-00, but have never
> played an animation. Correct scale across everything. No
> `CapsuleMesh`/`BoxMesh`/`PlaneMesh` placeholders remain on gameplay
> objects, and no model is still unanimated.
> Completed epic delivers: the game looks like a finished 3D product, with
> the Archero-style camera/lighting actually paying off.
>
> **Arena exception (decided during implementation, see Task 06-05):** the
> arena ground intentionally stays a shader-driven `PlaneMesh`, not a
> Meshy-generated model — this is a deliberate choice, not a remaining gap.
> The actual problem fixed was structural (ground was hardcoded inline in
> `game_world.tscn` instead of being its own scene); the look never changed.

---

## Task 06-01 — Generate Remaining Models & Animation Clips in Meshy

**Ref**: `assets.md` Sections 1–3

- [ ] Generate (or regenerate, iterating on results) every model still
	  missing per `assets.md` Section 2: `chap1/chap1_enemy_02.glb`,
	  `chap1/chap1_boss_01.glb` (unless already swapped in during Epic 04).
	  `chap1/arena_chapter_01.glb` will **not** be generated — see Task
	  06-05, the arena stays a procedural shader-driven ground by decision.
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
> ⤷ **Not done — moved to `remaining_to_do_list.md` ("OLD EPICS tasks not done yet").**
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
> ⤷ **Not done — moved to `remaining_to_do_list.md` ("OLD EPICS tasks not done yet").**
---

## Task 06-03 — Animation Wiring [DONE]

**File**: `res://scenes/game_object/tower/tower.gd`,
`res://scenes/game_object/enemy/enemy.gd`,
`res://scenes/game_object/chap1/chap1_enemy_01/chap1_enemy_01.tscn` (and
siblings), `res://scenes/component/move_to_target_component.gd`,
`res://scenes/component/boss_heavy_attack_component.gd`

**Decisions (made during implementation):**
- **The tower has no attack animation — by design.** The tower only plays a
  looping `idle` (`tower.gd:_play_idle()`, speed-scaled by
  `Constants.TOWER_IDLE_ANIM_SPEED_SCALE`). The original "play `attack` on
  every shot, return to idle on `animation_finished`" requirement is
  removed, not pending. (The `idle` clip is embedded in the
  `ancient_tower_lvl3/4/5.glb` models; `lvl1`/`lvl2` currently have no clip
  and the code no-ops gracefully on them.)
- **The Epic-02 shrink-tween death placeholder is kept permanently — by
  choice, it looks good.** No `death` animation clips exist or are planned;
  `DeathFXComponent` tweens scale down over 0.25s then `queue_free()`s. The
  "replace the tween with a real `death` animation" requirement is removed.

- [x] Tower: plays `idle` in `_ready()` (no attack animation — see decision
	  above).
- [x] Enemy: hand-authored `walk` (looping, `autoplay`) + `attack` clips in
	  each enemy scene's AnimationPlayer; `attack` plays on each melee hit,
	  with a short deliberate pause after every attack
	  (`Constants.ENEMY_ATTACK_ANIM_PAUSE_RATIO` extends the attack timer
	  past the clip length). Death stays the shrink tween (see decision
	  above).
- [x] Boss: plays `attack_heavy` (embedded in the boss `.glb`s) via
	  `BossHeavyAttackComponent` on every
	  `Constants.BOSS_HEAVY_ATTACK_EVERY_N`th attack.
- [x] Sprite-flip equivalent for 3D: `MoveToTargetComponent._update_facing()`
	  rotates the body toward its flattened (Y-zeroed) velocity every physics
	  frame.

**Acceptance criteria**:
- [x] Every enemy visibly faces its direction of travel while walking.
- [x] Enemies play `walk` while approaching and `attack` on each melee hit,
	  with the post-attack pause between swings.
- [x] Death shrink-tween completes fully before the enemy is freed
	  (`queue_free()` fires from the tween callback, not instantly at 0 HP).
- [x] Boss visibly plays a distinct heavy-attack animation on its telegraphed
	  hits.

---

## Task 06-04 — Lighting & Shadow Tuning [NOT REQUIRED]

**File**: `res://scenes/main/game_world.tscn`
**Ref**: `assets.md` Section 1, `project.md` Tech Stack

**Decision (made during implementation): skipped, not deferred.** Tuning the
`WorldEnvironment` ambient light and `DirectionalLight3D` shadow strength per
this task's original spec made the game look washed-out and bad in practice —
the flat, evenly-lit current look (`background_mode = 2`, no sky/ambient/
tonemap) reads better with the toon-flat models than a "correctly" tuned
real-time shadow pass does. `game_world.tscn`'s `WorldEnvironment` stays as-is
intentionally. Nothing here needs revisiting unless the base art style
changes.

~~- Tune the `DirectionalLight3D` angle and the `WorldEnvironment`'s ambient
	light so real character models read clearly at the fixed camera angle.~~
~~- Confirm shadow quality settings are reasonable for Mobile-renderer
	real-time shadows.~~
~~- Confirm the rim-light/toon-shader look reads correctly with real-time
	shadows now active.~~

---

## Task 06-05 — Arena Ground Extraction & Per-Chapter Colors [DONE]

**Files**: `res://scenes/game_object/chap1/chap1_arena/chap1_arena.tscn`,
`res://scenes/game_object/arena/arena.gd`, `res://scenes/main/game_world.tscn`

**Decision**: the arena ground stays a shader-driven `PlaneMesh` (not a
Meshy-generated `arena_chapter_01.glb`) — explicit choice, not a skipped
task. The real gap was structural: the ground was hardcoded inline inside
`game_world.tscn` instead of being its own scene like every other game
object in this project.

- [x] Extracted the ground into its own scene (`chap1_arena.tscn`),
	  matching the project's one-scene-folder-per-object convention — same
	  `PlaneMesh` size (40×57), same `ground_checker.gdshader`, same
	  `BoxShape3D` collision as before. `game_world.tscn` now instances it
	  as a single `Arena` node instead of inline sub-resources.
- [x] Added a reusable `Arena` script (`arena.gd`, `@tool class_name Arena`)
	  exposing `color_1`–`color_4` as `@export`ed `Color` fields wired to
	  the shader's 4 uniforms, editable live in the Inspector. Future
	  chapters get their own ground by duplicating this scene and setting
	  the 4 colors (e.g. blues for chapter 2) — no code changes needed.
- [x] Dimensions/position never changed (same mesh size, same collision),
	  so `WaveManager._get_spawn_position()`'s spawn-ring radius and the
	  camera rig's framing did not need retuning.

**Acceptance criteria**:
- [x] Ground renders and collides identically to before the refactor —
	  verified via headless Godot instantiation of both `chap1_arena.tscn`
	  and `game_world.tscn`, no load/compile errors.
- [x] Enemies still spawn correctly at the arena's edge — no change to
	  spawn geometry.
- N/A — no real-model swap occurred by design; the "fills camera frame"
	  criterion doesn't apply since the footprint is unchanged.

---

## Task 06-06 — VFX Particle Systems (3D)
> ⤷ **Not done — moved to `remaining_to_do_list.md` ("OLD EPICS tasks not done yet").**
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
- [x] Each of the 3 v1 spells and 3 v1 upgrades shows its correct icon in
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
> ⤷ **Not done — moved to `remaining_to_do_list.md` ("OLD EPICS tasks not done yet").**
