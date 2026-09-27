# Epic 13 — Tech, Release & Play Store

> Prerequisite: content (09), systems (10), audio (11) and monetization (12) in
> place for the final checks. **13-01 (Android export) can and should be pulled
> forward**: real-device testing of 10-08 / 12-xx needs it.
> **Rules**: see `epic_09_content.md` → "Rules for Epics 09–13".
> Google Play's rules change over time. Every Play requirement quoted here was
> true when `remaining_to_do_list.md` was written. **Re-check each one against
> Google's current docs when doing the task**, and don't trust these numbers
> blindly.
> Source: `remaining_to_do_list.md` sections **F** (except F6 → 09-01 and F8 →
> 12-02), **G**, and **D3**.
> Completed epic delivers: a signed AAB that meets Play's requirements, has
> passed closed testing, and has a complete store listing.

---

## Task 13-00 — Decision Gate: Release [DECISION NEEDED]

- [ ] **G6 — Final game name.** "Tower's Last Stand" is the working title.
      Answer: ______
- [ ] **Package name** (permanent once published, e.g. `com.<you>.<game>`).
      Answer: ______
- [ ] **F9 — Localization at launch or post-launch?** If launch: which
      languages. Answer: ______
- [ ] **F5 — Cloud save provider** (the list names Google Play Games
      Services). Also: which backend, if any, it shares with 12-02.
      Answer: ______
- [ ] **F7 — Crash reporting / analytics provider**, or none at launch.
      Claude checks Godot 4.4 support per candidate before you pick.
      Answer: ______

**Acceptance criteria**:
- [ ] Every blank filled or marked "later".

---

## Task 13-01 — Android Export (AAB) + Signing

**Covers**: F1 · Confirmed today: no `export_presets.cfg` exists.

- [ ] Install the Android build template for Godot 4.4 and create the
      Android export preset:
      - package name from 13-00, portrait orientation
      - **Gradle build, AAB output** (Play requires AAB)
      - the Mobile renderer's Vulkan path, with the automatic fallback left on
      - permissions only as needed: vibrate (10-09), internet only if 12/13
        need it
- [ ] Keystores:
      - a debug keystore for device testing
      - an **upload key** for Play, with Play App Signing managing the app key

      Store the keys and passwords **outside the repo**, and never commit
      them (you handle git).
- [ ] `BUILD_NOTES.md` at the repo root: exact steps and commands to build a
      debug APK (for sideloading) and a release AAB, and where the keys live
      (location only, never the passwords).

**Placeholders**: app icon from 13-08 placeholders until the final art exists.
**Preview**: n/a (a build). Verified by installing on a real device.

**Acceptance criteria**:
- [ ] A signed release AAB builds with no export errors.
- [ ] A debug build installs, launches, and shows the real 3D scene with
      shadows on a real device. If the device falls back to Compatibility and
      loses shadows, flag it loudly (it breaks the whole visual premise).

---

## Task 13-02 — Target API Level

**Covers**: F2 · The docs only set min SDK 24.

- [ ] Look up Play's **current** target-API requirement for new apps. The list
      says API 35; check whether it has risen since. Then check what Godot
      4.4's Android template supports and set `target_sdk` accordingly.
- [ ] If Godot 4.4 can't reach the required level, stop and tell you
      (options: engine upgrade, template patch). It's a real decision.

**Acceptance criteria**:
- [ ] The AAB's target SDK meets Play's current requirement (the Play Console
      accepts the upload).

---

## Task 13-03 — Mobile Input Pass

**Covers**: F4

- [ ] **Touch targets**: every tappable control at least 80×80 design px.
      Audit every screen from Epics 09–12 as well as the old ones.
- [ ] **Safe areas / notches**: read `DisplayServer.get_display_safe_area()`,
      and keep the top bar, pause button and nav bar clear of cut-outs and the
      gesture bar (one shared helper or container, not per-screen offsets).
- [ ] **Aspect ratios** other than 1080×1920 (tall 20:9 phones, tablets):
      decide per screen whether backgrounds extend and UI stays centred.
      Check the project's stretch settings in `project.godot` (`canvas_items`)
      against both.
- [ ] No hover-only states. Single-frame actions use `is_action_just_pressed`.
- [ ] Android back behavior from 10-08, checked on device.

**Placeholders**: none.
**Preview**: run each screen at 3 window sizes (1080×1920, 1080×2400,
1536×2048) with an emulated safe area. Keep a screenshot per screen per size
in `ui_reference/`.

**Acceptance criteria**:
- [ ] No clipped or unreachable UI at any of the 3 sizes; nothing under the
      notch on a real device.

---

## Task 13-04 — Performance Pass on a Real Device

**Covers**: F3

- [ ] Measure on a mid-range Android phone during the heaviest wave, with
      many spells and all 5 orb rings: fps, frame time, the shadow pass, and
      draw calls.
