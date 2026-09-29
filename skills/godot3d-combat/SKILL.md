---
name: godot3d-combat
description: Use this skill whenever implementing or modifying combat-related code in this project — projectiles, AoE zones, hurtboxes/apply_hit, damage calculation, targeting, object pooling for projectiles, or wave/enemy spawning. Trigger this before writing any new spell behavior, any new damage-dealing code path, or any code that spawns/despawns enemies or projectiles. Enemies queue_free (not pooled); projectiles are pooled.
---

# Godot 3D Combat Systems

Real 3D physics (`Area3D`, `CharacterBody3D`, `Vector3`) drives all combat in
this project — no faked 2D math. This skill covers the patterns specific to
doing tower-defense-style combat correctly in actual 3D.

## The damage pipeline — one path, no exceptions

Every hit in this game resolves through exactly one function:

```gdscript
# scripts/combat_utils.gd
static func calculate_damage(base_amount: float, damage_type: int, armor_type: int) -> float:
    var multiplier := DAMAGE_TABLE[damage_type][armor_type]
    return base_amount * multiplier
```

This function is a **table lookup, never a branch tree**. If you're tempted
to write:

```gdscript
# WRONG
if damage_type == Constants.DamageType.SIEGE and armor_type == Constants.ArmorType.HEAVY:
    return base_amount * 2.0
elif damage_type == Constants.DamageType.SIEGE:
    return base_amount * 0.5
# ...
```

— stop, and add a row/column to the table in `project.md` instead. The whole
point of the table is that adding a new `DamageType` or `ArmorType` is a data
change, not a code change. Synergy modifiers (e.g. `[Armor]×3`'s 15% damage
reduction) layer on top of this function's result as a separate multiplier
step, read from `GameState` flags — they don't get baked into the table
itself, since they're temporary per-run state, not permanent type
relationships.

## Hitbox / Hurtbox — how hits actually land (hybrid, verified 2026-09-29)

This project does **not** use `area_entered` for hits. `HitboxComponent`
exists in `scenes/component/` but no scene instances it. The real path:

1. **Broad phase**: each archetype (`standard_bolt.gd`, `chain_bolt.gd`,
   `orb.gd`, `aoe_area.gd`, `line_aoe_bolt.gd`) keeps a short list of nearby
   enemies via its own `body_entered` / `body_exited`, so it never scans
   every enemy each frame.
2. **Precise check**: in `_physics_process`, a `distance_to()` test (or a
   segment test for the lance) against that list.
3. **The one funnel**: call the target's
   `HurtboxComponent.apply_hit(damage, damage_type, hit_world_pos)`.

```gdscript
# hurtbox_component.gd (real code, trimmed)
func apply_hit(hit_damage: float, hit_damage_type: int, hit_world_pos: Vector3) -> void:
    var resist_mult := 1.0
    if hit_damage_type == resisted_school and hit_damage_type != Constants.DamageType.VOID:
        resist_mult = Constants.SCHOOL_RESIST_MULT   # boss-only by data rule
    var final_dmg := CombatUtils.calculate_damage(hit_damage, hit_damage_type, armor_type) * resist_mult
    health.damage(final_dmg)
    CombatUtils.apply_school_perk(final_dmg, hit_damage_type, get_parent(), resist_mult)
    _spawn_damage_number(...)
```

**Any new hit source** (rank-5 splash, lance trail, ult damage) must call
`apply_hit()` too, so the table, resist, perk and damage number all apply
in one place. Why not `area_entered`: overlap signals proved unreliable for
fast, small or runtime-resized `Area3D`s in Godot 4.4.

## Real 3D projectile movement

Straight-line projectiles travel at a fixed height in a straight 3D vector —
no arc, no gravity:

```gdscript
func initialize(start_pos: Vector3, target_pos: Vector3, spell: SpellDefinition) -> void:
    global_position = start_pos
    _direction = (target_pos - start_pos).normalized()
    look_at(global_position + _direction, Vector3.UP)
    hitbox.damage = spell.damage * GameState.tower_damage_multiplier
    hitbox.damage_type = spell.damage_type

func _physics_process(delta: float) -> void:
    global_position += _direction * speed * delta
```

Arcing projectiles (siege/bomb-style spells) compute a parabolic Y path
instead — this is the actual payoff of doing real 3D rather than faking it:

```gdscript
# arc_projectile.gd — travel time based, not fixed speed
var _start: Vector3
var _target: Vector3
var _flight_time: float
var _elapsed: float = 0.0
var _arc_height: float = 2.0

func _physics_process(delta: float) -> void:
    _elapsed += delta
    var t: float = clamp(_elapsed / _flight_time, 0.0, 1.0)
    var flat := _start.lerp(_target, t)
    var arc := sin(t * PI) * _arc_height
    global_position = flat + Vector3(0, arc, 0)
    if t >= 1.0:
        _on_impact()
```

Don't reach for Godot's rigid-body physics/gravity simulation for this —
explicit parabola math gives predictable, designer-tunable arcs instead of
physics-sim unpredictability.

## AoE — keep a nearby list, tick it, hit through `apply_hit()`

`aoe_area.gd` (Blizzard / Rain of Fire) keeps the enemies inside its radius
via `body_entered` / `body_exited`, and every `tick_interval` calls
`apply_hit()` on each of them. Damage is computed at tick time, so mid-run
upgrades apply to live zones. Reuse or extend this for any new zone (e.g.
the Poison ult's Plague Cloud); don't copy it.

## Targeting

`TargetingComponent` keeps an in-range list via its range `Area3D`'s
`body_entered` / `body_exited` (no full scan per frame).
`get_targets(count, max_distance)` returns up to `count` **random** distinct
enemies within the spell's own `range` (`targeting_component.gd:42–44`,
`shuffle()`), and `get_target()` = `get_targets(1)`. There is **no target
mode**: `TargetMode.CLOSEST` was removed after it turned out to be unwired
(`mechanics.md` §2). If a mode is wanted again, wire it all the way through.
Orb doesn't target at all.

## Object pooling — projectiles yes, enemies no

Projectiles, AoE zones and damage numbers go through `ObjectPool`
(`acquire(scene)` / `release(node)`; `release()` calls `_on_pool_released()`
if the node has one). **Enemies are deliberately not pooled**: each wave
`instantiate()`s fresh enemy scenes (`wave_manager.gd` `_spawn_enemy()`),
and `DeathFXComponent` `queue_free()`s them after the death tween
(`restructure.md` §4). `queue_free()` on an enemy is correct, not a
regression. `queue_free()` on a pooled projectile/zone/damage number is.

`ObjectPool.release()` must hide the node, disable every `CollisionShape3D`
child and return it to the pool. The owner needs a `reset()` that restores
a clean state before reuse.

## Deferred calls for structural changes mid-physics-step

Freeing/reparenting/disabling collision during a physics callback
(`_on_area_entered`, `take_damage` triggering death) can throw "can't change
state during physics processing" errors. Defer it:

```gdscript
func damage(amount: float) -> void:
    current_health = max(current_health - amount, 0.0)
    health_changed.emit(current_health, max_health)
    if current_health <= 0:
        call_deferred("_die")

func _die() -> void:
    died.emit()
```
