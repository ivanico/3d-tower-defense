@tool
extends Control

## Shows a tower's 3D model on the garage screen.
##
## Renders into a SubViewport with `own_world_3d = true` and a transparent
## background, so the model is lit by this widget's own lights only — nothing here
## can leak into or out of the gameplay world — and the garage's 2D background
## still shows through behind it.
##
## It instances the raw `.glb` from `TowerRegistry.get_preview_model()`, NOT the
## tower's `star_level_scenes`. Those are gameplay scenes and `tower.gd._ready()`
## calls `GameState.start_run()`, so putting one here would start a run.
##
## Everything is a knob and updates live in the editor. The stars and the tower's
## name are NOT part of this widget — they are plain nodes on the garage screen,
## so they can be moved independently of the 3D framing.

## Clip name every animated tower .glb uses. Falls back to the first clip in the
## file if a future model names it something else.
const IDLE_ANIMATION := "idle"

## The same script the autoload uses, preloaded rather than reached through the
## `Constants` singleton: this is a @tool script, and an autoload instance is not
## guaranteed to exist at editor time. Constants on a script need no instance.
const ConstantsScript := preload("res://autoloads/constants.gd")

## Where a star level's decoration scene lives, by convention:
##   scenes/game_object/tower/<id>/<id>_lvl<star>/<id>_lvl<star>_fx.tscn
const EFFECTS_PATH := "res://scenes/game_object/tower/%s/%s_lvl%d/%s_lvl%d_fx.tscn"

@export var tower_id: String = "ancient_tower":
	set(value):
		tower_id = value
		_reload_model()

@export_range(1, 5, 1) var star: int = 1:
	set(value):
		star = clampi(value, 1, 5)
		_reload_model()

@export_group("Camera")
## ONE camera position is used for every tower, at every star level. All five
## ancient_tower .glb files are exported into the same normalised box (y -0.957 to
## +0.953, identical to four decimals), so there is nothing to measure per model
## and nothing that can drift between them. These two numbers move every tower
## together; see "Moving the tower" in ui_tuning.md.

## How far back the camera sits. **Bigger = tower looks SMALLER.**
@export var camera_distance: float = 3.9:
	set(value):
		camera_distance = maxf(value, 0.1)
		_apply()

## Downward tilt in degrees. 0 looks level, 90 looks straight down.
@export var camera_pitch_deg: float = 14.0:
	set(value):
		camera_pitch_deg = value
		_apply()

## What the camera aims at, in model units. Whatever sits at this height appears
## in the middle of the panel, so **raising this moves the tower DOWN** the screen.
## The models run from y -0.957 (base) to +0.953 (top).
@export var look_height: float = 0.0:
	set(value):
		look_height = value
		_apply()

@export var camera_fov: float = 40.0:
	set(value):
		camera_fov = clampf(value, 1.0, 179.0)
		_apply()

@export_group("Model")
## Turntable angle. The gameplay scene stands the tower at 25°, so this defaults
## to roughly the same three-quarter view.
@export var model_yaw_deg: float = 25.0:
	set(value):
		model_yaw_deg = value
		_apply()

## Plays the model's own "idle" clip when the .glb ships one. lvl3-5 of the
## ancient tower do; lvl1 and lvl2 have no animations at all, and those simply
## stand still — nothing to configure per tower.
@export var play_idle: bool = true:
	set(value):
		play_idle = value
		_reload_model()

## Shows the star level's `_fx` decoration scene when one exists — the lvl5
## waterfalls. Turn it off to see the bare model, or if the extra transparent
## quads ever cost too much on a weak device.
@export var show_effects: bool = true:
	set(value):
		show_effects = value
		_reload_model()

## Degrees per second of idle spin. 0 = still, which is what the reference shows.
@export var spin_speed_deg: float = 0.0:
	set(value):
		spin_speed_deg = value
		set_process(spin_speed_deg != 0.0)

## Lifts or drops the model inside the frame.
@export var model_y_offset: float = 0.0:
	set(value):
		model_y_offset = value
		_apply()

@export var model_scale: float = 1.0:
	set(value):
		model_scale = maxf(value, 0.01)
		_apply()

@export_group("Lighting")
@export var key_energy: float = 1.9:
	set(value):
		key_energy = maxf(value, 0.0)
		_apply()

@export var key_color: Color = Color(1.0, 0.97, 0.9):
	set(value):
		key_color = value
		_apply()

## Where the key light comes from, in degrees around the model.
@export var key_yaw_deg: float = -40.0:
	set(value):
		key_yaw_deg = value
		_apply()

@export var key_pitch_deg: float = -45.0:
	set(value):
		key_pitch_deg = value
		_apply()

## Second light from the other side so the shadowed half is not black.
@export var fill_energy: float = 0.8:
	set(value):
		fill_energy = maxf(value, 0.0)
		_apply()

@export var fill_color: Color = Color(0.72, 0.78, 1.0):
	set(value):
		fill_color = value
		_apply()

@export var ambient_energy: float = 0.45:
	set(value):
		ambient_energy = maxf(value, 0.0)
		_apply()

@export var ambient_color: Color = Color(0.5, 0.45, 0.65):
	set(value):
		ambient_color = value
		_apply()

