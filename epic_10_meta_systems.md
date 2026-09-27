# Epic 10 — Meta Systems & Screens

> Prerequisite: Epic 09 tasks 09-01 (save versioning) and 09-02 (docs cleanup).
> The rest of Epic 09 can run in parallel.
> **Rules**: see `epic_09_content.md` → "Rules for Epics 09–13" (placeholders,
> previews, follow the skills/docs, decisions are yours, one task at a time,
> no git).
> Goal: every out-of-run screen a shipped mobile game needs (store, chests,
> daily rewards, settings, pause menu, tutorial), reachable from the home
> screen and previewable in the editor. Real money and real ads stay **out**
> of this epic; they're Epic 12. Here the store works with a **fake purchase
> provider**, so every flow can be built and tested first.
> Source: `remaining_to_do_list.md` section **B**, plus **D1** and the
> placeholder half of **D2**.
> Completed epic delivers: a home screen with Store / Chests / Daily /
> Settings entry points, each opening a working screen; a pause menu; a
> tutorial; the wave-timeout warning.

---

## Task 10-00 — Decision Gate: Meta [DECISION NEEDED]

**Covers**: B4, B10 and the design inputs this epic needs.

- [ ] **Store entry point.** Options:
  - (a) a 4th nav-bar tab. Store icons already exist: `nav/icon_nav_store.png`,
    `_v2_blue`, `_v3_purple`, and you pick the version. Note the nav bar keeps
    World Map in the middle on purpose, so a 4th tab changes that layout.
  - (b) a button on the home screen that opens the store over it.

  Answer: ______
- [ ] **What the store sells at launch** (layout only here, real prices in
      Epic 12): gem packs / energy / tower unlocks (if A2 includes store) /
      skins / chests / offers. Answer: ______
- [ ] **Where chests come from**: run rewards / store / daily reward /
      keys. Also what's inside them (materials, scrolls, gems, tower
      material…). Answer: ______
- [ ] **B4 — Daily rewards**: login calendar? streak? daily quests?
      achievements? Pick the launch scope. Answer: ______
- [ ] **Energy refill**: gem cost? rewarded ad (Epic 12)? both? how much per
      refill? Answer: ______
- [ ] **Pause menu Restart**: does restarting a run cost energy again?
      Answer: ______
- [ ] **B10 — Dead code**: remove or keep each of
      - `TowerDefinition.starting_spell_id` + `tower.gd._load_starting_spell()`
      - the synergy tag system (`SynergyTag`, `tag_counts`, `synergy_banner`,
        `tag_row_widget`, still driving card pill labels)
      - `TowerDefinition.model_path` / `EnemyDefinition.model_path` /
        `ChapterDefinition.arena_model_path`

      Answer per item: ______
- [ ] **Tutorial content** (feeds 10-10): what must a first-time player be
      taught, and in what order? Answer: ______

**Acceptance criteria**:
- [ ] Every blank filled or explicitly marked "later".

---

## Task 10-01 — Overlay Screen Host (one mechanism for every popup screen)

**Files**: `scenes/ui/world_map.tscn` / `.gd`, new
`scenes/ui/widget/overlay_screen/overlay_screen.tscn` / `.gd`

Store, Chests, Daily, Settings, and the reward popup all open over the home
screen and close back to it. They share **one** host so the open/close
animation, dim background, back button and input blocking exist once (no
duplicated code).

- [ ] An `OverlayLayer` in the `world_map.tscn` shell (above Track, below
      the `LoadingScreen`) with `open(scene: PackedScene)` / `close()`. It
      provides a dim background, a slide/fade in, and a close (X) button.
      Close reuses `common/ui_button_x_red_square_clean_transparent.png`,
      which already exists.
- [ ] Opened screens get a `_refresh()` call, same as tab screens do today.
- [ ] Android back / Escape closes the top overlay first (full back-button
      handling in 10-08).
- [ ] If 10-00 chose the store as a **nav tab**, the Store screen goes into the
      Track as a 4th slot instead, and this host is still used by
      Chests/Daily/Settings/rewards.

