extends Resource
class_name SaveData

@export var owned_towers: Array[String] = []
@export var tower_stars: Dictionary = {}
@export var spell_ranks: Dictionary = {}
@export var materials: int = 0
@export var energy: int = Constants.MAX_ENERGY
@export var last_energy_timestamp: int = 0
@export var music_volume: float = 1.0
@export var sfx_volume: float = 1.0
