@tool  # NOT inherited from spell_projectile_base.gd -- see standard_bolt.gd's
# own comment on this; every script in the chain must redeclare @tool.
extends "res://scenes/game_object/spell_projectile_base.gd"

## Chain Bolt archetype (spells.md Task S-02): flies at whichever enemy
## tower.gd already picked (TargetingComponent.get_targets() -- random, see
## targeting_component.gd), then BOUNCES to the enemy closest to the one
## just hit, max `max_bounces` bounces. The initial `_nearest_enemy_to()`
## call in initialize() below is not a second, competing target pick -- it
## just resolves the actual enemy Node3D standing at the position tower.gd
## already aimed at (initialize() only receives a Vector3, not a node
## reference), so it always resolves back to the same enemy tower.gd chose.
## Only the bounce step is genuinely nearest-based, and that's deliberate --
## a chain/arc effect reads as jumping to whatever's nearby, not another
## random pick across the whole arena. Despawns immediately (pool release,
## no fizzle) when no valid bounce target exists within `bounce_radius`.
##
## Root is Area3D (inherited from spell_projectile_base.gd) but hit
## detection here is pure distance math against the "enemies" group, not
## Area3D collision -- the CollisionShape3D in chain_bolt.tscn exists only
## so the editor doesn't flag "Area3D has no shapes"; nothing in this
## script ever reads it.

const MAX_LIFETIME_SEC := 6.0
const HIT_DISTANCE := 0.5
const AIM_HEIGHT := Vector3(0, 0.6, 0)

# Native size (~0.4m) is fine, so model_rotation_degrees/model_scale are
# left at spell_projectile_base.gd's defaults (ZERO/ONE) -- no per-scene
# override needed in chain_bolt.tscn.
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
	# World-space "opposite of travel" -- see spell_projectile_base.gd's doc
	# comment on _configure_school_vfx(). This archetype has no stored
	# `_direction` var the way Standard/Line AoE Bolt do (to_target is
	# recomputed fresh every physics frame instead, see below), so it's
	# worked out here from the raw cast vector. Falls back to the ZERO
	# sentinel (preset's plain "up" look, unchanged) on a zero-length cast,
	# same as the no-op guard below.
	var backward := Vector3.ZERO
	var travel := target_pos - start_pos
	if travel.length_squared() > 0.0001:
		backward = -travel.normalized()
	# `preview_allow_ring`/`preview_ring_filled` double as the REAL cast's
	# own values here -- one source of truth instead of separate hardcoded
	# literals that could drift out of sync with chain_bolt.tscn's own
	# overrides. Per feedback, Chain Bolt's Void ring should look like the
	# Orb's own flat accretion disk (not the 2-ring perpendicular-to-travel
	# sonic effect Standard/Line AoE Bolt use), but filled/solid instead of
	# a donut (see spell_projectile_base.gd's own comments on both params).
	_configure_school_vfx(damage_type, backward, preview_allow_ring, preview_ring_filled)
	_target = _nearest_enemy_to(target_pos, [])
	_initialized = _target != null
	if not _initialized:
		ObjectPool.release(self)

func _physics_process(delta: float) -> void:
	if not _initialized:
		return
	_age += delta
	if _age > MAX_LIFETIME_SEC or not is_instance_valid(_target) or not _target.is_inside_tree():
		_despawn()
		return
	# Tumbling-shuriken spin — sells the motion regardless of travel direction.
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
		hurtbox.apply_hit(damage * falloff, damage_type, victim.global_position + Vector3(0, 0.6, 0))
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
