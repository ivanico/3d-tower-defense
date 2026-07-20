class_name DraftManager
extends Node

var _draft_trigger: String = ""
var _taken_counts: Dictionary = {}
var _draft_cards: Array = []
var _queue: Array = []
var _start_wave_after: bool = false

const RARITY_WEIGHTS := {0: 60, 1: 30, 2: 10}

var _pool_exhausted: bool = false

func _ready() -> void:
	add_to_group("draft_manager")
	EventBus.level_up.connect(_on_level_up)
	EventBus.run_reset.connect(reset_run)

func _on_level_up(_new_level: int) -> void:
	open_draft("level_up")

func reset_run() -> void:
	_draft_trigger = ""
	_taken_counts = {}
	_draft_cards = []
	_queue = []
	_start_wave_after = false
	_pool_exhausted = false

func open_draft(trigger: String = "wave_clear") -> void:
	if GameState.phase == Constants.GamePhase.DRAFT:
		_queue.append(trigger)
		return
	if trigger == "wave_clear":
		_start_wave_after = true
	if _pool_exhausted:
		if _start_wave_after:
			_start_wave_after = false
			EventBus.start_wave_requested.emit(GameState.wave_number)
		return
	_do_open_draft(trigger)

func _do_open_draft(trigger: String) -> void:
	_draft_trigger = trigger
	_draft_cards = get_draft_cards()
	if _draft_cards.is_empty():
		_pool_exhausted = true
		if not _queue.is_empty():
			var next := _queue.pop_front() as String
			if next == "wave_clear":
				_start_wave_after = true
			_do_open_draft(next)
			return
		_close_draft()
		if _start_wave_after:
			_start_wave_after = false
			EventBus.start_wave_requested.emit(GameState.wave_number)
		return
	GameState.phase = Constants.GamePhase.DRAFT
	EventBus.phase_changed.emit(GameState.phase)
	EventBus.draft_opened.emit()

func _close_draft() -> void:
	if GameState.phase == Constants.GamePhase.DRAFT:
		GameState.phase = Constants.GamePhase.WAVE
		EventBus.draft_closed.emit()
		EventBus.phase_changed.emit(GameState.phase)

func get_draft_cards() -> Array:
	var pool := SpellRegistry.get_all_cards()
	var eligible := pool.filter(func(c): return _is_eligible(c))
	return _weighted_draw(eligible, Constants.DRAFT_CARDS_SHOWN)

func select_card(card: Resource) -> void:
	_draft_cards = []
	var cid := _card_id(card)
	if cid != "":
		_taken_counts[cid] = _taken_counts.get(cid, 0) + 1
	GameState.apply_card(card)
	EventBus.card_selected.emit(card)
	if not _queue.is_empty():
		var next := _queue.pop_front() as String
		if next == "wave_clear":
			_start_wave_after = true
		_do_open_draft(next)
	else:
		GameState.phase = Constants.GamePhase.WAVE
		EventBus.draft_closed.emit()
		EventBus.phase_changed.emit(GameState.phase)
		if _start_wave_after:
			_start_wave_after = false
			EventBus.start_wave_requested.emit(GameState.wave_number)

func _is_eligible(card: Resource) -> bool:
	var cid := _card_id(card)
	if cid == "":
		return false
	var count: int = _taken_counts.get(cid, 0)
	if count == 0:
		return true
	if card is SpellDefinition:
		# Spells stay draftable while under stack_max (spells.md Task S-00);
		# stack_max = 1 spells disappear from the pool after one pick.
		return count < card.stack_max
	var stackable = card.get("is_stackable")
	if stackable:
		var max_stack = card.get("stack_max")
		return count < (max_stack if max_stack != null else 1)
	return false

func _weighted_draw(pool: Array, count: int) -> Array:
	var result: Array = []
	var remaining := pool.duplicate()
	for _i in mini(count, remaining.size()):
		var total := 0
		for c in remaining:
			total += _weight(c)
		if total == 0:
			break
		var roll := randi() % total
		var cum := 0
		for j in remaining.size():
			cum += _weight(remaining[j])
			if roll < cum:
				result.append(remaining[j])
				remaining.remove_at(j)
				break
	return result

func _card_id(card: Resource) -> String:
	var sid = card.get("spell_id")
	if sid != null:
		return sid
	var uid = card.get("upgrade_id")
	return uid if uid != null else ""

func _weight(card: Resource) -> int:
	var r = card.get("rarity")
	return RARITY_WEIGHTS.get(r if r != null else 0, 60)

func _names_str(cards: Array) -> String:
	var parts: PackedStringArray = []
	for c in cards:
		var n = c.get("spell_name")
		if n == null:
			n = c.get("upgrade_name")
		parts.append(str(n) if n != null else "?")
	return ", ".join(parts)
