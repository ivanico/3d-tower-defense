# Epic 04 — Waves

> Prerequisite: Epic 03 complete and all its acceptance criteria verified.
> Goal: All v1 enemy types spawn correctly, wave-to-wave scaling applies,
> a chapter boss exists and is fightable, win/lose screens work end-to-end.
> **v1 scope: 2 regular enemy types + 1 boss, 1 chapter** — see
> `mechanics.md` Section 3 for the exact roster
> (`chap1_enemy_01`, `chap1_enemy_02`, `chap1_boss_01`).
> Completed epic delivers: a complete run, start to finish, win or lose.

---

## Task 04-01 — Second Enemy Definition

**File**: `res://resources/enemies/chap1_enemy_02.tres`
**Ref**: `mechanics.md` Section 3

- [ ] Create `chap1_enemy_02.tres`: `enemy_id="chap1_enemy_02"`,
      `model_path=""` (placeholder still — real model Epic 06),
      `base_hp=60`, `base_speed=2.6` (faster than `chap1_enemy_01`'s 1.5),
      `base_damage=6` (lower), `attack_cooldown=0.8`,
      `armor_type=Constants.ArmorType.UNARMORED`, `xp_value=8`.
- [ ] In `Enemy.tscn`'s placeholder mesh setup, make this variant visually
      distinct even as a primitive (smaller capsule scale + a different
      placeholder color) so it's visually testable before real models exist.

**Acceptance criteria**:
- [ ] `chap1_enemy_02.tres` loads correctly with the stats above.
- [ ] A spawned `chap1_enemy_02` enemy is visibly smaller/faster than a
      `chap1_enemy_01` enemy in a side-by-side test.

---

## Task 04-02 — Boss Enemy Definition & Heavy Attack

**File**: `res://resources/enemies/chap1_boss_01.tres`,
`res://scripts/components/` (new component)
**Ref**: `mechanics.md` Section 3

- [ ] Create `chap1_boss_01.tres`: `enemy_id="chap1_boss_01"`,
      `model_path=""`, `base_hp=2500`, `base_speed=1.0`, `base_damage=40`,
      `attack_cooldown=1.5`, `armor_type=Constants.ArmorType.HEAVY`,
      `xp_value=200`, `is_boss=true`.
- [ ] Add a `boss_heavy_attack_component.gd` (new, small, single-purpose —
      do **not** bolt this onto `enemy.gd` directly, per the component rule
      in `mechanics.md` Section 8): every `Constants.BOSS_HEAVY_ATTACK_EVERY_N`
      regular attacks, deals `Constants.BOSS_HEAVY_ATTACK_DAMAGE_MULT` times
      the boss's normal hit and triggers a telegraph (brief scale-pulse or
      color-flash on the boss mesh, `Constants.BOSS_HEAVY_ATTACK_TELEGRAPH_SEC`
      before the hit lands, giving the player a visual tell). Read all three
      values from `Constants.gd` (already defined there per `components.md`
      Section 2) — do not re-type the numbers in this component's code. This
      is the one **[V1-SIMPLE]** boss mechanic per `mechanics.md` Section 3 —
      no HP-phase-gated mechanic changes at v1.
- [ ] Attach this component only to the boss's enemy scene variant (or
      conditionally add it at runtime when `definition.is_boss == true` —
      either is fine, but it must not run for regular enemies).
- [ ] Scale the boss's placeholder mesh up significantly (per the scale table
      in `assets.md` Section 1) so it's visually obvious as a boss even
      before real models exist.

**Acceptance criteria**:
- [ ] `chap1_boss_01.tres` loads with the stats above.
- [ ] The boss's placeholder capsule is dramatically larger on screen than a
      regular enemy's.
- [ ] Every `Constants.BOSS_HEAVY_ATTACK_EVERY_N`th boss attack deals
      `Constants.BOSS_HEAVY_ATTACK_DAMAGE_MULT`× damage and is preceded by a
      visible telegraph; the others are normal-strength hits.
