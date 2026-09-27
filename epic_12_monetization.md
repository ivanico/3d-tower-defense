# Epic 12 — Monetization

> Prerequisite: Epic 10 (store screen with the fake purchase provider, gems,
> energy refill hook, settings screen). An Android export that installs on a
> device (13-01) is needed for real billing/ad testing, so 13-01 can be
> pulled forward.
> **Rules**: see `epic_09_content.md` → "Rules for Epics 09–13".
> **Design constraint (updated 2026-09-27)**: the old rule (`project.md`,
> `mechanics.md` §12: "time-saving, not power") was replaced by the user with
> **capped pay-to-skip**. See `epic_09_content.md` 09-00.1 "Store rule":
> - material chests: 3/day, key included, chance of an unowned tower
> - energy refills: unlimited
> - skins
> - no direct tower packs
>
> Update `project.md` / `mechanics.md` §12 to match (09-02).
> Source: `remaining_to_do_list.md` section **C**, plus **F8** and the final-art
> half of **D2**.
> Completed epic delivers: real Google Play purchases and rewarded ads behind
> the interfaces Epic 10 built, consent handled, skins, and every purchase
> validated.

---

## Task 12-00 — Decision Gate: Monetization [DECISION NEEDED]

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Research plugins with web search** and check current Godot 4.4 support.
>   Don't rely on memory.
> - **Read**: `project.md` "Save Data" (server options) and `mechanics.md` §12.

- [ ] **Catalog + prices** (store layout was set in 10-00). **Follow
      `epic_09_content.md` 09-00.1 "Store rule"**:
      - material chests: 3/day, key included, capped at one energy bar's
        worth, chance of an unowned tower
      - energy refills: unlimited
      - skins
      - no direct tower packs

      Still to answer: gem pack sizes and prices, chest and refill gem
      prices, bundles. Answer: ______
- [ ] **Rewarded ad placements** named in the list: energy refill / double
      run rewards / revive. Which ones, and any daily cap? Answer: ______
- [ ] **Revive** (if chosen): how much HP, how many times per run?
      This is a new gameplay mechanic in `game_world.gd`. Answer: ______
- [ ] **Plugins**: which Google Play Billing plugin and which ad SDK
      (the list names AdMob as an example). Claude checks each candidate's
      **current Godot 4.4 support** before you choose; no guessing.
      Answer: ______
- [ ] **Backend for purchase validation (F8)**: `project.md` names Firebase /
      PlayFab / Supabase / custom as the options. It must be the same one
      used for cloud save if 13-05 needs a server. Answer: ______
- [ ] **C4 Battle pass**: the docs say post-launch. Confirm it stays out of
      launch? Answer: ______

**Acceptance criteria**:
- [ ] Every blank is filled or marked "later".

---

## Task 12-01 — Google Play Billing

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Check**: 10-04's `StoreService` + provider interface exist, and 13-01
>   (Android export) is done.
> - **Remember**: product IDs = `StoreItemDefinition.id`.

**Covers**: C1 · **Files**: the `StoreService` provider from 10-04, export
preset (13-01)

- [ ] Install the chosen billing plugin. Add a `GooglePlayBillingProvider`
      that implements the same interface as the fake provider. The store UI
      doesn't change.
- [ ] Products are created in the Play Console, with IDs matching
      `StoreItemDefinition.id` (data, not code).
- [ ] Handle cancelled, pending, failed and already-owned purchases, plus
      restoring purchases on reinstall. Consumables (gems) are consumed only
      after the grant succeeds.
- [ ] The fake provider stays for editor/desktop runs, chosen by platform
      in one place.

**Placeholders**: none new (store art is 12-07).
**Preview**: `store_content.tscn` (unchanged). Real flows are tested on device
with license-test accounts.

**Acceptance criteria**:
- [ ] A test purchase of every item type grants correctly exactly once, even
      if the app is killed mid-purchase and reopened.

---

## Task 12-02 — Server-Side Purchase Validation

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Needs**: the backend chosen in 12-00.
> - **Watch out**: never put keys in the repo; document the location in
>   `BUILD_NOTES.md`.

**Covers**: F8 · **Blocked by**: 12-00 backend choice.

- [ ] The client sends the purchase token to the backend. The backend checks
      it with Google, records it, and returns the grant. The client grants
      **only** after the server confirms, which replaces the direct grant in
      12-01.
- [ ] Offline or server error: the purchase is kept pending and retried. It
      is never lost and never granted twice.
- [ ] Document the backend setup (where the keys live; **never** in the repo)
      in `BUILD_NOTES.md` (13-01).

**Placeholders**: none · **Preview**: none (service).

**Acceptance criteria**:
- [ ] A replayed or forged token is refused; a real one grants once.

---

## Task 12-03 — Consent / Privacy (before any ad code runs)

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Check**: the ad plugin's UMP support, and the privacy row reserved in
>   10-09.

