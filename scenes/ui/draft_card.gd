extends PanelContainer
class_name DraftCard

signal card_selected(card_data: Resource)

const RARITY_COLORS := {
	0: Color(0.55, 0.55, 0.55),  # COMMON — gray
	1: Color(0.20, 0.50, 1.00),  # RARE   — blue
	2: Color(0.65, 0.15, 1.00),  # EPIC   — purple
}

# Flat white texture reused by every card's icon slot until real icon art
# exists — modulated to the spell's school color (spells.md Task S-06).
static var _flat_icon_tex: GradientTexture2D = null

@onready var rarity_border: ColorRect = $VBoxContainer/RarityBorder
@onready var icon_rect: TextureRect   = $VBoxContainer/IconRect
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
	_setup_icon(card_data)

func _setup_icon(card_data: Resource) -> void:
	var icon = card_data.get("icon")
	var dtype = card_data.get("damage_type")
	if icon != null:
		# Real icon art wins as soon as a .tres provides it.
		icon_rect.texture = icon
		icon_rect.modulate = Color.WHITE
	else:
		icon_rect.texture = _get_flat_icon()
		# School-colored block: Fire/Frost/Void/Poison/Nature tellable at a
		# glance. Stat upgrades (no damage_type) get a neutral gray.
		icon_rect.modulate = CombatUtils.get_damage_color(dtype) if dtype != null else Color(0.75, 0.75, 0.75)
	# Spell names also carry the school color; upgrades keep default styling.
	if dtype != null:
		name_label.add_theme_color_override("font_color", CombatUtils.get_damage_color(dtype))
	else:
		name_label.remove_theme_color_override("font_color")

static func _get_flat_icon() -> GradientTexture2D:
	if _flat_icon_tex == null:
		var gradient := Gradient.new()
		gradient.colors = PackedColorArray([Color.WHITE])
		gradient.offsets = PackedFloat32Array([0.0])
		_flat_icon_tex = GradientTexture2D.new()
		_flat_icon_tex.gradient = gradient
		_flat_icon_tex.width = 64
		_flat_icon_tex.height = 64
	return _flat_icon_tex

func _on_select_pressed() -> void:
	select_button.disabled = true
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.07)
	tween.tween_property(self, "scale", Vector2.ONE, 0.07)
	tween.finished.connect(func(): card_selected.emit(_card_data))
