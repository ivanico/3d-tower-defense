# Spells — Visual Asset Reference & Spell Catalog

> **Scope of this file**: defines the reusable *shape archetypes* used across
> all spell visuals, the *spell schools* (damage types + their perks), the
> *resistance rules*, and the full planned spell list — so adding a new spell
> later means picking an archetype + a school, not modeling or coding
> something new. Follows the same pipeline as `assets.md`: base shapes
> modeled in Blender, exported as `.glb`, imported into Godot, then
> shaded/animated/particle'd in-engine (shared toon/emissive shader +
> `GPUParticles3D`, tinted per school via the same
> `CombatUtils.get_damage_color()` lookup used elsewhere in the project).

---

## 1. Shape Archetypes (v1)

Five base shapes, modeled once each in Blender, reused by every spell of
that category. Color and school are never baked into the model — they come
from the shared shader at spawn time, so one `.glb` per archetype covers
every school variant.

### 1. Chain Bolt (bounce shape)

- **Shape**: a "C"-curved bolt/arc — distinct silhouette from the straight
  bolt so bounce-type spells read differently on screen even before the
  color registers.
- **Used for**: bounce spells. **Void, Poison, and Nature only** — the
  schools where enemy-to-enemy jumping reads naturally (chaos energy
  arcing, disease spreading host to host, vines lashing between targets).
  Fire and Frost don't get chain spells; their AoE identity is the
  AoE Area archetype instead.
- **Behavior notes**: spins continuously around its own axis while flying
  (like a tumbling shuriken) — no forward-facing pivot needed, the spin
  sells the motion regardless of travel direction. Flies to the nearest
  enemy first; on hit, finds the *nearest enemy to the one just hit* within
  the bounce radius and bounces there; if no valid target is found within
  radius, despawns immediately (no fizzle animation, just free the node).
- **File**: `res://assets/models/spells/spell_chain_bolt.glb`

### 2. Standard Bolt (generic projectile shape)

- **Shape**: a plain, simple straight projectile bolt — small elongated
  capsule/lozenge shape, pointed or rounded front, tapered back where the
  particle trail attaches. No facets, no ornamentation, no baked-in color —
  kept deliberately plain so it reads clearly in *any* tint color at
  gameplay speed/zoom, matching the clean toon-ish look of the rest of the
  project (mobile arcade style, not a realistic/ornate arrow).
- **Used for**: default single-target projectile spells — **all 5 schools**.
  This is the workhorse shape.
- **File**: `res://assets/models/spells/spell_bolt_standard.glb`

### 3. Orb (simple circular shape)

- **Shape**: a simple sphere/circle — deliberately minimal so it stays
  cheap to spawn in numbers (used for orbiting spells, which may have
  several instances alive at once).
- **Used for**: orbs that spin/orbit around the tower — **all 5 schools**
  (Orb of the Void, Orb of Frost, etc.).
- **Behavior notes**: orbit motion (radius, speed, angle offset per orb) is
  a Godot script concern, not baked into the model.
- **File**: `res://assets/models/spells/spell_orb.glb`

### 4. AoE Area (falling shard shape)

- **Shape**: small crystal shard or mini-bolt shape, dropped from above
  onto a target position/area.
- **Used for**: area spells where projectiles rain down onto a zone over
  time. **Fire and Frost only** — Rain of Fire and Blizzard. Void, Poison,
  and Nature don't get AoE Area spells; their multi-target identity is the
  Chain archetype instead.
- **Behavior notes**: the shard mesh itself is a small **static** model —
  no baked/animated falling motion in Blender. Everything below is Godot
  script + particle work:
  1. On cast, show the ground-decal target area immediately
	 (reuses the existing `proj_aoe_marker` pattern from `assets.md`
	 Section 3), so the player sees where it's about to hit.
  2. A spawner picks random positions inside that radius and spawns
	 shards **staggered over time** via a repeating `Timer`
	 (~every 0.1-0.3s, randomized slightly) for the spell's duration —
	 not all at once. This staggering is what actually reads as
	 "blizzard"/"rain of fire" instead of a single instant burst.
  3. Each shard spawns above its target point and **falls into place**
	 via a `Tween` on position (~0.2-0.4s drop), then stays on the ground
	 for the remainder of the effect.
  4. On landing: small impact particle burst at that point.
  5. Separately, an invisible `Area3D` covers the *entire* AoE radius and
	 stays active for the whole spell duration, ticking damage to any
	 enemy standing inside it — this is what makes "stand in the
	 blizzard = take damage" work, independent of whether a visible
	 shard happens to land on that exact spot.
- **File**: `res://assets/models/spells/spell_aoe_shard.glb`

### 5. Line AoE Bolt (piercing beam shape)

