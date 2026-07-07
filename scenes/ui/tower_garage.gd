extends CanvasLayer

@onready var materials_label: Label = $MaterialsLabel
@onready var tower_list: VBoxContainer = $ScrollContainer/TowerList
@onready var back_button: Button = $BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	_refresh()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/world_map.tscn")

func _refresh() -> void:
	materials_label.text = "Materials: %d" % MetaManager.materials
	for child in tower_list.get_children():
		tower_list.remove_child(child)
		child.queue_free()
	for tower_id in MetaManager.owned_towers:
		tower_list.add_child(_build_tower_row(tower_id))

func _build_tower_row(tower_id: String) -> Control:
	var tower_def: TowerDefinition = load("res://resources/towers/tower_%s.tres" % tower_id)
	var star: int = MetaManager.tower_stars.get(tower_id, 1)
	var at_max: bool = star >= Constants.TOWER_MAX_STARS
	var next_star: int = star + 1

	var card := VBoxContainer.new()
	card.name = "TowerRow_%s" % tower_id
	card.add_theme_constant_override("separation", 6)

	var top_row := HBoxContainer.new()
	top_row.name = "TopRow"
	top_row.add_theme_constant_override("separation", 20)
	card.add_child(top_row)

	var name_label := Label.new()
	name_label.name = "NameLabel"
	name_label.text = tower_def.tower_name
	name_label.custom_minimum_size = Vector2(280, 0)
	name_label.add_theme_font_size_override("font_size", 28)
	top_row.add_child(name_label)

	var stars_label := Label.new()
	stars_label.name = "StarsLabel"
	stars_label.text = _star_string(star)
	stars_label.custom_minimum_size = Vector2(200, 0)
	stars_label.add_theme_font_size_override("font_size", 28)
	top_row.add_child(stars_label)

	var select_button := CheckButton.new()
	select_button.name = "SelectButton"
	select_button.text = "In Use"
	select_button.button_pressed = (MetaManager.selected_tower_id == tower_id)
	select_button.disabled = (MetaManager.selected_tower_id == tower_id)
	select_button.pressed.connect(_on_select_pressed.bind(tower_id))
	top_row.add_child(select_button)

	var stats_label := Label.new()
	stats_label.name = "StatsLabel"
	stats_label.text = _stats_text(tower_def, star, next_star, at_max)
	stats_label.add_theme_font_size_override("font_size", 22)
	stats_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8))
	card.add_child(stats_label)

	var upgrade_button := Button.new()
	upgrade_button.name = "UpgradeButton"
	upgrade_button.add_theme_font_size_override("font_size", 24)
	if at_max:
		upgrade_button.text = "MAX"
		upgrade_button.disabled = true
	else:
		var cost: int = Constants.TOWER_STAR_COSTS[star]
		upgrade_button.text = "Upgrade (%d)" % cost
		upgrade_button.disabled = MetaManager.materials < cost
		upgrade_button.pressed.connect(_on_upgrade_pressed.bind(tower_id))
	card.add_child(upgrade_button)

	return card

func _stats_text(tower_def: TowerDefinition, star: int, next_star: int, at_max: bool) -> String:
	var current_hp: float = CombatUtils.calculate_star_scaled_value(tower_def.base_hp, star)
	var current_dmg_pct: float = (CombatUtils.calculate_star_scaled_value(1.0, star) - 1.0) * 100.0
	if at_max:
		return "HP: %d   DMG Bonus: +%d%%" % [int(round(current_hp)), int(round(current_dmg_pct))]
	var next_hp: float = CombatUtils.calculate_star_scaled_value(tower_def.base_hp, next_star)
	var next_dmg_pct: float = (CombatUtils.calculate_star_scaled_value(1.0, next_star) - 1.0) * 100.0
	return "HP: %d → %d   DMG Bonus: +%d%% → +%d%%" % [
		int(round(current_hp)), int(round(next_hp)), int(round(current_dmg_pct)), int(round(next_dmg_pct))
	]

func _star_string(star: int) -> String:
	return "★".repeat(star) + "☆".repeat(Constants.TOWER_MAX_STARS - star)

func _on_select_pressed(tower_id: String) -> void:
	MetaManager.selected_tower_id = tower_id
	_refresh()

func _on_upgrade_pressed(tower_id: String) -> void:
	if MetaManager.upgrade_tower_star(tower_id):
		AudioManager.play_sfx("sfx_upgrade_confirm")
	_refresh()
