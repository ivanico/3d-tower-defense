extends RefCounted

## Every ChapterDefinition in res://resources/chapters/, in play order
## (`sort_order`). Adding a chapter = a new .tres + its arena scene; no code.
##
## Static helpers, preload()ed by callers — deliberately NOT an autoload: adding
## an autoload means editing project.godot while the editor is open, and the
## editor overwrites that file from memory on its next settings save. Same
## pattern as scripts/resource_dir.gd (no class_name, see components.md §7).
## Loading is cheap: ResourceLoader caches each .tres after the first call.

const ResourceDir := preload("res://scripts/resource_dir.gd")
const CHAPTER_DIR := "res://resources/chapters/"


static func all() -> Array:
	var chapters: Array = ResourceDir.load_all(CHAPTER_DIR)
	chapters.sort_custom(func(a, b): return a.sort_order < b.sort_order)
	return chapters


static func get_by_id(chapter_id: String) -> Resource:
	for chapter in all():
		if chapter.chapter_id == chapter_id:
			return chapter
	return null


## 1-based number shown to the player ("Chapter 3"): its place in play order.
static func number_of(chapter_id: String) -> int:
	var chapters := all()
	for i in chapters.size():
		if chapters[i].chapter_id == chapter_id:
			return i + 1
	return 0
