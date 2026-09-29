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

## The chapter whose FIRST victory unlocks this tower (09-00.1: ch1 -> Frost,
## ch2 -> Void, ch3 -> Poison, ch4 -> Fire). Empty = not unlocked by a chapter
## (Ancient: owned from a fresh save). Changing the order is a .tres edit.
@export var unlock_chapter_id: String = ""

## Placeholder support for towers with no model of their own yet (Epic 09 rule
## 1). `preview_model_id` = the tower line whose .glb the garage preview borrows
## (e.g. "ancient_tower"); empty = this tower's own id. `model_tint` washes the
## borrowed model in a colour in game AND in the garage (alpha 0 = no tint).
## When the real model arrives: clear both, and swap the model ext_resource in
## each <id>_lvlN.tscn. No code change.
@export var preview_model_id: String = ""
@export var model_tint: Color = Color(1, 1, 1, 0)

@export var model_path: String = ""
@export var base_hp: float = 1000.0
@export var base_damage: float = 20.0
@export var base_fire_rate: float = 1.0
@export var base_range: float = 8.0
@export var base_armor: float = 0.0
@export var starting_spell_id: String = ""
@export var passive_script: Script = null
@export var star_level_scenes: Array[PackedScene] = []
