@tool
class_name CurrencyPill
extends "res://scenes/ui/widget/pill_base.gd"

## One top-bar currency readout: a dark pill holding the amount, with the currency
## icon sitting ON the pill's left end and overhanging it above and below.
##
## The pill shape, the icon slot and every geometry knob live in `pill_base.gd`,
## shared with the garage's `stat_pill`. All this adds is the number.
##
## The amount is centred across the WHOLE pill, icon overhang included, so a
## 1-digit and a 4-digit value both sit sensibly. (A `text_gap` knob used to be
## exported here; it set `margin_left`/`margin_right` theme constants, which a
## PanelContainer does not read, so it had never done anything and is gone.)

## Size of the amount text.
@export var font_size: int = 40:
	set(value):
		font_size = maxi(value, 1)
		_apply()

## The number shown. Screens normally drive this through `set_amount()`.
@export var amount: int = 0:
	set(value):
		amount = value
		_apply()


func set_amount(value: int) -> void:
	amount = value


## Space kept clear at each end of the pill. The text is centred, so a number
## wider than `pill_size.x - 2 * TEXT_SIDE_MARGIN` would run under the icon on
## the left (a 7-digit amount lost its first digit there). Up to 4 digits at the
## default 40 px keep their full size; longer amounts shrink to fit.
const TEXT_SIDE_MARGIN := 42


func _apply_content() -> void:
	var label: Label = get_node_or_null("Pill/AmountLabel")
	if label == null:
		return
	label.text = str(amount)
	label.add_theme_font_size_override("font_size", _fitting_font_size(label))


## `font_size`, shrunk just enough for a long amount to fit between the margins.
func _fitting_font_size(label: Label) -> int:
	var max_width: float = pill_size.x - 2 * TEXT_SIDE_MARGIN
	var width: float = label.get_theme_font("font").get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	if width <= max_width:
		return font_size
	return maxi(int(font_size * max_width / width), 1)
