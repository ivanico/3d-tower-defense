extends Node3D

## Orb archetype (spells.md Task S-03): a persistent body sitting on a
## rotating ring pivot around the tower. Damages any enemy it touches, with
## a per-enemy re-hit interval so standing in the orbit path takes ticks,
## not one hit per physics frame. School perk applies per hit via the
## shared HurtboxComponent.apply_hit funnel.

const AIM_HEIGHT := Vector3(0, 0.6, 0)

# Swap in the Inspector if a spell later gets its own dedicated model.
@export var model_scene: PackedScene = preload("res://assets/models/spells/spell_orb.glb")
# The glb sphere is 0.6m across natively — half scale keeps the visual
# diameter (0.3m) under the 0.4m gap between school rings, so orbs on
# adjacent rings never visually overlap.
@export var model_scale: Vector3 = Vector3.ONE * 0.5
@export var hit_radius: float = 0.7

var spell: SpellDefinition = null
var hit_interval: float = Constants.ORB_HIT_INTERVAL

var _cooldowns: Dictionary = {}  # enemy instance_id -> seconds until re-hit allowed
var _model: Node3D = null

# Enemies currently overlapping `DetectionArea`, kept in sync by its
# body_entered/body_exited signals instead of asking `get_tree()` for every
# enemy in the game on every physics frame (perf.md/the FPS-drop audit:
# orbs are persistent -- unlike bolts they never despawn -- so this ran
# forever, every frame, once per orb, against the full enemy list; that's
# O(active_orbs x active_enemies) EVERY tick and was the single biggest
# contributor to FPS drops in mob-heavy waves). `DetectionArea`'s radius
# (3.0, see orb.tscn) is deliberately much bigger than `hit_radius` so this
# list is always a safe superset -- it only narrows WHICH enemies get the
# exact `hit_radius` distance check below, it never changes the check
# itself, so which enemies actually get hit is unchanged.
var _nearby_enemies: Array[Node3D] = []

func _ready() -> void:
	if model_scene != null:
		_model = model_scene.instantiate()
		add_child(_model)
		_model.scale = model_scale
	$DetectionArea.body_entered.connect(_on_body_entered)
	$DetectionArea.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies") and not _nearby_enemies.has(body):
		_nearby_enemies.append(body)

func _on_body_exited(body: Node3D) -> void:
	_nearby_enemies.erase(body)

func setup(spell_def: SpellDefinition) -> void:
	spell = spell_def
	hit_interval = spell_def.orb_hit_interval
	if _model != null:
		var mat := CombatUtils.get_school_material(spell_def.damage_type)
		for mi in _model.find_children("*", "MeshInstance3D", true, false):
			mi.material_override = mat

func _physics_process(delta: float) -> void:
	if spell == null:
		return
	for key in _cooldowns.keys():
		_cooldowns[key] -= delta
		if _cooldowns[key] <= 0.0:
			_cooldowns.erase(key)
	for enemy in _nearby_enemies:
		if not is_instance_valid(enemy):
			continue
		if global_position.distance_to(enemy.global_position + AIM_HEIGHT) > hit_radius:
			continue
		var key := enemy.get_instance_id()
		if _cooldowns.has(key):
			continue
		_cooldowns[key] = hit_interval
		var hurtbox := enemy.find_child("HurtboxComponent") as HurtboxComponent
		if hurtbox:
			# Damage computed at hit time so mid-run upgrades apply to
			# already-spawned orbs.
			var dmg: float = spell.damage * GameState.tower_damage_multiplier * GameState.offense_damage_mult * GameState.get_spell_damage_multiplier(spell.spell_id)
			hurtbox.apply_hit(dmg, spell.damage_type)
