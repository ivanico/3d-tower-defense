@tool
extends "res://scenes/ui/widget/hud_banner/hud_banner.gd"

## 09-16 boss intro: big "BOSS" text for BOSS_BANNER_HOLD_SEC when the boss
## spawns. The game keeps running (no pause). Placeholder: drawn Label →
## final art hud/ui_boss_banner.png.

const BANNER_TEXT := "BOSS"
const BANNER_COLOR := Color(1.0, 0.22, 0.18)

## Editor only: keeps the banner visible so the scene can be looked at.
@export var preview_visible: bool = true:
	set(v):
		preview_visible = v
		if is_node_ready() and Engine.is_editor_hint():
			panel.modulate.a = 1.0 if v else 0.0

func _ready() -> void:
	if Engine.is_editor_hint():
		panel.modulate.a = 1.0 if preview_visible else 0.0
		return
	super()
	hold_sec = Constants.BOSS_BANNER_HOLD_SEC
	EventBus.boss_spawned.connect(_on_boss_spawned)

func _on_boss_spawned() -> void:
	show_banner(BANNER_TEXT, BANNER_COLOR)
