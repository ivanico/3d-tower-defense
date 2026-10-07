extends Node

enum GamePhase      { WAVE, DRAFT, BOSS, DEFEAT, VICTORY }
enum DamageType     { FIRE, FROST, VOID, POISON, NATURE }
enum ArmorType      { UNARMORED, HEAVY, LIGHT, MEDIUM, FORTIFIED }
enum SpellCategory  { PROJECTILE, PASSIVE, ORB, AOE_AREA }
enum CardRarity     { COMMON, RARE, EPIC }
enum SynergyTag     { OFFENSE, ARMOR, UTILITY }

const TOTAL_WAVES:              int   = 12
const WAVE_DURATION_MAX:        float = 60.0
# Real floor is 40x57 (chap1_arena.tscn PlaneMesh/BoxShape3D -> half-extents
# X=20, Z=28.5); shrunk slightly for a safety margin. WaveManager clamps
# every spawn point to this so an enemy can never land past the physical
# floor's edge and fall through forever (was un-killable/un-targetable once
# off-frustum, stalling the wave until WAVE_DURATION_MAX force-cleared it).
const ARENA_FLOOR_HALF_EXTENTS: Vector2 = Vector2(19.5, 28.0)
# Nothing bounds the floor's edge (chap1_arena.tscn has no perimeter walls),
# and enemies converging on the tower jostle each other via move_and_slide()
# -- one can still get shoved off after spawning safely inside
# ARENA_FLOOR_HALF_EXTENTS. Once off, it free-falls forever: alive, off-
# camera, un-killable, stuck in WaveManager._active_enemies until
# WAVE_DURATION_MAX force-clears the wave. enemy.gd force-kills anything
# that falls this far below the floor (spawn height 0.6) as a safety net.
const ENEMY_FALL_KILL_Y: float = -5.0
const DRAFT_CARDS_SHOWN:        int   = 3
const ENEMY_HP_SCALE:           float = 1.12
const ENEMY_DMG_SCALE:          float = 1.08
const XP_PER_KILL_BASE:         int   = 10
const XP_PER_LEVEL_BASE:        int   = 100
const MAX_SPELL_SLOTS:          int   = 4
const SYNERGY_THRESHOLD_LOW:    int   = 3
const SYNERGY_THRESHOLD_HIGH:   int   = 5
const TOWER_MAX_STARS:          int   = 5
const SPELL_MAX_RANK:           int   = 5
const MAX_ENERGY:               int   = 5
const ENERGY_COST_PER_RUN:      int   = 1
const CAMERA_PITCH_DEGREES:     float = 60.0
# Version of the savegame.tres layout. Bump it (and add a MetaManager
# _migrate_N_to_N+1 step) whenever a field is added to SaveData.
const SAVE_VERSION:             int   = 5

# Balance tuning constants — never use bare literals in gameplay logic, always reference these
const XP_LEVEL_SCALE_PER_LEVEL:          float = 1.2
const STAR_STAT_BONUS_PER_LEVEL:         float = 0.10
const SPELL_RANK_DAMAGE_BONUS_PER_LEVEL: float = 0.08
# Rank milestones (09-14): rank 3 and rank 5 unlock a behaviour for that exact
# spell, on top of the damage bonus. CombatUtils.get_rank_milestone() returns
# 0 / 1 / 2. Values are starting numbers, tuned in 09-17. Two-entry arrays are
# [rank 3+, rank 5].
const RANK_MILESTONE_RANKS:      Array[int]   = [3, 5]
const BOLT_SPLASH_RADIUS:        Array[float] = [1.2, 2.0]
const BOLT_SPLASH_DAMAGE_PERCENT: float = 0.5
const CHAIN_RANK_EXTRA_BOUNCES:  Array[int]   = [1, 2]
const ORB_RANK3_SPIN_MULT:       float = 1.3
const ORB_RANK5_SIZE_MULT:       float = 1.4
const AOE_RANK3_DURATION_MULT:   float = 1.5
const AOE_RANK5_RADIUS_MULT:     float = 1.3
const LANCE_RANK3_SIZE_MULT:     float = 1.3
const LANCE_TRAIL_DURATION:      float = 2.0
const LANCE_TRAIL_TICK_SEC:      float = 0.5
const LANCE_TRAIL_DAMAGE_PERCENT: float = 0.3

