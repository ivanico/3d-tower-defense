extends CanvasLayer

@onready var materials_label: Label = $MaterialsLabel
@onready var spell_list: VBoxContainer = $ScrollContainer/SpellList
@onready var back_button: Button = $BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	_refresh()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/world_map.tscn")

func _refresh() -> void:
	materials_label.text = "Materials: %d" % MetaManager.materials
	for child in spell_list.get_children():
		spell_list.remove_child(child)
		child.queue_free()
	for spell in SpellRegistry.all_spells:
		spell_list.add_child(_build_spell_row(spell))

func _build_spell_row(spell: SpellDefinition) -> Control:
	var rank: int = MetaManager.spell_ranks.get(spell.spell_id, 1)
	var at_max: bool = rank >= Constants.SPELL_MAX_RANK
	var next_rank: int = rank + 1

	var card := VBoxContainer.new()
	card.name = "SpellRow_%s" % spell.spell_id
	card.add_theme_constant_override("separation", 6)

	var top_row := HBoxContainer.new()
	top_row.name = "TopRow"
	top_row.add_theme_constant_override("separation", 20)
	card.add_child(top_row)

	var name_label := Label.new()
	name_label.name = "NameLabel"
	name_label.text = spell.spell_name
	name_label.custom_minimum_size = Vector2(280, 0)
	name_label.add_theme_font_size_override("font_size", 28)
	top_row.add_child(name_label)

	var rank_label := Label.new()
	rank_label.name = "RankLabel"
	rank_label.text = "Rank %d/%d" % [rank, Constants.SPELL_MAX_RANK]
	rank_label.custom_minimum_size = Vector2(200, 0)
	rank_label.add_theme_font_size_override("font_size", 28)
	top_row.add_child(rank_label)

	var stats_label := Label.new()
	stats_label.name = "StatsLabel"
	stats_label.text = _stats_text(spell, rank, next_rank, at_max)
	stats_label.add_theme_font_size_override("font_size", 22)
	stats_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8))
	card.add_child(stats_label)

	var upgrade_button := Button.new()
	upgrade_button.name = "UpgradeButton"
	upgrade_button.add_theme_font_size_override("font_size", 24)
	if at_max:
		upgrade_button.text = "MAX"
		upgrade_button.disabled = true
	else:
		var cost: int = Constants.SPELL_RANK_COSTS[rank]
		upgrade_button.text = "Upgrade (%d)" % cost
		upgrade_button.disabled = MetaManager.materials < cost
		upgrade_button.pressed.connect(_on_upgrade_pressed.bind(spell.spell_id))
	card.add_child(upgrade_button)

	return card

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
