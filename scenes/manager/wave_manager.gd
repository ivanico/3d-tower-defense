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
var _wave_start_msec: int = 0

# Stall watchdog: while a wave is running, checks every WATCHDOG_INTERVAL
# seconds whether _active_enemies has shrunk since the last check. If not,
# dumps every remaining enemy's id/position/is_on_floor -- catches a stuck
# enemy (e.g. fallen off the arena edge) within seconds instead of waiting
# out the full WAVE_DURATION_MAX to find out something was wrong.
const WATCHDOG_INTERVAL := 5.0
var _watchdog_timer: Timer
var _watchdog_last_count: int = -1

func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.start_wave_requested.connect(start_wave)
	_wave_timer = Timer.new()
	_wave_timer.one_shot = true
	_wave_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	_wave_timer.timeout.connect(_on_wave_timeout)
	add_child(_wave_timer)
	_watchdog_timer = Timer.new()
	_watchdog_timer.wait_time = WATCHDOG_INTERVAL
	_watchdog_timer.one_shot = false
	_watchdog_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	_watchdog_timer.timeout.connect(_on_watchdog_tick)
	add_child(_watchdog_timer)

func start_wave(wave_number: int) -> void:
	print("DEBUGTEST start_wave(", wave_number, ")")
	_current_wave = wave_number
	_active_enemies.clear()
	_wave_start_msec = Time.get_ticks_msec()
	_watchdog_last_count = -1
	_watchdog_timer.start()
	_wave_timer.start(Constants.WAVE_DURATION_MAX)
	if wave_number >= chapter.wave_count:
		_spawn_enemy(_pick_boss())
		EventBus.boss_spawned.emit()
		EventBus.wave_started.emit(wave_number)
		print("DEBUGTEST   spawned BOSS")
		return
	var comp := _get_wave_composition(wave_number)
	for definition in comp:
		_spawn_enemy(definition)
	print("DEBUGTEST   spawned ", comp.size(), " enemies, active_enemies=", _active_enemies.size())
	EventBus.wave_started.emit(wave_number)

func _pick_boss() -> EnemyDefinition:
	if chapter.boss_pool.is_empty():
		return null
	return chapter.boss_pool[randi() % chapter.boss_pool.size()]

func _get_wave_composition(wave_number: int) -> Array[EnemyDefinition]:
	var exp_count := Constants.WAVE_ENEMY_COUNT_BASE * pow(Constants.WAVE_ENEMY_COUNT_GROWTH_RATE, wave_number - 1)
	var count: int = mini(roundi(exp_count), Constants.WAVE_ENEMY_COUNT_MAX)
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
	_watchdog_timer.stop()
	_active_enemies.clear()

func clear_all_enemies() -> void:
	_wave_timer.stop()
	_watchdog_timer.stop()
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
	var point := dir * radius
	# SPAWN_RADIUS_MAX (26.0) exceeds the arena floor's X half-extent (20) --
	# without this clamp, angles near the X axis can place the point past the
	# physical floor edge and the enemy falls through forever. Clamp
	# independent of the frustum-radius math above, which was never
	# floor-aware to begin with.
	point.x = clampf(point.x, -Constants.ARENA_FLOOR_HALF_EXTENTS.x, Constants.ARENA_FLOOR_HALF_EXTENTS.x)
	point.z = clampf(point.z, -Constants.ARENA_FLOOR_HALF_EXTENTS.y, Constants.ARENA_FLOOR_HALF_EXTENTS.y)
	return point + Vector3(0.0, SPAWN_HEIGHT, 0.0)

func _on_enemy_died(enemy: Node, _position: Vector3) -> void:
	var had := _active_enemies.has(enemy)
	_active_enemies.erase(enemy)
	print("DEBUGTEST enemy_died was_tracked=", had, " remaining=", _active_enemies.size())
	if _active_enemies.is_empty():
		_finish_wave()

func _on_wave_timeout() -> void:
	print("DEBUGTEST wave_timeout wave=", _current_wave, " remaining=", _active_enemies.size())
	if _active_enemies.is_empty():
		return
	for enemy in _active_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	_active_enemies.clear()
	_finish_wave()

func _finish_wave() -> void:
	var elapsed_sec := (Time.get_ticks_msec() - _wave_start_msec) / 1000.0
	print("DEBUGTEST _finish_wave wave=", _current_wave, " elapsed_sec=", elapsed_sec)
	_wave_timer.stop()
	_watchdog_timer.stop()
	if _current_wave >= chapter.wave_count:
		EventBus.boss_died.emit()
	else:
		EventBus.wave_cleared.emit(_current_wave)

func _on_watchdog_tick() -> void:
	var count := _active_enemies.size()
	if count == 0 or count != _watchdog_last_count:
		_watchdog_last_count = count
		return
	print("DEBUGTEST WATCHDOG stall wave=", _current_wave, " remaining=", count, " unchanged for ", WATCHDOG_INTERVAL, "s")
	for enemy in _active_enemies:
		if is_instance_valid(enemy):
			var on_floor: bool = enemy.is_on_floor() if enemy.has_method("is_on_floor") else false
			print("DEBUGTEST   stuck enemy=", enemy.name, " pos=", enemy.global_position, " is_on_floor=", on_floor)
		else:
			print("DEBUGTEST   stuck enemy=<freed but still tracked>")
