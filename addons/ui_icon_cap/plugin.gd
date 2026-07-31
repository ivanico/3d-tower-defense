@tool
extends EditorPlugin

## Keeps every UI image's import capped at a size matched to how large it's
## actually drawn on screen — never [constant DEFAULT_SIZE_LIMIT], full native
## resolution — and forces mipmap generation, since every image here is by
## definition displayed smaller than its imported size.
##
## **Why this exists instead of just editing the `.import` files.** `size_limit`
## lives in a per-file `.import`, and Godot writes a FRESH one with
## `size_limit=0` whenever a source image is added or replaced. So delete an icon,
## drop a new one in with the same name, and the cap silently disappears — which
## is exactly how `ui_star_filled`, `ui_star_empty`, `ui_notification_badge` and
## `icon_stat_level` ended up shipping at 1254px each. This re-applies the cap
## every time the filesystem changes, so a replaced file is capped again before
## you can run the game.
##
## The art is untouched; only the imported copy is downsampled. See the
## "UI image imports are size-capped" gotcha in `ui_tuning.md` for the measured
## cost of not doing this (the spell codex spent 411ms per visit decoding 20
## uncapped icons).

## Everything under here is treated as UI art.
const UI_ROOT := "res://assets/ui/"

## Ordered rule table: the first entry whose prefix matches the file name wins.
## Sizes are the audited max on-screen size for that category with ~2x headroom
## for high-DPI phones. Add a prefix here (or widen an existing entry) when new
## art is legitimately drawn larger than [constant DEFAULT_SIZE_LIMIT] — anything
## NOT listed still gets capped (at the default), it just may need a wider rule
## if it looks soft.
const SIZE_RULES: Array[Dictionary] = [
	{"prefixes": ["ui_panel"], "size_limit": 1536},
	{"prefixes": ["ui_button", "ui_play_button", "ui_topbar_pill_bg"], "size_limit": 768},
	{"prefixes": ["ui_card_bg", "ui_chapter_node_frame"], "size_limit": 512},
	{"prefixes": ["bg_", "chapter_"], "size_limit": 1920},
]

## Everything that doesn't match a rule above — icons, and any future/unrecognized
## art (e.g. a new "store_" screen) — falls back to this. Icons are never drawn
## above ~124px, so 256 leaves headroom for high-DPI; anything uncategorized gets
## the same safe default rather than shipping uncapped.
const DEFAULT_SIZE_LIMIT := 256

const IMAGE_EXTENSIONS: PackedStringArray = ["png", "jpg", "jpeg", "webp"]

## Reimporting emits `filesystem_changed` again; without this the plugin would
## chase its own tail.
var _working := false


func _enter_tree() -> void:
	var filesystem := EditorInterface.get_resource_filesystem()
	if not filesystem.filesystem_changed.is_connected(_on_filesystem_changed):
		filesystem.filesystem_changed.connect(_on_filesystem_changed)
	# NOT called straight away. A plugin's _enter_tree runs early in editor boot,
	# and reimporting there forces scripts to reload before the autoloads are
	# registered — which surfaces as "Identifier not found: TowerRegistry" in
	# scripts that are perfectly fine. Wait for the editor to settle first.
	_deferred_first_scan()


func _deferred_first_scan() -> void:
	for _frame in 4:
		await get_tree().process_frame
	var filesystem := EditorInterface.get_resource_filesystem()
	while filesystem.is_scanning():
		await get_tree().process_frame
	_on_filesystem_changed()


func _exit_tree() -> void:
	var filesystem := EditorInterface.get_resource_filesystem()
	if filesystem.filesystem_changed.is_connected(_on_filesystem_changed):
		filesystem.filesystem_changed.disconnect(_on_filesystem_changed)


func _on_filesystem_changed() -> void:
	if _working:
		return
	_working = true
	var changed := _enforce_in(UI_ROOT)
	if not changed.is_empty():
		print("UI Icon Import Cap: capped %d image(s)" % changed.size())
		for path in changed:
			print("    ", path)
		# Reimporting from inside the signal trips Godot's "Do not use progress
		# dialog while flushing the message queue" assert and fills the log with
		# noise. One idle frame is enough to be clear of it.
		await get_tree().process_frame
		EditorInterface.get_resource_filesystem().reimport_files(changed)
	_working = false


func _enforce_in(directory_path: String) -> PackedStringArray:
	var changed := PackedStringArray()
	var directory := DirAccess.open(directory_path)
	if directory == null:
		return changed
	directory.list_dir_begin()
	var entry := directory.get_next()
	while entry != "":
		var full_path := directory_path.path_join(entry)
		if directory.current_is_dir():
			changed.append_array(_enforce_in(full_path))
		elif entry.get_extension().to_lower() in IMAGE_EXTENSIONS:
			if _apply_cap(full_path, _size_limit_for(entry)):
				changed.append(full_path)
		entry = directory.get_next()
	directory.list_dir_end()
	return changed


## Every file resolves to a cap — the first matching rule in [constant SIZE_RULES],
## or [constant DEFAULT_SIZE_LIMIT] if nothing matches. Nothing ships uncapped.
func _size_limit_for(file_name: String) -> int:
	for rule in SIZE_RULES:
		for prefix in rule["prefixes"]:
			if file_name.begins_with(prefix):
				return rule["size_limit"]
	return DEFAULT_SIZE_LIMIT


## Rewrites only the relevant lines, by hand rather than through ConfigFile: an
## `.import` also carries `[remap]`, `[deps]` and a top-level `uid`, and round
## -tripping all of that through a config writer risks mangling a file the engine
## depends on. Returns true when the file actually needed changing.
##
## Forces `mipmaps/generate=true` alongside the size cap: every image this
## plugin touches is, by definition, displayed smaller than its imported size
## (that's the whole point of the cap), and downscaling detailed art with no
## mip chain is a GPU minification-aliasing bug — fine detail (outlines, small
## highlights) turns to visible noise. Godot's importer defaults this to false,
## so it would silently regress the same way `size_limit` used to.
func _apply_cap(image_path: String, size_limit: int) -> bool:
	var import_path := image_path + ".import"
	if not FileAccess.file_exists(import_path):
		return false
	var text := FileAccess.get_file_as_string(import_path)
	if text.is_empty():
		return false

	var wanted_lines := {
		"process/size_limit=": "process/size_limit=%d" % size_limit,
		"mipmaps/generate=": "mipmaps/generate=true",
	}

	var already_correct := true
	for wanted_line in wanted_lines.values():
		if not text.contains(wanted_line):
			already_correct = false
			break
	if already_correct:
		return false

	var lines := text.split("\n")
	var output := PackedStringArray()
	var written := {}
	for line in lines:
		var replaced := false
		for prefix in wanted_lines:
			if line.begins_with(prefix):
				output.append(wanted_lines[prefix])
				written[prefix] = true
				replaced = true
				break
		if not replaced:
			output.append(line)
			# No such key yet (a freshly imported file): add missing ones under [params].
			if line.strip_edges() == "[params]":
				for prefix in wanted_lines:
					if not written.has(prefix):
						output.append(wanted_lines[prefix])
						written[prefix] = true
	if written.size() != wanted_lines.size():
		return false

	var file := FileAccess.open(import_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string("\n".join(output))
	file.close()
	return true
