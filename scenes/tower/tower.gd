extends CharacterBody3D
class_name Tower

@export var definition: TowerDefinition

@onready var health: HealthComponent = $HealthComponent
@onready var targeting: TargetingComponent = $TargetingComponent

const PROJECTILE_SCENE := preload("res://scenes/spells/Projectile.tscn")

var _active_spells: Array[SpellDefinition] = []
var _spell_timers: Dictionary = {}  # spell_id -> seconds remaining

func _ready() -> void:
	add_to_group("tower")
	if definition == null:
		return
	health.max_health = definition.base_hp
	health.current_health = definition.base_hp
	GameState.start_run(definition)
	_load_starting_spell()
	print("[Tower] ready HP=%d spells=%d" % [int(definition.base_hp), _active_spells.size()])

func _load_starting_spell() -> void:
	var path := "res://resources/spells/spell_%s.tres" % definition.starting_spell_id
	if ResourceLoader.exists(path):
		_add_spell(load(path) as SpellDefinition)

func _add_spell(spell: SpellDefinition) -> void:
	if spell == null:
		return
	_active_spells.append(spell)
	_spell_timers[spell.spell_id] = 0.0

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
	_spell_timers[spell.spell_id] = spell.cooldown
	if spell.spell_category == Constants.SpellCategory.PROJECTILE:
		_fire_projectile(spell, target)

func _fire_projectile(spell: SpellDefinition, target: Node3D) -> void:
	var proj := ObjectPool.acquire(PROJECTILE_SCENE)
	var aim_pos := target.global_position + Vector3(0, 0.6, 0)
	proj.initialize(global_position + Vector3(0, 0.8, 0), aim_pos, spell)
	print("[Tower] fired %s at %s" % [spell.spell_id, target.name])
