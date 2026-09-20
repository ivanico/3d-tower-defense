extends Control

## Home screen. Shows the current chapter's artwork with its name above it and a
## Play button that spends energy and starts the run.
##
## v1 has one chapter, so the chapter is simply CHAPTER_IDS[0] rather than a grid
## of selectable nodes. Picking between chapters needs a carousel here plus a way
## to move `_current_index`; the artwork itself is display-only by design (see
## chapter_node.gd), so the Play button stays the single control.
##
## Content-only: no NavBar of its own. This scene lives inside `world_map.gd`'s
## shell, which owns the shared NavBar and calls `_refresh()` on this node
## directly. Play still goes through a real `change_scene_to_file` into
## `game_world.tscn` — that is a genuine change of game mode, not a hop between
## meta screens, so it is unaffected by the shell's slide navigation.

const CHAPTER_IDS: Array[String] = ["chapter_01"]
const OUT_OF_ENERGY_DISPLAY_SEC := 2.0

@onready var title_label: Label = $TitleLabel
@onready var chapter_image: Control = $ChapterImage
@onready var out_of_energy_label: Label = $OutOfEnergyLabel
@onready var play_button: Button = $PlayButton
@onready var energy_pill: Control = $TopBar/EnergyPill
@onready var materials_pill: Control = $TopBar/MaterialsPill

var _current_index: int = 0

func _ready() -> void:
	out_of_energy_label.visible = false
	play_button.cost_amount = Constants.ENERGY_COST_PER_RUN
	play_button.pressed.connect(_on_play_pressed)
	_refresh()

func _refresh() -> void:
	energy_pill.set_amount(MetaManager.energy)
	materials_pill.set_amount(MetaManager.base_material)
	var chapter_def := _current_chapter()
	title_label.text = chapter_def.chapter_name
	if chapter_def.map_image != null:
		chapter_image.chapter_image = chapter_def.map_image

func _current_chapter() -> ChapterDefinition:
	return load("res://resources/chapters/%s.tres" % CHAPTER_IDS[_current_index])

func _on_play_pressed() -> void:
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
