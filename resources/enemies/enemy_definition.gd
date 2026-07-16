class_name EnemyDefinition
extends Resource

@export var enemy_id: String = ""
@export var model_path: String = ""
@export var scene: PackedScene = null
@export var base_hp: float = 100.0
@export var base_speed: float = 1.5
@export var base_damage: float = 10.0
@export var attack_cooldown: float = 1.0
@export var armor_type: int = Constants.ArmorType.UNARMORED
@export var xp_value: int = 10
@export var is_boss: bool = false
@export var is_flying: bool = false
@export var hold_height: float = 0.5
