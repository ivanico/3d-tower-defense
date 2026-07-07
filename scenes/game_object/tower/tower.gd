extends CharacterBody3D
class_name Tower

@export var definition: TowerDefinition

@onready var health: HealthComponent = $HealthComponent
@onready var targeting: TargetingComponent = $TargetingComponent

const PROJECTILE_SCENE := preload("res://scenes/game_object/projectile/projectile.tscn")
const AOE_ZONE_SCENE := preload("res://scenes/game_object/aoe_zone/aoe_zone.tscn")

var _active_spells: Array[SpellDefinition] = []
var _spell_timers: Dictionary = {}
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

func _load_starting_spell() -> void:
	var path := "res://resources/spells/spell_%s.tres" % definition.starting_spell_id
	if ResourceLoader.exists(path):
		_add_spell(load(path) as SpellDefinition)

func add_spell(spell: SpellDefinition) -> void:
	_add_spell(spell)

func _add_spell(spell: SpellDefinition) -> void:
	if spell == null:
		return
	_active_spells.append(spell)
	_spell_timers[spell.spell_id] = 0.0
	GameState.register_spell_rank(spell.spell_id)

func _physics_process(delta: float) -> void:
	for spell in _active_spells:
		var t: float = _spell_timers.get(spell.spell_id, 0.0)
		if t > 0.0:
			_spell_timers[spell.spell_id] = t - delta
		else:
			_try_fire(spell)

func _try_fire(spell: SpellDefinition) -> void:
	var target := targeting.get_target()
	if target == null:
		return
	_spell_timers[spell.spell_id] = spell.cooldown * GameState.tower_fire_rate_multiplier * GameState.utility_cooldown_mult
	if spell.spell_category == Constants.SpellCategory.PROJECTILE:
		_fire_projectile(spell, target)
	elif spell.spell_category == Constants.SpellCategory.AOE_BURST:
		_fire_aoe(spell, target)

func _fire_aoe(spell: SpellDefinition, target: Node3D) -> void:
	var zone := ObjectPool.acquire(AOE_ZONE_SCENE)
	zone.initialize(target.global_position, spell.aoe_radius, spell)

func _fire_projectile(spell: SpellDefinition, target: Node3D) -> void:
	var proj := ObjectPool.acquire(PROJECTILE_SCENE)
	var aim_pos := target.global_position + Vector3(0, 0.6, 0)
	var origin := global_position + Vector3(0, 0.8, 0)
	proj.initialize(origin, aim_pos, spell)
	_shot_count += 1
	if GameState.offense_bonus_shot_active and _shot_count % Constants.OFFENSE_TIER2_BONUS_SHOT_N == 0:
		var bonus := ObjectPool.acquire(PROJECTILE_SCENE)
		var side := (aim_pos - origin).cross(Vector3.UP).normalized() * 0.6
		bonus.initialize(origin, aim_pos + side, spell)
