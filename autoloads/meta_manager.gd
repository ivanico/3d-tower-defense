extends Node

const SAVE_PATH := "user://savegame.tres"
const ChapterRegistry := preload("res://scripts/chapter_registry.gd")

var owned_towers: Array[String] = []
var tower_stars: Dictionary = {}
var spell_ranks: Dictionary = {}
var base_material: int = 0
var tower_material: int = 0
var scroll_materials: Dictionary = {}  # Constants.DamageType int -> int amount
var energy: int = Constants.MAX_ENERGY
var last_energy_timestamp: int = 0
var premium_currency: int = 0
var selected_tower_id: String = "ancient_tower"
## The chapter the world map carousel last showed (09-09). An id, not a
## position, so adding chapters never points it at the wrong one.
var last_chapter_id: String = "chapter_01"
## Every chapter whose boss has been beaten at least once (09-10). Chapter N+1
## opens when N is in here (ChapterRegistry.is_unlocked).
var cleared_chapters: Array[String] = []
var music_volume: float = 1.0
var sfx_volume: float = 1.0

# True when the save on disk was written by a NEWER game version than this
# one. Its values are still used, but save() refuses to write, so this build
# can never overwrite (and lose) data it doesn't understand.
var _read_only: bool = false
var _read_only_logged: bool = false
## Where save() writes: the file load() last read. Always SAVE_PATH in the game;
## tests load() a temp file so a save/reload round-trip never touches the real one.
var _save_path: String = SAVE_PATH

func _ready() -> void:
	self.load()

func spend_energy() -> bool:
	if energy <= 0:
		return false
	# A full bar doesn't regenerate, so the clock starts with this spend.
	if energy >= Constants.MAX_ENERGY:
		last_energy_timestamp = int(Time.get_unix_time_from_system())
	energy -= 1
	save()
	return true

func restore_energy(amount: int) -> void:
	energy = min(energy + amount, Constants.MAX_ENERGY)

func get_scroll_material(damage_type: int) -> int:
	return scroll_materials.get(damage_type, 0)

func award_base_material(amount: int) -> void:
	base_material += amount
	save()
	EventBus.base_material_earned.emit(amount)

func award_tower_material(amount: int) -> void:
	tower_material += amount
	save()
	EventBus.tower_material_earned.emit(amount)

func award_scroll_material(damage_type: int, amount: int) -> void:
	scroll_materials[damage_type] = get_scroll_material(damage_type) + amount
	save()
	EventBus.scroll_material_earned.emit(damage_type, amount)

## THE one way a tower becomes owned (09-05): a chapter's first victory
## (unlock_towers_for_chapter) or, later, a gem-chest drop (10-05). Never touches
## chapter progress. Returns true only if the tower was newly unlocked.
func unlock_tower(tower_id: String) -> bool:
	if tower_id in owned_towers:
		return false
	owned_towers.append(tower_id)
	save()
	EventBus.tower_unlocked.emit(tower_id)
	return true

## THE one hook for a won chapter (09-10), called on victory. The FIRST clear:
## records it, unlocks the chapter's towers, and points the map at the chapter it
## opened (09-10 Q2, the Archero way). A replay changes nothing. Returns what is
## new, for the victory screen: {"chapter_id": the newly opened chapter or "",
## "tower_ids": Array[String]}. Buying a tower (unlock_tower) never comes here.
func mark_chapter_cleared(chapter_id: String) -> Dictionary:
	var result := {"chapter_id": "", "tower_ids": [] as Array[String]}
	if chapter_id in cleared_chapters:
		return result
	cleared_chapters.append(chapter_id)
	result.tower_ids = unlock_towers_for_chapter(chapter_id)
	var next: Resource = ChapterRegistry.next_of(chapter_id)
	if next != null:
		result.chapter_id = next.chapter_id
		last_chapter_id = next.chapter_id
	save()
	return result

## Unlocks every tower whose TowerDefinition.unlock_chapter_id is this chapter.
## Returns the ids that were NEW, so the victory screen can announce them once
## (a replayed chapter returns nothing). Called by mark_chapter_cleared().
func unlock_towers_for_chapter(chapter_id: String) -> Array[String]:
	var newly: Array[String] = []
	for tower in TowerRegistry.all_towers:
		if tower.unlock_chapter_id == chapter_id and unlock_tower(tower.tower_id):
			newly.append(tower.tower_id)
	return newly

## Dual cost: Base Material (common) + Tower Material (rare). Both must be
## affordable or nothing is deducted.
func upgrade_tower_star(tower_id: String) -> bool:
	var current_star: int = tower_stars.get(tower_id, 1)
	if current_star >= Constants.TOWER_MAX_STARS:
		return false
	var base_cost: int = Constants.TOWER_STAR_COSTS[current_star]
	var rare_cost: int = Constants.TOWER_STAR_RARE_COSTS[current_star]
	if base_material < base_cost or tower_material < rare_cost:
		return false
	base_material -= base_cost
	tower_material -= rare_cost
	tower_stars[tower_id] = current_star + 1
	save()
	EventBus.tower_upgraded.emit(tower_id, tower_stars[tower_id])
	return true

## Dual cost: Base Material (common) + that school's Scroll Material (rare).
## Both must be affordable or nothing is deducted.
func upgrade_spell_rank(spell_id: String, damage_type: int) -> bool:
	var current_rank: int = spell_ranks.get(spell_id, 1)
	if current_rank >= Constants.SPELL_MAX_RANK:
		return false
	var base_cost: int = Constants.SPELL_RANK_COSTS[current_rank]
	var rare_cost: int = Constants.SPELL_RANK_RARE_COSTS[current_rank]
	if base_material < base_cost or get_scroll_material(damage_type) < rare_cost:
		return false
	base_material -= base_cost
	scroll_materials[damage_type] = get_scroll_material(damage_type) - rare_cost
	spell_ranks[spell_id] = current_rank + 1
	save()
	EventBus.spell_ranked_up.emit(spell_id, spell_ranks[spell_id])
	return true

