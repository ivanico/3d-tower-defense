extends Node3D

var _game_over_label: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$EnemyContainer.process_mode = Node.PROCESS_MODE_PAUSABLE
	$ProjectileContainer.process_mode = Node.PROCESS_MODE_PAUSABLE
	$Tower.process_mode = Node.PROCESS_MODE_PAUSABLE
	WaveManager._enemy_container = $EnemyContainer
	WaveManager.start_wave(1)
	EventBus.wave_cleared.connect(_on_wave_cleared)
	EventBus.tower_died.connect(_on_tower_died)
	EventBus.phase_changed.connect(_on_phase_changed)
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
	elif GameState.phase == Constants.GamePhase.DRAFT and event.is_action_pressed("ui_accept"):
		if not DraftManager._draft_cards.is_empty():
			DraftManager.select_card(DraftManager._draft_cards[0])

func _on_wave_cleared(wave_number: int) -> void:
	GameState.waves_cleared += 1
	GameState.wave_number += 1
	if wave_number >= Constants.TOTAL_WAVES:
		WaveManager.clear_all_enemies()
		_game_over_label.text = "YOU WIN!\nPress Enter to restart"
		_game_over_label.visible = true
		get_tree().paused = true
		return
	DraftManager.open_draft("wave_clear")

func _on_phase_changed(phase: int) -> void:
	if phase == Constants.GamePhase.DRAFT:
		get_tree().paused = true
	elif phase == Constants.GamePhase.WAVE:
		get_tree().paused = false

func _on_tower_died() -> void:
	WaveManager.clear_all_enemies()
	_game_over_label.visible = true
	get_tree().paused = true
