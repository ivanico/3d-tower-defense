extends Area3D

## AoE Area archetype (spells.md Task S-04): a zone placed at an enemy's
## position at cast time. It never moves. Shows a ground decal immediately,
## rains staggered falling shards over its duration, and ticks damage every
## tick_interval to every enemy currently inside the radius — including
## enemies that walk in after placement. School perk applies per tick via
## the shared HurtboxComponent.apply_hit funnel.

const SHARD_DROP_TIME := 0.3
const SHARD_DROP_HEIGHT := 3.0
# Stop spawning shards this close to expiry so no shard is mid-drop when
# the zone cleans itself up.
const SHARD_SPAWN_CUTOFF := 0.5

# Swap in the Inspector if a spell later gets its own dedicated model.
@export var shard_model_scene: PackedScene = preload("res://assets/models/spells/spell_aoe_shard.glb")
# The glb shard is only 0.1m wide natively — nearly invisible at the fixed
# camera distance. Scaled up so the rain actually reads on screen.
@export var shard_scale: Vector3 = Vector3.ONE * 2.5

static var _decal_materials: Dictionary = {}

var spell: SpellDefinition = null

# Margin added to the collision cylinder beyond spell.aoe_radius, so it's
# always a safe superset of the exact flat-radius check in _tick_damage --
# this shape only narrows WHICH enemies get that check, never changes it.
const DETECTION_MARGIN := 0.5

var _age: float = 0.0
var _tick_accum: float = 0.0
var _shard_accum: float = 0.0
var _next_shard_in: float = 0.0
var _active: bool = false

# Enemies currently overlapping `collision`. Kept in sync by body_entered/
# body_exited instead of scanning `get_tree()`'s full enemy list every damage
# tick -- lower frequency than the other projectile scripts (once per
# spell.tick_interval, not every physics frame) but overlapping zones stack,
# so still worth avoiding the full scan (see the FPS-drop audit).
var _nearby_enemies: Array[Node3D] = []

@onready var decal: MeshInstance3D = $Decal
@onready var shards_root: Node3D = $ShardsRoot
@onready var collision: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	# Own shape instance per zone — never mutate a shared shape resource.
	collision.shape = CylinderShape3D.new()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies") and not _nearby_enemies.has(body):
		_nearby_enemies.append(body)

func _on_body_exited(body: Node3D) -> void:
	_nearby_enemies.erase(body)

func initialize(pos: Vector3, spell_def: SpellDefinition) -> void:
	spell = spell_def
	global_position = pos
	_age = 0.0
	_tick_accum = 0.0
	_shard_accum = 0.0
	_next_shard_in = 0.0
	decal.scale = Vector3(spell.aoe_radius, 1.0, spell.aoe_radius)
	decal.material_override = _get_decal_material(spell.damage_type)
	var shape := collision.shape as CylinderShape3D
	shape.radius = spell.aoe_radius + DETECTION_MARGIN
	shape.height = 2.0
	_active = true
	# The cast-moment tick fires in this same call, before Godot's physics
	# server has had a chance to process the shape/position change above and
	# populate `_nearby_enemies` via body_entered -- that list would read
	# empty here even if enemies are already standing in the zone. Not a
	# per-frame cost (once per cast), so the full scan is fine right here;
	# `_nearby_enemies` takes over for every recurring tick below, which IS
	# per-frame-adjacent and is what the FPS-drop audit targeted.
	_tick_damage(get_tree().get_nodes_in_group("enemies"))

func _physics_process(delta: float) -> void:
	if not _active:
		return
	_age += delta
	if _age >= spell.duration:
		_expire()
		return
	_tick_accum += delta
	if _tick_accum >= spell.tick_interval:
		_tick_accum -= spell.tick_interval
		_tick_damage(_nearby_enemies)
	if _age <= spell.duration - SHARD_SPAWN_CUTOFF:
		_shard_accum += delta
		if _shard_accum >= _next_shard_in:
			_shard_accum = 0.0
			_next_shard_in = randf_range(0.5, 1.5) * spell.shard_spawn_interval
			_spawn_shard()

