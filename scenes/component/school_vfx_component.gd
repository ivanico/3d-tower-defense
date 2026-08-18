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
		# "direction_follows_travel": a moving projectile (Standard/Chain/Line
		# AoE Bolt -- see `_configure_school_vfx()` callers) passes its own
		# world-space backward vector into `configure()`; when it does, THIS
		# axis is swapped in for both `direction` and `gravity` above (same
		# magnitude, new heading, just converted to this node's own local
		# frame -- see `_build_particles()`'s doc comment) so the flame reads
		# as leaning backward off the mesh, continuously re-wrapping its live
		# position as it flies, instead of licking straight up. A stationary
		# Orb never passes that vector, so it keeps the plain "licks upward"
		# look above unchanged. Generic opt-in preset key, same pattern as
		# "has_ring"/
		# "no_aura" -- not Fire-specific machinery.
		"direction_follows_travel": true,
		# Opt-in second, SEPARATE particle system (see `_build_trail_particles()`)
		# -- deliberately world-space, unlike the always-glued aura above, so
		# it's the one place particles genuinely get left behind at old
		# positions as the bolt flies, scattering back along the ribbon trail
		# like embers falling off. 0/absent (every other school) skips it
		# entirely. Smaller amount than the aura's own 16 -- an accent
		# scattered along the whole trail, not a second full coat.
		"trail_amount": 6,
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
		# Trail particles (see PRESETS' comment on Fire's own "trail_amount",
		# and `_build_trail_particles()`) -- NOT travel-biased like Fire's
		# (no "direction_follows_travel" here), so they just fall straight
		# down same as the aura's own "direction"/"gravity" above -- snow
		# left scattered behind along the ribbon trail as the bolt flies.
		"trail_amount": 4,
	},
	Constants.DamageType.VOID: {
		"direction": Vector3(0, 0.3, 0), "spread": 60.0, "gravity": Vector3.ZERO,
		"velocity": 0.1, "lifetime": 1.5, "amount": 6,
		# Black hole accretion disk -- see _build_ring(). Generic optional
		# preset key (not Void-specific code), same pattern as "color_ramp"/
		# "particle_color" above.
		"has_ring": true,
		# No ambient aura for Void -- a black hole doesn't shed particles off
		# its own surface; the ring below is its only ambient dressing.
		"no_aura": true,
	},
	Constants.DamageType.POISON: {
		"direction": Vector3(0, 1, 0), "spread": 15.0, "gravity": Vector3(0, 0.3, 0),
		"velocity": 0.25, "lifetime": 0.9, "amount": 8,
		# Darker green -- must match combat_utils.gd's
		# SCHOOL_SHADER_PRESETS[POISON].tone_color (the sphere's own rim
		# color) exactly; the two dicts are separate files/architectures on
		# purpose (see this file's own top doc comment), so this is
		# authored twice deliberately, not shared via a helper.
		"particle_color": Color(0.1, 0.3, 0.06),
		# Spawns only from the upper hemisphere (Y >= 0 in local space,
		# never below the sphere's own equator) instead of wrapping the
		# whole surface like Fire/every other school -- see
		# _hemisphere_points() and its use in _build_particles().
		"emission_top_only": true,
		# Trail particles (see PRESETS' comment on Fire's own "trail_amount",
		# and `_build_trail_particles()`) -- NOT travel-biased like Fire's
		# (no "direction_follows_travel" here), so they just drift straight
		# up same as the aura's own "direction"/"gravity" above -- motes
		# left scattered behind along the ribbon trail as the bolt flies.
		"trail_amount": 4,
	},
	Constants.DamageType.NATURE: {
		"direction": Vector3(0, 0.4, 0), "spread": 40.0, "gravity": Vector3(0, -0.1, 0),
		"velocity": 0.2, "lifetime": 1.0, "amount": 8,
		# No ambient aura -- same "no_aura" opt-out as Void, per feedback
		# that the drifting particle dressing reads as "things coming out
		# of the orb" and isn't wanted here either. Independent of
		# "trail_amount" below -- see `configure()`'s own comment on why
		# "no_aura" only ever gates the wrap-coat, not the trail.
		"no_aura": true,
		# Trail particles (see PRESETS' comment on Fire's own "trail_amount")
		# -- NOT travel-biased (no "direction_follows_travel" here), so they
		# reuse this preset's own "direction"/"gravity" above, same as
		# Poison/Frost's trails do. "shape": "leaf" -- solid leaf silhouette
		# (see `_get_particle_texture()`'s own doc comment), deliberately
		# NOT the soft glowing dot every other school's particles use, per
		# feedback. "tumbles" spins each leaf randomly (see this file's
		# other particle-builders) so they read as leaves caught in the
		# bolt's wake, not a uniform stream of identical glyphs.
		"trail_amount": 5, "shape": "leaf", "tumbles": true,
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
var _trail_particles: GPUParticles3D
var _reserved_particles: int = 0

var _trail_mesh: MeshInstance3D
var _trail_width: float = 0.1
var _trail_positions: Array[Vector3] = []
var _trail_ages: Array[float] = []
var _trail_elapsed: float = 0.0
var _trail_update_timer: float = 0.0

var _ring_mesh: MeshInstance3D
const RING_SPIN_SPEED: float = 0.3  # radians/sec, local Y -- subtle, not a spinning top

# Void's stand-in for the accretion disk when `allow_ring` is false -- see
# `_build_sonic_rings()`'s own doc comment. A SINGLE ring now, attached right
# at the bolt's own tail -- an earlier version built a second, bigger ring
# right at the bolt's own nose too, removed per feedback: it wasn't
# noticeable in actual play.
var _sonic_ring: MeshInstance3D = null
# Bumped up from the old (removed) pair's fainter back-ring alpha of 0.5 --
# it used to be the fainter of two, now it's the only ring doing the job,
# so it needs to carry a bit more presence on its own.
const SONIC_RING_ALPHA: float = 0.6
# Darker than `CombatUtils.get_damage_color()`'s bright purple (what the
# Orb's own accretion disk uses, via `_build_ring()`) -- per feedback, this
# ring reads better in the near-black "event horizon" shade instead. Exact
# match for combat_utils.gd's SCHOOL_SHADER_PRESETS[VOID].albedo_color --
# authored twice deliberately, not shared via a helper, same pattern as
# PRESETS[POISON]'s own "particle_color" above (this file and that shader-
# preset builder are separate files/architectures on purpose -- see this
# file's own top doc comment). Hardcoded (not read from `_damage_type`)
# since `_build_sonic_rings()` is only ever reached by a `has_ring` school,
# currently just Void.
const SONIC_RING_COLOR: Color = Color(0.05, 0.01, 0.09)
# Tunable sizing/spacing, overridable per-archetype (see `configure()`'s own
# `sonic_ring_tuning` doc comment) -- these are the DEFAULTS, i.e. what
# Line AoE Bolt gets since it doesn't pass an override. Standard Bolt passes
# its own tuned dictionary instead, so retuning one never silently drags
# the other along with it (they're two different mesh shapes/sizes, so one
# shared set of numbers was never going to suit both). "offset_scale": 1.0
# sits the ring exactly at the mesh's own tail face (no gap), same "touches
# the silhouette" idea `_build_ring()` uses for the Orb's disk.
const SONIC_RING_DEFAULT_TUNING: Dictionary = {
	"radius_scale": 0.5, "outer_scale": 1.6, "offset_scale": 1.0,
}


## `search_root` is optional -- auto-discovers the parent's own subtree the
## same way `hit_flash_component.gd` does, if not given explicitly. Applies
## the elemental shader to EVERY `MeshInstance3D` under it (a model can have
## more than one), but only builds the particle dressing once regardless of
## mesh count -- callers looping over their model's meshes to set a material
## (the old `CombatUtils.get_school_material()` pattern) should call this
## ONCE with the model root, not once per mesh.
## `allow_ring` gates WHICH ring-style dressing a `has_ring` school (Void)
## gets, not whether it gets one at all -- Orb of the Void keeps the rigid
## accretion disk (a persistent orbiting body reads as a black hole), but
## every other archetype passes false and gets `_build_sonic_rings()`
## instead (a flying/bouncing/piercing Void object doesn't drag a spinning
## disk behind it, but per feedback it shouldn't get NOTHING either -- see
## that function's own doc comment). The preset itself stays shared across
## every archetype (see the file-level doc comment) -- this is a
## per-*call* override, not a per-school one.
## `backward_direction_world` is the same kind of per-*call* override as
## `allow_ring` -- a plain WORLD-space "opposite of travel" vector (see
## `spell_projectile_base.gd`'s callers: every archetype just negates its
## own already-known travel vector, no local-space conversion needed on
## their end -- `_build_particles()` converts it to this node's own local
## frame once it gets there). Left at the `Vector3.ZERO` sentinel by Orb,
## which has no travel direction to speak of -- only presets opting in via
## "direction_follows_travel" (currently just Fire) ever look at this
## value at all.
## `ring_filled` -- per-*call* override, same pattern -- false (default)
## keeps `_build_ring()`'s donut-shaped accretion disk (Orb: a black hole's
## own hole in the middle IS the point of that look). Chain Bolt passes
## true instead -- per feedback its ring should be a solid filled disc, no
## hole. Only meaningful when `allow_ring` is also true (Orb/Chain Bolt) --
## ignored otherwise (`_build_sonic_rings()`'s ring is always a fixed-hole
## annulus, not configurable via this param).
## `sonic_ring_tuning` -- per-*call* override for `_build_sonic_rings()`'s
## sizing/spacing (see `SONIC_RING_DEFAULT_TUNING`'s own comment on why this
## is per-archetype, not per-school) -- empty dict (default, Line AoE Bolt)
## keeps the original numbers; Standard Bolt passes its own tuned dict.
## Only meaningful when `allow_ring` is false (the sonic-rings path).
func configure(damage_type: int, search_root: Node3D = null, allow_ring: bool = true, backward_direction_world: Vector3 = Vector3.ZERO, ring_filled: bool = false, sonic_ring_tuning: Dictionary = {}) -> void:
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

	# Mesh radius drives the aura's emission-sphere size (so particles spawn
	# spread across the WHOLE surface, not from one point at the origin --
	# that single-point-at-center emission was the old "too little and
	# invisible, only ever looks like it's on top" problem, since a narrow
	# directional cone from a point reads as a jet, not a coat of flame
	# around a sphere) and the particle sizes, so this component scales
	# sanely whether it's dressing a small bolt or a bigger orb instead of
	# hardcoding an orb-specific size.
	var mesh_radius := _get_mesh_radius(meshes)
	# This node's own local-frame AABB (not just `mesh_radius`, a single
	# scalar collapsed from the longest axis) -- see `_get_mesh_local_aabb()`'s
	# own doc comment for why a rotation-and-offset-aware box is required.
	# Always computed now (not just for the box-emission particle path) --
	# the trail's own starting width below is driven by this mesh's real X
	# extent, same generic mechanism, no per-archetype special-casing.
	var mesh_aabb := _get_mesh_local_aabb(meshes)

	var preset: Dictionary = PRESETS.get(damage_type, PRESETS[Constants.DamageType.VOID])
	_build_trail(mesh_aabb.size.x)
	if preset.get("has_ring", false):
		if allow_ring:
			_build_ring(mesh_radius, ring_filled)
		else:
			_build_sonic_rings(mesh_aabb, sonic_ring_tuning)

	var trail_amount: int = preset.get("trail_amount", 0)

	# "no_aura" opts a school out of the ambient WRAP-COAT dressing
	# specifically (e.g. Void -- a black hole doesn't shed particles, the
	# ring is its own ambient effect; Nature -- per feedback the drifting
	# coat reads as "things coming out of the orb"). Deliberately does NOT
	# gate "trail_amount" below -- Nature keeps "no_aura" but still wants
	# its own trailing leaves, so the two are independent.
	if not preset.get("no_aura", false):
		_aura = _build_particles(preset.amount, preset.lifetime, preset, mesh_radius, mesh_aabb, backward_direction_world)
		if CombatUtils.try_reserve_particles(preset.amount):
			_reserved_particles = preset.amount
			_aura.emitting = true
	# "trail_amount" -- see PRESETS' own comment on Fire's/Poison's/Frost's/
	# Nature's keys -- a second, separate, deliberately world-space system,
	# layered ON TOP of the wrap-coat above when that's also present, so
	# particles actually get left behind along the ribbon trail. Doesn't
	# require `backward_direction_world` itself -- only the travel-biased
	# schools (Fire) need that, `_build_trail_particles()` falls back to the
	# preset's own direction/gravity otherwise (Poison/Frost/Nature).
	# Reserved/emitted independently of the wrap-coat's own reservation --
	# either can degrade under budget pressure without taking the other down.
	if trail_amount > 0:
		_trail_particles = _build_trail_particles(trail_amount, preset.lifetime, preset, mesh_radius, mesh_aabb, backward_direction_world)
		if CombatUtils.try_reserve_particles(trail_amount):
			_reserved_particles += trail_amount
			_trail_particles.emitting = true
	# else (both skipped): shader dressing above still applies -- only the
	# particle dressing is skipped when the global budget is already spent.
	# The trail mesh isn't a GPUParticles3D and doesn't draw from this
	# budget -- it's one small hand-built mesh, not a particle count.


## Public entry point for a caller to fully tear down this component's VFX
## OUTSIDE of a normal `configure()` cycle -- specifically, "this spell
## object was just pool-released (hidden), not necessarily about to be
## reused" (see `spell_projectile_base.gd`'s `_on_pool_released()`).
## Without this, a hidden-but-still-pooled instance's `GPUParticles3D`
## children keep `emitting = true` and keep being simulated even though
## `visible = false` (set by `ObjectPool.release()`) already stops them
## from being DRAWN -- wasted GPU work, for particles nobody sees, for
## however long the instance then sits idle in the pool before its next
## shot. Just calls the exact same teardown `configure()` already runs
## before every rebuild -- this is that teardown with no rebuild after.
func stop() -> void:
	_teardown_particles()


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


## Bounding box of the dressed mesh(es), expressed in THIS node's own local
## frame -- unlike `_get_mesh_radius()` above (a single scalar, immune to
## rotation), a box-shaped emission volume needs correctly-ORIENTED axes,
## and every bolt archetype's `Model` child carries an extra local rotation
## (`model_rotation_degrees`) that `SchoolVFXComponent` -- a sibling of
## `Model`, not its parent -- never inherits. Reading `get_aabb().size`
## straight off the mesh and using those numbers as if they were already
## this node's own X/Y/Z (the previous version of this function) silently
## swaps/misaims axes whenever that rotation is nonzero, i.e. on every
## current archetype -- the box ends up shaped for the mesh's UNROTATED
## orientation, floating off to the side of the actual (rotated) mesh
## instead of wrapping it. Transforming each corner of the mesh's own AABB
## through `self.global_transform.affine_inverse() * mesh_inst.global_transform`
## bakes in that relative rotation -- and any off-center mesh origin, since
## corners are used directly instead of assuming the mesh is centered on
## its own local (0,0,0) -- before measuring the result, so the box comes
## out correctly shaped AND positioned regardless of how the mesh sits
## relative to this node.
func _get_mesh_local_aabb(meshes: Array) -> AABB:
	var to_self := global_transform.affine_inverse()
	var result := AABB()
	var first := true
	for mi in meshes:
		var mesh_inst := mi as MeshInstance3D
		var mesh_to_self := to_self * mesh_inst.global_transform
		var aabb: AABB = mesh_inst.get_aabb()
		for corner_idx in 8:
			var corner := aabb.position + Vector3(
				aabb.size.x * float(corner_idx & 1),
				aabb.size.y * float((corner_idx >> 1) & 1),
				aabb.size.z * float((corner_idx >> 2) & 1))
			var local_corner: Vector3 = mesh_to_self * corner
			if first:
				result = AABB(local_corner, Vector3.ZERO)
				first = false
			else:
				result = result.expand(local_corner)
	return result


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
	if _trail_particles != null:
		remove_child(_trail_particles)
		_trail_particles.queue_free()
		_trail_particles = null
	if _trail_mesh != null:
		remove_child(_trail_mesh)
		_trail_mesh.queue_free()
		_trail_mesh = null
	if _ring_mesh != null:
		remove_child(_ring_mesh)
		_ring_mesh.queue_free()
		_ring_mesh = null
	if _sonic_ring != null:
		remove_child(_sonic_ring)
		_sonic_ring.queue_free()
		_sonic_ring = null
	_trail_positions.clear()
	_trail_ages.clear()
	_trail_elapsed = 0.0


## Spawn points confined to a sphere's upper hemisphere (Y >= 0 in local
## space), for EMISSION_SHAPE_POINTS -- used by "emission_top_only" schools
## (currently just Poison) so their ambient particles never appear below
## the sphere's own equator. Samples a uniform random direction on the
## FULL sphere, then flips the sign of Y whenever it's negative: folding a
## symmetric full-sphere sample onto its upper half like this preserves a
## correct, evenly-spread distribution with no rejection-sampling loop
## needed, and guarantees every resulting point has y >= 0.
static func _hemisphere_points(radius: float, count: int = 24) -> PackedVector3Array:
	var points := PackedVector3Array()
	for i in count:
		var dir := Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
		if dir.y < 0.0:
			dir.y = -dir.y
		points.append(dir * radius)
	return points


## GPU-processed ParticleProcessMaterial (unlike CPUParticles3D) has no
## direct PackedVector3Array property for EMISSION_SHAPE_POINTS -- point
## positions must be encoded into a texture instead (`emission_point_texture`,
## one point per pixel, read back on the GPU), same technique the editor's
## own "Load Emission Points" mesh-to-particles tool uses internally.
static func _points_to_texture(points: PackedVector3Array) -> ImageTexture:
	var img := Image.create(points.size(), 1, false, Image.FORMAT_RGBF)
	for i in points.size():
		var p := points[i]
		img.set_pixel(i, 0, Color(p.x, p.y, p.z))
	return ImageTexture.create_from_image(img)


## Ambient aura: particles spawn spread across the mesh's whole surface
## (EMISSION_SHAPE_SPHERE_SURFACE) instead of a single point at the origin,
## so the look wraps all the way around the mesh -- including the underside
## -- rather than jetting from one spot.
##
## `local_coords = true` (always, below) rigidly ties every particle to the
## node's CURRENT transform every frame -- this is what makes the aura read
## as a coat continuously wrapping the mesh, moving with it, instead of a
## discrete trail of puffs left behind in world space (that was tried --
## `local_coords = false` -- and rejected: at this project's bolt speeds
## the mesh outruns its own particles almost immediately, so only 1-2 stray
## particles are ever near the mesh at once, and Godot's particle
## `visibility_aabb` doesn't grow to cover a fast-moving emitter's world-
## space trail either, both compounding into a sparse, mostly-invisible
## result -- nothing like a firebolt). A school opting into
## "direction_follows_travel" still gets a backward-biased `direction`
## (see below), just applied in this node's own LOCAL frame every frame
## rather than baked into a single world-space snapshot at spawn -- the
## coat re-wraps the mesh's live position continuously, "leaning" back
## along the travel axis, same as Orb's plain "licks upward" but aimed
## opposite of travel instead of world-up.
func _build_particles(amount: int, lifetime: float, preset: Dictionary, mesh_radius: float, mesh_aabb: AABB = AABB(), backward_direction_world: Vector3 = Vector3.ZERO) -> GPUParticles3D:
	var follows_travel: bool = preset.get("direction_follows_travel", false) and backward_direction_world != Vector3.ZERO
	var p := GPUParticles3D.new()
	p.name = "Aura"
	p.amount = amount
	p.lifetime = lifetime
	p.one_shot = false
	p.emitting = false  # gated on the budget check in configure()
	p.local_coords = true  # see this function's own doc comment above

	# "particle_color" lets a school's particle dressing use a different tint
	# than its own surface (e.g. Frost: white snowflakes over a blue/white
	# sphere, not blue-on-blue) -- falls back to the usual school color.
	var color: Color = preset.get("particle_color", CombatUtils.get_damage_color(_damage_type))
	var particle_size: float = clampf(mesh_radius * 0.5, 0.04, 0.4)
	p.draw_pass_1 = _build_particle_quad(preset, particle_size, color)

	var proc := ParticleProcessMaterial.new()
	# "emission_top_only" confines spawn points to the upper hemisphere
	# (Poison) instead of the whole surface (every other school's default,
	# e.g. Fire's deliberate all-sides wrap) -- direction/spread/gravity
	# below are unaffected, so this only changes WHERE particles spawn, not
	# how they move afterward.
	if preset.get("emission_top_only", false):
		proc.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINTS
		var hemisphere_points := _hemisphere_points(mesh_radius)
		proc.emission_point_count = hemisphere_points.size()
		proc.emission_point_texture = _points_to_texture(hemisphere_points)
	elif follows_travel:
		# Box shaped to the mesh's own AABB, NOT `EMISSION_SHAPE_SPHERE_SURFACE`
		# with the single averaged `mesh_radius` the plain-Orb branch below
		# uses -- that scalar is half the mesh's LONGEST axis, so on a long
		# thin mesh (the Line AoE Bolt's ~2.4m lance) it wraps a sphere far
		# bigger than the mesh's actual width/height, spawning particles well
		# off to the sides where there's no real geometry ("particles coming
		# out of nothing"). A box sized to the real per-axis extents instead
		# spawns particles across the mesh's own true footprint -- nose,
		# tail, AND both side edges -- same "wraps the whole mesh" look the
		# plain branch has, just shaped correctly for a non-spherical mesh.
		# `emission_box_extents` alone is always centered on THIS node's own
		# local origin -- `mesh_aabb` (see `_get_mesh_local_aabb()`) already
		# accounts for the mesh possibly sitting off-center relative to that
		# origin, so `emission_shape_offset` recenters the box on the mesh's
		# actual middle instead of silently assuming the two coincide.
		proc.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		var box_extents: Vector3 = mesh_aabb.size * 0.5
		box_extents.x = maxf(box_extents.x, 0.05)
		box_extents.y = maxf(box_extents.y, 0.05)
		box_extents.z = maxf(box_extents.z, 0.05)
		proc.emission_box_extents = box_extents
		proc.emission_shape_offset = mesh_aabb.get_center()
	else:
		proc.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE_SURFACE
		proc.emission_sphere_radius = mesh_radius
	var launch_direction: Vector3 = preset.direction
	var launch_gravity: Vector3 = preset.gravity
	# Swap the authored "up" axis for the caller's backward vector, keeping
	# each value's own original magnitude (0.9 gravity strength, etc.) --
	# only the heading changes, so this reads as the same flame "kick," just
	# aimed behind the bolt instead of above it. The caller hands this in as
	# a plain WORLD-space vector (it's the simplest thing for every
	# archetype to compute -- just negate its own already-known travel
	# vector, no local-space math needed on that end), but `local_coords =
	# true` above means the process material's `direction`/`gravity` are
	# read in THIS node's own local frame -- `global_transform.basis`
	# converts world to local here, once, so every caller stays simple.
	if follows_travel:
		var backward_local: Vector3 = global_transform.basis.orthonormalized().inverse() * backward_direction_world
		backward_local = backward_local.normalized()
		launch_direction = backward_local
		launch_gravity = backward_local * preset.gravity.length()
	proc.direction = launch_direction
	proc.spread = preset.spread
	proc.gravity = launch_gravity
	proc.initial_velocity_min = preset.velocity * 0.7
	proc.initial_velocity_max = preset.velocity
	proc.scale_min = 0.6
	proc.scale_max = 1.2
	# "tumbles" -- generic preset key (currently only Nature's leaves) --
	# random initial billboard rotation plus a slow continuous spin, so
	# every particle doesn't render at the same fixed orientation. Harmless
	# no-op for round shapes (a rotated circle looks the same), but matters
	# for a directional shape like "leaf" -- without this every leaf would
	# point the same way, reading as a repeated glyph instead of debris.
	if preset.get("tumbles", false):
		proc.angle_min = 0.0
		proc.angle_max = 360.0
		proc.angular_velocity_min = -90.0
		proc.angular_velocity_max = 90.0
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


## Shared billboard-quad "look" (unshaded, alpha, glow) for any
## GPUParticles3D this component builds -- the always-glued aura above and
## the world-space trail particles below use the exact same visual
## dressing, just driven by different process materials (physics), so this
## is the one place that dressing is authored.
func _build_particle_quad(preset: Dictionary, particle_size: float, color: Color) -> QuadMesh:
	var quad := QuadMesh.new()
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
	mat.emission_enabled = true
	mat.emission = color
	# Emission doesn't pick up the per-particle color_ramp (that's an ALBEDO-
	# only mechanic here) -- a strong flat-orange glow added on top of every
	# particle would wash the yellow/red variation back out, so multi-tone
	# schools get a softer glow and let ALBEDO's gradient carry the look.
	mat.emission_energy_multiplier = 1.1 if preset.has("color_ramp") else 2.0
	quad.material = mat
	return quad


## Second, SEPARATE particle system, layered on top of the aura above, not
## a replacement for it -- see PRESETS' "trail_amount" comment for why:
## the aura is always `local_coords = true` (glued to the mesh, by design,
## see `_build_particles()`'s own doc comment), which by construction can
## never leave anything behind at an old position. This system is the one
## place that's actually wanted -- `local_coords = false`, so particles
## genuinely get left scattered along the ribbon trail as the bolt flies,
## reading as embers falling off, not just a coat around the mesh.
## Reuses the same mesh-footprint emission box as the aura's own
## "direction_follows_travel" branch (spawns across the real silhouette,
## not one point at the origin), just a smaller `amount`/particle size --
## an accent scattered along the trail, not a second full coat.
## Direction/gravity are world-space, used AS GIVEN, no local-frame
## conversion needed here (contrast `_build_particles()`'s own conversion,
## required only because ITS particles are local-space) -- but which
## values depend on the school: "direction_follows_travel" (Fire) biases
## backward off the caller's own travel vector plus an extra downward kick
## (embers falling off behind it); every other school with a "trail_amount"
## (Poison, Frost) has no travel bias at all -- it just reuses its own
## `direction`/`gravity` unchanged, the exact same up/down drift its aura
## already uses, just left behind in world space instead of staying glued
## to the mesh.
func _build_trail_particles(amount: int, lifetime: float, preset: Dictionary, mesh_radius: float, mesh_aabb: AABB, backward_direction_world: Vector3) -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.name = "TrailParticles"
	p.amount = amount
	p.lifetime = lifetime
	p.one_shot = false
	p.emitting = false  # gated on the budget check in configure()
	p.local_coords = false  # see this function's own doc comment above
	# `visibility_aabb` is a LOCAL-space box, re-transformed by this node's
	# CURRENT position every frame, that Godot uses to decide whether to
	# draw the system AT ALL -- it does not grow automatically. Godot's
	# small built-in default only covers particles that stay near the node,
	# which these deliberately don't once the bolt's flown a meter or two --
	# sized generously (this project's arena is ~40x57 units) rather than
	# tuned tightly to one archetype's speed.
	p.visibility_aabb = AABB(Vector3(-20, -20, -20), Vector3(40, 40, 40))

	var color: Color = preset.get("particle_color", CombatUtils.get_damage_color(_damage_type))
	var particle_size: float = clampf(mesh_radius * 0.35, 0.03, 0.25)
	p.draw_pass_1 = _build_particle_quad(preset, particle_size, color)

	var proc := ParticleProcessMaterial.new()
	proc.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	var box_extents: Vector3 = mesh_aabb.size * 0.5
	box_extents.x = maxf(box_extents.x, 0.05)
	box_extents.y = maxf(box_extents.y, 0.05)
	box_extents.z = maxf(box_extents.z, 0.05)
	proc.emission_box_extents = box_extents
	proc.emission_shape_offset = mesh_aabb.get_center()
	# See this function's own doc comment above -- Fire leans backward off
	# the caller's own travel vector (with an extra downward kick so it
	# reads as "falling off," not just "drifting straight back"); every
	# other school with a "trail_amount" just reuses its own preset
	# direction/gravity unchanged, same as its aura already does.
	if preset.get("direction_follows_travel", false) and backward_direction_world != Vector3.ZERO:
		var backward := backward_direction_world.normalized()
		proc.direction = backward
		proc.gravity = backward * preset.gravity.length() + Vector3(0, -1.0, 0)
	else:
		proc.direction = preset.direction
		proc.gravity = preset.gravity
	proc.spread = preset.spread
	proc.initial_velocity_min = preset.velocity * 0.5
	proc.initial_velocity_max = preset.velocity
	proc.scale_min = 0.5
	proc.scale_max = 1.0
	# See `_build_particles()`'s own comment on "tumbles" -- same generic key.
	if preset.get("tumbles", false):
		proc.angle_min = 0.0
		proc.angle_max = 360.0
		proc.angular_velocity_min = -90.0
		proc.angular_velocity_max = 90.0
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
## `mesh_width` is the dressed mesh's own real extent along this node's
## local X (see `configure()`'s `mesh_aabb`, computed via
## `_get_mesh_local_aabb()`) -- the ribbon STARTS at (approximately) that
## full width and tapers to nothing across `TRAIL_LIFETIME`, same taper as
## always (see `_rebuild_trail_mesh()`). Driven by the mesh's real geometry
## instead of a fixed/guessed fraction, so a wide mesh (Line AoE Bolt's
## lance) naturally gets a wide trail and a narrow mesh (Standard Bolt)
## naturally gets a narrow one -- no per-archetype special-casing needed.
func _build_trail(mesh_width: float) -> void:
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
	_trail_width = maxf(mesh_width, 0.03)
	_trail_positions.clear()
	_trail_ages.clear()
	_trail_elapsed = 0.0
	# Seed the spawn point immediately and pre-fill the throttle timer so the
	# very next _physics_process tick (~one physics frame, not a full
	# TRAIL_UPDATE_INTERVAL later) records the second point a trail needs
	# before it draws anything at all. Without this, a fast-moving
	# projectile fired at a close target can hit and despawn before its
	# first throttled sample (~0.083s) ever happens -- it would have 0-1
	# recorded points the entire time, so the trail never rendered, or only
	# "popped in" right as the hit landed. Steady-state sampling for
	# anything that survives past this first tick is unaffected, still
	# throttled at 12Hz same as always.
	_trail_positions.push_front(global_position)
	_trail_ages.push_front(0.0)
	_trail_update_timer = TRAIL_UPDATE_INTERVAL


## Shared annulus mesh builder -- used by both the Orb's rigid accretion
## disk (`_build_ring()`) and the bolt's own tail ring (`_build_sonic_rings()`)
## below. `basis_a`/`basis_b` are two perpendicular unit vectors spanning the
## ring's PLANE -- default (RIGHT, FORWARD) lies flat in local XZ
## (horizontal), the "fixed-camera-angle reads it as a tilted ellipse"
## shortcut `_build_ring()` uses for the stationary Orb (see that function's
## own doc comment). `_build_sonic_rings()` passes (RIGHT, UP) instead --
## normal along local FORWARD, perpendicular to travel, a hoop the bolt's
## tail sits inside of (see that function's own doc comment on why). `inner_
## alpha` lets a fainter ring start partway-faded at its own inner edge
## instead of fully opaque -- the outer edge always fades the rest of the
## way to 0 regardless, same per-vertex-alpha technique the trail uses.
static func _build_ring_mesh(inner_radius: float, outer_radius: float, color: Color, inner_alpha: float = 1.0, basis_a: Vector3 = Vector3.RIGHT, basis_b: Vector3 = Vector3.FORWARD) -> ArrayMesh:
	var segments := 32
	var verts := PackedVector3Array()
	var colors := PackedColorArray()
	var inner_color := color
	inner_color.a = inner_alpha
	var outer_color := color
	outer_color.a = 0.0
	for i in segments + 1:
		var angle: float = TAU * float(i) / float(segments)
		var dir := basis_a * cos(angle) + basis_b * sin(angle)
		verts.append(dir * inner_radius)
		colors.append(inner_color)
		verts.append(dir * outer_radius)
		colors.append(outer_color)

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_COLOR] = colors
	var arr_mesh := ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
	return arr_mesh


