extends RefCounted

## The stand-in payment provider for real-money store items (10-04): every
## purchase succeeds, with no money and no store account involved. Used in the
## editor, on desktop, and in every build until Epic 12 (12-01) adds the Google
## Play Billing provider with this same shape:
##   - `purchase(item)` starts a purchase
##   - `purchase_completed(item, success)` reports the result LATER
## The result is deferred on purpose, so StoreService already handles the
## asynchronous flow real billing has.

signal purchase_completed(item: Resource, success: bool)


func purchase(item: Resource) -> void:
	call_deferred("_finish", item)


func _finish(item: Resource) -> void:
	purchase_completed.emit(item, true)
