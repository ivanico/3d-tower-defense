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

# Enemies currently overlapping this bolt's own CollisionShape3D (radius 1.5,
# see standard_bolt.tscn -- deliberately much bigger than the 0.5 precise hit
# check below, so it's always a safe superset). Kept in sync by body_entered/
# body_exited instead of scanning `get_tree()`'s full enemy list every
# physics frame per bolt -- with volley-stacked casts that's several bolts x
# every enemy in the wave, every tick (see the FPS-drop audit). Narrows WHICH
# enemies get the exact distance check, doesn't change the check itself, so
# which enemies actually get hit is unchanged.
var _nearby_enemies: Array[Node3D] = []

func _ready() -> void:
	$VisibleOnScreenNotifier3D.screen_exited.connect(_on_screen_exited)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if model_scene != null:
		_model = model_scene.instantiate()
		add_child(_model)
		_model.rotation_degrees = model_rotation_degrees
		_model.scale = model_scale

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies") and not _nearby_enemies.has(body):
		_nearby_enemies.append(body)

func _on_body_exited(body: Node3D) -> void:
	_nearby_enemies.erase(body)

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
	for enemy in _nearby_enemies:
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
	_nearby_enemies.clear()