## Shared unshaded/emissive/alpha ring material -- same look for both
## `_build_ring()` and `_build_sonic_rings()`.
static func _build_ring_material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.vertex_color_use_as_albedo = true  # per-vertex alpha is how the outer edge fades out
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 2.0
	return mat


## Flat "accretion disk" ring encircling the mesh -- a real black hole's
## defining visual, and a fragment shader alone can't conjure geometry a
## mesh doesn't have (same reasoning the file-level doc comment above gives
## for particles+trail). Built once per configure(), gated on the
## "has_ring" preset key AND `allow_ring` (see `configure()`'s own doc
## comment on that param -- a flying/bouncing/piercing Void object gets
## `_build_sonic_rings()` below instead of this). Colored via
## CombatUtils.get_damage_color() -- the exact same bright color the
## sphere's own rim uses, by construction, not a separately-authored ring
## color. `filled` (see `configure()`'s own doc comment on `ring_filled`) --
## false keeps the donut/annulus shape (Orb: the hole IS the black hole),
## true collapses the inner edge to a solid disc instead (Chain Bolt).
func _build_ring(mesh_radius: float, filled: bool = false) -> void:
	var mesh_inst := MeshInstance3D.new()
	mesh_inst.name = "Ring"
	var color := CombatUtils.get_damage_color(_damage_type)
	# touches the sphere's own silhouette, no gap -- unless `filled`, which
	# collapses the inner edge to the center point instead.
	var inner_radius: float = 0.0 if filled else mesh_radius
	mesh_inst.mesh = _build_ring_mesh(inner_radius, mesh_radius * 2.0, color)
	mesh_inst.material_override = _build_ring_material(color)
	add_child(mesh_inst)
	_ring_mesh = mesh_inst


