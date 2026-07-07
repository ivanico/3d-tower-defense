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

static func calculate_star_scaled_value(base_value: float, star: int) -> float:
	return base_value * (1.0 + Constants.STAR_STAT_BONUS_PER_LEVEL * (star - 1))

static func calculate_rank_scaled_value(base_value: float, rank: int) -> float:
	return base_value * (1.0 + Constants.SPELL_RANK_DAMAGE_BONUS_PER_LEVEL * (rank - 1))

static func calculate_run_materials(waves_cleared: int) -> int:
	var checkpoints: Array[int] = Constants.MATERIAL_CHECKPOINT_WAVES
	var rewards: Array[int] = Constants.MATERIAL_CHECKPOINT_REWARDS
	var reward := 0
	for i in checkpoints.size():
		if waves_cleared >= checkpoints[i]:
			reward = rewards[i]
	return reward
