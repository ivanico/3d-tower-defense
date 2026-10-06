class_name EnemyDefinition
extends Resource

@export var enemy_id: String = ""
@export var model_path: String = ""
@export var scene: PackedScene = null
@export var base_hp: float = 100.0
@export var base_speed: float = 1.5
@export var base_damage: float = 10.0
@export var attack_cooldown: float = 1.0
@export var armor_type: int = Constants.ArmorType.UNARMORED
# Spell school (Constants.DamageType) this enemy resists; -1 = none. Every
# themed enemy sets its set's school (the Void set: -1). How much it resists
# depends on is_boss, see get_resist(). Never set this to VOID — nothing
# resists Void (spells.md Section 3).
@export var resisted_school: int = -1
@export var xp_value: int = 10
## Bosses resist their school more than regular enemies (get_resist()).
@export var is_boss: bool = false
@export var is_flying: bool = false
@export var hold_height: float = 0.5
## Placeholder support (Epic 09 rule 1): a themed set with no models of its own
## points `scene` at another chapter's enemy and washes it in its school colour
## (scripts/model_tint.gd, same as TowerDefinition.model_tint). Alpha 0 = no
## tint. When the real model arrives: point `scene` at it and clear this.
@export var model_tint: Color = Color(1, 1, 1, 0)


## How many points a hit of `resisted_school` loses off its armor-table value
## (09-11): bosses Constants.BOSS_SCHOOL_RESIST (0.50), everyone else
## Constants.REGULAR_SCHOOL_RESIST (0.30). THE one place this rule lives.
func get_resist() -> float:
	return Constants.BOSS_SCHOOL_RESIST if is_boss else Constants.REGULAR_SCHOOL_RESIST
