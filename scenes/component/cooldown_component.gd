class_name CooldownComponent
extends Node

@export var duration: float = 1.0

var _timer: Timer

func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = duration
	_timer.one_shot = true
	add_child(_timer)

func is_ready() -> bool:
	return _timer.is_stopped()

func consume() -> void:
	_timer.wait_time = duration
	_timer.start()
