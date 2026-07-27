extends PanelContainer
class_name DraftCard

signal card_selected(card_data: Resource)

const CARD_BG_TEXTURES := {
	0: preload("res://assets/ui/draft/ui_card_bg_common.png"),
	1: preload("res://assets/ui/draft/ui_card_bg_rare_v2.png"),
	2: preload("res://assets/ui/draft/ui_card_bg_epic_v3.png"),
}

# One shared StyleBoxTexture per rarity, built on first use.
static var _bg_styles := {}

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
	add_theme_stylebox_override("panel", _get_bg_style(rarity if rarity != null else 0))
	rarity_border.visible = false
	_setup_icon(card_data)

static func _get_bg_style(rarity: int) -> StyleBoxTexture:
	if not _bg_styles.has(rarity):
		var sb := StyleBoxTexture.new()
		sb.texture = CARD_BG_TEXTURES.get(rarity, CARD_BG_TEXTURES[0])
		sb.content_margin_left = 18.0
		sb.content_margin_top = 22.0
		sb.content_margin_right = 18.0
		sb.content_margin_bottom = 22.0
		_bg_styles[rarity] = sb
	return _bg_styles[rarity]

func _setup_icon(card_data: Resource) -> void:
	var icon := SpellRegistry.get_card_icon(card_data)
	var dtype = card_data.get("damage_type")
	if icon != null:
		# Real icon art: explicit .tres icon or the assets.md ID-convention lookup.
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
