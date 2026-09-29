class_name ChapterDefinition
extends Resource

@export var chapter_id: String = ""
@export var chapter_name: String = ""
@export var wave_count: int = 12
@export var enemy_pool: Array[EnemyDefinition] = []
@export var boss_pool: Array[EnemyDefinition] = []
@export var arena_model_path: String = ""  # dead field (B10); arena_scene replaced it
## The arena this chapter is played on (a copy of chap1_arena.tscn with its own
## colours). game_world.gd swaps it in at run start.
@export var arena_scene: PackedScene
## Play order: chapter N+1 has the next sort_order. ChapterRegistry sorts by it,
## so renaming a .tres can never reorder chapters.
@export var sort_order: int = 0
## Artwork shown on the world map. Data-driven like TowerDefinition.icon — a new
## chapter sets its own here and the world map needs no code change.
@export var map_image: Texture2D
