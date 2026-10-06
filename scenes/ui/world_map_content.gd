extends Control

## Home screen. Shows the chosen chapter's artwork with its name above it and a
## Play button that spends energy and starts the run.
##
## Archero-style (09-09 change, 2026-10-06): the home screen shows one chapter
## only — no arrows, no swipe. Tapping the picture opens the chapter screen
## (chapter_select.tscn, on its own CanvasLayer so it covers the shell's NavBar).
## Its Enter picks a chapter, saves it and hands it back here; Play then starts
## that chapter. The shown chapter is MetaManager.last_chapter_id, so the map
## reopens on it after a restart.
##
## Content-only: no NavBar of its own. This scene lives inside `world_map.gd`'s
## shell, which owns the shared NavBar and calls `_refresh()` on this node
## directly. Play still goes through a real `change_scene_to_file` into
## `game_world.tscn` — that is a genuine change of game mode, not a hop between
## meta screens, so it is unaffected by the shell's slide navigation.

const ChapterRegistry := preload("res://scripts/chapter_registry.gd")
const OUT_OF_ENERGY_DISPLAY_SEC := 2.0

@onready var title_label: Label = $TitleLabel
@onready var chapter_image: Control = $ChapterImage
@onready var out_of_energy_label: Label = $OutOfEnergyLabel
@onready var play_button: Button = $PlayButton
@onready var chapter_select: Control = $ChapterSelectLayer/ChapterSelect
@onready var energy_pill: Control = $TopBar/EnergyPill
@onready var materials_pill: Control = $TopBar/MaterialsPill

var _chapters: Array = []
var _current_index: int = 0

func _ready() -> void:
	_chapters = ChapterRegistry.all()
	_current_index = maxi(ChapterRegistry.index_of(MetaManager.last_chapter_id), 0)
	# A saved chapter that is locked (e.g. browsed before locks existed) opens on
	# the furthest open chapter instead (09-10 Q3).
	if _is_locked(_current_chapter()):
		_current_index = ChapterRegistry.furthest_open_index()
	out_of_energy_label.visible = false
	chapter_select.visible = false
	play_button.cost_amount = Constants.ENERGY_COST_PER_RUN
	play_button.pressed.connect(_on_play_pressed)
	chapter_image.gui_input.connect(_on_chapter_image_input)
	chapter_select.chapter_entered.connect(_on_chapter_entered)
	_refresh()

func _refresh() -> void:
	energy_pill.set_amount(MetaManager.energy)
	materials_pill.set_amount(MetaManager.base_material)
	var chapter_def := _current_chapter()
	title_label.text = chapter_def.chapter_name
	if chapter_def.map_image != null:
		chapter_image.chapter_image = chapter_def.map_image

func _current_chapter() -> ChapterDefinition:
	return _chapters[_current_index]

func _is_locked(chapter_def: ChapterDefinition) -> bool:
	return not ChapterRegistry.is_unlocked(chapter_def.chapter_id)

## A tap (press + release) on the picture opens the chapter screen.
func _on_chapter_image_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT \
			and not event.pressed:
		chapter_select.open(_current_chapter().chapter_id)

func _on_chapter_entered(chapter_id: String) -> void:
	_current_index = maxi(ChapterRegistry.index_of(chapter_id), 0)
	_refresh()

func _on_play_pressed() -> void:
	# Never reachable through the UI (Enter refuses locked chapters and _ready
	# falls back to an open one); kept as the last guard before spending energy.
	if _is_locked(_current_chapter()):
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
