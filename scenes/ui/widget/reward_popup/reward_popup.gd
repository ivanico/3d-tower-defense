@tool
extends Control

## THE reward reveal (10-04 step 6, planned in 10-05): a title and a row of
## `icon ×amount` entries that pop in one after another. One scene for every
## reward — store purchases now; chests (10-05), daily rewards (10-06) and
## optionally the victory screen later. Don't build another.
##
## Opened as popup content through the 10-01 host:
##   var popup = host.open(REWARD_POPUP_SCENE)
##   popup.show_rewards(rewards)
## Archero-style: no X, a tap anywhere (dim or panel) closes it.
##
## A reward is a Dictionary: {"icon": Texture2D, "amount": int,
## "hue_shift": float (optional, placeholder recolour), "name": String
## (optional, shown instead of an icon when there is none)}.
## `rewards_for_store_item()` builds the list for a store purchase.
##
## Preview: `preview_rewards` holds sample rewards, shown in the editor.

signal close_requested

const HueShift := preload("res://scenes/ui/widget/hue_shift.gd")
## Placeholder icons until the real ones exist (see ui_assets.md): gems = the
## materials gem hue-shifted pink (same as the top bar), revives have no icon
## yet (the entry shows its name).
const GEM_ICON := preload("res://assets/ui/topbar/icon_currency_materials1.png")
const GEM_ICON_HUE_SHIFT := 0.28
const ENERGY_ICON := preload("res://assets/ui/topbar/icon_currency_energy1.png")
const BASE_MATERIAL_ICON := preload("res://assets/ui/topbar/icon_currency_materials1.png")
## Chest id → icon. 10-05's ChestDefinition (closed/open icons) replaces this.
const CHEST_ICONS := {
	"chest_cheap": preload("res://assets/ui/rewards/icon_chest_common.png"),
	"chest_better": preload("res://assets/ui/rewards/icon_chest_rare.png"),
}

## Popup options read by overlay_screen.gd: no X, tap outside closes.
var overlay_show_close: bool = false
var overlay_tap_outside_closes: bool = true

@export var title: String = "You got":
	set(value):
		title = value
		if is_node_ready():
			title_label.text = value
## Sample rewards for the editor preview.
@export var preview_rewards: Array[Dictionary] = []:
	set(value):
		preview_rewards = value
		if Engine.is_editor_hint() and is_node_ready():
			show_rewards(preview_rewards, false)

## Size of each reward icon, in pixels.
@export var icon_size: int = 140
## Seconds between one entry popping in and the next.
@export var entry_stagger: float = 0.08
@export var entry_pop_time: float = 0.2

@onready var title_label: Label = $TitleLabel
@onready var entries: HBoxContainer = $Entries


func _ready() -> void:
	title_label.text = title
	if Engine.is_editor_hint():
		show_rewards(preview_rewards, false)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT \
			and not event.pressed:
		close_requested.emit()


## Replaces the entries with `rewards`. `animate` pops them in one by one.
func show_rewards(rewards: Array, animate: bool = true) -> void:
	for child in entries.get_children():
		entries.remove_child(child)
		child.queue_free()
	var delay := 0.0
	for reward in rewards:
		var entry := _make_entry(reward)
		entries.add_child(entry)
		if animate:
			_pop_in(entry, delay)
			delay += entry_stagger


## The rewards a store purchase gave, in display order. `granted` is
## StoreService's report (`purchase_completed`'s third argument).
static func rewards_for_store_item(granted: Dictionary) -> Array:
	var list: Array = []
	if granted.get("gems", 0) > 0:
		list.append({"icon": GEM_ICON, "amount": granted.gems, "hue_shift": GEM_ICON_HUE_SHIFT})
	if granted.get("energy", 0) > 0:
		list.append({"icon": ENERGY_ICON, "amount": granted.energy})
	if granted.get("base_material", 0) > 0:
		list.append({"icon": BASE_MATERIAL_ICON, "amount": granted.base_material})
	if granted.get("revives", 0) > 0:
		list.append({"name": "Revive", "amount": granted.revives})
	for chest_id in granted.get("chests", {}):
		list.append({"icon": CHEST_ICONS.get(chest_id), "name": chest_id.capitalize(),
				"amount": granted.chests[chest_id]})
	return list


func _make_entry(reward: Dictionary) -> Control:
	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	var icon: Texture2D = reward.get("icon")
	if icon != null:
		var rect := TextureRect.new()
		rect.texture = icon
		rect.custom_minimum_size = Vector2(icon_size, icon_size)
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		HueShift.apply(rect, reward.get("hue_shift", 0.0))
		box.add_child(rect)
	else:
		# Placeholder for a reward with no art yet: its name in the icon's place.
		var name_label := _label(reward.get("name", "?"), 34)
		name_label.custom_minimum_size = Vector2(icon_size, icon_size)
		name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		box.add_child(name_label)
	box.add_child(_label("×%d" % int(reward.get("amount", 0)), 40))
	return box


func _label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _pop_in(entry: Control, delay: float) -> void:
	entry.modulate.a = 0.0
	entry.scale = Vector2.ONE * 0.5
	# Containers place children after this frame; pivot on the final size then.
	entry.resized.connect(func(): entry.pivot_offset = entry.size * 0.5, CONNECT_ONE_SHOT)
	var tween := create_tween().set_parallel()
	tween.tween_property(entry, "modulate:a", 1.0, entry_pop_time).set_delay(delay)
	tween.tween_property(entry, "scale", Vector2.ONE, entry_pop_time).set_delay(delay) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
