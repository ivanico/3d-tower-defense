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

Split into 8 sub-tasks, one per question, answered one at a time. Nothing is
built in any of them: Claude explains what the question means against the
current code, you answer in your own words, and the confirmed answer is
written into that sub-task so later tasks can cite it. A sub-task is done
once its answer is confirmed, or marked "later" (which skips the task that
depends on it).

| Sub-task | Question | Feeds | Status |
|---|---|---|---|
| 09-00.1 | A2 — tower unlock method | 09-03, 09-04, 09-05, 10-04, 10-05, 12-00 | ✅ answered (6th garage slot deferred) |
| 09-00.2 | A4 — chapters at launch | 09-08, 09-17 | ✅ answered (12→20 timing deferred to 09-17) |
| 09-00.3 | A11a — AoE Area / Lance stacking | 09-15 | ✅ confirmed |
| 09-00.4 | A11b — fill the 5 empty grid spells | 09-15 | ✅ confirmed — no new spells |
| 09-00.5 | A13 — enemy resistances | 09-11 | ✅ answered — WC3 table + boss-only resist (boss values deferred to 09-11) |
| 09-00.6 | Tower passives + star 3 / 5 | 09-13 | ✅ answered — time charge; trigger tested in 09-13; ults designed in 09-13 |
| 09-00.7 | Spell rank behaviors | 09-14 | ✅ answered — rank 3 / 5 unlocks, per spell |
| 09-00.8 | Second material per chapter | 09-12 | ✅ answered — no new material; per-chapter reward scaling |

---

### Task 09-00.1 — A2: How does the player get tower #2+?

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - ✅ Answered. Unlock order (A); Ancient model is the Poison/Fire placeholder; 6th slot deferred to 09-04.
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
- **5 towers vs 6 garage slots**: one slot stays "Coming Soon" or is removed.
  To confirm.
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
   "Coming Soon" or is removed. Decide when 09-04 is built.

**Acceptance criteria**:
- [x] All questions answered or explicitly deferred.


---

### Task 09-00.2 — A4: How many chapters at launch?

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - ✅ Answered. The 12 → 20 wave switch is deferred to 09-17.
> - **Read**:
>   - `autoloads/Constants.gd`: `TOTAL_WAVES = 12`, `WAVE_DURATION_MAX`,
>     `MATERIAL_CHECKPOINT_WAVES = [3, 6, 9, 12]`.
>   - `resources/chapters/chapter_01.tres`: `wave_count = 12`.
>   - `scenes/manager/wave_manager.gd`: `_get_wave_composition()`, where
>     `enemy_pool[1]` is the "fast" enemy.

**Status**: draft answer below, waiting on the open questions.

**Draft answer (user, 2026-09-27)**:
- **About 10 chapters at launch** ("10 or something like that"). More content
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
> - ✅ Answered. Boss resist values are deferred to 09-11. Both chap1 bosses
>   currently have `resisted_school = 4` (Nature) in
>   `scenes/game_object/chap1/chap1_boss_01/chap1_boss_01.tres` and
>   `chap1_boss_02/chap1_boss_02.tres`.
> - **Code involved** (line numbers as of 2026-09-27): see 09-11's note.

**Status**: draft answer below, waiting on the open question.

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

---

### Task 09-00.6 — Tower passives + star 3 / star 5

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - ✅ Answered. What's left happens inside 09-13: the trigger-mode test and
>   research, and each tower's ult design.

**Status**: ✅ answered (2026-09-27). Left for 09-13: the trigger mode (tested + researched there)
and each tower's actual ult (designed there).

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

## Task 09-01 — Save Versioning & Migration (moved here from F6)

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

- [ ] Add `@export var save_version: int` to `SaveData` and a
      `Constants.SAVE_VERSION` (starts at 2; saves with no field count as 1).
- [ ] `MetaManager.load()` runs an ordered list of small migration steps
      (`_migrate_1_to_2()`, …) on older saves, then saves. Each step only
      fills in defaults for fields it introduced.
- [ ] Fix the existing gap found while writing this epic:
      `MetaManager.premium_currency` exists but **is not in `SaveData`**, so it
      never persists. Add it here, as migration 1 → 2.
- [ ] Rule for every later task that adds a save field: bump
      `SAVE_VERSION` and add a migration step. This rule is repeated in each
      task that touches `SaveData`.

**Placeholders**: none · **Preview**: none (data only). Verified with a headless
round-trip on a **backed-up copy** of the real save (memory: tests write to the
real `user://savegame.tres`).

**Acceptance criteria**:
- [ ] A save file written before this change loads with every old value
      intact and `save_version` = current.
