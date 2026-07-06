extends CanvasLayer

@onready var wave_label: Label = $StatsPanel/WaveLabel
@onready var retry_button: Button = $RetryButton
@onready var map_button: Button = $MapButton

func _ready() -> void:
	wave_label.text = "Wave Reached: %d" % GameState.wave_number
	retry_button.pressed.connect(_on_retry_pressed)
	map_button.pressed.connect(_on_retry_pressed)

func _on_retry_pressed() -> void:
	GameState.reset()
	get_tree().paused = false
	get_tree().reload_current_scene()
