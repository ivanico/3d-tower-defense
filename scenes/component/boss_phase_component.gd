extends Node

## 09-16: boss phases by HP. Sits on boss scenes next to HealthComponent and
## BossHeavyAttackComponent. Phase 1 = normal attacks only; each threshold
## crossed moves one phase up. From HEAVY_ATTACK_PHASE on, the heavy attack
## is on. Crossing up plays the heavy attack's scale pulse as the tell.
## A full-HP health_changed (enemy.reset() on a pooled boss) drops it back
## to phase 1 without a pulse.

const HEAVY_ATTACK_PHASE := 2

## HP fractions, highest first. One entry today; add more for more phases.
var thresholds: Array[float] = [Constants.BOSS_PHASE_2_HP_FRACTION]
var phase: int = 1

@onready var _health: HealthComponent = get_parent().get_node("HealthComponent")
@onready var _heavy: BossHeavyAttackComponent = get_parent().get_node("BossHeavyAttackComponent")

func _ready() -> void:
	_health.health_changed.connect(_on_health_changed)
	_set_phase(1)

func _on_health_changed(current: float, max_hp: float) -> void:
	if max_hp <= 0.0:
		return
	var new_phase := _phase_for(current / max_hp)
	if new_phase == phase:
		return
	var went_up := new_phase > phase
	_set_phase(new_phase)
	if went_up and current > 0.0:
		_heavy.telegraph()

func _phase_for(fraction: float) -> int:
	var p := 1
	for t in thresholds:
		if fraction < t:
			p += 1
	return p

func _set_phase(new_phase: int) -> void:
	phase = new_phase
	_heavy.set_heavy_enabled(phase >= HEAVY_ATTACK_PHASE)
