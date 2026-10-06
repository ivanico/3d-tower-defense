# Epic 09 — Content & Progression

> Prerequisite: everything in `epic_done/` (Epics 01–08, where built).
> Goal: more towers, more chapters, a way to pick and unlock them, and the
> deeper content hooks (tower passives, spell rank behaviors, boss phases)
> that `mechanics.md` marks [LATER]. Then balance all of it.
> Source: `remaining_to_do_list.md` section **A**, plus **F6** and **H1**
> (moved to the front of this epic, reasons below).
> Completed epic delivers: 3 playable towers, chapter 2 (plus any further
> launch chapters), a chapter carousel with unlocks, and a balanced run on
> every chapter. All of it works even where real art is still missing.

---

## Rules for Epics 09–13 (read once, applies to every task in 09, 10, 11, 12, 13)

1. **Missing art never blocks a task.** If a model, icon, background, or sound
   doesn't exist yet, the task ships with a **placeholder** and names the
   final file it's waiting for. Every task has a **Placeholders** line:
   `placeholder used → final file to make`. When a task adds a placeholder,
   also add the final file to `ui_assets.md` → "STILL TO MAKE", so every
   missing asset is listed in one place.
   - **3D: reuse the models you already have.** New chapters instance the
     existing `chap1`/`chap2` `.glb`s and new towers reuse the existing
     tower lines until real models exist. Swapping in the real model later
     must be **one `ext_resource` change in one scene** — never a code change.
   - **2D: reuse the closest existing art** (tinted if needed). Otherwise use a
     drawn `StyleBoxFlat`/`Label` stand-in, the way `pause_button` is
     drawn with no art. Name the placeholder's node or file after the final
     asset so the swap is obvious.
   - **Audio: a missing sound is a silent no-op** (logged once), never an
     error (see Epic 11).
