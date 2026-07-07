extends Node

const SAVE_PATH := "user://savegame.tres"

var owned_towers: Array[String] = []
var tower_stars: Dictionary = {}
var spell_ranks: Dictionary = {}
var materials: int = 0
var energy: int = Constants.MAX_ENERGY
var last_energy_timestamp: int = 0
var premium_currency: int = 0
var selected_tower_id: String = "ancient_tower"
var music_volume: float = 1.0
var sfx_volume: float = 1.0

func _ready() -> void:
	self.load()

func spend_energy() -> bool:
	if energy <= 0:
		return false
	energy -= 1
	save()
	return true

func restore_energy(amount: int) -> void:
	energy = min(energy + amount, Constants.MAX_ENERGY)

func award_materials(amount: int) -> void:
	materials += amount
	save()
	EventBus.materials_earned.emit(amount)

func upgrade_tower_star(tower_id: String) -> bool:
	var current_star: int = tower_stars.get(tower_id, 1)
	if current_star >= Constants.TOWER_MAX_STARS:
		return false
	var cost: int = Constants.TOWER_STAR_COSTS[current_star]
	if materials < cost:
		return false
	materials -= cost
	tower_stars[tower_id] = current_star + 1
	save()
	EventBus.tower_upgraded.emit(tower_id, tower_stars[tower_id])
	return true

func upgrade_spell_rank(spell_id: String) -> bool:
	var current_rank: int = spell_ranks.get(spell_id, 1)
	if current_rank >= Constants.SPELL_MAX_RANK:
		return false
	var cost: int = Constants.SPELL_RANK_COSTS[current_rank]
	if materials < cost:
		return false
	materials -= cost
	spell_ranks[spell_id] = current_rank + 1
	save()
	EventBus.spell_ranked_up.emit(spell_id, spell_ranks[spell_id])
	return true

func save() -> void:
	var data := SaveData.new()
	data.owned_towers = owned_towers
	data.tower_stars = tower_stars
	data.spell_ranks = spell_ranks
	data.materials = materials
	data.energy = energy
	last_energy_timestamp = int(Time.get_unix_time_from_system())
	data.last_energy_timestamp = last_energy_timestamp
	data.music_volume = music_volume
	data.sfx_volume = sfx_volume
	ResourceSaver.save(data, SAVE_PATH)

func load() -> void:
	if not ResourceLoader.exists(SAVE_PATH):
		owned_towers = ["ancient_tower"]
		tower_stars = {}
		spell_ranks = {}
		materials = 0
		energy = Constants.MAX_ENERGY
		last_energy_timestamp = int(Time.get_unix_time_from_system())
		save()
		return
	var data: Resource = ResourceLoader.load(SAVE_PATH)
	owned_towers = data.owned_towers
	tower_stars = data.tower_stars
	spell_ranks = data.spell_ranks
	materials = data.materials
	energy = data.energy
	last_energy_timestamp = data.last_energy_timestamp
	music_volume = data.music_volume
	sfx_volume = data.sfx_volume
	_apply_offline_energy_regen()

func _apply_offline_energy_regen() -> void:
	var now: int = int(Time.get_unix_time_from_system())
	var elapsed: int = max(now - last_energy_timestamp, 0)
	var regen_amount: int = int(floor(elapsed / Constants.ENERGY_REGEN_INTERVAL_SEC))
	if regen_amount > 0:
		restore_energy(regen_amount)
		save()
