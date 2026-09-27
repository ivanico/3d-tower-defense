# Epic 11 — Audio

> Prerequisite: none strictly, but it's easiest after Epic 10, because the
> screens that make sounds (store, chests, pause, settings) exist by then.
> Every task here works with **zero real sound files**.
> **Rules**: see `epic_09_content.md` → "Rules for Epics 09–13".
> **Skill**: `skills/godot3d-vfx-audio/SKILL.md` (reactive AudioManager, small
> SFX pool that skips instead of queueing, `EventBus` over direct calls).
> Base asset list: `assets.md` §6.
> Source: `remaining_to_do_list.md` section **E** (confirmed: `assets/audio/` is
> empty, `audio_manager.gd` is `pass` stubs, no bus layout file).
> Completed epic delivers: the game plays music and SFX for every event, with
> working volume sliders. Any sound not delivered yet is silent, not broken.

---

## Task 11-00 — Sound List & Placeholder Policy

**Covers**: E1 (planning half)

- [ ] One list of every sound the game needs, in this task. Start from
      `assets.md` §6, then add what Epics 09–10 introduced: store purchase,
      chest open, reward popup, daily claim, pause open/close, tutorial step,
      wave-timeout warning tick, and boss phase change.
      - Drop `sfx_synergy_unlock` (synergy bonuses were removed).
      - Ask before adding any others.
- [ ] Each entry: filename (existing `sfx_*` / `music_*` naming), bus, loop
      yes/no, and which event plays it.
- [ ] **Placeholder policy**: `AudioManager` resolves sounds by name. A
      missing file logs **once** and plays nothing, so every later task can
      be finished and tested before the sound exists.

**Placeholders**: every sound starts missing → final `assets/audio/<name>.ogg|.wav`
(also listed in `ui_assets.md` "STILL TO MAKE", or a new "Audio" section there).
**Preview**: the list itself; the audible preview is 11-05.

**Acceptance criteria**:
- [ ] You approve the list before 11-03 wires anything.

---

## Task 11-01 — Audio Buses

**Covers**: E3

- [ ] `default_bus_layout.tres`: `Master` with a limiter, and `Music` + `SFX`
      as its children. `SFX` gets a gentle compressor. No reverb or delay
      (mobile cost).
- [ ] Bus names in `Constants` so no script types a bus string.

**Placeholders**: none · **Preview**: Godot's Audio bottom panel shows the three
buses.

**Acceptance criteria**:
- [ ] The layout loads on project start with the three buses and their
      effects.

---

## Task 11-02 — AudioManager

**Covers**: E2 · **File**: `autoloads/audio_manager.gd`

- [ ] SFX pool (size in `Constants`). A busy pool **skips** instead of
      queueing (skill). Supports a pitch-variance parameter.
- [ ] Music on two players with a crossfade. It ignores a request for the
      track that's already playing.
- [ ] Sounds are loaded by name from `assets/audio/`, with the 11-00
      missing-file policy.
- [ ] `set_music_volume(linear)` / `set_sfx_volume(linear)`: convert to dB
      on the buses and save through `MetaManager` (fields already exist).
      Applied on startup.
- [ ] Mute or duck when the app loses focus or goes to the background; resume
      on return.
- [ ] Keep it under the ~150-line rule; split out a small helper if it grows.

**Placeholders**: none new · **Preview**: 11-05.

**Acceptance criteria**:
- [ ] With no files present: no errors, just one log line per missing sound.
      With a test file present: it plays on the right bus.

---

## Task 11-03 — EventBus Wiring

**Covers**: E4

- [ ] **Combat / run**: `AudioManager` subscribes to the existing `EventBus`
      signals and the ones added in Epics 09–10:
      - wave start, boss spawned
      - level up, card selected
      - tower damaged, enemy died
      - run ended (victory / defeat), wave-time warning
- [ ] **Per-cast / per-hit sounds** that need exact timing and pitch variance
      (spell fire, enemy hit) may call `AudioManager.play_sfx()` from the
      **one** shared place, per the skill:
      - spell fire → `tower.gd`'s cast path
      - enemy hit → `HurtboxComponent.apply_hit()`

      Never from each archetype script separately.
- [ ] **UI**: button clicks come from the shared button widgets
      (`primary_button`, `secondary_button`, `shadow_button`, `nav_button`,
      `home_side_button`), wired once each, not per screen. The draft card
      plays only its card-select sound, not a click on top of it.
- [ ] **Music**: home, in-run, draft (or keep the run music, your call in
      11-00), victory and defeat stingers.

**Placeholders**: none new · **Preview**: 11-05, plus an in-game run.

**Acceptance criteria**:
- [ ] Every row of the 11-00 list is triggered by its event. Exactly one
      sound per tap on every button.

---

## Task 11-04 — Volume Controls Hookup

**Covers**: E4 (settings side)

- [ ] The `volume_slider_row` from 10-08 / 10-09 calls the 11-02 setters.
      Moving a slider changes the volume live, and the value survives a
      restart.

**Placeholders**: none · **Preview**: `settings_content.tscn`, `pause_menu.tscn`.

**Acceptance criteria**:
- [ ] Sliders at 0 = silent bus; at max = full. Persisted.

---

## Task 11-05 — Audio Preview Scene

- [ ] `scenes/ui/audio_preview.tscn`: a dev-only screen listing every sound
      from 11-00. Each row has a play button and shows file present /
      missing. It's the "preview" for audio (rule 2): open it, press F6, and
      hear everything, including the music crossfade between two tracks.
- [ ] Not reachable from the shipped game's UI.

**Placeholders**: none · **Preview**: this is the preview.

**Acceptance criteria**:
- [ ] Every listed sound plays from this scene or shows as "missing".

---

## Task 11-06 — Source the Real Sounds

**Covers**: E1 (asset half)

- [ ] Fill `assets/audio/` from the 11-00 list. Sources are in `assets.md` §7
      (freesound CC0, incompetech). Keep a `CREDITS` entry for anything that
      needs attribution; it goes into the 10-09 credits page.
- [ ] Import settings: music Vorbis, looping except the stingers; SFX without
      a loop, compressed for mobile.
- [ ] Balance levels: SFX never louder than music, and nothing harsh on a
      phone speaker.

**Placeholders**: this task removes them · **Preview**: 11-05 shows every row
as "present".

**Acceptance criteria**:
- [ ] No sound in the list is missing. Credits are complete.

---

## Task 11-07 — Integration Test

- [ ] Full run + every meta screen with sound on: every event has its sound,
      no doubles, no clipping in a big AoE hit, and the music crossfades
      cleanly.
- [ ] Backgrounding the app (on device, in 13-04) silences audio, and it
      resumes on return.
