@tool
extends Button
class_name DraftCard

## The whole card is the button now (no separate "Choose" button) — tap
## anywhere on it to pick it, per user request.
##
## Every element (NameLabel, IconRect, TypePillLabel, EffectLabel, LevelPips)
## is a PLAIN, FREELY-POSITIONED child now — no MarginContainer/VBoxContainer
## auto-flow. That means moving/resizing/re-fonting anything is just:
## select that node in the Scene dock, type numbers into the Inspector's
## native Layout (position/size) and Theme Overrides (font size) sections —
## no custom script property needed for any of it, and every card instances
## this one file, so changes here apply everywhere at once. Same for
## LevelPips — it's its own widget with its own pip_size/gap/colors knobs,
## select IT directly rather than looking for them here.
##
## The only things that genuinely can't be a plain node property live below:
## the rarity-tinted card art (built per-rarity in code) and the
## Engine.is_editor_hint() preview stand-in content (real gameplay always
## calls setup() with real spell/upgrade data instead).

signal card_selected(card_data: Resource)

@export_group("Card Art")
## 9-slice protection (source texture pixels, the art is 1054x1492 natively)
## on the card art's own border/corners — bigger keeps more of the border
## un-stretched when the card is tall, instead of the frame looking
## thin/distorted.
@export var border_texture_margin: float = 50.0:
	set(value): border_texture_margin = value; _rebuild_bg_styles()

@export_group("Editor Preview Only")
## Only used when this scene is open directly in the editor (Engine.is_editor_hint) —
## real gameplay always calls setup() with real spell/upgrade data instead.
## Set differently per-instance in a preview scene to compare rarities/name
## lengths side by side.
@export var preview_name: String = "Preview Spell+":
	set(value): preview_name = value; _apply_editor_preview()
@export_enum("Common:0", "Rare:1", "Epic:2") var preview_rarity: int = 0:
	set(value): preview_rarity = value; _apply_editor_preview()
## When set, the editor preview calls setup() with this REAL resource
## instead of the synthetic preview_name/preview_rarity stand-in — shows
## the actual icon/background/text a card would render with in real
## gameplay (e.g. a StatUpgradeDefinition's bg_texture_override), with no
## need to run the game. Generic for any spell/upgrade resource.
@export var preview_card_data: Resource = null:
	set(value): preview_card_data = value; _apply_editor_preview()
## Background override for the plain preview_name/preview_rarity stand-in
## path (no real card_data) — e.g. to preview the green card family without
## a real resource. Ignored once preview_card_data/real card_data is set.
@export var preview_bg_override: Texture2D = null:
	set(value): preview_bg_override = value; _rebuild_bg_styles()

const CARD_BG_TEXTURES := {
	0: preload("res://assets/ui/draft/ui_card_bg_common.png"),
	1: preload("res://assets/ui/draft/ui_card_bg_rare_v2.png"),
	2: preload("res://assets/ui/draft/ui_card_bg_epic_v3.png"),
}

# One shared StyleBoxTexture per rarity, built on first use.
static var _bg_styles := {}

# One shared pill StyleBoxFlat per color, built on first use.
static var _pill_styles := {}

const GLOW_SHADER := preload("res://scenes/ui/draft_card_glow.gdshader")

@onready var glow_rect: ColorRect        = $GlowRect
@onready var icon_rect: SpellIcon        = $IconRect
@onready var name_label: Label           = $NameLabel
@onready var type_pill: Label            = $TypePillLabel
@onready var effect_label: Label         = $EffectLabel
@onready var level_pips: Control         = $LevelPips

var _card_data: Resource

