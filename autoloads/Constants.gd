extends Node

enum GamePhase      { WAVE, DRAFT, BOSS, DEFEAT, VICTORY }
enum DamageType     { NORMAL, MAGIC, PIERCING }
enum ArmorType      { UNARMORED, HEAVY }
enum SpellCategory  { PROJECTILE, AOE_BURST, PASSIVE }
enum TargetMode     { CLOSEST }
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

# Wave composition (Epic 04)
const WAVE_ENEMY_COUNT_BASE:             int   = 3
const WAVE_ENEMY_COUNT_MAX:              int   = 20
const WAVE_FAST_ENEMY_MIN_WAVE:          int   = 5
const WAVE_BASIC_ENEMY_WEIGHT:           int   = 70
const WAVE_FAST_ENEMY_WEIGHT:            int   = 30

# Victory rewards (Epic 04) — stub flat amount, real formula is Epic 05
const VICTORY_MATERIALS_REWARD:          int   = 100
