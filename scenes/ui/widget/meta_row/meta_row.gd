extends PanelContainer
class_name MetaRow

## Shared upgrade row for both meta screens: the Tower Garage shows stars +
## an "In Use" toggle, the Spell Codex shows a rank label. Same scene both
## times — the parts a screen doesn't need stay hidden.

signal upgrade_pressed
signal select_pressed

@onready var icon_rect: TextureRect = $HBox/Icon
@onready var name_label: Label = $HBox/Info/NameLabel
@onready var star_row: HBoxContainer = $HBox/Info/StatusSlot/StarRow
@onready var rank_label: Label = $HBox/Info/StatusSlot/RankLabel
@onready var select_button: CheckButton = $HBox/Actions/SelectButton
@onready var stat_text_label: Label = $HBox/Info/StatsRow/StatText
@onready var upgrade_button: Button = $HBox/Actions/UpgradeButton
@onready var cost_row: HBoxContainer = $HBox/Actions/CostRow
# Typed to the base class, not the global class name `CostChip` — see the
# note in tower_garage.gd about class_name resolving only through the
# editor-built global script class cache.
@onready var base_chip: HBoxContainer = $HBox/Actions/CostRow/BaseChip
@onready var rare_chip: HBoxContainer = $HBox/Actions/CostRow/RareChip

@onready var _chips: Array[HBoxContainer] = [$HBox/Info/StatsRow/Chip1, $HBox/Info/StatsRow/Chip2]


func _ready() -> void:
	upgrade_button.pressed.connect(func(): upgrade_pressed.emit())
	select_button.pressed.connect(func(): select_pressed.emit())


func set_row_icon(texture: Texture2D) -> void:
	icon_rect.texture = texture


func set_title(text: String) -> void:
	name_label.text = text


func show_stars(count: int) -> void:
	star_row.visible = true
	rank_label.visible = false
	star_row.set_stars(count)


func show_rank(text: String) -> void:
	rank_label.visible = true
	star_row.visible = false
	rank_label.text = text


## Garage-style stats: an icon beside each value. Index 0 or 1.
func set_stat_chip(index: int, texture: Texture2D, text: String) -> void:
	if index < 0 or index >= _chips.size():
		return
	var chip := _chips[index]
	chip.visible = true
	stat_text_label.visible = false
	chip.get_node("Icon").texture = texture
	chip.get_node("Label").text = text


## Codex-style stats: one plain line, no icons.
func set_stat_text(text: String) -> void:
	stat_text_label.visible = true
	stat_text_label.text = text
	for chip in _chips:
		chip.visible = false


## Dual cost: the button itself is a plain "Upgrade" trigger (a Button can only
## show one icon), the two currencies are shown as chips above it instead —
## disabled unless BOTH are affordable.
func set_upgrade_costs(base_cost: int, base_affordable: bool, base_icon: Texture2D, rare_cost: int, rare_affordable: bool, rare_icon: Texture2D) -> void:
	cost_row.visible = true
	base_chip.set_cost(base_cost, base_icon, base_affordable)
	rare_chip.set_cost(rare_cost, rare_icon, rare_affordable)
	upgrade_button.text = "Upgrade"
	upgrade_button.disabled = not (base_affordable and rare_affordable)


func set_upgrade_maxed() -> void:
	cost_row.visible = false
	upgrade_button.text = "MAX"
	upgrade_button.disabled = true


## Garage only — the "In Use" tower toggle stays hidden everywhere else.
func show_select(is_selected: bool) -> void:
	select_button.visible = true
	select_button.button_pressed = is_selected
	select_button.disabled = is_selected
