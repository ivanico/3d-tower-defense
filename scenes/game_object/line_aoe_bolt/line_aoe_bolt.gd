@tool  # NOT inherited from spell_projectile_base.gd -- see standard_bolt.gd's
# own comment on this; every script in the chain must redeclare @tool.
extends "res://scenes/game_object/spell_projectile_base.gd"

## Line AoE Bolt archetype (spells.md Task S-05): fired only when an enemy
## is inside the short trigger range, then travels in a straight line for
## max_travel_distance, piercing and damaging every enemy in its path
## exactly once. Never stops on HIT — only despawns at the end of its line
## OR the moment it leaves the camera view (`VisibleOnScreenNotifier3D`,
## same pattern as `standard_bolt.gd`), whichever comes first. Without the
## latter: `max_travel` (30m, "crosses the whole visible arena") is
## calibrated for a shot fired straight down the arena's long axis, but a
## shot fired toward a shorter/off-axis edge leaves the camera well before
## covering 30m -- and until this fix, the lance (and its trailing
## particles, once schools started having those) kept flying and emitting
## the whole time regardless, reading as "particles lingering forever"
## even though the lance itself had already left the visible arena.

# The glb is authored ~2.4m long along +X, nose toward -X; -90 flies it
# nose-first (-Z) toward the enemy. model_rotation_degrees/model_scale
# values are set as a per-scene override on line_aoe_bolt.tscn's root node
# (see spell_projectile_base.gd), not redeclared here.

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

@onready var collision: CollisionShape3D = $CollisionShape3D

# Margin added to the collision box beyond the precise hitbox_width/length
# below, so it's always a safe superset of what the exact longitudinal/
# lateral check counts as a hit -- this shape only narrows WHICH enemies get
# that exact check (via body_entered/body_exited, see _nearby_enemies),
# it never changes the check itself.
const DETECTION_MARGIN := 1.0

# Enemies currently overlapping `collision`. Kept in sync by body_entered/
# body_exited instead of scanning `get_tree()`'s full enemy list every
# physics frame for this lance's entire ~30m flight (Constants.LANCE_MAX_
# TRAVEL) -- see the FPS-drop audit.
var _nearby_enemies: Array[Node3D] = []

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint():
		return
	# Own shape instance per lance — never mutate a shared shape resource.
	collision.shape = BoxShape3D.new()
	$VisibleOnScreenNotifier3D.screen_exited.connect(_on_screen_exited)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_screen_exited() -> void:
	_initialized = false
	ObjectPool.release(self)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies") and not _nearby_enemies.has(body):
		_nearby_enemies.append(body)

func _on_body_exited(body: Node3D) -> void:
	_nearby_enemies.erase(body)

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
	damage = spell.damage * GameState.tower_damage_multiplier * GameState.get_school_damage_multiplier(spell.damage_type) * GameState.offense_damage_mult * GameState.get_spell_damage_multiplier(spell.spell_id)
	damage_type = spell.damage_type
	speed = spell.projectile_speed
	max_travel = spell.max_travel_distance
	(collision.shape as BoxShape3D).size = Vector3(
			hitbox_width + DETECTION_MARGIN, hitbox_width + DETECTION_MARGIN,
			hitbox_length + DETECTION_MARGIN)
	look_at(global_position + _direction, Vector3.UP)
	_configure_school_vfx(damage_type, -_direction)
	_hit_enemies.clear()
	_traveled = 0.0
	_initialized = true

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
	for enemy in _nearby_enemies:
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
			hurtbox.apply_hit(damage, damage_type, enemy.global_position + Vector3(0, 0.6, 0))

func reset() -> void:
	_initialized = false
	_direction = Vector3.ZERO
	_traveled = 0.0
	_hit_enemies.clear()
	_nearby_enemies.clear()
