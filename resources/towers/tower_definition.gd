class_name TowerDefinition
extends Resource

@export var tower_id: String = ""
@export var tower_name: String = ""
@export var icon: Texture2D = null

## False = a placeholder occupying a grid slot in the garage: drawn greyed out
## with a lock, not selectable, no 3D model expected. Set true once the tower has
## real art and stats. This is content availability, NOT player progress — what
## the player has earned is `MetaManager.owned_towers`.
@export var unlocked: bool = true

## Position in the garage grid. Explicit so renaming a .tres cannot reshuffle it.
@export var sort_order: int = 0

@export var model_path: String = ""
@export var base_hp: float = 1000.0
@export var base_damage: float = 20.0
@export var base_fire_rate: float = 1.0
@export var base_range: float = 8.0
@export var base_armor: float = 0.0
@export var starting_spell_id: String = ""
@export var passive_script: Script = null
@export var star_level_scenes: Array[PackedScene] = []