@onready var _viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var _camera: Camera3D = $SubViewportContainer/SubViewport/Camera3D
@onready var _key: DirectionalLight3D = $SubViewportContainer/SubViewport/KeyLight
@onready var _fill: DirectionalLight3D = $SubViewportContainer/SubViewport/FillLight
@onready var _model_root: Node3D = $SubViewportContainer/SubViewport/ModelRoot
@onready var _world_env: WorldEnvironment = $SubViewportContainer/SubViewport/WorldEnvironment

var _model: Node3D
var _spin: float = 0.0


func _ready() -> void:
	set_process(spin_speed_deg != 0.0)
	# Framing depends on the panel's real size, and at _ready() that is still the
	# widget scene's own default, not whatever the screen gave this instance.
	# Without this the model is framed for the wrong rect and gets clipped.
	if not resized.is_connected(_apply):
		resized.connect(_apply)
	_apply()
	_reload_model()


func _process(delta: float) -> void:
	_spin = fmod(_spin + spin_speed_deg * delta, 360.0)
	if _model_root != null:
		_model_root.rotation.y = deg_to_rad(model_yaw_deg + _spin)


## Called by the garage whenever the selection or star level changes.
func show_tower(id: String, star_level: int) -> void:
	tower_id = id
	star = star_level


func _reload_model() -> void:
	if not is_inside_tree() or _model_root == null:
		return
	if _model != null:
		_model.queue_free()
		_model = null
	var packed := TowerRegistry.get_preview_model(tower_id, star)
	if packed == null:
		return
	_model = packed.instantiate()
	_model_root.add_child(_model)
	_add_effects()
	_start_idle()
	_apply()


## Adds the star level's decoration scene — the lvl5 waterfalls, and whatever a
## future tower gets — if one exists at the conventional path.
##
## The decoration cannot come from the tower's gameplay scene: `tower.gd._ready()`
## calls `GameState.start_run()`, so instancing that here would begin a run. It is
## therefore split into its own `_fx` scene that BOTH the gameplay tower and this
## preview instance, so there is exactly one copy of the effect.
##
## A star level with no `_fx` scene simply gets nothing. Nothing to configure.
func _add_effects() -> void:
	if not show_effects or _model == null:
		return
	var path := EFFECTS_PATH % [tower_id, tower_id, star, tower_id, star]
	if not ResourceLoader.exists(path):
		return
	# Parented to the MODEL, not to ModelRoot: the transforms inside the _fx scene
	# are authored in the .glb's local space, exactly as they were when the planes
	# were direct children of the model instance in the gameplay scene.
	_model.add_child((load(path) as PackedScene).instantiate())


## The glTF importer builds an `AnimationPlayer` under the model's root when the
## file has clips, and does NOT carry glTF's loop flag across — so the clip plays
## once and freezes unless the loop mode is set here.
func _start_idle() -> void:
	if not play_idle or _model == null:
		return
	var player: AnimationPlayer = _model.find_child("AnimationPlayer", true, false)
	if player == null:
		return
	var clip := IDLE_ANIMATION
	if not player.has_animation(clip):
		var available := player.get_animation_list()
		if available.is_empty():
			return
		clip = available[0]
	var animation := player.get_animation(clip)
	if animation != null:
		animation.loop_mode = Animation.LOOP_LINEAR
	# Same speed the gameplay tower uses (tower.gd:39) — the clip is authored at
	# 1 second and runs three times too fast at its native rate. Shared constant,
	# so retuning the idle in Constants.gd changes the game AND this preview.
	player.play(clip, -1.0, ConstantsScript.TOWER_IDLE_ANIM_SPEED_SCALE)


func _apply() -> void:
	if not is_inside_tree() or _camera == null:
		return

	_camera.fov = camera_fov
	_model_root.position.y = model_y_offset
	_model_root.rotation.y = deg_to_rad(model_yaw_deg + _spin)
	_model_root.scale = Vector3.ONE * model_scale

	_place_camera(camera_distance, look_height)

	_key.light_energy = key_energy
	_key.light_color = key_color
	_key.rotation = Vector3(deg_to_rad(key_pitch_deg), deg_to_rad(key_yaw_deg), 0.0)
	_fill.light_energy = fill_energy
	_fill.light_color = fill_color
	_fill.rotation = Vector3(deg_to_rad(-20.0), deg_to_rad(key_yaw_deg + 180.0), 0.0)

	# The Environment lives on a WorldEnvironment node in the scene rather than
	# being assigned to `world_3d` here: with own_world_3d the viewport's World3D
	# does not exist yet while the export setters run, and touching it errors.
	if _world_env != null and _world_env.environment != null:
		_world_env.environment.ambient_light_color = ambient_color
		_world_env.environment.ambient_light_energy = ambient_energy


func _place_camera(distance: float, height: float) -> void:
	var target := Vector3(0.0, height, 0.0)
	var pitch := deg_to_rad(camera_pitch_deg)
	# Straight back along +Z, then lifted by the pitch angle and aimed back down.
	_camera.position = target + Vector3(0.0, sin(pitch), cos(pitch)) * distance
	_camera.look_at(target, Vector3.UP)
	_camera.force_update_transform()