func save() -> void:
	if _read_only:
		if not _read_only_logged:
			_read_only_logged = true
			push_error("MetaManager: save is from a newer game version; not saving so it isn't overwritten.")
		return
	var data := SaveData.new()
	data.save_version = Constants.SAVE_VERSION
	data.premium_currency = premium_currency
	data.selected_tower_id = selected_tower_id
	data.last_chapter_id = last_chapter_id
	data.cleared_chapters = cleared_chapters
	data.owned_towers = owned_towers
	data.tower_stars = tower_stars
	data.spell_ranks = spell_ranks
	data.base_material = base_material
	data.tower_material = tower_material
	data.scroll_materials = scroll_materials
	data.energy = energy
	# Saving never moves the regen clock (09-09): it used to set it to now on
	# every save, which threw away partial progress towards the next point.
	data.last_energy_timestamp = last_energy_timestamp
	data.music_volume = music_volume
	data.sfx_volume = sfx_volume
	ResourceSaver.save(data, _save_path)

## `path` is only ever passed by tests (a temp file); the game always uses the
## real save. Every save() after this writes to the same file.
func load(path: String = SAVE_PATH) -> void:
	_save_path = path
	if not ResourceLoader.exists(path):
		owned_towers = ["ancient_tower"]
		tower_stars = {}
		spell_ranks = {}
		base_material = 0
		tower_material = 0
		scroll_materials = {}
		energy = Constants.MAX_ENERGY
		last_energy_timestamp = int(Time.get_unix_time_from_system())
		premium_currency = 0
		selected_tower_id = "ancient_tower"
		last_chapter_id = "chapter_01"
		cleared_chapters = []
		save()
		return
	var data: Resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	owned_towers = data.owned_towers
	tower_stars = data.tower_stars
	spell_ranks = data.spell_ranks
	base_material = data.base_material
	tower_material = data.tower_material
	scroll_materials = data.scroll_materials
	energy = data.energy
	last_energy_timestamp = data.last_energy_timestamp
	music_volume = data.music_volume
	sfx_volume = data.sfx_volume
	premium_currency = data.premium_currency
	selected_tower_id = data.selected_tower_id
	last_chapter_id = data.last_chapter_id
	cleared_chapters = data.cleared_chapters
	var version: int = data.save_version
	if version > Constants.SAVE_VERSION:
		_read_only = true
		push_error("MetaManager: savegame is version %d, this game only knows up to %d. Loaded read-only." % [version, Constants.SAVE_VERSION])
	elif version < Constants.SAVE_VERSION:
		_migrate_from(version)
		save()
	# A selection must always be a tower the player owns (e.g. a hand-edited or
	# future save); fall back to the starting tower rather than start a run with
	# something locked.
	if not selected_tower_id in owned_towers:
		selected_tower_id = "ancient_tower"
	_apply_offline_energy_regen()

## Runs every upgrade step between an old save's version and the current one,
## in order. Each step is a `_migrate_N_to_N+1()` method below and only fills in
## defaults for the fields its version introduced.
func _migrate_from(version: int) -> void:
	for v in range(version, Constants.SAVE_VERSION):
		var step := "_migrate_%d_to_%d" % [v, v + 1]
		if has_method(step):
			call(step)
		else:
			push_error("MetaManager: missing save migration step %s" % step)
	print("MetaManager: savegame migrated from version %d to %d" % [version, Constants.SAVE_VERSION])

# v2: premium_currency joins the save (it existed in memory but was never written).
func _migrate_1_to_2() -> void:
	premium_currency = 0

# v3: the garage selection is saved (it used to reset to Ancient on every launch).
func _migrate_2_to_3() -> void:
	selected_tower_id = "ancient_tower"

# v4: the world map remembers the last chapter it showed (09-09).
func _migrate_3_to_4() -> void:
	last_chapter_id = "chapter_01"

# v5: chapter progress is saved (09-10). Starts empty on purpose (09-10 Q1): no
# guessing past wins from owned towers, so only chapter 1 is open after this.
func _migrate_4_to_5() -> void:
	cleared_chapters = []

## The carousel's current chapter. Saved at once, so it survives a restart.
func select_chapter(chapter_id: String) -> void:
	if chapter_id == last_chapter_id:
		return
	last_chapter_id = chapter_id
	save()

## The garage's pick for the next run. Saved at once, so it survives a restart.
func select_tower(tower_id: String) -> void:
	selected_tower_id = tower_id
	save()

func _apply_offline_energy_regen() -> void:
	var now: int = int(Time.get_unix_time_from_system())
	var elapsed: int = max(now - last_energy_timestamp, 0)
	var regen_amount: int = int(floor(elapsed / Constants.ENERGY_REGEN_INTERVAL_SEC))
	if regen_amount > 0:
		restore_energy(regen_amount)
		# Timestamp = start of the interval in progress. Advance it by exactly
		# the intervals used, so the leftover counts towards the next point;
		# a full bar has nothing in progress.
		if energy >= Constants.MAX_ENERGY:
			last_energy_timestamp = now
		else:
			last_energy_timestamp += int(regen_amount * Constants.ENERGY_REGEN_INTERVAL_SEC)
		save()
