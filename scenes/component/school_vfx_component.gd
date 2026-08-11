@tool
class_name SchoolVFXComponent
extends Node3D

## Dresses up a spell object's existing mesh with a per-school elemental
## look: `CombatUtils.get_school_shader_material()` (a livelier shader,
## replacing the old flat-tint `StandardMaterial3D`) plus two small
## `GPUParticles3D` children -- an ambient aura hugging the mesh, and a
## trail of particles left behind as it moves. Same auto-discovery component
## pattern as `hit_flash_component.gd`: instance this as a child, call
## `configure(damage_type)` once (from wherever the archetype script already
## called `CombatUtils.get_school_material()` -- see `orb.gd::setup()`).
##
## Why a mesh at all instead of a pure shader shape: a fragment shader only
## colors pixels a mesh already rasterizes -- it can't conjure geometry.
## Raymarching an SDF shape in the fragment shader is a real alternative but
## costly per-pixel, wrong for something spawned this often on the Mobile
## renderer target this project builds for. Keeping the existing mesh and
## dressing it with a surface shader + particles is the standard approach
## for frequently-spawned VFX in real games; fully custom sculpted geometry
## per variant is reserved for rare, high-budget effects (bosses, ultimates).
##
## Reused by every archetype eventually (bolt/chain/AoE/line), not just Orb
## -- nothing about this component assumes the orb specifically.

## Per-school PARTICLE look. Colocated here, not `Constants.gd`, because
## every value is specific to this component's own `GPUParticles3D` setup --
## nothing else in the project reads these (contrast `Constants.SCHOOL_COLORS`,
## which many consumers read, and `CombatUtils.SCHOOL_SHADER_PRESETS`, which
## lives next to the shader material builder it feeds).
const PRESETS: Dictionary = {
	Constants.DamageType.FIRE: {
		"direction": Vector3(0, 1, 0), "spread": 20.0, "gravity": Vector3(0, 0.6, 0),
		"velocity": 0.4, "lifetime": 0.6, "amount": 10,
	},
	Constants.DamageType.FROST: {
		"direction": Vector3.ZERO, "spread": 180.0, "gravity": Vector3.ZERO,
		"velocity": 0.15, "lifetime": 1.2, "amount": 8,
	},
	Constants.DamageType.VOID: {
		"direction": Vector3(0, 0.3, 0), "spread": 60.0, "gravity": Vector3.ZERO,
		"velocity": 0.1, "lifetime": 1.5, "amount": 6,
	},
	Constants.DamageType.POISON: {
		"direction": Vector3(0, 1, 0), "spread": 15.0, "gravity": Vector3(0, 0.3, 0),
		"velocity": 0.25, "lifetime": 0.9, "amount": 8,
	},
	Constants.DamageType.NATURE: {
		"direction": Vector3(0, 0.4, 0), "spread": 40.0, "gravity": Vector3(0, -0.1, 0),
		"velocity": 0.2, "lifetime": 1.0, "amount": 8,
	},
}

# Trail is world-space, low-velocity, continuously-emitting particles left
# behind as this node moves -- NOT GPUParticles3D's `trail_enabled` ribbon
# feature (that's a different look, meant for a continuous ribbon mesh
# behind each particle, and needs a trail mesh set up per-particle). Plain
# world-space emission is the simpler, standard way to get a fading trail
# behind a moving emitter: particles stay where they were emitted instead of
# following the node, so a moving orb naturally leaves a fading arc.
const TRAIL_AMOUNT: int = 14
const TRAIL_LIFETIME: float = 0.35

static var _particle_texture: ImageTexture

var _damage_type: int = -1
var _aura: GPUParticles3D
var _trail: GPUParticles3D
var _reserved_particles: int = 0


