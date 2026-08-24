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

# The folder scan lives in one place and is shared with TowerRegistry.
const ResourceDir := preload("res://scripts/resource_dir.gd")

var all_spells: Array = []
var all_stat_upgrades: Array = []

func _ready() -> void:
	all_spells        = ResourceDir.load_all("res://resources/spells/")
	all_stat_upgrades = ResourceDir.load_all("res://resources/upgrades/")
	print("SpellRegistry: %d spells + %d stat upgrades loaded (%d draft cards total)" % [all_spells.size(), all_stat_upgrades.size(), get_all_cards().size()])

func get_all_cards() -> Array:
	return all_spells + all_stat_upgrades

## static: touches no autoload state (just card_data fields + ResourceLoader),
## and MUST stay callable without going through the SpellRegistry singleton
## instance — a @tool script (SpellIcon) calling it via the autoload name
## crashes in the editor, because non-@tool autoloads are swapped for a
## placeholder instance there. Called normally (SpellRegistry.get_card_icon())
## still works fine at real runtime; SpellIcon instead calls it via its
## preloaded script directly, which resolves the static method without ever
## touching the (possibly-placeholder) singleton node.
static func get_card_icon(card_data: Resource) -> Texture2D:
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
