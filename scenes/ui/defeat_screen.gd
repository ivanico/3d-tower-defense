extends CanvasLayer

@onready var wave_label: Label = $StatsPanel/WaveLabel
@onready var materials_label: Label = $StatsPanel/MaterialsLabel
@onready var retry_button: Button = $RetryButton
@onready var map_button: Button = $MapButton

func _ready() -> void:
	wave_label.text = "Wave Reached: %d" % GameState.wave_number
	materials_label.text = "Materials Earned: %d" % CombatUtils.calculate_run_materials(GameState.waves_cleared)
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
	var reward: int = CombatUtils.calculate_run_materials(GameState.waves_cleared)
	if reward > 0:
		MetaManager.award_materials(reward)
