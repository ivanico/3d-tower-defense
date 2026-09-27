# Remaining To-Do List — Road to Play Store Launch

> Snapshot of what's left to ship Tower's Last Stand (3D) on Google Play.
> Built from a read of every `.md` in the repo, with each "missing" item
> checked against the actual code/assets (2026-09-25).
> This is the **raw list** — it gets turned into epic/task docs once agreed.
> Items marked **(decide)** need a design decision before they can be built.

---

## ✅ Already done (for context)

- **Core**: real 3D, Mobile renderer, fixed ortho camera, component
  architecture, ObjectPool, EventBus, local save/load.
- **Combat**: tower auto-fire, damage pipeline, WC3-style armor table (all 5
  armor types in use), resistances, status effects (burn / slow / poison /
  lifesteal), hit flash, floating damage numbers, 3D HP bars on all units.
- **Spells**: all 20 (5 schools × 4 archetypes), stacking, school VFX/shaders,
  8 stat-upgrade cards, mono-school mastery bonus + HUD icon.
- **Draft**: first-spell draft, wave-clear + level-up drafts, rarity weights,
  slot cap, styled cards.
- **Content**: Chapter 1 — 12 waves, 5 enemies + 2 bosses, all modeled and
  animated. Frost + Void tower models (lvl1–5) already made. Chapter 2 enemy
  and boss models already made.
- **Meta**: World Map, Tower Garage (stars + 3D preview), Spell Codex (ranks),
  materials + rare material drops, energy (5 max, 20 min regen, offline
  catch-up).
- **UI**: widget library, UI image size-cap plugin, styled Victory/Defeat
  screens, pause button, fonts (Baloo 2, Nunito), loading on first launch.

---

## A. Content

- [ ] **A1. More towers** — Frost and Void models exist but have no
      `TowerDefinition`, passive, or gameplay scenes. The garage still shows
      5 `tower_locked_0N` placeholders.
- [ ] **A2. Tower unlock method** **(decide)** — how does the player get
      tower #2+? (materials / chapter reward / store)
- [ ] **A3. Chapter 2** — models exist in `assets/models/chap2/` (5 enemies,
      2 bosses), but no scenes, no enemy `.tres`, no `chapter_02.tres`, no
      arena colors.
- [ ] **A4. More chapters** **(decide how many at launch)** — each needs
      enemies, boss(es), arena.
- [ ] **A5. Chapter select** — `world_map_content.gd` has
      `CHAPTER_IDS = ["chapter_01"]` hardcoded; no carousel or way to switch.
- [ ] **A6. Chapter progression & locks** — beat chapter N to unlock N+1,
      save cleared chapters.
- [ ] **A7. Difficulty curve & balancing** across all chapters (known issue:
      short-range spells rarely fire because enemies die before getting close).
- [ ] **A8. Boss depth** — multi-phase bosses / boss intro (docs mark these
      [LATER]).
- [ ] **A9. Tower passives + star 3 / star 5 enhancements** — stars are
      currently pure stat bumps.
- [ ] **A10. Spell rank behaviors** — ranks currently only scale numbers; the
      richer "rank adds a behavior" version is [LATER] in the docs.
- [ ] **A11. Open spell design decisions** **(decide)** — stacking for AoE
      Area and Lances (currently one-pick), and whether to fill the 5 empty
      grid spells.
- [ ] **A12. Second material type per chapter** — docs plan it once a second
      chapter exists.
- [ ] **A13. Check enemy resistances** **(decide)** — every chapter-1 enemy and
      boss has `resisted_school = 4` (Nature), and Ancient Tower is the Nature
      tower. Intentional or a leftover default?

## B. Game Systems

- [ ] **B1. Store / shop screen** — nothing exists yet.
- [ ] **B2. Premium currency (gems)** — `MetaManager.premium_currency` exists
      but is unused.
- [ ] **B3. Chests + rewards screen** — all 16 chest/key/scroll icons are
      painted, nothing displays them.
- [ ] **B4. Daily rewards / login bonus** **(decide)** — maybe quests or
      achievements too.
