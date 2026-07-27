extends CanvasLayer

const CHAPTER_IDS: Array[String] = ["chapter_01"]
const OUT_OF_ENERGY_DISPLAY_SEC := 2.0
const ChapterNodeScene := preload("res://scenes/ui/widget/chapter_node/chapter_node.tscn")

@onready var out_of_energy_label: Label = $OutOfEnergyLabel
@onready var chapter_grid: GridContainer = $ChapterGrid
@onready var energy_pill: PanelContainer = $TopBar/EnergyPill
@onready var materials_pill: PanelContainer = $TopBar/MaterialsPill
@onready var worldmap_button: TextureButton = $NavBar/WorldmapButton
@onready var garage_button: TextureButton = $NavBar/GarageButton
@onready var codex_button: TextureButton = $NavBar/CodexButton

func _ready() -> void:
	out_of_energy_label.visible = false
	worldmap_button.disabled = true
	garage_button.pressed.connect(_on_garage_pressed)
	codex_button.pressed.connect(_on_codex_pressed)
	_refresh()

func _refresh() -> void:
	energy_pill.set_amount(MetaManager.energy)
	materials_pill.set_amount(MetaManager.materials)
	for child in chapter_grid.get_children():
		chapter_grid.remove_child(child)
		child.queue_free()
	for chapter_id in CHAPTER_IDS:
		chapter_grid.add_child(_build_chapter_node(chapter_id))

func _build_chapter_node(chapter_id: String) -> Control:
	var chapter_def: ChapterDefinition = load("res://resources/chapters/%s.tres" % chapter_id)
	var node: Button = ChapterNodeScene.instantiate()
	node.name = "ChapterNode_%s" % chapter_id
	node.chapter_title = chapter_def.chapter_name
	node.pressed.connect(_on_chapter_pressed.bind(chapter_id))
	return node

func _on_chapter_pressed(chapter_id: String) -> void:
	if not MetaManager.spend_energy():
		_show_out_of_energy()
		return
	_refresh()
	GameState.pending_chapter_def = load("res://resources/chapters/%s.tres" % chapter_id)
	GameState.pending_tower_def = load("res://resources/towers/tower_%s.tres" % MetaManager.selected_tower_id)
	get_tree().change_scene_to_file("res://scenes/main/game_world.tscn")

func _show_out_of_energy() -> void:
	out_of_energy_label.visible = true
	await get_tree().create_timer(OUT_OF_ENERGY_DISPLAY_SEC).timeout
	if is_instance_valid(self):
		out_of_energy_label.visible = false

func _on_garage_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/tower_garage.tscn")

func _on_codex_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/spell_codex.tscn")
