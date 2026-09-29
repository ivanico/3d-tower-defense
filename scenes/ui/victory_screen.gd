extends CanvasLayer

@onready var waves_label: Label = $StatsPanel/WavesLabel
@onready var kills_label: Label = $StatsPanel/KillsLabel
@onready var time_label: Label = $StatsPanel/TimeLabel
@onready var materials_label: Label = $StatsPanel/MaterialsRow/MaterialsLabel
@onready var continue_button: Button = $ContinueButton
@onready var unlock_label: Label = $StatsPanel/UnlockLabel

## Set by game_world before this is added: towers this victory unlocked for the
## FIRST time (09-05). Empty on a replay, so the line only shows once. The
## scene's placeholder text is what the editor preview shows.
var unlocked_tower_ids: Array[String] = []

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
	_show_unlocks()

func _show_unlocks() -> void:
	var lines: PackedStringArray = []
	for tower_id in unlocked_tower_ids:
		var tower = TowerRegistry.get_by_id(tower_id)
		if tower != null:
			lines.append("New tower unlocked: %s!" % tower.tower_name)
	unlock_label.text = "
".join(lines)
	unlock_label.visible = not lines.is_empty()

func _format_time(seconds: float) -> String:
	var total := int(seconds)
	return "%d:%02d" % [total / 60, total % 60]

func _on_continue_pressed() -> void:
	CombatUtils.commit_material_reward(_reward)
	GameState.reset()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/world_map.tscn")
