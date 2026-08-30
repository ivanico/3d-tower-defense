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

# Scroll material icons (Epic 05) — one per school, awarded at run-end and
# spent on that school's spell rank-ups. Mirrors the ICONS dict pattern in
# school_bonus_icon.gd; void's file is named "shadow", same convention as
# icon_bonus_shadow.png / icon_upgrade_damage_shadow.png.
const SCROLL_ICONS := {
	Constants.DamageType.FIRE:   preload("res://assets/ui/rewards/icon_mat_scroll_fire.png"),
	Constants.DamageType.FROST:  preload("res://assets/ui/rewards/icon_mat_scroll_frost.png"),
	Constants.DamageType.VOID:   preload("res://assets/ui/rewards/icon_mat_scroll_shadow.png"),
	Constants.DamageType.POISON: preload("res://assets/ui/rewards/icon_mat_scroll_poison.png"),
	Constants.DamageType.NATURE: preload("res://assets/ui/rewards/icon_mat_scroll_nature.png"),
}

static func get_scroll_icon(damage_type: int) -> Texture2D:
	return SCROLL_ICONS.get(damage_type)

# The single material spent on tower star upgrades (not tied to any school).
const TOWER_MATERIAL_ICON := preload("res://assets/ui/rewards/icon_mat_tower_rare.png")

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

# Shared "two-tone" banding mechanics reused by every school using the
# lighter-middle/darker-outside look (Frost's originally-approved numbers,
# now the shared template). get_school_shader_material() below applies
# these automatically to any school whose preset declares a "tone_color"
# key (Fire, Frost, Poison currently), before that school's own preset is
# applied on top -- so a school opts in just by adding tone_color (+ its
# own noise/pulse character), not by repeating every banding value. Void
# also has a tone_color but re-specifies every one of these same keys
# itself (its "black hole" look inverts which region is dark, none of
# these numbers match this template), so applying the defaults first for
# Void is harmless -- immediately overwritten by its own preset right
# after. Nature has no tone_color yet, so it correctly skips this and
# stays the shader's true no-op default (tone_strength 0) until it's
# actually styled.
# Deliberately a plain const, NOT built via a merge-helper function call:
# an earlier version made SCHOOL_SHADER_PRESETS itself a `static var`
# whose initializer called a small merge function -- that compiled and
# passed headless tests (a fresh process every run), but broke in the
# actual editor after a script hot-reload (auto_reload_scripts_on_external_
# change, already a known quirk here -- see project memory), leaving the
# dict empty and every school colorless. `const` is always fully resolved
# before any code runs, with no such timing dependency, so the merge is
# done at material-build time instead (see get_school_shader_material()),
# keeping every preset dict below a plain literal.
const DEFAULT_TWO_TONE_PRESET: Dictionary = {
	"tone_source": 1, "tone_strength": 1.0, "tone_use_threshold": true,
	"tone_threshold": 0.53, "tone_softness": 0.12,
	"fresnel_power": 0.8, "fresnel_strength": 0.9,
}

