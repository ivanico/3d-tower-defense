# Epic 08 — Polish, Performance & Export

> Prerequisite: Epics 01–07 complete and tested. The game must be fully
> playable with art and audio before this epic.
> Goal: Damage numbers, synergy banner polish, performance optimizations
> specific to real-time 3D on mobile (shadow cost, draw calls, particle
> budget), and a shippable Android APK.
> Completed epic delivers: a game ready for internal testing on a real
> Android device, running at a stable frame rate with real shadows.

> ⤷ **Not done — moved to `remaining_to_do_list.md` ("OLD EPICS tasks not done yet").**

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
> ⤷ **Not done — moved to `remaining_to_do_list.md` ("OLD EPICS tasks not done yet").**
---

## Task 08-03 — Enemy HP Bar Polish (3D) [DONE, with two deviations from the original spec below]

**Files**: every `res://scenes/game_object/chap1/chap1_enemy_0*/`,
`chap1_boss_0*/`, `res://scenes/ui/widget/value_bar_3d/`,
`res://resources/ui/*.tres`

> **The widget already existed and was reused, not duplicated** —
> `scenes/ui/widget/value_bar_3d/` (renamed from `health_bar_3d/` as part of
> this task, since it was never actually health-specific) was built for the
> tower during the HUD pass and is deliberately generic. Every chapter-1
> enemy/boss now instances it, `follow_game_state = false`, and it
> auto-discovers its own sibling `HealthComponent` and wires itself — no
> per-unit script needed (same discovery pattern `hit_flash_component.gd`
> uses). The shared red/translucent look lives in two `Bar3DStyle` Resources
> (`resources/ui/enemy_bar_style.tres`, `boss_bar_style.tres`) instead of
> being copy-pasted into every scene — see `value_bar_3d.gd`'s doc comment
> for the full design, including the number-outline debugging history (MSDF
> font requirement, why native `outline_size` can't be used, why the outline
> copies must offset along the camera's true screen-perpendicular plane and
> not naive world axes).

- [x] Billboarded bar above each enemy/boss's head, height tuned per model.
> ⤷ **Not done — moved to `remaining_to_do_list.md` ("OLD EPICS tasks not done yet").**
- [x] **Boss, deliberately DIFFERENT from the original spec**: bosses use the
	  SAME 3D billboard system as regular enemies (a larger `Bar3DStyle`
	  preset), not a separate always-visible 2D HUD `ProgressBar`. This was a
	  session decision matching the actual reference art (which shows every
	  unit, boss included, with an in-world floating bar) rather than the
	  original guess that a boss might be too large to frame reliably.

**Acceptance criteria**:
- [x] Regular enemy HP bars correctly billboard toward the camera and show
	  the correct fill at all HP levels (colour is fixed red, not
	  threshold-based — see deviation above).
- [x] Boss HP bar updates correctly on every hit (as a 3D billboard, not a
	  HUD screen-space element — see deviation above).

---

## Task 08-04 — Targeting Indicator (3D)
> ⤷ **Not done — moved to `remaining_to_do_list.md` ("OLD EPICS tasks not done yet").**
---

## Task 08-05 — Camera Shake on Boss Hit
> ⤷ **Not done — moved to `remaining_to_do_list.md` ("OLD EPICS tasks not done yet").**
---

## Task 08-06 — Pause Menu
> ⤷ **Not done — moved to `remaining_to_do_list.md` ("OLD EPICS tasks not done yet").**
---

## Task 08-07 — Performance Pass (3D-Specific)
> ⤷ **Not done — moved to `remaining_to_do_list.md` ("OLD EPICS tasks not done yet").**
---

## Task 08-08 — Input Tuning for Mobile
> ⤷ **Not done — moved to `remaining_to_do_list.md` ("OLD EPICS tasks not done yet").**
---

## Task 08-09 — Android Export Setup
> ⤷ **Not done — moved to `remaining_to_do_list.md` ("OLD EPICS tasks not done yet").**
---

## Task 08-10 — Final Integration Test (Device)
> ⤷ **Not done — moved to `remaining_to_do_list.md` ("OLD EPICS tasks not done yet").**
