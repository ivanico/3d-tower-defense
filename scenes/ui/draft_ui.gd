extends CanvasLayer

const DRAFT_CARD_SCENE := preload("res://scenes/ui/draft_card.tscn")

@onready var dim_bg: ColorRect         = $DimBG
@onready var panel: PanelContainer     = $FullscreenContainer/Panel
@onready var card_container: HBoxContainer = $FullscreenContainer/Panel/VBoxContainer/CardContainer
@onready var title_label: Label        = $FullscreenContainer/Panel/VBoxContainer/TitleLabel

var _close_tween: Tween = null

func _ready() -> void:
	dim_bg.modulate = Color(1, 1, 1, 0)
	panel.visible = false
	EventBus.draft_opened.connect(_on_draft_opened)
	EventBus.draft_closed.connect(_on_draft_closed)

func _draft_manager() -> DraftManager:
	return get_tree().get_first_node_in_group("draft_manager") as DraftManager

func _on_draft_opened() -> void:
	if _close_tween:
		_close_tween.kill()
		_close_tween = null
	var dm := _draft_manager()
	match dm._draft_trigger:
		"wave_clear": title_label.text = "Wave Cleared!"
		"first_spell": title_label.text = "First Spell!"
		_: title_label.text = "Level Up!"
	for child in card_container.get_children():
		child.queue_free()
	var card_index := 0
	for card_data in dm._draft_cards:
		# The card sits inside a plain-Control WRAPPER, itself the direct
		# HBoxContainer child, instead of the card being a direct child of
		# the container — Container.fit_child_in_rect() resets scale to 1
		# on every direct child it lays out (ui_tuning.md "A Container
		# silently un-rotates its children"), which was silently stomping
		# the scale-in animation below on every card whose tween hadn't
		# already finished by the container's next sort pass. The wrapper
		# eats that reset (its own scale is never touched); the card inside
		# it is safe to animate.
		var wrapper := Control.new()
		wrapper.custom_minimum_size = Vector2(400.0, 600.0)
		card_container.add_child(wrapper)
		var card_node: DraftCard = DRAFT_CARD_SCENE.instantiate()
		wrapper.add_child(card_node)
		card_node.setup(card_data)
		card_node.card_selected.connect(_on_card_selected)
		# Scale-in pop instead of just appearing at full size — pivot at the
		# card's own center (its size is fixed at 400x600, draft_card.tscn)
		# so it grows from the middle, not the top-left corner (a Control's
		# default pivot). TRANS_BACK overshoots slightly past 1.0 before
		# settling, which is what makes it read as a "pop" rather than a
		# plain linear grow. Each card's tween is independent, so a small
		# per-card stagger (index * 0.1s start delay) reads as a left-to-
		# right cascade instead of all three popping in simultaneously.
		card_node.pivot_offset = Vector2(200.0, 300.0)
		card_node.scale = Vector2.ZERO
		var card_tween := create_tween()
		card_tween.tween_interval(card_index * 0.1)
		card_tween.tween_property(card_node, "scale", Vector2.ONE, 0.65) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		card_index += 1
	panel.visible = true
	var tween := create_tween()
	tween.tween_property(dim_bg, "modulate:a", 1.0, 0.2)

func _on_card_selected(card_data: Resource) -> void:
	_draft_manager().select_card(card_data)

func _on_draft_closed() -> void:
	_close_tween = create_tween()
	_close_tween.tween_property(dim_bg, "modulate:a", 0.0, 0.2)
	_close_tween.finished.connect(func():
		_close_tween = null
		panel.visible = false
		for child in card_container.get_children():
			child.queue_free()
	)
