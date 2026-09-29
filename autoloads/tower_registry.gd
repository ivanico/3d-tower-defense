extends Node

## Every tower that exists, in the order the garage grid shows them.
##
## The garage grid is data-driven off this: to add a real tower, drop a
## `.tres` into `res://resources/towers/` and set its `unlocked` and `sort_order`.
## No code or scene change is needed, and nothing hardcodes "6 slots".
##
## `unlocked = false` entries are placeholders — they occupy a grid slot, draw
## greyed out with a lock, and cannot be selected. They are NOT the same thing as
## `MetaManager.owned_towers`, which is what the player has actually earned.

# The folder scan lives in one place and is shared with SpellRegistry.
const ResourceDir := preload("res://scripts/resource_dir.gd")

var all_towers: Array = []


func _ready() -> void:
	all_towers = load_sorted()
	print("TowerRegistry: %d towers loaded (%d unlocked)" % [
			all_towers.size(), get_unlocked().size()])


## Every TowerDefinition in `resources/towers/`, in garage order. Explicit
## sort_order rather than filename order, so renaming a resource cannot silently
## reshuffle the grid. `static` so @tool scripts (the garage preview's tower
## dropdown) can call it at editor time, where this autoload is only a
## placeholder instance.
static func load_sorted() -> Array:
	var towers: Array = ResourceDir.load_all("res://resources/towers/")
	towers.sort_custom(func(a, b): return a.sort_order < b.sort_order)
	return towers


## Static twin of get_by_id() for @tool / editor-time callers (see load_sorted).
static func find_definition(tower_id: String) -> Resource:
	for tower in load_sorted():
		if tower.tower_id == tower_id:
			return tower
	return null


func get_by_id(tower_id: String) -> Resource:
	for tower in all_towers:
		if tower.tower_id == tower_id:
			return tower
	return null


func get_unlocked() -> Array:
	return all_towers.filter(func(t): return t.unlocked)


## The bare model for the garage preview, by ID convention:
##   assets/models/towers/<tower_id>/<tower_id>_lvl<star>.glb
##
## **Do not use `star_level_scenes` for a preview.** Those are gameplay scenes —
## `tower.gd._ready()` calls `GameState.start_run()`, so dropping one onto the
## garage screen would begin a run. Only the raw .glb is safe to show.
##
## Returns null when a tower has no model yet, which is the normal case for the
## locked placeholders; callers just show nothing.
##
## `static` because `tower_preview_3d.gd` is a @tool script: at editor time this
## autoload is a placeholder instance, and calling an instance method on it fails
## with "Attempt to call a method on a placeholder instance". A static function
## needs no instance, so the preview can preload this script and call it directly —
## the same trick the preview already uses for `constants.gd`. Nothing here reads
## `all_towers`, so there is no instance state to lose.
static func get_preview_model(tower_id: String, star: int) -> PackedScene:
	# A placeholder tower borrows another line's model (preview_model_id).
	var def := find_definition(tower_id)
	var model_id: String = tower_id
	if def != null and not def.preview_model_id.is_empty():
		model_id = def.preview_model_id
	var path := "res://assets/models/towers/%s/%s_lvl%d.glb" % [model_id, model_id, star]
	if not ResourceLoader.exists(path):
		return null
	return load(path)


## True when the player can actually pick this tower: it has to exist as real
## content AND have been earned.
func is_playable(tower_id: String) -> bool:
	var tower := get_by_id(tower_id)
	return tower != null and tower.unlocked and tower_id in MetaManager.owned_towers
