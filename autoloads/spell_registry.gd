extends Node

var all_spells: Array = []
var all_stat_upgrades: Array = []

func _ready() -> void:
	all_spells        = _scan_dir("res://resources/spells/")
	all_stat_upgrades = _scan_dir("res://resources/upgrades/")
	print("SpellRegistry: %d spells + %d stat upgrades loaded (%d draft cards total)" % [all_spells.size(), all_stat_upgrades.size(), get_all_cards().size()])

func _scan_dir(path: String) -> Array:
	var result: Array = []
	var dir := DirAccess.open(path)
	if dir == null:
		return result
	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if fname.ends_with(".tres"):
			var res = load(path + "/" + fname)
			if res != null:
				result.append(res)
		fname = dir.get_next()
	dir.list_dir_end()
	return result

func get_all_cards() -> Array:
	return all_spells + all_stat_upgrades

func get_spells_by_tag(tag: int) -> Array:
	return all_spells.filter(func(s): return tag in s.tags)
