class_name WeightedTable
extends RefCounted

# Weighted random picker: add_item(item, weight), then pick_item().
# Mirrors the reference project's WeightedTable API so the wave spawn path
# can register enemy scenes and pull one out by weight.

var _items: Array = []      # each entry: { "item": Variant, "weight": int }
var _total_weight: int = 0

func add_item(item: Variant, weight: int) -> void:
	_items.append({ "item": item, "weight": weight })
	_total_weight += weight

func pick_item() -> Variant:
	if _items.is_empty():
		return null
	var roll := randi_range(1, _total_weight)
	var cumulative := 0
	for entry in _items:
		cumulative += entry["weight"]
		if roll <= cumulative:
			return entry["item"]
	return _items.back()["item"]

func clear() -> void:
	_items.clear()
	_total_weight = 0
