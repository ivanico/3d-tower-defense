# Tower's Last Stand (3D) — Mechanics

> Every gameplay mechanic, described precisely enough to implement without
> guessing. Each section has a **priority label**:
> - **[V1]** — required for the smallest playable loop, build this first.
> - **[V1-SIMPLE]** — required for v1, but ship the simplest version; a richer
>   version is described as a later extension.
> - **[LATER]** — not required for v1, described now so the v1 code doesn't box
>   it out. Do not build this until the relevant epic explicitly says to.

---

## 1. Camera & Presentation [V1]

- One `Camera3D`, child of a `CameraRig` (`Node3D`) positioned above and behind
  the arena center.
- **Pitch**: ~45° from horizontal (oblique/axonometric, matching Archero's
  confirmed camera style). This is a tuning value (`camera_pitch_degrees` on
  the rig script) — adjust by eye once real models are in, but 45° is the
  correct starting point. height == distance gives exactly 45°.
- **Yaw**: 0, fixed. The camera never rotates around the arena. There is no
  player camera control — this is not that kind of game.
- **Distance/height**: far enough back that the full arena (tower + all 4
  spawn edges) is always in frame at 1080×1920 portrait aspect. Tune
  `camera_distance` and `camera_height` once arena size is final (see Section 2).
- **Projection**: orthographic (not perspective) — tiles read as perfect squares
  and the ground fills the full screen edge-to-edge, matching the Archero look.
- The camera does not follow the tower during normal play (tower is static at
  arena center, so a static camera is correct). It MAY do small reactive moves:
  - Screen shake (small positional jitter) on heavy hits / boss spawn — see
    Epic 08.
  - A brief zoom/pan on boss intro — **[LATER]**, not v1.

---

## 2. Arena & Tower [V1]

- The arena is a flat circular or square ground plane (`MeshInstance3D` +
  `StaticBody3D` collider), radius/half-width tuned per chapter but starting
  around **10–12 meters** across (matches a readable Archero-style enclosed
  arena at the chosen camera distance — exact number gets tuned once the
  camera and a placeholder tower/enemy are in scene, see Epic 01 acceptance
  criteria).
- The tower sits fixed at world origin `Vector3(0, 0, 0)` (or ground-height
  offset for its base) — it never moves.
- Enemies spawn at the arena's outer edge and walk toward the tower across the
  ground plane (X/Z movement, Y fixed to ground height per Section "Verticality
  Rules" in `project.md`).
- **Tower auto-combat**:
  - The tower has a fixed **attack range** (radius, meters) and **fire rate**
    (shots/sec), both modified by drafted upgrades.
  - Each `physics_process`, the tower's targeting component scans for enemies
    inside range and on a spell-by-spell cooldown, fires when ready.
  - Targeting mode for v1: **closest enemy**. (Other modes —
    lowest-HP/highest-HP/first-aggro — are **[LATER]**, the targeting component
    is written to accept a mode enum so adding modes is a new `match` branch,
    not new architecture.)
- **Tower HP**: tower has `max_hp` and current `hp`. Enemies that reach melee
  range of the tower deal damage on a cooldown. At `hp <= 0`, the run ends in
  defeat.
- **Tower regen**: optional small passive regen/sec, off by default at v1
  (0), turned on by drafted upgrades or tower stars.

---

## 3. Enemies [V1]

- Each enemy type is defined by an `EnemyDefinition` resource (see
  `components.md`), not a hardcoded script per enemy. New enemy types are new
  resources + a model reference, not new code, **unless** the enemy needs a
  genuinely new behavior (e.g. a flyer's hover logic) — those behaviors live in
  small opt-in components (see Section 8) that any `EnemyDefinition` can
  reference.
- **v1 enemy roster** (chapter 1):
  - `chap1_enemy_01` — baseline ground melee enemy. Walks straight at the
    tower, melee-attacks on contact.
  - `chap1_enemy_02` — fast, low-HP ground enemy. Same behavior, different
    stats (higher speed, lower HP) — proves the data-driven approach works
    without new code.
  - `chap1_boss_01` — chapter boss. Same base movement/attack component, much
    higher stats, plus one simple boss-only mechanic (a telegraphed heavier hit
    on a longer cooldown — **[V1-SIMPLE]**; multi-phase bosses with HP-gated
    mechanic changes are **[LATER]**).
- **Movement**: enemies move toward the tower's position on the X/Z plane using
  `CharacterBody3D.move_and_slide()`, with light separation steering against
  nearby enemies so they don't perfectly stack (check only nearby enemies
  within a small radius — see `epic_08_polish.md` for the performance-bounded
  version; v1 can check against all active enemies if the wave size is small).
- **Death**: enemy HP reaches 0 → death animation plays → object pool release
  (no `queue_free()` on pooled enemies after Epic 02 — see Section 9).
- **Naming convention**: enemy/asset identifiers use `chap<N>_enemy_<NN>` and
  `chap<N>_boss_<NN>` (zero-padded two digits), never flavor names like
  "grunt" or "flyer," so the data files read as plain catalog entries and new
  entries slot in without implying a fixed roster. (Internal *design* notes can
  still describe an enemy as "the fast one" or "the flying one" in prose — only
  the actual identifiers/filenames follow this convention.)
- **[LATER] Flying enemy type**: hovers at a fixed `flight_height` above ground
  with a small sinusoidal bob, otherwise same movement-toward-tower logic on
  X/Z. Build this once the ground-enemy loop is solid — the movement component
  is written so "ignore gravity, hold a target Y" is a flag, not a rewrite.
- **[LATER] Armor/elite variants, randomized armor per wave, multi-phase boss
  mechanics**: described in the original design backlog, not required for v1.

---

## 4. Draft System [V1]

- Triggers: after every wave clear, and on every level-up (XP-based, see
  Section 7). Both use the same draft UI/flow, just a different trigger label
  for context text.
- 3 cards offered, drawn from the combined pool of `SpellDefinition` +
  `StatUpgradeDefinition` resources, weighted by rarity (Common/Rare/Epic —
  same 3-tier rarity system as before, weights tunable in `Constants.gd`).
- Picking 1 card:
  - If a spell: added to the tower's active spell list (up to a max slot
    count), tags applied to the running tag counter.
  - If a stat upgrade: stat delta applied immediately to `GameState`/tower
    stats, tags applied.
