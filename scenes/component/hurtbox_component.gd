class_name HurtboxComponent
extends Area3D

@export var armor_type: int = Constants.ArmorType.UNARMORED
# Spell school this owner resists (spells.md Section 3): resisted hits deal
# SCHOOL_RESIST_MULT damage and their status effect is halved too.
# -1 = resists nothing. Void can never be resisted, enforced below.
@export var resisted_school: int = -1

func apply_hit(hit_damage: float, hit_damage_type: int) -> void:
	var resist_mult := 1.0
	if hit_damage_type == resisted_school and hit_damage_type != Constants.DamageType.VOID:
		resist_mult = Constants.SCHOOL_RESIST_MULT
	var final_dmg := CombatUtils.calculate_damage(hit_damage, hit_damage_type, armor_type) * resist_mult
	var health := get_parent().find_child("HealthComponent") as HealthComponent
	if health:
		health.damage(final_dmg)
	CombatUtils.apply_school_perk(final_dmg, hit_damage_type, get_parent(), resist_mult)
