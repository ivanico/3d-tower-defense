@tool
extends TextureRect
class_name SpellIcon

## Shared rounded-corner spell/upgrade icon — a real icon texture if one
## resolves (SpellRegistry.get_card_icon), otherwise a flat block tinted to
## the spell's damage-school color, same as before. Extracted out of
## draft_card.gd so the draft cards and the HUD spell-stack row (or anything
## else that needs a spell icon) share this instead of each re-implementing
## icon lookup + the rounded-mask shader — see the project's "no duplicate
## code" rule.

const ICON_MASK_SHADER := preload("res://scenes/ui/draft_card_icon_mask.gdshader")

# Called via the preloaded SCRIPT, not the `SpellRegistry` autoload name —
# this is a @tool script, and a non-@tool autoload is a placeholder instance
# in editor context (calling it there throws "Attempt to call a method on a
# placeholder instance"). get_card_icon() is `static` and touches no
# autoload state, so resolving it through the script resource directly works
# in both the editor and real gameplay alike; going through the singleton
# node would only work at real runtime.
const SPELL_REGISTRY_SCRIPT := preload("res://autoloads/spell_registry.gd")

# One shared ShaderMaterial PER ICON SIZE — draft cards (150x150) and the HUD
# row (much smaller) both use this widget at very different sizes, so a
# single shared material would have every instance fight over one
# "rect_size" uniform (the same class of hot-reload bug this project already
# hit once with a similarly-shared material). Keying by size lets each
# distinct usage size share safely among just its own instances.
static var _mask_materials_by_size := {}

static var _flat_icon_tex: GradientTexture2D = null

func _ready() -> void:
	if Engine.is_editor_hint():
		# Always a fresh material in the editor — the shared cache exists to
		# avoid rebuilding this at runtime, but in the editor only the
		# FIRST-loaded instance of a given size would get a correctly-synced
		# rect_size otherwise.
		var mat := ShaderMaterial.new()
		mat.shader = ICON_MASK_SHADER
		material = mat
	resized.connect(_sync_mask_size)
	_sync_mask_size()

func _sync_mask_size() -> void:
	if Engine.is_editor_hint():
		if material:
			material.set_shader_parameter("rect_size", size)
	else:
		# Re-bucket on every resize (a no-op if size didn't change bucket) —
		# cheap, and keeps this instance on the material whose "rect_size"
		# uniform actually matches it instead of a stale one from before a
		# layout change.
		material = _get_mask_material(size)
		material.set_shader_parameter("rect_size", size)

static func _get_mask_material(for_size: Vector2) -> ShaderMaterial:
	var key := for_size
	if not _mask_materials_by_size.has(key):
		var mat := ShaderMaterial.new()
		mat.shader = ICON_MASK_SHADER
		_mask_materials_by_size[key] = mat
	return _mask_materials_by_size[key]

## Real gameplay: resolves the card's actual icon art if one exists
## (explicit .tres icon or the assets.md ID-convention lookup), otherwise
## falls back to a flat block tinted to the damage school (or neutral gray
## for stat upgrades, which have no damage_type).
func setup(card_data: Resource) -> void:
	var icon: Texture2D = SPELL_REGISTRY_SCRIPT.get_card_icon(card_data)
	var dtype = card_data.get("damage_type")
	if icon != null:
		texture = icon
		modulate = Color.WHITE
	else:
		texture = _get_flat_icon()
		modulate = CombatUtils.get_damage_color(dtype) if dtype != null else Color(0.75, 0.75, 0.75)

## Editor/stand-in preview: no card data to look up, just a flat block
## tinted to whatever color the caller wants shown.
func setup_preview(tint: Color) -> void:
	texture = _get_flat_icon()
	modulate = tint

static func _get_flat_icon() -> GradientTexture2D:
	if _flat_icon_tex == null:
		var gradient := Gradient.new()
		gradient.colors = PackedColorArray([Color.WHITE])
		gradient.offsets = PackedFloat32Array([0.0])
		_flat_icon_tex = GradientTexture2D.new()
		_flat_icon_tex.gradient = gradient
		_flat_icon_tex.width = 64
		_flat_icon_tex.height = 64
	return _flat_icon_tex
