extends CharacterBody3D
class_name Tower

@export var definition: TowerDefinition

@onready var health: HealthComponent = $HealthComponent
@onready var targeting: TargetingComponent = $TargetingComponent
@onready var anim: AnimationPlayer = find_child("AnimationPlayer", true, false)

const STANDARD_BOLT_SCENE := preload("res://scenes/game_object/standard_bolt/standard_bolt.tscn")
const ORB_SCENE := preload("res://scenes/game_object/orb/orb.tscn")
const AOE_AREA_SCENE := preload("res://scenes/game_object/aoe_area/aoe_area.tscn")

var _active_spells: Array[SpellDefinition] = []
var _spell_timers: Dictionary = {}
var _spell_stacks: Dictionary = {}
var _orb_rings: Dictionary = {}  # spell_id -> {"pivot": Node3D, "speed_deg": float}
var _shot_count: int = 0

func _ready() -> void:
	add_to_group("tower")
	if GameState.pending_tower_def != null:
		definition = GameState.pending_tower_def
	if definition == null:
		return
	health.max_health = definition.base_hp
	health.current_health = definition.base_hp
	GameState.start_run(definition)
	_load_starting_spell()
	_play_idle()

func _play_idle() -> void:
	if anim == null:
		return
	var clip := anim.get_animation("idle")
	if clip == null:
		return
	clip.loop_mode = Animation.LOOP_LINEAR
	anim.play("idle", -1, Constants.TOWER_IDLE_ANIM_SPEED_SCALE)

func _load_starting_spell() -> void:
	var path := "res://resources/spells/spell_%s.tres" % definition.starting_spell_id
	if ResourceLoader.exists(path):
		_add_spell(load(path) as SpellDefinition)

func add_spell(spell: SpellDefinition) -> void:
	_add_spell(spell)

func get_stack_count(spell_id: String) -> int:
	return _spell_stacks.get(spell_id, 0)

func _add_spell(spell: SpellDefinition) -> void:
	if spell == null:
		return
	var is_orb := spell.spell_category == Constants.SpellCategory.ORB
	if _spell_stacks.has(spell.spell_id):
		# Duplicate pick: bump the stack on the existing entry — never a
		# second cooldown/instance (spells.md Task S-00).
		var cap := spell.stack_max
		if is_orb:
			cap = mini(cap, Constants.ORB_ANGLE_SEQUENCE.size())
		var new_count: int = mini(_spell_stacks[spell.spell_id] + 1, cap)
		if new_count == _spell_stacks[spell.spell_id]:
			return
		_spell_stacks[spell.spell_id] = new_count
		if is_orb:
			# Orb stacking effect applies immediately: a new orb at the next
			# angle in the sequence (spells.md Task S-03).
			_spawn_orb(spell, new_count - 1)
		return
	_active_spells.append(spell)
	_spell_stacks[spell.spell_id] = 1
	GameState.register_spell_rank(spell.spell_id)
	if is_orb:
		# Orbs never enter the cooldown-fire loop — they're persistent bodies.
		_spawn_orb(spell, 0)
	else:
		_spell_timers[spell.spell_id] = 0.0

func _spawn_orb(spell: SpellDefinition, index: int) -> void:
	var ring: Dictionary = _orb_rings.get(spell.spell_id, {})
	if ring.is_empty():
		var pivot := Node3D.new()
		pivot.name = "OrbRing_%s" % spell.spell_id
		add_child(pivot)
		ring = {"pivot": pivot, "speed_deg": spell.orbit_speed}
		_orb_rings[spell.spell_id] = ring
	var orb := ORB_SCENE.instantiate()
	ring["pivot"].add_child(orb)
	var angle := deg_to_rad(Constants.ORB_ANGLE_SEQUENCE[mini(index, Constants.ORB_ANGLE_SEQUENCE.size() - 1)])
	orb.position = Vector3(cos(angle) * spell.orbit_radius, Constants.ORB_HEIGHT, sin(angle) * spell.orbit_radius)
	orb.setup(spell)

func _physics_process(delta: float) -> void:
	# All orbs on a ring share the pivot's rotation, so spacing stays fixed.
	for ring in _orb_rings.values():
		ring["pivot"].rotate_y(deg_to_rad(ring["speed_deg"]) * delta)
	for spell in _active_spells:
		if spell.spell_category == Constants.SpellCategory.ORB:
			continue
		var t: float = _spell_timers.get(spell.spell_id, 0.0)
		if t > 0.0:
			_spell_timers[spell.spell_id] = t - delta
		else:
			_try_fire(spell)

func _try_fire(spell: SpellDefinition) -> void:
	var target := targeting.get_target(spell.range)
	if target == null:
		return
	_spell_timers[spell.spell_id] = spell.cooldown * GameState.tower_fire_rate_multiplier * GameState.utility_cooldown_mult
	if spell.spell_category == Constants.SpellCategory.PROJECTILE:
		_fire_projectile(spell, target)
	elif spell.spell_category == Constants.SpellCategory.AOE_AREA:
		_fire_aoe_area(spell, target)

func _fire_aoe_area(spell: SpellDefinition, target: Node3D) -> void:
	# Zone lands at the enemy's position at the moment of cast and never
	# moves afterwards (spells.md Task S-04).
	var zone := ObjectPool.acquire(AOE_AREA_SCENE)
	zone.initialize(Vector3(target.global_position.x, 0.0, target.global_position.z), spell)

func _fire_projectile(spell: SpellDefinition, target: Node3D) -> void:
	# Volley stacking (spells.md Task S-01): stack_count bolts per cast, at
	# the nearest distinct enemies, with a small stagger so it reads as a
	# volley. Extra bolts fall back to the nearest target when enemies < bolts.
	var stacks: int = maxi(_spell_stacks.get(spell.spell_id, 1), 1)
	var targets: Array[Node3D] = targeting.get_targets(stacks, spell.range)
	if targets.is_empty():
		targets.append(target)
	for i in stacks:
		if i > 0:
			await get_tree().create_timer(Constants.BOLT_VOLLEY_STAGGER_SEC, false).timeout
		var t: Node3D = targets[i] if i < targets.size() else targets[0]
		if not is_instance_valid(t):
			t = targeting.get_target(spell.range)
		if t == null:
			continue
		_spawn_bolt(spell, t)

func _spawn_bolt(spell: SpellDefinition, target: Node3D) -> void:
	# A spell's .tres can point at its own projectile scene (chain bolt etc.);
	# the plain standard bolt is the default.
	var scene: PackedScene = spell.projectile_scene if spell.projectile_scene != null else STANDARD_BOLT_SCENE
	var proj := ObjectPool.acquire(scene)
	var aim_pos := target.global_position + Vector3(0, 0.6, 0)
	var origin := global_position + Vector3(0, 0.8, 0)
	proj.initialize(origin, aim_pos, spell)
	_shot_count += 1
	if GameState.offense_bonus_shot_active and _shot_count % Constants.OFFENSE_TIER2_BONUS_SHOT_N == 0:
		var bonus := ObjectPool.acquire(scene)
		var side := (aim_pos - origin).cross(Vector3.UP).normalized() * 0.6
		bonus.initialize(origin, aim_pos + side, spell)
