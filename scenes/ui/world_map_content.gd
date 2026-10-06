extends Control

## Home screen. Shows the current chapter's artwork with its name above it and a
## Play button that spends energy and starts the run.
##
## Chapter carousel (09-09): every chapter from ChapterRegistry, in play order.
## The arrows and a horizontal swipe on the artwork move `_current_index`; the
## picture slides out and the next one slides in from the side moved towards,
## clipped to the `Carousel` band. The list stops at both ends (the arrow on that
## side hides). The shown chapter is saved at once (MetaManager.select_chapter),
## so the map reopens on it after a restart. The artwork itself stays display-only
## (chapter_node.gd); the swipe is read here, on the Carousel band.
##
## Content-only: no NavBar of its own. This scene lives inside `world_map.gd`'s
## shell, which owns the shared NavBar and calls `_refresh()` on this node
## directly. Play still goes through a real `change_scene_to_file` into
## `game_world.tscn` — that is a genuine change of game mode, not a hop between
## meta screens, so it is unaffected by the shell's slide navigation.

const ChapterRegistry := preload("res://scripts/chapter_registry.gd")
const CHAPTER_NODE_SCENE := preload("res://scenes/ui/widget/chapter_node/chapter_node.tscn")
const OUT_OF_ENERGY_DISPLAY_SEC := 2.0
## How long one chapter-to-chapter slide takes.
const SLIDE_TIME_SEC := 0.25
## A drag shorter than this (design pixels), or more vertical than horizontal,
## is a tap, not a swipe.
const SWIPE_MIN_PX := 80.0

@onready var title_label: Label = $TitleLabel
@onready var carousel: Control = $Carousel
@onready var out_of_energy_label: Label = $OutOfEnergyLabel
@onready var locked_label: Label = $LockedLabel
@onready var play_button: Button = $PlayButton
@onready var left_arrow: Button = $LeftArrow
@onready var right_arrow: Button = $RightArrow
@onready var energy_pill: Control = $TopBar/EnergyPill
@onready var materials_pill: Control = $TopBar/MaterialsPill

var _chapters: Array = []
var _current_index: int = 0
## The picture currently on screen. Replaced by the incoming one after a slide.
var _chapter_image: Control
var _slide_tween: Tween
var _press_pos: Vector2
var _pressing: bool = false

func _ready() -> void:
	_chapter_image = $Carousel/ChapterImage
	_chapters = ChapterRegistry.all()
	_current_index = maxi(_index_of(MetaManager.last_chapter_id), 0)
	# A saved chapter that is locked (e.g. browsed before locks existed) opens on
	# the furthest open chapter instead (09-10 Q3).
	if _is_locked(_current_chapter()):
		_current_index = _furthest_open_index()
	out_of_energy_label.visible = false
	play_button.cost_amount = Constants.ENERGY_COST_PER_RUN
	play_button.pressed.connect(_on_play_pressed)
	left_arrow.pressed.connect(_step.bind(-1))
	right_arrow.pressed.connect(_step.bind(1))
	carousel.gui_input.connect(_on_carousel_input)
	_refresh()

func _refresh() -> void:
	energy_pill.set_amount(MetaManager.energy)
	materials_pill.set_amount(MetaManager.base_material)
	var chapter_def := _current_chapter()
	title_label.text = chapter_def.chapter_name
	_show_chapter_on(_chapter_image, chapter_def)
	var locked := _is_locked(chapter_def)
	play_button.disabled = locked
	locked_label.visible = locked
	if locked:
		out_of_energy_label.visible = false
		if _current_index > 0:
			locked_label.text = ChapterRegistry.beat_to_unlock_text(_chapters[_current_index - 1].chapter_id)
	left_arrow.visible = _current_index > 0
	right_arrow.visible = _current_index < _chapters.size() - 1

func _current_chapter() -> ChapterDefinition:
	return _chapters[_current_index]

## THE one lock check for the carousel: ChapterRegistry's rule (09-10). The
## first chapter can never be locked.
func _is_locked(chapter_def: ChapterDefinition) -> bool:
	return not ChapterRegistry.is_unlocked(chapter_def.chapter_id)

## The last chapter in play order that `_is_locked()` lets through (chapter 1 at
## worst, which is never locked).
func _furthest_open_index() -> int:
	for i in range(_chapters.size() - 1, -1, -1):
		if not _is_locked(_chapters[i]):
			return i
	return 0

func _index_of(chapter_id: String) -> int:
	for i in _chapters.size():
		if _chapters[i].chapter_id == chapter_id:
			return i
	return -1

func _show_chapter_on(image: Control, chapter_def: ChapterDefinition) -> void:
	if chapter_def.map_image != null:
		image.chapter_image = chapter_def.map_image
	image.locked = _is_locked(chapter_def)

func _is_sliding() -> bool:
	return _slide_tween != null and _slide_tween.is_running()

## Moves one chapter left (-1) or right (+1). Ignored past either end and while a
## slide is still running.
func _step(direction: int) -> void:
	var target := _current_index + direction
	if _is_sliding() or target < 0 or target >= _chapters.size():
		return
	_current_index = target
	MetaManager.select_chapter(_current_chapter().chapter_id)
	# The incoming picture starts one band-width off on the side moved towards
	# and the old one leaves the opposite way, so "next" reads as turning a page.
	var incoming: Control = CHAPTER_NODE_SCENE.instantiate()
	carousel.add_child(incoming)
	incoming.position = _chapter_image.position
	incoming.size = _chapter_image.size
	var shift := carousel.size.x * direction
	incoming.position.x += shift
	var outgoing := _chapter_image
	_chapter_image = incoming
	_refresh()
	_slide_tween = create_tween().set_parallel(true)
	_slide_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_slide_tween.tween_property(incoming, "position:x", incoming.position.x - shift, SLIDE_TIME_SEC)
	_slide_tween.tween_property(outgoing, "position:x", outgoing.position.x - shift, SLIDE_TIME_SEC)
	_slide_tween.chain().tween_callback(outgoing.queue_free)

## Swipe on the artwork band. Touch arrives as emulated mouse input (the
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
	# Dragging the picture to the LEFT brings in the NEXT chapter.
	_step(1 if drag.x < 0.0 else -1)

func _on_play_pressed() -> void:
	if _is_sliding() or _is_locked(_current_chapter()):
		return
	if not MetaManager.spend_energy():
		_show_out_of_energy()
		return
	_refresh()
	GameState.pending_chapter_def = _current_chapter()
	GameState.pending_tower_def = load(
			"res://resources/towers/tower_%s.tres" % MetaManager.selected_tower_id)
	get_tree().change_scene_to_file("res://scenes/main/game_world.tscn")

func _show_out_of_energy() -> void:
	out_of_energy_label.visible = true
	await get_tree().create_timer(OUT_OF_ENERGY_DISPLAY_SEC).timeout
	if is_instance_valid(self):
		out_of_energy_label.visible = false