# [Offense] synergy tag
const OFFENSE_TIER1_DAMAGE_MULT:    float = 1.10
const OFFENSE_TIER2_BONUS_SHOT_N:   int   = 10

# [Armor] synergy tag
const ARMOR_TIER1_DAMAGE_REDUCTION: float = 0.15
const ARMOR_TIER2_REGEN_PERCENT:    float = 0.01
const ARMOR_TIER2_REGEN_INTERVAL:   float = 5.0

# [Utility] synergy tag
const UTILITY_TIER1_COOLDOWN_MULT:  float = 0.90

# Boss heavy-attack (Epic 04)
const BOSS_HEAVY_ATTACK_EVERY_N:         int   = 4
const BOSS_HEAVY_ATTACK_DAMAGE_MULT:     float = 2.5
const BOSS_HEAVY_ATTACK_TELEGRAPH_SEC:   float = 0.5

# Animation pacing (Epic 06) — tune these two by eye, nothing else needs editing
# The "attack" clip always plays at its real, unscaled, authored length — it
# is never sped up or slowed down. This is the pause added AFTER the clip
# finishes, before the enemy can attack again, expressed as a PERCENTAGE of
# that enemy's own clip length (0.15 = pause is 15% of however long its
# attack animation is) — same ratio for every enemy/boss, but the actual
# pause in seconds comes out different per enemy since it scales with each
# one's own attack speed. This keeps the pause feeling equally noticeable
# whether an enemy attacks fast or slow, instead of a flat number of seconds
# feeling huge on a fast attacker and tiny on a slow one. The enemy's real
# attack interval is (attack clip's own length * (1 + this ratio)); an enemy
# with no attack clip falls back to its attack_cooldown field (set per-type
# in its .tres) unchanged. Raise this for a longer, more visible pause;
# lower it for a snappier one.
const ENEMY_ATTACK_ANIM_PAUSE_RATIO:     float = 0.15
# Playback speed multiplier for the tower's looping "idle" animation.
# 1.0 = clip's native authored speed; e.g. 1.0 / 3.0 plays it 3x slower.
const TOWER_IDLE_ANIM_SPEED_SCALE:       float = 1.0 / 3.0

# Hit flash (Epic 06) — see HitFlashComponent
const HIT_FLASH_DURATION_SEC: float = 0.25

# Floating damage numbers (Epic 08 Task 08-01) — see DamageNumber3D
const DAMAGE_NUMBER_POOL_SIZE:      int   = 30
const DAMAGE_NUMBER_MAX_VISIBLE:    int   = 10
const DAMAGE_NUMBER_CRIT_MULT:      float = 1.5   # final_dmg > base_dmg * this = crit
const DAMAGE_NUMBER_CRIT_SCALE:     float = 1.4
const DAMAGE_NUMBER_SCALE_IN_DURATION: float = 0.15 # seconds, scale 0 -> full size on spawn
const DAMAGE_NUMBER_FADE_DELAY:     float = 0.4   # seconds before fade starts
const DAMAGE_NUMBER_FADE_DURATION:  float = 0.2   # seconds the fade itself takes
const DAMAGE_NUMBER_SPAWN_HEIGHT:   float = 0.5   # spawn offset above hit_world_pos
const DAMAGE_NUMBER_SCATTER_RADIUS: float = 0.3   # random X/Z spawn scatter

# Wave composition (Epic 04)
const WAVE_ENEMY_COUNT_BASE:             int   = 3
const WAVE_ENEMY_COUNT_GROWTH_RATE:      float = 1.5    # count = BASE * RATE^(wave-1), rounded, capped at MAX
const WAVE_ENEMY_COUNT_MAX:              int   = 60
const WAVE_FAST_ENEMY_MIN_WAVE:          int   = 5
const WAVE_BASIC_ENEMY_WEIGHT:           int   = 70
const WAVE_FAST_ENEMY_WEIGHT:            int   = 30

