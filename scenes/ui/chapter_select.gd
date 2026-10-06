extends Control

## Archero-style chapter screen (09-09 change, 2026-10-06). Opened by tapping the
## chapter picture on the home screen (world_map_content.gd); it draws over the
## shell's NavBar, so the bottom menu is hidden while it's open.
##
## Every chapter from ChapterRegistry sits on one horizontal `Strip`, PAGE_SPACING
## apart, so the neighbours of the centred chapter peek in at the sides. A
## horizontal swipe on the `Carousel` band slides the strip one page; it stops at
## both ends. The text below (length, description, lock line) always describes
## the centred chapter.
##
## Swiping only looks. Enter is the one thing that picks a chapter: it saves it
## (MetaManager.select_chapter), emits `chapter_entered` and closes. Back closes
## without changing anything. Enter is hidden on locked chapters, so the home
## screen only ever receives an open chapter.
##
## Editor preview: the three ChapterNode children of `Strip` in the .tscn
## (previous / current / next) are layout placeholders; open() replaces them.

signal chapter_entered(chapter_id: String)

const ChapterRegistry := preload("res://scripts/chapter_registry.gd")
const CHAPTER_NODE_SCENE := preload("res://scenes/ui/widget/chapter_node/chapter_node.tscn")
## How long one chapter-to-chapter slide takes.
const SLIDE_TIME_SEC := 0.25
## A drag shorter than this (design pixels), or more vertical than horizontal,
## is a tap, not a swipe.
const SWIPE_MIN_PX := 80.0
## Distance between two chapters on the strip. Smaller than the band width, so
## the neighbours show at the sides.
const PAGE_SPACING := 720.0

@onready var title_label: Label = $TitleLabel
@onready var carousel: Control = $Carousel
@onready var strip: Control = $Carousel/Strip
@onready var length_label: Label = $LengthLabel
@onready var description_label: Label = $DescriptionLabel
@onready var locked_label: Label = $LockedLabel
@onready var enter_button: Button = $EnterButton
@onready var back_button: Button = $BackButton
@onready var energy_pill: Control = $TopBar/EnergyPill
@onready var materials_pill: Control = $TopBar/MaterialsPill

var _chapters: Array = []
var _current_index: int = 0
## Left edge of the centred page inside the band (taken from the placeholder).
var _page_left: float = 0.0
var _slide_tween: Tween
var _press_pos: Vector2
var _pressing: bool = false

func _ready() -> void:
	_page_left = strip.get_child(1).position.x
	enter_button.pressed.connect(_on_enter_pressed)
	back_button.pressed.connect(close)
	carousel.gui_input.connect(_on_carousel_input)

## Shows the screen centred on `chapter_id` (chapter 1 if unknown).
func open(chapter_id: String) -> void:
	_chapters = ChapterRegistry.all()
	_current_index = maxi(ChapterRegistry.index_of(chapter_id), 0)
	_build_strip()
	_pressing = false
	visible = true
	_refresh()

func close() -> void:
	if _is_sliding():
		return
	visible = false

func _build_strip() -> void:
	for child in strip.get_children():
		strip.remove_child(child)
		child.queue_free()
	for i in _chapters.size():
		var chapter_def: ChapterDefinition = _chapters[i]
		var page: Control = CHAPTER_NODE_SCENE.instantiate()
		strip.add_child(page)
		page.position = Vector2(_page_left + i * PAGE_SPACING, 0.0)
		if chapter_def.map_image != null:
			page.chapter_image = chapter_def.map_image
		page.locked = _is_locked(chapter_def)
	strip.position.x = _strip_x(_current_index)

func _strip_x(index: int) -> float:
	return -index * PAGE_SPACING

func _refresh() -> void:
	energy_pill.set_amount(MetaManager.energy)
	materials_pill.set_amount(MetaManager.base_material)
	var chapter_def := _current_chapter()
	title_label.text = "%d. %s" % [_current_index + 1, chapter_def.chapter_name]
	length_label.text = "Chapter Length: %d" % chapter_def.wave_count
	description_label.text = chapter_def.description
	var locked := _is_locked(chapter_def)
	# Locked: Enter is hidden, not greyed (user, 2026-10-06), and the
	# "Beat Chapter N" line shows instead. disabled stays as a guard.
	enter_button.visible = not locked
	enter_button.disabled = locked
	locked_label.visible = locked
	if locked:
		locked_label.text = ChapterRegistry.beat_to_unlock_text(_chapters[_current_index - 1].chapter_id)

func _current_chapter() -> ChapterDefinition:
	return _chapters[_current_index]

func _is_locked(chapter_def: ChapterDefinition) -> bool:
	return not ChapterRegistry.is_unlocked(chapter_def.chapter_id)

func _is_sliding() -> bool:
	return _slide_tween != null and _slide_tween.is_running()

## Moves one chapter left (-1) or right (+1). Ignored past either end and while a
## slide is still running.
func _step(direction: int) -> void:
	var target := _current_index + direction
	if _is_sliding() or target < 0 or target >= _chapters.size():
		return
	_current_index = target
	_refresh()
	_slide_tween = create_tween()
	_slide_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_slide_tween.tween_property(strip, "position:x", _strip_x(target), SLIDE_TIME_SEC)

## Swipe on the picture band. Touch arrives as emulated mouse input (the
## project's default), so one handler covers phones and the editor.
func _on_carousel_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if event.pressed:
		_pressing = true
		_press_pos = event.position
		return
	if not _pressing:
		return
	_pressing = false
	var drag: Vector2 = event.position - _press_pos
	if absf(drag.x) < SWIPE_MIN_PX or absf(drag.x) < absf(drag.y):
		return
	# Dragging the pictures to the LEFT brings in the NEXT chapter.
	_step(1 if drag.x < 0.0 else -1)

func _on_enter_pressed() -> void:
	if _is_sliding() or _is_locked(_current_chapter()):
		return
	var chapter_id := _current_chapter().chapter_id
	MetaManager.select_chapter(chapter_id)
	visible = false
	chapter_entered.emit(chapter_id)
