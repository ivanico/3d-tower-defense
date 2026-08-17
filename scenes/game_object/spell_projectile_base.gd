@tool
extends Area3D

## Shared base for the "flying/bouncing/piercing" spell projectile
## archetypes -- Standard Bolt, Chain Bolt, Line AoE Bolt. NOT instantiated
## directly and has no `.tscn` of its own; each archetype extends it via
## script inheritance (`extends "res://..."`), the same pattern this
## project already uses for `aoe_area.gd`'s Blizzard/Rain of Fire variants.
##
## Owns the three things that were identical copy-paste across all three
## archetype scripts before this: applying the baked `Model` child's
## transform, the in-editor school preview toggle (same idea as orb.gd's
## own `preview_school`), and the `SchoolVFXComponent.configure()` call used
## by real casts. Archetype-specific behavior (targeting, movement, hit
## detection) stays in each subclass.
##
## Per-archetype `model_rotation_degrees`/`model_scale` defaults are set as
## saved property overrides on each archetype's own root node in its
## `.tscn` (same as `preview_school`'s per-scene override), not
## re-declared in script -- keeps this base free of per-archetype
## special-casing.

@export var model_rotation_degrees: Vector3 = Vector3.ZERO
@export var model_scale: Vector3 = Vector3.ONE
# Same per-archetype override pattern as the two above -- lets the EDITOR
# PREVIEW actually reflect what `initialize()`'s own `_configure_school_vfx()`
# call passes for this archetype (see that function's own doc comment),
# instead of the preview always silently using `false` regardless of what
# real gameplay does. Chain Bolt sets this true as a per-scene override in
# chain_bolt.tscn; every other archetype leaves it at this default.
@export var preview_allow_ring: bool = false
# Same idea, for `configure()`'s `ring_filled` param -- see that function's
# own doc comment. Chain Bolt sets this true alongside `preview_allow_ring`.
@export var preview_ring_filled: bool = false

## EDITOR ONLY -- open the scene in the editor and change this to see that
## school's shader + particle/trail look on the actual mesh, live.
@export_enum("Fire", "Frost", "Void", "Poison", "Nature") var preview_school: int = 0:
	set(value):
		preview_school = value
		if Engine.is_editor_hint() and is_inside_tree():
			_apply_preview()

# Baked as a permanent child node in each archetype's .tscn (NOT
# instantiated at runtime) so the model is visible the instant the scene is
# opened in the editor -- see orb.gd's own `Model` for why.
@onready var _model: Node3D = $Model

func _ready() -> void:
	_model.rotation_degrees = model_rotation_degrees
	_model.scale = model_scale
	if Engine.is_editor_hint():
		_apply_preview()

## Synthetic "flying toward -Z" backward vector (Godot's own forward
## convention) -- a static editor preview has no real travel to compute
## one from, but schools opting into "direction_follows_travel" (Fire)
## should still be visible here without having to run the game, so this
## fakes the same world-space backward vector a bolt actually flying
## toward -Z would work out for itself.
const PREVIEW_BACKWARD_DIRECTION := Vector3(0, 0, 1)

## Subclasses that need `sonic_ring_tuning` (currently just Standard Bolt --
## see its own `VOID_SONIC_RING_TUNING` comment) override this ONE function
## to add it, rather than this base exposing yet another per-archetype
## export -- a Dictionary constant living next to the archetype script that
## actually uses it is simpler than a Dictionary in the .tscn inspector.
func _apply_preview() -> void:
	$SchoolVFXComponent.configure(preview_school, _model, preview_allow_ring, PREVIEW_BACKWARD_DIRECTION, preview_ring_filled)

## Called by each subclass's own initialize()/setup() with the real cast
## damage_type. `allow_ring` defaults off -- Standard/Line AoE Bolt don't
## pass it, so they keep getting `_build_sonic_rings()`'s 2-ring travel
## effect (see school_vfx_component.gd's `allow_ring` doc). Chain Bolt
## passes `true` -- per feedback it should look like the Orb's own single
## flat accretion disk instead, not the sonic-ring pair the other bolts use.
## `backward_direction_world` is this bolt's own "opposite of travel"
## vector in plain WORLD space -- optional, only schools opting into
## "direction_follows_travel" (currently Fire) ever use it, see
## school_vfx_component.gd's doc comment on `configure()`/`_build_particles()`.
## `ring_filled` -- see school_vfx_component.gd's `configure()` doc comment.
## `sonic_ring_tuning` -- see school_vfx_component.gd's `configure()` doc
## comment on it. Empty (default) keeps the original sonic-ring numbers --
## only Standard Bolt currently passes its own tuned dict.
func _configure_school_vfx(damage_type: int, backward_direction_world: Vector3 = Vector3.ZERO, allow_ring: bool = false, ring_filled: bool = false, sonic_ring_tuning: Dictionary = {}) -> void:
	$SchoolVFXComponent.configure(damage_type, _model, allow_ring, backward_direction_world, ring_filled, sonic_ring_tuning)

## Called by `ObjectPool.release()` (via `has_method()` duck-typing, not an
## override -- see that function) the moment this projectile is hit and
## hidden. See `school_vfx_component.gd`'s `stop()` doc comment for why
## this matters: pooling only ever hides a node, it never frees it, so
## without this hook a hit-but-not-yet-reused bolt would keep simulating
## its particle dressing in the background, invisible, until its next shot.
func _on_pool_released() -> void:
	$SchoolVFXComponent.stop()