# Run-end material rewards (Epic 05) — checkpoint tiers keyed by
# GameState.waves_cleared (waves *fully* cleared, not just reached — dying
# mid-wave, including mid-boss-fight, does not count that wave). Reward only
# increases at each checkpoint; the top tier is only reachable by clearing
# the boss wave (i.e. an actual victory), never by reaching it and dying.
# TODO: this is tuned for the current 12-wave chapter (checkpoint every 3
# waves). Once the chapter grows (planned: wave 10 mini-boss + wave 20 final
# boss), update both arrays to match, e.g. checkpoints [5, 10, 15, 20].
const MATERIAL_CHECKPOINT_WAVES:   Array[int] = [3, 6, 9, 12]
# Base Material — the common currency, guaranteed every run, shown in the top
# bar next to Energy.
const MATERIAL_CHECKPOINT_REWARDS: Array[int] = [50, 100, 150, 220]
# Tower Material / Scroll Material — the rare currencies, only a CHANCE to
# drop (see CombatUtils.roll_material_reward). Same checkpoint tiers as
# above, scaled proportionally to MATERIAL_CHECKPOINT_REWARDS so the curve
# shape matches; capped at 25% on the boss checkpoint (wave 12) per design.
const MATERIAL_CHECKPOINT_CHANCES: Array[float] = [0.06, 0.11, 0.17, 0.25]
# Flat amount granted per rare currency when its roll hits. Tower Material is
# rolled once per run; Scroll Material is rolled independently once per
# fought school.
const RARE_MATERIAL_DROP_AMOUNT: int = 1

# Energy regen (Epic 05) — tunable
const ENERGY_REGEN_INTERVAL_SEC:         float = 1200.0  # 20 min per energy point

# Tower star / spell rank upgrade costs (Epic 05) — index by current level to
# get the cost of upgrading to the next level; index 0 is unused (no level 0).
# Each upgrade is a DUAL cost: the _COSTS arrays below are paid in the common
# Base Material, the _RARE_COSTS arrays alongside them are paid in the rare
# Tower Material / that school's Scroll Material.
const TOWER_STAR_COSTS:       Array[int] = [0, 100, 250, 500, 1000]
const SPELL_RANK_COSTS:       Array[int] = [0, 80, 200, 400, 800]
const TOWER_STAR_RARE_COSTS:  Array[int] = [0, 3, 6, 10, 15]
const SPELL_RANK_RARE_COSTS:  Array[int] = [0, 3, 6, 10, 15]

# Spell school perks (spells.md Sections 2-3) — applied generically by damage
# type in the hit-resolution path; a spell's .tres never re-implements these.
const FIRE_BURN_DPS_PERCENT:    float = 0.30  # burn ticks 30% of hit damage per second
const FIRE_BURN_DURATION:       float = 3.0
const FROST_SLOW_PERCENT:       float = 0.40  # strongest slow in the game
const FROST_SLOW_DURATION:      float = 2.0
const POISON_DOT_PERCENT:       float = 0.15  # half of Fire's burn
const POISON_DOT_DURATION:      float = 4.0   # longer but weaker
const POISON_SLOW_PERCENT:      float = 0.20  # half of Frost's slow
const POISON_SLOW_DURATION:     float = 2.0
# Void has no status perk — its premium is baked into its .tres damage values
# when authoring them (an equivalent-rarity Void spell's damage = other
# school's damage * (1 + VOID_DAMAGE_PREMIUM)); nothing reads this at runtime.
const VOID_DAMAGE_PREMIUM:      float = 0.18
const NATURE_LIFESTEAL_PERCENT: float = 0.18  # % of damage dealt healed to tower
# Resisted school (09-11, 2026-10-06): every themed enemy resists its set's
# school. The resist is SUBTRACTED from the armor-table value, in points:
# Nature 120% vs a regular enemy's 0.30 resist = 90%. Never below
# RESISTED_HIT_MIN. EnemyDefinition.get_resist() picks by is_boss. Burn/poison/
# heal follow the reduced hit damage; slows are not reduced. Void is never
# resisted.
const BOSS_SCHOOL_RESIST:    float = 0.50  # bosses: -50 points
const REGULAR_SCHOOL_RESIST: float = 0.30  # regular enemies: -30 points
const RESISTED_HIT_MIN:      float = 0.10  # a resisted hit always deals >= 10%

