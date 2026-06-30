extends CanvasLayer

@onready var wave_label: Label = $WaveLabel
@onready var hp_label: Label = $HPLabel
@onready var hp_bar: ProgressBar = $HPBar
@onready var level_label: Label = $LevelLabel
@onready var xp_bar: ProgressBar = $XPBar

var _hp_tween: Tween
var _xp_tween: Tween

func _ready() -> void:
	GameState.hp_changed.connect(_on_hp_changed)
	GameState.xp_bar_updated.connect(_on_xp_updated)
	EventBus.wave_started.connect(_on_wave_started)
	_on_hp_changed(GameState.tower_hp, GameState.tower_max_hp)
	_on_xp_updated(GameState.run_xp, GameState.run_xp_to_next, GameState.run_level)
	wave_label.text = "Wave %d" % GameState.wave_number

func _on_hp_changed(current: float, max_hp: float) -> void:
	if max_hp <= 0.0:
		return
	if _hp_tween:
		_hp_tween.kill()
	_hp_tween = create_tween()
	_hp_tween.tween_property(hp_bar, "value", current / max_hp * 100.0, 0.15)
	hp_label.text = "%d / %d" % [int(current), int(max_hp)]

func _on_xp_updated(current: int, to_next: int, level: int) -> void:
	if _xp_tween:
		_xp_tween.kill()
	_xp_tween = create_tween()
	_xp_tween.tween_property(xp_bar, "value", float(current) / float(to_next) * 100.0, 0.1)
	level_label.text = "Lv %d" % level

func _on_wave_started(wave_number: int) -> void:
	wave_label.text = "Wave %d" % wave_number
