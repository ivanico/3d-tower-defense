class_name HitFlashComponent
extends Node

## Flashes the parent's mesh white briefly on damage, without ever touching
## the mesh's own material. Uses MeshInstance3D.material_overlay -- a
## separate render pass Godot composites on top of the base material -- so
## the model's real colors are never read or written. A past attempt at
## this mutated the shared material directly and broke model colors; this
## approach can't do that, since each instance gets its own fresh
## ShaderMaterial and the base material is never referenced.

@export var enabled: bool = true
## Manual override for models with more than one MeshInstance3D. Leave
## unset to auto-discover the parent's (first) MeshInstance3D.
@export var mesh: MeshInstance3D

var _material: ShaderMaterial
var _tween: Tween
var _last_health: float = 0.0


func _ready() -> void:
	if not enabled:
		return
	if mesh == null:
		var found := get_parent().find_children("*", "MeshInstance3D", true, false)
		if found.is_empty():
			return
		mesh = found[0] as MeshInstance3D

	_material = ShaderMaterial.new()
	_material.shader = preload("res://scenes/component/hit_flash_overlay.gdshader")
	mesh.material_overlay = _material

	var health := get_parent().find_child("HealthComponent") as HealthComponent
	if health:
		_last_health = health.current_health
		health.health_changed.connect(_on_health_changed)


func _on_health_changed(current: float, _max_hp: float) -> void:
	# health_changed fires identically for damage/heal/reset -- a real drop
	# is the only case that should flash (this also skips reset()'s
	# pool-reuse snap back to max, which is a rise, not a drop).
	if current < _last_health:
		_flash()
	_last_health = current


func _flash() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_material.set_shader_parameter("flash_amount", 1.0)
	_tween = create_tween()
	_tween.tween_property(_material, "shader_parameter/flash_amount", 0.0, Constants.HIT_FLASH_DURATION_SEC)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
