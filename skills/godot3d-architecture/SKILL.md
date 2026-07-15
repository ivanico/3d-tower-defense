---
name: godot3d-architecture
description: Use this skill whenever writing or reviewing GDScript for this project's gameplay objects (tower, enemies, projectiles, anything with health/movement/combat). Covers the component-based architecture rule — small single-purpose scripts attached as child nodes instead of one monolithic script per object — plus the data-driven Resource pattern for adding new towers/enemies/spells without writing new code. Trigger this skill before creating any new scene script, before adding a new feature to an existing enemy/tower script, and any time a script is approaching ~150 lines or is about to grow a new `if` branch to special-case one entity type.
---

# Godot 3D Architecture — Component Pattern & Data-Driven Content

This project's previous (abandoned) version failed partly because of
monolithic scripts: one `TowerBase.gd` and one `EnemyBase.gd` that each tried
to own movement, combat, animation, audio, and special-case logic for every
variant. This skill exists to stop that from happening again.

## The core rule

**A gameplay object is a thin scene + several small components, not one
script that does everything.**

If you're about to add logic to `tower.gd` or `enemy.gd` and that logic isn't
*specifically* "find my definition resource and apply its stats" or
"coordinate which component fires when," it almost certainly belongs in:

1. **An existing component**, if the behavior is genuinely the same kind of
   thing that component already does (e.g. a new way to take damage belongs
   in `HealthComponent`/`HurtboxComponent`, not in `enemy.gd`).
2. **A new component**, if it's a genuinely new capability that only some
   objects need (e.g. a boss's telegraphed heavy attack, a future shield
   mechanic, a burn DoT). Write it as its own small `Node`/`Node3D` script
   and attach it only to the scenes that need it.

Never add a boolean flag + an `if` branch to a shared component to
special-case one entity. `HealthComponent` should never contain
`if owner_type == "boss":`. That pattern is exactly how the old project's
scripts grew to 300+ lines.

## Anatomy of a component

```gdscript
# res://scenes/component/example_component.gd
class_name ExampleComponent
extends Node  # or Node3D / Area3D if it needs a transform or shape

## One sentence describing the single responsibility.

@export var some_config_value: float = 1.0

signal something_happened(payload)

func _ready() -> void:
    # Wire up to sibling components or the owner's signals here.
    pass

func do_the_one_thing(args) -> void:
    # The component's single public action.
    pass
```

Rules of thumb:
- **One responsibility per component.** If you can't describe it in one
  sentence without "and," split it.
- **Talk to siblings directly, talk to everything else through signals or
  `EventBus`.** A `HurtboxComponent` calling its sibling
  `HealthComponent.damage()` is fine — they're part of the same object. A
  `HealthComponent` reaching across the scene tree to tell the HUD to update
  is not — emit a signal, let the HUD (or `EventBus`) handle it.
- **Export config, don't hardcode it.** `speed`, `max_health`, `damage` — all
  `@export` so a `Definition` resource (see below) can drive them without
  script edits.
- **Implement `reset()` if the component will ever be pooled.** Pooled nodes
  get reused; anything with internal state needs a way to snap back to a
  clean baseline.

## The data-driven Resource pattern

New content should be data, not code. This project has exactly one generic
scene per object category — `tower.tscn`, `chap1_enemy_01.tscn` — and content variety
comes entirely from which `Resource` (`TowerDefinition`, `EnemyDefinition`,
`SpellDefinition`, etc.) is assigned to that scene instance at spawn time.

```gdscript
# resources/enemies/enemy_definition.gd
class_name EnemyDefinition
extends Resource

@export var enemy_id: String
@export var model_path: String
@export var base_hp: float
@export var base_speed: float
@export var base_damage: float
@export var attack_cooldown: float
@export var armor_type: int  # Constants.ArmorType
@export var xp_value: int
@export var is_boss: bool = false
@export var hold_height: float = 0.0  # 0 = ground-bound; >0 = flying hook
```

```gdscript
# scenes/game_object/enemy/enemy.gd — stays thin
extends CharacterBody3D
class_name Enemy

@export var definition: EnemyDefinition

@onready var health: HealthComponent = $HealthComponent
@onready var mover: MoveToTargetComponent = $MoveToTargetComponent

func _ready() -> void:
    _apply_definition()

func reset() -> void:
    _apply_definition()
    health.reset()

func _apply_definition() -> void:
    health.max_health = definition.base_hp
    mover.speed = definition.base_speed
    mover.hold_height = definition.hold_height
    # ...etc. This function's only job is "copy definition fields onto components."
```

**The test for whether this pattern is working**: adding a new enemy type
should be "create a new `.tres`, assign a new model" — zero new GDScript. If
you find yourself writing a new `.gd` file per enemy type (`EnemyGrunt.gd`,
`EnemyFlyer.gd`, ...), that's the old pattern creeping back in. The only time
a new script is justified is a genuinely new *behavior* component (see "The
core rule" above) — and even then, that component is written once and
attached to whichever `Definition`s need it, not duplicated per type.

## Resource mutation footgun

`Resource` files loaded via `load()`/`preload()` are **shared in memory**
across every place that loads them. Never mutate a loaded `Resource`'s
fields at runtime expecting it to be a fresh per-instance copy — you will
silently corrupt that `.tres` for every future load in the same session (and
on `ResourceSaver.save()`, on disk).

```gdscript
# WRONG — mutates the shared SpellDefinition for every tower that ever fires this spell again
func apply_rank_bonus(spell: SpellDefinition, rank: int) -> void:
    spell.damage *= 1.0 + (rank - 1) * 0.08

# RIGHT — compute a runtime-only derived value, leave the resource untouched
func get_effective_damage(spell: SpellDefinition, rank: int) -> float:
    return spell.damage * (1.0 + (rank - 1) * 0.08)
```

If you genuinely need a per-instance mutable copy, call
`resource.duplicate()` first — but for stat scaling like spell ranks or tower
stars, prefer computing the effective value at the point of use instead of
duplicating resources at all.

## Groups instead of stored references

Don't store a direct node reference to "the tower" or keep arrays of enemy
references that can go stale across scene reloads or pooling. Use Godot
groups and query at the moment you need them:

```gdscript
var tower := get_tree().get_first_node_in_group("tower")
var enemies := get_tree().get_nodes_in_group("enemies")
```

This is the same pattern the 2D survival-game reference project used
(`get_first_node_in_group("player")` everywhere instead of stored
references) — it decouples systems from scene structure and survives
pooling/reload cleanly.

## EventBus for cross-cutting concerns

Anything that isn't "two components on the same object talking to each
other" goes through the `EventBus` autoload (see `components.md` Section 3
for the full signal list). Audio, UI, meta-progression, and synergy systems
should all be *reactive* — they listen to `EventBus` signals rather than
being called directly by combat code. This is what lets you add a new
reaction to an existing event (e.g. "also play a screen shake on
`tower_damaged`") without touching the code that originally emitted it.

## When you're about to break this pattern

Stop and ask:
- "Am I adding an `if` branch to a shared component for one entity type?" →
  Make a new component instead.
- "Am I about to hardcode a stat that varies by enemy/spell/tower?" → Move it
  to the relevant `Definition` resource.
- "Is this script over ~150 lines?" → Something in it is probably doing two
  jobs. Split it.
- "Am I storing a direct reference to a node that might be pooled/reloaded?"
  → Use a group lookup instead.
