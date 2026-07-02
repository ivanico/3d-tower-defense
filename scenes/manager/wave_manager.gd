class_name WaveManager
extends Node

const CHAP1_ENEMY_01_SCENE := preload("res://scenes/game_object/chap1/chap1_enemy_01/chap1_enemy_01.tscn")
const ARENA_SPAWN_RADIUS := 5.5

var _active_enemies: Array = []
var _current_wave: int = 0
var _enemy_container: Node3D = null
var _enemy_table := WeightedTable.new()

func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.start_wave_requested.connect(start_wave)
	_enemy_table.add_item(CHAP1_ENEMY_01_SCENE, 10)

func start_wave(wave_number: int) -> void:
	_current_wave = wave_number
	_active_enemies.clear()
	for i in 3:
		_spawn_enemy()
	EventBus.wave_started.emit(wave_number)

func stop_wave() -> void:
	_active_enemies.clear()

func clear_all_enemies() -> void:
	for enemy in _active_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	_active_enemies.clear()

func _spawn_enemy() -> void:
	if _enemy_container == null:
		return
	var scene := _enemy_table.pick_item() as PackedScene
	if scene == null:
		return
	var enemy := scene.instantiate() as Enemy
	_enemy_container.add_child(enemy)
	enemy.global_position = _get_spawn_position()
	_active_enemies.append(enemy)

func _get_spawn_position() -> Vector3:
	var angle := randf() * TAU
	return Vector3(cos(angle) * ARENA_SPAWN_RADIUS, 0.6, sin(angle) * ARENA_SPAWN_RADIUS)

func _on_enemy_died(enemy: Node, _position: Vector3) -> void:
	_active_enemies.erase(enemy)
	if _active_enemies.is_empty():
		EventBus.wave_cleared.emit(_current_wave)
