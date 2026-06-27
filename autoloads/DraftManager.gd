extends Node

func open_draft(trigger: String = "") -> void:
	EventBus.draft_opened.emit(trigger)

func select_card(card: Resource) -> void:
	EventBus.card_selected.emit(card)
	EventBus.draft_closed.emit()
