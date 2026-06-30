# Epic 03 — Draft System

> Prerequisite: Epic 02 complete and all its acceptance criteria verified.
> Goal: After each wave, a 3-card draft opens. Player picks a spell or stat
> upgrade. Tower gains the spell and fires it. Synergy tags accumulate and
> bonuses fire at thresholds. **v1 scope: 3 spells, 3 stat upgrades, 3 synergy
> tags** — see `project.md` "V1 Scope vs. Future Scope" before starting. Do
> not build the other 22 spells/6 tags from the original design backlog now;
> this epic's job is to prove the *system* works generically, not to fill out
> content.
> Completed epic delivers: a full run loop — fight, draft, fight, draft, with
> the v1 synergies building up correctly.

---

## Task 03-01 — Create the 3 V1 Spell Resource Files

**Folder**: `res://resources/spells/`
**Ref**: `mechanics.md` Section 4, `project.md` Tower section

One projectile spell, one AoE spell, one passive spell — enough to exercise
every `SpellCategory` branch in `tower.gd`'s `_fire_spell()`.

- [ ] `spell_basic_bolt.tres`: `spell_id="basic_bolt"`, `spell_name="Bolt"`,
	  `damage=40`, `cooldown=1.0`, `range=8.0`,
	  `damage_type=Constants.DamageType.NORMAL`,
	  `spell_category=Constants.SpellCategory.PROJECTILE`,
	  `tags=[Constants.SynergyTag.OFFENSE]`, `rarity=COMMON`.
	  (This also doubles as the tower's `starting_spell_id` — see
	  `tower_default.tres`.)
- [ ] `spell_basic_aoe.tres`: `spell_id="basic_aoe"`, `spell_name="Burst"`,
	  `damage=70`, `cooldown=2.5`, `range=7.0`, `aoe_radius=2.0`,
	  `damage_type=Constants.DamageType.MAGIC`,
	  `spell_category=Constants.SpellCategory.AOE_BURST`,
	  `tags=[Constants.SynergyTag.OFFENSE, Constants.SynergyTag.UTILITY]`,
	  `rarity=RARE`.
- [ ] `spell_basic_passive.tres`: `spell_id="basic_passive"`,
	  `spell_name="Hardened Plating"`, `damage=0`, `cooldown=0`, `range=0`,
	  `damage_type=Constants.DamageType.NORMAL` (unused for passives),
	  `spell_category=Constants.SpellCategory.PASSIVE`,
	  `tags=[Constants.SynergyTag.ARMOR]`, `rarity=COMMON`. Behavior: while
	  active, applies a flat damage-reduction modifier (implemented in Task
	  03-05).

> **Extend later by:** adding `spell_<id>.tres` files for any of the
> backlog's other damage types/categories (siege, chaos, chain, etc. — see
> `project.md`'s long-term tag/spell backlog notes). `SpellRegistry`'s
> directory scan (Epic 01) picks up new files automatically.

**Acceptance criteria**:
- [ ] All 3 `.tres` files load with `load()` and expose the fields above with
	  correct values and types (especially `tags` as an `Array[int]` or
	  `Array[Constants.SynergyTag]` matching whatever typing `SpellDefinition`
	  declares).

---

## Task 03-02 — Create the 3 V1 Stat Upgrade Resource Files

**Folder**: `res://resources/upgrades/`
**Ref**: `mechanics.md` Section 4

- [ ] `upgrade_damage.tres`: `upgrade_id="upgrade_damage"`,
	  `upgrade_name="Sharpening"`, `damage_multiplier=1.15`,
	  `tags=[Constants.SynergyTag.OFFENSE]`, `rarity=COMMON`,
	  `is_stackable=true`, `stack_max=4`.
- [ ] `upgrade_fire_rate.tres`: `upgrade_id="upgrade_fire_rate"`,
	  `upgrade_name="Quickened"`, `fire_rate_multiplier=0.90`,
	  `tags=[Constants.SynergyTag.OFFENSE, Constants.SynergyTag.UTILITY]`,
	  `rarity=RARE`, `is_stackable=true`, `stack_max=3`.
