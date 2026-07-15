extends CharacterBody3D
class_name Enemy

@export var definition: EnemyDefinition

@onready var health: HealthComponent = $HealthComponent
@onready var mover: MoveToTargetComponent = $MoveToTargetComponent
@onready var melee_area: Area3D = $MeleeRangeArea
@onready var anim: AnimationPlayer = find_child("AnimationPlayer", true, false)

var _is_attacking: bool = false
var _attack_cooldown: float = 1.0
var _attack_timer: float = 0.0
var _damage_scale: float = 1.0

func _ready() -> void:
	add_to_group("enemies")
	_apply_definition()
	melee_area.body_entered.connect(_on_melee_range_body_entered)
	health.died.connect(_on_died)

func reset() -> void:
	add_to_group("enemies")
	scale = Vector3.ONE
	_is_attacking = false
	_attack_timer = 0.0
	_damage_scale = 1.0
	_apply_definition()
	health.reset()

func apply_wave_scale(hp_scale: float, dmg_scale: float) -> void:
	health.max_health *= hp_scale
	health.current_health = health.max_health
	_damage_scale = dmg_scale

func _apply_definition() -> void:
	if definition == null:
		return
	health.max_health = definition.base_hp
	health.current_health = definition.base_hp
	mover.speed = definition.base_speed
	mover.hold_height = definition.hold_height
	_attack_cooldown = definition.attack_cooldown
	var hurtbox := find_child("HurtboxComponent") as HurtboxComponent
	if hurtbox:
		hurtbox.armor_type = definition.armor_type
	var tower := get_tree().get_first_node_in_group("tower")
	if tower:
		mover.target_position = tower.global_position

func _physics_process(delta: float) -> void:
	if not _is_attacking:
		return
	_attack_timer -= delta
	if _attack_timer <= 0.0:
		_attack_tower()

func _attack_tower() -> void:
	var dmg := (definition.base_damage if definition else 10.0) * _damage_scale
	_attack_timer = _play_attack_anim()
	var heavy := find_child("BossHeavyAttackComponent") as BossHeavyAttackComponent
	if heavy:
		heavy.perform_attack(dmg, anim)
	else:
		GameState.take_damage(dmg)

func _play_attack_anim() -> float:
	if anim == null:
		return _attack_cooldown
	var clip := anim.get_animation("attack")
	if clip == null:
		return _attack_cooldown
	anim.play("attack")
	return clip.length * (1.0 + Constants.ENEMY_ATTACK_ANIM_PAUSE_RATIO)

func _on_died() -> void:
	remove_from_group("enemies")
	mover.speed = 0.0
	_is_attacking = false
	EventBus.enemy_died.emit(self, global_position)
	if definition:
		EventBus.xp_gained.emit(definition.xp_value)

func _on_melee_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("tower"):
		mover.speed = 0.0
		_is_attacking = true