## `search_root` is optional -- auto-discovers the parent's own subtree the
## same way `hit_flash_component.gd` does, if not given explicitly. Applies
## the elemental shader to EVERY `MeshInstance3D` under it (a model can have
## more than one), but only builds the particle dressing once regardless of
## mesh count -- callers looping over their model's meshes to set a material
## (the old `CombatUtils.get_school_material()` pattern) should call this
## ONCE with the model root, not once per mesh.
func configure(damage_type: int, search_root: Node3D = null) -> void:
	_damage_type = damage_type
	if search_root == null:
		search_root = get_parent()
	var meshes := search_root.find_children("*", "MeshInstance3D", true, false)
	if meshes.is_empty():
		return
	var mat := CombatUtils.get_school_shader_material(damage_type)
	for mi in meshes:
		(mi as MeshInstance3D).material_override = mat

	_teardown_particles()

	var preset: Dictionary = PRESETS.get(damage_type, PRESETS[Constants.DamageType.VOID])
	_aura = _build_particles("Aura", preset.amount, preset.lifetime, true, preset)
	_trail = _build_particles("Trail", TRAIL_AMOUNT, TRAIL_LIFETIME, false, preset)

	var total: int = int(preset.amount) + TRAIL_AMOUNT
	if CombatUtils.try_reserve_particles(total):
		_reserved_particles = total
		_aura.emitting = true
		_trail.emitting = true
	# else: shader dressing above still applies -- only the particle
	# dressing is skipped when the global budget is already spent.


## `configure()` can be called more than once on the same instance -- e.g.
## the editor preview below switching schools -- and must not leak budget or
## pile up duplicate particle children each time. `remove_child()` first,
## THEN `queue_free()`: the new node gets the same deterministic name
## ("Aura"/"Trail") this same frame, and queue_free() alone defers removal
## to end-of-frame, so the still-attached old node would collide with it and
## get silently renamed by Godot (same gotcha as any other rebuilt-children
## UI list in this project).
func _teardown_particles() -> void:
	if _reserved_particles > 0:
		CombatUtils.release_particles(_reserved_particles)
		_reserved_particles = 0
	if _aura != null:
		remove_child(_aura)
		_aura.queue_free()
		_aura = null
	if _trail != null:
		remove_child(_trail)
		_trail.queue_free()
		_trail = null


func _build_particles(node_name: String, amount: int, lifetime: float, local: bool, preset: Dictionary) -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.name = node_name
	p.amount = amount
	p.lifetime = lifetime
	p.one_shot = false
	p.emitting = false  # gated on the budget check in configure()
	p.local_coords = local  # false for the trail: emitted particles stay put in world space as this node moves, which is what makes it read as a trail

	var quad := QuadMesh.new()
	quad.size = Vector2(0.08, 0.08)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	mat.albedo_texture = _get_particle_texture()
	var color := CombatUtils.get_damage_color(_damage_type)
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 2.0
	quad.material = mat
	p.draw_pass_1 = quad

	var proc := ParticleProcessMaterial.new()
	proc.direction = preset.direction if local else Vector3.ZERO
	proc.spread = preset.spread if local else 5.0
	proc.gravity = preset.gravity if local else Vector3.ZERO
	var vel: float = preset.velocity if local else 0.02
	proc.initial_velocity_min = vel * 0.7
	proc.initial_velocity_max = vel
	proc.scale_min = 0.6
	proc.scale_max = 1.2
	proc.color = color
	p.process_material = proc

	add_child(p)
	return p


## Small procedural soft-circle billboard, shared across every instance and
## every school (color comes from the material, not the texture) -- same
## "generate, don't depend on art" approach as `bar_texture.gd`, so this
## needs no PNG asset.
static func _get_particle_texture() -> ImageTexture:
	if _particle_texture == null:
		const SIZE := 16
		var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
		var center := Vector2(SIZE - 1, SIZE - 1) * 0.5
		for y in SIZE:
			for x in SIZE:
				var d := Vector2(x, y).distance_to(center) / (SIZE * 0.5)
				var a := clampf(1.0 - d, 0.0, 1.0)
				a *= a
				img.set_pixel(x, y, Color(1.0, 1.0, 1.0, a))
		_particle_texture = ImageTexture.create_from_image(img)
	return _particle_texture


func _exit_tree() -> void:
	if _reserved_particles > 0:
		CombatUtils.release_particles(_reserved_particles)
		_reserved_particles = 0
	# Note: does NOT call _teardown_particles() -- remove_child() during
	# _exit_tree() (the tree is already being torn down) is unnecessary and
	# queue_free() alone is enough for genuine destruction, unlike the
	# same-frame-rebuild case _teardown_particles() exists for.
