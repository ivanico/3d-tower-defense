class_name ChapterDefinition
extends Resource

@export var chapter_id: String = ""
@export var chapter_name: String = ""
@export var wave_count: int = 20
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
## One line under the picture on the chapter screen (chapter_select.tscn).
@export_multiline var description: String = ""
## Reward scaling (09-12): later chapters pay more of the same materials.
## Base Material amount x this (rounded). 1.0 = the plain checkpoint reward.
@export var base_reward_multiplier: float = 1.0
## Chance of each rare drop (Tower Material, each fought school's Scroll) x
## this, capped at 100%. A hit still gives RARE_MATERIAL_DROP_AMOUNT.
@export var rare_chance_multiplier: float = 1.0
## Difficulty (09-17): every enemy and boss in this chapter gets these on top
## of the per-wave growth. 1.0 = chapter 1. Applied in wave_manager._spawn_enemy().
@export var enemy_hp_multiplier: float = 1.0
@export var enemy_damage_multiplier: float = 1.0
