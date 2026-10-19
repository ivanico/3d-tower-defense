@tool
extends Control

## One store tile (10-04): ribbon, icon, name, what it contains, and a buy
## button showing the price — gems through the shared `cost_chip`, Archero's USD
## text for real money, "Watch ad" or "Free". A note line under the button says
## why it can't be bought ("Coming soon", "Bought", "29 days left").
##
## The card only draws. The store screen asks StoreService for the price and the
## block reason and passes them to `show_item()`; a tap emits `buy_pressed`.
##
## Preview: set `preview_item` to any `resources/store/*.tres` (one per price
## type is enough to see every look), plus the `preview_*` state knobs.

signal buy_pressed(item: Resource)

# The Constants script, not the autoload: this is a @tool script and autoloads
# are only placeholders in the editor (same as tower_preview_3d).
const ConstantsScript := preload("res://autoloads/constants.gd")
const HueShift := preload("res://scenes/ui/widget/hue_shift.gd")
## Gem price icon. Same placeholder as the top bar's GemsPill (the materials gem
## hue-shifted pink) until `topbar/icon_currency_gems.png` exists — swap both.
const GEM_ICON := preload("res://assets/ui/topbar/icon_currency_materials1.png")
const GEM_ICON_HUE_SHIFT := 0.28

## Sample item shown in the editor. Runtime cards are filled by show_item().
@export var preview_item: Resource:
	set(value):
		preview_item = value
		_apply_preview()
## Preview the "can't afford" red price.
@export var preview_unaffordable: bool = false:
	set(value):
		preview_unaffordable = value
		_apply_preview()
## Preview a blocked card: this text goes in the note line and the button greys
## out. Empty = buyable.
@export var preview_note: String = "":
	set(value):
		preview_note = value
		_apply_preview()

var item: Resource

@onready var icon_rect: TextureRect = $Content/Icon
@onready var name_label: Label = $Content/NameLabel
@onready var contents_label: Label = $Content/ContentsLabel
@onready var buy_button: Button = $Content/BuyButton
@onready var gem_chip: HBoxContainer = $Content/BuyButton/GemChip
@onready var note_label: Label = $Content/NoteLabel
@onready var ribbon: Label = $Ribbon


func _ready() -> void:
	HueShift.apply(gem_chip.get_node("Icon"), GEM_ICON_HUE_SHIFT)
	if not Engine.is_editor_hint():
		buy_button.pressed.connect(func(): buy_pressed.emit(item))
	_apply_preview()


## Fills the card. `gem_price` is only used by gem items (it includes the
## repeat-buy discount). `note` non-empty = blocked: shown under the button, and
## the button is disabled.
func show_item(new_item: Resource, gem_price: int, affordable: bool, note: String) -> void:
	item = new_item
	if not is_node_ready() or item == null:
		return
	icon_rect.texture = item.icon
	HueShift.apply(icon_rect, item.icon_hue_shift)
	name_label.text = item.display_name
	contents_label.text = contents_text(item)
	ribbon.text = item.ribbon_text
	ribbon.visible = not item.ribbon_text.is_empty()

	var is_gems: bool = item.price_type == ConstantsScript.StorePriceType.GEMS
	gem_chip.visible = is_gems
	if is_gems:
		gem_chip.set_cost(gem_price, GEM_ICON, affordable)
		buy_button.text = ""
	else:
		buy_button.text = _price_text(item)
	note_label.text = note
	note_label.visible = not note.is_empty()
	buy_button.disabled = not note.is_empty()


## What the item gives, in one short line ("300 Gems · 1000 Base Material ·
## 5 Revives"). Static so anything can describe an item the same way.
static func contents_text(it: Resource) -> String:
	var parts: PackedStringArray = []
	if it.card_days > 0:
		parts.append("%d Gems now" % it.gems)
		parts.append("%d Gems a day for %d days" % [it.daily_gems, it.card_days])
	elif it.gems > 0:
		parts.append("%d Gems" % it.gems)
	if it.energy > 0:
		parts.append("+%d Energy" % it.energy)
	if it.base_material > 0:
		parts.append("%d Base Material" % it.base_material)
	if it.revives > 0:
		parts.append("%d Revives" % it.revives)
	if it.chest_count > 0 and not it.open_on_buy:
		parts.append("%d× %s" % [it.chest_count, it.chest_id.replace("_", " ").capitalize()])
	if it.open_on_buy:
		parts.append("Materials, maybe a new tower")
	return " · ".join(parts)


static func _price_text(it: Resource) -> String:
	match it.price_type:
		ConstantsScript.StorePriceType.REAL_MONEY:
			return it.price_label
		ConstantsScript.StorePriceType.AD:
			return "Watch ad"
		ConstantsScript.StorePriceType.FREE:
			return "Free"
	return ""


func _apply_preview() -> void:
	if not Engine.is_editor_hint() or not is_node_ready() or preview_item == null:
		return
	var price: int = preview_item.gem_prices[0] if not preview_item.gem_prices.is_empty() else 0
	show_item(preview_item, price, not preview_unaffordable, preview_note)
