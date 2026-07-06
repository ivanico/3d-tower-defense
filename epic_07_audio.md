# Epic 07 — Audio

> Prerequisite: Epic 06 complete and tested.
> Goal: Every combat event, UI action, and scene transition has the correct
> sound effect. Music plays and crossfades between states. AudioManager
> handles all playback. Scope matches the v1 asset list in `assets.md`
> Section 6 — this epic does not invent new SFX categories beyond what's
> listed there; expanding SFX coverage (per-damage-type variants, per-enemy
> death sounds, etc.) is explicitly **[LATER]** per `assets.md`'s extend
> note.
> Completed epic delivers: the game sounds finished, no silent core actions.

---

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
