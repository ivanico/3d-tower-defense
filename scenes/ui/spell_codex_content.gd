extends Control

## Spell Codex. Content-only: no NavBar of its own — this scene lives inside
## `world_map.gd`'s shell, which owns the shared NavBar and calls `_refresh()`
## on this node directly.

const MetaRowScene := preload("res://scenes/ui/widget/meta_row/meta_row.tscn")

@onready var spell_list: VBoxContainer = $ScrollContainer/SpellList

@onready var energy_pill: Control = $TopBar/EnergyPill
@onready var materials_pill: Control = $TopBar/MaterialsPill

# One CostChip per school, in the same Fire/Frost/Void/Poison/Nature order as
# Constants.DamageType and CombatUtils.SCROLL_ICONS.
@onready var scroll_mat_chips: Dictionary = {
	Constants.DamageType.FIRE: $ScrollMatsRow/FireChip,
	Constants.DamageType.FROST: $ScrollMatsRow/FrostChip,
	Constants.DamageType.VOID: $ScrollMatsRow/VoidChip,
	Constants.DamageType.POISON: $ScrollMatsRow/PoisonChip,
	Constants.DamageType.NATURE: $ScrollMatsRow/NatureChip,
}

func _ready() -> void:
	_refresh()

func _refresh() -> void:
	energy_pill.set_amount(MetaManager.energy)
	materials_pill.set_amount(MetaManager.base_material)
	for damage_type in scroll_mat_chips:
		var chip: CostChip = scroll_mat_chips[damage_type]
		chip.set_balance(MetaManager.get_scroll_material(damage_type), CombatUtils.get_scroll_icon(damage_type))
	for child in spell_list.get_children():
		spell_list.remove_child(child)
		child.queue_free()
	for spell in SpellRegistry.all_spells:
		_add_spell_row(spell)

func _add_spell_row(spell: SpellDefinition) -> void:
	var rank: int = MetaManager.spell_ranks.get(spell.spell_id, 1)
	var at_max: bool = rank >= Constants.SPELL_MAX_RANK
	var next_rank: int = rank + 1

	# Added to the tree first so the row's @onready refs resolve before setup.
	var row: MetaRow = MetaRowScene.instantiate()
	row.name = "SpellRow_%s" % spell.spell_id
	spell_list.add_child(row)

	row.set_row_icon(SpellRegistry.get_card_icon(spell))
	row.set_title(spell.spell_name)
	row.show_rank("Rank %d/%d" % [rank, Constants.SPELL_MAX_RANK])
	row.set_stat_text(_stats_text(spell, rank, next_rank, at_max))

	if at_max:
		row.set_upgrade_maxed()
	else:
		var base_cost: int = Constants.SPELL_RANK_COSTS[rank]
		var rare_cost: int = Constants.SPELL_RANK_RARE_COSTS[rank]
		var base_affordable: bool = MetaManager.base_material >= base_cost
		var rare_affordable: bool = MetaManager.get_scroll_material(spell.damage_type) >= rare_cost
		row.set_upgrade_costs(base_cost, base_affordable, CombatUtils.BASE_MATERIAL_ICON, rare_cost, rare_affordable, CombatUtils.get_scroll_icon(spell.damage_type))
		row.upgrade_pressed.connect(_on_upgrade_pressed.bind(spell.spell_id, spell.damage_type))

func _stats_text(spell: SpellDefinition, rank: int, next_rank: int, at_max: bool) -> String:
	if spell.spell_category == Constants.SpellCategory.PASSIVE:
		var current_pct: float = CombatUtils.calculate_rank_scaled_value(spell.passive_value, rank) * 100.0
		if at_max:
			return "Damage Reduction: %d%%" % int(round(current_pct))
		var next_pct: float = CombatUtils.calculate_rank_scaled_value(spell.passive_value, next_rank) * 100.0
		return "Damage Reduction: %d%% → %d%%" % [int(round(current_pct)), int(round(next_pct))]
	var current_dmg: float = CombatUtils.calculate_rank_scaled_value(spell.damage, rank)
	if at_max:
		return "DMG: %d   Cooldown: %.1fs (fixed)" % [int(round(current_dmg)), spell.cooldown]
	var next_dmg: float = CombatUtils.calculate_rank_scaled_value(spell.damage, next_rank)
	return "DMG: %d → %d   Cooldown: %.1fs (fixed)" % [int(round(current_dmg)), int(round(next_dmg)), spell.cooldown]

func _on_upgrade_pressed(spell_id: String, damage_type: int) -> void:
	if MetaManager.upgrade_spell_rank(spell_id, damage_type):
		AudioManager.play_sfx("sfx_upgrade_confirm")
	_refresh()
