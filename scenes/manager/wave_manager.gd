class_name WaveManager
extends Node

const ARENA_SPAWN_RADIUS := 5.5
const SPAWN_OFFSCREEN_MARGIN := 2.0
const SPAWN_RADIUS_STEP := 0.5
const SPAWN_RADIUS_MAX := 26.0
const SPAWN_HEIGHT := 0.6

@export var chapter: ChapterDefinition = null

var _active_enemies: Array = []
var _current_wave: int = 0
var _enemy_container: Node3D = null
var _wave_timer: Timer

func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.start_wave_requested.connect(start_wave)
	_wave_timer = Timer.new()
	_wave_timer.one_shot = true
	_wave_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	_wave_timer.timeout.connect(_on_wave_timeout)
	add_child(_wave_timer)

func start_wave(wave_number: int) -> void:
	_current_wave = wave_number
	_active_enemies.clear()
	_wave_timer.start(Constants.WAVE_DURATION_MAX)
	if wave_number >= chapter.wave_count:
		_spawn_enemy(_pick_boss())
		EventBus.boss_spawned.emit()
		EventBus.wave_started.emit(wave_number)
		return
	for definition in _get_wave_composition(wave_number):
		_spawn_enemy(definition)
	EventBus.wave_started.emit(wave_number)

func _pick_boss() -> EnemyDefinition:
	if chapter.boss_pool.is_empty():
		return null
	return chapter.boss_pool[randi() % chapter.boss_pool.size()]

func _get_wave_composition(wave_number: int) -> Array[EnemyDefinition]:
	var count: int = mini(Constants.WAVE_ENEMY_COUNT_BASE + wave_number, Constants.WAVE_ENEMY_COUNT_MAX)
	# Index 0 is the baseline enemy, index 1 is the fast/small variant (gated to
	# later waves), indices 2+ are additional basic-tier variants available from
	# wave 1 onward alongside index 0.
	var basic_pool: Array[EnemyDefinition] = [chapter.enemy_pool[0]]
	for i in range(2, chapter.enemy_pool.size()):
		basic_pool.append(chapter.enemy_pool[i])
	var fast: EnemyDefinition = chapter.enemy_pool[1] if chapter.enemy_pool.size() > 1 else null
	var table := WeightedTable.new()
	if fast == null or wave_number < Constants.WAVE_FAST_ENEMY_MIN_WAVE:
		for basic in basic_pool:
			table.add_item(basic, 1)
	else:
		for basic in basic_pool:
			table.add_item(basic, Constants.WAVE_BASIC_ENEMY_WEIGHT)
		table.add_item(fast, Constants.WAVE_FAST_ENEMY_WEIGHT)
	var composition: Array[EnemyDefinition] = []
	for i in count:
		composition.append(table.pick_item() as EnemyDefinition)
	return composition

func stop_wave() -> void:
	_wave_timer.stop()
	_active_enemies.clear()

func clear_all_enemies() -> void:
	_wave_timer.stop()
	for enemy in _active_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	_active_enemies.clear()

func _spawn_enemy(definition: EnemyDefinition) -> void:
	if _enemy_container == null or definition == null or definition.scene == null:
		return
	var enemy := definition.scene.instantiate() as Enemy
	enemy.definition = definition
	_enemy_container.add_child(enemy)
	enemy.apply_wave_scale(CombatUtils.calculate_wave_hp_scale(_current_wave), CombatUtils.calculate_wave_dmg_scale(_current_wave))
	enemy.global_position = _get_spawn_position()
	_active_enemies.append(enemy)

func _get_spawn_position() -> Vector3:
	var angle := randf() * TAU
	var dir := Vector3(cos(angle), 0.0, sin(angle))
	var camera := get_viewport().get_camera_3d()
	var radius := ARENA_SPAWN_RADIUS
	if camera != null:
		# Walk outward along the spawn direction until the point leaves the
		# camera frustum, then add a margin so the enemy's whole mesh starts
		# off-screen and visibly walks into view.
		while radius < SPAWN_RADIUS_MAX and camera.is_position_in_frustum(dir * radius + Vector3(0.0, SPAWN_HEIGHT, 0.0)):
			radius += SPAWN_RADIUS_STEP
		radius = minf(radius + SPAWN_OFFSCREEN_MARGIN, SPAWN_RADIUS_MAX)
	return dir * radius + Vector3(0.0, SPAWN_HEIGHT, 0.0)

func _on_enemy_died(enemy: Node, _position: Vector3) -> void:
	_active_enemies.erase(enemy)
	if _active_enemies.is_empty():
		_finish_wave()

func _on_wave_timeout() -> void:
	if _active_enemies.is_empty():
		return
	for enemy in _active_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	_active_enemies.clear()
	_finish_wave()

func _finish_wave() -> void:
	_wave_timer.stop()
	if _current_wave >= chapter.wave_count:
		EventBus.boss_died.emit()
	else:
		EventBus.wave_cleared.emit(_current_wave)
