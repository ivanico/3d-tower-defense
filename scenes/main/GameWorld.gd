extends Node3D

var _game_over_label: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	WaveManager._enemy_container = $EnemyContainer
	WaveManager.start_wave(1)
	EventBus.wave_cleared.connect(_on_wave_cleared)
	EventBus.tower_died.connect(_on_tower_died)
	_setup_game_over_label()

func _setup_game_over_label() -> void:
	_game_over_label = Label.new()
	_game_over_label.text = "GAME OVER\nPress Enter to restart"
	_game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_game_over_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_game_over_label.add_theme_font_size_override("font_size", 48)
	_game_over_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_game_over_label.visible = false
	$HUD.add_child(_game_over_label)

func _unhandled_input(event: InputEvent) -> void:
	if get_tree().paused and event.is_action_pressed("ui_accept"):
		get_tree().paused = false
		GameState.reset()
		get_tree().reload_current_scene()

func _on_wave_cleared(wave_number: int) -> void:
	print("[GameWorld] wave %d cleared" % wave_number)
	GameState.waves_cleared += 1
	GameState.wave_number += 1
	if wave_number >= Constants.TOTAL_WAVES:
		print("[GameWorld] BOSS TIME (stub)")
		return
	await get_tree().create_timer(1.5).timeout
	WaveManager.start_wave(GameState.wave_number)

func _on_tower_died() -> void:
	print("[GameWorld] GAME OVER — pausing tree")
	WaveManager.clear_all_enemies()
	_game_over_label.visible = true
	get_tree().paused = true
