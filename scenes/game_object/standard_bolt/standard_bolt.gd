extends Area3D

# Swap in the Inspector if a spell later gets its own dedicated model.
@export var model_scene: PackedScene = preload("res://assets/models/spells/spell_bolt_standard.glb")
# The glb is authored 1.53m long along +X; Godot forward is -Z. These bring
# it to ~0.5m flying nose-first. Tune in the Inspector, no script edits.
@export var model_rotation_degrees: Vector3 = Vector3(0, 90, 0)
@export var model_scale: Vector3 = Vector3.ONE / 3.0

var speed: float = 14.0
var damage: float = 0.0
var damage_type: int = Constants.DamageType.VOID
var pierce_count: int = 0

var _direction: Vector3 = Vector3.ZERO
var _hits: int = 0
var _initialized: bool = false
var _model: Node3D = null

func _ready() -> void:
	$VisibleOnScreenNotifier3D.screen_exited.connect(_on_screen_exited)
	if model_scene != null:
		_model = model_scene.instantiate()
		add_child(_model)
		_model.rotation_degrees = model_rotation_degrees
		_model.scale = model_scale

func initialize(start_pos: Vector3, target_pos: Vector3, spell: SpellDefinition) -> void:
	global_position = start_pos
	damage = spell.damage * GameState.tower_damage_multiplier * GameState.offense_damage_mult * GameState.get_spell_damage_multiplier(spell.spell_id)
	damage_type = spell.damage_type
	pierce_count = spell.pierce_count
	speed = spell.projectile_speed
	_direction = (target_pos - start_pos).normalized()
	look_at(global_position + _direction, Vector3.UP)
	_apply_school_tint()
	_hits = 0
	_initialized = true

func _apply_school_tint() -> void:
	if _model == null:
		return
	var mat := CombatUtils.get_school_material(damage_type)
	for mi in _model.find_children("*", "MeshInstance3D", true, false):
		mi.material_override = mat

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