# Elemental surface look for spell VFX (SchoolVFXComponent) -- one shared
# ShaderMaterial per school, same batching-friendly caching as
# get_school_material() above, just a livelier shader instead of a flat
# tint. Uniform values live here (not the component) so they sit next to
# the other per-school data (get_damage_color, get_school_material) this
# file already owns; SchoolVFXComponent's own PRESETS dict is for its
# particle setup only, which isn't a material concern.
const SCHOOL_SHADER_PRESETS: Dictionary = {
	Constants.DamageType.FIRE: {
		# noise_scale dropped 6.0 -> 2.5: at the orb's actual size and the
		# real gameplay camera's distance (much further than the close-up
		# editor preview), 6.0 produced patches too small to read as
		# distinct color regions -- they blurred into one averaged tint.
		# Fewer, bigger blotches are legible from further away.
		"noise_scroll": Vector2(0.15, 0.8), "noise_scale": 2.5, "noise_strength": 0.5,
		"pulse_speed": 3.0, "pulse_strength": 0.25,
		# Base is the standard orange (get_damage_color(FIRE), same as every
		# other UI/damage-number/etc. reference to this school -- keep that
		# recognizable "old orange" as the anchor color, not swapped out) at
		# the center; darker/more saturated red at the rim, same style as
		# every other two-tone school now.
		"tone_color": Color(0.5, 0.04, 0.01),
	},
	Constants.DamageType.FROST: {
		"noise_scroll": Vector2(0.05, 0.05), "noise_scale": 10.0, "noise_strength": 0.3,
		"pulse_speed": 1.0, "pulse_strength": 0.1,
		# Base (center of the sphere, facing the camera) is near-white; the
		# rim shifts to blue -- a fixed white-middle, blue-edge look that
		# doesn't drift or scroll.
		"albedo_color": Color(0.95, 0.97, 1.0), "emission_color": Color(0.95, 0.97, 1.0),
		"tone_color": Color(0.22, 0.5, 0.85),
	},
	Constants.DamageType.VOID: {
		"noise_scroll": Vector2(-0.2, 0.1), "noise_scale": 4.0, "noise_strength": 0.4,
		"fresnel_power": 1.6, "fresnel_strength": 0.6, "pulse_speed": 1.0, "pulse_strength": 0.15,
		# Black hole look: dark "event horizon" center, bright purple limb at
		# the rim -- same tone_source=1 (fresnel/static) + threshold-band
		# technique as everyone else, just with the two colors' roles swapped
		# (everyone else: current color center/darker rim; Void: dark-purple
		# center/bright-purple rim). Base (center, facing camera) is a dark,
		# saturated variant of the purple, not plain black, so it still reads
		# as "void" rather than an unlit hole in the mesh.
		# Darker than the original 0.12/0.02/0.18 -- per feedback the center
		# needed to read more clearly "dark" now that the bright band below
		# covers more of the surface (contrast between the two matters more
		# than either one alone).
		"albedo_color": Color(0.05, 0.01, 0.09), "emission_color": Color(0.05, 0.01, 0.09),
		# tone_color is the exact current purple (get_damage_color(VOID) /
		# Constants.SCHOOL_COLORS[VOID]) -- unchanged everywhere else (UI,
		# damage numbers) -- shown at the rim as tone_strength mixes in.
		"tone_color": Color(0.8, 0.3, 1.0), "tone_strength": 1.0, "tone_source": 1,
		# tone_threshold lowered from the original 0.65 -- per feedback the
		# bright band was too thin (only right at the silhouette edge);
		# raw_fresnel crosses this threshold further from the edge now, so
		# more of the sphere's surface reads as the lighter outer tone
		# without changing tone_color itself or the dark center above.
		"tone_use_threshold": true, "tone_threshold": 0.42, "tone_softness": 0.12,
	},
	Constants.DamageType.POISON: {
		"noise_scroll": Vector2(0.1, 0.4), "noise_scale": 8.0, "noise_strength": 0.45,
		"pulse_speed": 2.0, "pulse_strength": 0.2,
		# Center stays the flat current green (no albedo_color/emission_color
		# override needed -- get_school_shader_material() already defaults
		# those to get_damage_color(POISON) before this preset applies), rim
		# shifts to a darker, more saturated green.
		"tone_color": Color(0.1, 0.3, 0.06),
	},
	Constants.DamageType.NATURE: {
		"noise_scroll": Vector2(0.08, 0.12), "noise_scale": 5.0, "noise_strength": 0.3,
		"pulse_speed": 1.2, "pulse_strength": 0.15,
		# Center overridden to a more saturated green (flat
		# get_damage_color(NATURE) is fairly yellow/gold-heavy -- fine as
		# the UI/damage-number color everywhere else, but too gold to read
		# as "green" here) -- same technique as Frost's near-white
		# override, just this shader's center, not the school's color
		# everywhere else. Rim shifts to a woody thorn-brown -- same
		# two-tone banding style as every other styled school now (opts in
		# automatically via tone_color, see DEFAULT_TWO_TONE_PRESET above).
		"albedo_color": Color(0.45, 0.82, 0.15), "emission_color": Color(0.45, 0.82, 0.15),
		"tone_color": Color(0.35, 0.22, 0.08),
	},
}
const SCHOOL_SURFACE_SHADER := preload("res://scenes/component/school_surface.gdshader")
static var _school_shader_materials: Dictionary = {}

