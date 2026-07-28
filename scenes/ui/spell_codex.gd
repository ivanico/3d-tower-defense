extends CanvasLayer

const MetaRowScene := preload("res://scenes/ui/widget/meta_row/meta_row.tscn")

@onready var spell_list: VBoxContainer = $ScrollContainer/SpellList
# preload, not the global class `NavBar` — see the note in tower_garage.gd.
const NavBarScript := preload("res://scenes/ui/widget/nav_bar/nav_bar.gd")

@onready var energy_pill: Control = $TopBar/EnergyPill
@onready var materials_pill: Control = $TopBar/MaterialsPill
@onready var nav_bar: Control = $NavBar

func _ready() -> void:
	# NavBar enlarges and disables the entry we are on; no per-button fiddling.
	nav_bar.selected = NavBarScript.Nav.CODEX
	$NavBar/WorldmapButton.pressed.connect(_on_map_pressed)
	$NavBar/GarageButton.pressed.connect(_on_garage_pressed)
	_refresh()

func _on_map_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/world_map.tscn")

func _on_garage_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/tower_garage.tscn")

func _refresh() -> void:
	energy_pill.set_amount(MetaManager.energy)
	materials_pill.set_amount(MetaManager.materials)
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
		var cost: int = Constants.SPELL_RANK_COSTS[rank]
		row.set_upgrade_cost(cost, MetaManager.materials >= cost)
		row.upgrade_pressed.connect(_on_upgrade_pressed.bind(spell.spell_id))

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

func _on_upgrade_pressed(spell_id: String) -> void:
	if MetaManager.upgrade_spell_rank(spell_id):
		AudioManager.play_sfx("sfx_upgrade_confirm")
	_refresh()
