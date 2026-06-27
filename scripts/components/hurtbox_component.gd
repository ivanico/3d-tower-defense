class_name HurtboxComponent
extends Area3D

@export var armor_type: int = Constants.ArmorType.UNARMORED

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(_area: Area3D) -> void:
	pass # Full wiring in Epic 02
