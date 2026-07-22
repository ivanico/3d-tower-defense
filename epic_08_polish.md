# Epic 08 — Polish, Performance & Export

> Prerequisite: Epics 01–07 complete and tested. The game must be fully
> playable with art and audio before this epic.
> Goal: Damage numbers, synergy banner polish, performance optimizations
> specific to real-time 3D on mobile (shadow cost, draw calls, particle
> budget), and a shippable Android APK.
> Completed epic delivers: a game ready for internal testing on a real
> Android device, running at a stable frame rate with real shadows.

> **Deferred from Epic 04**: `WaveManager`'s fallback timer
> (`Constants.WAVE_DURATION_MAX`) silently force-clears a stalled wave with
> no player-facing indication it's about to happen — confirmed during Epic
> 04 testing that this reads as confusing (wave clears with enemies still
> on-screen, no XP for them, no warning beforehand). Add some visual cue —
> a small countdown timer/HUD element, or a warning flash in the last few
> seconds — so the fallback feels intentional rather than like a bug. Small
> addition, pairs naturally with this epic's other HUD/UI polish tasks.

---

## Task 08-01 — Floating Damage Numbers (3D)

**File**: `res://scenes/ui/DamageNumber3D.tscn`
**Ref**: `mechanics.md` Section 10, `components.md` Section 7

- [ ] Create `DamageNumber3D.tscn` with root `Label3D`.
  - `billboard = BILLBOARD_ENABLED` (always faces the fixed camera).
  - Font: monospaced pixel font, sized for readability at the camera's fixed
	distance (tune by eye — start large, e.g. font_size 48, and adjust).
  - `no_depth_test` considerations: confirm the number renders on top of
	nearby geometry sensibly without needing a full always-on-top hack;
	if it visually clips behind a model at certain angles, enable
	`no_depth_test` on the `Label3D` as a fallback.
