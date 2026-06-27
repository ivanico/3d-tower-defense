extends Node

var owned_towers: Array = []
var tower_stars: Dictionary = {}
var spell_ranks: Dictionary = {}
var materials: int = 0
var energy: int = Constants.MAX_ENERGY
var premium_currency: int = 0
var selected_tower_id: String = "default"

func _ready() -> void:
	load_data()

func spend_energy() -> bool:
	if energy <= 0:
		return false
	energy -= 1
	return true

func restore_energy(amount: int) -> void:
	energy = min(energy + amount, Constants.MAX_ENERGY)

func save_data() -> void:
	pass

func load_data() -> void:
	pass