## Void's stand-in for the accretion disk when `allow_ring` is false -- a
## single ring attached right at the bolt's own tail. A PLAIN child (NOT
## `top_level`), unlike every other dressing this function's predecessor
## tried -- this node (`SchoolVFXComponent`) is already a normal child of
## the bolt root, which itself turns to face its travel direction every
## cast via `look_at()` (see standard_bolt.gd/line_aoe_bolt.gd's own
## `initialize()`). A plain child at a fixed LOCAL offset therefore rides
## along for free, position AND rotation, through Godot's ordinary
## parent-child transform propagation -- no per-frame code needed at all.
## Two earlier, more complicated versions were tried and dropped: one
## computed a fresh WORLD-space position every physics frame from a
## caller-supplied "backward" vector; another sourced it from this
## component's own recorded trail history (`_trail_positions`), which
## degenerates to sitting exactly ON the bolt for a stationary preview or a
## bolt that hasn't lived long enough to build up trail history yet (most
## of a fast bolt's short flight). Both were solving a problem that doesn't
## exist once the node is just a normal child.
##
## PERPENDICULAR to travel (`_build_ring_mesh()`'s RIGHT/UP basis, normal =
## local FORWARD) -- a hoop the bolt's own tail sits inside of, same "jet
## breaking the sound barrier" shockwave-ring look per feedback, not a flat
## disc lying under it.
##
## ANNULUS (a real hole in the middle, not a filled disc) -- per feedback,
## so it reads as a distinct ring shape instead of a solid blob.
##
## `mesh_aabb` (see `configure()`'s own comment on it) drives both the
## ring's radius (its cross-section perpendicular to travel -- X/Y extent,
## NOT `mesh_radius`'s longest-axis scalar, which is dominated by the
## mesh's LENGTH on an elongated shape like the Line AoE Bolt's lance and
## would leave the ring floating well outside the mesh's actual width) and
## its position (`offset_scale` in `tuning`, see `SONIC_RING_DEFAULT_TUNING`'s
## own comment, places it at the mesh's own back face by default).
func _build_sonic_rings(mesh_aabb: AABB, tuning: Dictionary = {}) -> void:
	var color := SONIC_RING_COLOR
	var radius_scale: float = tuning.get("radius_scale", SONIC_RING_DEFAULT_TUNING.radius_scale)
	var outer_scale: float = tuning.get("outer_scale", SONIC_RING_DEFAULT_TUNING.outer_scale)
	var offset_scale: float = tuning.get("offset_scale", SONIC_RING_DEFAULT_TUNING.offset_scale)
	# Half the mesh's actual width/height (perpendicular to travel), NOT
	# `mesh_radius` (half the LONGEST axis -- see doc comment above).
	# Floored so a degenerate/tiny mesh still gets a visible ring instead of
	# a zero-size one.
	var cross_radius: float = maxf(maxf(mesh_aabb.size.x, mesh_aabb.size.y) * radius_scale, 0.05)
	var outer_radius: float = cross_radius * outer_scale
	var inner_radius: float = outer_radius * 0.5  # the hole -- see doc comment above

	var mesh_inst := MeshInstance3D.new()
	mesh_inst.name = "SonicRing"
	mesh_inst.mesh = _build_ring_mesh(inner_radius, outer_radius, color, SONIC_RING_ALPHA, Vector3.RIGHT, Vector3.UP)
	mesh_inst.material_override = _build_ring_material(color)
	# Local offset behind the mesh's own tail -- forward is local -Z (Godot
	# convention, matches this node's own bolt-root parent's `look_at()`),
	# so "behind" is +Z. `mesh_aabb.get_center()` (not just the raw offset)
	# accounts for the mesh possibly sitting off-center relative to this
	# node's own local origin, same reasoning `_build_particles()`'s box
	# emission uses `mesh_aabb.get_center()` for its own offset.
	mesh_inst.position = mesh_aabb.get_center() + Vector3(0, 0, mesh_aabb.size.z * 0.5 * offset_scale)
	add_child(mesh_inst)
	_sonic_ring = mesh_inst


