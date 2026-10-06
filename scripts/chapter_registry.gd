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


## 0-based place of `chapter_id` in play order, or -1 if no chapter has it.
static func index_of(chapter_id: String) -> int:
	var chapters := all()
	for i in chapters.size():
		if chapters[i].chapter_id == chapter_id:
			return i
	return -1


## 1-based number shown to the player ("Chapter 3"): its place in play order.
static func number_of(chapter_id: String) -> int:
	return index_of(chapter_id) + 1


## Index of the last chapter in play order that is_unlocked() lets through
## (chapter 1 at worst, which is never locked). Used when a saved chapter is
## locked (09-10 Q3).
static func furthest_open_index() -> int:
	var chapters := all()
	for i in range(chapters.size() - 1, -1, -1):
		if is_unlocked(chapters[i].chapter_id):
			return i
	return 0


## The chapter after `chapter_id` in play order, or null for the last one.
static func next_of(chapter_id: String) -> Resource:
	var chapters := all()
	for i in chapters.size() - 1:
		if chapters[i].chapter_id == chapter_id:
			return chapters[i + 1]
	return null


## THE unlock rule (09-10), used everywhere a chapter can be locked: the first
## chapter is always open; chapter N+1 opens once N has been cleared.
static func is_unlocked(chapter_id: String) -> bool:
	var chapters := all()
	for i in chapters.size():
		if chapters[i].chapter_id == chapter_id:
			return i == 0 or chapters[i - 1].chapter_id in MetaManager.cleared_chapters
	return false


## "Beat Chapter N to unlock", N = `chapter_id`'s place in play order. Shared by
## the garage (a tower's unlock_chapter_id) and the chapter screen (the chapter
## before a locked one). A chapter not built yet falls back to the number
## in its id ("chapter_03" -> 3).
static func beat_to_unlock_text(chapter_id: String) -> String:
	var number := number_of(chapter_id)
	if number == 0:
		number = chapter_id.get_slice("_", 1).to_int()
	return "Beat Chapter %d to unlock" % number