- [ ] Tune from the numbers, not guesses:
      - `DirectionalLight3D` shadow distance/size
      - the existing particle budget (`CombatUtils.MAX_PARTICLE_BUDGET`)
      - material sharing across enemies (skill: vfx-audio, "Mobile 3D
        performance checklist")
- [ ] Memory: 3 full runs plus meta-screen hopping without restarting; no node
      or memory growth.
- [ ] Record before/after numbers in this task.

**Acceptance criteria**:
- [ ] Target fps met on the test device, or the measured number is written
      here with a plan.

---

## Task 13-05 — Cloud Save

**Covers**: F5 · **Blocked by**: 13-00 provider.

- [ ] The local `SaveData` becomes a cache (`project.md` "Save Data" section).
      The cloud copy syncs on launch, after a run, and after purchases.
      `save_version` (09-01) is part of the cloud payload.
- [ ] Conflict rule, written down and implemented in one place (e.g. keep
      the higher-progress save, or ask the player). Choosing the rule is a
      **[DECISION NEEDED]** inside this task.
- [ ] Offline-first: the game fully works with no network.

**Placeholders**: sign-in button drawn, in Settings.
**Preview**: `settings_content.tscn` shows the cloud-save row (signed-in and
signed-out states via a knob).

**Acceptance criteria**:
- [ ] Progress made on device A appears on device B. Offline play then
      syncing never loses progress.

---

## Task 13-06 — Crash Reporting + Analytics

**Covers**: F7 · **Blocked by**: 13-00 provider.

- [ ] Crash/error reporting from release builds.
- [ ] Analytics: a small event list you approve (e.g. run start/end, chapter,
      wave reached, purchase) sent from **one** `EventBus` listener, not
      sprinkled through gameplay code.
- [ ] Everything collected goes into the Data Safety answers (13-09), and
      respects consent (12-03).

**Acceptance criteria**:
- [ ] A forced test crash and a test event both show up in the provider's
      dashboard from a release build.

---

## Task 13-07 — Localization

**Covers**: F9 · **Blocked by**: 13-00 answer (skip if post-launch).

- [ ] All player-facing text goes through `tr()` with translation files. Grep
      every `.gd` and `.tscn` for hardcoded text, file by file.
- [ ] Check the fonts (Baloo 2, Nunito) cover each chosen language's
      characters. If not, add a fallback font in `ui_theme.tres`.
- [ ] Turn on the Language row reserved in 10-09.
- [ ] Longer strings (e.g. German) must still fit: check every preview scene
      in the longest language.

**Acceptance criteria**:
- [ ] Every screen reads fully in every launch language, with no overflow.

---

## Task 13-08 — App Icon, Feature Graphic, Screenshots

**Covers**: D3

- [ ] App icon: the launcher icon plus the Android adaptive icon (foreground
      and background layers) set in the export preset, and the 512×512 Play
      listing icon. Check Google's current size rules.
- [ ] Feature graphic (1024×500 per the current Play rules; re-check).
- [ ] Phone screenshots of real gameplay and screens, taken after 13-03 so
      the UI is final.

**Placeholders**: icon cropped from `garage/icon_tower_ancient.png` → final
`assets/branding/app_icon*.png`; feature graphic from a gameplay screenshot plus
the title → final `assets/branding/feature_graphic.png`.
**Preview**: the branding files open in any viewer; the icon is also checked on
the device's home screen.

**Acceptance criteria**:
- [ ] All listing images meet Play's current size rules (the Console accepts
      them).

---

## Task 13-09 — Play Console Setup, Policy & Listing

**Covers**: G1, G2, G3, G4

Mostly your own steps. Claude prepares the text and checklists.

- [ ] **G1**: Google Play Developer account (one-time fee, $25 when the list
      was written).
- [ ] **G2**: privacy policy hosted at a public URL. It must cover everything
      12-03 / 13-05 / 13-06 collect. Put the URL into the `Constants` value
      used by the 10-09 Settings link.
- [ ] **G3**: Data Safety form (from the data list gathered in 12-03 and 13-06)
      and the content-rating questionnaire.
- [ ] **G4**: store listing (title from G6, short and full descriptions, images
      from 13-08, category, contact details).

**Acceptance criteria**:
- [ ] The Play Console shows no blocking issues on the app's setup pages.

---

## Task 13-10 — Closed Testing

**Covers**: G5

- [ ] New personal developer accounts must run a closed test before
      production. When the list was written that meant **12 testers opted in
      for 14 days**; re-check the current rule.
- [ ] Upload the AAB to a closed track. Recruit the testers and keep them
      opted in for the whole period.
- [ ] Collect feedback and crashes (13-06). Fix issues with new builds on the
      same track; the tester count and the day count must still be met.

**Acceptance criteria**:
- [ ] Play Console shows the closed-testing requirement as met and allows
      applying for production.

---

## Task 13-11 — Final Pre-Launch Check (on device)

- [ ] Fresh install from the Play closed track: tutorial → chapter 1 → unlock
      chapter 2 → garage upgrade → codex rank-up → store purchase (test
      account) → rewarded ad → chest → daily reward → settings → restart the
      app: everything persists, and cloud save syncs to a second device.
- [ ] Defeat path, revive (if built), pause menu, Android back in every state.
- [ ] No placeholder left that you didn't accept for launch.
      `ui_assets.md` "STILL TO MAKE" is either empty or every remaining entry
      is marked "OK to ship as placeholder".
- [ ] `adb logcat` clean of errors across a full session.
- [ ] Performance numbers from 13-04 still hold on the final build.
