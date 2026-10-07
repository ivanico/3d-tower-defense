class_name HurtboxComponent
extends Area3D

const DamageNumber3DScene := preload("res://scenes/ui/widget/damage_number_3d/damage_number_3d.tscn")

@export var armor_type: int = Constants.ArmorType.UNARMORED
# Spell school this owner resists (spells.md Section 3): a resisted hit loses
# `resist` points off its armor-table value (CombatUtils.calculate_damage).
# -1 = resists nothing. Void can never be resisted, enforced below.
@export var resisted_school: int = -1
# Resist points for a resisted hit. Set by enemy.gd from
# EnemyDefinition.get_resist() (boss 0.50, regular 0.30).
@export var resist: float = Constants.REGULAR_SCHOOL_RESIST

## `hit_world_pos` is where the floating damage number spawns (epic_done/epic_08_polish.md
## Task 08-01) -- every caller already has a precise 3D hit point at the moment
## it calls this (its own `global_position`, or the enemy's), so it's passed
## in rather than approximated here.
## Returns the final damage dealt (after the armor table and resist), so a
## caller can total it (Void Rupture's star-5 shield, 09-13).
func apply_hit(hit_damage: float, hit_damage_type: int, hit_world_pos: Vector3) -> float:
	var hit_resist := 0.0
	if hit_damage_type == resisted_school and hit_damage_type != Constants.DamageType.VOID:
		hit_resist = resist
	var final_dmg := CombatUtils.calculate_damage(hit_damage, hit_damage_type, armor_type, hit_resist)
	var health := get_parent().find_child("HealthComponent") as HealthComponent
	if health:
		health.damage(final_dmg)
	CombatUtils.apply_school_perk(final_dmg, hit_damage_type, get_parent())
	_spawn_damage_number(hit_damage, final_dmg, hit_damage_type, hit_world_pos)
	return final_dmg


## Per epic_done/epic_08_polish.md Task 08-01: "Crit detection: final_damage > base_damage * 1.5".
func _spawn_damage_number(base_dmg: float, final_dmg: float, hit_damage_type: int, hit_world_pos: Vector3) -> void:
	if not DamageNumber3D.can_spawn():
		return
	var is_crit := final_dmg > base_dmg * Constants.DAMAGE_NUMBER_CRIT_MULT
	var number := ObjectPool.acquire(DamageNumber3DScene) as DamageNumber3D
	number.spawn(final_dmg, hit_damage_type, is_crit, hit_world_pos)
