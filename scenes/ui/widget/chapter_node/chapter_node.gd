@tool
extends Control

## The chapter artwork on the world map. Display only — starting a run is the
## screen-level `play_button`, matching the reference layout where the art is a
## picture and the Play button is the control.
##
## The decorative frame and the play bar that used to live here are gone; the
## chapter name is now the world map's title label.

@export var chapter_image: Texture2D:
	set(value):
		chapter_image = value
		_apply()

@export var locked: bool = false:
	set(value):
		locked = value
		_apply()


func _ready() -> void:
	_apply()


func _apply() -> void:
	if not is_inside_tree():
		return
	var image_rect: TextureRect = get_node_or_null("Image")
	var locked_overlay: TextureRect = get_node_or_null("LockedOverlay")
	if image_rect == null or locked_overlay == null:
		return
	if chapter_image != null:
		image_rect.texture = chapter_image
	locked_overlay.visible = locked