# Tower ults (09-13). Every tower has one signature ult that charges over time
# (scenes/component/tower_ult_component.gd). All numbers are STARTING values
# for play-testing, tuned in 09-17. Per-tier arrays are indexed by power tier
# - 1: tier 1 = star 1-2, tier 2 = star 3-4, tier 3 = star 5.
enum UltTrigger { TAP, AUTO }
# Which trigger is live. Both are built (09-00.6 Q1 is decided by play-test);
# flip this one value to try the other. TAP shows the HUD ult_button.
const ULT_TRIGGER_MODE: int = UltTrigger.TAP
# Seconds to fully charge, unless a tower's .tres sets its own ult_charge_sec.
const ULT_CHARGE_SEC_DEFAULT: float = 30.0
# Ancient: Barkskin — a shield worth a % of max HP. Tier 3 (star 5): any
# leftover shield heals the tower when it expires.
const BARKSKIN_SHIELD_PERCENT: Array[float] = [0.25, 0.40, 0.40]
const BARKSKIN_DURATION:       Array[float] = [6.0, 8.0, 8.0]
# Frost: freeze — roots every on-screen non-boss enemy (can't move, still
# attacks). Tier 3 also hits each rooted enemy with Frost damage.
const FROST_ULT_ROOT_SEC:      Array[float] = [2.0, 3.0, 3.0]
const FROST_ULT_STAR5_DAMAGE:  float = 60.0
# Void: Void Rupture — Void damage to every on-screen enemy, bosses included.
# Tier 3: the tower gets a shield = the damage dealt, capped at a % of max HP,
# lasting Barkskin's longest duration (09-13: "same as Barkskin").
const VOID_RUPTURE_DAMAGE:             Array[float] = [150.0, 250.0, 250.0]
const VOID_RUPTURE_SHIELD_CAP_PERCENT: float = 0.5
# Poison: Plague Cloud — a zone on the tower that hits everything inside every
# tick (plus Poison's normal DoT + slow). Tier 3: an enemy dying inside spreads
# a cloud hit to enemies within PLAGUE_CLOUD_SPREAD_RADIUS of it.
const PLAGUE_CLOUD_RADIUS:        Array[float] = [4.0, 5.0, 5.0]
const PLAGUE_CLOUD_DURATION:      Array[float] = [6.0, 8.0, 8.0]
const PLAGUE_CLOUD_DAMAGE:        float = 20.0
const PLAGUE_CLOUD_TICK_SEC:      float = 1.0
const PLAGUE_CLOUD_SPREAD_RADIUS: float = 3.0
# Fire: Ring of Fire — a ring at a fixed radius around the tower; each enemy
# that crosses it inward takes one Fire hit (plus Fire's normal burn). Tier 3:
# that hit deals +RING_OF_FIRE_BURNING_BONUS on an enemy already burning.
const RING_OF_FIRE_RADIUS:        float = 4.0
const RING_OF_FIRE_DURATION:      Array[float] = [6.0, 9.0, 9.0]
const RING_OF_FIRE_DAMAGE:        float = 80.0
const RING_OF_FIRE_BURNING_BONUS: float = 0.25
const STATUS_TICK_INTERVAL:     float = 0.5   # seconds between DoT damage ticks

# Mono-school mastery bonus — owning all MAX_SPELL_SLOTS spells of one school
# and nothing else (GameState.mono_school tracks which, -1 if not mono).
# Fire/Frost/Poison/Nature swap in a bigger status-perk constant here (see
# CombatUtils.apply_school_perk); Void has no status perk to amplify, so its
# bonus is flat extra damage instead, applied generically via
# GameState.get_school_damage_multiplier() through MONO_DAMAGE_BONUS_BY_SCHOOL.
const FIRE_MONO_BURN_DPS_PERCENT:    float = 0.45  # was 0.30 (+50% relative)
const FROST_MONO_SLOW_PERCENT:       float = 0.65  # was 0.40
const POISON_MONO_DOT_PERCENT:       float = 0.225 # was 0.15 (+50% relative)
const POISON_MONO_SLOW_PERCENT:      float = 0.30  # was 0.20 (+50% relative)
const NATURE_MONO_LIFESTEAL_PERCENT: float = 0.35  # was 0.18
const MONO_DAMAGE_BONUS_BY_SCHOOL: Dictionary = {
	DamageType.VOID: 0.35,  # flat extra damage multiplier while mono-Void
}

