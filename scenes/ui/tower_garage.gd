extends CanvasLayer

## Tower Garage. A 3D preview of the tower you are looking at with its stars, name
## and stats above a grid of every tower that exists, and an Upgrade bar.
##
## Tapping a tower in the grid picks it outright — it becomes both the one shown
## in 3D and `MetaManager.selected_tower_id`, the one that goes into a run. There
## used to be a separate Select button confirming the second step; with one tower
## per tap it had nothing to do, so the action bar is just Upgrade.
##
## The grid is data-driven off `TowerRegistry.all_towers`, so adding a tower is a
## new `.tres` in `res://resources/towers/` — no code and no scene change. Nothing
## here hardcodes a slot count.

const TowerSlotScene := preload("res://scenes/ui/widget/tower_slot/tower_slot.tscn")

# Preloaded rather than referenced as the global class `NavBar`: `class_name` only
# resolves through .godot/global_script_class_cache.cfg, which ONLY the editor
# rebuilds, so a headless run or a fresh clone fails to parse until someone opens
# the editor. preload has no such dependency. Node refs below are typed to their
# base class for the same reason — the methods resolve dynamically at runtime.
const NavBarScript := preload("res://scenes/ui/widget/nav_bar/nav_bar.gd")
const CombatUtilsScript := preload("res://scripts/combat_utils.gd")

@onready var preview: Control = $Preview3D
@onready var star_row: HBoxContainer = $StarRow
@onready var name_label: Label = $NameLabel
@onready var level_pill: Control = $StatsStrip/Level
@onready var atk_pill: Control = $StatsStrip/Atk
@onready var hp_pill: Control = $StatsStrip/Hp
@onready var tower_grid: GridContainer = $TowerGrid
@onready var upgrade_button: Button = $ActionBar/UpgradeButton
# Typed to the base class, not the global class name `CostChip` — see the
# note above about class_name only resolving through the editor-built
# global script class cache.
@onready var base_chip: HBoxContainer = $ActionBar/BaseChip
@onready var rare_chip: HBoxContainer = $ActionBar/RareChip
@onready var energy_pill: Control = $TopBar/EnergyPill
@onready var materials_pill: Control = $TopBar/MaterialsPill
@onready var nav_bar: Control = $NavBar

## The tower being shown, which is also the one a run will use.
var _viewing_id: String = ""

## tower_id -> its slot, so `_refresh` can restyle cells without rebuilding them.
var _slots: Dictionary = {}

func _ready() -> void:
	# NavBar enlarges and disables the entry we are on; no per-button fiddling.
	nav_bar.selected = NavBarScript.Nav.GARAGE
	$NavBar/WorldmapButton.pressed.connect(_on_map_pressed)
	$NavBar/CodexButton.pressed.connect(_on_codex_pressed)
	# Connected once, not per refresh — the buttons live in the scene and are never
	# freed, so reconnecting them on every redraw would stack duplicate calls.
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	_viewing_id = MetaManager.selected_tower_id
	_build_grid()
	_refresh()

# navigate_to plays the nav bar's select transition before swapping scene;
# calling change_scene_to_file here directly would cut it off on frame one.
func _on_map_pressed() -> void:
	nav_bar.navigate_to(NavBarScript.Nav.WORLDMAP, "res://scenes/ui/world_map.tscn")

func _on_codex_pressed() -> void:
	nav_bar.navigate_to(NavBarScript.Nav.CODEX, "res://scenes/ui/spell_codex.tscn")

# Built once. Which cell is highlighted, and each cell's star count, change often;
# which cells EXIST does not, so nothing here is redone by _refresh.
func _build_grid() -> void:
	# tower_garage.tscn holds six placeholder cells purely so the grid is visible
	# in the editor. Clear them before building the real ones.
	for placeholder in tower_grid.get_children():
		tower_grid.remove_child(placeholder)
		placeholder.queue_free()
	var cell := _cell_size()
	for tower_def in TowerRegistry.all_towers:
		var slot: Button = TowerSlotScene.instantiate()
		slot.name = "TowerSlot_%s" % tower_def.tower_id
		slot.custom_minimum_size = cell
		# Added to the tree first so the slot's internal children lay out against a
		# real size before the properties below are applied.
		tower_grid.add_child(slot)
		slot.icon_texture = tower_def.icon
		# One call answers both "does this tower exist as content" (unlocked) and
		# "has the player earned it" (owned_towers). Locked slots grey out, show the
		# padlock and refuse presses on their own — no guard needed in the handler.
		slot.locked = not TowerRegistry.is_playable(tower_def.tower_id)
		slot.slot_pressed.connect(_on_slot_pressed.bind(tower_def.tower_id))
		_slots[tower_def.tower_id] = slot