- [ ] `upgrade_max_hp.tres`: `upgrade_id="upgrade_max_hp"`,
	  `upgrade_name="Fortify"`, `hp_bonus=200`,
	  `tags=[Constants.SynergyTag.ARMOR]`, `rarity=COMMON`,
	  `is_stackable=true`, `stack_max=5`.

> **Extend later by:** same pattern as spells — new `.tres` files, picked up
> automatically by `SpellRegistry`'s scan.

**Acceptance criteria**:
- [ ] All 3 `.tres` files load correctly with the values above.

---

## Task 03-03 — Confirm SpellRegistry Loads the V1 Set

**File**: `res://autoloads/SpellRegistry.gd`
**Ref**: `components.md` Section 3

- [ ] In `_ready()`, use `DirAccess` to scan `res://resources/spells/` and
	  load all `.tres` files into `all_spells`. Same for
	  `res://resources/upgrades/` into `all_stat_upgrades`.
- [ ] Implement `get_spells_by_tag(tag: int) -> Array`: filter `all_spells`
	  by `spell.tags.has(tag)`.
- [ ] Print the total loaded count in `_ready()` for a quick sanity check.

**Acceptance criteria**:
- [ ] `SpellRegistry.get_all_cards().size() == 6` (3 spells + 3 upgrades) on
	  project start.
- [ ] `SpellRegistry.get_spells_by_tag(Constants.SynergyTag.OFFENSE).size()
	  == 2` (`basic_bolt` and `basic_aoe`).

---

## Task 03-04 — DraftManager Full Implementation

**File**: `res://autoloads/DraftManager.gd`
**Ref**: `mechanics.md` Section 4

- [ ] Add `_draft_trigger: String` var.
- [ ] Implement `open_draft(trigger: String = "wave_clear")`:
  - Set `_draft_trigger = trigger`.
  - Set `GameState.phase = GamePhase.DRAFT`, emit `phase_changed`.
  - Compute draft cards (see below), store result.
  - Emit `EventBus.draft_opened`.
