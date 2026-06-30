extends PanelContainer
class_name DraftCard

signal card_selected(card_data: Resource)

const RARITY_COLORS := {
	0: Color(0.55, 0.55, 0.55),  # COMMON — gray
	1: Color(0.20, 0.50, 1.00),  # RARE   — blue
	2: Color(0.65, 0.15, 1.00),  # EPIC   — purple
}

@onready var rarity_border: ColorRect = $VBoxContainer/RarityBorder
@onready var name_label: Label        = $VBoxContainer/NameLabel
@onready var desc_label: Label        = $VBoxContainer/DescLabel
@onready var select_button: Button    = $VBoxContainer/SelectButton

var _card_data: Resource

func _ready() -> void:
	select_button.pressed.connect(_on_select_pressed)

func setup(card_data: Resource) -> void:
	_card_data = card_data
	var n = card_data.get("spell_name")
	if n == null:
		n = card_data.get("upgrade_name")
	name_label.text = str(n) if n != null else "?"
	var desc = card_data.get("description")
	desc_label.text = str(desc) if desc != null else ""
	var rarity = card_data.get("rarity")
	rarity_border.color = RARITY_COLORS.get(rarity if rarity != null else 0, RARITY_COLORS[0])

func _on_select_pressed() -> void:
	select_button.disabled = true
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.07)
	tween.tween_property(self, "scale", Vector2.ONE, 0.07)
	tween.finished.connect(func(): card_selected.emit(_card_data))
