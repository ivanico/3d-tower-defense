extends RefCounted

## Loads every `.tres` in a folder, in filename order.
##
## ONE scan, shared by SpellRegistry and TowerRegistry — do not copy this loop into
## a registry. Non-`.tres` files in the folder (a `*_definition.gd` sitting next to
## its resources, `.uid` sidecars) are skipped, so registries can live beside their
## own script.
##
## Consumers `preload()` this rather than reaching for a global `class_name`.
## `class_name` only resolves through .godot/global_script_class_cache.cfg, which
## ONLY the editor rebuilds — so a headless run or a fresh clone can fail to parse
## until someone opens the editor. preload has no such dependency.


static func load_all(path: String) -> Array:
	var result: Array = []
	var dir := DirAccess.open(path)
	if dir == null:
		push_warning("ResourceDir: cannot open %s" % path)
		return result
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var res: Resource = load(path.path_join(file_name))
			if res != null:
				result.append(res)
		file_name = dir.get_next()
	dir.list_dir_end()
	return result
