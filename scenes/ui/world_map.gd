extends Control

## Persistent hub shell for the Garage / World Map / Spell Codex loop.
##
## Holds one shared NavBar and a horizontal filmstrip ("Track") with one slot per
## screen, laid out in NavBar's own Garage/Worldmap/Codex order so Worldmap — the
## default — sits in the physical middle. Navigating slides the whole Track
## instead of swapping scenes, so nothing is ever freed once shown.
##
## Every screen is instanced up front in _ready(), under a blank LoadingScreen
## cover (empty for now — a logo/spinner can go on it later), so the one load
## cost is paid once at launch instead of surfacing as a hitch the first time
## the player taps Garage or Codex.
##
## Leaving the hub entirely (Play, or returning here after a run via
## defeat_screen.gd/victory_screen.gd) still goes through a real
## change_scene_to_file to/from this same file path, which reloads this shell
## (and every screen inside it) from scratch — that is a genuine change of game
## mode, not a hop between meta screens, so it is unaffected by the logic here.

const NavBarScript := preload("res://scenes/ui/widget/nav_bar/nav_bar.gd")

## Design-space width of one screen slot — matches project.godot's
## window/size/viewport_width, the same 1080x1920 canvas nav_bar.gd's own
## comments describe.
const SLOT_WIDTH := 1080.0

const CONTENT_SCENES := {
	NavBarScript.Nav.GARAGE: preload("res://scenes/ui/tower_garage_content.tscn"),
	NavBarScript.Nav.WORLDMAP: preload("res://scenes/ui/world_map_content.tscn"),
	NavBarScript.Nav.CODEX: preload("res://scenes/ui/spell_codex_content.tscn"),
}

@onready var nav_bar: Control = $NavBar
@onready var track: Control = $Viewport/Track
@onready var input_blocker: Control = $InputBlocker
@onready var loading_screen: Control = $LoadingScreen

@onready var _slot_parents: Dictionary = {
	NavBarScript.Nav.GARAGE: $Viewport/Track/GarageSlot,
	NavBarScript.Nav.WORLDMAP: $Viewport/Track/WorldmapSlot,
	NavBarScript.Nav.CODEX: $Viewport/Track/CodexSlot,
}

## Nav -> its instanced content root, only present once a screen has been
## visited at least once.
var _screens: Dictionary = {}

var _current: int = NavBarScript.Nav.WORLDMAP
var _tween: Tween

func _ready() -> void:
	nav_bar.selected = NavBarScript.Nav.WORLDMAP
	$NavBar/GarageButton.pressed.connect(_navigate.bind(NavBarScript.Nav.GARAGE))
	$NavBar/WorldmapButton.pressed.connect(_navigate.bind(NavBarScript.Nav.WORLDMAP))
	$NavBar/CodexButton.pressed.connect(_navigate.bind(NavBarScript.Nav.CODEX))

	for nav in CONTENT_SCENES:
		_ensure_instanced(nav)
	# Snaps the Track to whatever slot _current already claims to be showing —
	# without this the Track sits at its scene-default x=0 (the Garage slot's
	# span) while the NavBar itself reports Worldmap selected, so the very
	# first frame shows Garage's (or, before this loop, nothing's) content
	# under a highlighted "Map" tab.
	track.position.x = -float(_current) * SLOT_WIDTH
	for nav in _screens:
		var screen: Control = _screens[nav]
		if screen.has_method("set_active"):
			screen.set_active(nav == _current)

	# One frame so the now-fully-built hub actually renders before the cover
	# lifts, then reveal it — the launch-time equivalent of the transition's
	# own input_blocker.
	await get_tree().process_frame
	loading_screen.visible = false

func _navigate(target: int) -> void:
	if target == _current or (_tween != null and _tween.is_running()):
		return
	_ensure_instanced(target)
	_current = target
	nav_bar.selected = target

	for nav in _screens:
		var screen: Control = _screens[nav]
		if screen.has_method("set_active"):
			screen.set_active(nav == target)

	# Blocks taps on whichever screens are mid-slide-through the visible window
	# for the short duration of the tween, and stops a second tap re-triggering
	# an overlapping slide.
	input_blocker.visible = true
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(track, "position:x", -float(target) * SLOT_WIDTH, nav_bar.animation_time)
	_tween.finished.connect(_on_slide_finished)

func _on_slide_finished() -> void:
	input_blocker.visible = false

## Instances a screen's content into its slot the first time it is called for
## (in practice, once each for all three, up front in _ready()), and keeps it
## cached from then on — navigating to an already-instanced screen just
## re-runs its own `_refresh()` (every screen already defines one) so it
## reflects whatever changed on the screens the player bounced through in
## between.
func _ensure_instanced(target: int) -> void:
	if _screens.has(target):
		var screen: Control = _screens[target]
		if screen.has_method("_refresh"):
			screen._refresh()
		return
	var screen: Control = CONTENT_SCENES[target].instantiate()
	_slot_parents[target].add_child(screen)
	_screens[target] = screen