- **Shape**: a larger version of the Standard Bolt (#2) — same silhouette
  language, scaled up, so it's visually clear it's "the big version" of a
  normal bolt rather than an unrelated shape.
- **Used for**: line-AoE spells that travel in a single straight line and
  hit every enemy in their path — **all 5 schools**.
- **Behavior notes**: needs a longer collision/hitbox shape than the
  standard bolt to match its piercing-line hit detection.
- **File**: `res://assets/models/spells/spell_bolt_line_aoe.glb`

---

## 2. Spell Schools (damage types + perks)

Five schools. Every spell belongs to exactly one school; the school decides
the tint color (via `CombatUtils.get_damage_color()`) **and** the on-hit
perk. The perk is applied generically by the damage/status system — a
spell's `.tres` never re-implements "burn" or "slow," it just declares its
school.

> **Relationship to the v1 damage table**: the schools ARE the `DamageType`
> enum now — the original v1 Normal/Magic/Piercing types were removed when
> the schools landed (the 3 placeholder v1 spells were migrated to Void:
> pure damage, no status, matching their old behavior). Same generic table
> lookup, no new code paths (see `mechanics.md` Section 5).

| School | Color (suggested) | Direct dmg | DoT | Slow | Special |
|---|---|---|---|---|---|
| **Fire** | orange/red | medium | **strong burn** (highest DoT in game) | — | — |
| **Frost** | ice blue | medium | — | **strong slow** (strongest slow in game) | — |
| **Void** | purple/magenta | **high — pure damage** | — | — | **never resisted by anything** (see Section 3) |
| **Poison** | green | low-medium | weak DoT (weaker than Fire's burn) | weak slow (weaker than Frost's) | the "does a bit of both" hybrid school |
| **Nature** | leaf green / gold | medium | — | — | **lifesteal**: a % of damage dealt heals the tower's HP |

Design-intent numbers (tunable — the real values live as named constants in
`Constants.gd`, per the project's "Balance tuning constants" rule; update
both places if retuned):

- `FIRE_BURN_DPS_PERCENT` — burn ticks for ~30% of the spell's hit damage
  per second, for `FIRE_BURN_DURATION` ≈ 3s.
- `FROST_SLOW_PERCENT` ≈ 40% move-speed slow, `FROST_SLOW_DURATION` ≈ 2s.
- `POISON_DOT_PERCENT` ≈ 15%/s (half of Fire's), `POISON_DOT_DURATION` ≈ 4s
  (longer but weaker), `POISON_SLOW_PERCENT` ≈ 20% (half of Frost's),
  `POISON_SLOW_DURATION` ≈ 2s.
- `VOID_DAMAGE_PREMIUM` ≈ +15-20% base damage vs. an equivalent-rarity
  spell of another school — Void's perk *is* the raw number plus never
  being resisted, so it must hit noticeably harder to feel like a perk.
- `NATURE_LIFESTEAL_PERCENT` ≈ 15-20% of damage dealt returned as tower HP.

Status effects (burn/slow/poison) are components on the enemy
(`StatusEffectComponent` or similar), applied by `CombatUtils` when the hit
resolves — same "generic function, no per-spell branches" rule as
`calculate_damage()`. Re-applying a status refreshes its duration; it does
not stack (v1 rule, revisit later if needed).

---

## 3. Resistances (armor vs. schools)

- Enemies carry a **resisted school** on their armor/enemy definition
  (extends the existing `ArmorType` / damage-table pattern — new table
  entries, not new code).
- A resisted hit deals `SCHOOL_RESIST_MULT` ≈ **0.5×** damage, and its
  status effect (burn/slow/poison/lifesteal amount) is halved too.
- **Nothing ever resists Void.** Void is the "safe pick" school — its rows
  in the damage table are always ≥ 1.0×. That's the tradeoff triangle:
  specialized schools have perks but can be countered; Void has no utility
  perk but always works.
- Suggested v1 usage: each chapter's enemy roster mixes 2-3 different
  resisted schools so no single non-Void school can carry a whole run —
  which is what makes drafting a *spread* of schools (or gambling on Void)
  an actual decision.

---

## 4. Spell Catalog — the full 20

Distribution: **Standard Bolt ×5** (all schools) + **Orb ×5** (all schools)
+ **Line AoE Bolt ×5** (all schools) + **AoE Area ×2** (Fire, Frost) +
**Chain ×3** (Void, Poison, Nature) = **20 spells**.

The split is deliberate, not a gap: Fire/Frost express "multi-target" as a
ground zone (AoE Area), Void/Poison/Nature express it as bouncing (Chain).
Every school ends up with exactly 4 spells — 3 shared archetypes + 1
signature multi-target archetype.

**Status legend**: `[ ]` = not built, `[x]` = built in-engine & confirmed
looking good. (v1 ships with only 3 spells wired — see `epic_03_draft.md` —
the rest of this table is the content backlog that the generic
`SpellDefinition` + `SpellRegistry` system absorbs one `.tres` at a time.)

### Fire (burn DoT) — 4 spells

| Status | Spell Name | Archetype | Notes |
|---|---|---|---|
| [x] | Bolt of Fire | Standard Bolt | single target + burn |
| [x] | Orb of Embers | Orb | orbiting, applies burn on contact |
| [x] | Flame Lance | Line AoE Bolt | pierces the line, burns everything hit |
| [x] | Rain of Fire | AoE Area | zone damage + burn while standing in it |

### Frost (strong slow) — 4 spells

| Status | Spell Name | Archetype | Notes |
|---|---|---|---|
| [x] | Bolt of Frost | Standard Bolt | single target + slow |
| [x] | Orb of Frost | Orb | orbiting slow-on-contact |
| [x] | Glacier Lance | Line AoE Bolt | slows the whole line — strong wave-shaping tool |
| [x] | Blizzard | AoE Area | zone damage + slow while standing in it |

### Void (pure damage, never resisted) — 4 spells

| Status | Spell Name | Archetype | Notes |
|---|---|---|---|
| [x] | Void Bolt | Standard Bolt | the highest single-target bolt damage |
| [x] | Orb of the Void | Orb | (was "Orb of Chaos" in early notes — Chaos = Void, one school) |
| [x] | Rift Lance | Line AoE Bolt | pure-damage line pierce |
| [x] | Chain of Chaos | Chain Bolt | (name kept from early notes) pure-damage bounce |

### Poison (weak DoT + weak slow) — 4 spells

| Status | Spell Name | Archetype | Notes |
|---|---|---|---|
| [x] | Venom Bolt | Standard Bolt | single target + poison |
| [x] | Orb of Venom | Orb | orbiting poison-on-contact |
| [x] | Toxic Lance | Line AoE Bolt | poisons the whole line |
| [x] | Contagion | Chain Bolt | disease jumping host to host — the most thematically "chain" spell in the game |

### Nature (lifesteal → heals tower) — 4 spells

| Status | Spell Name | Archetype | Notes |
|---|---|---|---|
| [x] | Thorn Bolt | Standard Bolt | single target, % damage returned as tower HP |
| [x] | Orb of Thorns | Orb | orbiting lifesteal — steady trickle heal |
| [x] | Briar Lance | Line AoE Bolt | line pierce; lifesteal off every enemy hit (big heals vs. packed waves) |
| [x] | Leeching Vines | Chain Bolt | lifesteal off every bounce |

### Count tracker

| | Fire | Frost | Void | Poison | Nature | **Total** |
|---|---|---|---|---|---|---|
| Designed | 4 | 4 | 4 | 4 | 4 | **20** |
| Built | 4 | 4 | 4 | 4 | 4 | **20** |

> **20/20 built and confirmed via draft** (S-06): all 20 verified
> draftable end-to-end — draft → pick → fight → duplicate-pick stacking —
> in a live multi-wave run, plus the range-hierarchy sanity pass
> (measured first-fire distances: Bolt 9.95 > Chain 7.95 > AoE 6.45 >
> Lance 3.95).

> **Extend later by**: adding a row per spell. If you ever want to get back
> up to 25, the 5 empty grid slots (Fire/Frost chains, Void/Poison/Nature
> AoE Areas) are the cheapest additions — both models already exist. A 6th
> school (e.g. Lightning — chain-flavored, maybe stun) is +1 `DamageType`
> entry, table rows, and new `.tres` files — no new models needed.

---

## 5. Implementation Tasks (for Claude Code) — Building the Missing Spells

> **How to use this section**: work the tasks in order. Task S-00 is shared
> plumbing every archetype depends on; S-01…S-05 are one task per archetype.
> Everything tunable must be an **exported field** on `SpellDefinition` (or
> the archetype's scene) so range/damage/speed/etc. are editable in the
> Godot Inspector per-`.tres`, never hardcoded in scripts. Follow the
> project's existing rules: hits resolve through
> `CombatUtils.calculate_damage()` + `HitboxComponent`/`HurtboxComponent`
> (`mechanics.md` Section 5), no per-spell branches in shared code, pooled
> projectiles (`mechanics.md` Section 9), and new content = new `.tres`
> files picked up by `SpellRegistry`'s scan.
>
> **Models already exist — use them.** The `.glb` models for the spells are
> already made and live in `res://assets/models/spells/` (the files listed
> per-archetype in Section 1 and repeated in each task's **Model** line).
> Do **not** generate placeholder meshes (no `CSGBox3D`/`SphereMesh`
> stand-ins) — load the real `.glb` into the archetype's projectile/orb/
> shard scene. Also expose the model path as an exported field
> (`model_path` on the `.tres` or a `PackedScene`/mesh export on the
> archetype scene) so if any individual spell later gets its own dedicated
> model in that folder, swapping it in is an Inspector change, not a code
> change.

### Range hierarchy (design rule — enforce via .tres values, not code)

Acquisition/cast range from longest to shortest:

1. **Standard Bolt** — longest range in the game (fires furthest).
2. **Chain Bolt** — a bit shorter than Standard Bolt.
3. **AoE Area** — a bit shorter than Chain Bolt.
4. **Line AoE Bolt** — shortest cast range of all (but its projectile
   travels to the edge of the screen once fired — see S-05).
- **Orb** is not ranged/targeted at all — it orbits close to the tower and
  only hits enemies that touch it (see S-03).

Suggested starting values (named constants in `Constants.gd`, mirrored into
each `.tres`, tune freely in the Inspector):
`BOLT_RANGE ≈ 10.0` > `CHAIN_RANGE ≈ 8.0` > `AOE_AREA_RANGE ≈ 6.5` >
`LINE_AOE_RANGE ≈ 4.0`.

---

### Task S-00 — Shared plumbing: school perks + duplicate-pick stacking

**Refs**: Sections 2-3 above, `mechanics.md` Sections 4-5, `components.md`
(`SpellDefinition`, `CombatUtils`)

- [x] Extend `Constants.DamageType` with `FIRE`, `FROST`, `VOID`, `POISON`,
	  `NATURE` and add their rows to the damage-vs-armor table
	  (`project.md`). Void's row is all `>= 1.0`.
- [x] Add the school perk constants from Section 2 to `Constants.gd`
	  (`FIRE_BURN_DPS_PERCENT`, `FROST_SLOW_PERCENT`, `POISON_*`,
	  `VOID_DAMAGE_PREMIUM`, `NATURE_LIFESTEAL_PERCENT`, durations, and
	  `SCHOOL_RESIST_MULT`).
- [x] Build a generic `StatusEffectComponent` on `Enemy.tscn`:
	  `apply_burn(dps, duration)`, `apply_slow(percent, duration)`,
	  `apply_poison(dps, slow_percent, duration)`. Re-apply refreshes
	  duration, no stacking (v1 rule). *(Added to all 7 enemy/boss scenes;
	  slows write `MoveToTargetComponent.slow_multiplier`.)*
- [x] In the hit-resolution path (where `CombatUtils.calculate_damage()` is
	  called), apply the school perk **generically by damage type** — one
	  `match` on `DamageType`, used by every archetype: Fire → burn,
	  Frost → slow, Poison → weak burn + weak slow, Nature → heal tower for
	  `NATURE_LIFESTEAL_PERCENT` of final damage (route through
	  `EventBus`/`GameState` to the tower's `HealthComponent`), Void → no
	  status (its premium is baked into its `.tres` damage values).
	  *(`CombatUtils.apply_school_perk()`, called from
	  `HurtboxComponent.apply_hit()` — the one shared hit funnel. Per-enemy
	  `resisted_school` on `EnemyDefinition` halves damage + status via
	  `SCHOOL_RESIST_MULT`; Void exempt.)*
- [x] **Duplicate-pick stacking**: when a drafted spell is already owned,
	  the draft must still be able to offer it; picking it again increments
	  a per-spell `stack_count` on the tower's active-spell entry (instead
	  of adding a second cooldown/instance). Expose `stack_max` as an
	  exported field on `SpellDefinition`. What `stack_count` *does* is
	  per-archetype (extra bolt, extra orb — see S-01…S-05).

**Acceptance criteria**:
- [x] A Fire hit visibly ticks burn damage; a Frost hit visibly slows; a
	  Poison hit does both (weaker); a Nature hit heals the tower; Void
	  applies no status but hits harder per its `.tres`.
- [x] Picking the same spell twice in the draft results in
	  `stack_count == 2`, not two separate spell entries.

---

### Task S-01 — Standard Bolt archetype (5 spells)

**Model**: `spell_bolt_standard.glb` · **Spells**: Bolt of Fire, Bolt of
Frost, Void Bolt, Venom Bolt, Thorn Bolt

- [x] Behavior: longest range of any spell. Targets the nearest enemy in
	  range and fires a simple straight-line projectile at it (existing
	  straight-projectile pattern — fixed height, straight 3D vector, no
	  arc). *(Per-spell acquisition range: the tower's range `Area3D` is now
	  `BOLT_RANGE` (10.0) and `TargetingComponent.get_target(s)` filters by
	  each spell's `.tres` `range` — this is the mechanism the whole range
	  hierarchy uses.)*
- [x] **Stacking**: each additional pick of the same spell fires **one more
	  bolt per cast** (`stack_count` bolts total). Extra bolts target the
	  next-nearest distinct enemies; if fewer enemies than bolts, remaining
	  bolts go at the same/nearest target. Fire the extras with a tiny
	  stagger (~0.05-0.1s) so it reads as a volley, not one overlapping
	  mesh. *(`Constants.BOLT_VOLLEY_STAGGER_SEC` = 0.07.)*
- [x] Exported/Inspector-tunable (on `.tres` / projectile scene): `damage`,
	  `range`, `cooldown`, `projectile_speed`, `stack_max`, per-school
	  status values inherited from S-00 constants.
- [x] Create the 5 `.tres` files (`spell_bolt_fire.tres`, etc.) — school
	  color comes from `CombatUtils.get_damage_color()`, one shared scene.
	  *(Projectile scene now instances the real `spell_bolt_standard.glb`
	  (exported `model_scene` field for later swaps) with one shared
	  emissive material per school via `CombatUtils.get_school_material()`.)*

**Acceptance criteria**:
- [x] One `.glb`/scene serves all 5 schools with only `.tres` + tint
	  differences.
- [x] With `stack_count = 3`, three bolts fire per cooldown cycle.

---

### Task S-02 — Chain Bolt archetype (3 spells)

**Model**: `spell_chain_bolt.glb` · **Spells**: Chain of Chaos, Contagion,
Leeching Vines

- [x] Behavior: range a bit shorter than Standard Bolt. Fires at the
	  nearest enemy in range; the projectile spins around its own axis
	  while flying (Section 1 notes). *(New
	  `game_object/chain_projectile/` scene using `spell_chain_bolt.glb`;
	  the spell's `.tres` points its `projectile_scene` field at it, so the
	  tower's existing volley/cast path fires chains with zero new
	  categories.)*
- [x] **Bounce logic — max 3 hits total (2 bounces)**:
	  1. Hit enemy A (nearest in cast range).
	  2. Bounce to the enemy **closest to A** within `bounce_radius`.
	  3. Bounce once more to the enemy **closest to B**, excluding A (and
		 B). Track already-hit enemies in an array and filter them out of
		 every bounce search.
	  4. If at any step no valid target exists in `bounce_radius`, despawn
		 immediately (pool release, no fizzle FX).
	  So the full 3-hit chain only happens when 3 enemies are clustered —
	  that's intended.
- [x] **Stacking**: same as Standard Bolt — each additional pick fires one
	  more chain projectile per cast, each running its own independent
	  bounce chain (they may hit overlapping enemies; that's fine).
- [x] Exported/Inspector-tunable: `damage`, `range`, `cooldown`,
	  `projectile_speed`, `bounce_radius`, `max_bounces` (default 2),
	  `stack_max`, `damage_falloff_per_bounce` (default 1.0 = none, there
	  so it's tunable later without code). *(Defaults live in
	  `Constants.CHAIN_BOUNCE_RADIUS` / `CHAIN_MAX_BOUNCES`; every field is
	  per-`.tres` in the Inspector. School perks land per hit via the
	  shared `HurtboxComponent.apply_hit` funnel — no per-spell branches.)*
- [x] Create the 3 `.tres` files.

**Acceptance criteria**:
- [x] With 3 clustered enemies, one projectile hits all 3, never the same
	  enemy twice; with 1 isolated enemy it hits once and despawns.
- [x] `max_bounces` and `bounce_radius` changes in the Inspector take
	  effect with no script edits.

---

### Task S-03 — Orb archetype (5 spells)

**Model**: `spell_orb.glb` · **Spells**: Orb of Embers, Orb of Frost, Orb
of the Void, Orb of Venom, Orb of Thorns

- [x] Behavior: no targeting, no cooldown-fire — a persistent body orbiting
	  the tower at its school's `orbit_radius`, damaging any enemy it
	  touches, applying the school perk per hit. Add a small per-enemy
	  re-hit interval (`orb_hit_interval`, ~0.5s) so an enemy standing in
	  the orbit path takes ticks, not one hit per physics frame. *(New
	  `SpellCategory.ORB` + `game_object/orb/` scene using
	  `spell_orb.glb`; hits are distance-based like every other archetype's
	  hit path, funneled through `HurtboxComponent.apply_hit`.)*
- [x] **Stacking — angle placement sequence**: additional picks of the same
	  orb spell add another orb on the *same ring*, at angle offsets that
	  keep splitting the circle in half:
	  orb 1 → `0°`, orb 2 → `180°`, orb 3 → `90°`, orb 4 → `270°`,
	  orb 5 → `45°`, orb 6 → `225°`, orb 7 → `135°`, orb 8 → `315°` …
	  Implement as a constant lookup array
	  `ORB_ANGLE_SEQUENCE = [0, 180, 90, 270, 45, 225, 135, 315, …]` in
	  `Constants.gd` — index by `stack_count - 1`. All orbs on a ring share
	  one `orbit_speed` so the spacing stays fixed. *(Each ring is one
	  rotating pivot `Node3D` under the tower; orbs are fixed children, so
	  shared speed/spacing holds by construction.)*
- [x] **Per-school rings, no overlap**: each school has its own
	  `orbit_radius`, all close to the tower but spaced by more than one
	  orb diameter so all 5 orb spells can be owned at once without orbs
	  colliding — `ORB_ORBIT_RADII = {FIRE: 1.6, FROST: 2.0,
	  VOID: 2.4, POISON: 2.8, NATURE: 3.2}` (tunable constants; also
	  exported per-`.tres` so any one ring can be nudged in the Inspector).
- [x] Exported/Inspector-tunable: `damage`, `orbit_radius`, `orbit_speed`,
	  `orb_hit_interval`, `stack_max` (cap at the angle-sequence length —
	  also code-capped in `tower._add_spell`).
- [x] Create the 5 `.tres` files.

**Acceptance criteria**:
- [x] Picking the same orb 4 times produces orbs at 0/180/90/270° on one
	  ring, evenly spinning, no jitter.
- [x] Owning all 5 orb spells shows 5 concentric rings with no
	  orb-vs-orb overlap.
- [x] An enemy walking through a ring takes ticked damage + the school
	  perk (e.g. Frost orb slows it).

---

### Task S-04 — AoE Area archetype (2 spells)

**Model**: `spell_aoe_shard.glb` · **Spells**: Rain of Fire, Blizzard

- [x] Behavior: cast range a bit shorter than Chain Bolt. On cast, pick an
	  enemy in range and place the zone **at that enemy's current
	  position** — the zone itself **never moves** after placement. *(New
	  `SpellCategory.AOE_AREA` + `game_object/aoe_area_zone/` scene;
	  pooled via ObjectPool.)*
- [x] Visuals/structure: exactly the Section 1 "AoE Area" spec — decal
	  marker immediately, staggered falling shards over the duration,
	  impact bursts, and one invisible `Area3D` covering the whole radius
	  for the full duration. *(Decal is a school-tinted transparent disc;
	  shards are real `spell_aoe_shard.glb` instances tween-dropped from
	  3m; landing spawns a one-shot school-colored `GPUParticles3D` burst.
	  Shard spawning stops 0.5s before expiry so nothing is mid-drop at
	  cleanup.)*
- [x] Damage: ticks damage every `tick_interval` to **every enemy
	  currently inside it** — including enemies that walk in after
	  placement — applying the school perk per tick (burn for Rain of
	  Fire, slow for Blizzard) via the shared `HurtboxComponent.apply_hit`
	  funnel. Damage computed at tick time so mid-run upgrades apply to
	  live zones.
- [x] **Stacking**: not designed yet — exported `stack_max` shipped at `1`
	  (duplicate picks simply won't be offered once owned). No stacking
	  behavior invented — `[TBD]`.
- [x] Exported/Inspector-tunable: `damage` (per tick), `range` (cast
	  range), `aoe_radius`, `duration`, `tick_interval`,
	  `shard_spawn_interval`, `cooldown`. *(Defaults in
	  `Constants.AOE_AREA_*`.)*
- [x] Create the 2 `.tres` files.

**Acceptance criteria**:
- [x] Zone spawns on an enemy's position and stays put while that enemy
	  walks away; a *different* enemy walking through it takes ticks.
- [x] Zone expires cleanly after `duration` (all timers/areas freed or
	  pooled).

---

### Task S-05 — Line AoE Bolt archetype (5 spells)

**Model**: `spell_bolt_line_aoe.glb` · **Spells**: Flame Lance, Glacier
Lance, Rift Lance, Toxic Lance, Briar Lance

- [x] Behavior: **shortest cast/acquisition range of all archetypes** — it
	  only triggers when an enemy gets close — but once fired, the
	  projectile does **not** stop at that enemy: it travels in a straight
	  line piercing and damaging **every** enemy in its path, despawning
	  only after `max_travel_distance` (30m — chosen over an arena-bounds
	  check; crosses the whole visible arena). *(New
	  `game_object/lance_projectile/` scene using
	  `spell_bolt_line_aoe.glb`, wired via the `.tres` `projectile_scene`
	  field like the chain. Flight is flattened to the ground plane so the
	  30m line never sinks/rises.)*
- [x] Hit handling: track already-hit enemies per projectile so each enemy
	  is damaged **once** per lance pass; apply the school perk on each
	  hit via the shared `HurtboxComponent.apply_hit` funnel. Longer hit
	  reach implemented as a segment check (half `hitbox_length` along the
	  flight axis, half `hitbox_width` sideways) with a matching
	  `BoxShape3D` on the scene's `CollisionShape3D`.
- [x] **Stacking**: not designed yet — exported `stack_max` shipped at
	  `1`, behavior `[TBD]`. No stacking behavior invented.
- [x] Exported/Inspector-tunable: `damage`, `range` (trigger range),
	  `projectile_speed`, `max_travel_distance`, `cooldown`, hitbox
	  length/width (exported on the lance scene). *(Defaults in
	  `Constants.LANCE_*`.)*
- [x] Create the 5 `.tres` files.

**Acceptance criteria**:
- [x] Lance only fires when an enemy is inside the short trigger range,
	  then visibly crosses the whole screen hitting every enemy on the
	  line exactly once each.
- [x] Trigger range vs. Standard Bolt range is clearly different in play
	  (Bolt fires at distant enemies the Lance ignores).

---

### Task S-06 — Wire all 20 spells into the draft cards [DONE]

> **Implementation notes**: the stacking eligibility filter and pick
> routing were built in S-00 and re-verified here end-to-end. Draft cards
> now show the school as a school-colored icon block + school-colored name
> (`draft_card.gd` reads `CombatUtils.get_damage_color()`); a real `icon`
> texture in a `.tres` automatically replaces the colored block — **no
> icon art exists in the repo yet**, so authoring the 20
> `icon_spell_<id>.png` files remains open as art-pass work (assets.md
> Section 4 naming). `SpellRegistry` logs its counts on startup:
> 23 spells (3 v1 + 20 catalog) + 3 stat upgrades = 26 draft cards.

**Refs**: `mechanics.md` Section 4 (draft), `epic_03_draft.md` (DraftManager,
SpellRegistry), `components.md` (`SpellDefinition` fields)

The draft pipeline is already generic (`SpellRegistry` directory-scans
`res://resources/spells/`, `DraftManager` builds cards from the pool), so
most of this task is making sure the 20 new `.tres` files are *complete
draft cards*, not just combat data:

- [x] Every one of the 20 `.tres` files fills in the draft-facing fields:
	  `spell_name`, `description` (one line naming the school perk, e.g.
	  "Slows enemies it pierces"), `icon`, `rarity`, and `tags`
	  (1-2 `SynergyTag`s per spell so the synergy counter keeps working —
	  e.g. damage spells → `[Offense]`, Nature spells → `[Armor]` or
	  `[Utility]`, tune per spell).
- [x] Confirm `SpellRegistry` loads all 20 automatically (plus the
	  existing v1 cards) — print count in `_ready()`, no manual list
	  anywhere.
- [x] Update `DraftManager`'s eligibility filter for stacking: a spell
	  already owned stays draftable while `stack_count < stack_max`, and
	  is filtered out once at `stack_max` (this replaces any "filter out
	  all owned spells" logic). AoE Area / Line Lance spells with
	  `stack_max = 1` therefore disappear from the pool after one pick —
	  correct per S-04/S-05.
- [x] Picking a card routes correctly per state: not owned → add to the
	  tower's active spell list (respecting the max-slot count) + start
	  its cooldown/orb/etc.; already owned → increment `stack_count` and
	  apply the archetype's stacking effect immediately (extra bolt next
	  cast, new orb spawns right away at its sequence angle).
- [x] Draft card UI shows the school: tint the card frame/icon with
	  `CombatUtils.get_damage_color(damage_type)` so Fire/Frost/Void/
	  Poison/Nature cards are tellable at a glance.
- [x] Rarity spread across the 20 (tunable, suggested start): Standard
	  Bolts = Common, Orbs = Common, Chain + Line Lance = Rare, AoE Area =
	  Epic — so draft weighting gives the stronger multi-target spells
	  appropriate scarcity.

**Acceptance criteria**:
- [x] A full run's drafts can offer any of the 20 spells; every card shows
	  name, description, icon, school color, and rarity.
- [x] Picking a duplicate Bolt/Chain/Orb visibly stacks (extra projectile
	  or new orb) instead of creating a duplicate entry.
- [x] A spell at `stack_max` never appears in a draft again that run.
- [x] Synergy tag counts increment on every pick, including duplicate
	  picks.

---

### After all tasks

- [x] Update the **Count tracker** in Section 4 (`Built` row + `[x]`
	  checkboxes) as each spell is confirmed in-engine.
- [x] Verify `SpellRegistry` reports 20 spell `.tres` files loaded.
- [x] Sanity pass on the range hierarchy in one live wave: Bolt fires
	  first (furthest), then Chain, then AoE Area placement, and Lance
	  last (closest) as an enemy approaches.
- [x] One full playtest run drafting only from the new pool: draft →
	  fight → draft, stacking a Bolt and an Orb at least twice each, to
	  confirm S-06's wiring end to end.

---

## 6. How It All Works In-Game (runtime reference)

> Living cheat sheet for the implemented system. If behavior and this
> section ever disagree, the code/`.tres` files are the truth — update
> this section to match.

### 6.1 What's in the draft pool

Every card comes from two auto-scanned folders — nothing is
hand-registered, dropping a `.tres` in is enough:

- `resources/spells/` → **exactly the 20 catalog spells** from Section 4.
  All v1-era spells (`basic_bolt`, `basic_aoe`, `basic_passive`) are
  **deleted**.
- `resources/upgrades/` → 3 stat upgrade cards: "Sharpening" (+15%
  damage, stackable ×4), "Quickened" (faster fire rate, ×3), "Fortify"
  (+200 HP, ×5). Epic-03-era cards, kept as slot-free filler. Delete
  their `.tres` files to remove them — no code involved.

A draft rolls 3 cards from those 23, weighted by rarity: **Common 60 /
Rare 30 / Epic 10** (`RARITY_WEIGHTS` in `draft_manager.gd`).
`SpellRegistry` prints the loaded counts on startup as a sanity check.

### 6.2 The tower's base attack

The tower starts every run with **Thorn Bolt** (Nature — it's the nature
tower) at stack 1, free, no slot used. Set per tower via
`starting_spell_id` in `tower_ancient_tower.tres` and the 5
`ancient_tower_lvl*.tres` files. Known quirk: the draft doesn't know
about the free copy, so Thorn Bolt can be drafted up to its `stack_max`
(3) times but only the first two picks add volley bolts (1 free + 2
drafted = cap).

### 6.3 The spell-slot limit

`Constants.MAX_SPELL_SLOTS = 6` — at most 6 *different* spells owned at
once. When all slots are full the draft **stops offering new spells**
(it never offers a pick that couldn't apply); you still get duplicates
of owned spells (stacking costs no slot) and stat upgrades. Change the
number in `autoloads/constants.gd`.

### 6.4 Archetype behavior at runtime

| Archetype | Scene folder | Fires when enemy within | Behavior |
|---|---|---|---|
| Standard Bolt (×5) | `standard_bolt/` | **10 m** (longest) | Straight shot at nearest enemy, 1.0s cooldown |
| Chain Bolt (×3) | `chain_bolt/` | 8 m | Spinning bolt, up to 3 hits (2 bounces, 4 m jump radius), 1.6s |
| Orb (×5) | `orb/` | — (no targeting) | Permanent body circling the tower, ticks anyone it touches every 0.5 s |
| AoE Area (×2) | `aoe_area/` | 6.5 m | 2.5 m zone at an enemy's position, ticks everyone inside for 4 s, 6s cooldown |
| Line AoE Bolt (×5) | `line_aoe_bolt/` | **4 m** (shortest) | Waits until something is close, then pierces the whole screen, each enemy hit once, 2.5s |

The range ladder (10 > 8 > 6.5 > 4) is deliberate: bolts are the
long-range workhorse, lances the close-range panic button. Felt
consequence: with high long-range damage, short-range spells rarely get
to fire — enemies die before closing to 6.5/4 m. Ranges are per-`.tres`.

### 6.5 Schools at runtime

Applied generically on every hit (`CombatUtils.apply_school_perk`, no
per-spell code): Fire burn 30%/s for 3 s · Frost slow 40% for 2 s ·
Void no status but ~18% higher damage baked in, never resistible ·
Poison 15%/s for 4 s + 20% slow for 2 s · Nature heals the tower for
18% of damage dealt. Re-applying refreshes the timer, never stacks.
Resistances are wired but **no enemy uses one yet** — every enemy
`.tres` has `resisted_school = -1`; set a school index and that enemy
takes half damage + half status from it (Void exempt by code).

### 6.6 Stacking

Duplicates bump a per-spell stack counter, never a second entry:
Bolts & Chains (×3) fire one more projectile per cast as a staggered
volley; Orbs (×8) add another orb on the same ring
(0°→180°→90°→270°→45°→…); AoE Area & Lances (×1) are one-pick — their
stacking is an open design decision. At `stack_max` a spell stops
appearing in drafts for the rest of the run.

### 6.7 Synergy tags

Most damage spells carry `[Offense]`, the Nature/heal spells `[Armor]`,
Glacier Lance and Blizzard `[Utility]`. Duplicate picks count too.
Thresholds at ×3 and ×5 grant the v1 bonuses (unchanged Epic-03 system).

### 6.8 Where to change things (no code, ever)

- **One spell's numbers** (damage, cooldown, range, radius, speed,
  `stack_max`, rarity, tags, orbit radius…): its `.tres` in
  `resources/spells/`, in the Inspector.
- **School perk strength, ring radii, default ranges, volley stagger,
  bounce/lance defaults**: `autoloads/constants.gd`.
- **Model look** (scale/rotation of bolt, lance, chain, orb, zone
  shards): exported `model_scale` / `model_rotation_degrees` /
  `shard_scale` fields on the archetype scenes in `scenes/game_object/`.
- **Slot limit / rarity weights**: `MAX_SPELL_SLOTS` in `constants.gd`,
  `RARITY_WEIGHTS` in `draft_manager.gd`.
- **Base attack**: `starting_spell_id` in the tower `.tres` files (all 6
  of them — base + lvl1..5).
- **Remove the stat upgrade cards**: delete `resources/upgrades/upgrade_*.tres`.
