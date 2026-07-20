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
@export var projectile_scene: PackedScene = null
@export var passive_value: float = 0.0
# Duplicate-pick stacking (spells.md Task S-00): how many times this spell
# can be drafted in one run. 1 = single pick, never offered again once owned.
# What each extra stack DOES is per-archetype (extra bolt, extra orb, ...).
@export var stack_max: int = 1
