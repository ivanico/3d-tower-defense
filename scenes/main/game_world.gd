extends Node3D

const VICTORY_SCREEN_SCENE := preload("res://scenes/ui/victory_screen.tscn")
const DEFEAT_SCREEN_SCENE := preload("res://scenes/ui/defeat_screen.tscn")

@onready var wave_manager: WaveManager = $WaveManager
@onready var draft_manager: DraftManager = $DraftManager

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$EnemyContainer.process_mode = Node.PROCESS_MODE_PAUSABLE
	$ProjectileContainer.process_mode = Node.PROCESS_MODE_PAUSABLE
	$Tower.process_mode = Node.PROCESS_MODE_PAUSABLE
	if GameState.pending_chapter_def != null:
		wave_manager.chapter = GameState.pending_chapter_def
	wave_manager._enemy_container = $EnemyContainer
	wave_manager.start_wave(1)
	EventBus.wave_cleared.connect(_on_wave_cleared)
	EventBus.tower_died.connect(_on_tower_died)
	EventBus.phase_changed.connect(_on_phase_changed)
	EventBus.boss_died.connect(_on_boss_died)

func _unhandled_input(event: InputEvent) -> void:
	if get_tree().paused and event.is_action_pressed("ui_accept"):
		get_tree().paused = false
		GameState.reset()
		get_tree().reload_current_scene()
	elif GameState.phase == Constants.GamePhase.DRAFT and event.is_action_pressed("ui_accept"):
		if not draft_manager._draft_cards.is_empty():
			draft_manager.select_card(draft_manager._draft_cards[0])

func _on_wave_cleared(wave_number: int) -> void:
	GameState.waves_cleared += 1
	GameState.wave_number += 1
	draft_manager.open_draft("wave_clear")

func _on_boss_died() -> void:
	GameState.waves_cleared += 1
	wave_manager.stop_wave()
	GameState.end_run(true)
	add_child(VICTORY_SCREEN_SCENE.instantiate())
	get_tree().paused = true

func _on_phase_changed(phase: int) -> void:
	if phase == Constants.GamePhase.DRAFT:
		get_tree().paused = true
	elif phase == Constants.GamePhase.WAVE:
		get_tree().paused = false

func _on_tower_died() -> void:
	wave_manager.clear_all_enemies()
	add_child(DEFEAT_SCREEN_SCENE.instantiate())
	get_tree().paused = true
