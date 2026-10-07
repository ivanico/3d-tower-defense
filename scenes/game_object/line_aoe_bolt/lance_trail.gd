extends Node3D

## A rank-5 Lance's damaging trail (09-14). It grows behind the lance as it
## flies (`extend_to()`), stays Constants.LANCE_TRAIL_DURATION after the lance
## is done (`finish()`), and every LANCE_TRAIL_TICK_SEC hits every enemy within
## half the lance's width of the line for a share of the lance's damage,
## through apply_hit (armor table + school perk).
##
## Look: a flat strip in the school's ground colour (the AoE decal material).
## No particles. Instanced per lance (a lance flies ~2 s, ~1 trail at a time
## per lance spell), freed when done.

const AoeArea := preload("res://scenes/game_object/aoe_area/aoe_area.gd")

var damage: float = 0.0
var damage_type: int = Constants.DamageType.VOID
var width: float = 1.0

var _start: Vector3
var _end: Vector3
var _tick_accum: float = 0.0
var _linger: float = -1.0  # < 0 while the lance is still flying

@onready var strip: MeshInstance3D = $Strip


func start(from: Vector3, hit_damage: float, school: int, trail_width: float) -> void:
	_start = Vector3(from.x, 0.0, from.z)
	_end = _start
	damage = hit_damage
	damage_type = school
	width = trail_width
	strip.material_override = AoeArea._get_decal_material(school)
	_update_strip()


func extend_to(pos: Vector3) -> void:
	_end = Vector3(pos.x, 0.0, pos.z)
	_update_strip()


## The lance is gone; the trail stays for LANCE_TRAIL_DURATION, then frees.
func finish() -> void:
	if _linger < 0.0:
		_linger = Constants.LANCE_TRAIL_DURATION


func _physics_process(delta: float) -> void:
	if _linger >= 0.0:
		_linger -= delta
		if _linger <= 0.0:
			queue_free()
			return
	_tick_accum += delta
	if _tick_accum >= Constants.LANCE_TRAIL_TICK_SEC:
		_tick_accum -= Constants.LANCE_TRAIL_TICK_SEC
		_tick()


## Twice a second, so the group scan is cheap.
func _tick() -> void:
	var seg := _end - _start
	var seg_len_sq := seg.length_squared()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var p: Vector3 = enemy.global_position
		p.y = 0.0
		var t := 0.0 if seg_len_sq < 0.0001 else clampf((p - _start).dot(seg) / seg_len_sq, 0.0, 1.0)
		if p.distance_to(_start + seg * t) > width * 0.5:
			continue
		var hurtbox := enemy.find_child("HurtboxComponent") as HurtboxComponent
		if hurtbox:
			hurtbox.apply_hit(damage * Constants.LANCE_TRAIL_DAMAGE_PERCENT, damage_type,
					enemy.global_position + Vector3(0, 0.6, 0))


func _update_strip() -> void:
	var seg := _end - _start
	var length := maxf(seg.length(), 0.01)
	var mesh := strip.mesh as BoxMesh
	mesh.size = Vector3(width, 0.02, length)
	strip.global_position = (_start + _end) * 0.5 + Vector3(0, 0.03, 0)
	if seg.length_squared() > 0.0001:
		strip.look_at(strip.global_position + seg, Vector3.UP)
