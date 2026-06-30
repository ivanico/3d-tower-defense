extends CanvasLayer

const DRAFT_CARD_SCENE := preload("res://scenes/ui/DraftCard.tscn")

@onready var dim_bg: ColorRect         = $DimBG
@onready var panel: PanelContainer     = $FullscreenContainer/Panel
@onready var card_container: HBoxContainer = $FullscreenContainer/Panel/VBoxContainer/CardContainer
@onready var subtitle_label: Label     = $FullscreenContainer/Panel/VBoxContainer/SubtitleLabel

func _ready() -> void:
	dim_bg.modulate = Color(1, 1, 1, 0)
	panel.visible = false
	EventBus.draft_opened.connect(_on_draft_opened)
	EventBus.draft_closed.connect(_on_draft_closed)

func _on_draft_opened() -> void:
	subtitle_label.text = "Wave Cleared!" if DraftManager._draft_trigger == "wave_clear" else "Level Up!"
	for child in card_container.get_children():
		child.queue_free()
	for card_data in DraftManager._draft_cards:
		var card_node: DraftCard = DRAFT_CARD_SCENE.instantiate()
		card_container.add_child(card_node)
		card_node.setup(card_data)
		card_node.card_selected.connect(_on_card_selected)
	panel.visible = true
	var tween := create_tween()
	tween.tween_property(dim_bg, "modulate:a", 1.0, 0.2)

func _on_card_selected(card_data: Resource) -> void:
	DraftManager.select_card(card_data)

func _on_draft_closed() -> void:
	var tween := create_tween()
	tween.tween_property(dim_bg, "modulate:a", 0.0, 0.2)
	tween.finished.connect(func():
		panel.visible = false
		for child in card_container.get_children():
			child.queue_free()
	)
