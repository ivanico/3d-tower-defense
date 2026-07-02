class_name HurtboxComponent
extends Area3D

@export var armor_type: int = Constants.ArmorType.UNARMORED

func apply_hit(hit_damage: float, hit_damage_type: int) -> void:
	var final_dmg := CombatUtils.calculate_damage(hit_damage, hit_damage_type, armor_type)
	var health := get_parent().find_child("HealthComponent") as HealthComponent
	if health:
		health.damage(final_dmg)
