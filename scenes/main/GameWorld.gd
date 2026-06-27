extends Node3D

@onready var hud_hp_label: Label = $HUD/HPLabel
@onready var hud_wave_label: Label = $HUD/WaveLabel

func _ready() -> void:
	WaveManager._enemy_container = $EnemyContainer
	WaveManager.start_wave(1)
	EventBus.wave_cleared.connect(_on_wave_cleared)
	EventBus.tower_died.connect(_on_tower_died)

func _process(_delta: float) -> void:
	hud_hp_label.text = "HP: %d / %d" % [GameState.tower_hp, GameState.tower_max_hp]
	hud_wave_label.text = "Wave: %d" % GameState.wave_number

func _on_wave_cleared(wave_number: int) -> void:
	print("[GameWorld] wave %d cleared" % wave_number)

func _on_tower_died() -> void:
	print("[GameWorld] GAME OVER")