func _tick_damage(enemies: Array) -> void:
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var flat := Vector2(enemy.global_position.x - global_position.x, enemy.global_position.z - global_position.z)
		if flat.length() > spell.aoe_radius:
			continue
		var hurtbox := enemy.find_child("HurtboxComponent") as HurtboxComponent
		if hurtbox:
			# Computed at tick time so mid-run upgrades apply to live zones.
			var dmg: float = spell.damage * GameState.tower_damage_multiplier * GameState.get_school_damage_multiplier(spell.damage_type) * GameState.offense_damage_mult * GameState.get_spell_damage_multiplier(spell.spell_id)
			hurtbox.apply_hit(dmg, spell.damage_type, enemy.global_position + Vector3(0, 0.6, 0))

func _spawn_shard() -> void:
	var shard := shard_model_scene.instantiate()
	shards_root.add_child(shard)
	shard.scale = shard_scale
	var mat := CombatUtils.get_school_material(spell.damage_type)
	for mi in shard.find_children("*", "MeshInstance3D", true, false):
		mi.material_override = mat
	# sqrt for a uniform spread over the disc, not clustered at the center.
	var r := sqrt(randf()) * spell.aoe_radius
	var a := randf() * TAU
	var ground := Vector3(cos(a) * r, 0.0, sin(a) * r)
	var spawn_pos := _get_shard_spawn_position(ground)
	# Position and rotation are set separately (never the whole transform) so
	# the scale set above is never touched.
	shard.position = spawn_pos
	shard.quaternion = _get_shard_rotation(ground, spawn_pos)
	var tw := shard.create_tween()
	tw.tween_property(shard, "position", ground, SHARD_DROP_TIME).set_ease(Tween.EASE_IN)
	tw.tween_callback(_on_shard_landed.bind(ground))

# Where a shard starts falling from, given where it will land. Default:
# straight above (a vertical drop).
func _get_shard_spawn_position(ground: Vector3) -> Vector3:
	return ground + Vector3(0, SHARD_DROP_HEIGHT, 0)

# How the shard is tilted to match its own fall path. Default: no tilt
# (straight vertical drop needs none). Shortest-arc rotation from "straight
# down" to the actual spawn->ground direction, so it's always exactly
# consistent with wherever _get_shard_spawn_position puts the shard.
func _get_shard_rotation(ground: Vector3, spawn_pos: Vector3) -> Quaternion:
	var drop_dir := (ground - spawn_pos).normalized()
	return Quaternion(Vector3.DOWN, drop_dir)

func _on_shard_landed(local_pos: Vector3) -> void:
	if not _active:
		return
	var burst := GPUParticles3D.new()
	shards_root.add_child(burst)
	burst.position = local_pos
	burst.one_shot = true
	burst.explosiveness = 1.0
	burst.amount = 8
	burst.lifetime = 0.4
	var proc := ParticleProcessMaterial.new()
	proc.initial_velocity_min = 1.0
	proc.initial_velocity_max = 2.0
	proc.direction = Vector3.UP
	proc.spread = 60.0
	proc.gravity = Vector3(0, -6.0, 0)
	burst.process_material = proc
	var mesh := SphereMesh.new()
	mesh.radius = 0.04
	mesh.height = 0.08
	mesh.material = CombatUtils.get_school_material(spell.damage_type)
	burst.draw_pass_1 = mesh
	burst.finished.connect(burst.queue_free)
	burst.emitting = true

func _expire() -> void:
	_active = false
	_clear_shards()
	ObjectPool.release(self)

func _clear_shards() -> void:
	for child in shards_root.get_children():
		child.queue_free()

func reset() -> void:
	_active = false
	spell = null
	_age = 0.0
	_nearby_enemies.clear()
	_clear_shards()

static func _get_decal_material(damage_type: int) -> StandardMaterial3D:
	if not _decal_materials.has(damage_type):
		var color := CombatUtils.get_damage_color(damage_type)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(color.r, color.g, color.b, 0.28)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_decal_materials[damage_type] = mat
	return _decal_materials[damage_type]
