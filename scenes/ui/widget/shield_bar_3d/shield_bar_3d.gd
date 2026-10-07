@tool
extends Node3D

## The tower's shield (09-13): a value_bar_3d (`Bar`) in shield colours above
## the tower's HP bar, plus a transparent `Bubble` around the tower
## (shield_bubble.gdshader). Both show only while a shield is up (Barkskin,
## Void Rupture star 5). Driven by EventBus.shield_changed; hidden at 0.
##
## The bar is a child instead of this script extending value_bar_3d.gd, because
## value_bar_3d wires itself to any HealthComponent it finds under its parent,
## and in game_world that would be the tower's HP. Here the parent is this node,
## which has none.
##
## Sits at the tower's position in game_world.tscn (the tower never moves).
## Tune the look on the `Bar` child of shield_bar_3d.tscn.

@onready var bar: Node3D = $Bar


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	visible = false
	EventBus.shield_changed.connect(_on_shield_changed)


func _on_shield_changed(current: float, max_value: float) -> void:
	visible = current > 0.0 and max_value > 0.0
	if visible:
		bar.set_value(current, max_value)
