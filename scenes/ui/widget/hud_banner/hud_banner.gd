extends CanvasLayer

## Shared HUD banner: fade in, hold, fade out, queued so banners never
## overlap. Subclasses (synergy_banner.gd, boss_banner.gd) only decide WHAT
## to show and call show_banner(). Expects $Panel and $Panel/MarginContainer/Label.

@export var hold_sec: float = 1.8
@export var fade_in_sec: float = 0.15
@export var fade_out_sec: float = 0.3

@onready var panel: Control = $Panel
@onready var label: Label   = $Panel/MarginContainer/Label

var _queue: Array = []
var _showing: bool = false

func _ready() -> void:
	panel.modulate.a = 0.0

func show_banner(text: String, color: Color = Color.WHITE) -> void:
	_queue.append({text = text, color = color})
	if not _showing:
		_show_next()

func _show_next() -> void:
	if _queue.is_empty():
		_showing = false
		return
	_showing = true
	var entry: Dictionary = _queue.pop_front()
	label.text = entry.text
	label.add_theme_color_override("font_color", entry.color)
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, fade_in_sec)
	tween.tween_interval(hold_sec)
	tween.tween_property(panel, "modulate:a", 0.0, fade_out_sec)
	tween.finished.connect(_show_next)