- [ ] **B5. Energy** — regen countdown in the UI + energy refill (buy / ad).
- [ ] **B6. Pause menu** — resume, restart, back to map, volume sliders,
      Android back button (`ui_cancel` is not bound anywhere). Only the pause
      button exists today.
- [ ] **B7. Settings screen** — music, SFX, vibration, language, credits,
      privacy policy link.
- [ ] **B8. Tutorial / first-time experience** — nothing exists.
- [ ] **B9. Wave fallback timer warning** — a wave force-clears after
      `WAVE_DURATION_MAX` with no on-screen warning; reads like a bug.
- [ ] **B10. Dead code cleanup** **(decide)** — `starting_spell_id`, the
      synergy tag system (bookkeeping only now), `TowerDefinition.model_path`.
      Remove or keep?

## C. Monetization

- [ ] **C1. Google Play Billing** — IAP for gem packs, tower unlock packs,
      skins.
- [ ] **C2. Rewarded ads** (e.g. AdMob) — energy refill, double rewards,
      revive.
- [ ] **C3. Tower skins.**
- [ ] **C4. Battle pass** — docs say post-launch.
- [ ] **C5. Consent / privacy** — GDPR / UMP consent form, needed if ads ship.

## D. Art

- [ ] **D1. HP bar tween / color shift** (optional — skipped in 08-03).
- [ ] **D2. Store art** — gem packs, offers, ad button.
- [ ] **D3. App icon, feature graphic, Play Store screenshots.**

## E. Audio (Epic 07 — 0% done)

- [ ] **E1. Source all music + SFX** — `assets/audio/` is empty.
- [ ] **E2. AudioManager** — `audio_manager.gd` is still a stub (no playback,
      no crossfade).
- [ ] **E3. Audio buses** — Music / SFX + limiter / compressor.
- [ ] **E4. EventBus wiring** — combat, UI and music-change events.

## F. Tech / Performance / Release

- [ ] **F1. Android export** — no `export_presets.cfg` yet. Needs package
      name, signing keystore, **AAB** build (Play Store requires AAB, not APK).
- [ ] **F2. Target API level** — Play currently requires new apps to target
      API 35 (docs only set min SDK 24).
- [ ] **F3. Performance pass on a real device** (08-07) — shadows, draw calls,
      particle budget, memory leaks.
- [ ] **F4. Mobile input pass** (08-08) — touch target sizes, safe areas /
      notches, aspect ratios other than 1080×1920.
- [ ] **F5. Cloud save** (e.g. Google Play Games Services) — local save is
      plaintext and marked "temporary v1" in `project.md`.
- [ ] **F6. Save versioning / migration** — so updates don't wipe progress.
- [ ] **F7. Crash reporting + analytics.**
- [ ] **F8. Server-side purchase validation** — once IAP exists.
- [ ] **F9. Localization** **(decide)** — launch or post-launch?

## G. Play Store Listing & Compliance

- [ ] **G1.** Google Play Developer account ($25).
- [ ] **G2.** Privacy policy (hosted URL, mandatory).
- [ ] **G3.** Data Safety form + content rating questionnaire.
- [ ] **G4.** Store listing — title, descriptions, screenshots, feature
      graphic.
- [ ] **G5.** Closed testing — new personal accounts need **12 testers for
      14 days** before production release.
- [ ] **G6.** Final game name **(decide)** — "Tower's Last Stand" is the
      working title.

## H. Docs Cleanup

- [ ] **H1.** `components.md`, `mechanics.md`, `spells.md` §6.2 / §6.7 are stale
      in places — synergy tags, starting spell, enemy pooling, "resistances
      not used yet", missing HUD file.

---

## Removed from the list (not wanted / already done)

- Hit / death / level-up particle VFX — not wanted.
- Hit flash — already built (`hit_flash_component.gd`, material overlay).
- Tower idle animation on every level — deliberate, not all levels get one.
- Remaining UI art (tower ability icon, portraits, victory/defeat bg).
- Camera shake.

---
---

# OLD EPICS tasks not done yet

