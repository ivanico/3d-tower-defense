extends PanelContainer

@export var icon: Texture2D
@export var amount: int = 0

@onready var icon_rect: TextureRect = $HBox/Icon
@onready var amount_label: Label = $HBox/AmountLabel


func _ready() -> void:
	icon_rect.texture = icon
	amount_label.text = str(amount)


func set_amount(value: int) -> void:
	amount = value
	if amount_label != null:
		amount_label.text = str(amount)
