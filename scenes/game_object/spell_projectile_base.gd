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

func _apply_preview() -> void:
	$SchoolVFXComponent.configure(preview_school, _model, false)

## Called by each subclass's own initialize()/setup() with the real cast
## damage_type. `allow_ring` is always off here -- Orb is the only
## archetype that keeps the Void accretion-disk ring (see
## school_vfx_component.gd's `allow_ring` doc).
func _configure_school_vfx(damage_type: int) -> void:
	$SchoolVFXComponent.configure(damage_type, _model, false)