> Everything below was cut out of the old `epic_0N_*.md` files (now in
> `epic_done/`) and pasted here word for word, so you can compare it against
> the list above. Each item says which new-list entry it overlaps with.
> Every item was checked against the code before it went on this list (2026-09-27).
> Epics 01–05 had nothing left except one [LATER] note, because those epics
> are built. Their unticked boxes are just stale checkboxes, not open work.

## Still open


### epic_05 · Task 05-09 — energy regen countdown (one bullet)

**Overlap with new list:** **B5** (energy regen countdown in the UI). Confirmed: no countdown code exists.

- [ ] This is the only energy regen mechanism needed at v1 — no in-session
	  live-ticking energy regen UI countdown required yet (**[LATER]**,
	  polish-tier feature).


### epic_06 · Task 06-01 — shared toon/cel shader (one bullet)

**Overlap with new list:** **None** — the new list doesn't mention it. Confirmed: no toon/cel shader exists anywhere in the project.

- [ ] Apply the shared toon/cel shading approach from `assets.md` Section 1
	  consistently across all models, including the two from Epic 02 if they
	  don't already have it.


### epic_07 — Audio (whole epic, all 7 tasks)

**Overlap with new list:** **E1–E4** (all of section E). Confirmed: `assets/audio/` is empty, `audio_manager.gd` is still `pass` stubs, no bus layout file. Note: 07-03's `synergy_threshold_reached` → `sfx_synergy_unlock` line is obsolete (synergy bonuses were removed).

## Task 07-01 — Import All V1 Audio Files

**Ref**: `assets.md` Section 6

- [ ] Place all `.ogg`/`.wav` files listed in `assets.md` Section 6 into
      `res://assets/audio/` with exact filenames.
- [ ] Import settings — music (`.ogg`): Loop = true except
      `music_victory.ogg`/`music_defeat.ogg`. Compress = Vorbis.
- [ ] Import settings — SFX (`.wav`): Loop = false. Compress = IMA ADPCM
      (mobile performance).

**Acceptance criteria**:
- [ ] All files import with no errors in Godot's FileSystem panel.

---

## Task 07-02 — AudioManager Full Implementation

**File**: `res://autoloads/audio_manager.gd`

Replace the Epic 01 stub:

- [ ] Vars: `_sfx_pool: Array[AudioStreamPlayer]` (8 pooled players — smaller
      pool than the original design's 12, matching v1's smaller SFX
      vocabulary; bump this later if profiling shows pool exhaustion),
      `_music_player_a`, `_music_player_b`, `_active_music_player`,
      `_music_volume_db`, `_sfx_volume_db`, `_current_track`,
      `_preloaded_sfx: Dictionary`.
- [ ] `_ready()`: create the two music crossfade players (bus "Music"), the
      8 SFX players (bus "SFX"), preload every SFX from `assets.md` Section
      6 into `_preloaded_sfx`, connect `EventBus` signals (Task 07-03).
- [ ] `play_sfx(filename, pitch_scale = 1.0)`: get an idle pooled player, set
      stream/pitch/volume, play. If all 8 are busy, skip (no queueing at
      v1 — that's a **[LATER]** refinement if profiling shows it's needed).
- [ ] `play_music(stream, crossfade_time = 1.0)`: same crossfade pattern as
      the original design — set inactive player's stream, tween volumes,
      swap active player on completion.
- [ ] `stop_music(fade_time = 1.0)`, `set_music_volume(linear)`,
      `set_sfx_volume(linear)` (values persist via `MetaManager.SaveData`,
      already has the fields from Epic 05 Task 05-01).

**Acceptance criteria**:
- [ ] Calling `play_sfx("sfx_proj_bolt.wav")` 10 times rapidly never errors
      and correctly skips playback once all 8 pool players are busy
      simultaneously (verify by checking no more than 8 concurrent SFX play).
- [ ] `play_music()` crossfades smoothly between two tracks with no audible
      pop/gap.

---

## Task 07-03 — Wire Combat & Wave SFX via EventBus

**File**: `res://autoloads/audio_manager.gd`

