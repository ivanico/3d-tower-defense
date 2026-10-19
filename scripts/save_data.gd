extends Resource
class_name SaveData

## Adding a field here: bump Constants.SAVE_VERSION and add a matching
## MetaManager._migrate_N_to_N+1() step that fills in its default for older
## saves (see MetaManager.load()).

## Default stays 1 forever: a save written before versioning existed has no
## such line in its .tres, so it reads back as version 1.
@export var save_version: int = 1
@export var owned_towers: Array[String] = []
@export var tower_stars: Dictionary = {}
@export var spell_ranks: Dictionary = {}
@export var base_material: int = 0
@export var tower_material: int = 0
@export var scroll_materials: Dictionary = {}  # Constants.DamageType int -> int amount
@export var energy: int = Constants.MAX_ENERGY
@export var last_energy_timestamp: int = 0
@export var premium_currency: int = 0  # added in save version 2
@export var selected_tower_id: String = "ancient_tower"  # added in save version 3
@export var last_chapter_id: String = "chapter_01"  # added in save version 4
@export var cleared_chapters: Array[String] = []  # added in save version 5
# Store (10-04), added in save version 6 — see MetaManager for what each means.
@export var bought_items: Array[String] = []
@export var daily_deals_day: int = 0
@export var daily_deals_bought: Array[String] = []
@export var monthly_card_end_day: int = 0
@export var monthly_card_last_paid_day: int = 0
@export var free_revives: int = 0
@export var owned_chests: Dictionary = {}  # chest_id -> count
@export var music_volume: float = 1.0
@export var sfx_volume: float = 1.0