func _ready() -> void:
	if not Engine.is_editor_hint():
		pressed.connect(_on_select_pressed)
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	# Glow color differs PER CARD (a draft shows Common/Rare/Epic side by
	# side), unlike SpellIcon's mask material — so this one is always
	# per-instance, never the shared-static trick, or every visible card
	# would fight over one material's glow_color (the same hot-reload-style
	# gotcha this project already hit once with a shared shader material).
	var glow_mat := ShaderMaterial.new()
	glow_mat.shader = GLOW_SHADER
	glow_mat.set_shader_parameter("card_size", Vector2(249.0, 566.0))
	glow_mat.set_shader_parameter("corner_radius", 10.0)
	glow_mat.set_shader_parameter("glow_radius", 12.0)
	glow_rect.material = glow_mat
	_apply_editor_preview()

# Editor-only stand-in content (real gameplay always calls setup() with real
# spell/upgrade data instead, which overwrites all of this). Lets this scene
# — or a preview scene instancing it several times with different
# preview_name/preview_rarity per instance — show something without needing
# the game running or a MetaManager/tower/EventBus to exist.
func _apply_editor_preview() -> void:
	if not Engine.is_editor_hint() or not is_inside_tree() or _card_data != null:
		return
	if preview_card_data != null:
		setup(preview_card_data)
		return
	name_label.text = preview_name
	var pill_colors := {0: Color(0.75, 0.75, 0.75), 1: Color(0.3, 0.55, 1.0), 2: Color(0.65, 0.25, 0.95)}
	var pill_texts := {0: "Common", 1: "Rare", 2: "Epic"}
	var color: Color = pill_colors.get(preview_rarity, pill_colors[0])
	# setup() normally assigns a real spell icon (icon_rect.setup) — preview
	# mode has no spell to look up, so it needs to fill this in itself.
	icon_rect.setup_preview(color)
	type_pill.visible = true
	type_pill.text = pill_texts.get(preview_rarity, "Common")
	type_pill.add_theme_stylebox_override("normal", _get_pill_style(color))
	type_pill.add_theme_color_override("font_color", color)
	effect_label.text = "+1 Bolt"
	level_pips.visible = true
	level_pips.max_pips = 5
	level_pips.filled = 2
	level_pips.filled_color = PIP_FILLED_COLORS.get(preview_rarity, PIP_FILLED_COLORS[0])
	_rebuild_bg_styles()

func _rebuild_bg_styles() -> void:
	if not is_inside_tree():
		return
	_bg_styles.clear()
	if _card_data != null:
		_refresh_bg_style()
	elif Engine.is_editor_hint():
		var r := preview_rarity
		var override_tex := preview_bg_override
		add_theme_stylebox_override("normal", _get_bg_style(r, false, override_tex))
		add_theme_stylebox_override("hover", _get_bg_style(r, false, override_tex))
		add_theme_stylebox_override("pressed", _get_bg_style(r, true, override_tex))
		add_theme_stylebox_override("disabled", _get_bg_style(r, false, override_tex))
		_refresh_glow(r, override_tex != null)

func setup(card_data: Resource) -> void:
	_card_data = card_data
	var n = card_data.get("spell_name")
	if n == null:
		n = card_data.get("upgrade_name")
	name_label.text = str(n) if n != null else "?"
	_refresh_bg_style()
	icon_rect.setup(card_data)
	_setup_type_pill(card_data)
	_setup_effect_line(card_data)
	_setup_level_pips(card_data)

func _refresh_bg_style() -> void:
	var rarity = _card_data.get("rarity")
	var r: int = rarity if rarity != null else 0
	var override_tex: Texture2D = _card_data.get("bg_texture_override")
	add_theme_stylebox_override("normal", _get_bg_style(r, false, override_tex))
	add_theme_stylebox_override("hover", _get_bg_style(r, false, override_tex))
	add_theme_stylebox_override("pressed", _get_bg_style(r, true, override_tex))
	add_theme_stylebox_override("disabled", _get_bg_style(r, false, override_tex))
	_refresh_glow(r, override_tex != null)

