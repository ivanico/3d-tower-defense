extends Area3D

## Line AoE Bolt archetype (spells.md Task S-05): fired only when an enemy
## is inside the short trigger range, then travels in a straight line for
## max_travel_distance, piercing and damaging every enemy in its path
## exactly once. Never stops on hit — only despawns at the end of its line.

# Swap in the Inspector if a spell later gets its own dedicated model.
@export var model_scene: PackedScene = preload("res://assets/models/spells/spell_bolt_line_aoe.glb")
# The glb is authored ~2.4m long along +X, nose toward -X; -90 flies it
# nose-first (-Z) toward the enemy. Inspector-tunable.
@export var model_rotation_degrees: Vector3 = Vector3(0, -90, 0)
@export var model_scale: Vector3 = Vector3.ONE * 0.5
# Longer hit reach than the standard bolt (Section 1) — the piercing line.
@export var hitbox_length: float = Constants.LANCE_HITBOX_LENGTH
@export var hitbox_width: float = Constants.LANCE_HITBOX_WIDTH

var speed: float = 16.0
var damage: float = 0.0
var damage_type: int = Constants.DamageType.VOID
var max_travel: float = Constants.LANCE_MAX_TRAVEL

var _direction: Vector3 = Vector3.ZERO
var _traveled: float = 0.0
var _hit_enemies: Array = []
var _initialized: bool = false
var _model: Node3D = null

@onready var collision: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	if model_scene != null:
		_model = model_scene.instantiate()
		add_child(_model)
		_model.rotation_degrees = model_rotation_degrees
		_model.scale = model_scale
	# Own shape instance per lance — never mutate a shared shape resource.
	collision.shape = BoxShape3D.new()

func initialize(start_pos: Vector3, target_pos: Vector3, spell: SpellDefinition) -> void:
	global_position = start_pos
	# Flattened direction: the lance flies level across the whole arena
	# instead of inheriting the slight downward slope toward its trigger
	# enemy (which would sink it underground over 30m).
	var flat := target_pos - start_pos
	flat.y = 0.0
	if flat.length_squared() < 0.0001:
		ObjectPool.release(self)
		return
	_direction = flat.normalized()
	damage = spell.damage * GameState.tower_damage_multiplier * GameState.offense_damage_mult * GameState.get_spell_damage_multiplier(spell.spell_id)
	damage_type = spell.damage_type
	speed = spell.projectile_speed
	max_travel = spell.max_travel_distance
	(collision.shape as BoxShape3D).size = Vector3(hitbox_width, hitbox_width, hitbox_length)
	look_at(global_position + _direction, Vector3.UP)
	_apply_school_tint()
	_hit_enemies.clear()
	_traveled = 0.0
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
	var step := speed * delta
	global_position += _direction * step
	_traveled += step
	_check_hits()
	if _traveled >= max_travel:
		_initialized = false
		ObjectPool.release(self)

func _check_hits() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or _hit_enemies.has(enemy):
			continue
		# Segment check in the ground plane: within half the lance's length
		# along the flight axis AND half its width sideways.
		var offset: Vector3 = enemy.global_position - global_position
		offset.y = 0.0
		var longitudinal := offset.dot(_direction)
		if absf(longitudinal) > hitbox_length * 0.5:
			continue
		var lateral := (offset - _direction * longitudinal).length()
		if lateral > hitbox_width * 0.5:
			continue
		_hit_enemies.append(enemy)
		var hurtbox := enemy.find_child("HurtboxComponent") as HurtboxComponent
		if hurtbox:
			hurtbox.apply_hit(damage, damage_type)

func reset() -> void:
	_initialized = false
	_direction = Vector3.ZERO
	_traveled = 0.0
	_hit_enemies.clear()