2. **Everything has a preview.** Every new screen, widget, or content piece
   is its own `.tscn` that you can open in the editor and **see** without
   pressing Play. Every task has a **Preview** line naming that scene.
   - UI screens follow the existing pattern (`tower_garage.tscn`'s six
     placeholder grid cells, `value_bar_3d`'s `editor_preview_fill`). The
     scene is laid out with representative placeholder children or `@tool`
     `preview_*` knobs, and runtime code replaces them with real data.
   - When a screen gets a new entry point (e.g. a Store button on the home
     screen), the **host screen's** preview shows the button too, and the
     new screen has its own preview scene.
   - Gameplay content (enemies, arenas, towers) gets a preview scene that
     lays the pieces out in the editor viewport (e.g. a chapter "lineup"
     scene).
3. **Follow the repo's own rules**, not habits:
   - `skills/godot3d-*/SKILL.md`: components over monoliths, data-driven
     `Resource`s, `EventBus` for cross-system events, groups over stored
     references, no mutating shared `.tres` at runtime.
   - `components.md` §0: every balance number goes in `Constants.gd` or a
     `.tres`.
   - `components.md` §7 and `ui_tuning.md`:
     - Tune the look in the widget scene and the content in the screen.
     - Use `preload()` over new `class_name`s for UI widgets.
     - Mark generated properties non-storable.
     - `game_world.tscn` must be closed in the editor before edits.
     - Only the listed writers may touch `get_tree().paused`.
   - UI art: the `addons/ui_icon_cap` plugin caps images by filename prefix.
     Any new art drawn larger than 256px needs its prefix added to
     `SIZE_RULES`.
   - **No duplicated code**: a new file that behaves like an existing one
     `extends` it or shares a helper.
4. **Decisions are yours, not Claude's.** Items marked **[DECISION NEEDED]**
   list the options found in the docs. The task waits for your answer and
   records it in the task before building. Claude never picks one "as a
   sensible default".
5. **One task at a time, small reviewable steps.** Each task ends with you
   looking at its preview scene and approving before the next task starts.
6. **No git commands.** You handle all git.
7. **Before calling anything done**, verify it against the real files. Say
   plainly what headless tests can't prove (visuals, editor hot-reload).
8. **Starting a new session with no context**: before touching a task:
   - Read the task, its **🔎 Fresh-session check** note (under every task
     heading in Epics 09–13), and any 09-00.x / 10-00 / 12-00 / 13-00
     decision it depends on. Don't build anything whose decision isn't ✅.
   - Run read-only `git log --oneline -15` and `git status` to see what
     changed since the notes were written (2026-09-27). If a file a note
     names has changed, re-read it; the note's line numbers may be stale.
   - Assume the user's Godot editor is open:
     - **Never** kill Godot by image name.
     - Run headless checks with
       `timeout <sec> "/f/Godot/Godot_v4.4-stable_win64.exe" --headless -s <script> --path <repo>`.
     - Ask the user to close a scene before editing its `.tscn`.
   - Before any test that saves, back up
     `%APPDATA%\Godot\app_userdata\TowersLastStand3D\savegame.tres` and
     restore it afterwards.

### Where every `remaining_to_do_list.md` item lives

| Item | Task | Item | Task | Item | Task |
|---|---|---|---|---|---|
| A1 | 09-03, 09-04 | B1 | 10-04 | E1 | 11-00, 11-06 |
| A2 | 09-00.1, 09-05 | B2 | 10-03 | E2 | 11-02 |
| A3 | 09-06, 09-07 | B3 | 10-05 | E3 | 11-01 |
| A4 | 09-00.2, 09-08 | B4 | 10-00, 10-06 | E4 | 11-03, 11-04 |
| A5 | 09-09 | B5 | 10-07 | F1 | 13-01 |
| A6 | 09-10 | B6 | 10-08 | F2 | 13-02 |
| A7 | 09-17 | B7 | 10-09 | F3 | 13-04 |
| A8 | 09-16 | B8 | 10-10 | F4 | 13-03 |
| A9 | 09-13 | B9 | 10-11 | F5 | 13-05 |
| A10 | 09-14 | B10 | 10-00, 10-13 | F6 | **09-01** |
| A11 | 09-00.3, 09-00.4, 09-15 | C1 | 12-01 | F7 | 13-06 |
| A12 | 09-00.8, 09-12 | C2 | 12-04 | F8 | 12-02 |
| A13 | 09-00.5, 09-11 | C3 | 12-05 | F9 | 13-00, 13-07 |
| D1 | 10-12 | C4 | 12-06 | G1–G4 | 13-09 |
| D2 | 10-04, 12-07 | C5 | 12-03 | G5 | 13-10 |
| D3 | 13-08 | H1 | **09-02** | G6 | 13-00 |

---

## Task 09-00 — Decision Gate: Content [DECISION NEEDED]

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Read**: the status table above. Only ✅ rows are settled; every
>   "Open questions" list inside a sub-task is still unanswered.
> - **Do**: ask one sub-task at a time, explain it against the real code first,
>   and write each answer into the file right away (answer + consequences +
>   open follow-ups, then update the table).
> - **Status (2026-09-27)**: ✅ all 8 sub-tasks answered. Three small items
>   were explicitly deferred by the user to the build task that needs them:
>   - 6th garage slot → 09-04
>   - 12 → 20 wave timing → 09-17
>   - boss resist values → 09-11
> - **Update 2026-09-28**: all three are now answered, inside those build
>   tasks (the 6th slot is removed; the switch to 20 waves happens at the
>   start of 09-17; each boss resists its themed set's school, Void none).
>   The 2026-09-28 session also answered every build-task question (09-04,
>   09-07, 09-08, 09-11, 09-13, 09-16, 09-17). See each task.

Split into 8 sub-tasks, one per question, answered one at a time. Nothing is
built in any of them: Claude explains what the question means against the
current code, you answer in your own words, and the confirmed answer is
written into that sub-task so later tasks can cite it. A sub-task is done
once its answer is confirmed, or marked "later" (which skips the task that
depends on it).

| Sub-task | Question | Feeds | Status |
|---|---|---|---|
| 09-00.1 | A2 — tower unlock method | 09-03, 09-04, 09-05, 10-04, 10-05, 12-00 | ✅ answered (6th slot: removed, 09-04, 2026-09-28) |
| 09-00.2 | A4 — chapters at launch | 09-08, 09-17 | ✅ answered (12→20: at the start of 09-17, answered 2026-09-28) |
| 09-00.3 | A11a — AoE Area / Lance stacking | 09-15 | ✅ confirmed |
| 09-00.4 | A11b — fill the 5 empty grid spells | 09-15 | ✅ confirmed — no new spells |
| 09-00.5 | A13 — enemy resistances | 09-11 | ✅ answered — WC3 table + boss-only resist (boss values: 09-11, answered 2026-09-28) |
| 09-00.6 | Tower passives + star 3 / 5 | 09-13 | ✅ answered — time charge; trigger tested in 09-13; ults designed in 09-13 |
| 09-00.7 | Spell rank behaviors | 09-14 | ✅ answered — rank 3 / 5 unlocks, per spell |
| 09-00.8 | Second material per chapter | 09-12 | ✅ answered — no new material; per-chapter reward scaling |

---

### Task 09-00.1 — A2: How does the player get tower #2+?

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - ✅ Answered. Unlock order (A); Ancient model is the Poison/Fire placeholder; 6th slot removed (09-04, 2026-09-28).
> - **Read before asking**:
>   - `resources/towers/*.tres`: `tower_ancient_tower.tres` plus the
>     `tower_locked_02–06.tres` "Coming Soon" placeholders.
>   - `autoloads/tower_registry.gd`: `is_playable()`.
>   - `autoloads/meta_manager.gd`: `owned_towers`, `tower_material`,
>     `award_tower_material()`.
>   - `autoloads/Constants.gd`: `MATERIAL_CHECKPOINT_*` and
>     `RARE_MATERIAL_DROP_AMOUNT`, which is how rare materials drop today.
> - **Watch out**: 5 towers vs 6 garage slots is still unconfirmed.

**Status**: ✅ answered (2026-09-27). The 6th garage slot is deferred (see
Q8).

**Answer (user, 2026-09-27, revised the same day)**:

- **Normal progression is fixed, one tower per chapter, in this order.**
  **Beating a chapter unlocks its tower directly.** There's no shard item and
  no "1/5" counter; the tower (its garage slot) is simply locked behind that
  chapter.

  | You beat… | Unlocks |
  |---|---|
  | (start) | Ancient Tower (Nature), owned from a fresh save |
  | Chapter 1 | Frost Tower |
  | Chapter 2 | Void Tower |
  | Chapter 3 | Poison Tower |
  | Chapter 4 | Fire Tower |

  After chapter 4 the player owns all 5 schools.
- **Regular materials** (Base, Tower, and the 5 school Scrolls, which stay as
  they are; the codex gets reworked later) keep dropping from runs as today.
- **The shortcut is a store chest**: a **material chest** bought with gems can
  also contain a **tower** (random, never one already owned). Towers are
  **not** sold directly. See "Store rule" below.
- **Superseded the same day**: tower shards dropped by bosses and found in
  chests; "gems must never buy upgrade materials". The user accepted capped
  pay-to-skip instead (below).

**Store rule — "capped pay-to-skip"** (user, 2026-09-27). This constrains
Epics 10 and 12:

| Gems buy | Limit | Contents / effect |
|---|---|---|
| **Material chest** | **3 per day** | Base Material, Tower Material, Scrolls, capped at **what one full energy bar (5 runs) would earn**. Also a **chance of a random tower the player doesn't own yet**. Once every tower is owned, materials only. |
| **Energy refill** | **no limit** | "They can grind and pay." |
| **Skins** | no limit | Look only (12-05). |

- **No separate keys.** A bought chest **comes with its key**; a key is never
  sold on its own. (If earned chests also exist in 10-05, they come with
  their key too.)
- The user knowingly **accepts that this is pay-to-skip / mildly
  pay-to-win**: 3 chests a day for anyone who wants to rush.
- Drop odds (materials and the tower chance) are decided later, in balancing.

**Consequences to carry into other tasks**:
- At least **4 chapters at launch** (09-00.2 says ~10). Chapters 3+ reuse
  chap1/chap2 models (rule 1).
- **Poison and Fire towers have no models.** They borrow an existing tower
  line (09-04) until real ones exist.
- **5 towers vs 6 garage slots**: ✅ the 6th slot is removed (09-04,
  2026-09-28).
- 09-05: a tower unlocks on the chapter's first victory (tied to 09-10's
  `mark_chapter_cleared`) **or** from a chest. Both call one `MetaManager`
  unlock function. The garage shows "Beat Chapter N" on locked towers.
- A tower from a chest doesn't unlock its chapter; chapter progress can't be
  bought.
- **Towers should be sidegrades** (different, not strictly stronger), since
  they can come from a bought chest. Keep this in mind when designing the
  ults in 09-13.
- **Reference chapter for "one energy bar's worth"**: not decided. Claude
  suggested the player's **highest cleared chapter**, so chest value grows
  with progress. Confirm when building 10-05.
- **Unlimited energy refills** are also a way to buy materials (more runs),
  with no cap. Accepted as is.
- Epic 10 (10-00 store/chest answers, 10-04, 10-05) and Epic 12 (12-00
  catalog) must follow this rule. Its daily counter lives in `SaveData`
  (+ migration).

**Open questions**:
1. Theme vs order. The themes are now known (09-00.2 Q2): Ch1 Nature, Ch2
   Ice, Ch3 Void, Ch4 Poison, Ch5 Fire, then mixed. Two readings fit what
   was said; pick one:
   - **(A) Beating a chapter unlocks the *next* chapter's school**: Ch1
     (Nature) → Frost, Ch2 (Ice) → Void, Ch3 (Void) → Poison, Ch4 (Poison)
     → Fire. You get the tower of the theme you're about to face. This is
     the table in the answer above.
   - **(B) Beating a chapter unlocks its *own* school**: Ch2 (Ice) → Frost,
     Ch3 (Void) → Void, Ch4 (Poison) → Poison, Ch5 (Fire) → Fire. Ch1 gives
     no tower (you start with Nature), so all 5 need Ch5.

   Answer (2026-09-27): **(A)**. Ch1 → Frost, Ch2 → Void, Ch3 → Poison,
   Ch4 → Fire, as the table above says. Ancient is the starting tower.
2. ~~Shards needed~~: no longer applies (no shards).
3. Beat or reach? Answer: **beat.** Finishing the chapter unlocks the tower.
4. ~~Replay drops for an owned tower~~: no longer applies (normal rewards
   only).
5. ~~Chest when every tower is owned~~: **materials only** (see store rule).
6. Gems → buy a tower directly? Answer: **no.** A tower only comes from a
   chest, at random.
7. Chests? Answer: **the store rule above** (3/day, key included, materials
   capped at one energy bar, chance of an unowned tower).
8. Poison and Fire towers have no models. What stands in for them?
   Answer (2026-09-27): **the Ancient Tower model as the placeholder**
   (tinted to the school) until their real models exist.
   **Deferred** ("the rest can wait"): whether the 6th garage slot stays
   "Coming Soon" or is removed. **Answered 2026-09-28 in 09-04: removed**
   (`tower_locked_06.tres` deleted; re-added only with a real 6th tower).

**Acceptance criteria**:
- [x] All questions answered or explicitly deferred.


---

### Task 09-00.2 — A4: How many chapters at launch?

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - ✅ Answered. The 12 → 20 wave switch happens at the start of 09-17 (answered 2026-09-28).
> - **Read**:
>   - `autoloads/Constants.gd`: `TOTAL_WAVES = 12`, `WAVE_DURATION_MAX`,
>     `MATERIAL_CHECKPOINT_WAVES = [3, 6, 9, 12]`.
>   - `resources/chapters/chapter_01.tres`: `wave_count = 12`.
>   - `scenes/manager/wave_manager.gd`: `_get_wave_composition()`, where
>     `enemy_pool[1]` is the "fast" enemy.

**Status**: ✅ answered (all open questions answered; the last, 12 → 20 timing, on 2026-09-28).

**Draft answer (user, 2026-09-27)**:
- **About 10 chapters at launch** ("10 or something like that"). **Update
  2026-09-28 (09-08):** Epic 09 builds all 10. Chapters 3–10 are
  placeholders mixing chap1 (Nature) and chap2 (Frost) enemies until real
  models exist. More content
  gets added over time, so the chapter list must stay open-ended: adding a
  chapter = new `.tres` + arena, no code change (09-06 already builds it that
  way).
- **Enemies are mixed across chapters for variety.** Chapter 1 is all nature
  enemies; later chapters mix-and-match enemies from different chapters
  instead of each chapter only using its own set.
- **20 waves per chapter** is the real target. The current 12 is only a
  testing value (shorter runs are easier to test), not the design.

**Consequences to carry into other tasks** (not decisions, just what the
answer implies):
- **Mixing enemies costs no new scenes.** A chapter's `enemy_pool`/`boss_pool`
  can list any existing enemy `.tres` from any chapter folder. So chapters
  3–10 can be built almost entirely from the chap1 + chap2 roster (12
  enemies/bosses), and only need new scenes where a tinted or retuned variant
  is wanted. This changes 09-08: "copy a folder per enemy" becomes "reference
  existing enemies, copy only when a variant is needed".
- **Enemies carry a theme/school** ("nature enemies"). This probably relates
  to 09-00.5: chapter 1 all resisting Nature may be intended because they
  *are* nature enemies. Ask there, don't assume.
- **20 waves touches more than one number**: `Constants.TOTAL_WAVES`, each
  chapter's `wave_count`, the material checkpoints
  (`MATERIAL_CHECKPOINT_WAVES = [3, 6, 9, 12]`), and the wave composition
  ramp in `wave_manager.gd`. When to switch 12 → 20 is an open question.
- **The `enemy_pool[1]` = "fast enemy" rule** (09-06) matters more with mixed
  pools. Every chapter's pool must still put a fast enemy at index 1, or the
  rule gets replaced with something explicit.

**Open questions**:
1. Chapters 5–10 come after every tower is unlocked (09-00.1). What does
   their final boss drop after all towers are unlocked? Answer (2026-09-27):
   **later**. Not decided yet; the user's direction is "we might add stuff to
   upgrade the towers". Until then, chapter 5+ bosses drop only the normal
   run materials. The drop is data on the chapter, so it's easy to add later.
2. Themes: does each chapter have a theme?
   Answer (2026-09-27): **yes, the first 5 chapters are one school each,
   then mixed**:

   | Chapter | Theme |
   |---|---|
   | 1 | Nature (as built today) |
   | 2 | Ice / Frost (the chap2 models) |
   | 3 | Void |
   | 4 | Poison |
   | 5 | Fire |
   | 6–10 | **mixed**: enemies from several themes combined |

   - Chapters 3–5 have no models of their own, so they reuse chap1/chap2
     enemies (rule 1) and get their theme from arena colours, a school tint
     on the reused models, and their boss setup, until real models exist.
   - How this lines up with the tower unlocks is 09-00.1 open question 1.
3. When do runs switch from 12 to 20 waves: now, or at balancing (09-17),
   keeping 12 while building? Answer (2026-09-27): **deferred ("can wait").**
   Keep 12 while building. 09-17 already lists the switch, so it's decided
   there at the latest.
   **Answered 2026-09-28: at the start of 09-17.** Everything before it is
   built at 12. New chapters (09-07 / 09-08) set `wave_count = 12` until
   then.

**Acceptance criteria**:
- [x] All questions answered or explicitly deferred.

---

### Task 09-00.3 — A11a: Should AoE Area and Lances stack?

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - ✅ Confirmed. Nothing to ask. The work lives in 09-15.

**Status**: ✅ confirmed by user (2026-09-27).

Before: `stack_max = 1` on AoE Area and Lance (`spells.md` §6.6, "open design
decision"). Bolt and Chain were 3, Orb 8 (checked in every spell `.tres`,
2026-09-27).

**Draft answer (user, 2026-09-27)**: yes, they stack. New pick caps:

| Spell type | Spells | `stack_max` before | `stack_max` now |
|---|---|---|---|
| AoE Area | Rain of Fire, Blizzard | 1 | **3** |
| Lance | Flame, Glacier, Rift, Toxic, Briar | 1 | **5** |
| Chain Bolt | Chain of Chaos, Contagion, Leeching Vines | 3 | **5** |
| Standard Bolt | all 5 bolts | 3 | **5** |
| Orb | all 5 orbs | 8 | 8 (not mentioned, unchanged) |

Plus: **the Lance needs work, starting with a bigger hitbox.** Today the hit
area is `Constants.LANCE_HITBOX_LENGTH = 1.6` × `LANCE_HITBOX_WIDTH = 0.7`
(exported on `line_aoe_bolt.gd`, so it can be tuned in the Inspector).

**Consequences to carry into other tasks**:
- Bolt and Chain going 3 → 5 is only a `stack_max` change in their `.tres`
  files: their existing "one more projectile per pick" behavior extends as-is.
- The Orb angle sequence already supports 8; untouched.
- New caps change draft odds: owned spells stay in the draft pool longer.
  Check this in balancing (09-17).
- The old "Thorn Bolt free copy" quirk (`spells.md` §6.2) is dead code (B10),
  so there's no cap interaction to worry about.

**Open questions**:
1. **AoE Area, picks 2 and 3**: what does each extra pick do?
   Answer (2026-09-27): **each extra pick adds 1 more spell fired**, i.e. one
   more zone per cast (pick 3 = 3 zones per cast).
2. **Lance, picks 2–5**: what does each extra pick do?
   Answer (2026-09-27): **each extra pick adds 1 more spell fired**, i.e. one
   more lance per cast (pick 5 = 5 lances per cast). Same rule as
   Bolt/Chain.
   - 2a. Should the extra zones/lances work like the existing Bolt volley?
     Answer (2026-09-27): **yes.** Each extra one behaves exactly like the
     first, aimed at a **different random enemy** in range, fired with a
     slight delay after the previous one (`BOLT_VOLLEY_STAGGER_SEC`). This
     applies to both AoE Area spells (**Blizzard** and **Rain of Fire**) and
     all 5 Lances.
3. **Lance hitbox**: how much bigger?
   Answer (2026-09-27): **a bit bigger than now, mainly wider.** The goal:
   when several enemies are bunched next to the tower and the lance fires at
   one of them, it should also hit the enemies **to its left and right**, plus
   everything **behind** it along its path (the piercing part already works).
   Exact numbers are tuned when the task is built ("we will optimise it as we
   get to it"). Test setup: a few enemies clustered side by side near the
   tower.
4. **"Lance should be worked on"**: anything besides the hitbox?
   Answer (2026-09-27): **no, only the hitbox.** The 4 m trigger range stays.

**Acceptance criteria**:
- [x] Open questions 1–4 answered and the draft marked confirmed by you.

---

### Task 09-00.4 — A11b: Fill the 5 empty grid spells?

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - ✅ Confirmed: no new spells. Nothing to do.

**Status**: ✅ confirmed by user (2026-09-27).

The 5 empty spells are Fire and Frost chains, and Void, Poison and Nature AoE
Areas (`spells.md` §4 "Extend later by").

- [x] Answer: **No, don't fill them.** 20 spells is enough for now. The work
      was removed from 09-15; the game stays at 20 spells, 4 per school.

---

### Task 09-00.5 — A13: Enemy resistances

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - ✅ Answered. Boss resist values answered 2026-09-28 (table in 09-11). Both chap1 bosses
>   currently have `resisted_school = 4` (Nature) in
>   `scenes/game_object/chap1/chap1_boss_01/chap1_boss_01.tres` and
>   `chap1_boss_02/chap1_boss_02.tres`.
> - **Code involved** (line numbers as of 2026-09-27): see 09-11's note.

**Status**: ✅ answered (boss values answered 2026-09-28, see 09-11).

**Context found while asking (2026-09-27)**: there are **two** damage layers
today, and they multiply on every hit:
1. The **WC3 table** (`project.md` "Damage Type vs Armor Table (v2)",
   `CombatUtils.DAMAGE_TABLE`): school × the enemy's armor type.
2. A **per-enemy resisted school** (`EnemyDefinition.resisted_school`, × 0.5
   via `SCHOOL_RESIST_MULT` in `hurtbox_component.gd`). Every chapter-1
   enemy is set to resist Nature.

Chapter 1 armor, read from each `.tres`: enemy_01/02/03 Light, enemy_04
Heavy, enemy_05 Medium, both bosses Fortified.

**Draft answer (user, 2026-09-27)**: **the WC3 table should be the only
system.** The per-enemy resistance layer goes away. Counterplay comes purely
from each enemy's armor type, like in WC3.

**Consequences to carry into other tasks**:
- 09-11 changes from "set resists per chapter" to **"remove the resist
  layer"** (rewritten below).
- Code that touches the resist layer, found by grep:
  - `EnemyDefinition.resisted_school`
  - `HurtboxComponent.resisted_school` and its resist check
  - `enemy.gd` line copying it onto the hurtbox
  - `Constants.SCHOOL_RESIST_MULT`
  - the `resist_mult` param of `CombatUtils.apply_school_perk()`
  - the comment in `combat_utils.gd`
  - `resisted_school = 4` in all 7 chapter-1 `.tres`
- Status effects (burn/slow/poison/lifesteal) are no longer halved by
  anything. Only damage is scaled, by the table.
- Docs to update: `spells.md` §3 "Resistances" and §6.5, `project.md` v1/v2
  table notes, `mechanics.md` §5.
- **Each chapter's variety now comes from its armor-type mix.** Picking armor
  types per enemy/chapter is part of building chapters (09-07 / 09-08) and
  balancing (09-17).
- Chapter 1 goes from Nature 35–75% to the plain table values: Light 100%,
  Heavy 100%, Medium 150%, Fortified 70%.

**Open questions**:
1. Remove it completely, or turn it off?
   Answer (2026-09-27): **neither. Keep it, but for bosses only**, so bosses
   can be given a resistance. The result:
   - **Regular enemies**: WC3 table only. Their `resisted_school` is cleared
     (set to none) in every regular-enemy `.tres`.
   - **Bosses**: WC3 table **plus** an optional resisted school (× 0.5
     damage and status, Void never resisted). This is the existing code,
     unchanged.
   - The code stays (field, constant, hurtbox check). It's a data rule: only
     boss `.tres` files set it.
   - This partly reverses the "Consequences" list above: nothing is deleted.
     Regular enemies lose their resist; bosses keep the mechanic.
2. The two chapter-1 bosses currently resist **Nature**. Keep that, change
   it, or set it per boss when chapters are built/balanced?
   Answer (2026-09-27): **deferred ("can wait").** The bosses keep Nature
   for now; each boss's resist is set when 09-11 is built.
   **Answered 2026-09-28**: a boss resists its chapter's school (Ch1 Nature,
   Ch2 Frost, …). Full table in 09-11.

---

### Task 09-00.6 — Tower passives + star 3 / star 5

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - ✅ Answered. What's left happens inside 09-13: the trigger-mode test and
>   research, and each tower's ult design.

**Status**: ✅ answered (2026-09-27). Left for 09-13: the trigger mode (tested + researched there)
and each tower's actual ult (designed there).
**Update 2026-09-28**: the research is done and all 5 ults are designed (see
09-13's table): Ancient Barkskin, Frost AoE snare, Void Rupture, Poison
Plague Cloud, Fire Ring of Fire. The auto-vs-tap pick is **consciously left
to play-testing**; 09-13 builds both modes.

Covers **5 towers** (Ancient, Frost, Void, Poison, Fire), per 09-00.1.

**Context found while asking (2026-09-27)**:
- The tower has no attack of its own. Everything comes from drafted spells,
  and every tower can use every spell.
- So towers currently differ **only in stats**. Stars add +10% max HP and +10%
  spell damage per star above 1 (`STAR_STAT_BONUS_PER_LEVEL`).
- `project.md`'s old Ancient passive ("every 5th shot → 3-way burst") dates
  from when the tower had a base attack. It's obsolete; drop it from
  `project.md` in 09-02.

**Draft answer (user, 2026-09-27)**:
1. **Yes, every tower gets its own passive**, and it's usually **like an "ult"
   in other games**: a big signature ability, not a small stat tweak.
2. **What each of the 5 towers does: not decided yet.** It gets designed
   tower by tower when we get to 09-13.
3. **Star 3 and star 5 = a stronger version of that tower's ult.** Stars keep
   their existing +10% HP / damage per star as well; nothing said otherwise.

**Consequences to carry into other tasks**:
- 09-13 can build the **shared framework** (how an ult charges, fires and gets
  stronger at star 3 / 5) once the open questions below are answered. Each
  tower's actual ult is a small subclass designed one at a time.
- If the ult is **player-triggered**, the in-run HUD needs an ult button with
  a charge display. That brings back the "tower ability icon" you removed
  from the art list, as a placeholder at first.

**Open questions**:
1. **Trigger**: does the ult fire automatically when ready, or does the
   player tap a button to fire it?
   Answer (2026-09-27): **undecided on purpose; test both.** The user isn't
   sure which is better, and wants to:
   - (a) **try both in play**
   - (b) **research what players prefer**: forums, reviews, comparable mobile
     tower-defense/roguelite games

   So 09-13's framework supports **both modes behind one switch**
   (`Constants` or the tower `.tres`), and the tap button only exists in tap
   mode. The final pick is made after the test and research, and recorded
   here.
2. **Charging**: what fills it?
   Answer (2026-09-27): **time**, because it's the easiest to balance. The
   charge duration is a tunable number (per tower on its `.tres`, default in
   `Constants`).

---

### Task 09-00.7 — Spell rank behaviors

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - ✅ Answered. The work lives in 09-14.

**Status**: ✅ answered (2026-09-27).

**Context found while asking (2026-09-27)**:
- Ranks 1–5 are bought in the Spell Codex with base material plus that
  school's scroll (`SPELL_RANK_COSTS` / `SPELL_RANK_RARE_COSTS`).
- Today a rank only adds **+8% damage per rank above 1**
  (`SPELL_RANK_DAMAGE_BONUS_PER_LEVEL`), via
  `GameState.get_spell_damage_multiplier()`.
- Ranks are permanent (meta); stacking is in-run (09-00.3).

**Draft answer (user, 2026-09-27)**:
- **Yes, ranks unlock new behaviors** on top of the damage bump, which stays.
- **Only at milestones: rank 3 and rank 5.** Ranks 2 and 4 stay pure damage.
- **Per spell**: an unlock applies only to the exact spell ranked up (see open
  question 1). The unlock **design** is shared by type, per the table:
  every Bolt's rank 3 is a splash, but only for Bolts ranked to 3.


| Spell type | Rank 3 unlocks | Rank 5 unlocks |
|---|---|---|
| Standard Bolt | small **splash** on hit | **bigger** splash |
| Chain Bolt | **+1 bounce** | **+1 more** bounce (+2 total) |
| Orb | **faster spin** | **bigger orbs** |
| AoE Area (Blizzard, Rain of Fire) | zone **lingers longer** | **bigger zone** |
| Lance | **bigger size** | leaves a **damaging trail** |

Exact numbers (splash radius, extra seconds, size %, trail damage/duration)
get tuned when 09-14 is built and in balancing (09-17). They live in
`Constants` or on the `.tres`, per the balance rule.

**Consequences to carry into other tasks**:
- Chain's bounce count is already a per-spell number (`max_bounces`,
  `CHAIN_MAX_BOUNCES`). Rank adds to it; no new mechanic.
- Orb: faster spin speeds up the whole ring, so every orb of that spell
  stays evenly spaced (the ring spins as one).
- Bigger orbs / zones / lances need both the **visual and the hit size**
  scaled together, or the look and the hits disagree.
- Bolt splash and Lance trail are **new hit sources**. They should go through
  the same `HurtboxComponent.apply_hit()` funnel as everything else.
- The Codex row shows "Rank 3: …" / "Rank 5: …" so players see what they're
  buying.

**Open questions**:
1. Per spell type or per spell?
   Answer (2026-09-27): **per spell.** Unlocks apply only to the **exact spell**
   you ranked up. Example: ranking Thorn Bolt (Nature) to 3 gives Thorn Bolt
   its splash; Bolt of Fire gets nothing until *it* is ranked. This matches
   the code (`MetaManager.spell_ranks` is keyed by `spell_id`). The **design**
   of each unlock is shared by type (the table above: every Bolt's rank 3 is
   a splash), but it turns on per spell.
2. Lance rank 3 "bigger size": does the hit area grow too?
   Answer (2026-09-27): **yes.** The look and the hit area both grow, on top
   of the 09-15 hitbox increase.
3. Do the splash and the trail apply the school's effect?
   Answer (2026-09-27): **yes.** Fire burns, Frost slows, Poison poisons and
   Nature lifesteals, the same as a direct hit (through `apply_hit()`, which
   already applies the school perk).

---

### Task 09-00.8 — Second material per chapter

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - ✅ Answered. Nothing to ask. The work is 09-12 (now a reward-scaling
>   task, not a new material).

**Status**: ✅ answered (2026-09-27).

**Context found while asking**: today's materials are the same in every
chapter:
- **Base Material**: every run, by checkpoint 50 / 100 / 150 / 220; spent on
  stars and ranks.
- **Tower Material**: a rare chance (6% → 25%); spent on stars.
- **5 school Scrolls**: a rare chance per school used; spent on ranks.

The roll happens in `CombatUtils.roll_material_reward()`
(`scripts/combat_utils.gd` ~300–346).

**Answer (user, 2026-09-27)**: **no separate chapter material.** Towers
already come from chapters (or a gem chest, 09-00.1), so a chapter material
isn't needed. Claude's recommendation, accepted: **later chapters give bigger
amounts of the existing materials**, through one reward multiplier per
chapter. That gives a reason to replay hard chapters without adding a
currency.

- [x] Answered. A12 is covered by 09-12 as per-chapter reward scaling.

---

## Task 09-01 — Save Versioning & Migration (moved here from F6) ✅ DONE (2026-09-29)

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Read**:
>   - `scripts/save_data.gd`. As of 2026-09-27 it has **no** `save_version` and
>     **no** `premium_currency`.
>   - `autoloads/meta_manager.gd`: `save()` / `load()` (~lines 83–121), and
>     `premium_currency` (line 13, never saved).
> - **Watch out**:
>   - `MetaManager.load()` shadows Godot's global `load()`. Inside the class,
>     call it as `self.load()`.
>   - `SaveData` uses a global `class_name` (see the cache caveat in
>     `components.md` §7).
> - **Before any test**: back up
>   `%APPDATA%\Godot\app_userdata\TowersLastStand3D\savegame.tres` and restore
>   it after.

**Covers**: F6 · **Files**: `scripts/save_data.gd`, `autoloads/meta_manager.gd`
**Ref**: `project.md` "Save Data — Temporary Local-Only Approach"

> **Why this is first:** Epics 09 and 10 add new save fields (cleared
> chapters, gems, chests, daily streak, settings…). Without a version number,
> each of those is a chance to silently wipe or corrupt an existing save.
> Doing this before any of them costs one small task.

- [x] Add `@export var save_version: int` to `SaveData` and a
      `Constants.SAVE_VERSION` (starts at 2; saves with no field count as 1).
- [x] `MetaManager.load()` runs an ordered list of small migration steps
      (`_migrate_1_to_2()`, …) on older saves, then saves. Each step only
      fills in defaults for fields it introduced.
- [x] Fix the existing gap found while writing this epic:
      `MetaManager.premium_currency` exists but **is not in `SaveData`**, so it
      never persists. Add it here, as migration 1 → 2.
- [x] Rule for every later task that adds a save field: bump
      `SAVE_VERSION` and add a migration step. This rule is repeated in each
      task that touches `SaveData`.

**Placeholders**: none · **Preview**: none (data only). Verified with a headless
round-trip on a **backed-up copy** of the real save (memory: tests write to the
real `user://savegame.tres`).

**Done (2026-09-29)**:
- `Constants.SAVE_VERSION = 2`
- `SaveData.save_version` (default 1, so an old file with no field = v1) +
  `premium_currency`
- `MetaManager.load()` runs `_migrate_from()`, which calls each
  `_migrate_N_to_N+1()` by name and then saves once. A newer version sets
  `_read_only`, and `save()` then refuses and logs once. The rule comment
  is in `save_data.gd` and next to `SAVE_VERSION`.
- Verified headless on a backup of the real save: 16/16 checks (every old
  value kept, the file now says v2, gems round-trip, a v99 file is
  byte-identical after save() + spend_energy()). The real save was
  restored, then the game booted headless for 600 frames with no errors,
  and the save migrated to v2 with all values intact.
- **Addendum 2026-09-29 (user request, after 09-05)**: `selected_tower_id`
  is saved now.
  - Save **version 3** (`_migrate_2_to_3` → "ancient_tower").
  - `MetaManager.select_tower(id)` sets and saves; the garage calls it on
    tap.
  - `load()` falls back to Ancient if the saved pick isn't owned.
  - Tested without writing the real save (temp file + `_read_only`). The
    user's save migrated 2 → 3 with the Frost unlock intact.

**Acceptance criteria**:
- [x] A save file written before this change loads with every old value
      intact and `save_version` = current.
- [x] A save with a *higher* version than the game knows is not overwritten
      (it's loaded read-only or refused, and the problem is logged).

---

## Task 09-02 — Docs Cleanup (moved here from H1) ✅ DONE (2026-09-29)

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Read**: `components.md`, `mechanics.md`, `spells.md` §3 / §6,
>   `project.md`, `skills/godot3d-combat/SKILL.md`.
> - **Verify each claim in code before writing it**:
>   - `scenes/game_object/tower/tower.gd` uses a `_spell_timers` dict, not
>     `CooldownComponent`s.
>   - Hits go through `HurtboxComponent.apply_hit()`
>     (`scenes/component/hurtbox_component.gd`).
>   - Chap1 armor types are Light/Heavy/Medium/Fortified.
>   - `tower_ancient_tower.tres` still has `starting_spell_id = "lance_rift"`,
>     but it's unused.
> - **Also include**:
>   - the 09-00.5 answer (resist is boss-only)
>   - the 09-00.3 stack caps
>   - removing `project.md`'s obsolete Ancient passive
>   - the stale `epic_0N` mentions in code comments: `hurtbox_component.gd`,
>     `tower.gd`, `damage_number_3d.gd`, `outlined_label_3d.gd`,
>     `pause_button.gd`, `value_bar_3d.gd`

**Covers**: H1 · **Files**: `components.md`, `mechanics.md`, `spells.md`

> **Why this is early:** rule 3 says every task follows the `.md` files. Right
> now some of them are wrong, so a task following them would build the wrong
> thing.

- [x] Fix every stale spot listed in H1:
  - synergy tags (bookkeeping only)
  - starting spell (`spells.md` §6.2 — no free spell; first-spell draft)
  - enemy pooling (enemies `queue_free()`, not pooled)
  - "resistances not used yet" (`spells.md` §6.5 — they are)
  - the missing `HUD.tscn` (the HUD is inline in `game_world.tscn`)
  - `spells.md` §6.7
- [x] Also fix the ones found this session:
  - `project.md` says no enemy uses Light/Medium/Fortified. Check each
    enemy `.tres` and correct it.
  - `components.md` §6 says one `CooldownComponent` per spell. `tower.gd`
    uses a `_spell_timers` dict.
  - Hit detection is a hybrid broad-phase + `apply_hit()`, not
    `area_entered`. Fix this in `mechanics.md` §5 and the `godot3d-combat`
    skill.
  - References to `epic_0N_*.md` now point to `epic_done/`.
- [x] Write the **09-00 decisions** into the design docs, so they stop
      contradicting the plan:
  - `project.md` "Tower (v1)": drop the obsolete Ancient passive. Towers get
    ults (09-00.6). Towers unlock per chapter (09-00.1).
  - `project.md` + `mechanics.md` §12 monetization: the "capped
    pay-to-skip" store rule (09-00.1) replaces "time-saving, not power".
  - `mechanics.md` §11 meta: no second chapter material (09-00.8); rank 3 /
    5 unlocks (09-00.7); star 3 / 5 = stronger ult (09-00.6).
  - `spells.md` §3 / §6.5: WC3 table for everyone, resist is boss-only
    (09-00.5). §6.6: new stack caps (09-00.3). §4: 20 spells final, no grid
    fill (09-00.4).
  - Chapter plan: about 10 chapters, themes Nature / Ice / Void / Poison /
    Fire then mixed, 20 waves target (09-00.2).

  Only write what's confirmed in 09-00; open items stay marked open.
  - Also the **2026-09-28 answers** that touch design docs:
    - chapter plan: 10 chapters (5 regular + 2 bosses each), names so far
      Ancient Ruins / Frozen Wastes / Void / Poison / Fire (09-07, 09-08)
    - boss resist rule: each boss resists its themed set's school, Void
      none (09-11) → `spells.md` §3
    - the 5 tower ults (09-13) → `project.md` "Tower (v1)"
    - boss phases + "BOSS" banner (09-16) → `mechanics.md` §1 / §3
    - 20 waves from 09-17 on
- [x] Verify each claim against the code before writing it (memory: verify,
      don't generalize).

**Placeholders**: none · **Preview**: none.

**Done (2026-09-29)**. Each fix and the code it was checked against:
- **Synergy tags are bookkeeping only**: `game_state.gd` ~127–131
  (`add_tag`, no `_apply_synergy_bonus`). Fixed in `spells.md` §6.7 and
  `components.md` §0 / §3 (the §2 constants block is marked a historical
  snapshot).
- **No starting spell**: `tower.gd` ~29–35 and `game_world.gd` ~25–32
  (`"first_spell"` draft). Fixed in `spells.md` §6.2 / §6.10 and
  `components.md` §5 (`starting_spell_id` marked dead).
- **Enemies are not pooled**: `death_fx_component.gd:12` (`queue_free`),
  `wave_manager.gd` `_spawn_enemy()`. Fixed in `mechanics.md` §3 / §8 / §9
  and the `godot3d-combat` skill (pooling section rewritten).
- **Resistances are in use**: all 7 chap1 `.tres` have
  `resisted_school = 4`; `hurtbox_component.gd:17–24`. Fixed in
  `spells.md` §3 / §6.5 and `project.md` v1/v2 notes, with the boss-only
  decision and the boss rule.
- **No HUD.tscn**: only `scenes/main/hud.gd` exists. Fixed in the
  `components.md` §1 tree.
- **Armor types in use**: chap1 enemy_01–03 Light, 04 Heavy, 05 Medium,
  bosses Fortified (each `.tres`). Fixed in `project.md` v2 note and
  `mechanics.md` §5.
- **No CooldownComponent in use**: `tower.gd:15` `_spell_timers`,
  `enemy.gd:13` `_attack_timer`, grep = no instances. Fixed in
  `components.md` §4 / §6 and `mechanics.md` §8.
- **Hybrid hit detection**: `hurtbox_component.gd:16` `apply_hit()`,
  `standard_bolt.gd` ~45–87, all 5 archetypes call it; no `area_entered`.
  Fixed in `mechanics.md` §5, `components.md` §4 and the `godot3d-combat`
  skill (Hitbox/Hurtbox, AoE and Targeting sections rewritten; targeting is
  random, `targeting_component.gd:42–44`).
- **Also found**: `HitboxComponent` is instanced nowhere (grep). Documented
  as unused, left for 10-13.
- **`epic_0N` references → `epic_done/`**: 7 docs and 6 code comments
  (`hurtbox_component.gd`, `tower.gd`, `damage_number_3d.gd`,
  `outlined_label_3d.gd`, `pause_button.gd`, `value_bar_3d.gd`). The audio
  reference now points to `epic_11_audio.md`.
- **09-00 and 2026-09-28 decisions written in**:
  - `project.md`: Core summary (chapters / meta / monetization) and Tower
    section (ult table; old passive dropped).
  - `mechanics.md`: §1 camera (no shake, banner only), §3 boss phases, §11
    meta, §12 store rule.
  - `spells.md`: §3 resist, §4 20 spells final, §6.4 short-range decision,
    §6.6 new stack caps, S-04 / S-05 stacking notes.
- Checked: the game boots headless (world map, and `game_world.tscn` for 900
  frames) with no errors. Code changes are comments only.

**Acceptance criteria**:
- [x] Each fix above cites the file and line it was checked against.

---

## Task 09-03 — Frost Tower & Void Tower (playable) ✅ DONE (2026-09-29)

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Read**:
>   - `scenes/game_object/tower/ancient_tower/ancient_tower_lvl1–5/` (each has
>     a `.tscn` and a `.tres`).
>   - `resources/towers/tower_ancient_tower.tres` (`star_level_scenes`).
>   - `resources/towers/tower_locked_02.tres` / `_03.tres`.
>   - `autoloads/tower_registry.gd`: `get_preview_model()` finds `.glb`s by the
>     `assets/models/towers/<id>/<id>_lvl<N>.glb` convention.
>   - `scenes/ui/widget/tower_preview_3d/tower_preview_3d.gd`.
>   - `scenes/ui/tower_garage_content.gd`.
> - **Verify**:
>   - The models exist in `assets/models/towers/frost_tower/` and
>     `void_tower/` (lvl1–5, confirmed 2026-09-27).
>   - Which frost/void `.glb`s have an `idle` clip.
> - **Watch out**:
>   - The `ancient_tower_lvlN.tres` files were orphaned (loaded nowhere) per an
>     earlier audit. Check before copying them.
>   - `ancient_tower_lvl5_fx.tscn` + `.gdshader` are Ancient-only waterfalls.
>     Don't copy them.
>   - Frost icon: `assets/ui/garage/icon_tower_frost_selection.png`.

**Covers**: A1 · **Refs**: `components.md` §3 `TowerRegistry`, §7 "Tower Garage";
`assets.md` §2 tower-line folders; existing
`scenes/game_object/tower/ancient_tower/`

Models already exist: `assets/models/towers/frost_tower/frost_tower_lvl1–5.glb`,
`void_tower/void_tower_lvl1–5.glb`.

- [x] For each of `frost_tower` and `void_tower`: create
      `scenes/game_object/tower/<id>/<id>_lvl1..5/<id>_lvl<N>.tscn`. Follow the
      structure `ancient_tower_lvlN.tscn` already uses (shared `tower.gd` +
      component scenes + `HealthBar3D`), with the model `ext_resource` swapped.
      The script is shared, not copied.
- [x] Idle animation: `tower.gd._play_idle()` already no-ops on models
      without an `idle` clip. Check which levels have one and note it. Don't
      add idle to every level (deliberate, see the "Removed" list).
- [x] `resources/towers/tower_frost_tower.tres` / `tower_void_tower.tres` replace
      `tower_locked_02` / `tower_locked_03` (keep their `sort_order` 1 and 2).
      Stats start as a copy of Ancient's numbers and get tuned in 09-17.
      `starting_spell_id` stays empty (dead field, B10).
- [x] Ownership follows 09-00.1: each tower is unlocked by **beating its
      chapter** (or from a gem chest), wired in 09-05. Until 09-05 the towers
      exist as content (`unlocked = true`) but aren't owned, so the garage
      greys them out through the existing `TowerRegistry.is_playable()`. To
      play-test before 09-05, add them to `owned_towers` in a throwaway
      headless script on a backed-up save.
- [x] Towers must be **sidegrades**, not strictly stronger, because they can
      come from a paid chest (09-00.1). Keep the base stats close to
      Ancient's; differences come from the ults (09-13).

**Built (2026-09-29)**:
- **Shared base scene** (user's choice, no-duplicate rule):
  `scenes/game_object/tower/tower.tscn` (unused before) now holds everything
  common to every tower level: collision, Health/Targeting/HitFlash
  components, `HealthBar3D`, `AttackRangeArea`. Every `<id>_lvlN.tscn` is an
  **inherited** scene that only adds its model (Ancient lvl5 also keeps its
  `WaterfallFX`). All 5 Ancient scenes were converted too (same UIDs, same
  model transform). 15 level scenes total; 09-04 adds Poison/Fire the same
  way.
- `resources/towers/tower_frost_tower.tres` (sort 1, Frost icon) and
  `tower_void_tower.tres` (sort 2, **Ancient icon as placeholder**, user's
  choice) replace `tower_locked_02/03.tres` (deleted). Stats = Ancient's.
  `icon_tower_void.png` was added to `ui_assets.md` STILL TO MAKE.
- **Idle**: no Frost or Void level has an `idle` clip (checked every
  `.glb`); Ancient has one on lvl3–5 only. Left as is.
- All 15 models share Ancient's normalised box (~1.91 tall), so one model
  transform fits. Void lvl1 is a bit shorter (its lowest point measured
  0.18 vs 0.06), so it may sit slightly high. Check it in the preview.
- **Verified**:
  - Headless: garage order Ancient / Frost / Void; Frost and Void greyed
    (not owned until 09-05); all 15 garage preview models resolve; all 15
    start a real run with the right model, all components, correct star and
    HP (1000 → 1400).
  - Ancient lvl5 measured 0.23 in that ground check. The old and new scenes
    were compared and are identical (same meshes, same positions), so it's
    a measurement quirk, not a change.
  - Windowed screenshots: Frost s1, Void s5 and Ancient s5 standing in a
    run; garage grid with the Frost icon + Void placeholder.
- **Not verified**: actual combat with Frost/Void (same `tower.gd` as
  Ancient, so expected identical); the garage 3D preview visually (open
  `tower_preview_3d.tscn`, set `tower_id` / `star`).
- Added on request: `tower_preview_3d`'s `tower_id` is an Inspector
  **dropdown** of every real tower (`_validate_property`, filled from the
  new static `TowerRegistry.load_sorted()`, which `_ready()` now uses too).
- Leftover: the 5 `ancient_tower_lvlN.tres` next to the scenes are still
  orphaned (loaded nowhere); left for 10-13.

**Placeholders**:
- Frost icon: `garage/icon_tower_frost_selection.png` exists, so use it.
- Void icon: `icon_tower_ancient.png`, tinted purple → final
  `garage/icon_tower_void.png`.

**Preview**:
- Each `<id>_lvlN.tscn` opens in the editor showing the model.
- `tower_preview_3d.tscn` with `tower_id = frost_tower` / `void_tower` and
  `star = 1..5` shows all 10 models with no code change (it resolves `.glb`s
  by ID convention).

**Acceptance criteria**:
- [x] Garage grid shows Ancient, Frost, Void in slots 1–3 with correct icons;
      the 3D preview shows every star level of each.
- [x] With the tower owned and selected, a run starts with that tower's model
      at each star level, and combat works exactly as with Ancient.

---

## Task 09-04 — Extra Tower Slots Reuse Existing Models (for towers without their own model, e.g. Poison & Fire per 09-00.1) ✅ DONE (2026-09-29)

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Status (2026-09-28)**: ✅ All answered (2026-09-28): delete `tower_locked_06.tres`. Nothing left to ask.
> - **Read**: `resources/towers/tower_definition.gd` and
>   `autoloads/tower_registry.gd` → `static func get_preview_model()`
>   (~line 55).
> - **Applies to**: Poison and Fire (no models), per 09-00.1.

**Covers**: A1 (beyond the 3 real models)

- [x] Add `@export var preview_model_id: String = ""` to `TowerDefinition`.
      `TowerRegistry.get_preview_model()` uses it when set, instead of the
      tower's own ID. This is how a new tower borrows an existing tower line's
      `.glb` for the garage preview.
- [x] Per 09-00.1, the two towers without models are **Poison Tower**
      (`poison_tower`, replaces `tower_locked_04`, `sort_order 3`) and **Fire
      Tower** (`fire_tower`, replaces `tower_locked_05`, `sort_order 4`).
      Each gets its own `<id>_lvlN.tscn` gameplay scenes (09-03 pattern)
      instancing the **Ancient Tower model as the placeholder** (09-00.1
      Q8), tinted to its school. The real model arrives
      later as one `ext_resource` change per scene plus clearing
      `preview_model_id`.
- [x] **Delete `resources/towers/tower_locked_06.tres`** (the 6th "Coming
      Soon" slot). ✅ Answered (user, 2026-09-28): **remove it; a 6th cell
      comes back only when a real 6th tower exists.**
  - Why no code change: `TowerRegistry` scans `resources/towers/` and the
    garage grid is built from `TowerRegistry.all_towers`. A grep on
    2026-09-28 found `locked_06` referenced only inside its own `.tres`. It
    was never ownable, so no save holds it and no migration is needed.
  - Result: the grid (`columns = 4`) shows Ancient, Frost, Void, Poison on row
    1 and Fire on row 2.
  - Adding a 6th tower later = a new `tower_<id>.tres` with `sort_order = 5`,
    no code.
  - Follow-up for the preview: `tower_garage_content.tscn` holds 6
    editor-only placeholder cells (`Slot1`–`Slot6`), which `_build_grid()`
    deletes at runtime. Drop `Slot6` so the editor preview matches the real
    5-tower grid. 09-05 edits these same placeholder cells (locked /
    unlockable / owned states), so do it there if this task doesn't.
    Close the scene in the editor first.

**Built (2026-09-29)**:
- `tower_locked_04/05/06.tres` deleted. The garage has exactly 5 towers
  (4 + 1 grid). The editor preview `Slot6` was removed from
  `tower_garage_content.tscn` (comment in `.gd` updated).
- `TowerDefinition` got `preview_model_id` and `model_tint`
  (alpha 0 = none).
  - `TowerRegistry.get_preview_model()` uses `preview_model_id` (via the new
    static `find_definition()`).
  - A shared `scripts/model_tint.gd` (`material_overlay` on
    `MeshInstance3D`s only, so HP-bar billboards are untouched) is applied
    by `tower.gd._ready()` **and** `tower_preview_3d`, so the game and the
    garage match.
- `tower_poison_tower.tres` (sort 3, tint = Poison green, alpha 0.45) and
  `tower_fire_tower.tres` (sort 4, Fire orange, alpha 0.45). Both borrow
  `ancient_tower` models and use Ancient's icon (user's choice, same as
  Void). 10 inherited level scenes as in 09-03 (Ancient's lvl3–5 idle
  plays; no lvl5 waterfall). Stats = Ancient's.
- Placeholder art added to `ui_assets.md` STILL TO MAKE (icons + models).
- **Verified**:
  - Headless: registry = exactly the 5 in order; the preview dropdown
    lists all 5; all 25 tower levels start a run with the right model;
    the tint is on Poison/Fire only (game + preview).
  - Windowed screenshots: garage 5 slots, Poison s1 and Fire s5 in a run,
    Fire s3 in the preview.
- Tune the look: change `model_tint` in the two `.tres` (colour and
  alpha = strength).

**Placeholders**: borrowed tower model + tinted Ancient icon → final
`assets/models/towers/<id>/<id>_lvl1–5.glb` and `garage/icon_tower_<id>.png`.
**Preview**: same as 09-03.

**Acceptance criteria**:
- [x] A borrowed-model tower is playable and previewable. Swapping the real
      `.glb` in touches no `.gd` file.

---

## Task 09-05 — Tower Unlock Method ✅ DONE (2026-09-29, user confirmed: winning ch1 unlocked Frost)

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - ✅ Not blocked: 09-00.1 is fully answered (order A, 2026-09-27).
> - **Read**:
>   - `scenes/ui/tower_garage_content.gd` (action bar with Select/Upgrade +
>     `cost_chip`s).
>   - `scenes/ui/widget/cost_chip/cost_chip.gd`.
>   - `autoloads/meta_manager.gd` (`owned_towers`, `upgrade_tower_star`).
>   - `autoloads/tower_registry.gd` (`is_playable`).

**Covers**: A2 · **Based on**: 09-00.1 (towers unlock by beating a chapter,
or from a gem chest). Order ✅ **(A)**: ch1 → Frost, ch2 → Void, ch3 →
Poison, ch4 → Fire.

- [x] `TowerDefinition` gets `@export var unlock_chapter_id: String`, the
      chapter whose **first victory** unlocks this tower. Ancient stays owned
      from a fresh save. Filled per 09-00.1 Q1 **(A)**: `frost_tower` →
      `chapter_01`, `void_tower` → `chapter_02`, `poison_tower` →
      `chapter_03`, `fire_tower` → `chapter_04`; Ancient empty (owned from
      the start). The mapping is data, so changing the order is a `.tres`
      edit.
- [x] One `MetaManager.unlock_tower(tower_id)` (adds to `owned_towers`, saves,
      emits an `EventBus` signal). It's called from:
      - chapter victory (09-10's `mark_chapter_cleared` → any tower whose
        `unlock_chapter_id` matches)
      - a gem-chest tower drop (10-05)

      No second unlock path.
- [x] Chapter progress is **not** unlocked by getting a tower from a chest.
- [x] Garage: a not-owned tower shows "Beat Chapter N" (from
      `unlock_chapter_id`) in the action bar, where Select/Upgrade are.
      Build note (found 2026-09-28): today `tower_slot` swallows presses on
      **every** locked cell (`tower_garage_content.gd` `_on_slot_pressed`
      comment), so a not-owned tower can't be viewed. Cells that exist as
      content (`unlocked = true`) but aren't owned must become tappable
      (view only; Select stays disabled).
- [x] Victory screen: "New tower unlocked: <name>!" the first time.
- [x] No new save field (uses `owned_towers`), so no migration needed unless
      something else is added.

**Built (2026-09-29)**:
- `TowerDefinition.unlock_chapter_id`: Frost `chapter_01`, Void
  `chapter_02`, Poison `chapter_03`, Fire `chapter_04`; Ancient empty.
- `MetaManager.unlock_tower(id)` is the one unlock path (append + save +
  new `EventBus.tower_unlocked`). `unlock_towers_for_chapter(chapter_id)`
  returns only NEW unlocks.
- Victory hook: `game_world.gd._on_boss_died()` calls it with
  `wave_manager.chapter.chapter_id` and hands the result to the victory
  screen. **09-10 must move this call inside `mark_chapter_cleared()`.**
- Victory screen: new `StatsPanel/UnlockLabel` ("New tower unlocked:
  <name>!"), shown only when something new unlocked. The placeholder text
  shows in the editor preview.
- Garage (`tower_garage_content`, the live one inside `world_map`):
  - `tower_slot` got `viewable`, so an unowned real tower is tappable
    (still grey + padlock). Tapping shows it but never makes it the run's
    tower.
  - The action bar swaps Upgrade + chips for `ActionBar/UnlockLabel`
    "Beat Chapter N to unlock". N is parsed from the chapter id until
    ChapterRegistry exists: **09-06 / 09-09 should switch it to the
    chapter's own number**.
  - Locked state is refreshed in `_refresh()`, so a new unlock shows
    without rebuilding.
- **Verified** (headless, 19/19): fresh save = only Ancient; ch1–4 each
  unlock exactly their tower, once; ch5 nothing; all survive a reload; a
  fake chest `unlock_tower("void_tower")` grants only Void and touches
  nothing else; the garage view/label behaviour; a real chapter-1 victory
  → "New tower unlocked: Frost Tower!" and Frost owned. Screenshots: the
  victory line; the real garage showing Frost with "Beat Chapter 1 to
  unlock".
- **Found**: `scenes/ui/tower_garage.tscn/.gd` (and the standalone
  `spell_codex.tscn` nav target) are an **older standalone copy** of the
  garage. The game uses `tower_garage_content.tscn` inside `world_map`
  (`world_map.gd:29`). The old one did **not** get these changes. Listed
  for 10-13 (dead code).
- **Test lesson**: the user plays while tests run, so tests must set
  `MetaManager._read_only = true` instead of backing up and restoring the
  real save.

**Placeholders**: any lock/price badge art → drawn stand-in, final
`garage/ui_tower_unlock_badge.png` (only if you want art there).
**Preview**: `tower_garage_content.tscn` placeholder cells include one locked,
one unlockable, and one owned cell, so all three states show in the editor.

**Acceptance criteria**:
- [x] Fresh save: only Ancient owned. Beating each tower's chapter unlocks
      exactly that tower, once; it stays owned after a restart and can be
      selected and played.
- [x] Calling the unlock from a (fake) chest grants a tower without touching
      chapter progress.

---

## Task 09-06 — Chapter Plumbing (arena per chapter, chapter registry) ✅ DONE (2026-09-29)

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Read**:
>   - `scenes/main/game_world.gd` (~lines 11–35: `pending_chapter_def`, the
>     `_spawn_tower()` fallback pattern).
>   - `scenes/main/game_world.tscn`, where the arena is instanced.
>   - `resources/chapters/chapter_definition.gd` (`arena_model_path` is dead).
>   - `scripts/resource_dir.gd` + `autoloads/tower_registry.gd` as the
>     registry pattern.
>   - `project.godot` `[autoload]` order.
>   - `scenes/manager/wave_manager.gd` `_get_wave_composition()`.
> - **Watch out**:
>   - Ask the user to **close `game_world.tscn` in the editor** before editing
>     it.
>   - A new autoload's `class_name` needs the editor's class cache. Prefer
>     `preload()` (`components.md` §7).

**Covers**: A3 (prerequisite) · **Files**: `resources/chapters/chapter_definition.gd`,
`scenes/main/game_world.tscn` / `.gd`, new `autoloads/chapter_registry.gd`

Today `game_world.tscn` hard-instances `chap1_arena.tscn`, and
`ChapterDefinition.arena_model_path` is a dead string.

- [x] Add `@export var arena_scene: PackedScene` and `@export var sort_order: int`
      to `ChapterDefinition`. `game_world.gd` instances the pending chapter's
      arena and falls back to the baked chap1 arena when run standalone (F6),
      the same way `pending_tower_def` already falls back. Leave
      `arena_model_path` for B10.
- [x] `ChapterRegistry` autoload: loads `resources/chapters/*.tres` via the
      shared `scripts/resource_dir.gd` (**do not copy the scan loop** —
      `TowerRegistry` already uses it) and sorts by `sort_order`. Same shape as
      `TowerRegistry`.
- [x] Document in `wave_manager.gd` and `components.md` that
      `_get_wave_composition()` treats `enemy_pool[1]` as the "fast" enemy.
      Every chapter's pool order must follow that rule.
- [x] Close `game_world.tscn` in the editor before editing it (rule 3).

**Placeholders**: none · **Preview**: none new (chapter 1 must look and play
identically).

**Acceptance criteria**:
- [x] Chapter 1 plays exactly as before, now reached through `arena_scene`.
- [x] `ChapterRegistry` lists chapter_01 and picks up a new `.tres` with no
      code change.

---

## Task 09-07 — Chapter 2 Content ✅ DONE (2026-10-03, user approved)

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Before starting (added 2026-09-29, end of the build session)**:
>   - 09-01 → 09-06 are ✅ DONE. Read their "Built" notes, because they
>     change how you build this task:
>     - Chapters: `ChapterRegistry` is `scripts/chapter_registry.gd`
>       (static, preload, NOT an autoload). A chapter needs `arena_scene` +
>       `sort_order` in its `.tres`; `game_world.gd._swap_arena()` loads it.
>     - Save is version 3 (`selected_tower_id`); adding a save field =
>       bump + `_migrate_N_to_N+1`.
>     - `game_world.gd._on_boss_died()` calls
>       `MetaManager.unlock_towers_for_chapter()`. Winning `chapter_02`
>       will unlock Void automatically.
>   - Tests: set `MetaManager._read_only = true` in every test script. The
>     user plays while tests run. Never back up and restore the real save.
>   - First, ask the user: the chap2 enemy roles (fast / flyer) and armor
>     (their animations were due 2026-09-30).
> - **Status (2026-09-28)**: Answered 2026-09-28: names (ch1 renamed "Ancient Ruins", ch2 "Frozen Wastes"), boss resist = Frost. **One item consciously left to build time**: each chap2 enemy's role (fast/flyer) and armor. Ask the user at the start of this task, once the chap2 animations exist.
> - **Copy from** `scenes/game_object/chap1/chap1_enemy_01–05/` and
>   `chap1_boss_01–02/` (`.tscn` + `.tres` each).
> - **Models**: `assets/models/chap2/*.glb`, with their own jpg/png textures
>   beside them.
> - **Watch out**:
>   - Each chap1 `.tscn` hand-authors `walk`/`attack` `Animation` sub-resources
>     whose tracks target the model node **by name**
>     (`"chap1_enemy_01:position"`). Rename these for chap2.
>   - Chap1 scenes also embed a `StandardMaterial3D` with
>     `chap1_enemy_0N_texture.png`. Check what chap2 needs.
> - **Check**: what `scenes/component/boss_heavy_attack_component.gd` does
>   when the model has no `attack_heavy` clip.
> - **Arena**: copy `scenes/game_object/chap1/chap1_arena/`. Colours via
>   `scenes/game_object/arena/arena.gd`.
> - **Apply**:
>   - 09-00.2: pools may mix enemies across chapters.
>   - 09-00.5: regular enemies get no resist; bosses may have one.

**Covers**: A3 · **Refs**: `restructure.md` §8–9 (copy-a-folder),
`epic_done/epic_06_art.md` 06-05 (arena colours)

Models: `assets/models/chap2/chap2_enemy_01–05.glb`, `chap2_boss_01–02.glb`.

- [x] `scenes/game_object/chap2/chap2_enemy_01..05/` and `chap2_boss_01..02/`:
      copy the matching chap1 folder, swap the model `ext_resource`, and
      re-point the hand-authored `walk`/`attack` animation tracks, which target
      the model node by name (`chap1_enemy_01:position` → `chap2_enemy_01:…`).
      If a chap2 `.glb` has its own clips, use those instead.
  - Bosses keep `BossHeavyAttackComponent`. Check it still works when the
    model has no `attack_heavy` clip; if not, it falls back to the scale-pulse
    telegraph.
  - Shared `enemy.gd`, not copied.
- [x] Co-located `.tres` per enemy. Stats start as the chap1 counterpart's
      values, tuned in 09-17. Order `enemy_pool` so index 1 is the fast
      enemy (09-06).
- [x] **Theme: Ice / Frost** (09-00.2): chapter name, arena colours (blues)
      and map art follow it.
- [x] **Names** ✅ answered (user, 2026-09-28):
  - Chapter 2 is **"Frozen Wastes"** (`chapter_02.tres` `chapter_name`).
  - Chapter 1 is renamed from "The Plains" to **"Ancient Ruins"**. That's a
    one-field edit in `resources/chapters/chapter_01.tres` (`chapter_name`),
    done in this task. The world map title reads it from the `.tres`, so no
    code changes.
- [x] **Armor & resist** (09-00.5): regular enemies get an armor type
      (Unarmored/Light/Medium/Heavy/Fortified) and **no** resisted school.
      Record the mix in 09-11's table.
  - **Each chap2 enemy's role and armor**: which model is the fast one
    (`enemy_pool[1]`), whether any is a flyer (`is_flying` + `hold_height`,
    like `chap1_enemy_05`), and each one's armor type.
    **Consciously left to build time** (user, 2026-09-28): "I will decide
    when I make the animation". Ask at the start of this task, once the
    chap2 animations exist. It's the only open item here, and nothing else
    in 09-07 waits on it except the enemy `.tres` values.
  - **Q1 fast enemy** ✅ answered (user, 2026-10-03): "as they are
    numbered", so **chap2 enemy 2** is the fast one, the same slot as
    chap1.
    - Consequence: `chapter_02.tres` `enemy_pool` is in number order
      (01, 02, 03, 04, 05), with `chap2_enemy_02` at index 1.
    - Consequence: chap2 enemy 2's `.tres` starts from chap1 enemy 2's
      fast stats.
  - **Q2 flyer** ✅ answered (user, 2026-10-03): **chap2 enemy 5 flies**
    (like chap1 enemy 5), and **chap2 enemy 3 also floats** above the
    ground.
    - Code check: `is_flying` only changes movement. In
      `move_to_target_component.gd` ~33–35 the enemy holds `hold_height`
      with a small sine bob. No spell or targeting code treats flyers
      differently (grep), so "float" and "fly" are the same setting.
    - Consequence: both `.tres` get `is_flying = true`. `hold_height`
      starts at chap1 enemy 5's 1.0 for both and is tuned in the lineup
      preview or a run (enemy 3's model is long and flat, 0.8 tall).
  - **Q3 armor per enemy** ✅ answered (user, 2026-10-03), then **revised
    the same day**:
    - The first answer was "same as chap1".
    - The user then didn't want three Light enemies in a row and changed
      it for **both chapters**:

      | Enemy | Armor (ch1 and ch2) | `armor_type` | Was in ch1 |
      |---|---|---|---|
      | Enemy 1 | **Medium** | 3 | Light |
      | Enemy 2 (fast) | Light | 2 | same |
      | Enemy 3 | Light | 2 | same |
      | Enemy 4 | Heavy | 1 | same |
      | Enemy 5 (flyer) | **Fortified** | 4 | Medium |
      | Boss 1 | Fortified | 4 | same |
      | Boss 2 | **Medium** | 3 | Fortified |

    - Consequence: three chap1 `.tres` change (`chap1_enemy_01`,
      `chap1_enemy_05`, `chap1_boss_02`). The docs that list chap1 armor
      (`project.md` v2 note, `mechanics.md` §5, see 09-02) and 09-11's
      table need the same update.
    - Also said: the regular enemies should **resist Frost**, "just like
      chap 1 is res to Nature".
    - ⚠ This conflicted with 09-00.5 / 09-11 ("resist is boss-only").
    - **Resolved** (user, 2026-10-03): the user asked how strong chap1's
      Nature resist is.
      - Code check: `Constants.SCHOOL_RESIST_MULT = 0.5`
        (`Constants.gd:156`), applied in `hurtbox_component.gd:18–19`. A
        resisted school does half damage and half status effect, and Void
        is never resisted.
      - User: "if it's 0.5 then yes add it to enemies of chap 2 as well".
      - So **regular enemies resist their chapter's school too** (option
        B). All 5 chap2 regulars and both bosses get
        `resisted_school = 1` (Frost). Chap1 keeps Nature (4) on all 7.
    - Consequence: this **replaces the "boss-only" part of 09-00.5 for
      regular enemies**. 09-11's "clear `resisted_school` on regular
      enemies" step no longer applies. The 09-11 note is updated, and
      `spells.md` §3 / §6.5 (written in 09-02 as boss-only) need the same
      fix.
  - **Bosses** (user, 2026-10-03): no animations on the chap2 bosses for
    now. The heavy attack uses the scale-pulse warning.
  - **Boss resist** ✅ answered (user, 2026-09-28): a boss resists **its
    chapter's school**. Both chap2 bosses get `resisted_school = 1`
    (Frost). The general rule and the chapter-3 Void case are in 09-11.
- [x] `wave_count`: same as chapter 1 for now (12 while building; 20 later,
      per 09-00.2 Q3).
- [x] Per-model `HealthBar3D.height_offset` set to that model's height.
- [x] `chap2_arena/chap2_arena.tscn`: copy `chap1_arena`, new `color_1–4`
      (e.g. blues, as `arena.gd` intends).
- [x] `resources/chapters/chapter_02.tres`: name, pools, `arena_scene`,
      `sort_order = 1`, `map_image`.

**Built (2026-10-03)**:
- Step 1 was the scene folders.
- The user asked for the chap2 folders first, so the animations can be
  made in them.
- `scenes/game_object/chap2/chap2_enemy_01–05/`, `chap2_boss_01–02/` and
  `chap2_arena/` exist, `.tscn` only.
- How they were made:
  - Each scene is generated from its chap1 counterpart: model swapped,
    node names and animation tracks renamed to chap2, and a new scene uid.
  - The chap2 `.glb`s have **no clips and no skeleton**. The enemies carry
    chap1's hand-made `walk`/`attack` as placeholders for the user to
    replace.
  - The bosses have no `AnimationPlayer`, same as chap1. Their heavy
    attack falls back to the scale-pulse warning.
  - If a hand-made boss `AnimationPlayer` is added without an
    `attack_heavy` clip, `anim.play("attack_heavy")` logs an error.
  - Dropped from the chap1 enemy_01 and enemy_02 copies: the editor-baked
    mesh + unshaded texture override. Chap2 uses each `.glb`'s own
    material, like chap1 enemy_03–05.
  - The bosses dropped chap1's Armature/Skeleton pose overrides.
  - Every model is normalised to ~1.91 m, so chap1's scales were kept.
    `chap2_enemy_03` is long and flat (0.8 tall); check it in the preview.
- Arena: blue `color_1–4`, tunable in the Inspector.
- Headless check: all 8 load, every model has its mesh, and 0 animation
  tracks point at a missing node.
- **Steps 1–7 built (2026-10-03), approved by the user**:
  1. chap1 armor: enemy_01 Medium, enemy_05 Fortified, boss_02 Medium.
  2. `chapter_01.tres` renamed "Ancient Ruins".
  3. 7 chap2 `.tres`: chap1 stats; Q3 armor; Frost resist on all 7;
     enemies 3 and 5 `is_flying`, `hold_height = 1.0`.
  4. `chapter_02.tres`: Frozen Wastes, pool in number order, 12 waves,
     `sort_order = 1`, blue arena, placeholder map image.
  5. `chap2_lineup_preview.tscn`:
     - Arena, camera at the runtime spot, the game's light.
     - Two rows so all 7 fit the portrait camera: 5 enemies in front,
       bosses behind. Flyers sit at 1.0.
  6. Docs: `project.md`, `mechanics.md` §5 and `spells.md` §3 / §6.5 got
     the new armor plus "every themed enemy resists its set's school".
     `ui_assets.md` lists `world_map/chapter_02_image.png`.
  7. Tests (`_read_only = true`, save never written):
     - Headless full ch2 run: 68/68 checks. Registry order, all armor and
       resist values, the blue arena swap.
     - The same run: all 5 types spawn, walk, attack and die. 3 and 5
       float at ~0.98; the others stay grounded.
     - A live Frost hit does exactly table ×0.5 on every type.
     - A boss spawns on wave 12. Victory unlocks Void, and Continue goes
       back to the map.
     - The defeat screen's Map button goes back to the map.
     - Ch1 still uses the green arena with the new armor and Nature resist.
     - Windowed run (2×): 0 fails. Screenshots of the lineup, a ch2 wave,
       a flyer, the boss wave, the victory screen ("New tower unlocked:
       Void Tower!"), the defeat screen and ch1.
     - "Target object freed… aborting Tweener" warnings show up in ch1 at
       the same rate. They're pre-existing, not from chap2.
- **Not verifiable by the tests**:
  - How the enemies look while moving (the user checks in the editor or
    a run).
  - Ch2 can't be picked from the world map yet: `world_map_content.gd`
    `CHAPTER_IDS` only has ch1. Picking a chapter comes with 09-09.
- **Changes after the build, at the user's request**:
  - chap2 enemy 2's walk is enemy 5's walk, with its scale keys
    × 0.32/0.45 so the squash keeps the same %. Its attack is unchanged.
  - chap2 enemy 5 is **20% bigger**; the user looked at 20% and kept it
    over 30%. Everything was scaled by 1.2:
    - model 0.45 → 0.54
    - the RESET / attack / walk scale keys
    - body and hurtbox collision
    - `HealthBar3D.height_offset` 0.9 → 1.08
  - Tested: headless (tracks OK) and windowed. In a live run it flies at
    ~1.1, and its scale matches the new keys.
  - No animations on the chap2 bosses for now (user). Their heavy attack
    uses the scale-pulse warning.
- **Look at**: the boss HP bars use chap1's `height_offset` (2.4 / 2.3)
  and sit fairly high above the chap2 bosses.

**Placeholders**: map image = `chapter_01_image_v2.png` → final
`world_map/chapter_02_image.png`. (Name picked: "Frozen Wastes".)

**Preview**: `scenes/game_object/chap2/chap2_lineup_preview.tscn`, an editor-only
scene with the arena, the camera rig and every chap2 enemy + boss standing in
a row. It shows scale, facing and HP-bar heights at a glance. It isn't meant
to be run.

**Acceptance criteria**:
- [x] A full chapter-2 run works: every enemy walks, attacks, dies; a boss
      appears on the final wave; victory and defeat both return to the map.
- [x] The lineup preview shows all 7 at believable relative sizes.

---

## Task 09-08 — Chapters 3+ Using Existing Models ✅ DONE (2026-10-06, user approved)

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Status (2026-09-28)**: Answered 2026-09-28: build **all chapters 3–10** as placeholders (5 regular + 2 bosses each), ch3–5 named "Void"/"Poison"/"Fire", ch6–10 "Chapter N" until named, mixed chapters draw from 2–3 themed sets. **One item left to build time**: exact enemy picks per chapter, asked together with 09-07's chap2 roles.
> - **Remember**: a chapter's `enemy_pool` can reference any existing enemy
>   `.tres` in any chapter folder, so only copy a folder when a variant is
>   needed.

**Covers**: A4 · **Based on**: 09-00.2 (about 10 chapters, open-ended;
enemies mixed across chapters; 20 waves target) and its theme table.

**Scope** ✅ answered (user, 2026-09-28, revised the same session): **build
ALL chapters 3–10 now as placeholders**, "so we have more things to see and
test". Their rosters **mix the existing Nature (chap1) and Frost (chap2)
enemies**, so extra chapters are ready to go when real models arrive.
- Superseded: an earlier answer the same session ("build only 3–5, leave
  6–10 until real content exists").
- Epic 09 therefore ships **10 chapters**, matching 09-00.2's "about 10 at
  launch".
- Chapters 3–5 still carry their school theme (tint + arena colours + boss
  resist). Chapters 6–10 are the "mixed" ones (09-00.2).
- Every chapter's roster is swapped to real models later, one `ext_resource`
  per enemy (rule 1). The model-borrow table below records what to swap.

**Names** ✅ answered (user, 2026-09-28): plain school-type placeholder names
("we will change when we have the models"):

| Chapter | Theme | `chapter_name` (placeholder) | Built from |
|---|---|---|---|
| 3 | Void | "Void" | reused chap1/chap2 enemies, Void tint + arena colours |
| 4 | Poison | "Poison" | reused, Poison tint + arena colours |
| 5 | Fire | "Fire" | reused, Fire tint + arena colours |
| 6–10 | mixed | "Chapter 6" … "Chapter 10" until named | chap1 + chap2 enemies mixed |

**Mixed chapters and names** ✅ answered (user, 2026-09-28): "when a chapter
is mixed it will use 2 or 3 types of enemies, and it will be named when we
get there".
- **Every chapter, themed or mixed, has the same shape as chapters 1 and
  2: 5 regular enemies + 2 bosses** (clarified by the user, 2026-09-28).
- **Themed sets**: each theme has its own set of enemies (Nature = chap1,
  Frost = chap2, and Void / Poison / Fire = the tinted placeholder sets
  built for chapters 3 / 4 / 5 from the chap1 and chap2 models).
- A **mixed** chapter (6–10) takes its 5 + 2 from **2 or 3 of those themed
  sets** ("the void enemies, nature enemies, frost enemies"). Mixed
  chapters reference the existing themed `.tres`/scenes and need no new
  variants.
- Themed placeholder chapters 3–5 mix chap1 + chap2 models, tinted to
  their school, because those are the only models that exist.
- **Names of chapters 6–10 are consciously deferred** until their real
  content exists. For the build, `chapter_name` = "Chapter 6" … "Chapter 10"
  as a placeholder, which is enough for the carousel.
- **Exact enemy picks per chapter** (which models make up the Void / Poison /
  Fire sets, and which themed sets and enemies each mixed chapter uses) are
  decided at the start of this task, **together with
  09-07's chap2 roles/armor**. That's the same moment, because the chap2
  enemies need roles before anyone can pick from them. It's the only open
  item left in 09-08. Constraint: `pool[1]` = a fast enemy.
  - **Q1 Void set (ch3)** ✅ answered (user, 2026-10-06): **all chap1
    models**, enemies 1–5 plus both chap1 bosses, **tinted purple**. (The
    user first noted "we don't have the enemies for chap 3 for now", then
    confirmed option a: keep the 2026-09-28 placeholder plan and borrow
    models.)
    - Consequence: the ch3 `enemy_pool` is in number order (chap1 enemy
      1–5), so `pool[1]` = the chap1 enemy 2 model, the fast one. Rule met.
    - Consequence: the flyer is the chap1 enemy 5 model (`is_flying`,
      `hold_height = 1.0`, same as chap1).
    - Consequence: armor is the same as chap1 (09-07 Q3 table): Medium,
      Light, Light, Heavy, Fortified, with bosses Fortified and Medium.
    - Consequence: every Void-set enemy has **no resist** (`resisted_school
      = -1`; nothing resists Void).
  - **Q2 Poison set (ch4)** ✅ answered (user, 2026-10-06): **all chap1
    models again**, the same picks as Void (enemies 1–5 plus both chap1
    bosses), **tinted green**.
    - Consequence: the same pool order as Void, so `pool[1]` = the chap1
      enemy 2 model (fast). The flyer is the chap1 enemy 5 model. Armor is
      the same as chap1.
    - Consequence: every Poison-set enemy resists **Poison**
      (`resisted_school = 3`).
    - Consequence: Void and Poison differ only in tint + resist. The chap1
      models are now borrowed by Nature (original), Void and Poison.
  - **Q3 Fire set (ch5)** ✅ answered (user, 2026-10-06): **all chap1
    models again**, the same picks as Void and Poison, **tinted orange**.
    - Consequence: the same pool order, so `pool[1]` = the chap1 enemy 2
      model (fast). The flyer is the chap1 enemy 5 model. Armor is the
      same as chap1.
    - Consequence: every Fire-set enemy resists **Fire**
      (`resisted_school = 0`).
    - Consequence: all three placeholder sets (Void / Poison / Fire) borrow
      the 7 chap1 models. The chap2 models are used only by Frost.
  - **Q4 Chapter 6** ✅ answered (user, 2026-10-06): **Nature + Frost**,
    option a as offered:
    - `enemy_pool` = Nature enemy 1, **Frost enemy 2**, Nature enemy 3,
      Frost enemy 4, Nature enemy 5. `boss_pool` = Nature boss 1, Frost
      boss 2.
    - Consequence: it reuses the existing chap1/chap2 `.tres` as they are,
      with no new files. `pool[1]` = Frost enemy 2 (fast). The flyer is
      Nature enemy 5.
    - Consequence: resists stay with their set (rule from 09-11). The
      Nature ones resist Nature and the Frost ones resist Frost, so no
      single school is resisted by the whole chapter.
  - **Q5 Chapter 7** ✅ answered (user, 2026-10-06): **Frost + Void**,
    option a as offered:
    - `enemy_pool` = Void enemy 1, **Frost enemy 2**, Void enemy 3, Frost
      enemy 4, Void enemy 5. `boss_pool` = Void boss 1, Frost boss 2.
    - Consequence: `pool[1]` = Frost enemy 2 (fast). The flyer is Void
      enemy 5 (the chap1 enemy 5 model, purple).
    - Consequence: it reuses the Void-set `.tres` built for ch3 plus the
      existing chap2 `.tres`. No extra files beyond the Void set.
    - Consequence: the Void ones resist nothing and the Frost ones resist
      Frost.
  - **Q6 Chapter 8** ✅ answered (user, 2026-10-06): **Void + Poison**,
    option a as offered:
    - `enemy_pool` = Poison enemy 1, **Void enemy 2**, Poison enemy 3, Void
      enemy 4, Poison enemy 5. `boss_pool` = Poison boss 1, Void boss 2.
    - Consequence: `pool[1]` = Void enemy 2 (fast, the chap1 enemy 2
      model). The flyer is Poison enemy 5.
    - Consequence: both sets borrow chap1 models, so this chapter is all
      chap1 shapes in purple and green.
    - Consequence: the Void ones resist nothing and the Poison ones resist
      Poison.
  - **Q7 Chapter 9** ✅ answered (user, 2026-10-06): **Poison + Fire**,
    option a as offered:
    - `enemy_pool` = Fire enemy 1, **Poison enemy 2**, Fire enemy 3, Poison
      enemy 4, Fire enemy 5. `boss_pool` = Fire boss 1, Poison boss 2.
    - Consequence: `pool[1]` = Poison enemy 2 (fast). The flyer is Fire
      enemy 5.
    - Consequence: all chap1 shapes, in green and orange.
    - Consequence: the Fire ones resist Fire and the Poison ones resist
      Poison.
  - **Q8 Chapter 10** ✅ answered (user, 2026-10-06): **Fire + Nature**,
    option a as offered:
    - `enemy_pool` = Nature enemy 1, **Fire enemy 2**, Nature enemy 3, Fire
      enemy 4, Nature enemy 5. `boss_pool` = Nature boss 1, Fire boss 2.
    - Consequence: `pool[1]` = Fire enemy 2 (fast). The flyer is Nature
      enemy 5.
    - Consequence: all chap1 shapes, untinted and orange.
    - Consequence: the Nature ones resist Nature and the Fire ones resist
      Fire.
  - **Roster summary** (all 8 answered 2026-10-06). E = regular enemy,
    B = boss; the number is the slot within its set:

    | Ch | Sets | E1 | E2 (fast) | E3 | E4 | E5 (flyer) | B1 | B2 |
    |---|---|---|---|---|---|---|---|---|
    | 3 | Void | Void 1 | Void 2 | Void 3 | Void 4 | Void 5 | Void B1 | Void B2 |
    | 4 | Poison | Poison 1 | Poison 2 | Poison 3 | Poison 4 | Poison 5 | Poison B1 | Poison B2 |
    | 5 | Fire | Fire 1 | Fire 2 | Fire 3 | Fire 4 | Fire 5 | Fire B1 | Fire B2 |
    | 6 | Nature + Frost | Nature 1 | Frost 2 | Nature 3 | Frost 4 | Nature 5 | Nature B1 | Frost B2 |
    | 7 | Frost + Void | Void 1 | Frost 2 | Void 3 | Frost 4 | Void 5 | Void B1 | Frost B2 |
    | 8 | Void + Poison | Poison 1 | Void 2 | Poison 3 | Void 4 | Poison 5 | Poison B1 | Void B2 |
    | 9 | Poison + Fire | Fire 1 | Poison 2 | Fire 3 | Poison 4 | Fire 5 | Fire B1 | Poison B2 |
    | 10 | Fire + Nature | Nature 1 | Fire 2 | Nature 3 | Fire 4 | Nature 5 | Nature B1 | Fire B2 |

  - **Model-borrow table** (the swap list for real models). Every
    placeholder set borrows the chap1 model in the same slot:

    | Set | Slot | Borrows | Final model to make |
    |---|---|---|---|
    | Void (ch3) | enemy 1–5, boss 1–2 | `chap1_enemy_01–05.glb`, `chap1_boss_01–02.glb`, purple tint | `assets/models/chap3/chap3_enemy_01–05.glb`, `chap3_boss_01–02.glb` |
    | Poison (ch4) | enemy 1–5, boss 1–2 | same chap1 models, green tint | `assets/models/chap4/…` |
    | Fire (ch5) | enemy 1–5, boss 1–2 | same chap1 models, orange tint | `assets/models/chap5/…` |
    | Ch6–10 | — | nothing of their own; they list the themed sets' `.tres` | none (they follow their sets) |
  - **Build decisions** ✅ answered (user, 2026-10-06), resolving the three
    "Open" points below:
    - **A: yes.** Each placeholder set gets its own 7 `.tres` (21 total),
      with chap1 stats/armor, its own resist (Void -1, Poison 3, Fire 0)
      and its own tint.
    - **B1.** The tint lives on the `.tres`: a new
      `EnemyDefinition.model_tint`, the same idea as
      `TowerDefinition.model_tint`, applied by `enemy.gd` via
      `scripts/model_tint.gd`. The 21 `.tres` point at the **existing chap1
      scenes**, so there are no variant scenes. The real-model swap later =
      the `.tres` `scene` line + clearing the tint. (This replaces the
      "variant scene" wording in the first checkbox below.)
    - **C: leave it.** Per-chapter rewards stay in 09-12. 09-08 doesn't
      touch rewards.
    - Tint vs flash gets fixed in this task with a shared overlay-stacking
      helper (`next_pass`). Towers use the same helper but don't flash
      (see the correction below).
  - **Tint colours** ✅ answered (user, 2026-10-06), all at 45% strength
    (alpha 0.45, the same as the Poison/Fire towers). 0% = the original
    model, 100% = a flat silhouette:
    - Void: purple `Color(0.6, 0.2, 0.9, 0.45)` (new, there's no Void
      tower tint)
    - Poison: green `Color(0.35, 0.9, 0.3, 0.45)`, the same as
      `tower_poison_tower.tres`
    - Fire: orange `Color(1, 0.45, 0.1, 0.45)`, the same as
      `tower_fire_tower.tres`
    - Note: chap1 enemy 1 is already purple, so the Void tint barely shows
      on it.
  - **Open (raised 2026-10-06, now decided above)**:
    - Because of the 09-07 resist rule (every themed enemy resists its
      set's school), each themed set needs its **own `.tres` per enemy**,
      bosses AND regulars, since the resist lives on the `.tres`. Reusing
      chap1's `.tres` would carry chap1's Nature resist into the Void set.
      That would be 7 `.tres` × 3 sets (Void / Poison / Fire).
    - Tint vs hit flash: both use the one `material_overlay` slot per mesh
      (`hit_flash_component.gd:33`, `model_tint.gd:25`). Whichever runs
      last wins, so a tinted enemy would lose either its tint or its
      flash.
      - **Correction (2026-10-06, found while testing)**: the earlier
        claim that this "is already live on the Poison/Fire towers" was
        wrong. `tower.tscn:27` has `HitFlashComponent.enabled = false`, so
        no tower flashes at all (by design). The clash only matters for
        enemies.
    - 09-12 (reward multipliers) isn't built, so "rewards per chapter via
      09-12" has no field to set yet.

(Chapter 1 is "Ancient Ruins" and chapter 2 is "Frozen Wastes"; see 09-07.)

- [x] **Chapters 3–5 (themed)**: ~~a variant scene per enemy~~ built as
      B1 (see "Build decisions"): each themed enemy is a `.tres` pointing at
      the chap1 scene in the same slot, with its own `model_tint` +
      `resisted_school`. Tint vs hit flash fixed via `next_pass`.
- [x] **Chapters 6–10 (mixed)**: `enemy_pool` / `boss_pool` list existing
      `.tres` from the themed sets. No new scenes. `enemy_pool[1]` = a fast
      enemy in every chapter.
- [x] Armor per chapter = the chap1 table (every set borrows chap1 stats).
      Resists: Void -1, Poison 3, Fire 0, on bosses AND regulars (09-07
      rule). Mixed chapters reuse the sets unchanged.
- [ ] ~~Rewards per chapter via 09-12's multipliers.~~ **Left to 09-12**
      (user, 2026-10-06, decision C). 09-08 doesn't touch rewards.
- [x] Each chapter gets `chapter_0N.tres`, an arena copy with its own colours,
      and a lineup preview. More chapters later = more `.tres` + arenas, no
      code.
- [x] Keep a table in this task: which chapter/enemy borrows which model
      (the "Model-borrow table" above).

**Built (2026-10-06)**:
1. **Tint + hit flash**:
   - `scripts/model_tint.gd` has a new `add_overlay(mesh, mat, on_top)`.
     When a mesh already has a `material_overlay`, it chains the two with
     `next_pass` instead of replacing it. A per-mesh copy carries the
     `next_pass`, and the flash material is never copied (its tween keeps
     working).
   - `hit_flash_component.gd` adds its flash with `on_top = true`.
   - New `EnemyDefinition.model_tint` (alpha 0 = none). `enemy.gd._ready()`
     applies it once (not in `reset()`, which would stack a second layer).
   - Towers: `tower.tscn` has `HitFlashComponent.enabled = false`, so no
     tower flashes (by design, unchanged). Their tint now goes through the
     same helper.
2. **21 `.tres`**: `scenes/game_object/chap3|4|5/chapN_enemy_01–05/` and
   `chapN_boss_01–02/`.
   - Generated from the chap1 `.tres`: same stats, armor and flyer. Own
     `enemy_id`, resist and tint (the colours above). `scene` = the chap1
     scene.
   - A comment at the top of each says how to swap in the real model.
   - The folders are where the real `chapN_*.tscn` goes later.
3. **8 arenas**: `chap3_arena` … `chap10_arena`, copies of `chap2_arena`
   with their own `color_1–4`: ch3 purple, ch4 muted dark green, ch5
   orange, ch6 sand, ch7 slate, ch8 mauve, ch9 rust, ch10 stone. Tunable in
   the Inspector.
4. **8 chapters**: `resources/chapters/chapter_03–10.tres`.
   - Names "Void", "Poison", "Fire", "Chapter 6" … "Chapter 10".
   - Pools per the roster table, 12 waves, `sort_order` 2–9, own arena,
     map image = `chapter_01_image_v2.png` (placeholder).
   - `ui_assets.md` → STILL TO MAKE lists the `chapter_03–10` map images and
     the chap3/4/5 models.
5. **Lineup previews**:
   - One shared `@tool` base:
     `scenes/game_object/chapter_lineup/chapter_lineup_preview.tscn` + `.gd`.
     It has the chap2 preview's camera and light, and builds the arena +
     5 enemies in front + 2 bosses behind from its `chapter` export.
   - Grounded enemies rest on their body sphere and flyers sit at
     `hold_height`. The tint is applied in the editor. Built nodes have no
     owner, so they're never saved.
   - `chapN_lineup_preview.tscn` (ch3–10) inherit it and set `chapter`.
   - The user checked ch3 in the editor: "all looks good".
   - `chap2_lineup_preview.tscn` is unchanged (hand-placed). The shared
     builder reproduces its positions within 2 cm.
6. **Tests** (`_read_only = true`, the save is never written):
   - Headless: overlay chain 6/6, the 21 `.tres` 357/357, chapters 175/175,
     previews 121/121.
   - Full run per chapter 3–10 (570 checks, 0 fails):
     - The arena swaps, and wave 1 only uses the pool.
     - All 7 types walk and attack. Flyers are at ~1.0; the rest stay
       grounded.
     - Tint + flash are on.
     - A hit from each of the 5 schools = the armor table, ×0.5 for the
       set's school.
     - All die.
     - Wave 12 spawns one pool boss, and its kill shows the victory
       screen. Ch3 unlocks Poison and ch4 unlocks Fire.
   - Windowed runs ch3/5/7 (216 checks, 0 fails) + screenshots of waves,
     the boss wave and victory.
   - The test spawns all 7 types (bosses too) around the tower at once,
     to check every type quickly. That's test-only: real waves 1–11 use
     only `enemy_pool`, and wave 12 is one boss.
- **Bug found and fixed (pre-existing, also ch1; fixed 2026-10-06 at the
  user's request)**:
  - Problem: the boss's XP could level the player up, and the level-up
    draft then opened *after* the victory screen. `enemy.gd._on_died()`
    emits `enemy_died` (→ victory) before `xp_gained` (→ level-up →
    `open_draft`). The draft sat behind the victory panel, and
    `GameState.phase` ended as DRAFT instead of VICTORY.
  - Fix: `draft_manager.gd open_draft()` returns early when the phase is
    VICTORY or DEFEAT. That's one guard, and it also covers XP arriving
    after the tower dies. The XP itself still counts.
  - The next run is unaffected: `GameState.start_run()` sets the phase to
    WAVE before the first-spell draft.
  - Tested:
    - Full runs of ch1–10: the phase stays VICTORY, with no DRAFT after
      it.
    - The boss XP still levels up.
    - A fresh run still opens its first-spell draft.
    - The windowed ch3 victory screenshot has no draft card behind it.
- **Not verified by the tests**: how the enemies look while moving in a
  real run, and the Return to Map button on ch3–10 (the same code as ch2,
  tested in 09-07). Ch3–10 can't be picked on the world map until 09-09.
- **Look at**: ch3 (purple on purple) and ch5 (orange on orange) enemies
  blend into the ground more than the others. A ground colour tweak fixes
  it if wanted.

**Placeholders**: borrowed `.glb` per enemy → final
`assets/models/chap<N>/chap<N>_enemy_0M.glb` / `_boss_0M.glb`; map image →
`world_map/chapter_0N_image.png`.
**Preview**: `chap<N>_lineup_preview.tscn` per chapter (ch3–10), built by
`chapter_lineup/chapter_lineup_preview.tscn`.

**Acceptance criteria**:
- [x] Every launch chapter is fully playable, and swapping any single enemy to
      a real model is one change in one file (the `.tres` `scene` line, plus
      clearing `model_tint`).

---

## Task 09-09 — Chapter Select Carousel ✅ DONE (2026-10-06, user approved)

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Read**:
>   - `scenes/ui/world_map_content.gd` (`CHAPTER_IDS` hardcoded,
>     `_current_index`, `_on_play_pressed`) and `world_map_content.tscn`.
>   - `scenes/ui/widget/chapter_node/chapter_node.gd` (`locked`
>     export).
>   - `scenes/ui/widget/play_button/play_button.gd`.
>   - `scenes/ui/world_map.gd`, the shell that calls `_refresh()`.
> - **Draw the arrows** the way `scenes/ui/widget/pause_button/pause_button.gd`
>   draws its glyph.

**Covers**: A5 · **Files**: `scenes/ui/world_map_content.tscn` / `.gd`,
`scenes/ui/widget/chapter_node/`

`world_map_content.gd` has `CHAPTER_IDS = ["chapter_01"]` hardcoded and a
`_current_index` nothing moves.

- [x] Replace `CHAPTER_IDS` with `ChapterRegistry` (09-06).
- [x] Left/right arrows + horizontal swipe on the chapter art move
      `_current_index`. The title, art and Play button follow it. Remember the
      last viewed chapter (per-viewer convenience, can live in `SaveData` with
      a migration).
  - **Q2 remember across restarts** ✅ answered (user, 2026-10-06):
    **option a**, saved in the save file.
    - Consequence: a new `SaveData` field for the last viewed chapter.
      `Constants.SAVE_VERSION` goes 3 → 4, with a
      `MetaManager._migrate_3_to_4()` that defaults it to chapter 1.
    - Consequence: store the chapter's **id** (e.g. `"chapter_03"`), not
      its position, so adding or reordering chapters never points it at
      the wrong one. An unknown id falls back to chapter 1.
    - Consequence: **09-10's save bump becomes 4 → 5** (its
      `cleared_chapters` field), not 3 → 4.
    - Consequence: your real save upgrades itself to v4 the first time you
      launch the updated game. Tests stay read-only and check the
      migration in memory, never on the real file.
    - **Follow-up: when to save, and the energy clock** ✅ answered (user,
      2026-10-06: "do what is recommended and how it's done in Archero").
      - Found: `MetaManager.save()` set `last_energy_timestamp = now` on
        **every** save. Offline regen (+1 per 20 min, applied only on
        launch) counts from that timestamp, so every save (Play,
        upgrades, tower pick) threw away partial progress, and time spent
        with the game open never counted. Saving on every chapter change
        would have made that worse.
      - Chosen: **save on every chapter change, and fix the clock**, the
        Archero way (its energy clock runs in real time and no action
        resets it). `save()` no longer touches the timestamp. It only
        moves when energy actually comes back (forward by exactly the time
        used, so partial progress is kept) or when spending from full
        starts the clock.
      - Not in this task: energy refilling live while the game is open,
        plus the countdown, which is **10-07** (noted there). This fix is
        the groundwork 10-07 builds on.
  - **Q3 ends of the list** ✅ answered (user, 2026-10-06): **stop at the
    ends**, no wrap-around.
    - Consequence: the left arrow is hidden on the first chapter and the
      right arrow on the last. Swiping past either end does nothing.
    - Consequence: "first" and "last" come from `ChapterRegistry`, so a
      chapter 11 added later just becomes the new end, with no code
      change.
  - **Q4 change animation** ✅ answered (user, 2026-10-06): **slide**. The
    old picture slides out and the new one slides in from the side you
    moved towards (~0.25 s), with the title following.
    - Consequence: the screen holds two chapter pictures during a slide,
      clipped so nothing shows outside the picture's band. Arrows and
      swipes are ignored mid-slide, the same as the NavBar's own slide
      guard.
- [x] Locked chapters use the existing `chapter_node.locked` and
      `ui_locked_overlay.png`. Play is disabled on them and shows the unlock
      condition (09-10).
  - **Q1 locks before 09-10** ✅ answered (user, 2026-10-06): **option a**,
    "if you change it later in the next task". All 10 chapters are playable
    from the carousel for now.
    - Consequence: 09-09 builds the lock **display** (overlay, disabled
      Play, unlock-condition text) and reads "is this chapter locked?" from
      one place, which returns "open" for every chapter until 09-10.
    - Consequence: **09-10 must switch the locks on**. Its
      `ChapterRegistry.is_unlocked(id)` replaces that one place, with no
      carousel change. (Added to 09-10 as a checkbox.)
- [x] Arrow buttons are a small `@tool` widget (`widget/carousel_arrow/`),
      tuned in its own scene.

**Built (2026-10-06)**:
1. **Arrow widget + shared panel base**:
   - `scenes/ui/widget/panel_button_base.gd` holds the rounded panel (colour,
     corners, outline, darker when pressed), moved out of `pause_button.gd`.
     It's the same pattern as `pill_base.gd`, with the subclass overriding
     `_apply_glyph()`.
   - `pause_button.gd` now extends it and keeps only its two bars. Checked:
     its panel, bars, positions and exports are identical before and after,
     so `game_world.tscn` needed no edit.
   - New `scenes/ui/widget/carousel_arrow/` (`.tscn` + `.gd`): extends the
     base, with a chevron drawn on an internal child. Knobs: `direction`,
     `glyph_size`, `glyph_thickness`. A 110×110 circle by default.
2. **Save v4 + energy clock**:
   - `SaveData.last_chapter_id` (default `"chapter_01"`), `SAVE_VERSION` 4,
     `MetaManager._migrate_3_to_4()` and `select_chapter(id)`, which saves.
   - Energy clock fix (see the follow-up under Q2): `save()` no longer
     touches `last_energy_timestamp`.
     - Offline regen advances it by exactly the intervals used, or sets it
       to now when the bar is full.
     - `spend_energy()` from full starts it.
   - The user's real save was upgraded once to v4 by the first launch of
     the new code (MetaManager loads before a test can go read-only). The
     user wasn't running Godot. The diff: only `save_version` and the new
     `last_chapter_id` changed; energy and the timestamp are identical.
3. **Carousel** (`world_map_content.tscn` / `.gd`):
   - `ChapterRegistry.all()` replaces `CHAPTER_IDS`. The screen opens on
     `MetaManager.last_chapter_id` (an unknown id → chapter 1).
   - `LeftArrow` / `RightArrow` are hidden at the ends, with no wrap.
   - The picture sits in a clipped `Carousel` band (full width, the
     picture's height), which reads the swipe: ≥ 80 px and more horizontal
     than vertical. Dragging left = next.
   - The slide is 0.25 s: the incoming picture (a runtime `chapter_node`)
     comes from the side moved towards and the old one is freed afterwards.
     Arrows, swipes and Play are ignored mid-slide.
   - Every change saves via `select_chapter()`.
   - Play starts the chapter on screen with the selected tower (unchanged).
   - Locks: `_is_locked()` is the one check and returns false for every
     chapter until 09-10 (Q1). Locked = lock overlay + greyed, disabled Play
     + `LockedLabel` "Beat Chapter N to unlock" (N = the chapter before).
   - "Beat Chapter N to unlock" moved into
     `ChapterRegistry.beat_to_unlock_text()`. The garage's `_unlock_text()`
     uses it, so the text isn't written twice.
   - `play_button.gd` got a `disabled_tint` knob (default grey 0.5),
     applied on redraw, because the art has no disabled variant and a
     disabled Play looked enabled.
4. **Preview**:
   - `world_map_content.tscn` shows both arrows in the editor
     (`carousel_arrow` is `@tool`), and `carousel_arrow.tscn` previews on its
     own.
   - New editor-only `chapter_node.preview_locked` knob shows the lock
     overlay without touching the runtime `locked` (tested: ignored at
     runtime).
   - `LockedLabel` is a real node with placeholder text, hidden by default.
     Show it with its eye icon to preview the locked screen, like
     `OutOfEnergyLabel`.
   - `ui_assets.md` lists the optional `world_map/ui_carousel_arrow.png`.
5. **Tests** (`_read_only = true`; the real save's mtime was unchanged
   after the tests):
   - Carousel, headless, 64/64:
     - Opens on the saved chapter, and an unknown id → chapter 1.
     - The right arrow visits all 10 in order, saving each and leaving one
       picture after each slide. No wrap at either end, and the arrows hide
       at the ends.
     - Input mid-slide is ignored.
     - Swipes: left = next and right = previous; a short (50 px) or
       vertical drag does nothing.
     - All chapters are open.
     - Forced lock (a test-only subclass locking ch3+): Play is disabled and
       greyed, the text reads "Beat Chapter 2 to unlock", the overlay shows,
       Play does nothing, and ch2 is normal again.
     - The garage text is unchanged.
     - Play → `pending_chapter_def` = ch5, 1 energy spent, the selected
       tower kept.
   - Save/energy 12/12. Pause button identical. Knob 3/3.
   - Windowed: ch1, mid-slide, ch10 (right arrow hidden) and forced-locked
     Void (overlay, text, grey Play).
- **Not verified by the tests**:
  - A real write → restart → reopen round-trip of `last_chapter_id`. The
    tests can't write the real save; the load path is the same one the v4
    migration used.
  - How the swipe feels on a phone.
  - The arrows inside the editor (Godot wasn't open). Open
    `world_map_content.tscn` to check.

**Placeholders**: arrows drawn in code (like `pause_button`) → final
`world_map/ui_carousel_arrow.png` (optional).
**Preview**: `world_map_content.tscn` shows the arrows. A `@tool`
`preview_locked` knob on `chapter_node` shows the locked look in the editor.
`carousel_arrow.tscn` previews on its own.

**Acceptance criteria**:
- [x] Every chapter from `ChapterRegistry` can be reached. Play starts the
      chapter on screen; locked ones can't be started.

---

## Task 09-10 — Chapter Progression & Locks ✅ DONE (2026-10-06, user approved)

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Read**:
>   - `scenes/ui/victory_screen.gd` and `scenes/main/game_world.gd`
>     (`_on_boss_died`).
>   - `scripts/save_data.gd` + `autoloads/meta_manager.gd`.
>   - `ChapterRegistry` (built in 09-06; check that it exists).
> - **Remember**: bump `SAVE_VERSION` + add a migration (09-01).

**Covers**: A6 · **Files**: `SaveData`, `MetaManager`, `victory_screen.gd`,
`ChapterDefinition`

- [x] `SaveData.cleared_chapters: Array[String]` (+ `SAVE_VERSION` bump and
      migration). `MetaManager.mark_chapter_cleared(id)` is called on victory.
  - Save bump is **v4 → v5** (09-09 already used v4 for `last_chapter_id`).
  - **Q1 existing saves** ✅ answered (user, 2026-10-06): start **empty**.
    No guessing past wins from owned towers ("my current save clear it,
    idc"). Only some chapters have towers, so that guess wouldn't work in
    general anyway.
    - Consequence: `_migrate_4_to_5()` sets `cleared_chapters = []`. After
      the upgrade only chapter 1 is open; beating it again opens chapter 2.
      Owned towers, materials, stars and ranks stay as they are.
    - Consequence: from now on every boss kill records its chapter, for
      all chapters (not just the ones with towers).
  - **Q2 after a first clear** ✅ answered (user, 2026-10-06: "do what
    Archero does"): the map opens on the **newly unlocked chapter**. Win
    ch1 → Continue → the map shows ch2.
    - Consequence: `mark_chapter_cleared()` also sets `last_chapter_id` to
      the next chapter, but only on a first clear that opened one. A replay,
      or clearing the last chapter, leaves it alone.
  - **Q3 saved chapter is locked** (e.g. after the v5 upgrade your save
    points at ch10, which will be locked): following the same Archero
    answer, the map opens on the **furthest open chapter** instead. ✅
    Approved with the plan (user, 2026-10-06).
  - Plan also approved (user, 2026-10-06): `save()` / `load()` take an
    optional path (default = the real save), so the "survives a restart"
    test round-trips a **temp file** and never the user's save.
- [x] `ChapterRegistry.is_unlocked(id)`: the first chapter is always open;
      chapter N+1 opens when N is cleared. The rule lives in one place.
- [x] **Switch the carousel's locks on** (from 09-09 Q1, 2026-10-06): 09-09
      ships with every chapter open. Point its single "is locked" check at
      `is_unlocked()` so locked chapters show the overlay and can't be
      played.
- [x] Victory screen shows "Chapter N+1 unlocked!" the first time only.
- [x] The first clear of a chapter also unlocks its tower (09-05's
      `unlock_chapter_id`). One hook: `mark_chapter_cleared` → tower
      unlocks. The victory screen shows both lines.
- [x] Buying a tower from a chest never marks a chapter cleared.

**Built (2026-10-06)**:
1. **Save v5**:
   - `SaveData.cleared_chapters`, `SAVE_VERSION` 5, and
     `MetaManager._migrate_4_to_5()` (empty, Q1).
   - `load(path = SAVE_PATH)` remembers its path and every `save()` writes
     there. The game always uses the real save; tests `load()` a temp file
     for a true save → reload round-trip.
   - Loading uses `CACHE_MODE_IGNORE`, so a reload reads the file, not a
     cached copy.
   - The fresh-save branch also resets gems, selected tower, last chapter
     and progress.
2. **One hook**: `MetaManager.mark_chapter_cleared(id)`. The first clear
   records the chapter, unlocks its towers (`unlock_towers_for_chapter`,
   moved out of `game_world.gd`), points `last_chapter_id` at the opened
   chapter (Q2), and returns `{chapter_id, tower_ids}`. A replay returns
   nothing and changes nothing.
   - `unlock_tower()` (the future chest path) never touches progress.
3. **One rule**: `ChapterRegistry.is_unlocked(id)`. The first chapter is
   always open; N+1 opens once N is in `cleared_chapters`. Plus
   `next_of(id)`.
4. **Victory**:
   - `game_world._on_boss_died()` calls `mark_chapter_cleared()`.
   - `victory_screen.gd` shows "Chapter N unlocked!" above the tower line.
     Both lines show only on a first clear, and there's no chapter line
     after the last chapter.
   - The editor placeholder shows both lines.
5. **Carousel locks on**: `world_map_content._is_locked()` =
   `not ChapterRegistry.is_unlocked()`.
   - A locked saved chapter opens on `_furthest_open_index()` (Q3). It's
     computed with the screen's own `_is_locked()`, so the screen has one
     lock check.
   - Locked chapters can still be browsed and show the overlay, a greyed
     Play and "Beat Chapter N to unlock".
6. **The user's real save**: upgraded once to v5 by the first launch of the
   new code (the user wasn't playing). The diff: only `save_version` 4 → 5
   and the new empty `cleared_chapters`. Towers, materials and energy are
   unchanged. Since it points at ch10 (locked), the map now opens on ch1.
7. **Tests** (the real save's mtime was unchanged after the upgrade):
   - Progression, headless, on a temp save (29/29):
     - A fresh save has only ch1 open.
     - Clearing ch1 opens ch2, unlocks Frost and moves the map to ch2.
     - A replay gives nothing new and doesn't move the map.
     - A chest tower doesn't clear a chapter.
     - Restart round-trip on the temp file: cleared ch1, the towers, the
       last chapter and ch2 open all survive, and the file is v5.
     - Clearing ch10 opens nothing.
     - Carousel: saved ch10 → opens ch1. A fresh ch2 is locked ("Beat
       Chapter 1 to unlock", overlay); after a ch1 win the map opens on
       open ch2; ch3 is still locked and Play does nothing.
     - Victory lines: both shown, and hidden on a replay.
   - Windowed full flow (7/7): ch1 boss kill → the victory screen shows
     both lines → Continue → the map is on Frozen Wastes and playable →
     ch3 (Void) is locked. Screenshots taken.
   - Regressions: carousel 65/65 (updated for the locks and the Q3 jump),
     save 12/12, full runs of ch1–10 all pass.

**Placeholders**: none (text).
**Preview**: `victory_screen.tscn` shows the unlock line in the editor
(placeholder text, hidden at runtime unless it applies).

**Acceptance criteria**:
- [x] Fresh save: only chapter 1 playable. Beating it unlocks 2, and that
      survives a restart.

---

## Task 09-11 — Resistances: WC3 Table for Everyone, Resist for Bosses Only

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Status (2026-09-28)**: ✅ All answered (2026-09-28): the boss-resist table is in this task. A boss resists its themed set's school, Void bosses none, and mixed chapters reuse them unchanged.
> - **Exact code** (line numbers as of 2026-09-27, re-grep `resisted_school` /
>   `SCHOOL_RESIST_MULT` first):
>   - `resources/enemies/enemy_definition.gd:14`
>   - `scenes/component/hurtbox_component.gd:8–19`
>   - `scenes/game_object/enemy/enemy.gd:51`
>   - `autoloads/Constants.gd:153`
>   - `scripts/combat_utils.gd:10` and `:233`
> - **Data**: chap1 regular enemies `chap1_enemy_01–05.tres` all have
>   `resisted_school = 4` → clear them. Bosses keep theirs, value per
>   09-00.5 Q2.
> - **Armor enum**: `UNARMORED 0, HEAVY 1, LIGHT 2, MEDIUM 3, FORTIFIED 4`.

**Covers**: A13 · **Based on**: 09-00.5. The WC3 table is the damage system for
every enemy. The per-enemy resisted school is kept, but used **only on
bosses**.

- [ ] ~~Clear `resisted_school` (set to none, `-1`) in every **regular enemy**
      `.tres`, in every chapter (read each file, not a sample). Today that's
      chap1 enemy_01 to enemy_05.~~
      **Superseded (user, 2026-10-03, during 09-07)**: regular enemies
      **keep** a resist of their chapter's school (×0.5). Chap1 has Nature
      on all 7; chap2 has Frost on all 7. See 09-07 Q3. This task's title
      and "boss-only" wording need revisiting when 09-11 starts.
- [ ] **Bosses keep the mechanic**: their `.tres` may set a resisted school
      (× 0.5 damage and status via `SCHOOL_RESIST_MULT`; Void never). The
      code in `hurtbox_component.gd` / `enemy.gd` / `apply_school_perk()`
      stays as is.
- [ ] Each boss's resisted school follows the 09-00.5 answer to open
      question 2.
  - **Rule** ✅ answered (user, 2026-09-28): **a boss resists the school
    its chapter is themed on.**
    - Ch1 (Nature): both chap1 bosses keep `resisted_school = 4` (Nature).
      No change.
    - Ch2 (Frost): both chap2 bosses get `resisted_school = 1` (Frost).
    - Ch3 (Void) ✅ answered (user, 2026-09-28): **no resist**,
      `resisted_school = -1`. Nothing resists Void
      (`hurtbox_component.gd:18` ignores Void anyway), so the Void
      chapter's bosses are the one set with no resist. The "nothing
      resists Void" design rule stays unchanged.
    - Ch4 (Poison): `resisted_school = 3`. Ch5 (Fire):
      `resisted_school = 0`. Both follow directly from the rule.
    - Chapters 6–10 (mixed) ✅ answered (user, 2026-09-28): **each boss
      keeps its own theme's resist**, wherever it appears. A Frost-set
      boss resists Frost, a Void-set boss resists nothing, and so on.
      Mixed chapters reuse the themed boss `.tres` files as they are, so
      there are no extra files.
  - **Build note**: the resist lives on the boss's **`.tres`**
    (`EnemyDefinition.resisted_school`), not its scene. A themed set that
    reuses another chapter's boss model gets its own small variant `.tres`
    (e.g. `chap4_boss_01.tres`, resist Poison, `scene` = the tinted
    variant scene from 09-08). `wave_manager.gd._spawn_enemy()` assigns
    `enemy.definition = definition` after instancing, so the `.tres` alone
    decides the resist.
  - **Final boss resist table** (by themed set):

    | Themed set | Bosses | `resisted_school` |
    |---|---|---|
    | Nature (chap1) | chap1_boss_01, _02 | 4 (Nature), already set |
    | Frost (chap2) | chap2_boss_01, _02 | 1 (Frost) |
    | Void (ch3 placeholders) | the ch3 bosses | -1 (none) |
    | Poison (ch4 placeholders) | the ch4 bosses | 3 (Poison) |
    | Fire (ch5 placeholders) | the ch5 bosses | 0 (Fire) |
    | Mixed (ch6–10) | reused from the sets above | unchanged from their set |
    - `DamageType` enum: FIRE 0, FROST 1, VOID 2, POISON 3, NATURE 4.
- [ ] Update the comments and docs to say "resist is a boss-only
      mechanic": `EnemyDefinition.resisted_school`,
      `hurtbox_component.gd`, `combat_utils.gd`, `spells.md` §3 and §6.5,
      `project.md` table notes, `mechanics.md` §5.
- [ ] Keep a table here, per chapter: each enemy's armor type (the only
      counterplay for regular enemies) and each boss's resisted school.

**Placeholders**: none · **Preview**: none (data). Checked with headless
tests:
- a Nature spell on a Light chap1 regular enemy deals exactly 100%
- the same spell on a boss that resists Nature deals table × 0.5

**Acceptance criteria**:
- [ ] No regular enemy `.tres` has a resisted school; bosses have exactly
      what the table here says.
- [ ] Regular-enemy damage matches the WC3 table exactly.

---

## Task 09-12 — Per-Chapter Reward Scaling (replaces "second material")

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Read**:
>   - `scripts/combat_utils.gd` `roll_material_reward()` /
>     `calculate_material_reward_amount()` / `calculate_rare_drop_chance()` /
>     `commit_material_reward()` (~lines 284–346).
>   - `autoloads/Constants.gd` `MATERIAL_CHECKPOINT_WAVES / _REWARDS /
>     _CHANCES` and `RARE_MATERIAL_DROP_AMOUNT`.
>   - Callers: `scenes/ui/victory_screen.gd` and `defeat_screen.gd`.
> - **Remember**: the 12 → 20 wave switch (09-00.2 Q3) changes the checkpoint
>   arrays too.

**Covers**: A12 · **Based on**: 09-00.8 (no new material; later chapters give
more of the existing ones).

- [ ] `ChapterDefinition` gets reward-scaling data, e.g. a
      `reward_multiplier` for Base Material and a `rare_chance_multiplier`
      for Tower Material and Scrolls. Defaults of 1.0 keep chapter 1
      unchanged.
- [ ] `CombatUtils.roll_material_reward()` applies the running chapter's
      multipliers (`GameState.pending_chapter_def`, or the chapter the run
      was started with). It's one place, so the victory/defeat screens need
      no change.
- [ ] The results screen shows the scaled amounts (it already formats from
      the rolled reward).
- [ ] Values per chapter are set in balancing (09-17).
- [ ] Also feeds the store rule (09-00.1): a chest's "one energy bar's worth"
      uses these same numbers, so chest value follows chapter rewards.

**Placeholders**: none.
**Preview**: `victory_screen.tscn` shows a sample scaled reward line in the
editor.

**Acceptance criteria**:
- [ ] The same result (waves reached) in a later chapter pays out more,
      exactly by that chapter's multipliers; chapter 1 pays exactly as
      today.

---

## Task 09-13 — Tower Ults (passive) + Star 3 / Star 5

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Status (2026-09-28)**: ✅ All answered (2026-09-28): research written up; all 5 ults designed (table below). The auto-vs-tap final pick is consciously left to play-testing (build both).
> - **Read**:
>   - `scenes/game_object/tower/tower.gd`: no passive code today;
>     `TowerDefinition.passive_script` is read by nothing.
>   - `autoloads/game_state.gd`: `tower_star_level` (~line 23, set in
>     `start_run()` ~line 85).
>   - `CombatUtils.calculate_star_scaled_value()` and
>     `Constants.STAR_STAT_BONUS_PER_LEVEL`.
>   - The HUD lives in `scenes/main/game_world.tscn` + `scenes/main/hud.gd`
>     (close the scene in the editor first).
> - **Do**: the trigger research needs web search. Cite sources.

**Covers**: A9 · **Based on**: 09-00.6 (every tower gets its own "ult"; star 3 / 5
make it stronger; each tower's ult is designed when this task is reached).
**Refs**: `mechanics.md` §11, `TowerDefinition.passive_script` (exists, read by
nothing)

**Part 1 — shared framework** (09-00.6: time-based charge; trigger mode to be
tested):
- [ ] `scenes/component/tower_ult_component.gd`: a base component that
      handles the **time-based charge** (duration per tower on its `.tres`,
      default in `Constants`), firing, and the star level
      (`GameState.tower_star_level`, already set at run start).
- [ ] **Both trigger modes behind one switch**: auto-fire when charged, or
      tap-to-fire. The switch is a `Constants` value, so both can be
      play-tested.
- [ ] **Trigger research**: look at what players prefer (forums, reviews,
      comparable mobile tower-defense/roguelite games), write up the
      findings here with sources, then play-test both modes. You make the
      final pick; record it in 09-00.6.
  - ✅ **Research done (2026-09-28)**. Findings:
    - **No clear winner; preference is personal.** Some players want
      control, others want the game to handle it
      ([itch.io thread](https://itch.io/post/10092386)).
    - **Many games offer both**:
      - Arknights marks each skill as either "Manual Trigger" (fires on
        the player's command once charged) or "Auto Trigger" (fires as soon
        as it's charged and has a target)
        ([Arknights wiki, Skill](https://arknights.fandom.com/wiki/Skill),
        [GamePress, Auto Trigger](https://ak.gamepress.gg/skill-activation/auto-trigger)).
      - AFK Arena's Auto mode fires ultimates "as soon as they are
        available". Guides say manual timing matters most for **defensive
        / support** ults (shields, heals), which auto mode wastes
        ([BlueStacks AFK Arena guide](https://www.bluestacks.com/blog/game-guides/afk-arena/afka-bluestack-setup-en.html)).
    - **Tower-defense players ask for auto once there's a lot to watch.**
      Bloons TD 6 abilities are manual. Players complain about "mashing
      ability hotkeys in late game" and ask for per-ability auto toggles
      ([Steam: Smart Ability System](https://steamcommunity.com/app/960090/discussions/0/3053989511988854517/)).
      The game sells auto-activation as a paid power, the Tech Bot
      ([Bloons wiki, Tech Bot](https://bloons.fandom.com/wiki/Tech_Bot)),
      and there are community "auto ability" mods.
      Legion TD 2 units attack and cast automatically
      ([Legion TD 2 manual](https://beta.legiontd2.com/manual/)).
    - **What it means for this game** (implications, not a pick):
      - The tower already auto-fires everything; the only in-run input is
        drafting. **Tap mode** would be the one moment of active skill
        during a wave.
      - **Auto mode** fits the auto-battler feel and one-handed mobile
        play.
      - Per the AFK Arena point, tap mode matters most for ults whose
        value depends on timing (heals, shields, "hit the big pack").
        Pure damage-on-cooldown ults lose little on auto.
      - The common compromise is **tap by default + an auto toggle**
        (Arknights, AFK Arena, BTD6 Tech Bot). It's cheap here, because
        the framework already builds both modes behind one switch.
    - **Final pick: still after play-testing both modes** (09-00.6 Q1),
      recorded in 09-00.6 when made.
- [ ] Star 3 / star 5: the base exposes "power tier" 1 / 2 / 3 (star 1–2 / 3–4
      / 5) that each ult reads for its stronger version. No branches in
      `tower.gd`.
- [ ] If the ult is player-triggered: an `ult_button` HUD widget showing the
      charge fill, with its own preview scene. It goes through the rule for
      editing `game_world.tscn` (close it in the editor first).
- [ ] Garage: a line under the tower name with the ult's name, what it does,
      and what star 3 / 5 add.

**Part 2 — each tower's ult, one at a time** (designed with you, recorded
here before building):

| Tower | Ult (what it does) | Star 3 | Star 5 | Status |
|---|---|---|---|---|
| Ancient (Nature) | **Barkskin**: a shield worth **25% of max HP** for **6 s**. Enemy hits drain the shield before HP | shield **40%** of max HP, **8 s** | as star 3, and **leftover shield heals the tower** when it expires | ✅ designed (user, 2026-09-28) |
| Frost | **AoE freeze (snare)**: roots **every enemy on screen** in place for a short time. They can't move but **still attack**. **Bosses are immune** | **longer** freeze | as star 3, and the freeze **also deals damage** | ✅ designed (user, 2026-09-28) |
| Void | **Void Rupture**: a burst of Void damage to **every enemy on screen** | **more damage** | as star 3, and the tower gets a **shield equal to the damage the burst dealt**, lasting 8 s | ✅ designed (user, 2026-09-28) |
| Poison | **Plague Cloud**: a poison cloud around the tower for **6 s**, poisoning and slowing everything inside | **bigger and longer** cloud | as star 3, and enemies that **die inside the cloud spread the poison** to nearby enemies | ✅ designed (user, 2026-09-28) |
| Fire | **Ring of Fire**: a ring of flame circles the tower for **6 s**, burning any enemy that crosses it | ring **lasts longer** | as star 3, and **the ring hits **already-burning** enemies for **+25%** | ✅ designed (user, 2026-09-28) |

- [ ] Each ult is a small subclass that `extends` the base and overrides only
      its effect. Attached via `passive_script` or as a component in that
      tower's scenes.

**Ult notes, per tower** (answers + consequences):
- **Ancient, Barkskin** (Claude's recommendation built on the user's
  "a shield or something like that", accepted 2026-09-28):
  - Numbers (25% / 6 s, 40% / 8 s) are **starting values**, to be kept in
    `Constants` / the tower `.tres` and tuned in 09-17 with the charge time.
  - Role: Ancient is the **defensive** tower (sidegrade rule, 09-00.1).
    The star-5 leftover-into-heal ties it to Nature's lifesteal identity.
  - **Build hook**: all tower damage goes through
    `GameState.take_damage(amount)` (`autoloads/game_state.gd` ~113, after
    `armor_damage_reduction`). The shield must absorb there, before
    `tower_hp` drops, via a small shield value/component that `take_damage`
    consults. It must be generic ("absorb N damage"), not an Ancient
    branch. The star-5 heal goes through `GameState.heal()`, which already
    emits `tower_healed`.
  - HUD / 3D: show the remaining shield (e.g. a second colour on the
    tower's `value_bar_3d`, or a bubble using the Nature school shader).
    The exact look is tuned in the preview. No new art (placeholder rule).
  - Tap-vs-auto: the ult most sensitive to timing (e.g. tapped before the
    boss heavy attack), so it's the main test case for the 09-00.6 trigger
    play-test.
- **Frost, AoE freeze** (user's design, 2026-09-28):
  - Role: the **control** tower.
  - "On screen" = enemies inside the camera frustum. `wave_manager.gd`
    already uses `camera.is_position_in_frustum()`; reuse that idea, don't
    copy it. Enemies still walking in from off-screen aren't frozen.
  - **Bosses are immune** (the user's "bosses not"). Check `definition.is_boss`
    on the enemy.
  - Freeze duration: short. Starting value ~2 s (star 1–2) and ~3 s
    (star 3+), kept in `Constants` / `.tres` and tuned in 09-17.
  - Star-5 damage: a Frost-school hit on each frozen enemy through
    `HurtboxComponent.apply_hit()`, so the WC3 table applies (Frost =
    Siege: 150% vs Unarmored/Fortified, 50% vs Medium). Amount tuned in
    09-17.
  - Build hook: the freeze is a status on the existing
    `StatusEffectComponent` (a full stop, beside its slow). Movement stops
    via `MoveToTargetComponent`, the same path slows already use.
  - ✅ **It's a snare, not a stun** (user, 2026-09-28): frozen enemies
    **can't move but keep attacking**. An enemy already at the tower keeps
    hitting it; the ult only holds back enemies still walking in. So the
    freeze touches **movement only**, and `enemy.gd`'s attack timer is
    left alone.
- **Void, Void Rupture** (user's design, 2026-09-28; the user replaced the
  example's star-5 "extra vs bosses" with a shield):
  - Role: the **damage** tower.
  - "Every enemy on screen" = the same frustum rule as Frost, and here it
    **includes bosses** (the user excluded bosses only for Frost). Hits go
    through `HurtboxComponent.apply_hit()` as Void damage: 100% vs every
    armor, never resisted.
  - Star-5 shield = the **total damage actually dealt** by that burst
    (sum of the final amounts after the table). It uses **the same generic
    shield mechanism as Ancient's Barkskin**: one shared shield
    component/value in `GameState.take_damage()`, not a second copy
    (no-duplicate rule).
  - Balance: a full screen at wave 11 (up to 60 enemies) could make a huge
    shield. The damage and any shield cap are tuning numbers for 09-17.
  - ✅ **Shield duration** (user, 2026-09-28): "same as Barkskin", i.e. a
    timed shield lasting **8 s** (Barkskin's star-5 duration; the user
    wrote "88 sec", read as 8). When time runs out, any leftover simply
    disappears; it doesn't heal (that stays Ancient's star-5 feature).
    Shares Barkskin's duration constant/mechanism.
- **Poison, Plague Cloud** (the user picked Claude's example, 2026-09-28):
  - Role: the **damage-over-time / spreading** tower.
  - A zone centred on the tower that applies Poison's normal perk (DoT +
    slow via `CombatUtils.apply_school_perk()` / `StatusEffectComponent`)
    to every enemy inside it, ticking like the AoE Area archetype
    (`aoe_area.gd`: body_entered/exited list + tick). **Reuse or extend
    that, don't copy it** (no-duplicate rule).
  - Starting values (tuned in 09-17): radius ~4 m, 6 s. Star 3+: a bigger
    radius **and** a longer duration (e.g. ~5 m, 8 s).
  - Star 5 spread: when a poisoned enemy dies inside the cloud, re-apply
    the poison to enemies within a small radius of it (reuse Chain Bolt's
    "nearest enemies within radius" idea, `CHAIN_BOUNCE_RADIUS`-style).
    The hit goes through `apply_hit()` so the table applies. Hooks the
    enemy's `HealthComponent.died` / `EventBus.enemy_died(enemy, position)`.
  - Bosses: not excluded (only Frost excludes bosses).
  - Visual: a ground disc with the Poison school shader, like the AoE Area
    decal. No new art.
- **Fire, Ring of Fire** (the user picked Claude's example, 2026-09-28):
  - Role: the **wall / burn** tower. Unlike Poison's filled cloud, this is
    a thin **ring** at a fixed radius (starting ~4 m, tuned in 09-17).
    Enemies take the hit + burn when they **cross** it, so it punishes
    anything walking in.
  - Hit = a Fire-school hit through `apply_hit()` (table: Fire = Magic,
    200% vs Heavy, 35% vs Fortified), which applies Fire's normal burn
    perk. An enemy is hit once per crossing (a per-enemy "already hit"
    set, like the lance's).
  - Starting values: 6 s; star 3+ ~9 s (09-17).
  - Visual: a ring decal with the Fire school shader. No new art.
  - Bosses: not excluded.
  - ✅ **Star-5 "extra damage"** (user, 2026-09-28): **from the ring only**.
    When the ring hits an enemy that is **already burning**, that ring hit
    deals **+25%**. The user's starting value is a `Constants` number,
    tuned in 09-17. Spells are unaffected. Needs a "is burning?" query on
    `StatusEffectComponent`.

**Placeholders**:
- ult icon: a school-coloured drawn circle → final
  `hud/icon_ult_<tower_id>.png`. This replaces the "tower ability icon"
  removed from the art list, so ask before adding real art.
- ult effect visuals: reuse the existing `SchoolVFXComponent` presets and
  shaders, no new particle art.

**Preview**: `ult_button.tscn` with a `preview_charge` knob (if
player-triggered); `tower_garage_content.tscn` shows the ult text line with
placeholder copy.

**Acceptance criteria**:
- [ ] Each designed ult charges and fires as specified; star 3 / 5 are
      visibly stronger; no `if tower_id == …` anywhere.

---

## Task 09-14 — Spell Rank Behaviors (rank 3 / rank 5 milestones)

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Read**:
>   - `autoloads/game_state.gd`: `spell_rank_multipliers` (~180) and
>     `get_spell_damage_multiplier()` (~182).
>   - The damage lines in `standard_bolt.gd:63`, `chain_bolt.gd:47`,
>     `orb.gd:125`, `aoe_area.gd:164`, `line_aoe_bolt.gd:85`.
>   - `scenes/ui/spell_codex.gd` (~68–85, row text/costs).
>   - Chain: `CHAIN_MAX_BOUNCES` and each chain spell's `max_bounces`.
> - **Watch out**:
>   - `@tool` must be **redeclared** in subclasses (`blizzard.gd`,
>     `rain_of_fire.gd`) for `preview_*` setters to run in the editor.
>   - Don't turn a `const` preset dict into a `static var` (editor hot-reload
>     bug, see `school_vfx_component.gd` history).

**Covers**: A10 · **Based on**: 09-00.7 · **Refs**: `mechanics.md` §11,
`spells.md` §5 archetype scripts

- [ ] Rank read at cast time from `MetaManager.spell_ranks` (via
      `GameState`), never by mutating the `.tres` (skill: resource mutation
      footgun). The +8% damage per rank stays as is.
- [ ] Milestone unlocks per spell type, from the 09-00.7 table. Each
      archetype script checks "rank ≥ 3" / "rank ≥ 5" through **one shared
      helper**, and the numbers live in `Constants` / `.tres`:
  - Standard Bolt: splash on hit (small at 3, bigger at 5), reusing an area
    query like `aoe_area.gd`'s, hits through `apply_hit()`.
  - Chain Bolt: `max_bounces` +1 at 3, +2 at 5.
  - Orb: ring spin speed up at 3; orb size (visual + hit radius) up at 5.
  - AoE Area: `duration` up at 3; `aoe_radius` (decal + shards + hit area)
    up at 5.
  - Lance: bigger at 3 (per 09-00.7 Q2); damaging trail at 5, a pooled
    lingering hit zone behind the lance, hits through `apply_hit()`.
- [ ] Spell Codex row shows both milestones ("Rank 3: …" / "Rank 5: …"),
      greyed until reached.

**Placeholders**: splash and trail visuals reuse the existing school VFX
(`SchoolVFXComponent` presets / `school_surface.gdshader`); no new art.
Particle budget applies (`CombatUtils.try_reserve_particles`).
**Preview**:
- `spell_codex_content.tscn` placeholder rows show the milestone lines
- each archetype scene gets a `@tool` `preview_rank` knob showing its bigger
  size at rank 5 in the editor, the same way `preview_school` works
- splash/trail: shown in a test run

**Acceptance criteria**:
- [ ] At rank 3 / 5 each spell type shows exactly its unlock in a run; below
      that rank it doesn't.
- [ ] Hit sizes match visual sizes. The splash and trail respect the
      particle budget.

---

## Task 09-15 — Spell Stacking & Lance Hitbox

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Current `stack_max`** (`resources/spells/*.tres`): bolt 3, chain 3,
>   orb 8, area 1, lance 1. Change every file.
> - **Read**:
>   - `scenes/game_object/tower/tower.gd` volley path: `_try_fire`,
>     `_fire_projectile`, `_spawn_bolt`, `_fire_aoe_area`, and
>     `Constants.BOLT_VOLLEY_STAGGER_SEC`.
>   - `scenes/manager/draft_manager.gd` eligibility filter.
> - **Lance hitbox**:
>   - `Constants.LANCE_HITBOX_LENGTH = 1.6` / `WIDTH = 0.7` (~line 225).
>   - `scenes/game_object/line_aoe_bolt/line_aoe_bolt.gd`: exports lines
>     25–26, collision box 90–91, hit check 118–121.
>   - `line_aoe_bolt.tscn`: `BoxShape3D` size `(1.7, 1.7, 2.6)`.

**Covers**: A11 · **Based on**: 09-00.3 (confirmed). 09-00.4 answered "no new
spells", so this task adds none.

- [ ] Set the new `stack_max` values in every affected `.tres`: AoE Area 3,
      Lance 5, Chain Bolt 5, Standard Bolt 5 (every file, not a sample). Orb
      stays 8.
- [ ] AoE Area (Blizzard, Rain of Fire) and all 5 Lances: each extra pick
      fires **1 more** per cast, same as the first, each at a **different
      random enemy** in range, with a slight delay between them. This reuses
      the tower's existing Bolt volley path (`stack_count`,
      `BOLT_VOLLEY_STAGGER_SEC`) instead of writing a second one.
- [ ] Lance hitbox a bit **wider** (`LANCE_HITBOX_WIDTH`, and `_LENGTH` only if
      needed, in `Constants.gd`); keep the scene's `BoxShape3D` matching.
      Target: a lance fired at one enemy in a cluster next to the tower also
      hits the enemies to its left and right, plus everything behind it.
      Numbers tuned in a test run.

**Placeholders**: none.
**Preview**: a test run with a few enemies clustered side by side near the
tower, showing the wider lance hits and a 3-zone Blizzard / 5-lance volley.

**Acceptance criteria**:
- [ ] Every spell type stops appearing in drafts exactly at its new
      `stack_max`.
- [ ] Pick N of an AoE Area / Lance fires N per cast, at different enemies
      when there are enough.
- [ ] A lance hits the enemies either side of its target in a cluster.

---

## Task 09-16 — Boss Depth (phases + intro)

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Status (2026-09-28)**: ✅ All answered (2026-09-28): "BOSS" banner only (no camera), 2 phases at 50% HP (heavy attack only in phase 2).
> - **Read**:
>   - `scenes/component/boss_heavy_attack_component.gd`
>   - `chap1_boss_01/02.tscn`
>   - `scenes/game_object/camera_rig/camera_rig.gd`
> - **Watch out**: camera shake is on the user's **"not wanted"** list. Ask
>   before touching the camera.

**Covers**: A8 · **Refs**: `mechanics.md` §3 "multi-phase bosses [LATER]", §1
"brief zoom/pan on boss intro [LATER]"

- [ ] `scenes/component/boss_phase_component.gd`: HP thresholds (on the boss
      `.tres` or as exports) switch the boss to its next phase. Each phase
      changes data such as speed, attack cooldown and heavy-attack frequency.
      Attached only to boss scenes, next to `BossHeavyAttackComponent`.
- [ ] Phase change tell: a reuse of the existing heavy-attack telegraph
      (scale pulse / flash), no new art.
- [ ] **Phase design** ✅ answered (user, 2026-09-28; the user's idea "simple
      attacks first, then add the heavy hit", in Claude's recommended
      form):
  - **2 phases, split at 50% HP**, the same rule for every boss.
  - **Phase 1 (100% → 50%)**: normal attacks only. The heavy attack is
    **off**.
  - **Phase 2 (< 50%)**: the heavy attack turns **on**, exactly as today
    (every `BOSS_HEAVY_ATTACK_EVERY_N` = 4th attack, ×2.5, 0.5 s
    telegraph).
  - Crossing 50% plays one scale pulse (`BossHeavyAttackComponent._telegraph()`
    reused, not copied).
  - Nothing else changes: speed and attack cooldown stay the same.
  - Build: `boss_phase_component.gd` listens to the sibling
    `HealthComponent.health_changed` and enables the heavy attack at the
    threshold. `BossHeavyAttackComponent.perform_attack()` needs an
    "enabled" flag; while disabled, every attack is a normal
    `GameState.take_damage(base_damage)`.
  - The threshold (`BOSS_PHASE_2_HP_FRACTION = 0.5`) goes in `Constants`.
    The component stays able to hold more thresholds later.
  - Known side effect: bosses get **easier than today** in their first
    half (the heavy hit is active from the start today). Compensate in
    09-17 if needed.
- [ ] **Boss intro** ✅ answered (user, 2026-09-28): **a "BOSS" banner only.
      No camera move, no shake.** `camera_rig.gd` is not touched.
  - Why (Claude's recommendation, accepted):
    - The fixed camera always shows the whole arena, and the boss spawns
      off-screen at a random edge, so a zoom/pan would hide the arena and
      chase the boss.
    - The boss wave is only the boss, so a banner is enough.
    - It's cheap.
  - Trigger: listen to `EventBus.boss_spawned` (emitted in
    `wave_manager.gd` `start_wave()`; nothing listens to it today). The
    HUD shows a big "BOSS" text banner for ~2 s, then it goes away. The
    game keeps running, with no new `get_tree().paused` writer.
  - Reuse `synergy_banner.gd`'s show / fade / queue mechanism (its synergy
    job was removed) by extending it or sharing a helper. Don't write a
    second banner script (no-duplicate rule). Check 10-13 (dead code
    cleanup) doesn't delete it first.
  - Text: "BOSS" only. Bosses have no display name field. Using the banner
    for phase changes too was offered as optional and **not** chosen.

**Placeholders**: banner = drawn `Label` → optional final `hud/ui_boss_banner.png`.
**Preview**: any chosen banner is its own `.tscn`, previewable on its own.
Phases are verified in a run.

**Acceptance criteria**:
- [ ] Bosses visibly change behavior at each threshold; regular enemies are
      unaffected.

---

## Task 09-17 — Difficulty Curve & Balancing

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Status (2026-09-28)**: ✅ All answered (2026-09-28): 20 waves as the length target; switch at the start of this task; difficulty curve (ch1–5 even climb, ch6–10 steeper); short-range spells: check after the switch, with a fallback. Only play-test numbers remain.
> - **Do last**. It tunes everything above.
> - **Read**:
>   - `autoloads/Constants.gd` (`ENEMY_HP_SCALE`, `ENEMY_DMG_SCALE`,
>     `WAVE_BASIC_ENEMY_WEIGHT`, `WAVE_FAST_ENEMY_WEIGHT`).
>   - `spells.md` §6.4 (range ladder: 10 / 8 / 6.5 / 4 m).
>   - Every chapter `.tres`.

**Covers**: A7 · Do this **after** 09-03 → 09-16, since it tunes all of them.

- [ ] Write down the targets first, with you: rough run length, how often a
      fresh star-1 tower should clear chapter 1, and the step up per chapter.
  - ✅ **Run length** (user, 2026-09-28): **no minute target; a run is
    20 waves** ("making it 20 waves will make it good enough").
    - Today a chapter-1 run takes **under 5 min** (user).
    - The user wanted "about one Archero chapter" but wasn't sure how long
      that is. The research couldn't pin it down: one unverified
      farming-guide figure says ~4–7 min
      ([HubPages](https://discover.hubpages.com/games-hobbies/Archero-Farming-Guide));
      speedruns take ~2.5–3 min
      ([speedrun.com](https://www.speedrun.com/archero)); chapters have up
      to 50 stages
      ([Archero wiki](https://archero.fandom.com/wiki/Frequently_Asked_Questions)).
    - So the target is the **wave count**, not a time. Measure the real
      20-wave run time in play-tests and record it here.
    - Consequence: the 20-wave ramp must actually get longer and harder.
      Today the enemy count (`3 × 1.5^(w−1)`, capped at 60) hits its cap at
      wave 9, so waves 9–19 would all be 60-enemy waves. Reshaping that
      ramp is part of "Switch to 20 waves" below.
  - ✅ **Difficulty curve** (user, 2026-09-28): **the requirement climbs
    chapter by chapter** (option B: chapter 1 is beatable with a fresh
    star-1 tower; the top chapters need at least star 3, ideally star 5).
    - **Chapters 1–5 (themed)**: an even, gentle climb. Each chapter needs
      **about the same amount of extra upgrading** as the one before
      ("the first 5 … about the same amount of upgrades to finish").
      Rough shape: ch1 fresh star 1 → ch5 around star 3.
    - **Chapters 6–10 (mixed, 2–3 enemy themes each)**: steeper. They need
      a **well-upgraded combination**: tower stars, ranked spells and
      good drafting across schools ("good upgraded combination of tower
      and spells and the rest"). Top chapters are star 3 at least, star 5
      to be comfortable.
    - Knock-on: a newly unlocked tower starts at star 1, so it usually
      needs upgrading before it can clear the next chapter. That's
      accepted as part of the climb.
    - Per-chapter scaling lives on `ChapterDefinition` (HP/damage
      multipliers, bullet below). The exact numbers come from
      play-testing against this curve.
- [ ] Per-chapter scaling lives on `ChapterDefinition` (e.g. HP/damage
      multipliers on top of `ENEMY_HP_SCALE`), so chapters differ by data.
- [ ] **Switch to 20 waves** (09-00.2). ✅ **Timing answered** (user,
      2026-09-28): **at the start of this task**. Every task before it
      (09-01 → 09-16) is built and tested at 12 waves; this task switches
      first, then tunes everything at 20. Update together:
      - `Constants.TOTAL_WAVES`
      - every chapter's `wave_count`
      - `MATERIAL_CHECKPOINT_WAVES` / `_REWARDS` / `_CHANCES`
      - the ramp in `wave_manager.gd`
- [ ] Tune the new numbers from Epic 09's answers:
      - stack caps (09-15)
      - rank 3 / 5 unlock values (09-14)
      - ult charge times (09-13)
      - per-chapter reward multipliers (09-12)
      - the chest cap of "one energy bar's worth" (09-00.1)
      - armor mixes (09-11)
- [ ] Check towers stay **sidegrades** (09-00.1): no tower should clearly
      beat the others at the same star.
- [ ] The known issue: short-range spells rarely fire because enemies die
      before closing to 6.5 / 4 m (`spells.md` §6.4). ✅ **Answered**
      (user, 2026-09-28, Claude's recommendation): **do nothing now; check
      it in this task after the 20-wave switch.**
  - Why:
    - At 20 waves (up to 60 enemies, ×3–7 HP), enemies will reach close
      range far more often.
    - 09-15 (wider lance, multi-cast), 09-14 (rank unlocks) and the ults
      (Frost snare, Poison cloud, Fire ring) all change it too.
    - The range ladder is deliberate.
  - **Check**: after the switch, play a few runs with Lances and
    Blizzard / Rain of Fire drafted and see whether they fire regularly.
  - **Fallback if they still rarely fire**: first raise their ranges in
    each spell's `.tres` (AoE 6.5 → ~8 m, Lance 4 → ~6 m). Only if that's
    not enough, look at enemy toughness. Record what you land on here.
- [ ] Balance every tower × chapter combination by play-testing. Record the
      numbers you land on in this task.

**Placeholders**: none · **Preview**: none (numbers).

**Acceptance criteria**:
- [ ] Each chapter meets the targets written at the top of this task, for
      each launch tower.

---

## Task 09-18 — Integration Test

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Back up the save first.** Open every preview scene listed in 09-03 …
>   09-16.

- [ ] Fresh save (backed up first). Play chapter 1 → unlocks chapter 2 → play
      it → every launch chapter.
- [ ] Get tower #2 by the A2 method; play a run with each tower at star 1 and
      star 5.
- [ ] An old (pre-09-01) save loads with nothing lost.
- [ ] Open every preview scene added this epic and confirm it shows what its
      task says.
- [ ] Every placeholder added this epic is listed in `ui_assets.md` "STILL TO
      MAKE" (or the model swap tables in 09-04 / 09-08).