- [ ] `EventBus.wave_started` → (no dedicated SFX in the v1 list — skip;
      do not invent one not listed in `assets.md`).
- [ ] `EventBus.boss_spawned` → `play_sfx("sfx_boss_spawn.wav")`, crossfade
      music — stays on `music_wave.ogg` at v1 (no separate boss track in the
      v1 asset list; that split is **[LATER]**).
- [ ] `EventBus.level_up` → `play_sfx("sfx_level_up.wav")`.
- [ ] `EventBus.synergy_threshold_reached` → `play_sfx("sfx_synergy_unlock.wav")`.
- [ ] `EventBus.tower_damaged` → `play_sfx("sfx_tower_hit.wav")`.
- [ ] `EventBus.draft_opened` → `play_sfx("sfx_draft_card_select.wav")`
      is wrong here — correct this to: no open-specific SFX in the v1 list,
      crossfade to `music_draft.ogg`.
- [ ] `EventBus.card_selected` → `play_sfx("sfx_draft_card_select.wav")`.
- [ ] `EventBus.draft_closed` → crossfade back to `music_wave.ogg`.
- [ ] `EventBus.run_ended(victory)` → play `music_victory.ogg` or
      `music_defeat.ogg` (one-shot, no loop).

**Acceptance criteria**:
- [ ] Every signal listed above triggers its correct SFX/music change during
      a live playtest, verified by ear, one event at a time.

---

## Task 07-04 — Wire Projectile/AoE/Enemy SFX

**File**: `res://scenes/game_object/projectile/projectile.tscn`/`projectile.gd`,
`res://scenes/game_object/aoe_zone/aoe_zone.tscn`/`aoe_zone.gd`,
`res://scenes/component/hurtbox_component.gd`,
`res://scenes/component/death_fx_component.gd`

- [ ] Projectile fire → `AudioManager.play_sfx("sfx_proj_bolt.wav",
      randf_range(0.9, 1.1))` (pitch variance to avoid repetitiveness).
- [ ] AoE impact → `AudioManager.play_sfx("sfx_aoe_impact.wav")`.
- [ ] `HurtboxComponent` on taking damage →
      `AudioManager.play_sfx("sfx_enemy_hit.wav", randf_range(0.85, 1.15))`
      — only for non-tower hurtboxes (the tower uses `sfx_tower_hit.wav`,
      already wired in Task 07-03).
- [ ] `DeathFXComponent` on death → `AudioManager.play_sfx(
      "sfx_enemy_death.wav")`.

**Acceptance criteria**:
- [ ] Every projectile fire, AoE impact, enemy hit, and enemy death produces
      its correct sound with audible pitch variance on repeated hits (not
      identical-sounding every time).

---

## Task 07-05 — UI SFX

**File**: `res://scenes/ui/world_map.gd`, `tower_garage.gd`,
`spell_codex.gd`, `draft_card.gd`

- [ ] Every `Button.pressed` across WorldMap/Garage/Codex →
      `AudioManager.play_sfx("sfx_ui_button.wav")`.
- [ ] Confirm `sfx_draft_card_select.wav` (wired in Task 07-03 via
      `card_selected`) is not double-triggered by also wiring a generic
      button-press SFX on the same card tap — pick one signal source per
      action, don't stack two SFX on the same tap.

**Acceptance criteria**:
- [ ] Every button across the meta screens produces exactly one SFX per tap
      (verify no doubled/overlapping sounds on the draft card specifically).

---

## Task 07-06 — Audio Bus Setup

- [ ] Project > Audio > Buses: create `"Music"` and `"SFX"` buses as children
      of `Master`.
- [ ] `Master` bus at 0 dB. `Music`/`SFX` at 0 dB by default (adjustable via
      the volume sliders built in Epic 05/08).
- [ ] Add `AudioEffectLimiter` to `Master` to prevent clipping.
- [ ] Add a gentle `AudioEffectCompressor` to `SFX` (threshold -12,
      ratio 3:1).
- [ ] Do not add reverb/delay — mobile performance cost not worth it at this
      scale.

