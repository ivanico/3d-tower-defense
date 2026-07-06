# Epic 05 — Meta Layer

> Prerequisite: Epic 04 complete and all its acceptance criteria verified.
> Goal: World map, tower garage, spell codex, real save/load, energy gating.
> The full meta loop closes: play a run → earn materials → spend them →
> play again, with persistence across app restarts.
> **v1 scope**: 1 tower (no garage "collection," just one upgrade-able tower),
> 3 spells in the codex, 1 chapter on the map. The screens are built to the
> full intended shape (grid of towers, list of spells, chapter nodes) even
> though v1's data is small — see `project.md` "V1 Scope vs. Future Scope."
> Completed epic delivers: the full game loop works end-to-end, persists
> between sessions.

---

## Task 05-01 — SaveData Resource

**File**: `res://scripts/save_data.gd`
**Ref**: `mechanics.md` Section 11

- [ ] Create `SaveData.gd` extending `Resource`, `class_name SaveData`.
- [ ] Fields: `owned_towers: Array[String]`, `tower_stars: Dictionary[String,
      int]`, `spell_ranks: Dictionary[String, int]`, `materials: int`,
      `energy: int`, `last_energy_timestamp: int` (Unix time, for offline
      regen calculation), `music_volume: float`, `sfx_volume: float`.

**Acceptance criteria**:
- [ ] A `SaveData` instance can be created, populated, saved via
      `ResourceSaver.save()` to `user://savegame.tres`, and reloaded via
      `load()` with all fields intact.

---

## Task 05-02 — MetaManager Full Implementation

**File**: `res://autoloads/meta_manager.gd`
**Ref**: `components.md` Section 3

- [ ] Replace the Epic 01 stub:
  - `save()`: populate a `SaveData` instance from current `MetaManager`
    state, `ResourceSaver.save()` to `user://savegame.tres`.
  - `load()`: if the file exists, `load()` it and apply fields to
    `MetaManager`'s in-memory state; if not, initialize defaults (1 owned
    tower — `"ancient_tower"` — energy 5, materials 0).
  - `restore_energy(amount)`: on `load()`, also compute offline energy
    regen from `last_energy_timestamp` vs current time (one energy per
    fixed regen interval — pick a value, e.g. 20 minutes per energy, tune
    later) and apply before exposing `energy` to the rest of the game.
  - `spend_energy() -> bool` (already built Epic 01 — confirm it now also
    calls `save()` after decrementing, so energy spend persists immediately
    rather than only on app close).
  - `award_materials(amount)`: add to `materials`, call `save()`, emit
    `EventBus.materials_earned(amount)`.
  - `upgrade_tower_star(tower_id) -> bool`: check material cost (see Task
    05-05), deduct, increment `tower_stars[tower_id]`, save, emit
    `EventBus.tower_upgraded`.
  - `upgrade_spell_rank(spell_id) -> bool`: same shape for spell ranks.
- [ ] Call `MetaManager.load()` once at game startup (e.g. from a splash/boot
      step, or directly in `MetaManager._ready()` — either is fine for this
      scope).

**Acceptance criteria**:
- [ ] Closing and reopening the project (or calling `save()` then `load()` in
      a test) preserves `materials`, `energy`, `tower_stars`, `spell_ranks`
      correctly.
- [ ] `spend_energy()` immediately persists the new energy value (verify by
      saving, then loading into a fresh `MetaManager` state and checking the
      value matches).

---

## Task 05-03 — Tower Stars Apply to Stats

**File**: `res://scenes/game_object/tower/tower.tscn`/`tower.gd`,
`res://autoloads/game_state.gd`
**Ref**: `mechanics.md` Section 11

- [ ] In `GameState.start_run(tower_def)`, after applying base stats, apply a
      star-level stat bonus: read `MetaManager.tower_stars.get(tower_def.
      tower_id, 1)`, apply `Constants.STAR_STAT_BONUS_PER_LEVEL` (already
      defined in `Constants.gd` per `components.md` Section 2 — do not
      re-type the percentage here, read the constant) as a flat bump per
      star above 1 to both HP and damage.
- [ ] Confirm star 3/star 5 passive-enhancement **hooks** exist (per
      `mechanics.md` Section 11, the actual enhanced-passive *behavior* is
      **[LATER]** — v1 only needs the stat-bump math to read the correct star
      level; do not build a passive-enhancement system this epic).

**Acceptance criteria**:
- [ ] Manually setting `tower_stars["ancient_tower"] = 3` and starting a run shows
      a tower with measurably higher base HP/damage than star 1, matching
      the formula exactly (verify the math, not just "it went up").

---

## Task 05-04 — Spell Ranks Apply to Stats

**File**: `res://autoloads/spell_registry.gd` or `res://autoloads/game_state.gd`
**Ref**: `mechanics.md` Section 11

- [ ] When a spell is added to the tower's active list (Epic 03's
      `add_spell()`), look up `MetaManager.spell_ranks.get(spell.spell_id, 1)`
      and apply `Constants.SPELL_RANK_DAMAGE_BONUS_PER_LEVEL` (already
      defined in `Constants.gd` per `components.md` Section 2) as a flat
      damage scaling per rank above 1; cooldown unaffected at v1.
      Do this as a runtime multiplier applied when the spell is fired, not by
      mutating the shared `.tres` resource (mutating a shared `Resource` at
      runtime would corrupt it for every future load — this is a common
      Godot footgun, explicitly avoid it).

**Acceptance criteria**:
- [ ] Ranking up a spell to rank 3 and starting a new run shows that spell
      dealing measurably more damage than rank 1, with the *resource file
      on disk* unchanged (confirm by reloading the `.tres` and checking its
      base `damage` field is untouched).

---

## Task 05-05 — Tower Garage Scene

