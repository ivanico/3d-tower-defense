extends Control

## The one way to open a popup over the home shell (10-01). Chests, Daily,
## Settings and the reward popup all go through `open()` / `close()`, so the dim,
## pop-in, X, tap-outside and back-button handling exist once.
##
## Lives on `OverlayLayer` in world_map.tscn: after the NavBar (so the dim covers
## it, Archero-style) and before the LoadingScreen. Popups STACK: a reward popup
## opened over Chests closes back to Chests. Find this node with
## `get_tree().get_first_node_in_group(GROUP)`.
##
## Escape / Android back close the top popup. Until 10-08 turns off
## `quit_on_go_back`, a real Android back press still quits the app.
##
## Note: chapter_select sits on its own CanvasLayer, which draws above this
## layer. Nothing opens a popup while it is showing.

signal overlay_opened(content: Control)
## Emitted after a popup's close animation has finished.
signal overlay_closed

const GROUP := "overlay_host"
const OVERLAY_SCENE := preload("res://scenes/ui/widget/overlay_screen/overlay_screen.tscn")


func _ready() -> void:
	add_to_group(GROUP)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Opens `scene` in a new popup on top of any already open, refreshes it the
## same way the shell refreshes its tab screens, and returns the content node.
func open(scene: PackedScene) -> Control:
	var overlay: Control = OVERLAY_SCENE.instantiate()
	add_child(overlay)
	var content: Control = scene.instantiate()
	overlay.set_content(content)
	overlay.close_requested.connect(_close_overlay.bind(overlay))
	overlay.closed.connect(_on_overlay_closed)
	if content.has_method("_refresh"):
		content._refresh()
	overlay.play_open()
	overlay_opened.emit(content)
	return content


## Closes the top popup. Does nothing when none is open.
func close() -> void:
	var top := _top()
	if top != null:
		_close_overlay(top)


func is_open() -> bool:
	return _top() != null


## The topmost popup's content, or null.
func top_content() -> Control:
	var top := _top()
	return top.get_content() if top != null else null


func _close_overlay(overlay: Control) -> void:
	overlay.play_close()


func _on_overlay_closed() -> void:
	# The popup underneath may show something the closed one changed.
	var under := top_content()
	if under != null and under.has_method("_refresh"):
		under._refresh()
	overlay_closed.emit()


## Last child that isn't already animating out, so a second back press closes
## the next popup instead of being swallowed.
func _top() -> Control:
	for i in range(get_child_count() - 1, -1, -1):
		var overlay: Control = get_child(i)
		if not overlay.is_closing():
			return overlay
	return null


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and is_open():
		close()
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and is_open():
		close()