## Records this node's current world position on a throttled timer
## (TRAIL_UPDATE_INTERVAL, not every physics frame) to bound how fast
## `_trail_positions` grows, drops anything older than TRAIL_LIFETIME, then
## hands off to `_rebuild_trail_mesh()` -- which runs every physics frame,
## unthrottled, and always draws the ribbon's leading edge at THIS frame's
## live `global_position`, not just the last throttled sample. Runs in-
## editor too (tool script), same as the rest of this component's preview
## support; harmless when stationary since duplicate points at the same
## spot just collapse to a zero-length sliver.
##
## Rebuilding unthrottled looks expensive but isn't: TRAIL_UPDATE_INTERVAL
## still caps how many points EXIST (~6-7 for the default TRAIL_LIFETIME),
## so this is a tiny per-frame ArrayMesh rebuild from a short array, not a
## return to rebuilding from scratch on a growing history -- only the
## *sampling* rate (how often a new historical point is captured) stays
## throttled, not the *draw* rate.
func _physics_process(delta: float) -> void:
	if _ring_mesh != null:
		_ring_mesh.rotate_y(delta * RING_SPIN_SPEED)
	if _trail_mesh != null:
		_trail_update_timer += delta
		if _trail_update_timer >= TRAIL_UPDATE_INTERVAL:
			_trail_elapsed += _trail_update_timer
			_trail_update_timer = 0.0
			_trail_positions.push_front(global_position)
			_trail_ages.push_front(_trail_elapsed)
			while _trail_ages.size() > 2 and _trail_elapsed - _trail_ages[-1] > TRAIL_LIFETIME:
				_trail_ages.pop_back()
				_trail_positions.pop_back()
		_rebuild_trail_mesh()

