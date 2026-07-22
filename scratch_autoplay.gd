extends SceneTree

var _game_world: Node = null
var _draft_manager: Node = null
var _game_state: Node = null
const MAX_FRAMES := 36000  # ~600 sim-seconds at 60fps

func _initialize() -> void:
	_game_state = root.get_node("GameState")
	var scene: PackedScene = load("res://scenes/main/game_world.tscn")
	_game_world = scene.instantiate()
	root.add_child(_game_world)
	call_deferred("_drive")

func _drive() -> void:
	await process_frame
	_draft_manager = get_first_node_in_group("draft_manager")
	var frame := 0
	while frame < MAX_FRAMES:
		await process_frame
		frame += 1
		if _draft_manager != null and not _draft_manager._draft_cards.is_empty():
			var card = _draft_manager._draft_cards[0]
			print("DEBUGTEST AUTOPLAY selecting card wave=", _game_state.wave_number, " level=", _game_state.run_level, " frame=", frame)
			_draft_manager.select_card(card)
	print("DEBUGTEST AUTOPLAY done, final wave=", _game_state.wave_number, " frames=", frame)
	quit()
