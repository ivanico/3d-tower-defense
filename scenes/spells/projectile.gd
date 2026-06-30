extends Area3D

var speed: float = 14.0
var damage: float = 0.0
var damage_type: int = Constants.DamageType.NORMAL
var pierce_count: int = 0

var _direction: Vector3 = Vector3.ZERO
var _hits: int = 0
var _initialized: bool = false

func _ready() -> void:
	$VisibleOnScreenNotifier3D.screen_exited.connect(_on_screen_exited)

func initialize(start_pos: Vector3, target_pos: Vector3, spell: SpellDefinition) -> void:
	global_position = start_pos
	damage = spell.damage * GameState.tower_damage_multiplier
	damage_type = spell.damage_type
	pierce_count = spell.pierce_count
	_direction = (target_pos - start_pos).normalized()
	_hits = 0
	_initialized = true

func _physics_process(delta: float) -> void:
	if not _initialized:
		return
	global_position += _direction * speed * delta
	_check_hits()

func _check_hits() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if global_position.distance_to(enemy.global_position + Vector3(0, 0.6, 0)) > 0.5:
			continue
		var hurtbox := enemy.find_child("HurtboxComponent") as HurtboxComponent
		if hurtbox:
			hurtbox.apply_hit(damage, damage_type)
		_hits += 1
		if _hits > pierce_count:
			_initialized = false
			ObjectPool.release(self)
			return

func _on_screen_exited() -> void:
	_initialized = false
	ObjectPool.release(self)

func reset() -> void:
	_initialized = false
	_direction = Vector3.ZERO
	_hits = 0
