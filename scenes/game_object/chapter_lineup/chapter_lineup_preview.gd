@tool
extends Node3D

## Editor-only lineup of one chapter (Epic 09 rule 2): its arena, plus its 5
## regular enemies in front and its 2 bosses behind, so all 7 fit the portrait
## game camera. Built from the ChapterDefinition, so each chapter's preview is
## just an inherited scene that sets `chapter` — a pool change in the .tres
## shows up here with no scene edit. Not meant to be run.
##
## Built nodes get no owner, so they're never saved into the .tscn (same idea
## as a widget's generated children). Placeholder tints (EnemyDefinition
## .model_tint) are applied here because enemy.gd, which applies them in game,
## doesn't run in the editor.

const ModelTint := preload("res://scripts/model_tint.gd")

## Same spacing as chap2_lineup_preview.tscn.
const ENEMY_X_STEP := 2.0
const ENEMY_Z := 1.0
const BOSS_X := 2.25
const BOSS_Z := -3.0

@export var chapter: ChapterDefinition:
	set(value):
		chapter = value
		_rebuild()

@onready var _lineup: Node3D = $Lineup


func _ready() -> void:
	_rebuild()


func _rebuild() -> void:
	if not is_inside_tree() or _lineup == null:
		return
	for child in _lineup.get_children():
		_lineup.remove_child(child)
		child.queue_free()
	if chapter == null:
		return
	if chapter.arena_scene:
		_lineup.add_child(chapter.arena_scene.instantiate())
	var count := chapter.enemy_pool.size()
	for i in count:
		var x := (i - (count - 1) / 2.0) * ENEMY_X_STEP
		_place(chapter.enemy_pool[i], Vector3(x, 0.0, ENEMY_Z))
	for i in chapter.boss_pool.size():
		_place(chapter.boss_pool[i], Vector3(BOSS_X * (i * 2 - 1), 0.0, BOSS_Z))


func _place(def: EnemyDefinition, pos: Vector3) -> void:
	if def == null or def.scene == null:
		return
	var enemy: Node3D = def.scene.instantiate()
	enemy.set("definition", def)
	enemy.name = def.enemy_id
	_lineup.add_child(enemy)
	pos.y = def.hold_height if def.is_flying else _rest_height(enemy)
	enemy.position = pos
	if Engine.is_editor_hint():
		ModelTint.apply(enemy, def.model_tint)


## Where a grounded enemy settles in game: its body sphere resting on the floor.
func _rest_height(enemy: Node3D) -> float:
	var body := enemy.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if body == null or not body.shape is SphereShape3D:
		return 0.0
	return (body.shape as SphereShape3D).radius * body.transform.basis.get_scale().y - body.position.y