**Acceptance criteria**:
- [ ] Rapid simultaneous hits (e.g. an AoE hitting 5 enemies at once) do not
      produce audible clipping/distortion.

---

## Task 07-07 — Integration Test

- [ ] Run the project. Verify:
  - Tower fires with a bolt SFX, slight pitch variance audible across
    repeated shots.
  - AoE impact plays its SFX.
  - Enemies play hit/death SFX correctly.
  - Boss entrance plays its spawn SFX.
  - Draft opening crossfades to calm draft music; card pick plays its SFX;
    combat music resumes on close.
  - Level-up and synergy-unlock chimes play correctly and distinctly from
    each other.
  - UI buttons across meta screens all play a click sound, exactly once per
    tap.
  - Victory/defeat screens play their respective one-shot stingers, no
    looping.
- [ ] Confirm the 8-player SFX pool never silently breaks under rapid-kill
      stress (many enemies dying within ~1 second) — some SFX skipping under
      extreme load is acceptable per Task 07-02's design, but nothing should
      error.
- [ ] Adjust relative volumes so SFX are never louder than music and nothing
      is uncomfortably loud on a phone speaker test if available.
- [ ] Fix all audio issues before moving to Epic 08.


### epic_08 · header note — wave fallback timer warning

**Overlap with new list:** **B9** (wave fallback timer warning). Confirmed: no warning/countdown UI exists; `WAVE_DURATION_MAX` is now 60s, not the 30s written here.

> **Deferred from Epic 04**: `WaveManager`'s fallback timer
> (`Constants.WAVE_DURATION_MAX`) silently force-clears a stalled wave with
> no player-facing indication it's about to happen — confirmed during Epic
> 04 testing that this reads as confusing (wave clears with enemies still
> on-screen, no XP for them, no warning beforehand). Add some visual cue —
> a small countdown timer/HUD element, or a warning flash in the last few
> seconds — so the fallback feels intentional rather than like a bug. Small
> addition, pairs naturally with this epic's other HUD/UI polish tasks.


### epic_08 · Task 08-03 — HP bar color shift + tween (two bullets)

**Overlap with new list:** **D1** (HP bar tween / color shift).

- [ ] ~~Fill color: green >50%, yellow 25–50%, red <25%.~~ **Not built** —
	  the reference art this session worked from uses a fixed red fill
	  regardless of HP%, not a threshold-based color shift. Revisit if a
	  color-shift look is wanted later; `Bar3DStyle`/`value_bar_3d.gd` would
	  need a new `set_value()`-driven color lerp, not currently there.
- [ ] ~~Tween fill width smoothly on damage (0.15s).~~ **Not built** — the
	  fill snaps instantly (`_refresh()` sets `region_rect` directly, no
	  tween). Would be a small, self-contained addition if wanted.


### epic_08 · Task 08-04 — Targeting Indicator (3D)

**Overlap with new list:** **None** — the new list doesn't mention it. Confirmed: no targeting line exists in code.

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



### epic_08 · Task 08-06 — Pause Menu

**Overlap with new list:** **B6** (pause menu) + the volume sliders part overlaps **B7** (settings). Confirmed: no PauseMenu scene, `ui_cancel` bound nowhere.

## Task 08-06 — Pause Menu

**File**: `res://scenes/ui/PauseMenu.tscn`

> **Partly done.** The in-run pause *button* exists
> (`scenes/ui/widget/pause_button/`, instanced in the HUD, wired in
> `hud.gd:_on_pause_pressed`) and toggles `get_tree().paused` while the phase is
> WAVE. The pre-existing bug where any `ui_accept` while paused wiped the run is
> fixed — `game_world.gd:_unhandled_input` now restarts only once `run_is_over()`.
> Still open: the menu itself, and the `ui_cancel` / Android back button binding.
> See "Who is allowed to pause" in components.md §7 before adding a fifth writer
> of `get_tree().paused`.

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



### epic_08 · Task 08-07 — Performance Pass (3D-Specific)

**Overlap with new list:** **F3** (performance pass on a real device). Partly started: the particle budget (`CombatUtils.try_reserve_particles`, cap 150) already exists.

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



