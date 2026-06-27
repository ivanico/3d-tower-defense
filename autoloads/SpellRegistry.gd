extends Node

var all_spells: Array = []
var all_stat_upgrades: Array = []

func _ready() -> void:
	pass # Resources loaded here in Epic 03 via DirAccess scan

func get_all_cards() -> Array:
	return all_spells + all_stat_upgrades

func get_spells_by_tag(tag: int) -> Array:
	return all_spells.filter(func(s): return tag in s.tags)
