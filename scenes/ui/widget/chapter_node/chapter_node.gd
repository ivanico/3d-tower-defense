extends Button

@export var chapter_image: Texture2D
@export var chapter_title: String = ""
@export var locked: bool = false

@onready var image_rect: TextureRect = $Image
@onready var name_label: Label = $PlayBar/NameLabel
@onready var locked_overlay: TextureRect = $LockedOverlay


func _ready() -> void:
	if chapter_image != null:
		image_rect.texture = chapter_image
	name_label.text = chapter_title
	locked_overlay.visible = locked
	disabled = locked
