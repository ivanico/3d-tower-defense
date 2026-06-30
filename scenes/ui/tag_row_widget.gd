extends HBoxContainer

const TAG_NAMES   := ["OFF", "ARM", "UTL"]
const TAG_COLORS  := [
	Color(1.00, 0.40, 0.10),  # OFFENSE
	Color(0.20, 0.60, 1.00),  # ARMOR
	Color(0.20, 0.85, 0.30),  # UTILITY
]
const COLOR_INACTIVE := Color(0.35, 0.35, 0.35)

@onready var _panels: Array = [$OffensePanel, $ArmorPanel, $UtilityPanel]
@onready var _labels: Array = [$OffensePanel/Label, $ArmorPanel/Label, $UtilityPanel/Label]

func _ready() -> void:
	EventBus.card_selected.connect(func(_c): _refresh())
	_refresh()

func _refresh() -> void:
	for i in 3:
		var count: int = GameState.tag_counts.get(i, 0)
		var tier: int  = 2 if count >= Constants.SYNERGY_THRESHOLD_HIGH else (1 if count >= Constants.SYNERGY_THRESHOLD_LOW else 0)
		var suffix     := " ★" if tier == 2 else (" +" if tier == 1 else "")
		_labels[i].text = "%s %d%s" % [TAG_NAMES[i], count, suffix]
		var col: Color  = TAG_COLORS[i] if tier > 0 else COLOR_INACTIVE
		_panels[i].self_modulate = col
