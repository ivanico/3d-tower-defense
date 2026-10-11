extends Control

## Store tab (10-02, 2026-10-12: the Store is a nav-bar tab, Archero-style). A
## placeholder page until 10-04 builds the real store here: background, the
## top bar, a title and "Coming soon".
##
## Content-only, like the other tab screens: it lives in `world_map.gd`'s shell,
## which owns the NavBar and calls `_refresh()` when the tab is shown.

@onready var top_bar: Control = $TopBar


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	top_bar.refresh()