- **[LATER]** Reroll cards, "guarantee a card matching an active tag," 4-card
  draft from the [Utility]×5 synergy — all described in Section 6/`project.md`
  tag table, build once the base draft loop is solid.

---

## 5. Damage System [V1]

- Every hit resolves through one generic function:
  `CombatUtils.calculate_damage(base_amount, damage_type, armor_type) -> float`
  which looks up a multiplier from the Damage Type vs Armor table
  (`project.md`) and returns `base_amount * multiplier`, then any active
  synergy modifiers (Section 6) are applied on top.
- This function must never contain per-enemy or per-spell special-case
  branches — new damage types/armor types are new table entries, not new code
  paths. This is the single most important rule for keeping the "add more
  spells/enemies later" promise true.
- Hit detection: every projectile/AoE/melee hit is an `Area3D` overlap check
  against the target's `HurtboxComponent` (see Section 8 / `components.md`).

---

## 6. Synergy Tags [V1-SIMPLE]

- Every card (spell or stat upgrade) carries 1–2 tags from the `SynergyTag`
  enum.
- `GameState` keeps a `tag_counts: Dictionary[SynergyTag, int]`. Picking a card
  increments the count for each of its tags.
- When a tag count crosses a threshold (`SYNERGY_THRESHOLD_LOW = 3`,
  `SYNERGY_THRESHOLD_HIGH = 5`), `GameState._apply_synergy_bonus(tag, level)`
  runs a `match` statement that sets the relevant flag/multiplier and fires
  `EventBus.synergy_threshold_reached` (which the UI listens to for the banner).
- **v1 ships 3 tags** ([Offense], [Armor], [Utility] — see `project.md` table).
  The counting/threshold/event system is fully generic; adding tag #4 onward
  is: add an enum entry, add a table row, add a `match` branch. No new system.

---

## 7. XP & Level-Up [V1]

- Killing an enemy grants XP (`EnemyDefinition.xp_value`).
- `GameState.run_xp` accumulates; at `run_xp >= run_xp_to_next`, level up:
  increment `run_level`, roll over remainder XP, scale `run_xp_to_next` up
  by `Constants.XP_LEVEL_SCALE_PER_LEVEL` (named constant, not a bare
  literal — see `components.md` Section 0/2), trigger a draft (Section 4).
- Level-up draft pauses combat (enemies freeze) until a card is picked, same
  as wave-clear draft, just triggered mid-wave.

---

## 8. Component Pattern (Core Architecture Rule) [V1]