- [ ] A save with a *higher* version than the game knows is not overwritten
      (it's loaded read-only or refused, and the problem is logged).

---

## Task 09-02 — Docs Cleanup (moved here from H1)

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

- [ ] Fix every stale spot listed in H1:
  - synergy tags (bookkeeping only)
  - starting spell (`spells.md` §6.2 — no free spell; first-spell draft)
  - enemy pooling (enemies `queue_free()`, not pooled)
  - "resistances not used yet" (`spells.md` §6.5 — they are)
  - the missing `HUD.tscn` (the HUD is inline in `game_world.tscn`)
  - `spells.md` §6.7
- [ ] Also fix the ones found this session:
  - `project.md` says no enemy uses Light/Medium/Fortified. Check each
    enemy `.tres` and correct it.
  - `components.md` §6 says one `CooldownComponent` per spell. `tower.gd`
    uses a `_spell_timers` dict.
  - Hit detection is a hybrid broad-phase + `apply_hit()`, not
    `area_entered`. Fix this in `mechanics.md` §5 and the `godot3d-combat`
    skill.
  - References to `epic_0N_*.md` now point to `epic_done/`.
- [ ] Write the **09-00 decisions** into the design docs, so they stop
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
- [ ] Verify each claim against the code before writing it (memory: verify,
      don't generalize).

**Placeholders**: none · **Preview**: none.

**Acceptance criteria**:
- [ ] Each fix above cites the file and line it was checked against.

---

## Task 09-03 — Frost Tower & Void Tower (playable)

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

- [ ] For each of `frost_tower` and `void_tower`: create
      `scenes/game_object/tower/<id>/<id>_lvl1..5/<id>_lvl<N>.tscn`. Follow the
      structure `ancient_tower_lvlN.tscn` already uses (shared `tower.gd` +
      component scenes + `HealthBar3D`), with the model `ext_resource` swapped.
      The script is shared, not copied.
- [ ] Idle animation: `tower.gd._play_idle()` already no-ops on models
      without an `idle` clip. Check which levels have one and note it. Don't
      add idle to every level (deliberate, see the "Removed" list).
- [ ] `resources/towers/tower_frost_tower.tres` / `tower_void_tower.tres` replace
      `tower_locked_02` / `tower_locked_03` (keep their `sort_order` 1 and 2).
      Stats start as a copy of Ancient's numbers and get tuned in 09-17.
      `starting_spell_id` stays empty (dead field, B10).
- [ ] Ownership follows 09-00.1: each tower is unlocked by **beating its
      chapter** (or from a gem chest), wired in 09-05. Until 09-05 the towers
      exist as content (`unlocked = true`) but aren't owned, so the garage
      greys them out through the existing `TowerRegistry.is_playable()`. To
      play-test before 09-05, add them to `owned_towers` in a throwaway
      headless script on a backed-up save.
- [ ] Towers must be **sidegrades**, not strictly stronger, because they can
      come from a paid chest (09-00.1). Keep the base stats close to
      Ancient's; differences come from the ults (09-13).

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
- [ ] Garage grid shows Ancient, Frost, Void in slots 1–3 with correct icons;
      the 3D preview shows every star level of each.
- [ ] With the tower owned and selected, a run starts with that tower's model
      at each star level, and combat works exactly as with Ancient.

---

## Task 09-04 — Extra Tower Slots Reuse Existing Models (for towers without their own model, e.g. Poison & Fire per 09-00.1)

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Read**: `resources/towers/tower_definition.gd` and
>   `autoloads/tower_registry.gd` → `static func get_preview_model()`
>   (~line 55).
> - **Applies to**: Poison and Fire (no models), per 09-00.1.

**Covers**: A1 (beyond the 3 real models)

- [ ] Add `@export var preview_model_id: String = ""` to `TowerDefinition`.
      `TowerRegistry.get_preview_model()` uses it when set, instead of the
      tower's own ID. This is how a new tower borrows an existing tower line's
      `.glb` for the garage preview.
- [ ] Per 09-00.1, the two towers without models are **Poison Tower**
      (`poison_tower`, replaces `tower_locked_04`, `sort_order 3`) and **Fire
      Tower** (`fire_tower`, replaces `tower_locked_05`, `sort_order 4`).
      Each gets its own `<id>_lvlN.tscn` gameplay scenes (09-03 pattern)
      instancing the **Ancient Tower model as the placeholder** (09-00.1
      Q8), tinted to its school. The real model arrives
      later as one `ext_resource` change per scene plus clearing
      `preview_model_id`.
- [ ] The 6th slot (`tower_locked_06`): stays "Coming Soon" or is removed.
      Deferred in 09-00.1 Q8; ask when building this task.

**Placeholders**: borrowed tower model + tinted Ancient icon → final
`assets/models/towers/<id>/<id>_lvl1–5.glb` and `garage/icon_tower_<id>.png`.
**Preview**: same as 09-03.

**Acceptance criteria**:
- [ ] A borrowed-model tower is playable and previewable. Swapping the real
      `.glb` in touches no `.gd` file.

---

## Task 09-05 — Tower Unlock Method

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Blocked** until 09-00.1's open questions are answered.
> - **Read**:
>   - `scenes/ui/tower_garage_content.gd` (action bar with Select/Upgrade +
>     `cost_chip`s).
>   - `scenes/ui/widget/cost_chip/cost_chip.gd`.
>   - `autoloads/meta_manager.gd` (`owned_towers`, `upgrade_tower_star`).
>   - `autoloads/tower_registry.gd` (`is_playable`).

**Covers**: A2 · **Based on**: 09-00.1 (towers unlock by beating a chapter,
or from a gem chest). **Needs** 09-00.1 open question 1 answered: order
(A) or (B).

- [ ] `TowerDefinition` gets `@export var unlock_chapter_id: String`, the
      chapter whose **first victory** unlocks this tower. Ancient stays owned
      from a fresh save. Filled per 09-00.1 Q1 (A or B). The mapping is data,
      so changing the order is a `.tres` edit.
- [ ] One `MetaManager.unlock_tower(tower_id)` (adds to `owned_towers`, saves,
      emits an `EventBus` signal). It's called from:
      - chapter victory (09-10's `mark_chapter_cleared` → any tower whose
        `unlock_chapter_id` matches)
      - a gem-chest tower drop (10-05)

      No second unlock path.
- [ ] Chapter progress is **not** unlocked by getting a tower from a chest.
- [ ] Garage: a not-owned tower shows "Beat Chapter N" (from
      `unlock_chapter_id`) in the action bar, where Select/Upgrade are.
- [ ] Victory screen: "New tower unlocked: <name>!" the first time.
- [ ] No new save field (uses `owned_towers`), so no migration needed unless
      something else is added.

**Placeholders**: any lock/price badge art → drawn stand-in, final
`garage/ui_tower_unlock_badge.png` (only if you want art there).
**Preview**: `tower_garage_content.tscn` placeholder cells include one locked,
one unlockable, and one owned cell, so all three states show in the editor.

**Acceptance criteria**:
- [ ] Fresh save: only Ancient owned. Beating each tower's chapter unlocks
      exactly that tower, once; it stays owned after a restart and can be
      selected and played.
- [ ] Calling the unlock from a (fake) chest grants a tower without touching
      chapter progress.

---

## Task 09-06 — Chapter Plumbing (arena per chapter, chapter registry)

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

- [ ] Add `@export var arena_scene: PackedScene` and `@export var sort_order: int`
      to `ChapterDefinition`. `game_world.gd` instances the pending chapter's
      arena and falls back to the baked chap1 arena when run standalone (F6),
      the same way `pending_tower_def` already falls back. Leave
      `arena_model_path` for B10.
- [ ] `ChapterRegistry` autoload: loads `resources/chapters/*.tres` via the
      shared `scripts/resource_dir.gd` (**do not copy the scan loop** —
      `TowerRegistry` already uses it) and sorts by `sort_order`. Same shape as
      `TowerRegistry`.
- [ ] Document in `wave_manager.gd` and `components.md` that
      `_get_wave_composition()` treats `enemy_pool[1]` as the "fast" enemy.
      Every chapter's pool order must follow that rule.
- [ ] Close `game_world.tscn` in the editor before editing it (rule 3).

**Placeholders**: none · **Preview**: none new (chapter 1 must look and play
identically).

**Acceptance criteria**:
- [ ] Chapter 1 plays exactly as before, now reached through `arena_scene`.
- [ ] `ChapterRegistry` lists chapter_01 and picks up a new `.tres` with no
      code change.

---

## Task 09-07 — Chapter 2 Content

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
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

- [ ] `scenes/game_object/chap2/chap2_enemy_01..05/` and `chap2_boss_01..02/`:
      copy the matching chap1 folder, swap the model `ext_resource`, and
      re-point the hand-authored `walk`/`attack` animation tracks, which target
      the model node by name (`chap1_enemy_01:position` → `chap2_enemy_01:…`).
      If a chap2 `.glb` has its own clips, use those instead.
  - Bosses keep `BossHeavyAttackComponent`. Check it still works when the
    model has no `attack_heavy` clip; if not, it falls back to the scale-pulse
    telegraph.
  - Shared `enemy.gd`, not copied.
- [ ] Co-located `.tres` per enemy. Stats start as the chap1 counterpart's
      values, tuned in 09-17. Order `enemy_pool` so index 1 is the fast
      enemy (09-06).
- [ ] **Theme: Ice / Frost** (09-00.2): chapter name, arena colours (blues)
      and map art follow it.
- [ ] **Armor & resist** (09-00.5): regular enemies get an armor type
      (Unarmored/Light/Medium/Heavy/Fortified) and **no** resisted school.
      Bosses may get a resisted school; which one is the user's pick.
      Record the mix in 09-11's table.
- [ ] `wave_count`: same as chapter 1 for now (12 while building; 20 later,
      per 09-00.2 Q3).
- [ ] Per-model `HealthBar3D.height_offset` set to that model's height.
- [ ] `chap2_arena/chap2_arena.tscn`: copy `chap1_arena`, new `color_1–4`
      (e.g. blues, as `arena.gd` intends).
- [ ] `resources/chapters/chapter_02.tres`: name, pools, `arena_scene`,
      `sort_order = 1`, `map_image`.

**Placeholders**: map image = `chapter_01_image_v2.png` → final
`world_map/chapter_02_image.png`. Chapter name "Chapter 2" until you pick one.

**Preview**: `scenes/game_object/chap2/chap2_lineup_preview.tscn`, an editor-only
scene with the arena, the camera rig and every chap2 enemy + boss standing in
a row. It shows scale, facing and HP-bar heights at a glance. It isn't meant
to be run.

**Acceptance criteria**:
- [ ] A full chapter-2 run works: every enemy walks, attacks, dies; a boss
      appears on the final wave; victory and defeat both return to the map.
- [ ] The lineup preview shows all 7 at believable relative sizes.

---

## Task 09-08 — Chapters 3+ Using Existing Models

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
> - **Needs**: 09-00.2's open answers (count, themes, when to switch to 20
>   waves).
> - **Remember**: a chapter's `enemy_pool` can reference any existing enemy
>   `.tres` in any chapter folder, so only copy a folder when a variant is
>   needed.

**Covers**: A4 · **Based on**: 09-00.2 (about 10 chapters, open-ended;
enemies mixed across chapters; 20 waves target) and its theme table.

| Chapter | Theme | Built from |
|---|---|---|
| 3 | Void | reused chap1/chap2 enemies, Void tint + arena colours |
| 4 | Poison | reused, Poison tint + arena colours |
| 5 | Fire | reused, Fire tint + arena colours |
| 6–10 | mixed | enemies from several themes combined in one pool |

- [ ] **Chapters 3–5 (themed)**: a themed enemy is a small **variant scene**
      in `scenes/game_object/chap<N>/…` that instances an existing chap1/chap2
      model with a school tint (e.g. `material_overlay`; check it doesn't
      fight `hit_flash_component.gd`, which also uses `material_overlay`).
      Only make a variant where the tint or stats must differ. Otherwise
      reference the existing enemy `.tres` directly.
- [ ] **Chapters 6–10 (mixed)**: `enemy_pool` / `boss_pool` list **existing**
      enemy `.tres` files from any chapter folder. No new scenes unless a
      variant is needed. Keep the `enemy_pool[1]` = fast-enemy rule (09-06).
- [ ] Armor mix per chapter and boss resists per 09-00.5 (09-11's table).
- [ ] Rewards per chapter via 09-12's multipliers.
- [ ] Each chapter gets `chapter_0N.tres`, an arena copy with its own colours,
      and a lineup preview. More chapters later = more `.tres` + arenas, no
      code.
- [ ] Keep a table in this task: which chapter/enemy borrows which model, so
      the real-model swap list is obvious later.

**Placeholders**: borrowed `.glb` per enemy → final
`assets/models/chap<N>/chap<N>_enemy_0M.glb` / `_boss_0M.glb`; map image →
`world_map/chapter_0N_image.png`.
**Preview**: `chap<N>_lineup_preview.tscn` per chapter.

**Acceptance criteria**:
- [ ] Every launch chapter is fully playable, and swapping any single enemy to
      a real model is one `ext_resource` change.

---

## Task 09-09 — Chapter Select Carousel

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

- [ ] Replace `CHAPTER_IDS` with `ChapterRegistry` (09-06).
- [ ] Left/right arrows + horizontal swipe on the chapter art move
      `_current_index`. The title, art and Play button follow it. Remember the
      last viewed chapter (per-viewer convenience, can live in `SaveData` with
      a migration).
- [ ] Locked chapters use the existing `chapter_node.locked` and
      `ui_locked_overlay.png`. Play is disabled on them and shows the unlock
      condition (09-10).
- [ ] Arrow buttons are a small `@tool` widget (`widget/carousel_arrow/`),
      tuned in its own scene.

**Placeholders**: arrows drawn in code (like `pause_button`) → final
`world_map/ui_carousel_arrow.png` (optional).
**Preview**: `world_map_content.tscn` shows the arrows. A `@tool`
`preview_locked` knob on `chapter_node` shows the locked look in the editor.
`carousel_arrow.tscn` previews on its own.

**Acceptance criteria**:
- [ ] Every chapter from `ChapterRegistry` can be reached. Play starts the
      chapter on screen; locked ones can't be started.

---

## Task 09-10 — Chapter Progression & Locks

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

- [ ] `SaveData.cleared_chapters: Array[String]` (+ `SAVE_VERSION` bump and
      migration). `MetaManager.mark_chapter_cleared(id)` is called on victory.
- [ ] `ChapterRegistry.is_unlocked(id)`: the first chapter is always open;
      chapter N+1 opens when N is cleared. The rule lives in one place.
- [ ] Victory screen shows "Chapter N+1 unlocked!" the first time only.
- [ ] The first clear of a chapter also unlocks its tower (09-05's
      `unlock_chapter_id`). One hook: `mark_chapter_cleared` → tower
      unlocks. The victory screen shows both lines.
- [ ] Buying a tower from a chest never marks a chapter cleared.

**Placeholders**: none (text).
**Preview**: `victory_screen.tscn` shows the unlock line in the editor
(placeholder text, hidden at runtime unless it applies).

**Acceptance criteria**:
- [ ] Fresh save: only chapter 1 playable. Beating it unlocks 2, and that
      survives a restart.

---

## Task 09-11 — Resistances: WC3 Table for Everyone, Resist for Bosses Only

> **🔎 Fresh-session check** (written 2026-09-27; re-verify, since files and line numbers may have changed since)
>
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

- [ ] Clear `resisted_school` (set to none, `-1`) in every **regular enemy**
      `.tres`, in every chapter (read each file, not a sample). Today that's
      chap1 enemy_01 to enemy_05.
- [ ] **Bosses keep the mechanic**: their `.tres` may set a resisted school
      (× 0.5 damage and status via `SCHOOL_RESIST_MULT`; Void never). The
      code in `hurtbox_component.gd` / `enemy.gd` / `apply_school_perk()`
      stays as is.
- [ ] Each boss's resisted school follows the 09-00.5 answer to open
      question 2.
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
| Ancient (Nature) | ______ | ______ | ______ | to design |
| Frost | ______ | ______ | ______ | to design |
| Void | ______ | ______ | ______ | to design |
| Poison | ______ | ______ | ______ | to design |
| Fire | ______ | ______ | ______ | to design |

- [ ] Each ult is a small subclass that `extends` the base and overrides only
      its effect. Attached via `passive_script` or as a component in that
      tower's scenes.

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
- [ ] **[DECISION NEEDED]** Boss intro: camera zoom/pan, a "BOSS" banner, both,
      or none? Camera shake is on your "not wanted" list, so ask before
      touching `camera_rig.gd`.

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
> - **Do last**. It tunes everything above.
> - **Read**:
>   - `autoloads/Constants.gd` (`ENEMY_HP_SCALE`, `ENEMY_DMG_SCALE`,
>     `WAVE_BASIC_ENEMY_WEIGHT`, `WAVE_FAST_ENEMY_WEIGHT`).
>   - `spells.md` §6.4 (range ladder: 10 / 8 / 6.5 / 4 m).
>   - Every chapter `.tres`.

**Covers**: A7 · Do this **after** 09-03 → 09-16, since it tunes all of them.

- [ ] Write down the targets first, with you: rough run length, how often a
      fresh star-1 tower should clear chapter 1, and the step up per chapter.
- [ ] Per-chapter scaling lives on `ChapterDefinition` (e.g. HP/damage
      multipliers on top of `ENEMY_HP_SCALE`), so chapters differ by data.
- [ ] **Switch to 20 waves** (09-00.2) here at the latest, unless the user
      chose to switch earlier. Update together:
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
- [ ] **[DECISION NEEDED]** The known issue: short-range spells rarely fire
      because enemies die before closing to 6.5 / 4 m (`spells.md` §6.4).
      Options include spawning enemies further out, lowering long-range
      damage, raising lance/AoE ranges, or leaving it. Claude lists the
      options and you pick.
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