# Rarity-tinted glow behind the card (GlowRect's ShaderMaterial —
# draft_card_glow.gdshader — draws a soft rounded-rect falloff around the
# card's own visible frame). Common: gray, Rare: blue, Epic: purple.
const RARITY_GLOW_COLORS := {
	0: Color(0.75, 0.75, 0.75, 0.85),
	1: Color(0.3, 0.55, 1.0, 0.85),
	2: Color(0.65, 0.25, 0.95, 0.85),
}
# A card using bg_texture_override (e.g. the green school-damage cards)
# gets a matching green glow instead of its rarity's color — the glow is
# meant to echo the card's own frame, and rarity's blue/purple clashed
# visibly against the green art (Rare-tier "Frost Dmg Increase" showed a
# blue halo behind its green card).
const OVERRIDE_GLOW_COLOR := Color(0.35, 0.85, 0.3, 0.85)

func _refresh_glow(rarity: int, use_override_color: bool = false) -> void:
	var glow: Color = OVERRIDE_GLOW_COLOR if use_override_color else RARITY_GLOW_COLORS.get(rarity, RARITY_GLOW_COLORS[0])
	glow_rect.material.set_shader_parameter("glow_color", glow)

# Same rarity-tinted card art as before, now used as the Button's normal/
# hover/pressed/disabled style instead of a PanelContainer's single "panel"
# style — pressed gets a slight darken so tapping the card still reads as a
# press with no separate button needed.
func _get_bg_style(rarity: int, pressed_state: bool = false, texture_override: Texture2D = null) -> StyleBoxTexture:
	var key := "%s_%s" % [(texture_override.resource_path if texture_override != null else rarity), pressed_state]
	if not _bg_styles.has(key):
		var sb := StyleBoxTexture.new()
		sb.texture = texture_override if texture_override != null else CARD_BG_TEXTURES.get(rarity, CARD_BG_TEXTURES[0])
		# 9-slice margins (in the SOURCE texture's own pixels — it's 1054x1492
		# natively, aspect 1.42) so the rounded corners/border stay crisp
		# instead of stretching when the card is sized to a taller aspect
		# ratio than the texture's native one — without this, the border
		# reads as thin/distorted the taller the card gets.
		sb.texture_margin_left = border_texture_margin
		sb.texture_margin_top = border_texture_margin
		sb.texture_margin_right = border_texture_margin
		sb.texture_margin_bottom = border_texture_margin
		if pressed_state:
			sb.modulate_color = Color(0.8, 0.8, 0.8, 1)
		_bg_styles[key] = sb
	return _bg_styles[key]

# Pill under the icon: damage school for a spell (colored to match), the
# scoped school for a school-specific stat upgrade (e.g. "Fire Dmg
# Increase" — same treatment as a spell), or the first synergy tag for any
# other stat upgrade (which has neither).
func _setup_type_pill(card_data: Resource) -> void:
	var dtype = card_data.get("damage_type")
	var scoped = card_data.get("scoped_damage_type")
	var text := ""
	var color := Color(0.75, 0.75, 0.75)
	if dtype != null:
		text = Constants.DamageType.keys()[dtype].capitalize()
		color = CombatUtils.get_damage_color(dtype)
	elif scoped != null and scoped != -1:
		text = Constants.DamageType.keys()[scoped].capitalize()
		color = CombatUtils.get_damage_color(scoped)
	else:
		var tags = card_data.get("tags")
		if tags != null and tags.size() > 0:
			text = Constants.SynergyTag.keys()[tags[0]].capitalize()
	type_pill.visible = text != ""
	if text == "":
		return
	type_pill.text = text
	type_pill.add_theme_stylebox_override("normal", _get_pill_style(color))
	type_pill.add_theme_color_override("font_color", color)

static func _get_pill_style(color: Color) -> StyleBoxFlat:
	var key := color.to_html()
	if not _pill_styles.has(key):
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.08, 0.08, 0.1, 0.85)
		sb.border_color = color
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(14)
		sb.content_margin_left = 18.0
		sb.content_margin_right = 18.0
		sb.content_margin_top = 5.0
		sb.content_margin_bottom = 5.0
		_pill_styles[key] = sb
	return _pill_styles[key]

