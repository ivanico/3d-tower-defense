extends CanvasLayer

## In-run HUD: pause button, wave name, level readout and the XP bar.
##
## The tower's health is NOT here any more — it is the floating bar over the tower
## (scenes/ui/widget/health_bar_3d/), which connects to GameState.hp_changed itself.

@onready var wave_label: Label = $WaveLabel
@onready var level_label: Label = $LevelLabel
@onready var xp_bar: TextureProgressBar = $XPBar
@onready var pause_button: Button = $PauseButton

var _xp_tween: Tween

func _ready() -> void:
	GameState.xp_bar_updated.connect(_on_xp_updated)
	EventBus.wave_started.connect(_on_wave_started)
	EventBus.phase_changed.connect(_on_phase_changed)
	pause_button.pressed.connect(_on_pause_pressed)
	_on_xp_updated(GameState.run_xp, GameState.run_xp_to_next, GameState.run_level)
	wave_label.text = "Wave %d" % GameState.wave_number
	_on_phase_changed(GameState.phase)

func _on_xp_updated(current: int, to_next: int, level: int) -> void:
	if _xp_tween:
		_xp_tween.kill()
	_xp_tween = create_tween()
	_xp_tween.tween_property(xp_bar, "value", float(current) / float(to_next) * 100.0, 0.1)
	level_label.text = "Lv.%d" % level

func _on_wave_started(wave_number: int) -> void:
	wave_label.text = "Wave %d" % wave_number

## Pausing is only the player's to give while a wave is running. The draft, victory
## and defeat each drive get_tree().paused themselves (game_world.gd), so a button
## that could toggle it during those would fight them and strand the game paused.
func _on_phase_changed(phase: int) -> void:
	pause_button.visible = phase == Constants.GamePhase.WAVE

func _on_pause_pressed() -> void:
	if GameState.phase != Constants.GamePhase.WAVE:
		return
	get_tree().paused = not get_tree().paused
