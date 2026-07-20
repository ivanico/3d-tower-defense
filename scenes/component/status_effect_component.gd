class_name StatusEffectComponent
extends Node

## Holds the school status effects (burn / slow / poison) on one enemy.
## Re-applying an effect refreshes its duration — no stacking (v1 rule).

@export var tick_interval: float = Constants.STATUS_TICK_INTERVAL

var _burn_dps: float = 0.0
var _burn_remaining: float = 0.0
var _poison_dps: float = 0.0
var _poison_remaining: float = 0.0
var _poison_slow_percent: float = 0.0
var _poison_slow_remaining: float = 0.0
var _slow_percent: float = 0.0
var _slow_remaining: float = 0.0

var _tick_accum: float = 0.0

@onready var _health: HealthComponent = get_parent().find_child("HealthComponent")
@onready var _mover: MoveToTargetComponent = get_parent().find_child("MoveToTargetComponent")

func apply_burn(dps: float, duration: float) -> void:
	_burn_dps = dps
	_burn_remaining = duration

func apply_slow(percent: float, duration: float) -> void:
	_slow_percent = percent
	_slow_remaining = duration
	_update_mover_slow()

func apply_poison(dps: float, slow_percent: float, duration: float, slow_duration: float = -1.0) -> void:
	_poison_dps = dps
	_poison_remaining = duration
	_poison_slow_percent = slow_percent
	_poison_slow_remaining = slow_duration if slow_duration >= 0.0 else duration
	_update_mover_slow()

func reset() -> void:
	_burn_dps = 0.0
	_burn_remaining = 0.0
	_poison_dps = 0.0
	_poison_remaining = 0.0
	_poison_slow_percent = 0.0
	_poison_slow_remaining = 0.0
	_slow_percent = 0.0
	_slow_remaining = 0.0
	_tick_accum = 0.0
	_update_mover_slow()

func _physics_process(delta: float) -> void:
	if _burn_remaining <= 0.0 and _poison_remaining <= 0.0 \
			and _slow_remaining <= 0.0 and _poison_slow_remaining <= 0.0:
		return
	_burn_remaining = maxf(_burn_remaining - delta, 0.0)
	_poison_remaining = maxf(_poison_remaining - delta, 0.0)
	if _slow_remaining > 0.0 or _poison_slow_remaining > 0.0:
		_slow_remaining = maxf(_slow_remaining - delta, 0.0)
		_poison_slow_remaining = maxf(_poison_slow_remaining - delta, 0.0)
		_update_mover_slow()
	_tick_accum += delta
	if _tick_accum >= tick_interval:
		_tick_accum -= tick_interval
		var dot_dps := 0.0
		if _burn_remaining > 0.0:
			dot_dps += _burn_dps
		if _poison_remaining > 0.0:
			dot_dps += _poison_dps
		if dot_dps > 0.0 and _health:
			_health.damage(dot_dps * tick_interval)

func _update_mover_slow() -> void:
	if _mover == null:
		return
	# Strongest active slow wins — slows don't stack multiplicatively (v1 rule).
	var active_slow := 0.0
	if _slow_remaining > 0.0:
		active_slow = _slow_percent
	if _poison_slow_remaining > 0.0:
		active_slow = maxf(active_slow, _poison_slow_percent)
	_mover.slow_multiplier = 1.0 - active_slow
