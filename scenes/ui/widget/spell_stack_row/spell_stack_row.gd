@tool
extends HFlowContainer
class_name SpellStackRow

## HUD row replacing the old OFF/ARM/UTL tag pills: one small icon per
## DISTINCT card the player has picked this run, with a row of gold dots
## under each icon showing how many times it's been picked — mirrors the
## draft card's own icon (SpellIcon, shared — see spell_icon.gd) and
## rank-pip row (SpellRankPips, shared) so this reuses both instead of
## re-implementing icon/pip rendering.
##
## Shared by BOTH HUD rows via the `source` export: Spells (left side,
## Tower._active_spells/get_stack_count) and Upgrades (right side,
## GameState.active_upgrades/get_upgrade_stack_count) — one scene/script,
## instanced twice with a different `source`, instead of forking it, since
## SpellIcon/SpellRegistry already resolve either resource type generically.
##
## Rebuilds only on EventBus.card_selected (a pick), never per-frame — a
## handful of small TextureRects + cheap _draw()-based pip rows is
## negligible, but there's no reason to touch it more often than the data
## actually changes.
##
## Root is an HFlowContainer, not HBoxContainer — once cells stop fitting
## the row's own assigned width, it wraps them onto a new line on its own
## (no custom wrap math needed) instead of running past the row's edge.

const SPELL_ICON_SCENE := preload("res://scenes/ui/widget/spell_icon/spell_icon.tscn")
const SPELL_RANK_PIPS_SCENE := preload("res://scenes/ui/widget/spell_rank_pips/spell_rank_pips.tscn")

## Which owned-card list to read at runtime — Spells (Tower's active
## spells, the original behavior) or Upgrades (GameState's active stat-
## upgrade cards, e.g. the right-side HUD row). SpellIcon/SpellRegistry
## already resolve either resource type generically, so one script/scene
## serves both rows via this knob instead of forking the widget.
@export_enum("Spells:0", "Upgrades:1") var source: int = 0:
	set(value): source = value; _rebuild()

@export_group("Layout")
@export var icon_size: Vector2 = Vector2(56.0, 56.0):
	set(value): icon_size = value; _rebuild()
@export var cell_separation: float = 4.0:
	set(value): cell_separation = value; _rebuild()
@export var pip_size: float = 5.0:
	set(value): pip_size = value; _rebuild()
@export var pip_gap: float = 3.0:
	set(value): pip_gap = value; _rebuild()
@export var pip_color: Color = Color(1.0, 0.82, 0.2):
	set(value): pip_color = value; _rebuild()
## 0 = unlimited (one row, however wide) — see spell_rank_pips.gd's own
## pips_per_row for what this forwards into.
@export var pips_per_row: int = 4:
	set(value): pips_per_row = value; _rebuild()

@export_group("Editor Preview Only")
## Only used when this scene is open directly in the editor — real gameplay
## always reads Tower.get_active_spells()/get_stack_count() instead. Set on
## a preview-scene instance to compare a few spells/stack counts side by
## side without running the game.
@export var preview_spells: Array[SpellDefinition] = []:
	set(value): preview_spells = value; _rebuild()
@export var preview_counts: PackedInt32Array = []:
	set(value): preview_counts = value; _rebuild()
## Same idea as preview_spells/preview_counts above, read instead when
## source == Upgrades.
@export var preview_upgrades: Array[StatUpgradeDefinition] = []:
	set(value): preview_upgrades = value; _rebuild()
@export var preview_upgrade_counts: PackedInt32Array = []:
	set(value): preview_upgrade_counts = value; _rebuild()

func _ready() -> void:
	if Engine.is_editor_hint():
		_rebuild()
	else:
		EventBus.card_selected.connect(func(_c): _rebuild())
		_rebuild()

func _rebuild() -> void:
	if not is_inside_tree():
		return
	# include_internal=true — the cells below are added as INTERNAL_MODE_BACK
	# (see why below), and get_children() excludes internal nodes by
	# default, so without this a rebuild would stop finding last time's
	# cells and just accumulate new ones on top forever instead of
	# replacing them.
	for child in get_children(true):
		remove_child(child)
		child.queue_free()
	var cards: Array
	var counts: Array
	if Engine.is_editor_hint():
		cards = preview_upgrades if source == 1 else preview_spells
		counts = preview_upgrade_counts if source == 1 else preview_counts
	elif source == 1:
		cards = GameState.get_active_upgrades()
		counts = cards.map(func(u): return GameState.get_upgrade_stack_count(u.upgrade_id))
	else:
		var tower := get_tree().get_first_node_in_group("tower")
		if tower == null:
			return
		cards = tower.get_active_spells()
		counts = cards.map(func(s): return tower.get_stack_count(s.spell_id))
	for i in cards.size():
		var card = cards[i]
		if card == null:
			continue
		var count: int = counts[i] if i < counts.size() else 0
		# INTERNAL_MODE_BACK on every generated node below — this is a @tool
		# script, so it rebuilds in the editor too, and a plain add_child()
		# here is exactly what let a generated widget's children get baked
		# into a screen's .tscn as a stale snapshot elsewhere in this project
		# (see ui_tuning.md "Don't hand-write generated properties into a
		# scene" / pause_button.gd's own INTERNAL_MODE_BACK use). Internal
		# children are never serialized, so this rebuild can never leave a
		# stale copy behind.
		add_child(_build_cell(card, count), false, Node.INTERNAL_MODE_BACK)

func _build_cell(card: Resource, count: int) -> VBoxContainer:
	var cell := VBoxContainer.new()
	cell.add_theme_constant_override("separation", cell_separation)
	cell.alignment = BoxContainer.ALIGNMENT_BEGIN

	var icon: SpellIcon = SPELL_ICON_SCENE.instantiate()
	icon.custom_minimum_size = icon_size
	cell.add_child(icon, false, Node.INTERNAL_MODE_BACK)
	icon.setup(card)

	var pips: Control = SPELL_RANK_PIPS_SCENE.instantiate()
	pips.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	pips.pip_size = pip_size
	pips.gap = pip_gap
	pips.filled_color = pip_color
	# A heavily-stacked spell has no upper bound on count, unlike the draft
	# card's fixed-max codex rank — wrap onto a new row every 4 dots instead
	# of growing wide enough to run into the next spell's icon.
	pips.pips_per_row = pips_per_row
	pips.max_pips = maxi(count, 1)
	pips.filled = count
	cell.add_child(pips, false, Node.INTERNAL_MODE_BACK)

	return cell
