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

static func get_damage_color(damage_type: int) -> Color:
	return Constants.SCHOOL_COLORS.get(damage_type, Color.WHITE)

# One shared emissive material per school — shared (not duplicated) so every
# projectile of a school batches as one material (mobile perf rule).
static var _school_materials: Dictionary = {}

static func get_school_material(damage_type: int) -> StandardMaterial3D:
	if not _school_materials.has(damage_type):
		var mat := StandardMaterial3D.new()
		var color := get_damage_color(damage_type)
		mat.albedo_color = color
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = 1.5
		_school_materials[damage_type] = mat
	return _school_materials[damage_type]

# Elemental surface look for spell VFX (SchoolVFXComponent) -- one shared
# ShaderMaterial per school, same batching-friendly caching as
# get_school_material() above, just a livelier shader instead of a flat
# tint. Uniform values live here (not the component) so they sit next to
# the other per-school data (get_damage_color, get_school_material) this
# file already owns; SchoolVFXComponent's own PRESETS dict is for its
# particle setup only, which isn't a material concern.
const SCHOOL_SHADER_PRESETS: Dictionary = {
	Constants.DamageType.FIRE: {
		"noise_scroll": Vector2(0.15, 0.8), "noise_scale": 6.0, "noise_strength": 0.5,
		"fresnel_power": 2.0, "fresnel_strength": 0.5, "pulse_speed": 3.0, "pulse_strength": 0.25,
	},
	Constants.DamageType.FROST: {
		"noise_scroll": Vector2(0.05, 0.05), "noise_scale": 10.0, "noise_strength": 0.3,
		"fresnel_power": 3.5, "fresnel_strength": 0.9, "pulse_speed": 1.0, "pulse_strength": 0.1,
	},
	Constants.DamageType.VOID: {
		"noise_scroll": Vector2(-0.2, 0.1), "noise_scale": 4.0, "noise_strength": 0.7,
		"fresnel_power": 1.5, "fresnel_strength": 1.1, "pulse_speed": 1.5, "pulse_strength": 0.3,
	},
	Constants.DamageType.POISON: {
		"noise_scroll": Vector2(0.1, 0.4), "noise_scale": 8.0, "noise_strength": 0.45,
		"fresnel_power": 2.5, "fresnel_strength": 0.4, "pulse_speed": 2.0, "pulse_strength": 0.2,
	},
	Constants.DamageType.NATURE: {
		"noise_scroll": Vector2(0.08, 0.12), "noise_scale": 5.0, "noise_strength": 0.3,
		"fresnel_power": 2.0, "fresnel_strength": 0.5, "pulse_speed": 1.2, "pulse_strength": 0.15,
	},
}
const SCHOOL_SURFACE_SHADER := preload("res://scenes/component/school_surface.gdshader")
static var _school_shader_materials: Dictionary = {}

static func get_school_shader_material(damage_type: int) -> ShaderMaterial:
	if not _school_shader_materials.has(damage_type):
		var preset: Dictionary = SCHOOL_SHADER_PRESETS.get(damage_type, SCHOOL_SHADER_PRESETS[Constants.DamageType.VOID])
		var color := get_damage_color(damage_type)
		var mat := ShaderMaterial.new()
		mat.shader = SCHOOL_SURFACE_SHADER
		mat.set_shader_parameter("albedo_color", color)
		mat.set_shader_parameter("emission_color", color)
		mat.set_shader_parameter("emission_energy", 1.5)
		for key in preset:
			mat.set_shader_parameter(key, preset[key])
		_school_shader_materials[damage_type] = mat
	return _school_shader_materials[damage_type]

# Global particle budget (skills/godot3d-vfx-audio/SKILL.md) -- one counter
# for every ad-hoc/continuous VFX particle system in the game, not
# per-effect-type, so a burst of orbs + hit sparks + death bursts all draw
# from the same ceiling instead of separately blowing the mobile frame
# budget. Reserve on spawn, release on despawn; skip low-priority dressing
# (never gameplay-critical VFX) when over budget instead of erroring.
const MAX_PARTICLE_BUDGET: int = 150
static var _active_particle_budget: int = 0

static func try_reserve_particles(count: int, is_priority: bool = false) -> bool:
	if _active_particle_budget + count > MAX_PARTICLE_BUDGET and not is_priority:
		return false
	_active_particle_budget += count
	return true

static func release_particles(count: int) -> void:
	_active_particle_budget = maxi(0, _active_particle_budget - count)

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
