extends "res://scenes/ui/widget/hud_banner/hud_banner.gd"

const COLORS := {
	0: Color(1.00, 0.40, 0.10),  # OFFENSE — orange
	1: Color(0.20, 0.60, 1.00),  # ARMOR   — blue
	2: Color(0.20, 0.85, 0.30),  # UTILITY — green
}

const TEXTS := {
	0: {1: "Offense x3  —  Damage +10%",    2: "Offense x5  —  Bonus Shot!"},
	1: {1: "Armor x3  —  Dmg Reduction +15%", 2: "Armor x5  —  HP Regen Active"},
	2: {1: "Utility x3  —  Fire Rate +10%",  2: ""},
}

func _ready() -> void:
	super()
	EventBus.synergy_threshold_reached.connect(_on_synergy_reached)

func _on_synergy_reached(tag: int, level: int) -> void:
	show_banner(TEXTS.get(tag, {}).get(level, "Synergy!"), COLORS.get(tag, Color.WHITE))
