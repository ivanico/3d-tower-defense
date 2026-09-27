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

### Where every `remaining_to_do_list.md` item lives

| Item | Task | Item | Task | Item | Task |
|---|---|---|---|---|---|
| A1 | 09-03, 09-04 | B1 | 10-04 | E1 | 11-00, 11-06 |
| A2 | 09-00, 09-05 | B2 | 10-03 | E2 | 11-02 |
| A3 | 09-06, 09-07 | B3 | 10-05 | E3 | 11-01 |
| A4 | 09-00, 09-08 | B4 | 10-00, 10-06 | E4 | 11-03, 11-04 |
| A5 | 09-09 | B5 | 10-07 | F1 | 13-01 |
| A6 | 09-10 | B6 | 10-08 | F2 | 13-02 |
| A7 | 09-17 | B7 | 10-09 | F3 | 13-04 |
| A8 | 09-16 | B8 | 10-10 | F4 | 13-03 |
| A9 | 09-13 | B9 | 10-11 | F5 | 13-05 |
| A10 | 09-14 | B10 | 10-00, 10-13 | F6 | **09-01** |
| A11 | 09-00, 09-15 | C1 | 12-01 | F7 | 13-06 |
| A12 | 09-12 | C2 | 12-04 | F8 | 12-02 |
| A13 | 09-00, 09-11 | C3 | 12-05 | F9 | 13-00, 13-07 |
| D1 | 10-12 | C4 | 12-06 | G1–G4 | 13-09 |
| D2 | 10-04, 12-07 | C5 | 12-03 | G5 | 13-10 |
| D3 | 13-08 | H1 | **09-02** | G6 | 13-00 |

---

## Task 09-00 — Decision Gate: Content [DECISION NEEDED]

**Covers**: A2, A4, A11, A13, plus the design inputs 09-12, 09-13 and 09-14 need.

Nothing gets built here. Claude asks, you answer, and the answers are written
into this task so the tasks below can cite them.

- [ ] **A2 — How does the player get tower #2+?** Options named in the list:
      materials / chapter reward / store (or a mix). Answer: ______
- [ ] **A4 — How many chapters at launch?** Chapter 2 has real models; any
      chapter beyond 2 reuses chap1/chap2 models until new ones exist (rule 1).
      Answer: ______
- [ ] **A11a — Should AoE Area and Lances stack?** (currently `stack_max = 1`,
      `spells.md` §6.6 "open design decision") If yes, what does a second pick
      do? Answer: ______
- [ ] **A11b — Fill the 5 empty grid spells?** (Fire/Frost chains,
      Void/Poison/Nature AoE Areas — `spells.md` §4 "Extend later by";
      models already exist.) Answer: ______
- [ ] **A13 — Every chapter-1 enemy resists Nature, and Ancient Tower is the
      Nature tower.** Intended, or a leftover default? If leftover, which
      schools should chapter 1 resist? (`spells.md` §3 suggests 2–3 different
      resisted schools per chapter.) Answer: ______
- [ ] **Tower passives (feeds 09-13)**: `project.md` defines only Ancient
      Tower's passive ("every 5th shot fires a 3-way burst"), written when the
      tower had a base attack. It now has no base attack, only drafted spells.
      Does "shot" mean every spell cast, one spell type, or something else?
      And what are the Frost and Void passives? What do star 3 and star 5
      add? Answer: ______
- [ ] **Spell rank behaviors (feeds 09-14)**: what does a rank add beyond
      numbers, per archetype or per spell? Nothing in the repo specifies it.
      Answer: ______
- [ ] **Second material (feeds 09-12)**: what does a chapter material buy
      that base material doesn't? Answer: ______

**Acceptance criteria**:
- [ ] Every blank above is filled, or explicitly marked "later" so the
      dependent task is skipped.

---

