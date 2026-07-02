extends Node

# Run state
var phase: int = Constants.GamePhase.WAVE
var wave_number: int = 1
var run_level: int = 1
var run_xp: int = 0
var run_xp_to_next: int = Constants.XP_PER_LEVEL_BASE

# Tower stats (base + accumulated bonuses from drafted cards/stars)
var tower_hp: float = 0.0
var tower_max_hp: float = 0.0
var tower_damage_multiplier: float = 1.0
var tower_fire_rate_multiplier: float = 1.0
var tower_range: float = 8.0
var tower_regen_per_sec: float = 0.0

# Active spells drafted this run
var active_spells: Array = []

# Synergy tag counts and active bonuses
var tag_counts: Dictionary = {}
var offense_damage_mult: float = 1.0
var offense_bonus_shot_active: bool = false
var armor_damage_reduction: float = 0.0
var armor_regen_active: bool = false
var utility_cooldown_mult: float = 1.0

# Run stats
var run_kills: int = 0
var waves_cleared: int = 0
var damage_dealt: float = 0.0

signal hp_changed(current: float, max_hp: float)
signal xp_bar_updated(current: int, to_next: int, level: int)

var _regen_timer: Timer

func _ready() -> void:
	EventBus.xp_gained.connect(gain_xp)
	_regen_timer = Timer.new()
	_regen_timer.wait_time = Constants.ARMOR_TIER2_REGEN_INTERVAL
	_regen_timer.timeout.connect(_on_regen_tick)
	add_child(_regen_timer)

func _on_regen_tick() -> void:
	if armor_regen_active and tower_max_hp > 0.0:
		heal(tower_max_hp * Constants.ARMOR_TIER2_REGEN_PERCENT)

func start_run(tower_def) -> void:
	reset()
	if tower_def != null:
		tower_max_hp = tower_def.base_hp
		tower_hp = tower_max_hp
		tower_damage_multiplier = 1.0
		tower_fire_rate_multiplier = 1.0
		tower_range = tower_def.base_range
	phase = Constants.GamePhase.WAVE
	EventBus.phase_changed.emit(phase)

func gain_xp(amount: int) -> void:
	run_xp += amount
	while run_xp >= run_xp_to_next:
		run_xp -= run_xp_to_next
		run_level += 1
		run_xp_to_next = int(run_xp_to_next * Constants.XP_LEVEL_SCALE_PER_LEVEL)
		EventBus.level_up.emit(run_level)
	xp_bar_updated.emit(run_xp, run_xp_to_next, run_level)

func take_damage(amount: float) -> void:
	var reduced := amount * (1.0 - armor_damage_reduction)
	tower_hp = max(tower_hp - reduced, 0.0)
	hp_changed.emit(tower_hp, tower_max_hp)
	EventBus.tower_damaged.emit(amount)
	if tower_hp <= 0.0:
		call_deferred("_on_tower_died")

func heal(amount: float) -> void:
	tower_hp = min(tower_hp + amount, tower_max_hp)
	hp_changed.emit(tower_hp, tower_max_hp)
	EventBus.tower_healed.emit(amount)

func add_tag(tag: int) -> void:
	if not tag_counts.has(tag):
		tag_counts[tag] = 0
	tag_counts[tag] += 1
	var count: int = tag_counts[tag]
	if count == Constants.SYNERGY_THRESHOLD_LOW:
		_apply_synergy_bonus(tag, 1)
		EventBus.synergy_threshold_reached.emit(tag, 1)
	elif count == Constants.SYNERGY_THRESHOLD_HIGH:
		_apply_synergy_bonus(tag, 2)
		EventBus.synergy_threshold_reached.emit(tag, 2)

func apply_card(card: Resource) -> void:
	if card is SpellDefinition:
		if card.spell_category == Constants.SpellCategory.PASSIVE:
			armor_damage_reduction = clamp(armor_damage_reduction + card.passive_value, 0.0, 0.9)
			for tag in card.tags:
				add_tag(tag)
		elif active_spells.size() < Constants.MAX_SPELL_SLOTS:
			active_spells.append(card)
			for tag in card.tags:
				add_tag(tag)
			var tower = get_tree().get_first_node_in_group("tower")
			if tower:
				tower.add_spell(card)
	elif card is StatUpgradeDefinition:
		tower_max_hp += card.hp_bonus
		tower_hp = min(tower_hp + card.hp_bonus, tower_max_hp)
		tower_damage_multiplier *= card.damage_multiplier
		tower_fire_rate_multiplier *= card.fire_rate_multiplier
		for tag in card.tags:
			add_tag(tag)
		hp_changed.emit(tower_hp, tower_max_hp)

func end_run(victory: bool) -> void:
	phase = Constants.GamePhase.VICTORY if victory else Constants.GamePhase.DEFEAT
	EventBus.phase_changed.emit(phase)
	EventBus.run_ended.emit(victory)

func reset() -> void:
	EventBus.run_reset.emit()
	phase = Constants.GamePhase.WAVE
	wave_number = 1
	run_level = 1
	run_xp = 0
	run_xp_to_next = Constants.XP_PER_LEVEL_BASE
	tower_hp = 0.0
	tower_max_hp = 0.0
	tower_damage_multiplier = 1.0
	tower_fire_rate_multiplier = 1.0
	tower_range = 8.0
	tower_regen_per_sec = 0.0
	active_spells = []
	tag_counts = {}
	offense_damage_mult = 1.0
	offense_bonus_shot_active = false
	armor_damage_reduction = 0.0
	armor_regen_active = false
	utility_cooldown_mult = 1.0
	_regen_timer.stop()
	run_kills = 0
	waves_cleared = 0
	damage_dealt = 0.0

func _apply_synergy_bonus(tag: int, level: int) -> void:
	match tag:
		Constants.SynergyTag.OFFENSE:
			if level == 1:
				offense_damage_mult = Constants.OFFENSE_TIER1_DAMAGE_MULT
			elif level == 2:
				offense_bonus_shot_active = true
		Constants.SynergyTag.ARMOR:
			if level == 1:
				armor_damage_reduction = maxf(armor_damage_reduction, Constants.ARMOR_TIER1_DAMAGE_REDUCTION)
			elif level == 2:
				armor_regen_active = true
				_regen_timer.start()
		Constants.SynergyTag.UTILITY:
			if level == 1:
				utility_cooldown_mult = Constants.UTILITY_TIER1_COOLDOWN_MULT

func _on_tower_died() -> void:
	phase = Constants.GamePhase.DEFEAT
	EventBus.tower_died.emit()
