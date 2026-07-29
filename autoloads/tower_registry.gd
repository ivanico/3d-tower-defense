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
	all_towers = ResourceDir.load_all("res://resources/towers/")
	# Explicit sort_order rather than filename order, so renaming a resource
	# cannot silently reshuffle the grid.
	all_towers.sort_custom(func(a, b): return a.sort_order < b.sort_order)
	print("TowerRegistry: %d towers loaded (%d unlocked)" % [
			all_towers.size(), get_unlocked().size()])


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
func get_preview_model(tower_id: String, star: int) -> PackedScene:
	var path := "res://assets/models/towers/%s/%s_lvl%d.glb" % [tower_id, tower_id, star]
	if not ResourceLoader.exists(path):
		return null
	return load(path)


## True when the player can actually pick this tower: it has to exist as real
## content AND have been earned.
func is_playable(tower_id: String) -> bool:
	var tower := get_by_id(tower_id)
	return tower != null and tower.unlocked and tower_id in MetaManager.owned_towers
