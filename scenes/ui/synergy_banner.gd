extends CanvasLayer

const COLORS := {
	0: Color(1.00, 0.40, 0.10),  # OFFENSE — orange
	1: Color(0.20, 0.60, 1.00),  # ARMOR   — blue
	2: Color(0.20, 0.85, 0.30),  # UTILITY — green
}

const TEXTS := {
	0: {1: "Offense x3  —  Damage +10%",    2: "Offense x5  —  Bonus Shot!"},
	1: {1: "Armor x3  —  Dmg Reduction +15%", 2: "Armor x5  —  HP Regen Active"},
	2: {1: "Utility x3  —  Fire Rate +10%",  2: ""},
}

@onready var panel: PanelContainer = $Panel
@onready var label: Label          = $Panel/MarginContainer/Label

var _queue: Array = []
var _showing: bool = false

func _ready() -> void:
	panel.modulate.a = 0.0
	EventBus.synergy_threshold_reached.connect(_on_synergy_reached)

func _on_synergy_reached(tag: int, level: int) -> void:
	_queue.append({tag = tag, level = level})
	if not _showing:
		_show_next()

func _show_next() -> void:
	if _queue.is_empty():
		_showing = false
		return
	_showing = true
	var entry: Dictionary = _queue.pop_front()
	var tag: int = entry.tag
	var level: int = entry.level
	label.text = TEXTS.get(tag, {}).get(level, "Synergy!")
	label.add_theme_color_override("font_color", COLORS.get(tag, Color.WHITE))
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.15)
	tween.tween_interval(1.8)
	tween.tween_property(panel, "modulate:a", 0.0, 0.3)
	tween.finished.connect(_show_next)
