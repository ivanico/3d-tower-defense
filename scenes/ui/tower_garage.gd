extends CanvasLayer

const MetaRowScene := preload("res://scenes/ui/widget/meta_row/meta_row.tscn")
const ICON_HP := preload("res://assets/ui/garage/icon_stat_hp.png")
const ICON_ATK := preload("res://assets/ui/garage/icon_stat_atk.png")

# Preloaded rather than referenced as the global class `NavBar`: `class_name` only
# resolves through .godot/global_script_class_cache.cfg, which ONLY the editor
# rebuilds, so a headless run or a fresh clone fails to parse until someone opens
# the editor. preload has no such dependency. Node refs below are typed to their
# base class for the same reason — the methods resolve dynamically at runtime.
const NavBarScript := preload("res://scenes/ui/widget/nav_bar/nav_bar.gd")

@onready var tower_list: VBoxContainer = $ScrollContainer/TowerList
@onready var energy_pill: Control = $TopBar/EnergyPill
@onready var materials_pill: Control = $TopBar/MaterialsPill
@onready var nav_bar: Control = $NavBar

func _ready() -> void:
	# NavBar enlarges and disables the entry we are on; no per-button fiddling.
	nav_bar.selected = NavBarScript.Nav.GARAGE
	$NavBar/WorldmapButton.pressed.connect(_on_map_pressed)
	$NavBar/CodexButton.pressed.connect(_on_codex_pressed)
	_refresh()

func _on_map_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/world_map.tscn")

func _on_codex_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/spell_codex.tscn")

func _refresh() -> void:
	energy_pill.set_amount(MetaManager.energy)
	materials_pill.set_amount(MetaManager.materials)
	for child in tower_list.get_children():
		tower_list.remove_child(child)
		child.queue_free()
	for tower_id in MetaManager.owned_towers:
		_add_tower_row(tower_id)

func _add_tower_row(tower_id: String) -> void:
	var tower_def: TowerDefinition = load("res://resources/towers/tower_%s.tres" % tower_id)
	var star: int = MetaManager.tower_stars.get(tower_id, 1)
	var at_max: bool = star >= Constants.TOWER_MAX_STARS
	var next_star: int = star + 1

	# Added to the tree first so the row's @onready refs resolve before setup.
	var row: MetaRow = MetaRowScene.instantiate()
	row.name = "TowerRow_%s" % tower_id
	tower_list.add_child(row)

	row.set_row_icon(tower_def.icon)
	row.set_title(tower_def.tower_name)
	row.show_stars(star)
	row.show_select(MetaManager.selected_tower_id == tower_id)
	row.select_pressed.connect(_on_select_pressed.bind(tower_id))

	row.set_stat_chip(0, ICON_HP, _hp_text(tower_def, star, next_star, at_max))
	row.set_stat_chip(1, ICON_ATK, _damage_text(star, next_star, at_max))

	if at_max:
		row.set_upgrade_maxed()
	else:
		var cost: int = Constants.TOWER_STAR_COSTS[star]
		row.set_upgrade_cost(cost, MetaManager.materials >= cost)
		row.upgrade_pressed.connect(_on_upgrade_pressed.bind(tower_id))

func _hp_text(tower_def: TowerDefinition, star: int, next_star: int, at_max: bool) -> String:
	var current: float = CombatUtils.calculate_star_scaled_value(tower_def.base_hp, star)
	if at_max:
		return "%d" % int(round(current))
	var next: float = CombatUtils.calculate_star_scaled_value(tower_def.base_hp, next_star)
	return "%d → %d" % [int(round(current)), int(round(next))]

func _damage_text(star: int, next_star: int, at_max: bool) -> String:
	var current: float = (CombatUtils.calculate_star_scaled_value(1.0, star) - 1.0) * 100.0
	if at_max:
		return "+%d%%" % int(round(current))
	var next: float = (CombatUtils.calculate_star_scaled_value(1.0, next_star) - 1.0) * 100.0
	return "+%d%% → +%d%%" % [int(round(current)), int(round(next))]

func _on_select_pressed(tower_id: String) -> void:
	MetaManager.selected_tower_id = tower_id
	_refresh()

func _on_upgrade_pressed(tower_id: String) -> void:
	if MetaManager.upgrade_tower_star(tower_id):
		AudioManager.play_sfx("sfx_upgrade_confirm")
	_refresh()