- [ ] Implement `get_draft_cards() -> Array[Resource]`:
  - Get `SpellRegistry.get_all_cards()`.
  - Filter out non-stackable cards already taken, and stackable cards already
	at `stack_max`.
  - Weighted draw of `Constants.DRAFT_CARDS_SHOWN` (3) cards — implement
	`_weighted_draw(pool, count)` using `Constants.CardRarity` weights
	(COMMON 60, RARE 30, EPIC 10 — same weights as the original design,
	reused since rarity weighting isn't part of what changed).
  - Return the array (4-card [Utility]×5 logic is **[LATER]** per
	`mechanics.md` Section 4 — do not build it now; v1 always shows exactly
	3).
- [ ] Implement `select_card(card: Resource)`:
  - Call `GameState.apply_card(card)`.
  - Append to `_taken_cards`.
  - Set `GameState.phase = GamePhase.WAVE`, emit relevant `EventBus` signals
	(`card_selected`, `draft_closed`, `phase_changed`).
  - If triggered by `wave_clear`: call
	`WaveManager.start_wave(GameState.wave_number)`.
  - If triggered by `level_up`: unfreeze enemies (see Task 03-12).

**Acceptance criteria**:
- [ ] `DraftManager.get_draft_cards()` always returns exactly 3 cards while
	  the pool has more than 3 eligible entries.
- [ ] A maxed-out stackable upgrade (at `stack_max`) never appears again in
	  subsequent draft calls.
- [ ] Selecting a card correctly removes the draft UI state and resumes the
	  wave (verified by `phase` returning to `WAVE`).

---

## Task 03-05 — GameState Apply Card (Real Implementation)

**File**: `res://autoloads/GameState.gd`
**Ref**: `mechanics.md` Section 4

- [ ] Implement `apply_card(card: Resource)`:
  - If `card is SpellDefinition`:
	- If `active_spells.size() < Constants.MAX_SPELL_SLOTS`: append to
	  `active_spells`.
	- For each tag in `card.tags`: call `add_tag(tag)`.
	- Find the tower node (group `"tower"`) and call
	  `tower.add_spell(card)` (implement `add_spell()` on `tower.gd` now —
	  instances a `CooldownComponent` child for the new spell and appends to
	  its internal active-spell list, matching the pattern already used for
	  the hardcoded starting spell in Epic 02).
	- **Passive-category spells** (`basic_passive`): instead of going through
	  the cooldown/fire loop, apply their effect as a standing modifier —
	  e.g. `tower_armor += <value derived from the passive>`. Keep this
	  one `if spell.spell_category == PASSIVE:` branch isolated in
	  `apply_card`, not spread across `tower.gd`.
  - If `card is StatUpgradeDefinition`:
	- Apply non-zero deltas: `tower_max_hp += card.hp_bonus` (and add to
	  current `tower_hp` too), `tower_damage_multiplier *=
	  card.damage_multiplier`, `tower_fire_rate_multiplier *=
	  card.fire_rate_multiplier`.
	- For each tag in `card.tags`: call `add_tag(tag)`.

**Acceptance criteria**:
- [ ] Selecting `spell_basic_aoe` mid-run causes the tower to start firing
	  AoE bursts in addition to its starting bolt, on its own independent
	  cooldown.
- [ ] Selecting `upgrade_max_hp` immediately increases both `tower_max_hp`
	  and current `tower_hp` by 200, reflected in the HUD HP bar.
- [ ] Selecting `spell_basic_passive` increases `tower_armor` (or whatever
	  the chosen passive effect is) without adding anything to the tower's
	  active-spell cooldown list.

---

## Task 03-06 — DraftCard Scene & Script

**File**: `res://scenes/ui/DraftCard.tscn`
**Ref**: `components.md` Section 7

- [ ] Create `DraftCard.tscn` with root `PanelContainer`.
- [ ] Add children: `RarityBorder` (`ColorRect` placeholder — real 9-slice
	  art in Epic 06), `IconRect` (`TextureRect` placeholder), `NameLabel`,
	  `DescriptionLabel`, `SelectButton` (or make the whole card tappable via
	  `_gui_input` — pick one, mobile tap-target sizing matters here, see
	  `epic_08_polish.md` for the full mobile-input pass, but size buttons
	  generously now too).
- [ ] Create `draft_card.gd`:
  - `setup(card_data: Resource)`: populate name/description/icon (icon can
	be null/placeholder at v1 — real icons Epic 06), set border color by
	`card_data.rarity`.
  - Signal `card_selected(card_data)`.
  - On tap: brief scale tween feedback, emit `card_selected`.

**Acceptance criteria**:
- [ ] A `DraftCard` instance correctly displays the name/rarity color of
	  whichever card resource it's given.
- [ ] Tapping the card emits `card_selected` with the correct card resource.

---

## Task 03-07 — DraftUI Scene & Script

**File**: `res://scenes/ui/DraftUI.tscn`
**Ref**: `components.md` Section 7

- [ ] Create `DraftUI.tscn` with root `CanvasLayer`, `layer = 10`.
- [ ] Add children: `DimBG` (`ColorRect`, semi-transparent), `Panel`
	  (`VBoxContainer`, centered) containing `TriggerLabel`, `SubLabel`
	  ("Choose an Upgrade"), `CardContainer` (`HBoxContainer`).
- [ ] Hidden by default.
- [ ] Create `DraftUI.gd`:
  - `_ready()`: connect `EventBus.draft_opened`/`draft_closed`.
  - `_on_draft_opened()`: get cards from `DraftManager.get_draft_cards()`,
	clear and repopulate `CardContainer` with `DraftCard` instances,
	connect each `card_selected` → `_on_card_selected`, show with a fade-in.
  - `_on_card_selected(card)`: call `DraftManager.select_card(card)`.
  - `_on_draft_closed()`: fade out, hide, free `DraftCard` children.

**Acceptance criteria**:
- [ ] Clearing a wave visibly opens the draft panel with exactly 3 distinct
	  cards.
- [ ] Picking a card visibly closes the panel and resumes gameplay.

---

## Task 03-08 — Wire Draft Into Game Loop

**File**: `res://scenes/main/GameWorld.gd`

- [ ] In `_on_wave_cleared(wave_number)`: replace the Epic 02
	  "start next wave after 1 second" stub with
	  `DraftManager.open_draft("wave_clear")`.
- [ ] In `_on_phase_changed(phase)`: `DRAFT` → pause enemy movement/attack
	  (see Task 03-12); `WAVE` → resume.
- [ ] Connect `EventBus.level_up` → `_on_level_up(level)`:
  - If `GameState.phase == GamePhase.WAVE`: freeze enemies.
  - Call `DraftManager.open_draft("level_up")`.

**Acceptance criteria**:
- [ ] Clearing a wave opens the draft instead of immediately starting the
	  next wave.
- [ ] Leveling up mid-wave pauses combat and opens the draft, then resumes
	  correctly after a pick.

---

## Task 03-09 — Synergy Tag System (V1 Implementation)

**File**: `res://autoloads/GameState.gd`
**Ref**: `mechanics.md` Section 6, `project.md` Synergy Tags table,
`components.md` Section 0 (Balance Editing Cheat Sheet) and Section 2's
"Balance tuning constants" block

> **Rule**: every magnitude below must read from the named constant in
> `Constants.gd`, never be re-typed as a literal inside this `match`
> statement. If a number appears here as a literal in your implementation,
> stop and pull it into `Constants.gd` first — this is the one rule this
> task cannot skip, since it's the entire point of the constants block added
> in `components.md` Section 2.

- [ ] Implement `_apply_synergy_bonus(tag: int, level: int)` with exactly the
	  3 v1 tags from `project.md`, every value sourced from `Constants.gd`:
  - `[Offense]×3`: `tower_damage_multiplier *=
	Constants.OFFENSE_TIER1_DAMAGE_MULT`.
  - `[Offense]×5`: set `bonus_projectile_every_n =
	Constants.OFFENSE_TIER2_BONUS_SHOT_N`; track shot count in `tower.gd`'s
	firing logic and fire one extra bolt at the current target every Nth
	shot when this flag is set.
  - `[Armor]×3`: set `damage_reduction =
	Constants.ARMOR_TIER1_DAMAGE_REDUCTION`; apply this as a final
	multiplier in `CombatUtils.calculate_damage()` **only for damage where
	the target is the tower** (pass an `is_tower_target: bool` param or
	equivalent — do not apply tower-only reduction to enemy-taken damage).
  - `[Armor]×5`: set `armor_regen_active = true`; start a repeating `Timer`
	in `GameState` at `Constants.ARMOR_TIER2_REGEN_INTERVAL` seconds that
	calls `heal(tower_max_hp * Constants.ARMOR_TIER2_REGEN_PERCENT)` while
	active.
  - `[Utility]×3`: `tower_fire_rate_multiplier *=
	Constants.UTILITY_TIER1_COOLDOWN_MULT`.
  - `[Utility]×5`: set `draft_shows_four_cards = true` — note this flag is
	intentionally **not consumed anywhere yet** (4-card draft is **[LATER]**
	per Task 03-04); set the flag for forward-compatibility but do not branch
	on it in `DraftManager` this epic.
- [ ] `add_tag(tag)` (already declared in Epic 01) now actually calls this on
	  threshold crossing.

**Acceptance criteria**:
- [ ] Grep the implemented `_apply_synergy_bonus()` for bare numeric literals
	  (`1.1`, `0.9`, `0.15`, `10`, `5.0`, `0.01`, etc.) — there should be
	  **zero**; every magnitude must trace back to a `Constants.gd` entry.
	  Confirm this explicitly, it's the actual test of whether the
	  "balance without touching code" promise holds for this system.
- [ ] Picking 3 cards tagged `[Offense]` triggers exactly one
	  `synergy_threshold_reached(OFFENSE, 3)` emit and visibly increases
	  tower damage output by exactly `Constants.OFFENSE_TIER1_DAMAGE_MULT`
	  (verify via a controlled before/after damage number on the same enemy
	  type).
- [ ] Continuing to `[Offense]×5` causes a bonus projectile to fire on
	  exactly every `Constants.OFFENSE_TIER2_BONUS_SHOT_N`th shot, no more,
	  no less (count shots in a test run).
- [ ] `[Armor]×3` reduces tower-incoming damage by exactly
	  `Constants.ARMOR_TIER1_DAMAGE_REDUCTION` without affecting damage the
	  tower deals to enemies.
- [ ] **Balance-change smoke test**: change
	  `Constants.OFFENSE_TIER1_DAMAGE_MULT` from `1.10` to `1.25` in the
	  Inspector/constants file only (no other edits), rerun, and confirm the
	  `[Offense]×3` damage bump now matches the new value exactly. This is
	  the literal scenario you'll do constantly while balancing — it must
	  work with zero script edits.

---

## Task 03-10 — SynergyBanner Scene & Script

**File**: `res://scenes/ui/SynergyBanner.tscn`
**Ref**: `components.md` Section 7

- [ ] Create `SynergyBanner.tscn`, root `CanvasLayer`, `layer = 20`.
- [ ] `BannerPanel` (hidden by default) with `TagIcon` (`TextureRect`
	  placeholder) and `BannerLabel`.
- [ ] `synergy_banner.gd`: on `EventBus.synergy_threshold_reached`, set label
	  text from a lookup table of tag+level → description string (only the 3
	  v1 tags need entries), slide down from top, hold ~2s, slide back up.

**Acceptance criteria**:
- [ ] Reaching `[Armor]×3` shows a banner with correct, readable text, then
	  auto-dismisses without manual interaction.

---

## Task 03-11 — TagRowWidget Scene & Script

**File**: `res://scenes/ui/TagRowWidget.tscn`
**Ref**: `components.md` Section 7

- [ ] Create `TagRowWidget.tscn`, root `HBoxContainer`, added to `HUD.tscn`.
- [ ] `tag_row_widget.gd`: on `GameState.tag_count_changed`, find-or-create a
	  small widget per tag (icon placeholder + "×N" label), update count.

**Acceptance criteria**:
- [ ] Picking any tagged card immediately updates that tag's visible count in
	  the HUD.

---

## Task 03-12 — Enemy Freeze/Unfreeze for Draft Pauses

**File**: `res://scenes/enemies/Enemy.tscn`/`enemy.gd`

- [ ] Implement `freeze()`/`unfreeze()` on `enemy.gd`: toggles whether
	  `MoveToTargetComponent` and the attack `CooldownComponent` tick. Do not
	  use `get_tree().paused` for this (that would also pause UI tweens and
	  the draft animations themselves) — toggle per-enemy instead.
- [ ] `GameWorld.gd`: on entering `DRAFT` phase, call `freeze()` on every
	  node in group `"enemies"`; on leaving, call `unfreeze()`.

**Acceptance criteria**:
- [ ] Enemies visibly stop moving and stop attacking the instant the draft
	  panel opens, and resume exactly where they left off (not reset) when
	  the draft closes.

---

## Task 03-13 — Integration Test

- [ ] Run the project.
- [ ] Kill all enemies in wave 1. Verify DraftUI appears with exactly 3
	  cards.
- [ ] Pick a card. Verify: if spell, tower starts firing the new spell type
	  (visible second projectile/AoE behavior); if stat, tower HP or damage
	  visibly changes.
- [ ] Verify tag count increments in the `TagRowWidget`.
- [ ] Pick enough `[Offense]` cards to hit ×3, then ×5. Verify
	  `SynergyBanner` appears each time with correct text, and verify the
	  actual gameplay effect (damage bump at ×3, bonus shot every 10th at
	  ×5).
- [ ] Reach level 2 mid-combat. Verify enemies freeze and DraftUI opens
	  mid-wave; verify enemies resume correctly after the pick.
- [ ] Verify all 3 spells and all 3 upgrades are reachable across multiple
	  runs (check `SpellRegistry`'s loaded count and draft variety in
	  Output).
- [ ] Fix all errors before moving to Epic 04.
