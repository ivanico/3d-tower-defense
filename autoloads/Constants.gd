extends Node

enum GamePhase      { WAVE, DRAFT, BOSS, DEFEAT, VICTORY }
enum DamageType     { FIRE, FROST, VOID, POISON, NATURE }
enum ArmorType      { UNARMORED, HEAVY }
enum SpellCategory  { PROJECTILE, AOE_BURST, PASSIVE }
enum TargetMode     { CLOSEST, RANDOM }
enum CardRarity     { COMMON, RARE, EPIC }
enum SynergyTag     { OFFENSE, ARMOR, UTILITY }
enum MaterialType   { STANDARD }

const TOTAL_WAVES:              int   = 12
const WAVE_DURATION_MAX:        float = 60.0
const DRAFT_CARDS_SHOWN:        int   = 3
const ENEMY_HP_SCALE:           float = 1.12
const ENEMY_DMG_SCALE:          float = 1.08
const XP_PER_KILL_BASE:         int   = 10
const XP_PER_LEVEL_BASE:        int   = 100
const MAX_SPELL_SLOTS:          int   = 6
const SYNERGY_THRESHOLD_LOW:    int   = 3
const SYNERGY_THRESHOLD_HIGH:   int   = 5
const TOWER_MAX_STARS:          int   = 5
const SPELL_MAX_RANK:           int   = 5
const MAX_ENERGY:               int   = 5
const CAMERA_PITCH_DEGREES:     float = 60.0

# Balance tuning constants — never use bare literals in gameplay logic, always reference these
const XP_LEVEL_SCALE_PER_LEVEL:          float = 1.2
const STAR_STAT_BONUS_PER_LEVEL:         float = 0.10
const SPELL_RANK_DAMAGE_BONUS_PER_LEVEL: float = 0.08

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

# Wave composition (Epic 04)
const WAVE_ENEMY_COUNT_BASE:             int   = 3
const WAVE_ENEMY_COUNT_MAX:              int   = 20
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
const MATERIAL_CHECKPOINT_REWARDS: Array[int] = [50, 100, 150, 220]

# Energy regen (Epic 05) — tunable
const ENERGY_REGEN_INTERVAL_SEC:         float = 1200.0  # 20 min per energy point

# Tower star / spell rank upgrade costs (Epic 05) — index by current level to
# get the cost of upgrading to the next level; index 0 is unused (no level 0)
const TOWER_STAR_COSTS:  Array[int] = [0, 100, 250, 500, 1000]
const SPELL_RANK_COSTS:  Array[int] = [0, 80, 200, 400, 800]

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
const SCHOOL_RESIST_MULT:       float = 0.5   # resisted school: damage AND status halved
const STATUS_TICK_INTERVAL:     float = 0.5   # seconds between DoT damage ticks
