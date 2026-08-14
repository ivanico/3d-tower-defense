@tool
class_name SchoolVFXComponent
extends Node3D

## Dresses up a spell object's existing mesh with a per-school elemental
## look: `CombatUtils.get_school_shader_material()` (a livelier shader,
## replacing the old flat-tint `StandardMaterial3D`) plus an ambient
## `GPUParticles3D` aura wrapping the whole mesh surface, and a hand-built
## ribbon-mesh trail left behind as it moves. Same auto-discovery component
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
		# Wide spread + emission across the whole sphere surface (see
		# `_build_particles()`) is what makes this read as flames licking up
		# all around the orb rather than a jet off the top -- every emission
		# point (including ones that spawned on the underside) drifts
		# straight up via `direction`, so the bottom of the sphere gets
		# covered too, not just the top.
		"direction": Vector3(0, 1, 0), "spread": 35.0, "gravity": Vector3(0, 0.9, 0),
		"velocity": 0.5, "lifetime": 0.7, "amount": 16,
		# Flat single-color particles read as tinted balls, not fire -- real
		# flame is hottest (yellow-white) at its base and cools to orange
		# then deep red as it rises, so each particle shifts through that
		# same range over its own lifetime instead of staying one color.
		# Just a minor accent around the orb now -- the main flame look is
		# the sphere's own surface shader (school_surface.gdshader's
		# tone_color/tone_strength), not these particles.
		"color_ramp": [Color(1.0, 0.98, 0.82), Color(0.85, 0.38, 0.04), Color(0.75, 0.12, 0.05)],
	},
	Constants.DamageType.FROST: {
		# Snowflakes: fall straight down (not the omnidirectional drift every
		# other school uses), a little gravity to reinforce the fall, and
		# tinted white via "particle_color" -- NOT Constants.SCHOOL_COLORS'
		# blue, which is what the sphere's own surface uses instead (see
		# combat_utils.gd's FROST shader preset).
		"direction": Vector3(0, -1, 0), "spread": 25.0, "gravity": Vector3(0, -0.4, 0),
		"velocity": 0.15, "lifetime": 1.2, "amount": 8,
		"particle_color": Color(1.0, 1.0, 1.0),
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

# Trail is a hand-built ribbon mesh, NOT GPUParticles3D's `trail_enabled`
# feature -- that was tried twice (once misconfigured, once missing a
# required material flag) and even fixed correctly it's a finicky,
# sparsely-documented system to get an exact look out of. A tapered strip
# rebuilt from this node's own recent position history is simple, fully
# within our control, and is genuinely how this effect works in mobile games
# like Archero: a short streak mesh trailing the orbiting object, tapering to
# nothing at the tail.
const TRAIL_LIFETIME: float = 0.55  # how far back the tail's history reaches, seconds
# Sampled/rebuilt on a timer, NOT every physics frame (60Hz) -- this is the
# only per-instance work that runs continuously for the whole lifetime of
# every spell object on screen, so it's the one place worth being deliberate
# about cost on a phone. 12Hz is still smooth for a fading streak (the eye
# doesn't need 60 unique trail segments/sec to read as a continuous curve)
# and cuts the mesh-rebuild rate -- and the point/vertex count for the same
# TRAIL_LIFETIME -- to a fifth of doing this every physics tick.
const TRAIL_UPDATE_INTERVAL: float = 1.0 / 12.0

static var _particle_textures: Dictionary = {}  # shape name -> ImageTexture
static var _color_ramps: Dictionary = {}  # Constants.DamageType -> GradientTexture1D

var _damage_type: int = -1
var _aura: GPUParticles3D
var _reserved_particles: int = 0

var _trail_mesh: MeshInstance3D
var _trail_width: float = 0.1
var _trail_positions: Array[Vector3] = []
var _trail_ages: Array[float] = []
var _trail_elapsed: float = 0.0
var _trail_update_timer: float = 0.0


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

	# Mesh radius drives both the aura's emission-sphere size (so particles
	# spawn spread across the WHOLE surface, not from one point at the
	# origin -- that single-point-at-center emission was the old "too little
	# and invisible, only ever looks like it's on top" problem, since a
	# narrow directional cone from a point reads as a jet, not a coat of
	# flame around a sphere) and the particle/ribbon sizes, so this component
	# scales sanely whether it's dressing a small bolt or a bigger orb
	# instead of hardcoding an orb-specific size.
	var mesh_radius := _get_mesh_radius(meshes)

	var preset: Dictionary = PRESETS.get(damage_type, PRESETS[Constants.DamageType.VOID])
	_aura = _build_particles(preset.amount, preset.lifetime, preset, mesh_radius)
	_build_trail(mesh_radius)

	if CombatUtils.try_reserve_particles(preset.amount):
		_reserved_particles = preset.amount
		_aura.emitting = true
	# else: shader dressing above still applies -- only the particle
	# dressing is skipped when the global budget is already spent. The trail
	# mesh isn't a GPUParticles3D and doesn't draw from this budget -- it's
	# one small hand-built mesh, not a particle count.


## Rough world-space radius of the dressed mesh(es), used to size the aura's
## emission sphere and the particle/ribbon dimensions proportionally.
## Average-axis approximation (not exact for non-uniform scale) -- plenty
## precise for sizing ambient VFX, not a collision check.
func _get_mesh_radius(meshes: Array) -> float:
	var radius := 0.0
	for mi in meshes:
		var mesh_inst := mi as MeshInstance3D
		var size: Vector3 = mesh_inst.get_aabb().size
		# Half the longest single axis, NOT half the AABB diagonal -- for a
		# roughly spherical mesh (every current archetype), the diagonal
		# overshoots the true radius by ~1.7x (sqrt(3) for a cube-ish AABB),
		# which pushed the aura's emission sphere visibly outside the mesh.
		var local_radius: float = maxf(size.x, maxf(size.y, size.z)) * 0.5
		var s: Vector3 = mesh_inst.global_transform.basis.get_scale()
		var avg_scale: float = (s.x + s.y + s.z) / 3.0
		radius = maxf(radius, local_radius * avg_scale)
	return maxf(radius, 0.05)


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
	if _trail_mesh != null:
		remove_child(_trail_mesh)
		_trail_mesh.queue_free()
		_trail_mesh = null
	_trail_positions.clear()
	_trail_ages.clear()
	_trail_elapsed = 0.0


## Ambient aura: particles spawn spread across the mesh's whole surface
## (EMISSION_SHAPE_SPHERE_SURFACE) instead of a single point at the origin,
## so the look wraps all the way around the mesh -- including the underside
## -- rather than jetting from one spot.
func _build_particles(amount: int, lifetime: float, preset: Dictionary, mesh_radius: float) -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.name = "Aura"
	p.amount = amount
	p.lifetime = lifetime
	p.one_shot = false
	p.emitting = false  # gated on the budget check in configure()
	p.local_coords = true  # aura follows the mesh; particles emitted from and drifting relative to it

	var quad := QuadMesh.new()
	var particle_size: float = clampf(mesh_radius * 0.5, 0.04, 0.4)
	quad.size = Vector2(particle_size, particle_size)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	mat.albedo_texture = _get_particle_texture(preset.get("shape", "circle"))
	# Required for ParticleProcessMaterial's per-particle `color`/`color_ramp`
	# to actually reach the rendered pixel at all -- without this the particle
	# instance color is computed but never multiplied into ALBEDO, so every
	# particle silently renders as the flat mat.albedo_color below regardless
	# of what the process material says (Godot docs, ParticleProcessMaterial).
	mat.vertex_color_use_as_albedo = true
	mat.albedo_color = Color.WHITE  # neutral -- actual tint comes from proc.color/color_ramp below
	# "particle_color" lets a school's particle dressing use a different tint
	# than its own surface (e.g. Frost: white snowflakes over a blue/white
	# sphere, not blue-on-blue) -- falls back to the usual school color.
	var color: Color = preset.get("particle_color", CombatUtils.get_damage_color(_damage_type))
	mat.emission_enabled = true
	mat.emission = color
	# Emission doesn't pick up the per-particle color_ramp (that's an ALBEDO-
	# only mechanic here) -- a strong flat-orange glow added on top of every
	# particle would wash the yellow/red variation back out, so multi-tone
	# schools get a softer glow and let ALBEDO's gradient carry the look.
	mat.emission_energy_multiplier = 1.1 if preset.has("color_ramp") else 2.0
	quad.material = mat
	p.draw_pass_1 = quad

	var proc := ParticleProcessMaterial.new()
	proc.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE_SURFACE
	proc.emission_sphere_radius = mesh_radius
	proc.direction = preset.direction
	proc.spread = preset.spread
	proc.gravity = preset.gravity
	proc.initial_velocity_min = preset.velocity * 0.7
	proc.initial_velocity_max = preset.velocity
	proc.scale_min = 0.6
	proc.scale_max = 1.2
	# Multi-tone schools (currently just Fire) shift color over each
	# particle's own lifetime via a gradient instead of staying one flat
	# tint; proc.color stays white so the ramp isn't multiplied/darkened.
	if preset.has("color_ramp"):
		proc.color_ramp = _get_color_ramp(_damage_type, preset.color_ramp)
		proc.color = Color.WHITE
	else:
		proc.color = color
	p.process_material = proc

	add_child(p)
	return p


## Sets up the trail's MeshInstance3D + material once; the actual ribbon
## geometry is rebuilt every physics frame by `_physics_process()` from this
## node's own recorded position history. `top_level = true` detaches it from
## inheriting this node's (moving) transform -- the mesh's own transform
## stays at world-space identity, so vertices can be written directly in
## world-space coordinates from `_trail_positions` without having to
## re-derive them relative to a parent that's moved since they were recorded.
func _build_trail(mesh_radius: float) -> void:
	var mesh_inst := MeshInstance3D.new()
	mesh_inst.name = "Trail"
	mesh_inst.top_level = true
	mesh_inst.global_transform = Transform3D.IDENTITY

	var color := CombatUtils.get_damage_color(_damage_type)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.vertex_color_use_as_albedo = true  # per-vertex alpha is how the tail fades out
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 2.0
	mesh_inst.material_override = mat

	add_child(mesh_inst)
	_trail_mesh = mesh_inst
	_trail_width = clampf(mesh_radius * 0.6, 0.03, 0.3)
	_trail_positions.clear()
	_trail_ages.clear()
	_trail_elapsed = 0.0


## Records this node's current world position on a throttled timer
## (TRAIL_UPDATE_INTERVAL, not every physics frame), drops anything older
## than TRAIL_LIFETIME, and rebuilds the trail as a flat triangle-strip
## ribbon connecting the remaining points -- newest end at full
## width/opacity, tapering to nothing at the oldest end. Runs in-editor too
## (tool script), same as the rest of this component's preview support;
## harmless when stationary since duplicate points at the same spot just
## collapse to a zero-length sliver.
func _physics_process(delta: float) -> void:
	if _trail_mesh == null:
		return
	_trail_update_timer += delta
	if _trail_update_timer < TRAIL_UPDATE_INTERVAL:
		return
	_trail_elapsed += _trail_update_timer
	_trail_update_timer = 0.0
	_trail_positions.push_front(global_position)
	_trail_ages.push_front(_trail_elapsed)
	while _trail_ages.size() > 2 and _trail_elapsed - _trail_ages[-1] > TRAIL_LIFETIME:
		_trail_ages.pop_back()
		_trail_positions.pop_back()

	var n := _trail_positions.size()
	if n < 2:
		_trail_mesh.mesh = null
		return

	var verts := PackedVector3Array()
	var colors := PackedColorArray()
	var color := CombatUtils.get_damage_color(_damage_type)
	for i in n:
		var pos: Vector3 = _trail_positions[i]
		var age: float = _trail_elapsed - _trail_ages[i]
		var t: float = clampf(age / TRAIL_LIFETIME, 0.0, 1.0)  # 0 = newest, 1 = oldest
		# Direction along the ribbon at this point, from a neighbour --
		# whichever neighbour exists (points are newest-first).
		var neighbor: Vector3 = _trail_positions[i + 1] if i + 1 < n else _trail_positions[i - 1]
		var along: Vector3 = pos - neighbor if i + 1 < n else neighbor - pos
		if along.length_squared() < 0.0001:
			along = Vector3.FORWARD
		# Flat, ground-parallel ribbon (cross with world UP) -- this project's
		# camera is a fixed angle (project.md), so a horizontally-flat strip
		# reads correctly without needing true per-frame camera-facing math.
		var side: Vector3 = along.normalized().cross(Vector3.UP)
		if side.length_squared() < 0.0001:
			side = Vector3.RIGHT
		side = side.normalized() * (_trail_width * 0.5 * (1.0 - t))
		var c := color
		c.a = 1.0 - t
		verts.append(pos + side)
		colors.append(c)
		verts.append(pos - side)
		colors.append(c)

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_COLOR] = colors
	var arr_mesh := ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
	_trail_mesh.mesh = arr_mesh


