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


func _apply_content() -> void:
	var label: Label = get_node_or_null("Pill/AmountLabel")
	if label == null:
		return
	label.add_theme_font_size_override("font_size", font_size)
	label.text = str(amount)
