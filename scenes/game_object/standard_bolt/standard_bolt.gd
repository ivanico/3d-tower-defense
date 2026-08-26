@tool  # NOT inherited from spell_projectile_base.gd -- verified via Script.is_tool(),
# GDScript requires every script in the chain to redeclare @tool itself for
# _ready()/the preview_school setter to actually run in the editor.
extends "res://scenes/game_object/spell_projectile_base.gd"

# The glb is authored 1.53m long along +X; Godot forward is -Z. The
# model_rotation_degrees=(0,90,0)/model_scale=ONE/3.0 values that bring it
# to ~0.5m flying nose-first are set as a per-scene override on
# standard_bolt.tscn's root node (see spell_projectile_base.gd), not
# redeclared here.

var speed: float = 14.0
var damage: float = 0.0
var damage_type: int = Constants.DamageType.VOID
var pierce_count: int = 0

# Void's trailing ring (see school_vfx_component.gd's `_build_sonic_rings()`
# and `configure()`'s `sonic_ring_tuning` doc comments) tuned specifically
# for THIS archetype's mesh, per feedback -- NOT the shared default, which
# Line AoE Bolt keeps using untouched. Bigger overall (radius/outer scale
# bumped up) to suit this bolt's own model size.
const VOID_SONIC_RING_TUNING: Dictionary = {
	"radius_scale": 0.8, "outer_scale": 2.4,
}

var _direction: Vector3 = Vector3.ZERO
var _hits: int = 0
var _initialized: bool = false

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
	super._ready()
	if Engine.is_editor_hint():
		return
	$VisibleOnScreenNotifier3D.screen_exited.connect(_on_screen_exited)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

## Override, not just a per-scene export -- see `VOID_SONIC_RING_TUNING`'s
## own comment on why this archetype's sonic-ring numbers live here instead
## of the base's generic per-archetype exports.
func _apply_preview() -> void:
	$SchoolVFXComponent.configure(preview_school, _model, preview_allow_ring, PREVIEW_BACKWARD_DIRECTION, preview_ring_filled, VOID_SONIC_RING_TUNING)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies") and not _nearby_enemies.has(body):
		_nearby_enemies.append(body)

func _on_body_exited(body: Node3D) -> void:
	_nearby_enemies.erase(body)

func initialize(start_pos: Vector3, target_pos: Vector3, spell: SpellDefinition) -> void:
	global_position = start_pos
	damage = spell.damage * GameState.tower_damage_multiplier * GameState.get_school_damage_multiplier(spell.damage_type) * GameState.offense_damage_mult * GameState.get_spell_damage_multiplier(spell.spell_id)
	damage_type = spell.damage_type
	pierce_count = spell.pierce_count
	speed = spell.projectile_speed
	_direction = (target_pos - start_pos).normalized()
	look_at(global_position + _direction, Vector3.UP)
	_configure_school_vfx(damage_type, -_direction, false, false, VOID_SONIC_RING_TUNING)
	_hits = 0
	_initialized = true

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
			hurtbox.apply_hit(damage, damage_type, enemy.global_position + Vector3(0, 0.6, 0))
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
