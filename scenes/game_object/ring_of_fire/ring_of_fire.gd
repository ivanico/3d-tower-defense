extends Area3D

## Fire's ult zone, Ring of Fire (09-13): a thin ring at `radius` around the
## tower for `duration`. Every enemy that crosses it walking IN takes one Fire
## hit through apply_hit (armor table + Fire's normal burn). Star 5
## (`burning_bonus` > 0): that hit deals +bonus on an enemy already burning.
## Enemies already inside when it appears aren't hit until they leave and cross
## again.
##
## Broad phase like aoe_area.gd: a cylinder a little wider than the ring keeps
## the list of nearby enemies, so it never scans every enemy each frame.

const AoeArea := preload("res://scenes/game_object/aoe_area/aoe_area.gd")
## How far outside the ring the broad-phase cylinder reaches.
const DETECTION_MARGIN := 1.0

var radius: float = Constants.RING_OF_FIRE_RADIUS
var duration: float = 6.0
var damage: float = Constants.RING_OF_FIRE_DAMAGE
var burning_bonus: float = 0.0

var _age: float = 0.0
var _nearby: Array[Node3D] = []
## instance id -> was the enemy outside the ring last frame?
var _was_outside: Dictionary = {}

@onready var ring_mesh: MeshInstance3D = $Ring
@onready var collision: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	collision.shape = CylinderShape3D.new()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	ring_mesh.material_override = AoeArea._get_decal_material(Constants.DamageType.FIRE)


func start(pos: Vector3, ring_radius: float, ring_duration: float, hit_damage: float, bonus: float) -> void:
	global_position = pos
	radius = ring_radius
	duration = ring_duration
	damage = hit_damage
	burning_bonus = bonus
	var torus := ring_mesh.mesh.duplicate() as TorusMesh
	torus.inner_radius = radius - 0.2
	torus.outer_radius = radius + 0.2
	ring_mesh.mesh = torus
	var shape := collision.shape as CylinderShape3D
	shape.radius = radius + DETECTION_MARGIN
	shape.height = 2.0
	# Whoever is already around when it appears: remember which side they're on.
	for enemy in get_tree().get_nodes_in_group("enemies"):
		_was_outside[enemy.get_instance_id()] = _flat_distance(enemy) > radius


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies") and not _nearby.has(body):
		_nearby.append(body)
		if not _was_outside.has(body.get_instance_id()):
			_was_outside[body.get_instance_id()] = _flat_distance(body) > radius


func _on_body_exited(body: Node3D) -> void:
	_nearby.erase(body)


func _physics_process(delta: float) -> void:
	_age += delta
	if _age >= duration:
		queue_free()
		return
	for enemy in _nearby:
		if not is_instance_valid(enemy) or not enemy.is_in_group("enemies"):
			continue
		var id := enemy.get_instance_id()
		var outside := _flat_distance(enemy) > radius
		if _was_outside.get(id, true) and not outside:
			_hit(enemy)
		_was_outside[id] = outside


func _hit(enemy: Node3D) -> void:
	var hurtbox := enemy.find_child("HurtboxComponent")
	if hurtbox == null:
		return
	var dmg := damage
	var status := enemy.find_child("StatusEffectComponent")
	if burning_bonus > 0.0 and status and status.is_burning():
		dmg *= 1.0 + burning_bonus
	hurtbox.apply_hit(dmg, Constants.DamageType.FIRE, enemy.global_position + Vector3(0, 0.6, 0))


func _flat_distance(enemy: Node3D) -> float:
	return Vector2(enemy.global_position.x - global_position.x, enemy.global_position.z - global_position.z).length()