static func get_school_shader_material(damage_type: int) -> ShaderMaterial:
	# Skip the cache entirely in-editor: this dict is a `static var`, which
	# lives for the whole life of the Godot editor PROCESS, not per scene-
	# open or per script-reload. Once orb.tscn's preview builds a school's
	# material the first time in a given editor session, every subsequent
	# edit to SCHOOL_SHADER_PRESETS above -- however correct -- silently has
	# NO effect on that already-open preview, because this check finds the
	# stale entry and returns it unchanged instead of rebuilding. That was
	# the real cause behind "I changed the values but nothing changed" here.
	# Rebuilding every call in-editor costs nothing that matters (a handful
	# of set_shader_parameter calls, only while actually tuning); real
	# gameplay still caches normally.
	if Engine.is_editor_hint() or not _school_shader_materials.has(damage_type):
		var preset: Dictionary = SCHOOL_SHADER_PRESETS.get(damage_type, SCHOOL_SHADER_PRESETS[Constants.DamageType.VOID])
		var color := get_damage_color(damage_type)
		var mat := ShaderMaterial.new()
		mat.shader = SCHOOL_SURFACE_SHADER
		mat.set_shader_parameter("albedo_color", color)
		mat.set_shader_parameter("emission_color", color)
		mat.set_shader_parameter("emission_energy", 1.5)
		# Schools with a tone_color opt into the shared two-tone banding
		# mechanics automatically (applied before the school's own preset
		# so per-school values -- Void's full override, Frost's albedo
		# override, everyone's tone_color -- always win applying second).
		if preset.has("tone_color"):
			for key in DEFAULT_TWO_TONE_PRESET:
				mat.set_shader_parameter(key, DEFAULT_TWO_TONE_PRESET[key])
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
	# Mono-school mastery bonus (project.md) — Fire/Frost/Poison/Nature swap in
	# a bigger constant while all owned spells are this one school. Void has no
	# status perk to amplify; its mono bonus is flat damage instead, applied
	# generically via GameState.get_school_damage_multiplier(), not here.
	var mono := GameState.mono_school == damage_type
	match damage_type:
		Constants.DamageType.FIRE:
			if status:
				var dps_pct := Constants.FIRE_MONO_BURN_DPS_PERCENT if mono else Constants.FIRE_BURN_DPS_PERCENT
				status.apply_burn(final_damage * dps_pct * resist_mult, Constants.FIRE_BURN_DURATION)
		Constants.DamageType.FROST:
			if status:
				var slow_pct := Constants.FROST_MONO_SLOW_PERCENT if mono else Constants.FROST_SLOW_PERCENT
				status.apply_slow(slow_pct * resist_mult, Constants.FROST_SLOW_DURATION)
		Constants.DamageType.POISON:
			if status:
				var dot_pct := Constants.POISON_MONO_DOT_PERCENT if mono else Constants.POISON_DOT_PERCENT
				var slow_pct := Constants.POISON_MONO_SLOW_PERCENT if mono else Constants.POISON_SLOW_PERCENT
				status.apply_poison(final_damage * dot_pct * resist_mult, slow_pct * resist_mult, Constants.POISON_DOT_DURATION, Constants.POISON_SLOW_DURATION)
		Constants.DamageType.NATURE:
			var lifesteal_pct := Constants.NATURE_MONO_LIFESTEAL_PERCENT if mono else Constants.NATURE_LIFESTEAL_PERCENT
			GameState.heal(final_damage * lifesteal_pct * resist_mult)
		# VOID applies no status — its premium is baked into its .tres damage.

static func calculate_wave_hp_scale(wave: int) -> float:
	return pow(Constants.ENEMY_HP_SCALE, wave - 1)

static func calculate_wave_dmg_scale(wave: int) -> float:
	return pow(Constants.ENEMY_DMG_SCALE, wave - 1)

static func calculate_star_scaled_value(base_value: float, star: int) -> float:
	return base_value * (1.0 + Constants.STAR_STAT_BONUS_PER_LEVEL * (star - 1))

static func calculate_rank_scaled_value(base_value: float, rank: int) -> float:
	return base_value * (1.0 + Constants.SPELL_RANK_DAMAGE_BONUS_PER_LEVEL * (rank - 1))

static func calculate_material_reward_amount(waves_cleared: int) -> int:
	var checkpoints: Array[int] = Constants.MATERIAL_CHECKPOINT_WAVES
	var rewards: Array[int] = Constants.MATERIAL_CHECKPOINT_REWARDS
	var reward := 0
	for i in checkpoints.size():
		if waves_cleared >= checkpoints[i]:
			reward = rewards[i]
	return reward

# Distinct schools (Constants.DamageType) among a run's active_spells, in
# first-seen order — the set of scroll materials that run's rewards touch.
# Shared by victory_screen and defeat_screen (both display AND later commit
# the same reward, so both need this list independently — see
# format_material_reward_summary / commit_material_reward below).
static func get_fought_schools(active_spells: Array) -> Array:
	var schools: Array = []
	for spell in active_spells:
		if spell.damage_type not in schools:
			schools.append(spell.damage_type)
	return schools

# Display text for a run-end reward, e.g. "Tower Mat x50, Fire Scroll x50" —
# pure, safe to call repeatedly (e.g. once for the results label, again later
# when actually committing via commit_material_reward).
static func format_material_reward_summary(amount: int, fought_schools: Array) -> String:
	if amount <= 0:
		return "None"
	var parts: Array[String] = ["Tower Mat x%d" % amount]
	for damage_type in fought_schools:
		parts.append("%s Scroll x%d" % [Constants.DamageType.keys()[damage_type].capitalize(), amount])
	return ", ".join(parts)

# Actually grants a run-end reward through MetaManager — the Tower material
# always, plus each fought school's scroll, all at `amount`. No-ops at
# amount <= 0 (nothing was earned).
static func commit_material_reward(amount: int, fought_schools: Array) -> void:
	if amount <= 0:
		return
	for damage_type in fought_schools:
		MetaManager.award_scroll_material(damage_type, amount)
	MetaManager.award_tower_material(amount)