This is the architectural fix for the problem you hit in the old project
(monolithic 300-line scripts that did everything for one node). Every gameplay
object — tower, enemy, projectile — is built from small, single-purpose
`Node3D` (or `Node`) component scripts attached as children, not one script
that owns all behavior. A new feature is usually a new component, not an edit
to an existing 300-line file.

**Core components (v1, build these in Epic 01–02):**

| Component | Responsibility | Used by |
|---|---|---|
| `HealthComponent` | Current/max HP, `damage()`, `heal()`, emits `died`/`health_changed` | Tower, every enemy |
| `HurtboxComponent` | `Area3D` that receives hits, reads `damage_type`, calls owner's `HealthComponent.damage()` through `CombatUtils` | Tower, every enemy |
| `HitboxComponent` | `Area3D` that deals damage on overlap with a `HurtboxComponent` | Projectiles, AoE zones, melee swings |
| `MoveToTargetComponent` | Moves a `CharacterBody3D` toward a target position on X/Z using `move_and_slide()`, with optional fixed-height hold (for flyers later) | Every enemy |
| `TargetingComponent` | Finds the best target in range by a `TargetMode` (closest, etc.) | Tower |
| `CooldownComponent` | Generic reusable timer-with-ready-check (used for spell cooldowns, attack cooldowns, regen ticks) | Tower spells, enemy attacks |
| `HitFlashComponent` | Brief material-color flash on damage taken | Enemies, tower |
| `DeathFXComponent` | Plays death animation/particles, then signals release-to-pool | Every enemy |

**Rule of thumb**: if you're about to add a new `if` branch to an existing
component to special-case one enemy or one spell, stop — that behavior
probably wants its own small component instead, attached only to the things
that need it. See `skills/godot3d-architecture/SKILL.md` for the full pattern
with code examples.

---

## 9. Object Pooling [V1]

- Frequently spawned/despawned nodes (enemies, projectiles, AoE zones, damage
  numbers) are pooled via the `ObjectPool` autoload, never `queue_free()`'d
  directly once pooling is wired (Epic 02 onward).
- Pool contract: `ObjectPool.get(scene) -> Node`, `ObjectPool.release(node)`,
  `ObjectPool.preload_pool(scene, count)`.
- Releasing a node: hide it, disable its `CollisionShape3D`(s), move it under a
  hidden pool root, return it to the available list. Getting a node reverses
  this and calls a `reset()` method the component/owner script must implement.

---

## 10. HUD Readouts [V1]

- HP bar (tower), XP bar, wave counter, level counter, synergy tag row.
- Damage numbers: floating 3D-world-space numbers (a `Label3D` or a
  billboarded `Sprite3D`-backed number, pooled) that spawn at the hit point
  and float upward/fade — **[V1-SIMPLE]**, polish pass (crit scaling, color by
  damage type, stacking cap) is Epic 08.

---

## 11. Meta Layer [V1]

- **Materials**: earned at end of run (scaled by waves cleared / victory /
  boss kill). Single material type at v1 is acceptable
  (**[V1-SIMPLE]** — the original design's Chapter Material vs Universal
  Material split is **[LATER]**, add the second currency type once there's a
  second chapter to justify it).
- **Tower stars**: spend materials to increase a tower's star level (1–5).
  Each star bumps base stats by a tunable percentage; star 3 and star 5 are
  reserved hooks for passive enhancements (**[LATER]** for the actual enhanced
  passive behavior — v1 can ship stars as pure stat bumps and add the passive
  hook later without restructuring).
- **Spell ranks**: spend materials to increase a spell's rank (1–5). Same
  pattern — v1 can ship ranks as pure numeric scaling (damage/cooldown), with
  "rank adds a new behavior" (the richer version from the original design)
  as **[LATER]**.
- **Energy**: 5 runs/day, regenerates over time, gates run starts.
- **Save/load**: single save file (`user://savegame.save` or a `.tres`
  `SaveData` resource) holding owned towers, tower stars, spell ranks,
  materials, energy, timestamps.

---

## 12. Monetization Hooks (Design-Only, Not a v1 Build Task) [LATER]

Energy refill, cosmetic tower skins (swap the tower's model/material set —
trivial given the data-driven model reference), tower unlock packs, battle
pass. None of this blocks gameplay or is gated by payment beyond convenience —
documented here for completeness; no epic builds monetization UI until the
core loop is proven fun.
