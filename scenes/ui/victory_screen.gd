extends CanvasLayer

@onready var waves_label: Label = $StatsPanel/WavesLabel
@onready var kills_label: Label = $StatsPanel/KillsLabel
@onready var time_label: Label = $StatsPanel/TimeLabel
@onready var materials_label: Label = $StatsPanel/MaterialsLabel
@onready var continue_button: Button = $ContinueButton

func _ready() -> void:
	waves_label.text = "Waves Cleared: %d" % GameState.waves_cleared
	kills_label.text = "Kills: %d" % GameState.run_kills
	time_label.text = "Time: %s" % _format_time(GameState.get_run_time_sec())
	materials_label.text = "Materials Earned: %d" % CombatUtils.calculate_run_materials(GameState.waves_cleared)
	continue_button.pressed.connect(_on_continue_pressed)

func _format_time(seconds: float) -> String:
	var total := int(seconds)
	return "%d:%02d" % [total / 60, total % 60]

func _on_continue_pressed() -> void:
	var reward: int = CombatUtils.calculate_run_materials(GameState.waves_cleared)
	MetaManager.award_materials(reward)
	GameState.reset()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/world_map.tscn")