**File**: `res://scenes/ui/tower_garage.tscn`

- [ ] Create `tower_garage.tscn`: a grid/list of owned towers (v1: just the
      one), each showing current star level, star rating (filled/empty star
      icons — placeholders fine), and an "Upgrade" button showing the
      material cost for the next star.
- [ ] Define a simple cost curve in `Constants.gd` or a small lookup
      (`TOWER_STAR_COSTS: Array[int] = [0, 100, 250, 500, 1000]` — index by
      current star level to get next-star cost).
- [ ] `tower_garage.gd`: on "Upgrade" tap, call
      `MetaManager.upgrade_tower_star(tower_id)`, refresh display, play
      `sfx_upgrade_confirm` stub (real audio Epic 07).
- [ ] Allow selecting which owned tower to bring into a run (v1: trivial
      since there's only one, but build the actual selection UI/state now so
      adding tower #2 later doesn't require new screen logic).

**Acceptance criteria**:
- [ ] Garage screen correctly shows current star level and the right next-
      star material cost.
- [ ] Upgrading deducts the correct material amount and persists (verify via
      `MetaManager.materials` and a save/reload).
- [ ] Attempting to upgrade with insufficient materials is blocked (button
      disabled or upgrade call returns `false` with no deduction).

---

## Task 05-06 — Spell Codex Scene

**File**: `res://scenes/ui/spell_codex.tscn`

- [ ] Create `spell_codex.tscn`: a list of all spells from
      `SpellRegistry.all_spells` (v1: 3 entries), each showing current rank
      and the next rank's cost.
- [ ] Define `SPELL_RANK_COSTS` similarly to tower star costs.
- [ ] `spell_codex.gd`: on rank-up tap, call
      `MetaManager.upgrade_spell_rank(spell_id)`, refresh.

**Acceptance criteria**:
- [ ] Codex correctly lists all 3 v1 spells with correct current rank and
      cost.
- [ ] Ranking up persists correctly across save/reload.

---

## Task 05-07 — World Map Scene

**File**: `res://scenes/ui/world_map.tscn`

- [ ] Create `world_map.tscn`: v1 shows one chapter node (`chapter_01`),
      tappable to start a run (spends 1 energy via
      `MetaManager.spend_energy()` — if it returns `false`, show an
      "Out of energy" message instead of starting). Include buttons/nav to
      `tower_garage.tscn` and `spell_codex.tscn`.
- [ ] Build the chapter-node-grid layout to accommodate more chapters later
      (a `HBoxContainer`/`GridContainer` of node buttons, not a single
      hardcoded button) even though only one node exists at v1.
- [ ] On tapping the chapter node (with energy available): load
      `game_world.tscn`, passing/setting which `ChapterDefinition` and which
      `TowerDefinition` (from garage selection) to use for the run.

**Acceptance criteria**:
- [ ] WorldMap correctly blocks a run start at 0 energy and allows it
      otherwise, decrementing energy by exactly 1 per run start.
- [ ] Starting a run correctly loads `game_world.tscn` configured for
      `chapter_01` and the selected tower.

---

## Task 05-08 — Wire Victory/Defeat Back to World Map

**File**: `res://scenes/ui/victory_screen.gd`,
`res://scenes/ui/defeat_screen.gd`

- [ ] Replace Epic 04's stub navigation: both screens' "Return to Map"/"Map"
      buttons now call `get_tree().change_scene_to_file(
      "res://scenes/ui/world_map.tscn")`.
- [ ] On Victory: call `MetaManager.award_materials(amount)` with a real
      formula now (e.g. base amount + bonus for boss kill — a simple tunable
      formula, not the original design's full Chapter/Universal material
      split, which is **[LATER]** per `mechanics.md` Section 11).

**Acceptance criteria**:
- [ ] Winning a run correctly awards materials (verify the exact amount
      matches the formula), then returns to WorldMap with the updated
      material total visible.
- [ ] Losing a run returns to WorldMap with no materials awarded (or a
      smaller consolation amount if you choose to add one — either is
      acceptable, just confirm the actual implemented behavior matches what
      you intended, since this is a design choice not pinned by mechanics.md).

---

## Task 05-09 — Daily Energy Regen (Background)

**File**: `res://autoloads/meta_manager.gd`
**Ref**: `mechanics.md` Section 11

- [ ] On `load()` (app start), compute elapsed time since
      `last_energy_timestamp`, grant `floor(elapsed / regen_interval)`
      energy capped at `Constants.MAX_ENERGY`, update the timestamp.
- [ ] This is the only energy regen mechanism needed at v1 — no in-session
      live-ticking energy regen UI countdown required yet (**[LATER]**,
      polish-tier feature).

**Acceptance criteria**:
- [ ] Manually setting `last_energy_timestamp` to several hours in the past,
      then reloading, grants the correct number of energy points, capped at
      max.

---

## Task 05-10 — Integration Test

- [ ] Fresh save (delete `user://savegame.tres` or equivalent): launch
      shows WorldMap with default state (1 energy run available × 5,
      0 materials, tower at star 1).
- [ ] Start a run, win it. Verify materials awarded, energy decremented by 1,
      returned to WorldMap.
- [ ] Open Tower Garage, upgrade the tower to star 2 (assuming enough
      materials — play multiple runs if needed). Start a new run, verify
      the tower has star-2 stats.
- [ ] Open Spell Codex, rank up one spell. Start a run, draft that spell,
      verify it deals rank-scaled damage.
- [ ] Close and reopen the project (simulate app restart). Verify materials,
      tower star, spell rank, and energy all persisted correctly.
- [ ] Run out of energy (5 runs without waiting). Verify WorldMap blocks a
      6th run start with a clear message.
- [ ] Fix all errors before moving to Epic 06.
