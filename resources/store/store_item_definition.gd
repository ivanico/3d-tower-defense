class_name StoreItemDefinition
extends Resource

## One thing the store sells (10-04). Items are data: a new `.tres` in
## `res://resources/store/` adds a card, with no code or scene change. Every
## amount here is a STARTING value copied from the original Archero where it
## had one, tuned in balancing.
##
## A purchase grants every non-zero field below at once, so a bundle (beginner
## pack, chapter pack) is just an item with several fields set. Towers are never
## a grant (09-00.1): they only come from chests.

@export var item_id: String = ""
@export var display_name: String = ""
@export var icon: Texture2D = null
## Placeholder support, like pill_base's knob: rotates the icon's colours so a
## gem item can borrow the blue materials gem in pink until
## `store/icon_store_gems_*.png` exist. 0 = the art as drawn.
@export_range(-0.5, 0.5, 0.01) var icon_hue_shift: float = 0.0
## Constants.StoreSection.
@export var section: int = 0
## Order inside its section, top/left first. Explicit so renaming a .tres can't
## reshuffle the store.
@export var sort_order: int = 0

@export_group("Price")
## Constants.StorePriceType.
@export var price_type: int = 0
## GEMS items: the price of each buy in a row while the store screen stays
## open; the last entry repeats (Archero: better chest 300 → 280 → 260 → 260).
## One entry = no discount.
@export var gem_prices: Array[int] = []
## REAL_MONEY items: Epic 12's Google Play product id. Empty until then.
@export var product_id: String = ""
## REAL_MONEY items: the price text on the card until Epic 12 reads the real,
## localised price from Google Play. Archero's USD prices (10-04 answer C).
@export var price_label: String = ""
## Ribbon text on the card ("Best value", "Offer"). Empty = no ribbon.
@export var ribbon_text: String = ""

@export_group("Grants")
@export var gems: int = 0
@export var energy: int = 0
@export var base_material: int = 0
## Free revives (10-15).
@export var revives: int = 0
## Chest id (10-05's ChestDefinition) and how many. Opening is 10-05's job.
@export var chest_id: String = ""
@export var chest_count: int = 0

@export_group("Limits")
## True = can be bought once per save (beginner pack, chapter packs).
@export var one_time: bool = false
## Chapter packs: shown one at a time in this order; pack N+1 appears only
## after pack N is bought. 0 = not part of the chain.
@export var chain_index: int = 0
## Daily deals: true = in the pool the day's deals are drawn from.
@export var daily_deal: bool = false
## True = buying opens the chest at once, Archero-style (the Chests section).
## Needs 10-05's opening, so StoreService keeps these unbuyable until then.
## False with a chest grant = the chest is kept unopened (chapter packs).
@export var open_on_buy: bool = false

@export_group("Monthly card")
## > 0 = a monthly card: `gems` on purchase, then `daily_gems` on each login
## day for `card_days` days.
@export var card_days: int = 0
@export var daily_gems: int = 0
