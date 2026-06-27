class_name StatUpgradeDefinition
extends Resource

@export var upgrade_id: String = ""
@export var upgrade_name: String = ""
@export var description: String = ""
@export var icon: Texture2D = null
@export var rarity: int = Constants.CardRarity.COMMON
@export var tags: Array[int] = []
@export var hp_bonus: float = 0.0
@export var damage_multiplier: float = 1.0
@export var fire_rate_multiplier: float = 1.0
@export var is_stackable: bool = true
@export var stack_max: int = 5
