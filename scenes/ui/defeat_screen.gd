extends CanvasLayer

@onready var wave_label: Label = $StatsPanel/WaveLabel
@onready var materials_label: Label = $StatsPanel/MaterialsRow/MaterialsLabel
@onready var retry_button: Button = $RetryButton
@onready var map_button: Button = $MapButton

# Rolled once in _ready() and reused when actually granting the reward — see
# the same note in victory_screen.gd / CombatUtils.roll_material_reward.
var _reward: Dictionary = {}

func _ready() -> void:
	wave_label.text = "Wave Reached: %d" % GameState.wave_number
	var fought_schools := CombatUtils.get_fought_schools(GameState.active_spells)
	_reward = CombatUtils.roll_material_reward(GameState.waves_cleared, fought_schools)
	materials_label.text = "Earned: %s" % CombatUtils.format_material_reward_summary(_reward)
	retry_button.pressed.connect(_on_retry_pressed)
	map_button.pressed.connect(_on_map_pressed)

func _on_retry_pressed() -> void:
	CombatUtils.commit_material_reward(_reward)
	GameState.reset()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_map_pressed() -> void:
	CombatUtils.commit_material_reward(_reward)
	GameState.reset()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/world_map.tscn")
