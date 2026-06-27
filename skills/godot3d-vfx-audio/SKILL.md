---
name: godot3d-vfx-audio
description: Use this skill whenever implementing particle effects (GPUParticles3D), wiring AudioManager/EventBus-driven sound, billboarded UI-in-3D elements (damage numbers, HP bars), or doing mobile performance tuning specific to real-time 3D (shadow cost, particle budgets, draw calls). Trigger this for any task involving VFX, SFX/music wiring, Label3D/Sprite3D billboard UI, or performance profiling on the Mobile renderer.
---

# Godot 3D VFX, Audio & Mobile Performance

Patterns specific to making real-time 3D feel and sound finished without
tanking frame rate on a mid-range phone.

## GPUParticles3D — one-shot effects must clean themselves up

```gdscript
# vfx_hit_spark.gd
extends GPUParticles3D

func _ready() -> void:
    emitting = true
    finished.connect(queue_free)
```

For pooled VFX (if you choose to pool them — not required at this project's
scale, but consider it if profiling shows particle-node churn is a cost),
release to `ObjectPool` instead of `queue_free()`, same contract as every
other pooled combat entity.

**Always set `one_shot = true` and `emitting = true` together on spawn**, and
always connect `finished` to actually remove/release the node. A particle
emitter that's left in the scene tree after it's done emitting is exactly the
kind of leak that shows up as slow memory growth over a long play session.

## Particle budget — global ceiling, not per-effect limits

3D particles are typically costlier per-particle than 2D ones. Use a simple
shared counter so the game degrades gracefully under load instead of
silently tanking frame rate:

```gdscript
# Could live in CombatUtils as static state, or a small dedicated autoload —
# pick one location, don't duplicate the counter in multiple places.
static var _active_particle_budget: int = 0
const MAX_PARTICLE_BUDGET: int = 150

static func try_reserve_particles(count: int, is_priority: bool = false) -> bool:
    if _active_particle_budget + count > MAX_PARTICLE_BUDGET and not is_priority:
        return false  # skip low-priority effects like hit sparks when over budget
    _active_particle_budget += count
    return true

static func release_particles(count: int) -> void:
    _active_particle_budget = max(0, _active_particle_budget - count)
```

Always let death and level-up VFX through regardless of budget (`is_priority
= true`) — those communicate important game state, unlike hit sparks which
are pure flourish.

## Billboarded 3D UI — damage numbers, HP bars

`Label3D` and `Sprite3D` both support `billboard = BILLBOARD_ENABLED`, which
keeps them always facing the camera regardless of where in the arena they
are. This is the simplest path for "2D-feeling UI element living in 3D
space" and should be preferred over building a `SubViewport`-based
UI-rendered-as-a-3D-texture setup unless billboard mode genuinely can't
achieve the look you need (it almost always can at this project's scope).

```gdscript
# damage_number_3d.gd
extends Label3D

func spawn(value: float, dtype: int, is_crit: bool, world_pos: Vector3) -> void:
    text = str(int(value))
    modulate = CombatUtils.get_damage_color(dtype)
    scale = Vector3.ONE * (1.4 if is_crit else 1.0)
    global_position = world_pos + Vector3(randf_range(-0.3, 0.3), 1.5, randf_range(-0.3, 0.3))
    var tween := create_tween()
    tween.tween_property(self, "position:y", position.y + 1.0, 0.8)
    tween.parallel().tween_property(self, "modulate:a", 0.0, 0.4).set_delay(0.4)
    tween.finished.connect(func(): ObjectPool.release(self))
```

Note the 3D-specific detail: the random scatter is a real `Vector3` offset
on X/Z (world space), not a 2D screen-space pixel offset — don't port 2D
scatter logic (`randf_range(-20, 20)` in screen pixels) directly; the
equivalent in world meters is a much smaller number.

If a billboarded label visually clips behind nearby geometry at certain
camera angles, try `no_depth_test = true` on the `Label3D` before reaching
for anything more complex.

## AudioManager — reactive, not called directly from gameplay code

Gameplay code emits `EventBus` signals; `AudioManager` is the only thing that
listens to them and decides what to play. This keeps audio swappable/
tunable without touching combat code:

```gdscript
# In AudioManager._ready()
EventBus.tower_damaged.connect(func(amount): play_sfx("sfx_tower_hit.wav"))
EventBus.level_up.connect(func(level): play_sfx("sfx_level_up.wav"))
```

Avoid calling `AudioManager.play_sfx()` directly from deep inside combat
logic for events that already have an `EventBus` signal — wire it through
the signal instead, so a future "mute combat hit sounds during boss intro"
type of rule has one place to live (`AudioManager`) rather than scattered
call sites.

For sounds that don't have a natural `EventBus` signal yet (e.g. per-shot
pitch-varied projectile SFX, which needs to happen at the exact moment of
firing with per-call pitch randomization), calling
`AudioManager.play_sfx(name, pitch_scale)` directly from that one call site
is fine — the point isn't "never call AudioManager directly," it's "don't
duplicate logic that's already reactive to an existing signal."

## SFX pool exhaustion — skip, don't queue, at this scale

```gdscript
func play_sfx(filename: String, pitch_scale: float = 1.0) -> void:
    var player := _get_idle_player()
    if player == null:
        return  # all pool players busy — just skip this one, don't queue it
    player.stream = _preloaded_sfx.get(filename)
    player.pitch_scale = pitch_scale
    player.volume_db = _sfx_volume_db
    player.play()
```

A small SFX pool (8 players at this project's v1 scale) occasionally
skipping a sound under a burst of simultaneous hits is the correct trade-off
— building a priority queue for SFX is over-engineering for this scope.
Revisit only if playtesting reveals audibly-missing important sounds (like
the tower taking damage), not for flourish sounds like hit impacts.

## Mobile 3D performance checklist

When profiling on the Mobile renderer with real-time shadows:

1. **Shadow distance/resolution first.** This is usually the single biggest
   new cost versus a 2D project. Check the profiler's render breakdown
   specifically for the shadow pass. Tune `DirectionalLight3D`'s shadow
   distance down to the minimum that still covers what the fixed camera can
   actually see — don't render shadow detail for the far side of an arena the
   camera never shows from this angle.
2. **Shared materials batch better than unique-per-instance materials.**
   If every enemy of the same type uses the same `StandardMaterial3D`/
   `ShaderMaterial` resource (not a `.duplicate()`'d copy each), Godot can
   batch draw calls more effectively. Don't accidentally give every spawned
   enemy instance its own unique material instance unless you actually need
   per-instance material variation (you usually don't, at this scope).
3. **Collision shape complexity.** Use simple primitive `CollisionShape3D`
   types (capsule, sphere, box) for combat hitboxes/hurtboxes/movement
   bodies — never a concave/mesh collision shape for anything that moves or
   triggers frequently. Reserve mesh collision for static, rarely-queried
   geometry like the arena ground/walls if absolutely needed.
4. **Re-check after every Epic 06 art swap.** A primitive placeholder and a
   real Meshy model can have very different triangle counts and material
   complexity. The performance pass in `epic_08_polish.md` happens after art
   is in for exactly this reason — don't assume placeholder-stage performance
   numbers hold once real models are wired in.
