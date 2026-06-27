---
name: godot3d-combat
description: Use this skill whenever implementing or modifying combat-related code in this project — projectiles, AoE zones, hitboxes/hurtboxes, damage calculation, targeting, object pooling for combat entities, or wave/enemy spawning. Trigger this before writing any new spell behavior, any new damage-dealing code path, or any code that spawns/despawns enemies or projectiles. Also trigger when something says "queue_free" near an enemy or projectile, since pooling should be used instead once Epic 02 is complete.
---

# Godot 3D Combat Systems

Real 3D physics (`Area3D`, `CharacterBody3D`, `Vector3`) drives all combat in
this project — no faked 2D math. This skill covers the patterns specific to
doing tower-defense-style combat correctly in actual 3D.

## The damage pipeline — one path, no exceptions

Every hit in this game resolves through exactly one function:

```gdscript
# scripts/utils/combat_utils.gd
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

## Hitbox / Hurtbox — who does what

- **`HitboxComponent`** (`Area3D`): pure data. `damage`, `damage_type`. No
  logic. Attached to the thing dealing damage (projectile, AoE zone, melee
  swing).
- **`HurtboxComponent`** (`Area3D`): the thing that *receives* the hit. On
  `area_entered`, reads the hitbox's damage/type, calls
  `CombatUtils.calculate_damage()`, applies the result to its sibling
  `HealthComponent`. Attached to the thing taking damage (tower, every
  enemy).

This split means a projectile never needs to know what kind of armor its
target has, and a hurtbox never needs to know what spell fired the hit that's
currently overlapping it. Each side only knows its own half.

```gdscript
# hurtbox_component.gd
extends Area3D
class_name HurtboxComponent

@export var armor_type: int  # Constants.ArmorType

@onready var health: HealthComponent = $"../HealthComponent"

func _ready() -> void:
    area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
    if not area.has_method("get_damage_payload"):
        return
    var dmg: float = area.damage
    var dtype: int = area.damage_type
    var final_amount := CombatUtils.calculate_damage(dmg, dtype, armor_type)
    health.damage(final_amount)
```

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

## AoE — query overlapping areas, don't iterate every enemy

```gdscript
func _apply_damage() -> void:
    for area in get_overlapping_areas():
        if area is HurtboxComponent and area.get_parent().is_in_group("enemies"):
            var final := CombatUtils.calculate_damage(damage, damage_type, area.armor_type)
            area.health.damage(final)
```

Let the `Area3D`'s own collision shape define "what's in range" — don't
manually loop over every active enemy and do a distance check unless you have
a specific reason `Area3D` overlap won't work (e.g. checking against a much
larger group where the overlap check itself becomes the bottleneck — that's
a `epic_08_polish.md`-stage optimization concern, not a default).

## Targeting

`TargetingComponent` maintains a list via a range-trigger `Area3D`'s
`body_entered`/`body_exited`, not by scanning all enemies every frame:

```gdscript
var _enemies_in_range: Array[Node3D] = []

func _on_range_entered(body: Node3D) -> void:
    if body.is_in_group("enemies"):
        _enemies_in_range.append(body)

func _on_range_exited(body: Node3D) -> void:
    _enemies_in_range.erase(body)

func get_target() -> Node3D:
    match mode:
        Constants.TargetMode.CLOSEST:
            return _closest_of(_enemies_in_range)
    return null
```

New target modes are new `match` cases. Resist the urge to write a generic
"sortable by any criteria" targeting framework before you actually need a
second mode — `mechanics.md` explicitly scopes v1 to closest-only.

## Object pooling — never `queue_free()` a combat entity after Epic 02

```gdscript
# get
var proj: Node3D = ObjectPool.get(preload("res://scenes/spells/Projectile.tscn"))
proj.global_position = start_pos
proj.initialize(start_pos, target_pos, spell)

# release — inside the projectile/enemy's own script, on its terminal condition
func _on_screen_exited() -> void:
    ObjectPool.release(self)
```

`ObjectPool.release()` must, at minimum: hide the node, disable every
`CollisionShape3D` child (a 3D-specific detail — don't forget this is
`CollisionShape3D` not `CollisionShape2D`), and return it to the pool's
available list. Whatever owns the node needs a `reset()` method that
restores it to a clean state before reuse (full HP, cleared velocity, fresh
`Definition` applied if it's being reused for a different enemy type).

If you ever see `queue_free()` called on an enemy, projectile, AoE zone, or
damage number after Epic 02 is complete, that's a regression — flag it.

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
