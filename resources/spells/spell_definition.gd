class_name SpellDefinition
extends Resource

@export var spell_id: String = ""
@export var spell_name: String = ""
@export var description: String = ""
@export var icon: Texture2D = null
@export var rarity: int = Constants.CardRarity.COMMON
@export var spell_category: int = Constants.SpellCategory.PROJECTILE
@export var damage_type: int = Constants.DamageType.VOID
@export var tags: Array[int] = []
@export var damage: float = 20.0
@export var cooldown: float = 1.0
@export var range: float = 8.0
@export var aoe_radius: float = 0.0
@export var pierce_count: int = 0
@export var projectile_speed: float = 14.0
@export var projectile_scene: PackedScene = null
# Chain Bolt archetype fields (spells.md Task S-02) — ignored by other archetypes.
@export var bounce_radius: float = Constants.CHAIN_BOUNCE_RADIUS
@export var max_bounces: int = Constants.CHAIN_MAX_BOUNCES
@export var damage_falloff_per_bounce: float = 1.0
# Orb archetype fields (spells.md Task S-03) — ignored by other archetypes.
@export var orbit_radius: float = 2.0
@export var orbit_speed: float = Constants.ORB_ORBIT_SPEED_DEG
@export var orb_hit_interval: float = Constants.ORB_HIT_INTERVAL
# AoE Area archetype fields (spells.md Task S-04) — ignored by other archetypes.
@export var duration: float = Constants.AOE_AREA_DURATION
@export var tick_interval: float = Constants.AOE_AREA_TICK_INTERVAL
@export var shard_spawn_interval: float = Constants.AOE_AREA_SHARD_INTERVAL
# Line AoE Bolt archetype fields (spells.md Task S-05) — ignored by other archetypes.
@export var max_travel_distance: float = Constants.LANCE_MAX_TRAVEL
@export var passive_value: float = 0.0
# Duplicate-pick stacking (spells.md Task S-00): how many times this spell
# can be drafted in one run. 1 = single pick, never offered again once owned.
# What each extra stack DOES is per-archetype (extra bolt, extra orb, ...).
@export var stack_max: int = 1
