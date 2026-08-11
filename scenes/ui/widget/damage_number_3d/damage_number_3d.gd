class_name DamageNumber3D
extends Node3D

## Floating 3D damage number, pooled via `ObjectPool` (epic_08_polish.md
## Task 08-01). Follows the base pattern documented in
## `skills/godot3d-vfx-audio/SKILL.md`'s "Billboarded 3D UI" section, but
## wraps one `OutlinedLabel3D` instead of a bare `Label3D` -- that gives
## damage numbers the same shadow+outline look as every other 3D number in
## the game (`value_bar_3d.gd`'s HP number) for free, instead of a second,
## visually inconsistent implementation.
##
## Has a `class_name` (unlike the `@tool` widgets it's built from) because
## it's a plain runtime gameplay script, not an editor-preview widget --
## same convention `HurtboxComponent`/`HealthComponent` already use. This
## lets `HurtboxComponent` call `DamageNumber3D.can_spawn()` directly.

const OutlinedLabel3DScene := preload("res://scenes/ui/widget/outlined_label_3d/outlined_label_3d.tscn")

## Tune by eye per epic_08_polish.md's own instruction ("start large ... and
## adjust") — spec started at 48; 64 still read small in-game, so this is
## more than double that. World size is `font_size * pixel_size`, so this and
## `pixel_size` below both push the same direction if it still needs to grow.
@export var font_size: int = 140

## World units per texture pixel -- the other half of the size equation
## (world size = `font_size * pixel_size`). Matches `value_bar_3d`'s own
## default; raise this instead of `font_size` if the text needs to get
## bigger without looking any less crisp.
@export var pixel_size: float = 0.003

## Fallback for when the number visually clips behind nearby geometry at
## certain camera angles (per the epic task's acceptance criteria). Off by
## default -- only turn on where it's actually needed.
@export var always_on_top: bool = false

# Global budget across every damage number in the game at once, per the
# epic task's "cap at 10 simultaneous" requirement -- static, not
# per-instance, since the cap is a whole-game budget, not per-enemy/spell.
static var _visible_count: int = 0

var _label # an OutlinedLabel3D instance (untyped -- see value_bar_3d.gd's
		   # note on why: outlined_label_3d.gd has no class_name)
var _base_scale: Vector3 = Vector3.ONE


func _ready() -> void:
	_label = OutlinedLabel3DScene.instantiate()
	add_child(_label)
	_label.font_size = font_size
	_label.pixel_size = pixel_size
	_label.always_on_top = always_on_top
	_base_scale = scale


## Callers should check this BEFORE `ObjectPool.acquire()`-ing an instance,
## so a hit past the cap doesn't consume (and immediately have to release) a
## pool slot for nothing.
static func can_spawn() -> bool:
	return _visible_count < Constants.DAMAGE_NUMBER_MAX_VISIBLE


func spawn(value: float, dtype: int, is_crit: bool, world_pos: Vector3) -> void:
	var shown := str(int(round(value)))
	_label.text = ("★" + shown) if is_crit else shown
	_label.text_color = CombatUtils.get_damage_color(dtype)
	_label.opacity = 1.0

	# Intro is a scale pop-in (0 -> full size), not a rising position anymore
	# -- the number now spawns and stays put at world_pos, no longer travels
	# upward. TRANS_BACK/EASE_OUT gives it a small overshoot-then-settle
	# "pop" instead of a flat linear grow.
	var target_scale := _base_scale * (Constants.DAMAGE_NUMBER_CRIT_SCALE if is_crit else 1.0)
	scale = Vector3.ZERO

	global_position = world_pos + Vector3(
			randf_range(-Constants.DAMAGE_NUMBER_SCATTER_RADIUS, Constants.DAMAGE_NUMBER_SCATTER_RADIUS),
			Constants.DAMAGE_NUMBER_SPAWN_HEIGHT,
			randf_range(-Constants.DAMAGE_NUMBER_SCATTER_RADIUS, Constants.DAMAGE_NUMBER_SCATTER_RADIUS))

	_visible_count += 1
	var tween := create_tween()
	tween.tween_property(self, "scale", target_scale, Constants.DAMAGE_NUMBER_SCALE_IN_DURATION) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Fade timing unchanged -- still starts DAMAGE_NUMBER_FADE_DELAY in and
	# runs DAMAGE_NUMBER_FADE_DURATION, so the total lifetime (and therefore
	# when this releases back to the pool) is exactly what it was before.
	tween.parallel().tween_property(_label, "opacity", 0.0, Constants.DAMAGE_NUMBER_FADE_DURATION) \
			.set_delay(Constants.DAMAGE_NUMBER_FADE_DELAY)
	tween.finished.connect(_on_tween_finished)


func _on_tween_finished() -> void:
	_visible_count = maxi(_visible_count - 1, 0)
	ObjectPool.release(self)
