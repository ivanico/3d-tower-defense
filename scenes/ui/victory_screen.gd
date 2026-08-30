extends CanvasLayer

@onready var waves_label: Label = $StatsPanel/WavesLabel
@onready var kills_label: Label = $StatsPanel/KillsLabel
@onready var time_label: Label = $StatsPanel/TimeLabel
@onready var materials_label: Label = $StatsPanel/MaterialsRow/MaterialsLabel
@onready var continue_button: Button = $ContinueButton

func _ready() -> void:
	waves_label.text = "Waves Cleared: %d" % GameState.waves_cleared
	kills_label.text = "Kills: %d" % GameState.run_kills
	time_label.text = "Time: %s" % _format_time(GameState.get_run_time_sec())
	var amount := CombatUtils.calculate_material_reward_amount(GameState.waves_cleared)
	var fought_schools := CombatUtils.get_fought_schools(GameState.active_spells)
	materials_label.text = "Earned: %s" % CombatUtils.format_material_reward_summary(amount, fought_schools)
	continue_button.pressed.connect(_on_continue_pressed)

func _format_time(seconds: float) -> String:
	var total := int(seconds)
	return "%d:%02d" % [total / 60, total % 60]

func _on_continue_pressed() -> void:
	var amount := CombatUtils.calculate_material_reward_amount(GameState.waves_cleared)
	var fought_schools := CombatUtils.get_fought_schools(GameState.active_spells)
	CombatUtils.commit_material_reward(amount, fought_schools)
	GameState.reset()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/world_map.tscn")
