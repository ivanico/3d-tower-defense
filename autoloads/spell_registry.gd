extends Node

# assets.md §4: icons are looked up by ID convention —
# spells:   assets/ui/spells/<school>/icon_spell_<spell_id>.png
# upgrades: assets/ui/upgrades/icon_<upgrade_id>.png
# An explicit `icon` set in a .tres always wins over the convention.
const SCHOOL_FOLDERS := {
	Constants.DamageType.FIRE: "fire",
	Constants.DamageType.FROST: "frost",
	Constants.DamageType.VOID: "void",
	Constants.DamageType.POISON: "poison",
	Constants.DamageType.NATURE: "nature",
}

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

func get_card_icon(card_data: Resource) -> Texture2D:
	var explicit = card_data.get("icon")
	if explicit != null:
		return explicit
	var spell_id = card_data.get("spell_id")
	if spell_id != null and spell_id != "":
		var folder: String = SCHOOL_FOLDERS.get(card_data.get("damage_type"), "")
		var path := "res://assets/ui/spells/%s/icon_spell_%s.png" % [folder, spell_id]
		if folder != "" and ResourceLoader.exists(path):
			return load(path)
	var upgrade_id = card_data.get("upgrade_id")
	if upgrade_id != null and upgrade_id != "":
		var path2 := "res://assets/ui/upgrades/icon_%s.png" % upgrade_id
		if ResourceLoader.exists(path2):
			return load(path2)
	return null

func get_spells_by_tag(tag: int) -> Array:
	return all_spells.filter(func(s): return tag in s.tags)