### epic_08 · Task 08-08 — Input Tuning for Mobile

**Overlap with new list:** **F4** (mobile input pass). The draft-card bullet is already done (ticked).

## Task 08-08 — Input Tuning for Mobile

**File**: Various UI scripts

- [ ] All `Button`/tappable UI: `minimum_size` at least `Vector2(80, 80)`.
- [x] Draft cards: full-card tap area (not just a small button), per Epic
	  03's existing implementation — confirm here as a check, not a rebuild.
	  Confirmed: `draft_card.gd`'s root is the `Button` itself (no separate
	  select button), tap anywhere on the card selects it.
- [ ] Disable mouse-hover-only states (no mobile hover).
- [ ] Test on a 1080×1920 device/emulator: confirm no UI clipping.
- [ ] Audit for `Input.is_action_pressed()` calls that should be
	  `just_pressed()` for single-frame actions (e.g. pause toggle).

**Acceptance criteria**:
- [ ] Every tappable UI element responds correctly to a single normal-finger
	  tap on a real or emulated touchscreen, with no clipped elements at
	  1080×1920.



### epic_08 · Task 08-09 — Android Export Setup

**Overlap with new list:** **F1** (Android export — new list says **AAB**, this says APK), **F2** (target API — this says min SDK 24 only), **D3** (app icon). Confirmed: no `export_presets.cfg`.

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



### epic_08 · Task 08-10 — Final Integration Test (Device)

**Overlap with new list:** **F3** (real-device pass), **G5** (closed testing). The pause-menu and synergy-banner checks inside it depend on B6 / obsolete synergy. The last line's git tag is yours to do.

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


## Decided against / obsolete (kept here so you can see them)


### epic_06 · Task 06-02 — Wire Models Into Definitions

**Overlap with new list:** **B10** (dead code: `model_path`). Moot — `model_path` is read by no code; models are embedded in each enemy `.tscn` / tower `star_level_scenes` instead.

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



### epic_06 · Task 06-06 — VFX Particle Systems (3D)

**Overlap with new list:** New list → **Removed: "Hit / death / level-up particle VFX — not wanted."**

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



### epic_06 · Task 06-09 — Integration Test

**Overlap with new list:** Nothing open left in it: every check is either done (no placeholder meshes, walk/attack anims, boss heavy attack, draft icons) or decided against (tower attack anim, hit sparks/death bursts/level-up rings, 06-04 lighting).

## Task 06-09 — Integration Test

- [ ] Run the project. Confirm zero `CapsuleMesh`/`BoxMesh`/`PlaneMesh`
	  placeholders remain on any gameplay object (UI `ColorRect`s used for
	  non-gameplay backgrounds where no real asset applies are fine to flag
	  separately, but every character/tower placeholder must be gone). The
	  arena's `PlaneMesh` (`chap1_arena.tscn`) is an intentional permanent
	  exception per Task 06-05 and does not count as a remaining placeholder.
- [ ] All enemy animations play correctly: `walk` → `attack` → `death`,
	  with correct facing-direction rotation throughout.
- [ ] Tower plays `attack` synced to firing, returns to `idle`.
- [ ] Boss plays its distinct heavy-attack animation on schedule.
- [ ] Hit sparks, death bursts, and level-up rings all play correctly and
	  clean themselves up.
- [ ] Shadows and lighting read correctly on the real models from multiple
	  camera-distance test positions (re-verify Task 06-04's tuning didn't
	  regress after the arena swap in Task 06-05).
- [x] Draft cards show correct spell/upgrade icons and rarity borders.
- [ ] Fix all visual glitches before moving to Epic 07.


### epic_08 · Task 08-02 — Synergy Banner Polish

**Overlap with new list:** Obsolete — synergy bonuses/banner were removed (project.md). The leftover banner files overlap **B10** (synergy tag cleanup).

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



### epic_08 · Task 08-05 — Camera Shake on Boss Hit

**Overlap with new list:** New list → **Removed: "Camera shake."**

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