## Task 09-01 — Save Versioning & Migration (moved here from F6)

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
- [ ] Verify each claim against the code before writing it (memory: verify,
      don't generalize).

**Placeholders**: none · **Preview**: none.

**Acceptance criteria**:
- [ ] Each fix above cites the file and line it was checked against.

---

## Task 09-03 — Frost Tower & Void Tower (playable)

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
- [ ] Ownership follows A2 (task 09-05). Until then the towers exist as content
      (`unlocked = true`) but aren't owned, so the garage greys them out
      through the existing `TowerRegistry.is_playable()`. To play-test before
      09-05, add them to `owned_towers` in a throwaway headless script on a
      backed-up save.

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

## Task 09-04 — Extra Tower Slots Reuse Existing Models (only if 09-00 wants more than 3 towers)

**Covers**: A1 (beyond the 3 real models)

- [ ] Add `@export var preview_model_id: String = ""` to `TowerDefinition`.
      `TowerRegistry.get_preview_model()` uses it when set, instead of the
      tower's own ID. This is how a new tower borrows an existing tower line's
      `.glb` for the garage preview.
- [ ] Each extra tower gets its own `<id>_lvlN.tscn` gameplay scenes (09-03
      pattern) instancing a borrowed model. The real model arrives later as one
      `ext_resource` change per scene plus clearing `preview_model_id`.
- [ ] Slots not in the launch plan stay `tower_locked_0N.tres` ("Coming Soon").

**Placeholders**: borrowed tower model + tinted Ancient icon → final
`assets/models/towers/<id>/<id>_lvl1–5.glb` and `garage/icon_tower_<id>.png`.
**Preview**: same as 09-03.

**Acceptance criteria**:
- [ ] A borrowed-model tower is playable and previewable. Swapping the real
      `.glb` in touches no `.gd` file.

---

## Task 09-05 — Tower Unlock Method

**Covers**: A2 · **Blocked by**: 09-00 answer for A2.

- [ ] Implement whatever 09-00 decided, as **data on `TowerDefinition`**
      (e.g. an unlock cost/source field). The unlock flow reads it, so a new
      tower's unlock is a `.tres` edit.
- [ ] Garage: a not-owned but unlocked tower shows how to get it (cost / "Beat
      Chapter N" / "In Store") in the action bar, where Select/Upgrade are.
- [ ] Unlocking goes through `MetaManager` (one function, saves, emits an
      `EventBus` signal) and adds to `owned_towers`.
- [ ] If the answer involves the store, the store purchase calls this same
      `MetaManager` function (Epic 10/12). No second unlock path.
- [ ] New save fields (if any) → bump `SAVE_VERSION` + migration (09-01).

**Placeholders**: any lock/price badge art → drawn stand-in, final
`garage/ui_tower_unlock_badge.png` (only if you want art there).
**Preview**: `tower_garage_content.tscn` placeholder cells include one locked,
one unlockable, and one owned cell, so all three states show in the editor.

**Acceptance criteria**:
- [ ] A not-owned tower can be obtained by exactly the decided method, stays
      owned after restart, and can then be selected and played.

---

## Task 09-06 — Chapter Plumbing (arena per chapter, chapter registry)

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

**Covers**: A4 · **Blocked by**: 09-00 answer for A4.

- [ ] For each extra launch chapter: `scenes/game_object/chap<N>/…` folders built
      exactly like 09-07, but each enemy scene instances an **existing** chap1 or
      chap2 `.glb` (rule 1). Tell chapters apart by arena colours, stats,
      resist mix (09-11), and optionally a per-chapter `material_overlay` tint
      on reused models.
- [ ] Each chapter gets `chapter_0N.tres`, an arena copy with its own colours,
      and a lineup preview.
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

**Covers**: A6 · **Files**: `SaveData`, `MetaManager`, `victory_screen.gd`,
`ChapterDefinition`

- [ ] `SaveData.cleared_chapters: Array[String]` (+ `SAVE_VERSION` bump and
      migration). `MetaManager.mark_chapter_cleared(id)` is called on victory.
- [ ] `ChapterRegistry.is_unlocked(id)`: the first chapter is always open;
      chapter N+1 opens when N is cleared. The rule lives in one place.
- [ ] Victory screen shows "Chapter N+1 unlocked!" the first time only.

**Placeholders**: none (text).
**Preview**: `victory_screen.tscn` shows the unlock line in the editor
(placeholder text, hidden at runtime unless it applies).

**Acceptance criteria**:
- [ ] Fresh save: only chapter 1 playable. Beating it unlocks 2, and that
      survives a restart.

---

## Task 09-11 — Enemy Resistances Per Chapter

**Covers**: A13 · **Blocked by**: 09-00 answer for A13.

- [ ] Apply the answer to every enemy `.tres` in every chapter
      (`resisted_school`). Keep a per-chapter table in this task.
- [ ] Void can never be a resisted school (enforced by code already; don't
      set it).

**Placeholders**: none · **Preview**: none (data). Verified by reading every
enemy `.tres`, not a sample.

**Acceptance criteria**:
- [ ] The table in this task matches every enemy `.tres` on disk.

---

## Task 09-12 — Second Material Type Per Chapter

**Covers**: A12 · **Blocked by**: 09-00 answer; `mechanics.md` §11 marks this
[LATER] "once there's a second chapter".

- [ ] Material defined as data (on `ChapterDefinition`: id, name, icon) and
      saved as a dict like `scroll_materials` (+ migration). No per-chapter
      code.
- [ ] Earned at the same checkpoint moments as base material
      (`MATERIAL_CHECKPOINT_*`); spent where 09-00 decided.
- [ ] Shown where it's spent, using the existing `cost_chip.set_balance()`
      pattern.

**Placeholders**: icon = `topbar/icon_currency_materials1.png` tinted per
chapter → final `rewards/icon_mat_chapter_<N>.png`.
**Preview**: the screen that spends it shows a chapter-material chip in its
editor layout.

**Acceptance criteria**:
- [ ] Clearing checkpoints in chapter 2 awards chapter-2 material, it
      persists, and it can be spent as decided.

---

## Task 09-13 — Tower Passives + Star 3 / Star 5 Enhancements

**Covers**: A9 · **Blocked by**: 09-00 passive answers ·
**Refs**: `mechanics.md` §11, `project.md` "Tower (v1)", `TowerDefinition.passive_script`
(exists, read by nothing)

- [ ] `scenes/component/tower_passive_component.gd`: a base component that
      listens to the tower's cast events and exposes hooks (`on_cast`,
      `on_star_changed`). It knows the current star from `MetaManager`.
- [ ] One small subclass per tower (`extends` the base, overrides only the
      hooks it needs). Wire it through `passive_script` or as a component
      child in each tower's scenes, whichever keeps `tower.gd` thin
      (godot3d-architecture).
- [ ] Star 3 / star 5 behavior is a flag or number the subclass reads, never
      a branch in `tower.gd`.
- [ ] Garage: the stats strip or a line under the name shows the passive and
      what star 3 / 5 adds.

**Placeholders**: passive icon → final `garage/icon_passive_<tower_id>.png`
(until then, text only). This replaces the "tower ability icon" that was
removed from the art list, so ask before adding art.
**Preview**: `tower_garage_content.tscn` shows the passive text line with
placeholder copy.

**Acceptance criteria**:
- [ ] Each tower's passive fires as specified in a run; star 3 / 5 visibly
      change it; no `if tower_id == …` anywhere.

---

## Task 09-14 — Spell Rank Behaviors

**Covers**: A10 · **Blocked by**: 09-00 rank answer · **Refs**: `mechanics.md` §11,
`spells.md` §5 archetype scripts

- [ ] Behaviors are data. Proposed shape, confirmed with you first: a
      per-archetype list of "at rank N, turn on X", read by that archetype's
      script, alongside the existing damage/cooldown scaling
      (`CombatUtils.calculate_rank_scaled_value`).
- [ ] Rank read at cast time from `MetaManager.spell_ranks`, never by
      mutating the `.tres` (skill: resource mutation footgun).
- [ ] Spell Codex row shows what the next rank unlocks.

**Placeholders**: none (text).
**Preview**: `spell_codex_content.tscn` placeholder rows show the "next rank
unlocks…" line.

**Acceptance criteria**:
- [ ] A spell at the unlocking rank shows the new behavior in a run; below
      that rank it doesn't.

---

## Task 09-15 — Spell Design Follow-ups

**Covers**: A11 · **Blocked by**: 09-00 answers A11a / A11b.

- [ ] **A11a**: if stacking was chosen, implement it in `aoe_area.gd` /
      `line_aoe_bolt` the way Bolt/Chain/Orb stacking works (`stack_count`),
      and raise `stack_max` in their `.tres`.
- [ ] **A11b**: if filling the grid was chosen, add the 5 spells as new `.tres`
      files on the **existing** archetype scenes and models (`chain_bolt`,
      `aoe_area`), with their school set. `SpellRegistry` picks them up with
      no code change. Update the `spells.md` §4 tables and count tracker.
      - Fire and Frost chains need no new scene.
      - Void, Poison and Nature AoE Areas reuse `aoe_area.gd`. They add a
        subclass only if they need a different drop path, the way Blizzard
        and Rain of Fire do.

**Placeholders**:
- `spells/fire/icon_spell_chain_fire.png` already exists.
- The other 4 new icons use the draft card's existing school-colour block
  fallback → final `spells/<school>/icon_spell_<spell_id>.png`.

**Preview**: `scratch_card_preview.tscn`-style card preview showing each new
card; `spell_codex_content.tscn` lists them.

**Acceptance criteria**:
- [ ] New spells are draftable, fire correctly, and stack per their
      `stack_max`.

---

## Task 09-16 — Boss Depth (phases + intro)

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

**Covers**: A7 · Do this **after** 09-03 → 09-16, since it tunes all of them.

- [ ] Write down the targets first, with you: rough run length, how often a
      fresh star-1 tower should clear chapter 1, and the step up per chapter.
- [ ] Per-chapter scaling lives on `ChapterDefinition` (e.g. HP/damage
      multipliers on top of `ENEMY_HP_SCALE`), so chapters differ by data.
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

- [ ] Fresh save (backed up first). Play chapter 1 → unlocks chapter 2 → play
      it → every launch chapter.
- [ ] Get tower #2 by the A2 method; play a run with each tower at star 1 and
      star 5.
- [ ] An old (pre-09-01) save loads with nothing lost.
- [ ] Open every preview scene added this epic and confirm it shows what its
      task says.
- [ ] Every placeholder added this epic is listed in `ui_assets.md` "STILL TO
      MAKE" (or the model swap tables in 09-04 / 09-08).