# Square cells that exactly fill the grid's width at its column count, so the two
# can never drift: change `columns` or `h_separation` in the scene and the cells
# resize themselves. Square because the tower art fills the whole cell now.
func _cell_size() -> Vector2:
	var columns: int = maxi(tower_grid.columns, 1)
	var gaps: int = tower_grid.get_theme_constant("h_separation") * (columns - 1)
	var edge: float = floorf((tower_grid.size.x - gaps) / columns)
	return Vector2(edge, edge)


func _refresh() -> void:
	energy_pill.set_amount(MetaManager.energy)
	materials_pill.set_amount(MetaManager.base_material)

	var tower_def: Resource = TowerRegistry.get_by_id(_viewing_id)
	var star: int = _star_of(_viewing_id)
	var at_max: bool = star >= Constants.TOWER_MAX_STARS

	# The preview shows the raw .glb via TowerRegistry.get_preview_model(), never the
	# tower's star_level_scenes — those are gameplay scenes and tower.gd._ready()
	# calls GameState.start_run(), so one on this screen would begin a run.
	preview.show_tower(_viewing_id, star)
	star_row.stars = star
	name_label.text = tower_def.tower_name
	level_pill.value_text = "%d/%d" % [star, Constants.TOWER_MAX_STARS]
	_set_stat(atk_pill, tower_def.base_damage, star, at_max)
	_set_stat(hp_pill, tower_def.base_hp, star, at_max)

	for tower_id in _slots:
		var slot: Button = _slots[tower_id]
		slot.selected = tower_id == _viewing_id
		slot.stars = _star_of(tower_id)

	var playable: bool = TowerRegistry.is_playable(_viewing_id)
	if at_max:
		upgrade_button.text = "MAX"
		upgrade_button.disabled = true
		base_chip.visible = false
		rare_chip.visible = false
	else:
		var base_cost: int = Constants.TOWER_STAR_COSTS[star]
		var rare_cost: int = Constants.TOWER_STAR_RARE_COSTS[star]
		var base_affordable: bool = MetaManager.base_material >= base_cost
		var rare_affordable: bool = MetaManager.tower_material >= rare_cost
		base_chip.visible = true
		rare_chip.visible = true
		base_chip.set_cost(base_cost, CombatUtilsScript.BASE_MATERIAL_ICON, base_affordable)
		rare_chip.set_cost(rare_cost, CombatUtilsScript.TOWER_MATERIAL_ICON, rare_affordable)
		upgrade_button.text = "Upgrade"
		upgrade_button.disabled = not (base_affordable and rare_affordable) or not playable

func _star_of(tower_id: String) -> int:
	return MetaManager.tower_stars.get(tower_id, 1)

# The value plus what one more star would add, which is the whole point of the
# readout — you can see the upgrade before paying for it. Every stat scales the
# same way, so ATK and HP share this.
func _set_stat(pill: Control, base_value: float, star: int, at_max: bool) -> void:
	var current: float = CombatUtilsScript.calculate_star_scaled_value(base_value, star)
	pill.value_text = "%d" % int(round(current))
	if at_max:
		# The pill hides an empty delta by itself; "+0" would just be noise.
		pill.delta_text = ""
		return
	var next: float = CombatUtilsScript.calculate_star_scaled_value(base_value, star + 1)
	pill.delta_text = "(+%d)" % int(round(next - current))

# tower_slot swallows presses on locked cells, so anything arriving here is a
# tower the player owns and can take into a run.
func _on_slot_pressed(tower_id: String) -> void:
	_viewing_id = tower_id
	MetaManager.selected_tower_id = tower_id
	_refresh()

func _on_upgrade_pressed() -> void:
	if MetaManager.upgrade_tower_star(_viewing_id):
		AudioManager.play_sfx("sfx_upgrade_confirm")
	_refresh()
