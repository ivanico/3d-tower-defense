@tool
extends Control

## Store tab (10-04; a nav-bar tab, Archero-style, since 10-02). Scrolling
## sections, top to bottom in Constants.StoreSection order, each a grid of
## `store_item_card`s.
##
## Content-only, like the other tab screens: it lives in `world_map.gd`'s shell,
## which owns the NavBar and calls `set_active()` / `_refresh()`.
##
## This screen only draws: what shows, what it costs and whether it can be
## bought all come from StoreService, and a tap goes to StoreService.purchase().
## Adding an item = a new `.tres` in resources/store/; no change here.
##
## Preview: in the editor the sections are built from every item file (chapter
## packs: the first only; daily deals: the first few), since StoreService and
## the save don't run there. Built cards have no owner, so they're never saved
## into the scene.

const ConstantsScript := preload("res://autoloads/constants.gd")
const StoreServiceScript := preload("res://autoloads/store_service.gd")
const CARD_SCENE := preload("res://scenes/ui/widget/store_item_card/store_item_card.tscn")
const REWARD_POPUP_SCENE := preload("res://scenes/ui/widget/reward_popup/reward_popup.tscn")
const RewardPopupScript := preload("res://scenes/ui/widget/reward_popup/reward_popup.gd")
const OverlayHostScript := preload("res://scenes/ui/widget/overlay_screen/overlay_host.gd")

const SECTION_TITLES := {
	ConstantsScript.StoreSection.DAILY_DEALS: "Daily Deals",
	ConstantsScript.StoreSection.OFFERS: "Special Offers",
	ConstantsScript.StoreSection.CHESTS: "Chests",
	ConstantsScript.StoreSection.BASE_MATERIAL: "Base Material",
	ConstantsScript.StoreSection.GEMS: "Gems",
	ConstantsScript.StoreSection.ENERGY: "Energy",
	ConstantsScript.StoreSection.SKINS: "Skins",
}
const GRID_COLUMNS := 3
const GRID_SEPARATION := 20
const SECTION_TITLE_FONT_SIZE := 40

@onready var top_bar: Control = $TopBar
@onready var sections_box: VBoxContainer = $ScrollContainer/Sections


func _ready() -> void:
	if Engine.is_editor_hint():
		_build(_editor_sections())
		return
	StoreService.purchase_completed.connect(_on_purchase_completed)
	_refresh()


## Called by the shell when the tab is shown or hidden. Showing it starts a new
## store visit (repeat-buy discounts reset, as when you leave Archero's shop)
## and pays any monthly-card gems due today.
func set_active(active: bool) -> void:
	if not active:
		return
	StoreService.reset_session()
	StoreService.collect_monthly_card()
	_refresh()


func _refresh() -> void:
	top_bar.refresh()
	_build(_runtime_sections())


## [[section, items], ...] for every section with something to show.
func _runtime_sections() -> Array:
	var result: Array = []
	for section in ConstantsScript.StoreSection.values():
		var items: Array = StoreService.visible_items(section)
		if not items.is_empty():
			result.append([section, items])
	return result


func _editor_sections() -> Array:
	var by_section := {}
	var deals := 0
	for item in StoreServiceScript.load_sorted():
		if item.section == ConstantsScript.StoreSection.SKINS or item.chain_index > 1:
			continue
		if item.daily_deal:
			deals += 1
			if deals > ConstantsScript.DAILY_DEALS_SHOWN:
				continue
		if not by_section.has(item.section):
			by_section[item.section] = []
		by_section[item.section].append(item)
	var result: Array = []
	for section in ConstantsScript.StoreSection.values():
		if by_section.has(section):
			result.append([section, by_section[section]])
	return result


func _build(sections: Array) -> void:
	for child in sections_box.get_children():
		sections_box.remove_child(child)
		child.queue_free()
	for entry in sections:
		var title := Label.new()
		title.text = SECTION_TITLES.get(entry[0], "")
		title.add_theme_font_size_override("font_size", SECTION_TITLE_FONT_SIZE)
		title.add_theme_color_override("font_color", Color(1, 1, 1))
		sections_box.add_child(title)
		var grid := GridContainer.new()
		grid.columns = GRID_COLUMNS
		grid.add_theme_constant_override("h_separation", GRID_SEPARATION)
		grid.add_theme_constant_override("v_separation", GRID_SEPARATION)
		sections_box.add_child(grid)
		for item in entry[1]:
			var card: Control = CARD_SCENE.instantiate()
			grid.add_child(card)
			_show_card(card, item)


func _show_card(card: Control, item: Resource) -> void:
	if Engine.is_editor_hint():
		var price: int = item.gem_prices[0] if not item.gem_prices.is_empty() else 0
		card.show_item(item, price, true, "")
		return
	var block: int = StoreService.block_reason(item)
	card.show_item(item, StoreService.current_gem_price(item),
			block != StoreServiceScript.Block.CANT_AFFORD, _note_for(block))
	card.buy_pressed.connect(_on_buy_pressed)


## The note line for a blocked card ("" = buyable).
func _note_for(block: int) -> String:
	match block:
		StoreServiceScript.Block.CANT_AFFORD:
			return "Not enough gems"
		StoreServiceScript.Block.AD_NOT_READY, StoreServiceScript.Block.CHEST_NOT_READY:
			return "Coming soon"
		StoreServiceScript.Block.CARD_ACTIVE:
			return "%d days left" % StoreService.monthly_card_days_left()
		StoreServiceScript.Block.BOUGHT:
			return "Bought"
		StoreServiceScript.Block.PENDING:
			return "Buying…"
	return ""


func _on_buy_pressed(item: Resource) -> void:
	if StoreService.purchase(item):
		_refresh()  # shows "Buying…" while a real-money purchase is in flight


## Redraws, then shows what was bought in the shared reward popup (through the
## 10-01 host; none when this screen runs on its own, e.g. F6).
func _on_purchase_completed(_item: Resource, success: bool, granted: Dictionary) -> void:
	_refresh()
	if not success:
		return
	var rewards: Array = RewardPopupScript.rewards_for_store_item(granted)
	var host := get_tree().get_first_node_in_group(OverlayHostScript.GROUP)
	if rewards.is_empty() or host == null:
		return
	var popup: Control = host.open(REWARD_POPUP_SCENE)
	popup.show_rewards(rewards)
