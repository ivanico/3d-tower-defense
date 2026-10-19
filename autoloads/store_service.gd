extends Node

## The store's rules (10-04): which items show today, what they cost, whether
## they can be bought, and THE one purchase path:
##   purchase(item) → price (gems spent here, or the payment provider for real
##   money) → _complete() → grant(item).
## The store screen only draws what this says. Epic 12 swaps the provider for
## Google Play Billing and changes nothing else.
##
## Items are data: every StoreItemDefinition `.tres` in resources/store/. The
## saved facts (bought one-time items, today's deals, the monthly card) live in
## MetaManager, the one save writer; the rules live here.

## Emitted when a purchase ends, bought or not. `success` false = the provider
## refused or was cancelled; nothing was granted or spent. `granted` is what
## grant() returned (empty on failure) — the reward popup shows it.
signal purchase_completed(item: Resource, success: bool, granted: Dictionary)

const ResourceDir := preload("res://scripts/resource_dir.gd")
const DayClock := preload("res://scripts/day_clock.gd")
const FakePurchaseProvider := preload("res://scripts/store/fake_purchase_provider.gd")
const STORE_DIR := "res://resources/store/"

## Why an item can't be bought right now. NONE = it can.
enum Block {
	NONE,
	CANT_AFFORD,     # gem price above the player's gems
	AD_NOT_READY,    # rewarded ads arrive in Epic 12
	CHEST_NOT_READY, # opening a chest arrives in 10-05
	CARD_ACTIVE,     # the monthly card is still running
	BOUGHT,          # one-time item, or today's deal, already bought
	PENDING,         # a real-money purchase of it is in flight
}

var items: Array = []
var _provider: RefCounted
## item_id -> buys since the store was last opened. Drives Archero's repeat-buy
## discount (better chest 300 → 280 → 260); reset_session() clears it.
var _session_buys: Dictionary = {}
## item_ids of real-money purchases waiting on the provider.
var _pending: Dictionary = {}


func _ready() -> void:
	items = load_sorted()
	_provider = FakePurchaseProvider.new()
	_provider.purchase_completed.connect(_on_provider_completed)
	collect_monthly_card()
	print("StoreService: %d store items loaded" % items.size())


## Every StoreItemDefinition, in store order: section, then sort_order.
## `static` so editor-time (@tool) callers can use it without the autoload.
static func load_sorted() -> Array:
	var result: Array = ResourceDir.load_all(STORE_DIR)
	result.sort_custom(func(a, b):
		if a.section != b.section:
			return a.section < b.section
		return a.sort_order < b.sort_order)
	return result


## The items a section shows right now, in order.
func visible_items(section: int) -> Array:
	if section == Constants.StoreSection.SKINS:
		return []  # skins arrive in 12-05
	if section == Constants.StoreSection.DAILY_DEALS:
		return todays_deals()
	var next_chain: int = _next_chain_index()
	return items.filter(func(item):
		if item.section != section or item.daily_deal:
			return false
		if item.chain_index > 0:
			return item.chain_index == next_chain
		return not (item.one_time and item.item_id in MetaManager.bought_items))