## Rebuilds the trail as a flat triangle-strip ribbon -- newest end at full
## width/opacity, tapering to nothing at the oldest end. The very first
## point is always THIS frame's live position (age 0), not the last
## historical sample -- without this, the mesh only visibly moved once
## every TRAIL_UPDATE_INTERVAL (~0.083s) while the object it's attached to
## keeps moving every physics frame, so the ribbon's tip visibly lagged up
## to ~1+ meter behind a fast bolt (this project's bolts move at
## 14-16 m/s) -- it never looked attached to the thing it was trailing.
func _rebuild_trail_mesh() -> void:
	if _trail_positions.is_empty():
		_trail_mesh.mesh = null
		return
	var positions := _trail_positions.duplicate()
	positions.push_front(global_position)
	var n := positions.size()
	if n < 2:
		_trail_mesh.mesh = null
		return

	# Time elapsed as of THIS frame, including whatever's accumulated in
	# the not-yet-throttled partial interval -- keeps every historical
	# point's fade-out age correct even between samples.
	var current_elapsed := _trail_elapsed + _trail_update_timer
	var verts := PackedVector3Array()
	var colors := PackedColorArray()
	var color := CombatUtils.get_damage_color(_damage_type)
	for i in n:
		var pos: Vector3 = positions[i]
		# i==0 is always the live leading point seeded above -- always age 0
		# (full width/opacity), regardless of throttling.
		var age: float = 0.0 if i == 0 else current_elapsed - _trail_ages[i - 1]
		var t: float = clampf(age / TRAIL_LIFETIME, 0.0, 1.0)  # 0 = newest, 1 = oldest
		# Direction along the ribbon at this point, from a neighbour --
		# whichever neighbour exists (points are newest-first).
		var neighbor: Vector3 = positions[i + 1] if i + 1 < n else positions[i - 1]
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
## "leaf": solid, hard-edged pointed-oval (vesica -- two overlapping circles
## offset along Y) instead of "circle"/"flicker"'s soft glowing falloff --
## per feedback, Nature's trail wants "solid leafs, not particles like
## fire/poison/frost." Alpha ramps from 0 to 1 across a thin few-pixel band
## right at the true silhouette edge, not across the whole radius, so the
## interior reads as a flat filled shape rather than a glow.
static func _get_particle_texture(shape: String = "circle") -> ImageTexture:
	if not _particle_textures.has(shape):
		const SIZE := 16
		var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
		var center := Vector2(SIZE - 1, SIZE - 1) * 0.5
		for y in SIZE:
			for x in SIZE:
				var p := Vector2(x, y) - center
				var a: float
				if shape == "leaf":
					var px: float = p.x / (SIZE * 0.5) * 1.6  # narrower than tall
					var py: float = p.y / (SIZE * 0.5)
					var offset := 0.55
					var radius := 0.85
					var edge := 0.12
					var d1 := Vector2(px, py - offset).length()
					var d2 := Vector2(px, py + offset).length()
					a = clampf((radius - maxf(d1, d2)) / edge, 0.0, 1.0)
				else:
					var d := p.length() / (SIZE * 0.5)
					if shape == "flicker":
						var angle := p.angle()
						var wobble := 0.18 * sin(angle * 5.0) + 0.12 * sin(angle * 9.0 + 1.7)
						d /= (1.0 + wobble)
					a = clampf(1.0 - d, 0.0, 1.0)
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