**Placeholders**: none (reuses existing X button art).
**Preview**: `overlay_screen.tscn` opens in the editor showing the dim, the frame
and the X over a sample child.

**Acceptance criteria**:
- [ ] Any content scene can be opened and closed through this one API.
- [ ] Nav-bar sliding still works, and taps can't reach the screen underneath
      while an overlay is open.

---

## Task 10-02 — Home Screen Entry Points (+ preview)

**Files**: `scenes/ui/world_map_content.tscn` / `.gd`, new
`scenes/ui/widget/home_side_button/`

- [ ] A small `@tool` `home_side_button` widget: icon, optional label, and
      an optional notification badge (reuse `ui_notification_badge.png` and
      the badge knobs `nav_button` already has; share the code, don't copy
      it).
- [ ] Add Store / Chests / Daily / Settings buttons to the home screen in the
      layout you approve. Each calls the 10-01 host. The Daily and Chests
      badges light up when something can be claimed or opened.
- [ ] The buttons exist before their screens: each opens a "Coming soon"
      placeholder until its task (10-04 … 10-09) lands. That way the home
      screen layout can be reviewed on its own.

**Placeholders**:

| Button | Placeholder | Final file |
|---|---|---|
| Store | one of `nav/icon_nav_store*.png`, your pick | `world_map/icon_home_store.png` |
| Chests | `rewards/icon_chest_common.png` (exists) | — |
| Daily | drawn calendar | `world_map/icon_home_daily.png` |
| Settings | drawn gear | `world_map/icon_home_settings.png` |

**Preview**: `world_map_content.tscn` shows all four buttons (one with its badge
on) in the editor. `home_side_button.tscn` previews on its own.

**Acceptance criteria**:
- [ ] You approve the home layout from the editor preview before 10-04 starts.
- [ ] Each button opens its (placeholder) screen and closes back.

---

## Task 10-03 — Premium Currency (Gems)

**Covers**: B2 · **Files**: `MetaManager`, `SaveData` (field added in 09-01),
`widget/top_bar/`

- [ ] `MetaManager.award_gems(n)` / `spend_gems(n) -> bool`: save
      immediately and emit `EventBus.gems_changed`. `premium_currency` is the
      field (it already exists); expose it under one name.
