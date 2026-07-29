@tool
extends EditorPlugin

## Keeps every UI icon's import capped at [constant SIZE_LIMIT] pixels.
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
## The art is untouched; only the imported copy is downsampled. See
## "Icon imports are capped" in `ui_tuning.md` for the measured cost of not doing
## this (the spell codex spent 411ms per visit decoding 20 uncapped icons).

## Everything under here is treated as UI art.
const UI_ROOT := "res://assets/ui/"

## Icons are never drawn above ~124px, so 256 leaves headroom for high-DPI.
const SIZE_LIMIT := 256

## Art that is legitimately drawn large and must NOT be downsampled: full-screen
## backgrounds and the stretched panel/button frames. Matched on the file name's
## start, so `_v2` / `_v3` variants are covered too.
## `ui_chapter_node_frame` is here because the world map draws it at 760px
## (`world_map.tscn` -> ChapterImage), so 256 would visibly blur it. If you add
## art that is drawn large, add its prefix here or it WILL get downsampled.
const EXEMPT_PREFIXES: PackedStringArray = [
	"bg_", "chapter_", "ui_panel", "ui_button", "ui_card_bg",
	"ui_play_button", "ui_topbar_pill_bg", "ui_chapter_node_frame",
]

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
		print("UI Icon Import Cap: capped %d image(s) at %dpx" % [changed.size(), SIZE_LIMIT])
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
			if not _is_exempt(entry) and _apply_cap(full_path):
				changed.append(full_path)
		entry = directory.get_next()
	directory.list_dir_end()
	return changed


func _is_exempt(file_name: String) -> bool:
	for prefix in EXEMPT_PREFIXES:
		if file_name.begins_with(prefix):
			return true
	return false


## Rewrites only the one line, by hand rather than through ConfigFile: an
## `.import` also carries `[remap]`, `[deps]` and a top-level `uid`, and round
## -tripping all of that through a config writer risks mangling a file the engine
## depends on. Returns true when the file actually needed changing.
func _apply_cap(image_path: String) -> bool:
	var import_path := image_path + ".import"
	if not FileAccess.file_exists(import_path):
		return false
	var text := FileAccess.get_file_as_string(import_path)
	if text.is_empty():
		return false

	var wanted := "process/size_limit=%d" % SIZE_LIMIT
	if text.contains(wanted):
		return false

	var lines := text.split("\n")
	var output := PackedStringArray()
	var written := false
	for line in lines:
		if line.begins_with("process/size_limit="):
			output.append(wanted)
			written = true
		else:
			output.append(line)
			# No such key yet (a freshly imported file): add it under [params].
			if not written and line.strip_edges() == "[params]":
				output.append(wanted)
				written = true
	if not written:
		return false

	var file := FileAccess.open(import_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string("\n".join(output))
	file.close()
	return true