# Empty on a spell's first pick (nothing granted yet beyond owning it).
# On a repeat pick, the exact effect stacking actually gives that spell's
# archetype (tower.gd's _add_spell/_fire_projectile — spells.md §6.6). A
# stat-upgrade card always shows its flat bonus, first pick or not, since
# apply_card applies the same amount every time (game_state.gd:147-154).
func _setup_effect_line(card_data: Resource) -> void:
	effect_label.text = _get_effect_text(card_data)

func _get_effect_text(card_data: Resource) -> String:
	if card_data is StatUpgradeDefinition:
		return _stat_upgrade_effect_text(card_data)
	if card_data is SpellDefinition:
		var tower := get_tree().get_first_node_in_group("tower")
		var owned: bool = tower != null and tower.get_stack_count(card_data.spell_id) > 0
		if not owned:
			return ""
		match card_data.spell_category:
			Constants.SpellCategory.PROJECTILE:
				# Volley stacking (spells.md §6.6): Bolts & Chains fire one
				# more projectile per cast, staggered as a volley.
				return "+1 Bolt"
			Constants.SpellCategory.ORB:
				# tower.gd::_add_spell spawns another orb on the same ring.
				return "+1 Orb"
			Constants.SpellCategory.PASSIVE:
				# game_state.gd::apply_card adds this amount again, additively,
				# every pick (no owned-check for passives).
				var rank: int = MetaManager.spell_ranks.get(card_data.spell_id, 1)
				var pct := CombatUtils.calculate_rank_scaled_value(card_data.passive_value, rank) * 100.0
				return "+%d%% Damage Reduction" % roundi(pct)
			_:
				# AoE Area & Lance are stack_max = 1 (spells.md §6.6, "one-pick"),
				# so _is_eligible removes them from the pool after one take —
				# this branch is never actually reached in current gameplay.
				return ""
	return ""

func _stat_upgrade_effect_text(u: StatUpgradeDefinition) -> String:
	var parts: PackedStringArray = []
	if u.hp_bonus != 0.0:
		parts.append("+%d Max HP" % int(u.hp_bonus))
	if u.damage_multiplier != 1.0:
		parts.append("%+d%% Damage" % roundi((u.damage_multiplier - 1.0) * 100.0))
	if u.fire_rate_multiplier != 1.0:
		parts.append("%+d%% Cooldown" % roundi((u.fire_rate_multiplier - 1.0) * 100.0))
	return ", ".join(parts)

# Filled-pip color by rarity, matching the reference art exactly (measured
# from its actual pixels): Common cards' filled pips are red, Rare (and
# above) are gold.
const PIP_FILLED_COLORS := {
	0: Color(0.75, 0.16, 0.14),  # Common: red
	1: Color(1.0, 0.82, 0.2),    # Rare: gold
	2: Color(1.0, 0.82, 0.2),    # Epic: gold (no reference sample; reuses Rare's)
}

# The pip row itself: the spell's permanent Spell Codex rank
# (MetaManager.spell_ranks, out of Constants.SPELL_MAX_RANK). Stat-upgrade
# cards have no codex rank. Select the LevelPips node directly to change its
# own position/size/pip_size/gap/colors — none of that lives here.
func _setup_level_pips(card_data: Resource) -> void:
	if card_data is SpellDefinition:
		var rarity = card_data.get("rarity")
		level_pips.visible = true
		level_pips.max_pips = Constants.SPELL_MAX_RANK
		level_pips.filled = MetaManager.spell_ranks.get(card_data.spell_id, 1)
		level_pips.filled_color = PIP_FILLED_COLORS.get(rarity if rarity != null else 0, PIP_FILLED_COLORS[0])
	else:
		level_pips.visible = false

func _on_select_pressed() -> void:
	disabled = true
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.07)
	tween.tween_property(self, "scale", Vector2.ONE, 0.07)
	tween.finished.connect(func(): card_selected.emit(_card_data))