- [ ] A third `currency_pill` in `top_bar.tscn`, with the same widget and the
      same `icon_scale` correction method (`ui_tuning.md` "Icons are not the
      size you think": measure with `Image.get_used_rect()`).
- [ ] Gems are only granted in the store (10-04), rewards (10-05/10-06) and
      dev tools. There is no free gem source by accident.

**Placeholders**: gem icon = `topbar/icon_currency_materials1.png` tinted pink /
purple → final `topbar/icon_currency_gems.png`.
**Preview**: `top_bar.tscn` shows three pills.

**Acceptance criteria**:
- [ ] Gems persist, display on every meta screen, and can't go negative.

---

## Task 10-04 — Store Screen

**Covers**: B1, D2 (placeholders) · **Blocked by**: 10-00 (entry point, catalog).
**Files**: new `scenes/ui/store_content.tscn` / `.gd`,
`scenes/ui/widget/store_item_card/`, `resources/store/store_item_definition.gd`
+ `*.tres`, `autoloads/store_service.gd` (or a run-agnostic helper, to be
confirmed)

- [ ] **Items are data**: `StoreItemDefinition` holds id, name, section, icon,
      price type (real money / gems / ad), price, and what it grants (gems,
      energy, tower unlock via 09-05, skin, chest, bundle). Items are loaded
      with the shared `ResourceDir` scan. Adding an item = a new `.tres`.
- [ ] **Purchase goes through one interface**: `StoreService.purchase(item)` →
      provider → on success, `grant(item)`. The **fake provider**
      (editor/desktop, and any build with a dev flag) succeeds instantly.
      Epic 12 swaps in Google Play Billing without touching the store UI.
- [ ] Gem-priced items spend gems (10-03) directly; no provider needed.
- [ ] `store_item_card` is a `@tool` widget that shows the icon, name, price
      chip and a "best value"/"offer" ribbon. The price chip reuses `cost_chip`
      where possible.
- [ ] Sections are scrollable (reuse the codex `ScrollContainer` rules,
      `horizontal_scroll_mode = 0`).
- [ ] After a purchase, the reward popup from 10-05 shows what was granted.

**Placeholders (D2)**:

| Thing | Placeholder | Final file |
|---|---|---|
| Card background | `common/ui_panel_dark_v2.png` at its correct 0.73 aspect | `store/ui_store_card_bg.png` |
| Gem pack art | gem icon at 3 sizes | `store/icon_store_gems_s/m/l.png` |
| Ad button | drawn | `store/ui_store_ad_button.png` |
| Offer ribbon | drawn | `store/ui_store_ribbon.png` |
| Store background | `garage/bg_garage.png` | `store/bg_store.png` |

Add a `ui_store` / `bg_store` prefix to the `ui_icon_cap` `SIZE_RULES` if
these are drawn larger than 256px.
**Preview**: `store_content.tscn` shows each section filled with placeholder
cards in the editor. `store_item_card.tscn` has `preview_*` knobs for each
price type.

**Acceptance criteria**:
- [ ] With the fake provider, buying each item type grants exactly what its
      `.tres` says and persists after restart.
- [ ] Adding a new `.tres` adds a card with no code or scene change.

---

## Task 10-05 — Reward Popup + Chests

**Covers**: B3 · **Blocked by**: 10-00 (chest sources/contents).
**Files**: `scenes/ui/widget/reward_popup/`, `resources/chests/chest_definition.gd`
+ `chest_common/rare/epic.tres`, new `scenes/ui/chests_content.tscn`

- [ ] **`reward_popup`**: one widget that shows a list of `icon × amount`
      rewards with a pop-in. It's used by chests, the store, daily rewards,
      and optionally the victory screen, which is the only place a reward
      reveal exists today. Built once.
- [ ] **Chests are data**: a `ChestDefinition` holds its icons (closed/open),
      the key it needs, and a loot table via `scripts/weighted_table.gd` (the
      existing helper). Owned chests and keys go in `SaveData` (+ migration).
- [ ] Chests screen: owned chests, keys and an Open button. Opening plays a
      closed → open swap and then the `reward_popup`.
- [ ] Chest sources wired as decided in 10-00, each calling one
      `MetaManager.award_chest(id)`.

**Placeholders**: none needed for chests, since all 16 reward icons exist
(`rewards/icon_chest_*`, `icon_key_*`, `icon_mat_scroll_*`,
`icon_mat_tower_rare*`). Opening FX: a scale/flash tween, not particles
(particle VFX are on your "not wanted" list).
**Preview**:
- `chests_content.tscn` shows one of each chest + keys.
- `reward_popup.tscn` has a `preview_rewards` knob listing sample rewards.

**Acceptance criteria**:
- [ ] Opening each chest type gives rewards from its table. Chests and keys
      persist. The reward popup is the same scene everywhere it appears.

---

## Task 10-06 — Daily Rewards / Login Bonus

**Covers**: B4 · **Blocked by**: 10-00 answer for B4.

- [ ] Build only the decided scope. Rewards are data (a `.tres` calendar, or
      a quest list if quests were chosen).
- [ ] `SaveData`: last claim day and streak (+ migration). Day boundaries
      come from the device clock in **local** time. The clock can be cheated
      until a server exists (F5/F8, Epic 12/13); note that here and move on.
- [ ] Claiming uses the `reward_popup` (10-05). The home screen Daily badge
      shows when something is claimable.

**Placeholders**: day-cell frame drawn with `StyleBoxFlat` → final
`daily/ui_daily_cell.png` / `ui_daily_cell_claimed.png`.
**Preview**: `daily_content.tscn` shows a full week: claimed, today, and future.

**Acceptance criteria**:
- [ ] One claim per day. The streak follows the decided rules and survives
      a restart.

---

## Task 10-07 — Energy Countdown + Refill

**Covers**: B5 · **Files**: `MetaManager`, `widget/top_bar/` or
`widget/currency_pill/`, world map

Today energy only regenerates in `_apply_offline_energy_regen()` **on load**.
A player sitting on the home screen never gains energy until they restart.

- [ ] `MetaManager` ticks regen while the game runs (a `Timer`, same interval
      math as the offline catch-up, shared, not copied) and exposes
      `seconds_to_next_energy()`.
- [ ] The energy pill shows `mm:ss` under or beside the amount while below
      max. It's a knob on the pill widget, so only the energy pill uses it.
- [ ] Refill as decided in 10-00: a gem button, and an ad button that calls
      the Epic 12 ad hook. Until Epic 12 the ad button is disabled with the
      note "coming soon". The existing "Not enough energy" message offers
      refill.

**Placeholders**: refill popup uses the 10-01 host + existing buttons; no new
art.
**Preview**: `currency_pill.tscn` has a `preview_countdown` knob;
`world_map_content.tscn` shows the energy pill with a countdown.

**Acceptance criteria**:
- [ ] Energy regenerates while the game stays open, the countdown is right,
      and refill works by the decided method(s).

---

## Task 10-08 — Pause Menu (+ Android back button)

**Covers**: B6 · **Files**: new `scenes/ui/pause_menu.tscn` / `.gd`,
`scenes/main/hud.gd`, `scenes/main/game_world.gd`
**Refs**: `components.md` §7 "Who is allowed to pause" (read it first; this
must not become a 5th writer that fights the others)

- [ ] Pause menu (CanvasLayer, `process_mode = ALWAYS`) with Resume /
      Restart / Back to map / Music & SFX sliders. It opens from the existing
      `pause_button`, through the same `hud.gd` writer. It's only available in
      the WAVE phase, as today.
- [ ] Restart follows the 10-00 energy answer. Back to map ends the run
      (forfeit) and returns to the world map.
- [ ] Volume sliders: a shared `volume_slider_row` widget, also used by 10-09.
      Values save to `MetaManager.music_volume` / `sfx_volume` (already in
      `SaveData`) and call `AudioManager` (a no-op until Epic 11).
- [ ] **Android back / Escape**: bind `ui_cancel`, turn off auto-quit on
      back (`application/config/quit_on_go_back`), and handle the go-back
      request. Back behaves as follows:
      - in a run: opens or closes the pause menu
      - on an overlay: closes it
      - on the home screen: shows an "Exit game?" confirm

      One handler decides this; the rest don't each listen.
- [ ] Explicitly test: pressing back during a draft does nothing harmful.

**Placeholders**: panel = `common/ui_panel_dark_v2.png` (exists); buttons =
`primary_button` / `secondary_button` widgets.
**Preview**: `pause_menu.tscn` opens in the editor fully laid out;
`volume_slider_row.tscn` on its own.

**Acceptance criteria**:
- [ ] Every button works. Pausing can't un-pause a draft or a defeat screen.
- [ ] Back behaves as listed above on a real Android device (checked again
      in 13-03).

---

## Task 10-09 — Settings Screen

**Covers**: B7 · **Files**: new `scenes/ui/settings_content.tscn` / `.gd`

- [ ] Music / SFX: the same `volume_slider_row` as 10-08.
- [ ] Vibration toggle: a `SaveData` field (+ migration). Vibration goes
      through one helper that checks the toggle. The Android export needs the
      vibrate permission (note it for 13-01).
- [ ] Language: the row exists but is disabled until F9 is decided (13-00 /
      13-07).
- [ ] Credits: a scrollable text page (the font OFL notices go here too:
      Baloo 2, Nunito).
- [ ] Privacy policy: opens a URL from one `Constants` value. It's a
      placeholder URL until G2 (13-09).
- [ ] Privacy/consent options row: hidden until Epic 12 (C5) needs it.

**Placeholders**: section icons drawn or omitted → optional final
`settings/icon_settings_<name>.png`. Privacy URL `https://example.com/privacy`
→ the real hosted URL (G2).
**Preview**: `settings_content.tscn` shows every row in the editor.

**Acceptance criteria**:
- [ ] Settings persist after restart; vibration actually toggles on device.

---

## Task 10-10 — Tutorial / First-Time Experience

**Covers**: B8 · **Blocked by**: 10-00 tutorial content.

- [ ] `SaveData`: tutorial steps completed (+ migration). A step never shows
      twice.
- [ ] One reusable `tutorial_hint` overlay widget: dim, a cut-out/highlight
      around a target Control or screen point, an arrow, and text. Steps are
      data (a `.tres` list: trigger event → target → text), triggered by
      `EventBus` signals such as the first draft, first wave or first level-up.
      No tutorial `if`s scattered through gameplay scripts.
- [ ] The first run may be forced or simplified as 10-00 decides.
- [ ] Settings gets a "Replay tutorial" row.

**Placeholders**: arrow and highlight are drawn → optional final
`hud/ui_tutorial_arrow.png`.
**Preview**: `tutorial_hint.tscn` has `preview_text` / `preview_target_rect`
knobs showing a sample step.

**Acceptance criteria**:
- [ ] A fresh save walks through every step once; a replay walks through
      them again.

---

## Task 10-11 — Wave Fallback Timer Warning

**Covers**: B9 · **Files**: `scenes/manager/wave_manager.gd`, `hud.gd`,
`game_world.tscn` (close in editor first), `Constants.gd`

Today a wave force-clears after `WAVE_DURATION_MAX` (60s) with no warning, so
it reads like a bug.

- [ ] `WaveManager` emits `EventBus.wave_time_warning(seconds_left)` when the
      timer passes `Constants.WAVE_WARNING_SEC` (new constant). HUD shows a
      small countdown, flashing in the last seconds.
- [ ] Not shown on the boss wave, if the boss wave has no fallback. Check
      `wave_manager.gd` first.

**Placeholders**: text + tint only.
**Preview**: the HUD countdown is a `@tool` label widget with a
`preview_seconds` knob, visible in its own scene.

**Acceptance criteria**:
- [ ] A stalled wave shows the countdown before it force-clears; normal
      waves never show it.

---

## Task 10-12 — HP Bar Tween / Colour Shift (optional)

**Covers**: D1 · **Files**: `scenes/ui/widget/value_bar_3d/value_bar_3d.gd`,
`bar_3d_style.gd`

- [ ] Two opt-in knobs:
      - `fill_tween_time` (0 = snap, today's behavior)
      - a colour-by-fraction gradient (off = today's fixed red)

      Both are also on `Bar3DStyle`, so enemy and boss styles set them in one
      file each. Defaults keep the current look exactly.
- [ ] Tweening moves `region_rect`/`offset` (no image regeneration), in
      keeping with the widget's existing performance design.

**Placeholders**: none.
**Preview**: `value_bar_3d.tscn` with `editor_preview_fill` shows the gradient
colour at the previewed fraction.

**Acceptance criteria**:
- [ ] With the knobs at default, nothing changes. With them on, the bar
      animates and recolours.

---

## Task 10-13 — Dead Code Cleanup

**Covers**: B10 · **Blocked by**: 10-00 answer per item.

- [ ] Remove or keep each item exactly as answered.
- [ ] Removing an `@export` from a Resource class leaves orphan values in
      `.tres` files. Strip them from every affected `.tres` (grep, then read
      each file, not a sample).
- [ ] Update `components.md` and the other docs to match.

**Placeholders**: none · **Preview**: none.

**Acceptance criteria**:
- [ ] Grep shows zero references to anything removed. The project opens and
      a full run plays with no errors.

---

## Task 10-14 — Integration Test

- [ ] Fresh save: home → every entry point opens and closes; buy one of each
      store item (fake provider); open each chest; claim a daily; refill
      energy; change every setting and restart.
- [ ] In a run: pause / resume / restart / back to map; Android back in every
      state; see the wave-timeout warning; see the tutorial on a fresh save.
- [ ] Old save (from before this epic) loads with nothing lost.
- [ ] Open every preview scene from this epic.
- [ ] Every placeholder listed in `ui_assets.md` "STILL TO MAKE".