- [ ] `damage_number_3d.gd`:
  - `spawn(value, dtype, is_crit, world_pos: Vector3)`: set text, color via
	`CombatUtils.get_damage_color(dtype)` (added in Epic 06 Task 06-06 — if
	it doesn't exist yet, add it now), scale up 1.4× and prefix "★" if crit.
  - Position at `world_pos + Vector3(0, 1.5, 0)` plus small random X/Z
	scatter (not 2D screen-space scatter — actual 3D world offset, since this
	is a real `Label3D` in the 3D scene).
  - Tween: move `position.y` up further over 0.8s, fade alpha (0.4s delay
	before fade starts), then release to pool.
- [ ] Pool via `ObjectPool`, preload count 30 (smaller than the original
	  design's 40 — v1 has fewer simultaneous enemies; bump if profiling
	  shows exhaustion).
- [ ] In `HurtboxComponent`'s damage-taking logic: after computing final
	  damage, get a pooled `DamageNumber3D`, call `spawn()` at the hit
	  position. **Crit detection**: `final_damage > base_damage * 1.5`.
- [ ] Cap visible damage numbers at 10 simultaneously; skip spawning beyond
	  that until the oldest clears.

**Acceptance criteria**:
- [ ] Damage numbers spawn at the correct 3D hit position, are always
	  readable face-on regardless of where on the arena the hit occurred
	  (billboarding works), and color-match the damage type.
- [ ] Crit hits visibly scale up and show the star prefix.
- [ ] No more than 10 numbers visible at once under a heavy-hit-rate stress
	  test.

---

## Task 08-02 — Synergy Banner Polish

**File**: `res://scenes/ui/synergy_banner.tscn`/`synergy_banner.gd`

Banner is functional from Epic 03; this is UI-only polish (`CanvasLayer`,
not affected by the 3D rebuild) — same approach as the original design:

- [ ] Slide-down-from-top tween (off-screen → on-screen over 0.3s ease-out),
	  hold 2.0s, slide back (0.2s ease-in).
- [ ] Brief full-screen white flash (`ColorRect`, alpha 0.3 → 0 over 0.25s)
	  on ×5 synergy tiers only, not ×3.
- [ ] Queue multiple banners if they fire in quick succession (an `Array`
	  queue in the script) rather than overlapping/cutting each other off.

**Acceptance criteria**:
- [ ] Triggering both `[Offense]×3` and `[Armor]×3` in quick succession shows
	  both banners in sequence, not overlapping or skipped.
- [ ] Only ×5 tiers trigger the screen flash.

---

## Task 08-03 — Enemy HP Bar Polish (3D)

**File**: `res://scenes/game_object/chap1/chap1_enemy_01/chap1_enemy_01.tscn`

- [ ] Replace Epic 02's simple HP bar approach with a clean billboarded
	  version: a small `Node3D` positioned above the enemy's head (height
	  tuned per the model's actual size from Epic 06), containing either two
	  `Sprite3D`/`MeshInstance3D` bars (background + fill, both billboarded)
	  or a `Label3D`-adjacent simple bar — pick whichever renders cleanly;
	  avoid a full `SubViewport`-based UI-in-3D solution unless the simpler
	  options look bad (that approach costs more render overhead and isn't
	  justified at this scale).
- [ ] Fill color: green >50%, yellow 25–50%, red <25%.
- [ ] Tween fill width smoothly on damage (0.15s).
- [ ] Boss: a separate, larger always-visible `ProgressBar` in the HUD
	  `CanvasLayer` (2D, top-center of screen) rather than a 3D billboard —
	  bosses are visually large enough that a screen-space bar reads better
	  than a billboard that might be off-frame at the boss's scale.

**Acceptance criteria**:
- [ ] Regular enemy HP bars correctly billboard toward the camera and show
	  the right color/fill at all HP levels.
- [ ] Boss HP bar appears in the HUD as a screen-space element, updates
	  correctly on every hit.

---

## Task 08-04 — Targeting Indicator (3D)

**File**: `res://scenes/game_object/tower/tower.tscn`/`tower.gd`

- [ ] Add a faint 3D line from the tower to its current target, using a
	  `MeshInstance3D` with an `ImmediateMesh`/thin cylinder, or Godot 4's
	  line-drawing approach for 3D (there's no `Line2D` equivalent built-in
	  for 3D in the same way — use a thin stretched `BoxMesh`/cylinder
	  oriented between the two points, regenerated each frame, or a
	  transparent unshaded material so it doesn't pick up odd lighting).
- [ ] Width-equivalent thin, color `Color(1, 1, 1, 0.15)` — intentionally
	  subtle, just a hint of targeting direction.
- [ ] Update each `_physics_process` if there's an active target; hide/clear
	  if not.

**Acceptance criteria**:
- [ ] A faint line is visible from tower to current target during combat,
	  correctly updates as the target changes, and disappears when no target
	  is in range.

---

## Task 08-05 — Camera Shake on Boss Hit

**File**: `res://scenes/game_object/camera_rig/camera_rig.tscn`/`camera_rig.gd`

- [ ] Implement the real body of `shake(duration, magnitude)` (stubbed in
	  Epic 01 Task 01-14): tween the `Camera3D` child's local position offset
	  between small random `Vector3` values for `duration` seconds, then
	  tween the magnitude back to zero. Keep the offset small and on the
	  X/Y plane mostly (don't shake along the camera's forward axis, which
	  would look like a zoom pulse rather than a shake).
- [ ] Trigger mild shake (0.2s, small magnitude) on `EventBus.tower_damaged`.
- [ ] Trigger strong shake (0.4s, larger magnitude) on
	  `EventBus.boss_spawned` and on the boss's telegraphed heavy-attack
	  landing (Epic 04's `boss_heavy_attack_component`).

**Acceptance criteria**:
- [ ] Tower taking damage produces a subtle, brief camera shake; boss spawn
	  and boss heavy-attack landings produce a noticeably stronger one.
- [ ] Shake never visibly breaks the fixed-pitch/no-rotation camera rule
	  (i.e. it's a small positional jitter, not a rotation or a frame where
	  the arena goes out of view).

---

## Task 08-06 — Pause Menu

**File**: `res://scenes/ui/PauseMenu.tscn`

- [ ] Create `PauseMenu.tscn`, root `CanvasLayer`, layer 50. `DimBG`
	  (`ColorRect`), `Panel` with `TitleLabel`, `ResumeButton`,
	  `RestartButton`, `MapButton`, `MusicSlider`, `SFXSlider`. Hidden by
	  default.
- [ ] `pause_menu.gd`: slider values initialized from `AudioManager`; button/
	  slider wiring matches the original design's behavior (Resume unpauses;
	  Restart reloads the current chapter without spending energy again;
	  Map returns to WorldMap).
- [ ] `game_world.gd`: handle Android back button / Escape (`ui_cancel`
	  action) to toggle pause.

**Acceptance criteria**:
- [ ] Pausing mid-wave correctly freezes gameplay (note: use
	  `get_tree().paused = true` here, unlike the per-enemy `freeze()` used
	  for draft pauses in Epic 03 — confirm both pause mechanisms don't
	  conflict if a draft happens to be open when pause is pressed; test that
	  specific edge case explicitly).
- [ ] Volume sliders immediately affect playback and persist via
	  `MetaManager`.

---

## Task 08-07 — Performance Pass (3D-Specific)

**Ref**: `project.md` Tech Stack

Target: 60 fps stable on a mid-range Android device (Mobile renderer,
real-time shadows active).

- [ ] **Enemy separation steering**: limit distance checks to nearby enemies
	  only (pre-filter by a cheap distance check before any more expensive
	  logic), matching the same performance shape as a 2D version of this
	  check but using `Vector3`/`global_position.distance_squared_to()`.
- [ ] **Shadow cost**: this is the category that did not exist as a concern
	  in 2D and is new to this rebuild. Tune `DirectionalLight3D` shadow
	  distance/resolution down to the minimum that still looks correct at
	  the fixed camera's actual viewing distance — don't render shadow detail
	  for geometry far outside what the camera ever shows. Check the
	  in-editor frame-time breakdown specifically for shadow-pass cost.
- [ ] **Draw call / mesh instancing**: if many identical enemies are on
	  screen at once, confirm Godot is able to batch them reasonably (same
	  mesh + material instances batch better than unique materials per
	  instance) — this is a reason the shared toon-shader-material approach
	  from `assets.md` Section 1 matters for performance too, not just
	  visual consistency.
- [ ] **Particle budget**: cap total active `GPUParticles3D` emission across
	  all VFX to a tuned ceiling (start at 150, adjust by profiling — lower
	  than the original 2D design's 200, since 3D particles are typically
	  costlier per-particle). Add a lightweight global counter (a
	  `VFXManager` autoload or a static counter in `CombatUtils` — pick one,
	  don't duplicate). Skip low-priority effects (hit sparks) over budget;
	  always allow death/level-up VFX through.
- [ ] **Object pool audit**: run 5+ waves, check the profiler for orphan
	  nodes; confirm every pooled `get()` has a matching `release()`; grep
	  the codebase for any remaining `queue_free()` on pooled scene types
	  (should be zero for enemies, projectiles, AoE zones, damage numbers).
- [ ] **Wave fallback**: confirm Epic 04's 30-second fallback timer still
	  works correctly with real models/animations in place.
- [ ] **Memory**: run 3 full chapter runs without restarting; check Remote >
	  Memory for growing arrays or leaked scene instances (a 3D-specific risk
	  here: leaked `MeshInstance3D`/`AnimationPlayer` references if a model
	  instancing helper from Epic 06 has a bug — explicitly check this).

**Acceptance criteria**:
- [ ] Sustained 60 fps (or document the actual measured number if the test
	  device can't hit 60, with a plan to address it) during a wave with the
	  maximum expected enemy count and multiple spells/VFX firing
	  simultaneously, with real-time shadows enabled.
- [ ] No node-count growth across repeated waves/runs.
- [ ] Shadow-pass cost is identified and reduced if it was a major frame-time
	  contributor in the initial profiling pass.

---

## Task 08-08 — Input Tuning for Mobile

**File**: Various UI scripts

- [ ] All `Button`/tappable UI: `minimum_size` at least `Vector2(80, 80)`.
- [ ] Draft cards: full-card tap area (not just a small button), per Epic
	  03's existing implementation — confirm here as a check, not a rebuild.
- [ ] Disable mouse-hover-only states (no mobile hover).
- [ ] Test on a 1080×1920 device/emulator: confirm no UI clipping.
- [ ] Audit for `Input.is_action_pressed()` calls that should be
	  `just_pressed()` for single-frame actions (e.g. pause toggle).

**Acceptance criteria**:
- [ ] Every tappable UI element responds correctly to a single normal-finger
	  tap on a real or emulated touchscreen, with no clipped elements at
	  1080×1920.

---

## Task 08-09 — Android Export Setup

**Ref**: `project.md` Tech Stack

- [ ] Install the Android build template (Editor > Export Template
	  Manager).
- [ ] Project > Export > Android preset:
  - Package name: your own reverse-domain identifier.
  - App name: the project's working title.
  - Min SDK: 24 (Android 7.0). Target SDK: latest available stable at
	build time.
  - Orientation: Portrait.
  - **Graphics API**: confirm this matches the **Mobile** renderer
	requirement (Vulkan, with the automatic fallback to GLES3/Compatibility
	on unsupported devices per Godot 4.4+'s fallback behavior — do not force
	a GLES2-only path, which would conflict with the real-time shadow
	requirements this whole rebuild depends on).
  - Internet permission: OFF (no network required for v1).
- [ ] Configure signing: generate a debug keystore via `keytool` for testing
	  builds; document the exact command in a `BUILD_NOTES.md` at project
	  root.
- [ ] App icon: a placeholder is fine for internal testing; real icon is a
	  post-Epic-08 hotfix, not blocking.
- [ ] Export a debug APK; install on a real device or emulator.

**Acceptance criteria**:
- [ ] A debug APK builds successfully with no export errors.
- [ ] The APK installs and launches on a real Android device or emulator,
	  showing the real 3D scene (not a black screen or renderer-fallback
	  error) — this is the critical check that the Mobile-renderer choice
	  actually works on target hardware; if a real device falls back to
	  Compatibility and visibly loses shadows, flag this explicitly rather
	  than treating it as a minor issue, since it affects the whole visual
	  premise of the rebuild.

---

## Task 08-10 — Final Integration Test (Device)

Run ALL of the following on a real Android device or Godot's Android
emulator:

- [ ] Full run: WorldMap → wave 1 → final wave → boss → VictoryScreen →
	  WorldMap. No crashes.
- [ ] Defeat run: play until tower dies → DefeatScreen → retry → WorldMap.
	  No crashes.
- [ ] Draft picks: pick several cards across one run; synergy banners fire
	  correctly; no visual glitches.
- [ ] Pause menu: open/close mid-wave; enemies resume correctly; volume
	  sliders work; explicitly test pausing while a draft is also open
	  (the edge case flagged in Task 08-06).
- [ ] Tower Garage: upgrade to star 2; start a run; confirm higher HP/damage.
- [ ] Spell Codex: rank up one spell; confirm it shows improved damage in a
	  run.
- [ ] Save/load: kill the app mid-run (not mid-wave); reopen; confirm return
	  to WorldMap with previous tower star/materials intact.
- [ ] Performance: confirm frame rate holds steady during the heaviest wave
	  with multiple spells/VFX/shadows active simultaneously, on the actual
	  target device, not just the editor.
- [ ] No crashes in `adb logcat | grep -i godot` while playing a full run.
- [ ] Touch targets: every button responsive on first tap with a normal
	  adult finger.
- [ ] **3D-specific regression check**: confirm shadows render correctly on
	  the real device (not just in the editor) — mobile GPU shadow rendering
	  can behave differently than desktop preview; this is the final
	  confirmation that the entire 3D-rebuild premise holds up on target
	  hardware.
- [ ] Fix any remaining issues. Tag the git commit as `v0.1-internal`.
