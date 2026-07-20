class_name CombatUtils

# Damage multiplier table: [DamageType][ArmorType]
# Rows: FIRE=0, FROST=1, VOID=2, POISON=3, NATURE=4
# Cols: UNARMORED=0, HEAVY=1
# School rows are neutral 1.0 vs armor — school counterplay comes from the
# per-enemy resisted school (SCHOOL_RESIST_MULT in apply_hit), not armor.
# Void's row must always stay >= 1.0 (never resisted by anything).
const DAMAGE_TABLE: Array = [
	[1.0,  1.0 ],  # FIRE
	[1.0,  1.0 ],  # FROST
	[1.0,  1.0 ],  # VOID
	[1.0,  1.0 ],  # POISON
	[1.0,  1.0 ],  # NATURE
]

static func calculate_damage(base_amount: float, damage_type: int, armor_type: int) -> float:
	var multiplier: float = DAMAGE_TABLE[damage_type][armor_type]
	return base_amount * multiplier

# School perk on-hit application (spells.md Section 2) — the one generic
# match on DamageType, used by every archetype's hit path. `resist_mult` is
# 1.0 normally, SCHOOL_RESIST_MULT when the target resists this school.
static func apply_school_perk(final_damage: float, damage_type: int, target: Node, resist_mult: float = 1.0) -> void:
	var status := target.find_child("StatusEffectComponent") as StatusEffectComponent
	match damage_type:
		Constants.DamageType.FIRE:
			if status:
				status.apply_burn(final_damage * Constants.FIRE_BURN_DPS_PERCENT * resist_mult, Constants.FIRE_BURN_DURATION)
		Constants.DamageType.FROST:
			if status:
				status.apply_slow(Constants.FROST_SLOW_PERCENT * resist_mult, Constants.FROST_SLOW_DURATION)
		Constants.DamageType.POISON:
			if status:
				status.apply_poison(final_damage * Constants.POISON_DOT_PERCENT * resist_mult, Constants.POISON_SLOW_PERCENT * resist_mult, Constants.POISON_DOT_DURATION, Constants.POISON_SLOW_DURATION)
		Constants.DamageType.NATURE:
			GameState.heal(final_damage * Constants.NATURE_LIFESTEAL_PERCENT * resist_mult)
		# VOID applies no status — its premium is baked into its .tres damage.

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
