---
name: godot3d-camera-character
description: Use this skill whenever working on the camera rig, character/enemy facing direction, animation state switching, or anything related to making real 3D content read as an Archero-style fixed-angle top-down game. Trigger this when setting up or adjusting Camera3D, when wiring AnimationPlayer states (idle/walk/attack/death) on the tower or enemies, when handling movement-direction facing, or when something looks "off" about how the 3D scene presents (wrong angle, camera rotating, models not facing their movement direction).
---

# Godot 3D Camera & Character — The Archero-Style "2.5D" Look

This project's entire visual identity rests on getting one thing right: real
3D content, fixed-angle camera, never-rotating presentation. This skill
covers the concrete Godot patterns for that.

## The camera rig — fixed, never orbits

```gdscript
# scenes/game_object/camera_rig/camera_rig.gd
extends Node3D
class_name CameraRig

@export var camera_pitch_degrees: float = 45.0
@export var camera_distance: float = 10.0
@export var camera_height: float = 10.0  # height == distance = exactly 45° pitch
@export var camera_size: float = 14.0

@onready var camera: Camera3D = $Camera3D

func _ready() -> void:
    camera.position = Vector3(0, camera_height, camera_distance)
    camera.look_at(Vector3.ZERO, Vector3.UP)
    camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    camera.size = camera_size  # world-units visible across the shorter viewport axis
```

**There is no camera rotation input anywhere in this project.** No
`_unhandled_input` reading touch-drag to orbit, no right-stick camera
control. If you find yourself wiring camera rotation input, stop — that's
not this game. The only camera *motion* allowed is:
- Tiny reactive jitter for screen shake (small positional offset, tweened
  back to zero — never changes pitch/yaw).
- Possibly a slow lerp of position if a future chapter has a moving focal
  point (not needed at v1, since the tower never moves).

```gdscript
func shake(duration: float, magnitude: float) -> void:
    var tween := create_tween()
    var elapsed := 0.0
    var original_pos := camera.position
    while elapsed < duration:
        var offset := Vector3(
            randf_range(-magnitude, magnitude),
            randf_range(-magnitude, magnitude),
            0.0  # never shake along the camera's forward axis — that reads as a zoom pulse, not a shake
        )
        tween.tween_property(camera, "position", original_pos + offset, 0.05)
        elapsed += 0.05
    tween.tween_property(camera, "position", original_pos, 0.1)
```

## Why orthographic + 45° + Z-stretched ground = perfect squares

Archero uses **orthographic projection at ~45° oblique pitch**. At 45°, a unit
of Z-depth projects to `sin(45°) = 0.707` units on screen — meaning floor tiles
would appear shorter in depth than in width. To compensate, the ground plane is
physically elongated in Z by `1/sin(45°) = √2 ≈ 1.414×`. A tile that is 1m × 1m
in visual intent becomes 1m × 1.414m in world space — and at 45° pitch through
the orthographic lens it appears as a perfect square on screen.

This stretch applies to the ground plane only. All game logic (spawn positions,
movement, collision) stays in unstretched world space. Tune `camera_size` to
control zoom; smaller = more zoomed in.

## Facing direction — the 3D equivalent of sprite-flipping

2D games fake facing direction with `flip_h`. In real 3D, rotate the model
to actually face its direction of travel:

```gdscript
# enemy.gd or inside move_to_target_component.gd
func _update_facing(direction: Vector3) -> void:
    if direction.length_squared() < 0.001:
        return
    var flat_dir := Vector3(direction.x, 0, direction.z).normalized()
    var target_pos := global_position + flat_dir
    look_at(target_pos, Vector3.UP)
```

Keep this rotation on the X/Z plane only (don't let `look_at` tip the model
forward/backward as it moves on uneven... there is no uneven ground in this
project, since the arena is flat per `mechanics.md`, but the principle holds
for any future terrain). If a model visually tips or rolls when turning,
something is feeding `look_at` a target that isn't flattened to the same Y as
the model's own position.

## Animation state machine — keep it explicit, not implicit

Each character has a small, fixed set of states. Don't build a generic
animation-blend-tree system for this scope — a plain `match`/`if` on a state
enum, calling `AnimationPlayer.play()`, is the right amount of complexity:

```gdscript
enum EnemyState { WALK, ATTACK, DEATH }
var _state: EnemyState = EnemyState.WALK

func _set_state(new_state: EnemyState) -> void:
    if _state == new_state:
        return
    _state = new_state
    match new_state:
        EnemyState.WALK:
            anim_player.play("walk")
        EnemyState.ATTACK:
            anim_player.play("attack")
        EnemyState.DEATH:
            anim_player.play("death")
            anim_player.animation_finished.connect(_on_death_finished, CONNECT_ONE_SHOT)
```

Guard against re-triggering the same animation every frame (`if _state ==
new_state: return` above) — calling `.play()` on an already-playing
animation every physics frame can cause visible stutter on some animation
setups.

## Death animation must complete before pool release

```gdscript
func _on_death_finished(anim_name: String) -> void:
    if anim_name == "death":
        ObjectPool.release(get_parent())  # or owner, depending on component placement
```

Don't release to the pool the instant HP hits zero — that skips the death
animation entirely. Wait for `animation_finished`.

## Scale sanity checks when wiring real models (Epic 06)

When swapping a primitive placeholder for a real Meshy `.glb`:
1. Instance the model, check its bounding box against the expected height
   range in `assets.md` Section 1's scale table.
2. If it's wildly off (a common Meshy/Blender export-scale mismatch), fix it
   with an explicit `scale` adjustment at import or in the spawning script —
   don't leave models at an arbitrary native scale and compensate by moving
   the camera, which will throw off every other model's relative size.
3. Re-check the boss specifically — it must read as dramatically larger than
   regular enemies both in actual `Vector3` scale and in on-screen footprint
   at the fixed camera distance.

## Quick checklist when something "looks wrong"

- Camera rotating or tilting unexpectedly → check nothing is calling
  `look_at()` or setting `rotation` on the `CameraRig`/`Camera3D` outside of
  `_ready()` and the `shake()` tween.
- Models facing the wrong way while walking → confirm the facing update uses
  a flattened (Y-zeroed) direction vector, and confirm it's actually being
  called (not just computed and discarded).
- Ground tiles showing perspective (far tiles smaller) → confirm
  `Camera3D.projection == PROJECTION_ORTHOGONAL`, not perspective.
- Shadows missing or wrong shape → that's `godot3d-architecture`/the asset
  pipeline's territory (lighting setup), not this skill — check
  `DirectionalLight3D.shadow_enabled` and the `WorldEnvironment` ambient
  settings.