- [ ] **Balance-change smoke test**: change
      `Constants.BOSS_HEAVY_ATTACK_DAMAGE_MULT` from `2.5` to `3.0` with no
      other edits, rerun, confirm the heavy hit now deals exactly the new
      amount.

---

## Task 04-03 — ChapterDefinition & Wave Config

**File**: `res://resources/chapters/chapter_01.tres`
**Ref**: `components.md` Section 5

- [ ] Populate `chapter_01.tres`: `chapter_id="chapter_01"`,
      `chapter_name="The Plains"` (or your own naming — not load-bearing),
      `wave_count=Constants.TOTAL_WAVES` (12), `enemy_pool=
      [chap1_enemy_01.tres, chap1_enemy_02.tres]`, `boss=chap1_boss_01.tres`,
      `arena_model_path=""` (placeholder arena from Epic 01 still in use).
- [ ] Implement a simple per-wave enemy count/mix rule in `WaveManager.gd`:
      `_get_wave_composition(wave_number) -> Array[EnemyDefinition]` — v1
      rule: wave count scales `3 + wave_number` enemies total (cap at a
      reasonable number, e.g. 20, to protect performance — see
      `epic_08_polish.md` for the real performance budget), mixing
      `chap1_enemy_01`/`02` roughly 70/30 by wave 5+ (before wave 5, spawn
      only `chap1_enemy_01` so the player learns the baseline first). This is
      a simple, tunable rule, not a complex difficulty curve — refine by
      playtesting.

**Acceptance criteria**:
- [ ] `chapter_01.tres` loads correctly and exposes its enemy pool/boss.
- [ ] `WaveManager._get_wave_composition(1)` returns only `chap1_enemy_01`
      entries. `_get_wave_composition(8)` returns a mix including some
      `chap1_enemy_02`.

---

## Task 04-04 — Wave Scaling Applied

**File**: `res://autoloads/WaveManager.gd`
**Ref**: `mechanics.md` Section 3, `components.md` Section 2

- [ ] When spawning an enemy for wave N, apply
      `CombatUtils.calculate_wave_hp_scale(N)` and
      `calculate_wave_dmg_scale(N)` (built in Epic 01) to that enemy's
      `base_hp`/`base_damage` before assigning to its `HealthComponent`/
      attack logic.
- [ ] Confirm this scaling does **not** apply to the boss wave's base stats a
      second time on top of `chap1_boss_01.tres`'s already-high numbers in
      an unbounded way — apply the same formula consistently; if the boss
      feels too strong/weak after scaling, tune `chap1_boss_01.tres`'s base
      stats directly rather than special-casing the scaling formula for
      bosses.

**Acceptance criteria**:
- [ ] A `chap1_enemy_01` spawned in wave 5 has measurably higher HP than one
      spawned in wave 1 (verify the exact multiplier matches
      `pow(1.12, 4)`).
- [ ] No code path special-cases "if is_boss, skip scaling" or similar —
      confirm by reading `WaveManager`'s spawn function.

---

## Task 04-05 — Boss Wave Trigger

**File**: `res://scenes/main/GameWorld.gd`, `res://autoloads/WaveManager.gd`

- [ ] Replace the Epic 02 "BOSS TIME" print stub: when
      `wave_number >= chapter.wave_count`, instead of a regular wave, spawn
      only the chapter's `boss` enemy (one instance, scaled per Task 04-04),
      emit `EventBus.boss_spawned`.
- [ ] On the boss's `HealthComponent.died`: emit `EventBus.boss_died`, then
      trigger victory (Task 04-07) instead of a regular `wave_cleared` →
      next-wave flow.

**Acceptance criteria**:
- [ ] Reaching the final wave spawns exactly one boss enemy, not a regular
      wave mix.
- [ ] Killing the boss triggers victory, not another wave spawn.

---

## Task 04-06 — VictoryScreen Scene

**File**: `res://scenes/main/VictoryScreen.tscn`

- [ ] Create `VictoryScreen.tscn`, root `CanvasLayer`. Children: `BG`
      (`ColorRect` placeholder), `TitleLabel` ("Victory!"), `StatsPanel`
      (waves cleared, kills, time — pull from `GameState` run stats),
      `ContinueButton` ("Return to Map" — stub navigation for now, real
      WorldMap is Epic 05).