## Small procedural billboard mask, cached per shape and shared across every
## instance/school that uses it (color comes from the material/color_ramp,
## not the texture) -- same "generate, don't depend on art" approach as
## `bar_texture.gd`, so this needs no PNG asset.
## "circle": soft round dot, the default look for most schools.
## "flicker": irregular jagged-edged blob instead of a clean circle -- reads
## as an organic flame lick rather than a uniform ball, from any rotation
## (the wobble is purely radial/per-angle, so there's no fixed up/down
## orientation a billboard could render wrong side up).
static func _get_particle_texture(shape: String = "circle") -> ImageTexture:
	if not _particle_textures.has(shape):
		const SIZE := 16
		var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
		var center := Vector2(SIZE - 1, SIZE - 1) * 0.5
		for y in SIZE:
			for x in SIZE:
				var p := Vector2(x, y) - center
				var d := p.length() / (SIZE * 0.5)
				if shape == "flicker":
					var angle := p.angle()
					var wobble := 0.18 * sin(angle * 5.0) + 0.12 * sin(angle * 9.0 + 1.7)
					d /= (1.0 + wobble)
				var a := clampf(1.0 - d, 0.0, 1.0)
				a *= a
				img.set_pixel(x, y, Color(1.0, 1.0, 1.0, a))
		_particle_textures[shape] = ImageTexture.create_from_image(img)
	return _particle_textures[shape]


## Cached per-school Gradient, used by multi-tone presets (PRESETS[...].
## color_ramp) so ParticleProcessMaterial.color_ramp shifts a particle's
## color across its own lifetime instead of staying one flat tint.
static func _get_color_ramp(damage_type: int, stops: Array) -> GradientTexture1D:
	if not _color_ramps.has(damage_type):
		var gradient := Gradient.new()
		gradient.colors = PackedColorArray(stops)
		var offsets := PackedFloat32Array()
		for i in stops.size():
			offsets.append(float(i) / float(stops.size() - 1))
		gradient.offsets = offsets
		var tex := GradientTexture1D.new()
		tex.gradient = gradient
		_color_ramps[damage_type] = tex
	return _color_ramps[damage_type]


func _exit_tree() -> void:
	if _reserved_particles > 0:
		CombatUtils.release_particles(_reserved_particles)
		_reserved_particles = 0
	# Note: does NOT call _teardown_particles() -- remove_child() during
	# _exit_tree() (the tree is already being torn down) is unnecessary and
	# queue_free() alone is enough for genuine destruction, unlike the
	# same-frame-rebuild case _teardown_particles() exists for.