## Today's daily deals: every FREE deal, plus the rest of
## Constants.DAILY_DEALS_SHOWN drawn from the pool by today's day number, so
## the same day always shows the same deals (nothing extra to save).
func todays_deals() -> Array:
	var free: Array = []
	var paid: Array = []
	for item in items:
		if not item.daily_deal:
			continue
		if item.price_type == Constants.StorePriceType.FREE:
			free.append(item)
		else:
			paid.append(item)
	var rng := RandomNumberGenerator.new()
	rng.seed = DayClock.today()
	for i in range(paid.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var swap = paid[i]
		paid[i] = paid[j]
		paid[j] = swap
	var deals: Array = free + paid.slice(0, maxi(Constants.DAILY_DEALS_SHOWN - free.size(), 0))
	deals.sort_custom(func(a, b): return a.sort_order < b.sort_order)
	return deals


## What the next buy of a gem item costs (repeat-buy discount included).
func current_gem_price(item: Resource) -> int:
	var prices: Array[int] = item.gem_prices
	if prices.is_empty():
		return 0
	return prices[mini(int(_session_buys.get(item.item_id, 0)), prices.size() - 1)]


## Block.NONE if `item` can be bought right now, else why not.
func block_reason(item: Resource) -> int:
	if _pending.has(item.item_id):
		return Block.PENDING
	if item.price_type == Constants.StorePriceType.AD:
		return Block.AD_NOT_READY
	if item.open_on_buy:
		return Block.CHEST_NOT_READY
	if item.one_time and item.item_id in MetaManager.bought_items:
		return Block.BOUGHT
	if item.daily_deal and is_deal_bought_today(item):
		return Block.BOUGHT
	if item.card_days > 0 and monthly_card_days_left() > 0:
		return Block.CARD_ACTIVE
	if item.price_type == Constants.StorePriceType.GEMS and MetaManager.gems < current_gem_price(item):
		return Block.CANT_AFFORD
	return Block.NONE


## Starts buying `item`. Returns false (nothing spent) if it's blocked. Gem and
## free items finish at once; real-money items finish when the provider answers.
## Either way the result arrives through `purchase_completed`.
func purchase(item: Resource) -> bool:
	if block_reason(item) != Block.NONE:
		return false
	match item.price_type:
		Constants.StorePriceType.GEMS:
			if not MetaManager.spend_gems(current_gem_price(item)):
				return false
			_complete(item)
		Constants.StorePriceType.FREE:
			_complete(item)
		Constants.StorePriceType.REAL_MONEY:
			_pending[item.item_id] = true
			_provider.purchase(item)
		_:
			return false
	return true


## Gives everything `item` grants and returns what was given:
## {"gems", "energy", "base_material", "revives": int, "chests": {id: count}}
## (a monthly card's gems include today's payout). Public so tests and later
## reward sources can reuse it; a purchase goes through purchase(), never
## straight here.
func grant(item: Resource) -> Dictionary:
	var granted := {"gems": item.gems, "energy": item.energy,
			"base_material": item.base_material, "revives": item.revives, "chests": {}}
	MetaManager.award_gems(item.gems)
	if item.energy > 0:
		MetaManager.restore_energy(item.energy)
	if item.base_material > 0:
		MetaManager.award_base_material(item.base_material)
	MetaManager.award_free_revives(item.revives)
	if not item.chest_id.is_empty() and item.chest_count > 0:
		MetaManager.award_chest(item.chest_id, item.chest_count)
		granted.chests[item.chest_id] = item.chest_count
	if item.card_days > 0:
		MetaManager.monthly_card_end_day = DayClock.today() + item.card_days
		MetaManager.monthly_card_last_paid_day = 0
		granted.gems += collect_monthly_card()
	return granted


## Pays today's monthly-card gems once, if a card is running. Called on launch
## and whenever the store opens. A day the game isn't opened is not paid later.
## Returns the gems paid (0 if nothing was due).
func collect_monthly_card() -> int:
	var card: Resource = _monthly_card_item()
	var today: int = DayClock.today()
	if card == null or today >= MetaManager.monthly_card_end_day:
		return 0
	if MetaManager.monthly_card_last_paid_day >= today:
		return 0
	MetaManager.monthly_card_last_paid_day = today
	MetaManager.award_gems(card.daily_gems)  # saves
	return card.daily_gems


## Days the monthly card still pays, today included. 0 = not running.
func monthly_card_days_left() -> int:
	return maxi(MetaManager.monthly_card_end_day - DayClock.today(), 0)


func is_deal_bought_today(item: Resource) -> bool:
	return MetaManager.daily_deals_day == DayClock.today() \
			and item.item_id in MetaManager.daily_deals_bought


## Starts a new store visit: repeat-buy discounts reset, as in Archero when you
## leave the screen. The store screen calls this when its tab is shown.
func reset_session() -> void:
	_session_buys.clear()


func _complete(item: Resource) -> void:
	_session_buys[item.item_id] = int(_session_buys.get(item.item_id, 0)) + 1
	if item.one_time and not item.item_id in MetaManager.bought_items:
		MetaManager.bought_items.append(item.item_id)
	if item.daily_deal:
		var today: int = DayClock.today()
		if MetaManager.daily_deals_day != today:
			MetaManager.daily_deals_day = today
			MetaManager.daily_deals_bought = []
		MetaManager.daily_deals_bought.append(item.item_id)
	var granted := grant(item)
	MetaManager.save()
	EventBus.store_item_purchased.emit(item.item_id)
	purchase_completed.emit(item, true, granted)


func _on_provider_completed(item: Resource, success: bool) -> void:
	_pending.erase(item.item_id)
	if success:
		_complete(item)
	else:
		purchase_completed.emit(item, false, {})


## The lowest chapter-pack chain index not yet bought (0 when all are).
func _next_chain_index() -> int:
	var lowest: int = 0
	for item in items:
		if item.chain_index <= 0 or item.item_id in MetaManager.bought_items:
			continue
		if lowest == 0 or item.chain_index < lowest:
			lowest = item.chain_index
	return lowest


## The (single) monthly card item. One card's state is saved; a second card
## type would need its own fields.
func _monthly_card_item() -> Resource:
	for item in items:
		if item.card_days > 0:
			return item
	return null