- [ ] `victory_screen.gd`: populate stats on `_ready()` from
      `GameState`/`MetaManager`; on `ContinueButton.pressed`, call
      `MetaManager` to award materials (stub a flat amount now if
      `MetaManager`'s real material formula isn't built yet — Epic 05 firms
      this up) and reload/navigate.

**Acceptance criteria**:
- [ ] Winning a run shows this screen with correct, non-placeholder stat
      values pulled from the actual run just played.

---

## Task 04-07 — Wire Victory Into Game Loop

**File**: `res://scenes/main/GameWorld.gd`

- [ ] On `EventBus.boss_died`: pause `WaveManager`, instance
      `VictoryScreen.tscn`, call `GameState.end_run(true)`.
- [ ] On `EventBus.run_ended(victory)`: if `victory == false` (defeat path,
      already partially built in Epic 02's `_on_tower_died`), make sure the
      same `end_run()` bookkeeping (run stats finalized) happens on both
      paths, not just victory.

**Acceptance criteria**:
- [ ] Both the victory path (boss killed) and the defeat path (tower HP 0)
      correctly call `GameState.end_run()` with the right `victory` value,
      verified by checking `GameState.phase` ends as `VICTORY` or `DEFEAT`
      respectively.

---

## Task 04-08 — DefeatScreen Scene (Full, Replacing Epic 02 Stub)

**File**: `res://scenes/main/DefeatScreen.tscn`

- [ ] Create `DefeatScreen.tscn` matching the shape of `VictoryScreen.tscn`
      (same component reuse where sensible — e.g. a shared `StatsPanel`
      sub-scene used by both, rather than duplicating the stat-display logic
      twice).
- [ ] `TitleLabel` ("Defeat"), wave reached stat, `RetryButton`,
      `MapButton` (stub navigation).
- [ ] Replace the Epic 02 plain-`Label` game-over stub in `GameWorld.gd` with
      instancing this scene.

**Acceptance criteria**:
- [ ] Losing a run shows this screen (not the old plain-text stub) with the
      correct wave-reached value.
- [ ] `RetryButton` correctly restarts the same chapter from wave 1.

---

## Task 04-09 — Wave Fallback Timer

**File**: `res://autoloads/WaveManager.gd`
**Ref**: `mechanics.md` Section 3, `project.md` Waves description

- [ ] Add a per-wave fallback `Timer` set to `Constants.WAVE_DURATION_MAX`
      (30s). If it fires before the wave naturally clears (e.g. enemies
      stuck/unreachable due to a pathing edge case), force-clear remaining
      enemies and proceed as if the wave cleared normally. This guards
      against a run stalling forever — a real risk once enemy variety and
      AI-ish behavior increase.

**Acceptance criteria**:
- [ ] Artificially preventing an enemy from reaching the tower (e.g. a test
      build with one enemy stuck against invisible geometry) still results in
      the wave clearing after 30 seconds, not hanging indefinitely.

---

## Task 04-10 — Integration Test

- [ ] Run a full chapter from wave 1 through the boss wave.
- [ ] Verify: `chap1_enemy_01` appears from wave 1; `chap1_enemy_02` starts
      appearing by wave 5 in the expected mix.
- [ ] Verify: enemy HP/damage visibly scales up across waves (compare wave 1
      vs wave 10 time-to-kill on the same spell loadout).
- [ ] Verify: the final wave spawns the boss alone, visibly larger than
      regular enemies, with a working telegraphed heavy attack on schedule
      per `Constants.BOSS_HEAVY_ATTACK_EVERY_N`.
- [ ] Verify: killing the boss shows VictoryScreen with correct stats.
- [ ] Verify: losing at any point (tower HP 0) shows DefeatScreen with the
      correct wave-reached value, and Retry correctly restarts.
- [ ] Verify: the 30-second fallback timer correctly unsticks an
      artificially-stalled wave.
- [ ] Fix all errors before moving to Epic 05.
