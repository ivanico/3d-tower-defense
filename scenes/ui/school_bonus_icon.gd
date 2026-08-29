extends TextureRect

## Shows whichever school's mono-school mastery bonus is currently active
## (GameState.mono_school — see spells.md "Mono-school mastery bonus"),
## hidden otherwise. Same refresh pattern as tag_row_widget.gd: listen for
## EventBus.card_selected (any pick can change mono status) and re-check.

const ICONS := {
	Constants.DamageType.FIRE:   preload("res://assets/ui/bonuses/icon_bonus_fire.png"),
	Constants.DamageType.FROST:  preload("res://assets/ui/bonuses/icon_bonus_frost.png"),
	Constants.DamageType.VOID:   preload("res://assets/ui/bonuses/icon_bonus_shadow.png"),
	Constants.DamageType.POISON: preload("res://assets/ui/bonuses/icon_bonus_poison.png"),
	Constants.DamageType.NATURE: preload("res://assets/ui/bonuses/icon_bonus_nature.png"),
}

func _ready() -> void:
	EventBus.card_selected.connect(func(_c): _refresh())
	_refresh()

func _refresh() -> void:
	var school: int = GameState.mono_school
	visible = school != -1
	if visible:
		texture = ICONS.get(school)
