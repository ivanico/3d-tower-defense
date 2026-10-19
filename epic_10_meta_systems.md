# Epic 10 — Meta Systems & Screens

> Prerequisite: Epic 09 (done, `epic_done/epic_09_content.md`), tasks 09-01 (save versioning) and 09-02 (docs cleanup).
> The rest of Epic 09 can run in parallel.
> **Rules**: see `epic_done/epic_09_content.md` → "Rules for Epics 09–13" (placeholders,
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
> tutorial; the wave-timeout warning. Since 10-00 (2026-10-19, "like the
> original Archero") also: Archero energy (20 / 5 per run / 12 min), the
> four daily systems (10-06a–d) and revives (10-15).

---

## Task 10-00 — Decision Gate: Meta [DECISION NEEDED]

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Re-read** the Epic 09 answers first; some affect these questions (e.g.
>   09-00.1 "Store rule": gem chests, 3/day, key included, may hold an unowned tower).
> - **Ask one at a time**, the same way as 09-00, and write answers into the
>   file.

**Covers**: B4, B10 and the design inputs this epic needs.

- [x] **Store entry point.** Options:
  - (a) a 4th nav-bar tab. Store icons already exist: `nav/icon_nav_store.png`,
    `_v2_blue`, `_v3_purple`, and you pick the version. Note the nav bar keeps
    World Map in the middle on purpose, so a 4th tab changes that layout.
  - (b) a button on the home screen that opens the store over it.

  Answer: ✅ (2026-10-12) **(a) a 4th nav-bar tab**, Archero-style, far left:
  Store · Garage · Map · Codex. Icon `nav/icon_nav_store.png`. Built in 10-02
  as a "Coming soon" tab page; 10-04 fills it.
- [x] **What the store sells at launch** (layout only here, real prices in
      Epic 12). **Mostly decided in 09-00.1 "Store rule"**:
      - gems buy **material chests** (3/day, key included, may contain an
        unowned tower)
      - **energy refills** (no limit)
      - **skins**
      - no direct tower purchase, no separate keys

      Still to answer: gem pack sizes and whether there are bundles/offers.
      Answer: ✅ (2026-10-19, user: "make it same as Archero"). Researched
      Archero's store (wiki, guides, App Store IAP list; sources 2019–2026, may
      be dated). Sections in order: Offers → Chests → Base Material → Gems →
      Energy → Skins (hidden until 12-05).
      - **Gems** (real money, prices set in Epic 12; Archero's USD shown for
        reference only): 80 Pile ($0.99) · 500 Heap ($4.99) · 1,200 Bucket
        ($9.99) · 2,500 Barrel ($19.99) · 6,500 Chest ($49.99) · 14,000 Cart
        ($99.99).
      - **Chests** (gems), two kinds like Golden / Obsidian: a cheap one,
        60 gems (50 on repeat buys), and a better one, 300 gems (280, then
        260 on repeat buys while the screen stays open). **No daily limit**:
        this **replaces** 09-00.1's "3 per day". A bought chest needs no key.
      - **Base Material** (gems): 3 packs at 30 / 80 / 200 gems, the
        equivalent of Archero's gold. Amounts set in balancing.
      - **Energy** (see the energy question below): 20 energy for 100 gems.
      - **Offers** (real money): a **beginner pack** (gems + Base Material +
        5 free revives; Archero: 300 gems, 10k gold, 5 revives, $1.99) and
        **chapter packs**, one per chapter, each shown only after the
        previous one is bought (Archero: $6.99, then $10 each).
      - **Monthly card** (Archero: $2.99; pay, get gems now + a small daily
        amount on login) and **daily deals** (rotating, contents to be
        defined in 10-04): **at launch**.
      - **Battle pass**: Archero has one (Battle Pass $4.99, Battle Pass 2
        $16.99), so it moves from post-launch to **launch** (12-06; its
        design questions are asked there).
      - Consequences:
        - **Revives are a new feature** (Archero: on death, one revive for
          30 gems or a free revive). No task covers it yet; add one.
        - Real-money items use the fake provider until Epic 12; ad items are
          disabled ("coming soon") until Epic 12.
- [x] **Where chests come from and what's inside**. The **store** part is
      decided in 09-00.1: materials capped at one energy bar's worth, plus a
      chance of an unowned tower. Still to answer: do chests **also** come
      from runs or daily rewards (each with its key included), and which
      chapter "one energy bar" is measured at (Claude suggested the highest
      cleared chapter)? Answer: ✅ (2026-10-19, user: "highest cleared
      chapter", the rest "just like Archero"):
      - Cap measured at the player's **highest cleared chapter**. With the
        Archero energy below, one full bar = **4 runs** (20 / 5), not 5.
      - Like Archero, a chest opens with **its key or with gems**. Keys are
        **earned** (stage/progress rewards, daily rewards), never sold.
      - Free opens like Archero: the cheap chest **once a day**, the better
        chest **once a week**, each by watching an ad (disabled until
        Epic 12).
      - Still unchanged from 09-00.1: chance of an unowned tower, materials
        only once every tower is owned; odds set in balancing.
- [x] **B4 — Daily rewards**: login calendar? streak? daily quests?
      achievements? Pick the launch scope. Answer: ✅ (2026-10-19, user:
      "like the original Archero", **not Archero 2**). All four at launch,
      as the original Archero does them:
      - **Daily login gift**: 15 days, one claim every 24 h, a missed day
        does **not** reset progress, runs once (not renewable).
      - **Daily quests**: tasks give XP (Archero: log in 10, open a cheap
        chest 10, play 2 stages 15, open the better chest 20, make a
        purchase 20 …); every 20 XP unlocks one reward, up to 100 XP
        (5 rewards). Resets daily.
      - **Achievements**: long-term goals with rewards.
      - **Daily ad reward** (30 gems + a little energy, once a day) and a
        **lucky spin** wheel (free spin, then ad spins, up to 5 a day). Ads
        disabled until Epic 12.
      - Per-day / per-step reward amounts weren't found (guide pages
        blocked); they're set when 10-06 is built. Archero uses server time;
        we use the device clock until a server exists (see 10-06).
      - Scope note: this is much bigger than 10-06's original single
        calendar; 10-06 will likely need splitting (login gift / quests /
        achievements / ad reward + spin).
- [x] **Energy refill**: gem cost? rewarded ad (Epic 12)? both? how much per
      refill? **Decided in 09-00.1: no daily limit on gem refills.**
      Still to answer: price, ad refill yes/no, energy per refill.
      Answer: ✅ (2026-10-19, user: "change the energy as well to be like in
      Archero"):
      - Energy becomes Archero's: **max 20, 5 per run, 1 back every 12 min**
        (today: 5 / 1 / 20 min). Touches `Constants.MAX_ENERGY`,
        `ENERGY_COST_PER_RUN`, `ENERGY_REGEN_INTERVAL_SEC`, and needs a save
        migration (an old save's energy must be scaled, not left at ≤5).
      - Refill: **20 energy for 100 gems**, no daily limit; **ad: +5 energy,
        up to 4 times a day** (disabled until Epic 12).
- [x] **Pause menu Restart**: does restarting a run cost energy again?
      Answer: ✅ (2026-10-19, user: "make it like Archero, no restart").
      **No Restart button.** The pause menu has Resume, Home (ends the run as
      a forfeit; energy is not refunded) and the volume sliders. 10-08's
      "Restart" bullet is dropped.
- [ ] **B10 — Dead code**: remove or keep each of
      - `TowerDefinition.starting_spell_id` + `tower.gd._load_starting_spell()`
      - the synergy tag system (`SynergyTag`, `tag_counts`, `synergy_banner`,
        `tag_row_widget`, still driving card pill labels)
      - `TowerDefinition.model_path` / `EnemyDefinition.model_path` /
        `ChapterDefinition.arena_model_path`

      Answer per item: ✅ (2026-10-19, user picked the recommended option
      for each):
      - `starting_spell_id` + `_load_starting_spell()`: **remove** (field,
        function, and the value in the tower `.tres` files).
      - Synergy tags: **remove the system** (`SynergyTag`, `tag_counts`,
        `synergy_banner` incl. its instance in `game_world.tscn`,
        `tag_row_widget`), **but keep the grey pill label**: general stat
        cards get a plain label-text field that `draft_card.gd` reads instead
        of `tags[0]`.
      - `model_path` (Tower/Enemy) + `arena_model_path`: **remove**, and
        strip their values from every `.tres`.
      - 10-13's extra list (old standalone `tower_garage` / `spell_codex`
        scenes, `CooldownComponent`, `HitboxComponent`, the 5
        `ancient_tower_lvlN.tres`): **remove**, fixing the old codex →
        garage link.
- [x] **Tutorial content** (feeds 10-10): what must a first-time player be
      taught, and in what order? Answer: ✅ (2026-10-19, user):
      - **First run = a short tutorial run** (a few easy waves), modelled on
        Archero's tutorial stage, so the player learns card picking. It ends
        with a **small gem reward**: enough to feel like a gift, not enough to
        buy anything meaningful, nudging toward the store. Amount set in
        balancing. Whether it costs energy: decide in 10-10 (Claude's
        suggestion: free).
      - **9 one-time hand-pointer hints, in this order**:
        1. First draft: "Pick a spell", hand on the cards.
        2. First wave: hand on the Start wave button.
        3. First level-up: "Each level gives a new card".
        4. Ult ready for the first time: hand on the ult button, "Tap to use".
        5. First boss: "Boss incoming!".
        6. Home screen after the first run: hand on the Garage, "Upgrade
           your tower".
        7. Then: hand on the Codex, "Upgrade your spells".
        8. Then: "Each run costs energy, it refills over time".
        9. Then: hand on the **Store** tab, showing where gems are spent.

**Acceptance criteria**:
- [x] Every blank filled or explicitly marked "later". (2026-10-19; one small
      detail left to 10-10: tutorial-run energy cost.)

---

## Task 10-01 — Overlay Screen Host (one mechanism for every popup screen) ✅ DONE (2026-10-12, user approved)

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Read**:
>   - `scenes/ui/world_map.gd` (Track slide, `InputBlocker`, `LoadingScreen`,
>     `CONTENT_SCENES`, `_ensure_instanced`).
>   - `scenes/ui/world_map.tscn` node order (later siblings draw on top).
> - **Art**: the X button already exists at
>   `assets/ui/common/ui_button_x_red_square_clean_transparent.png`.

**Files**: `scenes/ui/world_map.tscn` / `.gd`, new
`scenes/ui/widget/overlay_screen/overlay_screen.tscn` / `.gd`

> **✅ Decided 2026-10-12 (user: "make it just like in Archero")**:
> - The dim covers **everything**, the bottom NavBar included; nothing behind
>   is tappable.
> - The popup is a **centred panel** (not a full page). Opening is a quick
>   **pop-in** (scale up + fade), not a slide.
> - Red **X on the panel's top-right corner**. **Tapping the dim outside the
>   panel also closes it.** Both are per-popup options, so a reward popup can
>   hide the X and use "tap anywhere" instead (10-05).
> - `chapter_select` stays as it is (already an Archero-style full page with
>   its own Back), not moved onto this host.

Store, Chests, Daily, Settings, and the reward popup all open over the home
screen and close back to it. They share **one** host so the open/close
animation, dim background, back button and input blocking exist once (no
duplicated code).

- [x] An `OverlayLayer` in the `world_map.tscn` shell (above Track, below
      the `LoadingScreen`) with `open(scene: PackedScene)` / `close()`. It
      provides a dim background, a slide/fade in, and a close (X) button.
      Close reuses `common/ui_button_x_red_square_clean_transparent.png`,
      which already exists.
- [x] Opened screens get a `_refresh()` call, same as tab screens do today.
- [x] Android back / Escape closes the top overlay first (full back-button
      handling in 10-08). Escape works now; on a real Android device back still
      quits the app until 10-08 turns off `quit_on_go_back`.
- [x] If 10-00 chose the store as a **nav tab**, the Store screen goes into the
      Track as a 4th slot instead, and this host is still used by
      Chests/Daily/Settings/rewards. (Settled 2026-10-12: the Store is a nav
      tab, built as a Track slot in 10-02; filling it is 10-04's work.)

**Placeholders**: none (reuses existing X button art).
**Preview**: `overlay_screen.tscn` opens in the editor showing the dim, the frame
and the X over a sample child.

**Acceptance criteria**:
- [x] Any content scene can be opened and closed through this one API.
- [x] Nav-bar sliding still works, and taps can't reach the screen underneath
      while an overlay is open.

---

## Task 10-02 — Home Screen Entry Points (+ preview) ✅ DONE (2026-10-12, user approved)

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Read**:
>   - `scenes/ui/world_map_content.tscn` / `.gd`.
>   - `scenes/ui/widget/nav_button/nav_button.gd` badge code (`badge_visible`
>     …). Share it, don't copy it.
> - **Store icon**: three versions exist (`nav/icon_nav_store.png`,
>   `_v2_blue`, `_v3_purple`). **The user picks**; never choose a version
>   yourself.

**Files**: `scenes/ui/world_map_content.tscn` / `.gd`, new
`scenes/ui/widget/home_side_button/`, `widget/badge_button_base.gd` (badge shared
with `nav_button`), `nav_bar` (4th tab), new `store_content.tscn` /
`coming_soon_content.tscn`

> **✅ Decided 2026-10-12**:
> - Store = a **nav-bar tab**, far left (Store · Garage · Map · Codex), icon
>   `nav/icon_nav_store.png`. So no Store button on the home screen.
> - Layout **C**: Chests and Daily down the left beside the chapter picture,
>   the Settings gear top-right beside the currency pills. ⚠️ 10-03 adds a
>   third (gems) pill to that top row, so 10-03 must fit the gear in too.

- [x] A small `@tool` `home_side_button` widget: icon, optional label, and
      an optional notification badge (reuse `ui_notification_badge.png` and
      the badge knobs `nav_button` already has; share the code, don't copy
      it).
- [x] Add Store / Chests / Daily / Settings buttons to the home screen in the
      layout you approve. Each calls the 10-01 host. The Daily and Chests
      badges light up when something can be claimed or opened.
- [x] The buttons exist before their screens: each opens a "Coming soon"
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
- [x] You approve the home layout from the editor preview before 10-04 starts.
- [x] Each button opens its (placeholder) screen and closes back.

---

## Task 10-03 — Premium Currency (Gems) ✅ DONE (2026-10-12, user approved)

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Check first**: 09-01 must already have put `premium_currency` into
>   `SaveData`.
> - **Read**:
>   - `scenes/ui/widget/top_bar/top_bar.tscn` (2 pills; materials uses
>     `icon_scale = 0.82`).
>   - `scenes/ui/widget/currency_pill/currency_pill.gd` + `pill_base.gd`.
>   - Every screen that sets pills: grep `set_amount`.

**Note (10-02)**: the Settings gear now sits top-right beside the pills; the third
pill must fit beside it.
**Covers**: B2 · **Files**: `MetaManager`, `SaveData` (field added in 09-01),
`widget/top_bar/`

> **✅ Decided 2026-10-12**:
> - Code name `MetaManager.gems`; the save field stays `premium_currency`.
> - **Garage**: Materials · Gems · Tower Material — energy is dropped there
>   (`top_bar.show_energy = false`). Gems show even though nothing in the
>   Garage costs gems yet. Every other screen: Energy · Materials · Gems.
> - **Home**: pills stay centred, gear top-right; gaps 40 → 24 px everywhere.
> - Built: `top_bar.gd` fills its own numbers (`refresh()`, live on
>   `gems_changed`), replacing the per-screen `set_amount` lines.
> - Placeholder icon: a multiply tint can't turn the blue gem pink, so the
>   pill got `icon_hue_shift` (`hue_shift.gdshader`) instead, at 0.28.
> - No dev tool grants gems yet (none exists); tests call `award_gems()`.

- [x] `MetaManager.award_gems(n)` / `spend_gems(n) -> bool`: save
      immediately and emit `EventBus.gems_changed`. `premium_currency` is the
      field (it already exists); expose it under one name.
- [x] A third `currency_pill` in `top_bar.tscn`, with the same widget and the
      same `icon_scale` correction method (`ui_tuning.md` "Icons are not the
      size you think": measure with `Image.get_used_rect()`).
- [x] Gems are only granted in the store (10-04), rewards (10-05/10-06) and
      dev tools. There is no free gem source by accident.

**Placeholders**: gem icon = `topbar/icon_currency_materials1.png` hue-shifted pink
purple → final `topbar/icon_currency_gems.png`.
**Preview**: `top_bar.tscn` shows three pills.

**Acceptance criteria**:
- [x] Gems persist, display on every meta screen, and can't go negative.

---

## Task 10-04 — Store Screen ✅ DONE (2026-10-19, user approved; look polish moved to 10-16)

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Read**:
>   - `scripts/resource_dir.gd` and `scenes/ui/widget/cost_chip/cost_chip.gd`.
>   - The codex `ScrollContainer` in `scenes/ui/spell_codex_content.tscn`
>     (`horizontal_scroll_mode = 0`).
>   - `addons/ui_icon_cap/plugin.gd` `SIZE_RULES`.
> - **Remember**: `ui_panel_dark_v2.png` is 0.73 aspect; keep it.

**Covers**: B1, D2 (placeholders) · **Unblocked** (10-00 catalog ✅ 2026-10-19;
the entry point is a nav TAB, and `scenes/ui/store_content.tscn` already
exists as its "Coming soon" page from 10-02 — build the store into it, not
as a popup).

> **✅ Catalog (10-00, 2026-10-19, "same as the original Archero")**:
> sections in order Offers → Chests → Base Material → Gems → Energy → Skins
> (Skins hidden until 12-05).
> - Gems (real money): 80 Pile · 500 Heap · 1,200 Bucket · 2,500 Barrel ·
>   6,500 Chest · 14,000 Cart. Prices are Epic 12's.
> - Chests (gems): cheap 60 (50 on repeat buys), better 300 (280, then 260
>   on repeat buys while the screen stays open). No daily limit. Opening is
>   10-05's job; the store card only sells.
> - Base Material (gems): 3 packs at 30 / 80 / 200 gems; amounts in
>   balancing.
> - Energy (gems): 20 energy for 100 gems (shares 10-07's refill code).
> - Offers (real money): beginner pack (gems + Base Material + 5 revives,
>   10-15), chapter packs shown one at a time (next appears after the
>   previous is bought; owned packs saved in `SaveData` + migration).
> - Monthly card (real money): gems on purchase + a daily login amount for
>   the card's duration (saved + migration).
> - Daily deals: a few rotating items that refresh each day (device clock);
>   contents to be decided at the start of this task.
> - Ad-priced items show disabled ("coming soon") until Epic 12.
> - **Ask at the start of this task**: monthly card length / amounts, daily
>   deal contents, the beginner/chapter pack contents. Amounts can be
>   placeholders tuned in balancing.

> **✅ Start-of-task answers (user, 2026-10-19)**:
> - **A. Order**: yes. 10-04 pulls in **the `reward_popup` widget** (from
>   10-05) and **the switch to Archero energy** (from 10-07: constants +
>   save migration). Chest cards are shown, but **buying is off** until 10-05
>   builds opening (Archero opens a bought chest at once).
> - **B. Contents**: copy Archero (placeholder amounts, tuned in balancing):
>   beginner pack = 300 gems + Base Material + 5 revives; chapter packs =
>   gems + Base Material + a chest; monthly card = gems now + gems daily for
>   30 days; daily deals = a few rotating items (Base Material, a chest,
>   energy, one free item a day).
> - **C. Placeholder real-money price text**: ✅ **Archero's USD prices**
>   (gems $0.99 / 4.99 / 9.99 / 19.99 / 49.99 / 99.99, beginner $1.99,
>   monthly card $2.99, chapter pack 1 $6.99, the rest $9.99 for Archero's
>   "$10"), in `StoreItemDefinition.price_label` until Epic 12.
> - **D. Confirm before spending gems?**: Archero's behaviour wasn't found
>   (wiki + guides, 2026-10-19). ✅ User: **buy straight away**, no confirm.
> - **Chest art**: ✅ cheap = `icon_chest_common`, better =
>   `icon_chest_rare`. The epic chest **may be added later** (one more
>   `.tres`).
>
> **Build steps** (each ends with a "Session note" below, user review
> between steps):
> 1. Item data (`StoreItemDefinition` + every `.tres`)
> 2. `StoreService` autoload + fake provider + `grant()`
> 3. `SaveData` v6 fields + migration (+ the Archero energy switch)
> 4. `store_item_card` widget (needs C)
> 5. Store screen layout
> 6. Purchase flow + `reward_popup` (needs D)
> 7. Headless tests (save backed up first)

> **📝 Session note — step 1 done (2026-10-19, awaiting user review)**
> - **Added** `Constants.StoreSection` (DAILY_DEALS, OFFERS, CHESTS,
>   BASE_MATERIAL, GEMS, ENERGY, SKINS; draw order) and
>   `Constants.StorePriceType` (REAL_MONEY, GEMS, AD, FREE).
> - **Added** `resources/store/store_item_definition.gd` (`class_name
>   StoreItemDefinition`): id, name, icon, section, sort_order; price
>   (`price_type`, `gem_prices` = repeat-buy steps, last one repeats,
>   `product_id` for Epic 12, `ribbon_text`); grants (gems, energy,
>   base_material, revives, chest_id + chest_count); limits (`one_time`,
>   `chain_index` for chapter packs, `daily_deal`); monthly card
>   (`card_days`, `daily_gems`). A bundle = several grant fields set.
> - **Added 29 `.tres`** in `resources/store/`: 6 gem packs (Pile…Cart),
>   2 chests (cheap 60→50, better 300→280→260), 3 Base Material packs
>   (30/80/200 gems → 300/900/2500), energy (100 gems → 20; ad → 5),
>   beginner pack (300 gems + 1000 Base + 5 revives), monthly card (300 now
>   + 100/day × 30), 10 chapter packs (500 gems + 1500 Base + 1 better
>   chest each, chain 1–10), 4 daily deals (free 100 Base; 20 gems → 400
>   Base; 40 gems → cheap chest; ad → 5 energy). **All non-Archero amounts
>   are placeholders** for balancing (Base Material amounts, card numbers,
>   pack contents, deal prices).
> - **Placeholders**: gem icon = `topbar/icon_currency_materials1.png`
>   (no hue shift on cards yet: step 4 adds it); chest icons
>   `icon_chest_common` (cheap) / `icon_chest_epic` (better), **user still to
>   pick which chest art**. Added to `ui_assets.md` "STILL TO MAKE".
> - **Verified**: headless script loads all 29 through `ResourceDir`, no
>   empty ids/icons, no duplicates, every GEMS item has a price → PASS.
>   Not checked: how anything looks (no UI yet).
> - **Fixed** the Godot path in `epic_09_content.md` rule 8.
> - **Next**: step 2 (`StoreService` + fake provider + `grant()`).
>
> **📝 Session note — step 1 follow-up (2026-10-19)**: answers C, D and chest
> art recorded above. Added `price_label` to `StoreItemDefinition` and filled
> it on every real-money `.tres`; better chest and the 10 chapter packs now
> use `icon_chest_rare.png`. Headless check re-run (now also requires a
> price label on every real-money item) → PASS.
>
> **📝 Session note — steps 2–5 done (2026-10-19, user asked for them in one
> go; awaiting user review of the editor preview)**
> - **Step 2 — `StoreService`** (`autoloads/store_service.gd`, registered in
>   `project.godot` as autoload 8, after AudioManager): rules + the one
>   purchase path (see `components.md` §3 "StoreService"). Fake provider
>   `scripts/store/fake_purchase_provider.gd` (always succeeds, deferred).
>   New shared day helper `scripts/day_clock.gd` (local day number; 10-06
>   reuses it). New EventBus signals `energy_changed`, `store_item_purchased`.
>   Decisions made inside the rules, **for the user to confirm**:
>   - the monthly card can't be re-bought while running (note "N days
>     left"); a day the game isn't opened isn't paid later; the first daily
>     payout is on the purchase day.
>   - `Constants.DAILY_DEALS_SHOWN = 3` (free deal + 2 drawn by day) —
>     placeholder.
>   - unaffordable gem items: red price, "Not enough gems", button off.
>   - real-money items are one per press; the card says "Buying…" until the
>     provider answers.
> - **Step 3 — save v6** (`Constants.SAVE_VERSION = 6`): `SaveData` +
>   `MetaManager` got `bought_items`, `daily_deals_day/_bought`,
>   `monthly_card_end_day/_last_paid_day`, `free_revives`, `owned_chests`;
>   `_migrate_5_to_6()` defaults them and scales energy ×4. **Archero
>   energy switched**: MAX 20, cost 5 (`spend_energy` uses the constant now;
>   it used to subtract 1), regen 720 s. Chapter packs' chest goes into
>   `owned_chests` unopened (10-05 opens it).
> - **Step 4 — `store_item_card`** (`scenes/ui/widget/store_item_card/`,
>   `@tool`): see `components.md`. `StoreItemDefinition` gained
>   `icon_hue_shift` (gem items 0.28, placeholder) and `open_on_buy` (the
>   two chests + daily chest: blocked "Coming soon" until 10-05). The hue
>   shift code moved out of `pill_base.gd` into the shared
>   `widget/hue_shift.gd`. `cost_chip.gd` is now `@tool`.
> - **Step 5 — Store screen** (`store_content.tscn` / `.gd`, `@tool`):
>   "Coming soon" replaced by a `ScrollContainer` (codex rules) of section
>   titles + 3-column grids built in code (editor too, as the preview; built
>   nodes have no owner so they're never saved). `set_active(true)` resets
>   the repeat-buy discount and collects the monthly card. **Tapping Buy
>   already works** (StoreService.purchase); only the reward popup is
>   missing (step 6).
> - **Verified headless** (save backed up to the session scratchpad and
>   restored after each run): `test_store_service` 34/34 (migration v5→v6,
>   energy rules, fake provider, every price type, discounts, offers chain,
>   monthly card, daily deals, reload) and `test_store_screen` 16/16
>   (section order, 19 cards, labels, taps, editor build path, card scene,
>   world_map instancing). **Not verified**: how it looks — the user must
>   open `store_content.tscn` and `store_item_card.tscn` in the editor.
> - **Before opening the editor**: `project.godot` was edited outside the
>   editor (new autoload) → Project → Reload Current Project, or the editor
>   may overwrite it.
> - **Next**: user review of the look → step 6 (reward popup after buying)
>   → step 7 (tests + acceptance).
>
> **📝 Session note — steps 6–7 done (2026-10-19; 10-04 now waits only on
> the user's look approval)**
> - **Chapter packs**: user asked "can I get chapter 3 before finishing 2? do
>   it like Archero". Only the original Archero rule found = buy the previous
>   pack first (Archero 2 ties packs to chapter clears; not used). **Kept as
>   built.** Pack amounts (500 gems, 1500 Base, 1 better chest, all 10 the
>   same) are placeholders for balancing.
> - **Step 6 — `reward_popup`** (`scenes/ui/widget/reward_popup/`, `@tool`):
>   title + row of `icon ×amount` entries popping in one by one; no X, tap
>   anywhere closes (overlay options). `rewards_for_store_item(granted)`
>   builds the list. Placeholders: gem = hue-shifted materials gem; revive
>   has no icon (shows "Revive"); chest icons via a temporary `CHEST_ICONS`
>   map. `StoreService.grant()` now returns what it gave, and
>   `purchase_completed(item, success, granted)` carries it (monthly card =
>   300 + today's 100). `store_content.gd` opens the popup through the 10-01
>   host after each successful buy.
> - **Step 7 — tests** (scripts in the session scratchpad, not the repo):
>   `test_store_data` PASS, `test_store_service` 34/34, `test_store_screen`
>   16/16, `test_reward_popup` 11/11 (popup opens in the real world_map
>   shell, right entries, no X, tap closes, bundles, monthly card ×400,
>   preview scene), new-`.tres` test PASS (20th card appears).
> - **⚠️ Mistake this session**: after a test run Claude restored the
>   *morning* save backup over the user's save, which by then held newer play
>   (the chapter packs the user bought in game). That play was lost; no other
>   copy existed. **Rule from now on: copy the save right before EACH test
>   run and restore that same copy afterwards — never reuse an older
>   backup.** (Also added to `epic_09_content.md` rule 8.)
> - **Open for the user**: approve the look (`store_content.tscn`,
>   `store_item_card.tscn`, `reward_popup.tscn`, and in game); confirm the
>   rule choices listed in the steps 2–5 note (monthly card, 3 deals,
>   unaffordable look).
**Files**: new `scenes/ui/store_content.tscn` / `.gd`,
`scenes/ui/widget/store_item_card/`, `resources/store/store_item_definition.gd`
+ `*.tres`, `autoloads/store_service.gd` (or a run-agnostic helper, to be
confirmed)

- [x] **Items are data**: `StoreItemDefinition` holds id, name, section, icon,
      price type (real money / gems / ad), price, and what it grants (gems,
      energy, Base Material, revives, chest, skin, bundle, monthly card).
      Towers are never a direct grant (09-00.1); they only come from chests.
      Repeat-buy discounts (chests) are data on the item too. Items are loaded
      with the shared `ResourceDir` scan. Adding an item = a new `.tres`.
- [x] **Purchase goes through one interface**: `StoreService.purchase(item)` →
      provider → on success, `grant(item)`. The **fake provider**
      (editor/desktop, and any build with a dev flag) succeeds instantly.
      Epic 12 swaps in Google Play Billing without touching the store UI.
- [x] Gem-priced items spend gems (10-03) directly; no provider needed.
- [x] `store_item_card` is a `@tool` widget that shows the icon, name, price
      chip and a "best value"/"offer" ribbon. The price chip reuses `cost_chip`
      where possible.
- [x] Sections are scrollable (reuse the codex `ScrollContainer` rules,
      `horizontal_scroll_mode = 0`).
- [x] After a purchase, the reward popup from 10-05 shows what was granted.
      (2026-10-19: `reward_popup` built here, pulled forward from 10-05.)

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
- [x] With the fake provider, buying each item type grants exactly what its
      `.tres` says and persists after restart. (Headless, 2026-10-19. Not
      buyable yet by design: the two store chests + daily chest (10-05) and
      ad items (Epic 12).)
- [x] Adding a new `.tres` adds a card with no code or scene change.
      (Headless, 2026-10-19: a temporary `zz_test_gems.tres` appeared as a
      20th card, then was deleted.)
- [x] **User approval** (2026-10-19: "mark 10-04 done"). The look itself is
      **not** final: polishing it is task 10-16, with the Codex and Map.

---

## Task 10-05 — Reward Popup + Chests

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Art**: all reward icons are in `assets/ui/rewards/`.
>   `icon_mat_tower_rare` has a `_v2`; **the user picks**.
> - **Read**: `scripts/weighted_table.gd` and `scenes/ui/victory_screen.gd`.
> - **Apply**: the 09-00.1 "Store rule" **as revised in 10-00 (2026-10-19)**: no daily limit, key or gems to open, materials capped at one energy bar (4 runs, highest cleared chapter), chance of an unowned tower.

**Covers**: B3 · **Unblocked** (10-00 chest answers ✅ 2026-10-19).

> **✅ Decided in 10-00 (2026-10-19, "like the original Archero")**: two
> chest kinds, cheap and better (Archero's Golden / Obsidian; icons from
> `rewards/icon_chest_*`, user picks which two). No daily limit. A chest
> opens with **its key or with gems**; keys are **earned** (progress
> rewards, daily rewards, quests), never sold. Free open by ad: cheap chest
> once a day, better chest once a week (disabled until Epic 12). This
> replaces the "3/day" and "key included" lines below.
**Files**: `scenes/ui/widget/reward_popup/`, `resources/chests/chest_definition.gd`
+ `chest_common/rare/epic.tres`, new `scenes/ui/chests_content.tscn`

- [x] **`reward_popup`**: one widget that shows a list of `icon × amount`
      rewards with a pop-in. It's used by chests, the store, daily rewards,
      and optionally the victory screen, which is the only place a reward
      reveal exists today. Built once. (**Built in 10-04 step 6**,
      `scenes/ui/widget/reward_popup/`: `show_rewards(list)`, reward =
      `{icon, amount, hue_shift?, name?}`. Replace its `CHEST_ICONS` map with
      `ChestDefinition` icons here.)
- [ ] **Chests are data**: a `ChestDefinition` holds its icons (closed/open),
      the key it needs, and a loot table via `scripts/weighted_table.gd` (the
      existing helper). Owned chests and keys go in `SaveData` (+ migration).
- [ ] Chests screen: owned chests, keys and an Open button. Opening plays a
      closed → open swap and then the `reward_popup`.
- [ ] Keys wired as decided in 10-00: `MetaManager.award_key(chest_id)`
      called by progress rewards, daily rewards and quests (10-06a–c).
      Opening spends a key if the player has one, otherwise the chest's gem
      price (the same price data as the 10-04 store card, not a copy).
- [ ] Free ad opens: cheap chest once a day, better chest once a week
      (last-free-open times in `SaveData` + migration). The button calls the
      Epic 12 ad hook and is disabled ("coming soon") until then.
- [ ] **Chest contents follow 09-00.1 "Store rule" as revised in 10-00**:
  - **no daily limit** on opening or buying
  - materials capped at **one full energy bar's worth = 4 runs** (Archero
    energy: 20 / 5 per run), using 09-12's chapter reward numbers at the
    player's **highest cleared chapter**
  - a **chance of a random tower the player doesn't own**, through 09-05's
    single `MetaManager.unlock_tower()`. Once every tower is owned,
    materials only.
  - drop odds are set in balancing (09-17), the better chest paying more.

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

## Task 10-06 — Daily Systems (split into 10-06a–d, 2026-10-19)

> **✅ Decided in 10-00 (2026-10-19, "like the original Archero")**: all four
> of Archero's daily systems at launch. The original single-calendar task
> was split into four, one at a time, each with its own preview and
> approval. Shared rules for all four:
> - **Read first**: `scripts/save_data.gd` (09-01 migration rule).
> - Rewards are data (`.tres`), granted through 10-05's `reward_popup`.
> - Day boundaries come from the device clock in **local** time. Archero
>   uses server time; ours can be cheated until a server exists (F5/F8,
>   Epic 12/13). Note it and move on.
> - One shared "day changed" helper (not one per system) decides when daily
>   things reset.
> - The home-screen Daily badge (10-02) shows when anything here is
>   claimable.
> - Reward amounts weren't found in research; placeholders, tuned in
>   balancing.
> - **Ask at the start of 10-06a**: where each system lives on the home
>   screen (one Daily popup with tabs, or separate buttons like Archero).

### Task 10-06a — Daily Login Gift

**Covers**: B4

- [ ] 15 days of rewards (a `.tres` list). One claim every 24 h. A missed day
      does **not** reset progress. Runs once: after day 15 it's gone.
- [ ] `SaveData`: days claimed + last claim time (+ migration).

**Placeholders**: day-cell frame drawn with `StyleBoxFlat` → final
`daily/ui_daily_cell.png` / `ui_daily_cell_claimed.png`.
**Preview**: `login_gift_content.tscn` shows all 15 days: claimed, today,
future.

**Acceptance criteria**:
- [ ] One claim per 24 h, a skipped day doesn't reset, survives a restart,
      disappears after day 15.

### Task 10-06b — Daily Quests

**Covers**: B4

- [ ] Quests are data (`.tres`: id, text, the `EventBus` signal that counts,
      target count, XP), like Archero: log in 10 XP, open a cheap chest
      10 XP, play 2 runs 15 XP, open the better chest 20 XP, make a purchase
      20 XP. Counting listens to `EventBus` (no quest `if`s in gameplay
      code).
- [ ] An XP bar to 100. Every 20 XP unlocks one reward (5 rewards, `.tres`).
- [ ] Everything resets daily. `SaveData`: progress per quest, XP, rewards
      claimed, last reset day (+ migration).

**Placeholders**: drawn bar + `StyleBoxFlat` rows → optional final
`daily/ui_quest_row.png`.
**Preview**: `daily_quests_content.tscn` shows quests in progress, done and
claimed, and the XP bar partly filled.

**Acceptance criteria**:
- [ ] Quests count from real play, rewards unlock at each 20 XP, everything
      resets the next day and survives a restart.

### Task 10-06c — Achievements

**Covers**: B4

- [ ] Long-term goals as data (`.tres`: text, the stat/signal it tracks,
      target, reward), e.g. clear chapter N, star a tower to 5, rank a spell
      to 5, kill N enemies. Counting listens to `EventBus`.
- [ ] `SaveData`: progress + claimed per achievement (+ migration). Never
      resets.
- [ ] **Ask at the start of this task**: the launch achievement list.

**Placeholders**: `StyleBoxFlat` rows.
**Preview**: `achievements_content.tscn` shows locked, in-progress, ready and
claimed rows.

**Acceptance criteria**:
- [ ] Progress counts from real play and persists. Each reward claims once.

### Task 10-06d — Daily Ad Reward + Lucky Spin

**Covers**: B4

- [ ] **Daily ad reward**: once a day, an ad gives 30 gems + a little energy.
- [ ] **Lucky spin**: a wheel with weighted prizes (`.tres`, using
      `scripts/weighted_table.gd`). One free spin a day, then ad spins, up to
      5 a day.
- [ ] Ad buttons call the Epic 12 ad hook and are disabled ("coming soon")
      until then. The free spin works now.
- [ ] `SaveData`: last ad-reward day, spins used today (+ migration).

**Placeholders**: wheel drawn (segments + pointer) → final
`daily/ui_spin_wheel.png` / `ui_spin_pointer.png`.
**Preview**: `lucky_spin.tscn` shows the wheel with sample prizes.

**Acceptance criteria**:
- [ ] The free spin pays out from its table once a day; the ad buttons are
      disabled until Epic 12; counts survive a restart.

---

## Task 10-07 — Energy Countdown + Refill

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Read**:
>   - `autoloads/meta_manager.gd`: `_apply_offline_energy_regen()` (~123), which
>     only runs on load; and `spend_energy()`.
>   - `Constants.ENERGY_REGEN_INTERVAL_SEC = 1200`, `MAX_ENERGY = 5`.
>   - `world_map_content.gd`: `_show_out_of_energy()`.

**Covers**: B5 · **Files**: `MetaManager`, `widget/top_bar/` or
`widget/currency_pill/`, world map

Today energy only regenerates in `_apply_offline_energy_regen()` **on load**.
A player sitting on the home screen never gains energy until they restart.

> **✅ Decided in 10-00 (2026-10-19, "like the original Archero")**: energy
> becomes **20 max, 5 per run, 1 back every 12 min** (today 5 / 1 / 20 min).
> Refill: **20 energy for 100 gems**, no limit; **ad +5, up to 4 times a
> day** (disabled until Epic 12).

> **Changed in 09-09 (2026-10-06)**: `save()` no longer resets
> `last_energy_timestamp`. The timestamp is now "start of the regen interval in
> progress". It moves forward by `regen × interval` when energy comes back
> (partial progress kept), and to now when energy is full or when spending from
> full. The live `Timer` here should reuse that same rule, not set the
> timestamp itself.

- [ ] `MetaManager` ticks regen while the game runs (a `Timer`, same interval
      math as the offline catch-up, shared, not copied) and exposes
      `seconds_to_next_energy()`.
- [ ] The energy pill shows `mm:ss` under or beside the amount while below
      max. It's a knob on the pill widget, so only the energy pill uses it.
- [x] (**Done early, in 10-04 step 3, 2026-10-19** — constants, `spend_energy`
      uses the cost, v6 migration ×4, `energy_changed` signal, docs. Still to
      check here: `_show_out_of_energy()` wording and the regen Timer.)
      **Switch to Archero energy**: `Constants.MAX_ENERGY = 20`,
      `ENERGY_COST_PER_RUN = 5`, `ENERGY_REGEN_INTERVAL_SEC = 720`. Save
      migration scales an old save's energy ×4 (5/5 → 20/20). Grep every
      place that assumes 5 or 1 (energy pill, `_show_out_of_energy()`,
      tests, the `MAX_ENERGY` line in `components.md`) and update the docs.
- [ ] Refill as decided in 10-00: a gem button (**100 gems → +20 energy**,
      no limit) and an ad button (**+5, up to 4 times a day**; count in
      `SaveData` + migration) that calls the Epic 12 ad hook. Until Epic 12
      the ad button is disabled with the note "coming soon". The existing
      "Not enough energy" message offers refill. The 10-04 store's energy
      card uses the same refill code.
- [ ] Check with the user (and how Archero does it): may a refill go above
      max?

**Placeholders**: refill popup uses the 10-01 host + existing buttons; no new
art.
**Preview**: `currency_pill.tscn` has a `preview_countdown` knob;
`world_map_content.tscn` shows the energy pill with a countdown.

**Acceptance criteria**:
- [ ] Energy regenerates while the game stays open, the countdown is right,
      and refill works by the decided method(s).

---

## Task 10-08 — Pause Menu (+ Android back button)

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Read first**: `components.md` §7 "Who is allowed to pause".
> - **Read**:
>   - `scenes/main/hud.gd` (`_on_pause_pressed`, `_on_phase_changed`).
>   - `scenes/ui/widget/pause_button/pause_button.gd` (process_mode ALWAYS).
>   - `scenes/main/game_world.gd` (`_unhandled_input`, `run_is_over`).
> - **Facts**:
>   - `project.godot` input map: `ui_cancel` is not bound anywhere (as of
>     2026-09-27).
>   - `SaveData.music_volume` / `sfx_volume` already exist.

**Covers**: B6 · **Files**: new `scenes/ui/pause_menu.tscn` / `.gd`,
`scenes/main/hud.gd`, `scenes/main/game_world.gd`
**Refs**: `components.md` §7 "Who is allowed to pause" (read it first; this
must not become a 5th writer that fights the others)

- [ ] Pause menu (CanvasLayer, `process_mode = ALWAYS`) with Resume /
      Home / Music & SFX sliders. **No Restart** (10-00, 2026-10-19: "like
      Archero, no restart"). It opens from the existing `pause_button`,
      through the same `hud.gd` writer. It's only available in the WAVE
      phase, as today.
- [ ] Home ends the run (forfeit, energy not refunded) and returns to the
      world map. Ask the user whether Home needs a "Leave the run?" confirm.
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

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Read**: `scripts/save_data.gd` and `resources/theme/ui_theme.tres`
>   (fonts Baloo 2 + Nunito, for the credits page).

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

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Read**: `autoloads/event_bus.gd`, the signal list tutorial steps can
>   trigger on.

**Covers**: B8 · **Unblocked** (10-00 tutorial content ✅ 2026-10-19: a short
tutorial run ending in a small gem reward, then 9 one-time hints; see
10-00 for the list and order). Still to decide here: whether the tutorial
run costs energy.

- [ ] `SaveData`: tutorial steps completed (+ migration). A step never shows
      twice.
- [ ] One reusable `tutorial_hint` overlay widget: dim, a cut-out/highlight
      around a target Control or screen point, an arrow, and text. Steps are
      data (a `.tres` list: trigger event → target → text), triggered by
      `EventBus` signals such as the first draft, first wave or first level-up.
      No tutorial `if`s scattered through gameplay scripts.
- [ ] The first run is a **short tutorial run** (a few easy waves, as data:
      its own `ChapterDefinition` or wave list, not `if` branches). It ends
      with a small gem reward via `award_gems()` (amount in `Constants.gd`,
      tuned in balancing).
- [ ] The 9 hints from 10-00, in order; hints 6–9 point at Garage, Codex,
      energy and the Store tab on the home screen after the first run.
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

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Read**:
>   - `scenes/manager/wave_manager.gd`: `_wave_timer.start(Constants.WAVE_DURATION_MAX)`
>     (~line 49), boss spawn (~51), `_on_wave_timeout` (~142), `_on_watchdog_tick`.
>   - `Constants.WAVE_DURATION_MAX = 60` and its comments (~lines 11–23).
>   - `scenes/main/hud.gd`.

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

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Read**:
>   - `scenes/ui/widget/value_bar_3d/value_bar_3d.gd` (`_refresh`, `region_rect`).
>   - `bar_3d_style.gd` (same folder).
>   - `resources/ui/enemy_bar_style.tres` / `boss_bar_style.tres`.
>   - Its long doc comment about the MSDF / outline history.

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

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Grep list**:
>   - `starting_spell_id`: `tower_definition.gd:23`, `tower.gd:32/48`,
>     `draft_manager.gd:78`, `tower_ancient_tower.tres`.
>   - `SynergyTag`, `tag_counts`, `add_tag`: `Constants.gd`, `game_state.gd`,
>     `draft_card.gd` pill labels.
>   - `synergy_banner.*` and `tag_row_widget.*` in `scenes/ui/`.
>   - `model_path` (Tower/Enemy definitions) and `arena_model_path`.
> - **Watch out**: `passive_script` is **no longer dead**. 09-13 may use it.
>   Don't remove it.

**Covers**: B10 · **Unblocked** (10-00 ✅ 2026-10-19: remove all four groups;
the synergy pill label stays via a plain label-text field).

- [ ] (added 2026-09-29, found in 09-05) Old standalone garage `scenes/ui/tower_garage.tscn/.gd` and standalone `spell_codex.tscn` — the game uses the `*_content.tscn` versions inside `world_map`; only `spell_codex.gd`'s nav still links to `tower_garage.tscn`. Also unused: `CooldownComponent`, `HitboxComponent`, the 5 `ancient_tower_lvlN.tres` (09-02 / 09-03).
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

## Task 10-15 — Revive (added 2026-10-19)

> **🔎 Fresh-session check**
>
> - **Read**:
>   - `scenes/main/game_world.gd` `_on_tower_died`, `run_is_over`.
>   - `components.md` §7 "Who is allowed to pause" (the revive prompt must
>     not become an extra pause writer).
>   - `epic_12_monetization.md` 12-00 "Revive" and 12-04 (the ad revive is
>     built there, on top of this).

**Covers**: new (10-00 store answer, "like the original Archero").
**Built before 10-14**; numbered last only to avoid renumbering.

Archero: on the first death in a run, the player is offered a revive for
30 gems, with a short countdown to decide; the beginner pack includes 5 free
revives.

- [ ] On tower death, before the defeat screen: a revive prompt with a
      countdown. Pay **30 gems** or use a **free revive** (count in
      `SaveData` + migration, granted by the beginner pack in 10-04). The
      price and countdown go in `Constants.gd`.
- [ ] On revive the run continues the same wave.
- [ ] **Ask at the start of this task**: how much HP comes back, whether
      nearby enemies are pushed back or cleared, and how many revives per
      run (Archero: check before asking, don't guess). Write the answers into
      12-00's "Revive" question too.
- [ ] Leave a slot for the ad-revive button (12-04), disabled until Epic 12.

**Placeholders**: prompt uses the 10-01 host + existing buttons.
**Preview**: `revive_prompt.tscn` shows the prompt with the countdown.

**Acceptance criteria**:
- [ ] Revive with gems and with a free revive both continue the run; a
      declined or timed-out prompt goes to the defeat screen; nothing pauses
      or un-pauses outside the §7 rules.

---

## Task 10-14 — Integration Test

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Back up the save first.** Open every preview scene from Epic 10.

- [ ] Fresh save: play the tutorial run and see all 9 hints; home → every
      entry point opens and closes; buy one of each store item (fake
      provider); open each chest with a key and with gems; claim the login
      gift, a quest reward, an achievement and the free spin; refill energy
      (20 max, 5 per run); change every setting and restart.
- [ ] In a run: pause / resume / home; revive with gems and with a free
      revive; Android back in every state; see the wave-timeout warning.
- [ ] Old save (from before this epic) loads with nothing lost.
- [ ] Open every preview scene from this epic.
- [ ] Every placeholder listed in `ui_assets.md` "STILL TO MAKE".

---

## Task 10-16 — Look Pass: Store, Codex, World Map (+ previews) (added 2026-10-19)

> **🔎 Fresh-session check**
>
> - **Read**: `ui_tuning.md` (tune the look in the widget scene, the content
>   in the screen), `components.md` §7, and the 10-04 session notes.
> - **Open first** (editor, with the user): `scenes/ui/store_content.tscn`,
>   `widget/store_item_card/store_item_card.tscn`,
>   `widget/reward_popup/reward_popup.tscn`, `scenes/ui/spell_codex_content.tscn`,
>   `scenes/ui/world_map_content.tscn`. Ask the user what they dislike in
>   each before changing anything.

**Covers**: user request (2026-10-19, when approving 10-04): "we need to work
on the looks of the store/codex/map with a preview".
**Order**: placed last at the user's request; it may run any time after
10-04. Do it before 10-14 so the integration test checks the final look.

- [ ] **Store**: card layout and sizes, section titles, spacing, ribbon,
      price button, gem chip size, reward popup. Archero's store as the
      reference (the user's rule: copy the original Archero).
- [ ] **Codex** (`spell_codex_content`): same review.
- [ ] **World map** (`world_map_content`): same review.
- [ ] Every screen and widget touched keeps (or gets) an **editor preview**
      that shows the final look without pressing Play (Epic 09 rule 2).
- [ ] Real art can replace placeholders here where it exists; anything
      still missing stays in `ui_assets.md` "STILL TO MAKE".

**Placeholders**: as listed in `ui_assets.md`.
**Preview**: each of the scenes above, approved by the user in the editor.

**Acceptance criteria**:
- [ ] The user approves each screen's look from its editor preview and in
      game.
