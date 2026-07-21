extends Area3D

## Chain Bolt archetype (spells.md Task S-02): homes to the nearest enemy,
## then bounces to the enemy closest to the one just hit, max `max_bounces`
## bounces. Despawns immediately (pool release, no fizzle) when no valid
## bounce target exists within `bounce_radius`.

const MAX_LIFETIME_SEC := 6.0
const HIT_DISTANCE := 0.5
const AIM_HEIGHT := Vector3(0, 0.6, 0)

# Swap in the Inspector if a spell later gets its own dedicated model.
@export var model_scene: PackedScene = preload("res://assets/models/spells/spell_chain_bolt.glb")
# Native size (~0.4m) is fine; exports here so it's tunable like the others.
@export var model_rotation_degrees: Vector3 = Vector3.ZERO
@export var model_scale: Vector3 = Vector3.ONE
@export var spin_speed_degrees: float = 720.0

var speed: float = 14.0
var damage: float = 0.0
var damage_type: int = Constants.DamageType.VOID
var bounce_radius: float = 4.0
var max_bounces: int = 2
var damage_falloff_per_bounce: float = 1.0

var _target: Node3D = null
var _hit_enemies: Array = []
var _initialized: bool = false
var _age: float = 0.0
var _model: Node3D = null

func _ready() -> void:
	if model_scene != null:
		_model = model_scene.instantiate()
		add_child(_model)
		_model.rotation_degrees = model_rotation_degrees
		_model.scale = model_scale

func initialize(start_pos: Vector3, target_pos: Vector3, spell: SpellDefinition) -> void:
	global_position = start_pos
	damage = spell.damage * GameState.tower_damage_multiplier * GameState.offense_damage_mult * GameState.get_spell_damage_multiplier(spell.spell_id)
	damage_type = spell.damage_type
	speed = spell.projectile_speed
	bounce_radius = spell.bounce_radius
	max_bounces = spell.max_bounces
	damage_falloff_per_bounce = spell.damage_falloff_per_bounce
	_hit_enemies.clear()
	_age = 0.0
	_apply_school_tint()
	_target = _nearest_enemy_to(target_pos, [])
	_initialized = _target != null
	if not _initialized:
		ObjectPool.release(self)

func _apply_school_tint() -> void:
	if _model == null:
		return
	var mat := CombatUtils.get_school_material(damage_type)
	for mi in _model.find_children("*", "MeshInstance3D", true, false):
		mi.material_override = mat

func _physics_process(delta: float) -> void:
	if not _initialized:
		return
	_age += delta
	if _age > MAX_LIFETIME_SEC or not is_instance_valid(_target):
		_despawn()
		return
	# Tumbling-shuriken spin — sells the motion regardless of travel direction.
	if _model != null:
		_model.rotate_y(deg_to_rad(spin_speed_degrees) * delta)
	var aim: Vector3 = _target.global_position + AIM_HEIGHT
	var to_target := aim - global_position
	var step := speed * delta
	if to_target.length() <= maxf(step, HIT_DISTANCE):
		_hit_current_target()
	else:
		global_position += to_target.normalized() * step

func _hit_current_target() -> void:
	var victim := _target
	var hurtbox := victim.find_child("HurtboxComponent") as HurtboxComponent
	if hurtbox:
		var falloff := pow(damage_falloff_per_bounce, _hit_enemies.size())
		hurtbox.apply_hit(damage * falloff, damage_type)
	_hit_enemies.append(victim)
	if _hit_enemies.size() > max_bounces:
		_despawn()
		return
	var next := _nearest_enemy_to(victim.global_position, _hit_enemies, bounce_radius)
	if next == null:
		_despawn()
		return
	_target = next

func _nearest_enemy_to(pos: Vector3, exclude: Array, max_dist: float = INF) -> Node3D:
	var best: Node3D = null
	var best_dist := max_dist
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or exclude.has(enemy):
			continue
		var dist: float = pos.distance_to(enemy.global_position)
		if dist <= best_dist:
			best_dist = dist
			best = enemy
	return best

func _despawn() -> void:
	_initialized = false
	ObjectPool.release(self)

func reset() -> void:
	_initialized = false
	_target = null
	_hit_enemies.clear()
	_age = 0.0
