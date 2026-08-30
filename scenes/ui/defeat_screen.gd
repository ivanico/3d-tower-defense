extends CanvasLayer

@onready var wave_label: Label = $StatsPanel/WaveLabel
@onready var materials_label: Label = $StatsPanel/MaterialsRow/MaterialsLabel
@onready var retry_button: Button = $RetryButton
@onready var map_button: Button = $MapButton

func _ready() -> void:
	wave_label.text = "Wave Reached: %d" % GameState.wave_number
	var amount := CombatUtils.calculate_material_reward_amount(GameState.waves_cleared)
	var fought_schools := CombatUtils.get_fought_schools(GameState.active_spells)
	materials_label.text = "Earned: %s" % CombatUtils.format_material_reward_summary(amount, fought_schools)
	retry_button.pressed.connect(_on_retry_pressed)
	map_button.pressed.connect(_on_map_pressed)

func _on_retry_pressed() -> void:
	_award_consolation_materials()
	GameState.reset()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_map_pressed() -> void:
	_award_consolation_materials()
	GameState.reset()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/world_map.tscn")

func _award_consolation_materials() -> void:
	var amount := CombatUtils.calculate_material_reward_amount(GameState.waves_cleared)
	var fought_schools := CombatUtils.get_fought_schools(GameState.active_spells)
	CombatUtils.commit_material_reward(amount, fought_schools)
