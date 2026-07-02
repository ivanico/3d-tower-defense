class_name CombatUtils

# Damage multiplier table: [DamageType][ArmorType]
# Rows: NORMAL=0, MAGIC=1, PIERCING=2
# Cols: UNARMORED=0, HEAVY=1
const DAMAGE_TABLE: Array = [
	[1.0,  0.7 ],  # NORMAL
	[1.0,  1.25],  # MAGIC
	[1.5,  0.4 ],  # PIERCING
]

static func calculate_damage(base_amount: float, damage_type: int, armor_type: int) -> float:
	var multiplier: float = DAMAGE_TABLE[damage_type][armor_type]
	return base_amount * multiplier

static func calculate_wave_hp_scale(wave: int) -> float:
	return pow(Constants.ENEMY_HP_SCALE, wave - 1)

static func calculate_wave_dmg_scale(wave: int) -> float:
	return pow(Constants.ENEMY_DMG_SCALE, wave - 1)