# Spell archetype range hierarchy (spells.md Section 5) — mirrored into each
# spell's .tres `range` field; Bolt > Chain > AoE Area > Line Lance.
const BOLT_RANGE:               float = 10.0
const CHAIN_RANGE:              float = 8.0
const AOE_AREA_RANGE:           float = 6.5
const LINE_AOE_RANGE:           float = 4.0
const BOLT_VOLLEY_STAGGER_SEC:  float = 0.07  # delay between stacked volley bolts

# Chain Bolt archetype (spells.md Task S-02)
const CHAIN_BOUNCE_RADIUS:      float = 4.0   # max distance a chain can jump between enemies
const CHAIN_MAX_BOUNCES:        int   = 2     # 2 bounces = 3 hits total

# Orb archetype (spells.md Task S-03)
# Stacking angle sequence: orb N sits at ORB_ANGLE_SEQUENCE[N-1] degrees on
# its ring — keeps splitting the circle in half. stack_max caps at its length.
const ORB_ANGLE_SEQUENCE: Array[float] = [0.0, 180.0, 90.0, 270.0, 45.0, 225.0, 135.0, 315.0]
# Per-school ring radius — every school's ring is distinct so all 5 orb
# spells can be owned at once with no orb-vs-orb overlap. Mirrored into each
# .tres's orbit_radius (the .tres value is what the game reads).
const ORB_ORBIT_RADII: Dictionary = {
	DamageType.FIRE:   1.2,
	DamageType.FROST:  2.0,
	DamageType.VOID:   2.4,
	DamageType.POISON: 2.8,
	DamageType.NATURE: 3.2,
}
const ORB_ORBIT_SPEED_DEG:      float = 90.0  # degrees/sec, shared by a ring
const ORB_HIT_INTERVAL:         float = 0.5   # seconds between re-hits on one enemy
const ORB_HEIGHT:               float = 0.6   # orb hover height above ground
# Per-school hit radius (mirrored into each orb .tres's `hit_radius`, which is
# what the game reads — same pattern as ORB_ORBIT_RADII above). Sized so an
# orbiting orb's closest possible approach to a melee-engaged enemy still
# lands a hit: enemies stop and attack the tower with their body as close as
# ~0.85m from the tower's center (smallest MeleeRangeArea, chap1_enemy_02,
# against the tower's collision box) — worked out by hand from the two
# colliders' sizes, not tuned by eye. Needed hit_radius = orbit_radius - 0.85,
# rounded up ~0.05m for margin. Before this, only Fire's small ring ever
# reached melee-range enemies at all; Frost/Void/Poison/Nature orbited too far
# out to ever touch anything actually attacking the tower.
const ORB_HIT_RADII: Dictionary = {
	DamageType.FIRE:   0.4,
	DamageType.FROST:  1.2,
	DamageType.VOID:   1.6,
	DamageType.POISON: 2.0,
	DamageType.NATURE: 2.4,
}

# AoE Area archetype (spells.md Task S-04)
const AOE_AREA_DURATION:        float = 4.0   # zone lifetime, seconds
const AOE_AREA_TICK_INTERVAL:   float = 0.5   # seconds between damage ticks
const AOE_AREA_SHARD_INTERVAL:  float = 0.2   # base seconds between shard drops (randomized ±50%)

# Line AoE Bolt archetype (spells.md Task S-05)
const LANCE_MAX_TRAVEL:         float = 30.0  # crosses the whole visible arena, then despawns
const LANCE_HITBOX_LENGTH:      float = 1.6   # longer than the standard bolt's hit reach
const LANCE_HITBOX_WIDTH:       float = 2.2   # wide enough to hit enemies either side of the target next to the tower (09-13 play-test)

# School tint colors (spells.md Section 2), read via CombatUtils.get_damage_color()
const SCHOOL_COLORS: Dictionary = {
	DamageType.FIRE:   Color(1.0, 0.45, 0.1),   # orange/red
	DamageType.FROST:  Color(0.45, 0.8, 1.0),   # ice blue
	DamageType.VOID:   Color(0.8, 0.3, 1.0),    # purple/magenta
	DamageType.POISON: Color(0.35, 0.9, 0.3),   # green
	DamageType.NATURE: Color(0.75, 0.85, 0.2),  # leaf green / gold
}
