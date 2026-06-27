class_name ChapterDefinition
extends Resource

@export var chapter_id: String = ""
@export var chapter_name: String = ""
@export var wave_count: int = 12
@export var enemy_pool: Array[EnemyDefinition] = []
@export var boss: EnemyDefinition = null
@export var arena_model_path: String = ""
