extends CanvasLayer

@onready var waves_label: Label = $StatsPanel/WavesLabel
@onready var kills_label: Label = $StatsPanel/KillsLabel
@onready var time_label: Label = $StatsPanel/TimeLabel
@onready var materials_label: Label = $StatsPanel/MaterialsRow/MaterialsLabel
@onready var continue_button: Button = $ContinueButton

# Rolled once in _ready() and reused by _on_continue_pressed() — the reward
# includes chance-based rare drops, so re-rolling on Continue could grant
# something different than what the label just promised. See
# CombatUtils.roll_material_reward.
var _reward: Dictionary = {}

func _ready() -> void:
	waves_label.text = "Waves Cleared: %d" % GameState.waves_cleared
	kills_label.text = "Kills: %d" % GameState.run_kills
	time_label.text = "Time: %s" % _format_time(GameState.get_run_time_sec())
	var fought_schools := CombatUtils.get_fought_schools(GameState.active_spells)
	_reward = CombatUtils.roll_material_reward(GameState.waves_cleared, fought_schools)
	materials_label.text = "Earned: %s" % CombatUtils.format_material_reward_summary(_reward)
	continue_button.pressed.connect(_on_continue_pressed)

func _format_time(seconds: float) -> String:
	var total := int(seconds)
	return "%d:%02d" % [total / 60, total % 60]

func _on_continue_pressed() -> void:
	CombatUtils.commit_material_reward(_reward)
	GameState.reset()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/world_map.tscn")
