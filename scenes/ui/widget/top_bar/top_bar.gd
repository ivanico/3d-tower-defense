@tool
extends HBoxContainer

## The currency row at the top of every meta screen: Energy · Materials · Gems.
##
## It fills its OWN numbers from MetaManager (`refresh()`), so screens call one
## method instead of each setting every pill. Gems also update live through
## `EventBus.gems_changed`, since a purchase can happen while the row is showing.
##
## Which pills show is per screen: the Garage turns `show_energy` off (10-03,
## user decision — energy only matters for Play). Look and spacing stay here.

## Show the energy pill. Off on the Garage.
@export var show_energy: bool = true:
	set(value):
		show_energy = value
		var pill := get_node_or_null("EnergyPill")
		if pill != null:
			pill.visible = value

@onready var energy_pill: Control = $EnergyPill
@onready var materials_pill: Control = $MaterialsPill
@onready var gems_pill: Control = $GemsPill


func _ready() -> void:
	energy_pill.visible = show_energy
	# Editor preview keeps the sample amounts in the scene; autoloads don't run there.
	if Engine.is_editor_hint():
		return
	EventBus.gems_changed.connect(_on_gems_changed)
	refresh()


func refresh() -> void:
	energy_pill.set_amount(MetaManager.energy)
	materials_pill.set_amount(MetaManager.base_material)
	gems_pill.set_amount(MetaManager.gems)


func _on_gems_changed(total: int) -> void:
	gems_pill.set_amount(total)
