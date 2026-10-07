extends Node

## Base of every tower ult (09-13). tower.gd adds the tower's ult script
## (`TowerDefinition.passive_script`, which extends this one) as an "Ult" child.
##
## This base owns everything the five ults share:
## - charging: fills over `charge_sec` (the tower's `ult_charge_sec`, or
##   Constants.ULT_CHARGE_SEC_DEFAULT). Pausable, so it stops during drafts.
## - firing: TAP waits for EventBus.ult_fire_requested (the HUD ult_button);
##   AUTO fires the moment it's charged. Constants.ULT_TRIGGER_MODE picks.
## - the power tier from the tower's star level: 1 = star 1-2, 2 = star 3-4,
##   3 = star 5. Each ult reads it for its stronger version.
## - damage scaling: `scaled_damage()` applies the tower's damage multiplier
##   (stars + drafted bonuses), the same one spells use.
##
## A subclass overrides only `_get_school()` (button colour) and
## `_activate(tier)` (the effect). No ult ever checks which tower it's on.

var charge_sec: float = Constants.ULT_CHARGE_SEC_DEFAULT
## Copied from Constants.ULT_TRIGGER_MODE (the one switch); a var so a test can
## exercise both modes in one run.
var trigger_mode: int = Constants.ULT_TRIGGER_MODE
var tower: Node3D
var _charge: float = 0.0


func setup(owner_tower: Node3D, definition: Resource) -> void:
	tower = owner_tower
	if definition != null and definition.ult_charge_sec > 0.0:
		charge_sec = definition.ult_charge_sec


func _ready() -> void:
	EventBus.ult_fire_requested.connect(try_fire)
	_emit_charge()


func _physics_process(delta: float) -> void:
	if _is_run_over() or is_ready():
		return
	_charge = minf(_charge + delta, charge_sec)
	_emit_charge()
	if is_ready() and trigger_mode == Constants.UltTrigger.AUTO:
		try_fire()


func is_ready() -> bool:
	return _charge >= charge_sec


func get_charge_ratio() -> float:
	return clampf(_charge / charge_sec, 0.0, 1.0) if charge_sec > 0.0 else 1.0


## 1 = star 1-2, 2 = star 3-4, 3 = star 5.
func power_tier() -> int:
	var star: int = GameState.tower_star_level
	if star >= 5:
		return 3
	if star >= 3:
		return 2
	return 1


## A per-tier value from a Constants array (index = tier - 1).
func tier_value(values: Array) -> float:
	return values[mini(power_tier(), values.size()) - 1]


## Ult damage gets the tower's damage multiplier, like every spell.
func scaled_damage(base: float) -> float:
	return base * GameState.tower_damage_multiplier


## Fires if charged and the run is still going. Returns whether it fired.
func try_fire() -> bool:
	if not is_ready() or _is_run_over():
		return false
	_charge = 0.0
	_activate(power_tier())
	EventBus.ult_fired.emit(_get_school())
	_emit_charge()
	return true


func _is_run_over() -> bool:
	return GameState.phase == Constants.GamePhase.VICTORY \
			or GameState.phase == Constants.GamePhase.DEFEAT


func _emit_charge() -> void:
	EventBus.ult_charge_changed.emit(get_charge_ratio(), is_ready(), _get_school())


## Override: the ult's school (Constants.DamageType), for the button colour.
func _get_school() -> int:
	return Constants.DamageType.VOID


## Override: the effect. `tier` = power_tier() at the moment of firing.
func _activate(_tier: int) -> void:
	pass