**Covers**: C5

- [ ] Show the Google UMP consent form (via the chosen ad plugin, if it
      supports it; confirm first) on first launch in regions that need it,
      **before** the ad SDK initialises.
- [ ] The Settings "privacy options" row (reserved in 10-09) reopens the form.
- [ ] Record what data is collected for the Data Safety form (13-09).

**Placeholders**: none (the form is Google's UI).
**Preview**: the settings row is visible in `settings_content.tscn`.

**Acceptance criteria**:
- [ ] With EU test settings the form appears before any ad request, and
      the choice is honoured afterwards.

---

## Task 12-04 — Rewarded Ads

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Read**:
>   - `scenes/main/game_world.gd` `_on_tower_died` (revive).
>   - `scenes/ui/victory_screen.gd` / `defeat_screen.gd`.
>   - The 10-07 refill button and the 10-01 overlay host.

**Covers**: C2 · **Blocked by**: 12-00 placements, 12-03 consent.

- [ ] An `AdService` with one interface, `show_rewarded(placement) -> result`.
      There are two implementations:
      - a **fake provider** (editor/desktop) that shows a 3-second
        "AD PLACEHOLDER" overlay through the 10-01 host, so every placement
        can be tested without an SDK
      - a real provider using the chosen SDK
- [ ] Wire only the chosen placements:
      - energy refill (the disabled button from 10-07)
      - double rewards (victory/defeat screen, doubles the checkpoint
        materials)
      - revive (defeat → restore HP per 12-00, continue the wave)
- [ ] A reward is granted only on a completed view. Caps from 12-00 are
      stored in `SaveData` (+ migration).

**Placeholders**: ad button = drawn / `store/ui_store_ad_button.png` stand-in
from 10-04.
**Preview**: the victory, defeat and energy-refill popups show their ad
buttons in the editor.

**Acceptance criteria**:
- [ ] Each placement grants its reward on completion and nothing on cancel,
      with the fake provider and with test ads on device.

---

## Task 12-05 — Tower Skins

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Read**:
>   - `scenes/ui/widget/tower_preview_3d/tower_preview_3d.gd`.
>   - The tower star scenes.
>   - `scenes/component/hit_flash_component.gd`.
> - **Watch out**: hit flash uses `material_overlay`, so a skin tint must not
>   fight it.

**Covers**: C3

- [ ] `SkinDefinition` `.tres`: `tower_id`, name, price/source, and per-star
      overrides. Skins are data.
- [ ] **Placeholder skins use the existing models** (rule 1): a material
      override or shader tint on the current `.glb` (e.g. a gold or shadow
      recolour), set per skin in its `.tres`. A real skin model later = the
      `.tres` points at new scenes; no code change.
- [ ] `MetaManager`: owned skins + an equipped skin per tower (+ migration).
      The gameplay tower and `tower_preview_3d` both apply the equipped skin
      through one shared helper.
- [ ] Garage: skin selector row under the tower. The store sells skins via
      `StoreItemDefinition` (10-04).

**Placeholders**: tinted existing models → final skin models/materials per skin;
skin thumbnails = preview render → final `garage/icon_skin_<id>.png`.
**Preview**: `tower_preview_3d.tscn` gets a `skin_id` knob, so every skin can be
viewed in the editor.

**Acceptance criteria**:
- [ ] Buying and equipping a skin changes the tower in the garage **and** in
      a run, and persists.

---

## Task 12-06 — Battle Pass

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Nothing to read.** Record the decision only.

**Covers**: C4 · **Default**: post-launch per the docs, unless 12-00 says
otherwise.

- [ ] If still post-launch: nothing is built; this task only records the
      design notes you give.
- [ ] If pulled into launch: split into its own tasks (season data, tier
      track, free/paid rows) before building, following the same data-driven
      and preview rules.

**Acceptance criteria**:
- [ ] The decision is recorded here.

---

## Task 12-07 — Store Art (replace placeholders)

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Use** the placeholder list in 10-04 / 12-04, and update `ui_assets.md`.

**Covers**: D2 (final art)

- [ ] Replace every store placeholder listed in 10-04 / 12-04 with the real
      files. Each is referenced in exactly one widget scene, so the swap is
      one texture per file.
- [ ] Check the `ui_icon_cap` prefix rules so big store art isn't downscaled.

**Placeholders**: this task removes them · **Preview**: `store_content.tscn`,
`store_item_card.tscn`.

**Acceptance criteria**:
- [ ] No store placeholder remains; `ui_assets.md` updated.

---

## Task 12-08 — Integration Test

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Needs** license-test accounts on the Play Console.

- [ ] On a device with license-test accounts: buy every item; kill the app
      mid-purchase; reinstall and restore; decline and accept consent; watch
      every ad placement; equip a skin; confirm server validation on every
      grant.
- [ ] Confirm nothing sold gives gameplay power beyond what the design
      constraint above allows.
