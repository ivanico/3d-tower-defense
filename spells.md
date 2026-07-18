# Spells — Visual Asset Reference

> **Scope of this file**: defines the reusable *shape archetypes* used across
> all spell visuals, so adding a new spell later means picking an archetype +
> a color/type, not modeling something new. Follows the same pipeline as
> `assets.md`: base shapes modeled in Blender, exported as `.glb`, imported
> into Godot, then shaded/animated/particle'd in-engine (shared toon/emissive
> shader + `GPUParticles3D`, tinted per damage type via the same
> `CombatUtils.get_damage_color()` lookup used elsewhere in the project).
>
> Individual spells (Bolt of Fire, Blizzard, Chain of Chaos, etc.) get added
> below in **Section 2** once each archetype's base shape/shader/particle
> setup is built and confirmed to look good. Section 1 is the foundation;
> don't add spell entries until the archetype they depend on is done.

---

## 1. Shape Archetypes (v1)

Five base shapes, modeled once each in Blender, reused by every spell of
that category. Color and damage type are never baked into the model — they
come from the shared shader at spawn time, so one `.glb` per archetype
covers every elemental variant.

### 1. Chain Bolt (bounce shape)

- **Shape**: a "C"-curved bolt/arc — distinct silhouette from the straight
  bolt so bounce-type spells read differently on screen even before the
  color registers.
- **Used for**: any spell that bounces from enemy to enemy within a radius
  (e.g. a Sedge-type chain spell, a Chaos-type chain spell).
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
- **Used for**: default single-target projectile spells across all damage
  types (fire, frost, shadow, etc.) — this is the workhorse shape most
  spells will use.
- **File**: `res://assets/models/spells/spell_bolt_standard.glb`

### 3. Orb (simple circular shape)

- **Shape**: a simple sphere/circle — deliberately minimal so it stays
  cheap to spawn in numbers (used for orbiting spells, which may have
  several instances alive at once).
- **Used for**: orbs that spin/orbit around the tower, one color per
  damage type (Orb of Chaos, Orb of Frost, etc.).
- **Behavior notes**: orbit motion (radius, speed, angle offset per orb) is
  a Godot script concern, not baked into the model.
- **File**: `res://assets/models/spells/spell_orb.glb`

### 4. Sky-Drop AoE (falling shard/bolt shape)

- **Shape**: small crystal shard or mini-bolt shape, dropped from above
  onto a target position/area.
- **Used for**: AoE spells where projectiles rain down onto an area over
  time (Blizzard, Rain of Fire).
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
- **File**: `res://assets/models/spells/spell_sky_shard.glb`

### 5. Line AoE Bolt (piercing beam shape)

- **Shape**: a larger version of the Standard Bolt (#2) — same silhouette
  language, scaled up, so it's visually clear it's "the big version" of a
  normal bolt rather than an unrelated shape.
- **Used for**: line-AoE spells that travel in a single straight line and
  hit every enemy in their path (as opposed to a single-target bolt).
- **Behavior notes**: needs a longer collision/hitbox shape than the
  standard bolt to match its piercing-line hit detection.
- **File**: `res://assets/models/spells/spell_bolt_line_aoe.glb`

---

## 2. Individual Spells (fill in as built)

Once an archetype above is modeled + shaded + particle'd and confirmed to
look good, list actual spells here — archetype + damage type/color is all
that should be needed per entry.

| Spell Name | Archetype | Damage Type / Color | Notes |
|---|---|---|---|
| *(add spells here once ready)* | | | |

> **Extend later by**: adding a row per spell — no new model/shader needed
> unless a spell genuinely doesn't fit any of the 5 archetypes above.
