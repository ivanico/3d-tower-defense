# UI Tuning Guide — change it yourself, no code

Every UI element in this project is built from a `@tool` script with **exported
knobs**. That means you open the scene in Godot, click the root node, and edit
numbers in the Inspector — and the viewport redraws immediately, without running
the game. Nothing here needs a programmer.

This file tells you **which file to open** and **which number to change**.

---

## The 30-second version

1. Open the **widget** scene (paths below), e.g.
   `scenes/ui/widget/currency_pill/currency_pill.tscn`.
2. Click the **root node** in the Scene dock (the top one, same name as the file).
3. The Inspector shows the knobs. Change one. The viewport updates live.
4. `Ctrl+S`.

Because every screen *instances* these widgets, editing the widget scene changes
**every screen at once**. That is the point — you should almost never edit a
widget's numbers on an individual screen.

---

## Screen by screen — every piece, where it is, how to change it

Three screens. Each table lists **every visible thing on it**, the exact file and
node, and what to change. Position is always the same answer — click the node and
drag it, or type numbers into **Layout → Transform** — so the "change it by"
column only mentions position when there is a catch.

Two rules that apply to all three:

- **Set the LOOK inside the widget's own scene, the CONTENT on the screen.** How
  big a currency pill is belongs in `currency_pill.tscn`; *which* currency it
  shows belongs in `top_bar.tscn`. Change the look on one screen and the screens
  drift apart.
- A node inside a **Container** cannot be dragged — Godot says *"Children of a
  container get their position and size determined only by their parent"*. Move
  the container instead. The tables below say which nodes those are.

---

### 1. Tower Garage — `scenes/ui/tower_garage.tscn`

Nothing on this screen is in a Container except `TowerGrid`, so everything else
drags freely.

| Component | Where it lives | How to change it |
|---|---|---|
| Background image | node `BG` · art `assets/ui/garage/bg_garage.png` | Swap `texture`. `stretch_mode` 6 = fill & crop, 5 = fit & letterbox, 1 = stretch |
| Energy + materials pills | node `TopBar` → widget `widget/top_bar/top_bar.tscn` | Which icon/amount: on `EnergyPill` / `MaterialsPill` inside `top_bar.tscn`. Size & shape: `widget/currency_pill/currency_pill.tscn` |
| The 3D tower model | node `Preview3D` → widget `widget/tower_preview_3d/` | Drag the **panel** here. The tower **inside** it is a camera: `look_height` (bigger = tower moves down) and `camera_distance` (bigger = tower looks smaller) on the widget root |
| lvl5 waterfalls | `scenes/game_object/tower/ancient_tower/ancient_tower_lvl5/ancient_tower_lvl5_fx.tscn` | Edit that scene — plane positions, sizes, and each `water_color`. The **gameplay tower and the garage preview both instance it**, so one edit changes both. `show_effects` on the preview root turns it off |
| Tower name text | node `NameLabel` | Drag it. `theme_override_font_sizes/font_size`, outline size and colours on the node |
| The five stars | node `StarRow` → widget `widget/star_row/` | Drag it. `star_size` on the node. Keep the node's width at `star_size × 5 + separation × 4` or they clip |
| Darker Level/ATK/HP band | node `StatsStrip` (a plain `Panel`) | Drag/resize it. Colour = its `theme_override_styles/panel` StyleBoxFlat |
| The three stat pills | nodes `StatsStrip/Level`, `/Atk`, `/Hp` → widget `widget/stat_pill/` | **Each drags independently.** Per pill: `title`, `title_color`, `icon`, `icon_scale`, `icon_rotation_deg`. Shared look (pill colour, corner radius, font sizes): `stat_pill.tscn` |
| Grid of tower icons | node `TowerGrid` (a `GridContainer`) | Drag the grid. **Cells can't be dragged** — spacing is `h_separation` / `v_separation`, count per row is `columns` |
| One grid cell | widget `widget/tower_slot/tower_slot.tscn` | `icon_fill` (how much of the cell the art fills), `star_size`, `star_margin_bottom`, `lock_fill`, `locked_brightness`, and the green selection ring: `ring_color`, `ring_width`, `ring_corner_radius` |
| Bottom light bar | node `ActionBar` (a plain `Panel`) | Drag/resize. Colour = its StyleBoxFlat |
| Green Upgrade button | node `ActionBar/UpgradeButton` | Drag/resize. Its four state colours are the `up_normal` / `up_pressed` / `up_disabled` StyleBoxFlats at the top of `tower_garage.tscn`. `Shine` is the gloss strip — move it with the button |
| Bottom nav bar | node `NavBar` → widget `widget/nav_bar/` | See the Nav bar section below |

**Why the grid looks empty in the editor — it isn't any more.** The scene carries
six placeholder cells so you can see and space the grid without running the game.
`tower_garage.gd` deletes them and builds the real ones from `TowerRegistry` at
runtime, so editing a placeholder individually is pointless — only `columns` and
the separations matter.

---

### 2. World Map — `scenes/ui/world_map.tscn`

The screen the game opens on.

| Component | Where it lives | How to change it |
|---|---|---|
| Background image | node `BG` · art `assets/ui/world_map/bg_worldmap.png` | Same as the garage: swap `texture`, `stretch_mode` controls fill vs fit |
| Energy + materials pills | node `TopBar` → widget `widget/top_bar/` | Identical to the garage — one widget, both screens |
| Chapter title text | node `TitleLabel` | Drag it. Font size / colours on the node. The **text** comes from the chapter `.tres`, not here |
| Chapter artwork | node `ChapterImage` → widget `widget/chapter_node/` | Drag/resize on this screen. The picture itself is `chapter_image` on the widget, fed from `resources/chapters/chapter_01.tres`. `locked` greys it out |
| "Not enough energy" message | node `OutOfEnergyLabel` | Drag it. Hidden until you press Play without energy; it shows for `OUT_OF_ENERGY_DISPLAY_SEC` in `world_map.gd` |
| Play button | node `PlayButton` → widget `widget/play_button/` | Position here; size and insides in `play_button.tscn` — `button_width`, `margin_h/top/bottom`, `play_font_size`, `cost_icon_size`. See its own section below, it has a warning |
| Bottom nav bar | node `NavBar` → widget `widget/nav_bar/` | See the Nav bar section below |

---

### 3. Spell Codex — `scenes/ui/spell_codex.tscn`

| Component | Where it lives | How to change it |
|---|---|---|
| Background image | node `BG` | Currently **borrows `assets/ui/garage/bg_garage.png`** — the codex has no art of its own yet (`bg_menu_generic.png` is still unmade) |
| Energy + materials pills | node `TopBar` → widget `widget/top_bar/` | Same widget again |
| Title text | node `TitleLabel` | Drag it, font size on the node |
| The scrolling list | nodes `ScrollContainer` → `SpellList` | Drag/resize the `ScrollContainer`. `SpellList` is a `VBoxContainer` — **rows can't be dragged**; the gap between them is its `separation`. `horizontal_scroll_mode` is 0 on purpose so a wide row can never make a sideways scrollbar |
| One spell row | widget `widget/meta_row/meta_row.tscn` | Edit the widget scene — row height, icon size, fonts, the panel behind it. **All 20 rows share it** |
| What a row says | `spell_codex.gd` | Rows are built in code from `SpellRegistry`, and each icon resolves by naming convention. Adding a spell `.tres` adds a row with no scene edit |
| Bottom nav bar | node `NavBar` → widget `widget/nav_bar/` | See the Nav bar section below |

---

### If you get "Failed to load script … Compilation failed"

Nothing is broken. `game_state.gd` and other autoloads use `class_name`, which
resolves only through `.godot/global_script_class_cache.cfg`, and **only the editor
rebuilds that file**. Editing project files while the editor is open can leave it
stale, and then every script that touches those classes fails to parse at once.
**Fix: reload the project in Godot** (Project → Reload Current Project). See
`components.md` → "`class_name` is not safe to depend on".

---

## Three rules that will save you pain

**1. Tune in the WIDGET scene, not on the instance in a screen.**
If you select `TopBar/EnergyPill` inside `world_map.tscn` and change `icon_size`
there, you have made an *override* that applies only to that screen, and the
other screens drift out of sync. Open `currency_pill.tscn` instead.
The exception is genuinely per-instance data: which `icon` a pill shows, which
`selected` entry the nav bar highlights, the `icon_scale` correction for one
specific piece of art.

**2. Close `scenes/main/game_world.tscn` in the editor before anyone edits it
outside the editor.** Godot writes its whole in-memory copy on save, so an open
scene silently overwrites changes made to the file on disk.

**3. Position and size come from the SCREEN; look and internals come from the
WIDGET.** Where the Play button sits on the world map is `world_map.tscn`'s
offsets. How big the Play button is and what is inside it is
`play_button.tscn`'s knobs.

---

## File map — "I want to change X, which file?"

### Screens

The three menu screens are broken down piece by piece above. The rest:

| What you see | Scene | Script |
|---|---|---|
| Victory screen | `scenes/ui/victory_screen.tscn` | `scenes/ui/victory_screen.gd` |
| Defeat screen | `scenes/ui/defeat_screen.tscn` | `scenes/ui/defeat_screen.gd` |
| In-run HUD (pause, wave, Lv bar) | `scenes/main/game_world.tscn` → `HUD` node | `scenes/main/hud.gd` |
| Draft card popup | `scenes/ui/draft_ui.tscn`, `scenes/ui/draft_card.tscn` | `scenes/ui/draft_card.gd` |
| Synergy banner / tag row | `scenes/ui/synergy_banner.tscn`, `scenes/ui/tag_row_widget.tscn` | — |

### Widgets (the reusable pieces)

| Widget | Folder |
|---|---|
| Currency pill (icon + amount) | `scenes/ui/widget/currency_pill/` |
| Stat pill (garage LEVEL / ATK / HP) | `scenes/ui/widget/stat_pill/` |
| ↳ shape both pills share | `scenes/ui/widget/pill_base.gd` |
| Top bar (holds two pills) | `scenes/ui/widget/top_bar/` |
| Nav bar (bottom 3 buttons) | `scenes/ui/widget/nav_bar/` |
| Nav button (one entry: icon, label, badge) | `scenes/ui/widget/nav_button/` |
| Play button | `scenes/ui/widget/play_button/` |
| Chapter artwork | `scenes/ui/widget/chapter_node/` |
| Pause button | `scenes/ui/widget/pause_button/` |
| HP / XP bar (2D, in the HUD) | `scenes/ui/widget/hp_bar/`, `scenes/ui/widget/xp_bar/` |
| ↳ their shared script | `scenes/ui/widget/value_bar.gd` |
| Floating HP bar over the tower (3D) | `scenes/ui/widget/value_bar_3d/` |
| ↳ shared bar drawing code | `scenes/ui/widget/bar_texture.gd` |
| ↳ shared number/text renderer (also used by damage numbers) | `scenes/ui/widget/outlined_label_3d/` |
| Floating damage numbers (3D, Epic 08) | `scenes/ui/widget/damage_number_3d/` |
| Star row (garage) | `scenes/ui/widget/star_row/` |
| Tower grid cell (garage) | `scenes/ui/widget/tower_slot/` |
| ↳ its desaturate shader | `scenes/ui/widget/tower_slot/greyscale.gdshader` |
| 3D tower preview (garage) | `scenes/ui/widget/tower_preview_3d/` |
| Meta row (codex list rows) | `scenes/ui/widget/meta_row/` |
| Primary / secondary buttons | `scenes/ui/widget/primary_button/`, `secondary_button/` |
| Spell/upgrade icon (rounded mask + school-color fallback) | `scenes/ui/widget/spell_icon/` |
| Spell rank pips (diamond row, draft card + HUD row) | `scenes/ui/widget/spell_rank_pips/` |
| HUD spell-stack row (icon + pick-count per active spell, replaces the OFF/ARM/UTL tag row — Draft Card polish follow-up) | `scenes/ui/widget/spell_stack_row/` |

### Art

All UI art is under `assets/ui/<folder>/`. The full inventory and what is still
unmade is in **`ui_assets.md`**. Theme (base font size, label colour/outline) is
`resources/theme/ui_theme.tres`, applied to every Control in the game.

---

## Every knob, widget by widget

Values in brackets are the current defaults.

### Currency pill — `scenes/ui/widget/currency_pill/currency_pill.tscn`

The dark pill with the amount, and the icon sitting on its left end, overhanging
it top and bottom.

| Knob | What it does |
|---|---|
| `pill_size` `[190, 90]` | Size of the dark pill. Height here is the pill only, not the icon. |
| `icon_size` `[124]` | The icon's layout slot. Keep it bigger than `pill_size.y` — the overhang is the look. |
| `icon_scale` `[1.0]` | Fine-tune how big the ART reads without moving the pill. **See "icons are not the size you think" below — this is the one you usually want.** |
| `icon_offset` `[0, 0]` | Free nudge in pixels. +x right, +y **down**. For art that is not centred in its own canvas. |
| `icon_overlap` `[62]` | How many pixels of the icon sit on the pill. Bigger = icon further right / more overlap. |
| `icon_rotation_deg` `[0]` | Tilts the icon about its own centre. Layout is unaffected. |
| `font_size` `[40]` | Size of the amount text. |
| `icon`, `amount` | Per-instance. Set in `top_bar.tscn`, not here. |

Everything above `font_size` actually lives in **`scenes/ui/widget/pill_base.gd`**,
shared with the garage's `stat_pill` — the two widgets are the same shape with
different contents, so tuning the geometry is one place, not two.

(A `text_gap` knob used to be listed here. It set `margin_left`/`margin_right`
theme constants, which a `PanelContainer` does not read, so it had never done
anything and has been removed. `stat_pill` has a real one.)

### Stat pill (garage LEVEL / ATK / HP) — `scenes/ui/widget/stat_pill/stat_pill.tscn`

Same shape as the currency pill — icon standing proud of a pill's left end — with
a title above it and the next-star gain in green beside the value. **The pill is a
`StyleBoxFlat` drawn in code, not artwork**, so there is no PNG to keep in step
with the palette.

Shares every geometry knob above via `pill_base.gd`, plus:

| Knob | What it does |
|---|---|
| `title`, `value_text`, `delta_text` | Per-instance. The garage drives the last two at runtime; empty `delta_text` hides the gain, which is what a maxed stat wants. |
| `pill_color` `[#1a0d2e8c]`, `corner_radius` `[10]` | The pill. Softly rounded, NOT a capsule — half the pill height would make it one. |
| `title_height` `[25]`, `title_font_size` `[20]`, `title_color` | The label above the pill, left-aligned with the value so the two share an edge just clear of the icon. `title_height` is also the extra height it adds to the widget. `title_color` is per-instance — the garage tints Level blue, ATK yellow, HP pink, as in the reference. |
| `value_font_size` `[30]` | The number. |
| `delta_font_size` `[24]`, `delta_color` `[#59eb66]` | The green gain. |
| `text_gap` `[8]` | Space between the overhanging icon and the value. Applied as the pill StyleBox's left content margin — the thing that actually works. |

The garage sets only `icon`, `title` and — on ATK — `icon_rotation_deg = 45` and
`icon_scale = 1.3`, because the sword fills 39% × 88% of its canvas against the
heart's 75% × 70% and reads far smaller at the same box size.

### Top bar — `scenes/ui/widget/top_bar/top_bar.tscn`

Holds the two pills. This is where you say *which* currency each pill shows.
`separation` `[40]` is the gap between them. Its height (124) is the **icon's**
height, not the pill's.

### Nav bar — `scenes/ui/widget/nav_bar/nav_bar.tscn`

Order is **Garage · Worldmap · Codex** — worldmap in the middle on purpose,
because it is the screen the game opens on.

Three square-cornered tiles sit flush against each other and fill the bar's whole
width, over a dark frame. The one you are on is wider, shaded tan instead of grey,
and shows its name. **No artwork is involved** except the three icons.

The tiles always add up to exactly the bar's inner width, so `selected_extra_width`
only *redistributes* space; it never leaves a seam or overflows.

**Each tile is shaded in two bands**, which is what stops it looking like a flat
slab: a gradient from `*_color_top` down to `*_color_split`, ending at `*_split`
of the height, then a flat `*_color_bottom` below that. Set `*_split` to `1.0` and
you get one continuous fade the whole way down with no second band — that is what
the selected tile does. On top of both sits `highlight_height` pixels of
`*_highlight_color`: the thin bright line that makes the tile read as shiny.

Every default below was **sampled off the reference art**, not guessed.

| Knob | What it does |
|---|---|
| `selected` | Which entry is highlighted. **Set per screen**, not here. |
| `animation_time` `[0.18]` | Seconds the grow/cross-fade takes. `0` disables it. |
| **Frame** | |
| `bar_color` `[#272923]` | The dark strip. Seen only as the border around the tiles. |
| `frame_side` `[0]` / `frame_top` `[2]` / `frame_bottom` `[13]` | How much of it shows on each edge. Three knobs because the bar runs **edge to edge** (no left/right border) while the bottom border is far thicker than the top. |
| **Tile shading — unselected** | |
| `tile_color_top` `[#ddd9cf]` | Top of the gradient band. |
| `tile_color_split` `[#eae8db]` | Bottom of the gradient band. |
| `tile_color_bottom` `[#dedbd4]` | The flat lower band — the second tone. |
| `tile_split` `[0.52]` | Where the gradient ends and the flat band starts. |
| `tile_highlight_color` `[#f8f8f4]` | The bright top line. **This is the shine.** |
| **Tile shading — selected** | |
| `selected_color_top` `[#c5966e]` | Darkest, at the top. |
| `selected_color_split` `[#edd3b8]` | Lightest, at the bottom. |
| `selected_color_bottom` `[#edd3b8]` | Unused while `selected_split` is 1.0. |
| `selected_split` `[1.0]` | 1.0 = **one continuous fade**, no second band. |
| `selected_highlight_color` `[#e2c1a6]` | Its top line is tinted, not white. |
| **Tiles** | |
| `highlight_height` `[4]` | Thickness of the bright top line, both looks. |
| `divider_width` `[3]` / `divider_color` `[#272923]` | The seam. Its own strip at each INTERNAL boundary (two of them for three entries), so this is the exact width you see and the outer sides of the bar stay clean. `0` removes the seams. |
| `selected_extra_width` `[90]` | How many pixels wider the selected tile is. |
| `selected_rise` `[0]` | How far the selected tile pokes above the others. |
| `row_offset` `[0, 0]` | Free nudge for the whole row. +y moves down. |
| **Icons** | |
| `normal_icon_size` `[104]` / `selected_icon_size` `[124]` | Icon edge length, unselected / selected. |
| `icon_offset` `[0, 0]` | Free nudge for every icon. +y down. |
| **Labels** | |
| `label_on_selected_only` `[on]` | Reference behaviour. Turn off to name all three. |
| `label_font_size` `[34]`, `label_gap` `[4]`, `label_offset` `[0, 0]` | Size, distance below the icon, free nudge. |
| `label_color` `[#4a4038]` / `label_color_selected` `[#4a3627]` | Both dark — **both tiles are light.** |

There is **no corner-radius knob**: the reference's tiles are square, so the
rounding was removed rather than left in at 0.

Per-entry settings live on the buttons *inside* `nav_bar.tscn` — select
`GarageButton` / `WorldmapButton` / `CodexButton` and set `icon_texture`
(files are in `assets/ui/nav/`) and `label_text`. Each also has an optional
badge: `badge_visible`, `badge_text`, `badge_size` `[52]`,
`badge_anchor` `[1, 0]` (a fraction — `(0,0)` top-left, `(1,0)` top-right) and
`badge_offset`.

⚠️ Don't set colours or sizes on an individual `NavButton` — `nav_bar.gd` pushes
the same values into all three every time it lays out, so anything you set there
is overwritten. Tune on the **NavBar root**.

**The transition and scene changes.** Each screen is its own scene, so tapping an
entry would normally swap scenes on the next frame and you would never see the
animation. The screens therefore call `nav_bar.navigate_to(target, scene_path)`,
which selects, waits `animation_time`, then changes scene. If you set
`animation_time` to 0 the wait disappears too — navigation stays instant.

### Tower grid cell — `scenes/ui/widget/tower_slot/tower_slot.tscn`

One cell of the garage grid. The garage fills these from `TowerRegistry`, so
nothing is set per tower in a scene.

| Knob | What it does |
|---|---|
| `locked` / `selected` / `stars` | Set by the garage at runtime; set them here only to preview a look. |
| `plate_color` `[transparent]`, `border_color` `[transparent]`, `border_width` `[4]`, `corner_radius` `[18]` | The unselected plate. **Both colours default to fully transparent**: the reference shows the artwork alone, not an icon floating on a card. Give `plate_color` an alpha to bring the card back. |
| `ring_color` `[#4ee34e]`, `ring_width` `[6]`, `ring_inset` `[0.05]`, `ring_corner_radius` `[0.19]` | The selection highlight, and the **only** thing marking the pick. Drawn on its own node sized to the ARTWORK, not the cell — `icon_tower_ancient.png` is already a finished card (stone-and-gold frame, teal backdrop) whose opaque pixels stop ~5% short of the PNG edge, so a border on the Button's rect floated a dozen pixels outside the frame the art already had. `ring_inset` is what lands it on that frame. `ring_corner_radius` is a FRACTION of the ring's width, not pixels — the card art is rounded at 19% of its width (measured off the alpha), so a fixed pixel value looked square against it and stopped matching whenever the grid resized cells. |
| `border_color_selected` `[#ffc94a]`, `border_width_selected` `[4]` | Legacy plate border. Unused while the plate is transparent — the ring above replaced it. |
| `icon_fill` `[1.0]` | Icon size as a fraction of the cell's shorter side, so it survives the grid resizing cells. 1.0 because the art fills the cell instead of sitting on a plate. |

Cells are **square and derived**: `tower_garage.gd`'s `_cell_size()` divides the
grid's width by its `columns` and `h_separation`, so changing the column count in
`tower_garage.tscn` (currently **4**, tightly spaced) needs no code edit and the
two can never drift apart.
| `icon_offset` `[0, 0]` | Free nudge. +y down. |
| `lock_fill` `[0.52]` | Padlock size, as a fraction of the icon. |
| `star_size` `[26]`, `star_margin_bottom` `[14]` | The little star row along the bottom. |
| `locked_brightness` `[0.75]` | How much the greyed-out art is darkened. 1.0 = grey but same brightness. |

**Locked cells are desaturated by a shader, not by a second grey copy of the
art.** `modulate` can only tint or darken — it cannot remove hue — so
`greyscale.gdshader` does it. That means you never have to draw a grey version of
any tower icon.

### 3D tower preview — `scenes/ui/widget/tower_preview_3d/tower_preview_3d.tscn`

Renders the tower model into a `SubViewport` with `own_world_3d` and a
transparent background, so it has its own lighting and the garage background
shows through.

#### Moving the tower

**Click the root node of this scene and change these two numbers:**

- **`look_height`** — moves the tower UP or DOWN. Bigger = further down.
  `0.0` puts the base on the name label. Try `-0.15` to lift it, `0.15` to drop it.
- **`camera_distance`** — makes the tower BIGGER or SMALLER. Bigger number =
  smaller tower. `3.9` now; `3.5` is noticeably bigger, `4.4` noticeably smaller.

**One camera serves every tower at every star level.** There is no per-tower
framing and nothing is measured at runtime: all five `ancient_tower` glb files are
exported into the same normalised box (y −0.957 to +0.953, identical to four
decimals), so a single camera puts every one of them in the same place. Change
these two numbers and all five move together.

The widget used to auto-frame from each model's bounding box. That is gone. Since
every box is identical it could never do anything useful, and it produced towers
sitting at five different heights.

| Knob | What it does |
|---|---|
| `tower_id`, `star` | Which model. The garage sets these; change them here to preview. |
| **`camera_distance`** `[3.9]` | **How big the tower looks. Bigger number = smaller tower.** |
| **`look_height`** `[0.0]` | **Where the tower sits vertically. Bigger number = tower moves DOWN.** |
| `camera_pitch_deg` `[14]`, `camera_fov` `[40]` | Tilt and lens. |
| `model_yaw_deg` `[25]` | Turntable angle. Matches the angle the gameplay scene stands the tower at. |
| `spin_speed_deg` `[0]` | Degrees per second of idle spin. 0 = still. |
| `show_effects` `[on]` | Adds the star level's `_fx` decoration scene when one exists — currently the lvl5 waterfalls. Found by convention at `scenes/game_object/tower/<id>/<id>_lvl<star>/<id>_lvl<star>_fx.tscn`; a level without one gets nothing, no configuration needed. Turn it off for the bare model. |
| `play_idle` `[on]` | Plays the `.glb`'s own `idle` clip when it has one. lvl3–5 do; lvl1 and lvl2 have none and stand still. glTF does not carry a loop flag, so the clip is set to `LOOP_LINEAR` in code or it plays once and freezes. **Speed is not a knob here** — it uses `Constants.TOWER_IDLE_ANIM_SPEED_SCALE` (`1/3`), the same value `tower.gd` plays it at in game, so the preview and the run can't drift apart. Change the speed in `Constants.gd` and both follow. |
| `model_y_offset` `[0]`, `model_scale` `[1.0]` | Nudge and resize inside the frame. |
| `key_energy` `[1.9]`, `key_color`, `key_yaw_deg` `[-40]`, `key_pitch_deg` `[-45]` | Main light. |
| `fill_energy` `[0.8]`, `fill_color` | Second light from the opposite side, so the shadowed half is not black. |
| `ambient_energy` `[0.45]`, `ambient_color` | Overall lift. |

⚠️ Its `Environment.background_mode` must stay **0 (BG_CLEAR_COLOR)**. It was set to
4 (BG_KEEP), which tells the renderer not to clear the target between frames — on a
`transparent_bg` SubViewport that leaves uninitialised GPU memory on screen, and the
garage showed a rectangle of coloured static behind the tower. BG_CLEAR_COLOR still
honours `transparent_bg`, so the background art shows through as intended.

⚠️ **Decoration cannot come from the tower's gameplay scene.** The lvl5 waterfalls
used to be seven inline `MeshInstance3D`s inside `ancient_tower_lvl5.tscn`, and
instancing that scene here would call `tower.gd._ready()` → `GameState.start_run()`
and begin a run. They now live in `ancient_tower_lvl5_fx.tscn`, which the gameplay
tower and this preview both instance — one copy of the effect, no duplication.
Splitting them out also collapsed 6 PlaneMesh sub-resources to 4 and 7 materials
to 6 (duplicates), and set `cast_shadow = 0` on every plane: they are `unshaded`
`blend_mix` quads, so a shadow pass over them was pure waste in gameplay too.

⚠️ This shows the raw `.glb`, found by convention at
`assets/models/towers/<tower_id>/<tower_id>_lvl<star>.glb`. It must **never**
instance the tower's `star_level_scenes` — those are gameplay scenes, and
`tower.gd._ready()` calls `GameState.start_run()`, so putting one on the garage
screen would start a run.

### Play button — `scenes/ui/widget/play_button/play_button.tscn`

| Knob | What it does |
|---|---|
| `button_width` `[600]` | On-screen width. **This is the size knob.** |
| `button_height` `[260]` | Recomputed from width while `lock_aspect` is on. |
| `lock_aspect` `[on]` | Keeps the art's 2.31 ratio. **Turning this off visibly distorts the gold frame.** |
| `margin_h` `[0.09]` | Left/right inset to the art's blue interior, as a fraction. |
| `margin_top` `[0.19]` | Top inset. Measured off the art, not guessed. |
| `margin_bottom` `[0.25]` | Bottom inset. Too small and the text runs onto the gold frame. |
| `line_gap` `[0]` | Space between the PLAY line and the cost line. |
| `content_offset` `[0, 0]` | Free nudge for both lines together. +y down. |
| `play_text` `["PLAY"]`, `play_font_size` `[58]` | Top line. |
| `cost_icon`, `cost_amount`, `cost_font_size` `[40]`, `cost_icon_size` `[72]` | Bottom line. `cost_amount` is overwritten at runtime from `Constants.ENERGY_COST_PER_RUN`. |

⚠️ The art's blue interior is only ~57% of the button's height, so the two lines
have roughly 145px on a 260px button. **`play_font_size` and `cost_icon_size`
cannot both be large** — if you raise one, lower the other or the content pushes
onto the frame.

### Pause button — `scenes/ui/widget/pause_button/pause_button.tscn`

Entirely drawn, no art file. `button_size` `[96,96]`, `panel_color`,
`corner_radius` `[24]`, `border_color`, `border_width` `[2]`, `pressed_dim`
`[0.25]`, `glyph_color`, `glyph_bar_size` `[14,42]`, `glyph_gap` `[14]`,
`glyph_corner_radius` `[4]`. Keep it at or above 80×80 for touch.

### HUD Lv/XP bar — `scenes/ui/widget/xp_bar/xp_bar.tscn`

Shares `value_bar.gd` with `hp_bar`. Three layers: dark track, coloured fill,
outline.

| Knob | What it does |
|---|---|
| `bar_size` `[740, 52]` | Exact on-screen pixels. The capsule is redrawn at this size. |
| `color_top` / `color_bottom` | Fill gradient. |
| `track_color_top` / `_bottom` | The empty part behind the fill. |
| `rim_color` / `rim_width` `[3]` | The outline. Alpha 0 hides it without losing the width. |
| `corner_radius` `[10]` | 0 = square, half the height = full capsule. |

**Never set `scale` on these bars.** Scaling non-uniformly flattens the round end
caps into ovals — change `bar_size` instead. A partly-full bar has a flat right
edge; that is correct and matches the reference art.

### Floating HP bar over the tower — `scenes/ui/widget/value_bar_3d/value_bar_3d.tscn`

Tune it **here** and all five tower star-levels update at once.

| Knob | What it does |
|---|---|
| `bar_size` `[480, 68]` | Texture resolution, **not** screen size. |
| `pixel_size` `[0.003]` | World units per texture pixel. **This is the on-screen size knob.** |
| `height_offset` `[2.8]` | How high it floats above the tower. Per-instance — enemy/boss/tower scenes each set their own (see below), never `style`. |
| `rim_width` `[7]` | The outline. See the sub-pixel warning below. |
| `corner_radius` `[12]`, colours, `track_*` | Same meaning as the 2D bar. |
| `show_value`, `value_font_size` `[80]` | The number on the bar. |
| `value_raise` `[0.5]` | In bar heights: 0 centres the number on the bar, 0.5 centres it on the top edge, 1.0 clears the bar. |
| `value_outline_color` `[black]`, `value_outline_thickness` `[0.09]` | The ring drawn around the number. Thickness is a fraction of `value_font_size`. Alpha 0 turns the outline off. |
| `value_shadow_color` `[black, 60% alpha]`, `value_shadow_offset` `[0.19]` | Drop shadow beneath the number, matching the 2D HUD's "Lv.X" look. Offset is a fraction of `value_font_size`. Alpha 0 turns the shadow off. |
| `always_on_top` `[off]` | Draw through geometry. Only if the bar gets clipped. |
| `editor_preview_fill` `[0.7]` | **Editor only.** Lets you judge a part-full bar without running the game. |
| `follow_game_state` `[on]` | Tracks the tower's HP by itself. Enemies set this off and call `set_hp()`. |

**`height_offset` is the one knob NOT shared here** — each enemy/boss/tower
scene's own `HealthBar3D` node sets it individually (it depends on that
unit's own model height), so raising/lowering the bar for one enemy type
means opening that unit's own scene, not this one. Everything else in the
table above IS shared from this one file, same as the rest of this section.

### Outlined 3D label — `scenes/ui/widget/outlined_label_3d/outlined_label_3d.tscn`

The actual text/outline/shadow renderer behind the HP bar's number above
**and** the floating damage numbers below — one place, so they can never
drift apart. You will rarely open this file directly; `value_bar_3d.tscn`
and `damage_number_3d.tscn` each expose their own `value_*` / plain-named
passthrough knobs that forward into it. Open it directly only if you want a
third consumer, or to change the underlying mechanism itself.

| Knob | What it does |
|---|---|
| `font` | The typeface. Swap this to give one consumer a different font without touching the others. |
| `font_size`, `text_color` | The main number/text. |
| `outline_color`, `outline_thickness` | Same outline mechanism as the HP bar's `value_outline_*`. |
| `shadow_color`, `shadow_offset` | Same shadow mechanism as the HP bar's `value_shadow_*`. |
| `opacity` | Fades text + outline + shadow together. Used by `damage_number_3d.gd`'s despawn tween — `Node3D` has no native `modulate` to animate instead. |
| `base_render_priority` | Layering against other billboards it's stacked with (e.g. the HP bar's Track/Fill). Leave at `0` for a standalone label. |

### Floating damage numbers — `scenes/ui/widget/damage_number_3d/damage_number_3d.tscn`

Pops up over an enemy when it's hit (Epic 08 Task 08-01). Pooled via
`ObjectPool`, one `OutlinedLabel3D` inside for the shadow+outline look.

| Knob | What it does |
|---|---|
| `font_size` `[140]` | **Size of the number.** World size is `font_size × pixel_size` — went 48 → 64 → 140 to actually read at a glance in gameplay. |
| `pixel_size` `[0.003]` | The other half of that equation. Raise this instead of `font_size` for a bigger number that's just as crisp. |
| `always_on_top` `[off]` | Draw through geometry, if a number clips behind a model at some camera angles. |

Everything else (rise height/duration, fade timing, crit scale, spawn
scatter, the pool size, the 10-visible cap) is in `autoloads/constants.gd`
under **"Floating damage numbers (Epic 08 Task 08-01)"** — not exported
knobs, since they're gameplay tuning rather than a look, matching how
`Constants.gd` holds every other numeric-tuning value in the project (see
that file's own header comment). Color comes from `Constants.SCHOOL_COLORS`,
the same table the school orbs/tints already use — not a knob here either.

---

## Recipes

**Make an icon bigger or smaller** → `icon_scale` on `currency_pill`, or
`cost_icon_size` on `play_button`, or `normal_icon_size` / `selected_icon_size`
on `nav_bar`.

**Move an icon a few pixels** → `icon_offset` on `currency_pill`,
`content_offset` on `play_button`, `icon_offset` (icons only) or `row_offset`
(whole tile row) on `nav_bar`.

**Move a whole element on a screen** → open the screen scene, select the node,
change its Layout → Transform → Position (or the offsets). E.g. the Play button's
place on the world map is `world_map.tscn` → `PlayButton` offsets.

**Make the selected nav entry stand out more** → raise `selected_extra_width`
and `selected_icon_size`, push `tile_color_selected` further from `tile_color`,
and/or set `selected_rise` so the tile pokes above the strip.

**Recolour the nav bar** → `nav_bar.tscn` root. The two "Tile shading" groups are
the tiles themselves; `bar_color` is the frame around them. No art to repaint.

**Make a nav tile look flat / look more shaded** → move `tile_color_top` and
`tile_color_split` closer together or further apart. Setting `tile_split` to `1.0`
removes the second tone entirely.

**Change the Lv bar's colours** → `xp_bar.tscn` → `color_top` / `color_bottom`.

**Make a bar's outline thicker** → `rim_width`. For the 3D bar read the sub-pixel
warning first.

**Make the HP bar's number bigger, or add/remove its shadow/outline** →
`value_font_size` / `value_outline_*` / `value_shadow_*` on
`value_bar_3d.tscn`. Alpha 0 on either colour turns that effect off.

**Make the damage numbers bigger** → `font_size` (or `pixel_size` for the
same effect) on `damage_number_3d.tscn`. Everything about their timing
(rise, fade, crit scale) is in `Constants.gd`, not here — see the widget's
own section above.

**Swap a piece of art** → each texture is referenced in exactly ONE widget scene,
so change it there and it updates everywhere. `ui_assets.md` lists what exists.

**Change all body text at once** → `resources/theme/ui_theme.tres`
(`default_font_size`, label colour, outline). Do *not* add per-node font
overrides for ordinary text.

---

## Gotchas that will otherwise waste your time

### UI image imports are size-capped — and a plugin keeps them that way

Every UI icon is authored at ~1254x1254 but never shown above ~124px, so each one
imports at `process/size_limit=256`. The source PNGs are untouched; only the
imported copy is downsampled.

This is not cosmetic. At full size, loading the codex's 20 spell icons cost
**411ms every time you opened the screen**. Measured, whole-screen, cold:

| Screen | Before | After |
|---|---|---|
| Spell codex | 670ms | 113ms |
| Tower garage | 228ms | 109ms |
| World map | 282ms | 185ms |

**You do not have to remember to set this, and it's not just icons.**
`addons/ui_icon_cap/` is an editor plugin that re-applies a size cap to
*everything* under `assets/ui/` every time the filesystem changes — no image
category ships at full native resolution. `size_limit` lives in a per-file
`.import`, and Godot writes a fresh one with `size_limit=0` whenever an image is
added or replaced — so **delete an image, drop a new one in with the same name,
and the cap comes back by itself**. That is exactly how `ui_star_filled`,
`ui_star_empty`, `ui_notification_badge` and `icon_stat_level` once shipped at
full size.

The cap size depends on the filename, via the ordered `SIZE_RULES` table at the
top of `addons/ui_icon_cap/plugin.gd` — first matching prefix wins:

| Category | Prefixes | Cap |
|---|---|---|
| Panels | `ui_panel` | 1536 |
| Buttons / pills | `ui_button`, `ui_play_button`, `ui_topbar_pill_bg` | 768 |
| Cards / frames | `ui_card_bg`, `ui_chapter_node_frame` | 512 |
| Full-screen backgrounds | `bg_`, `chapter_` | 1920 |
| Everything else (icons, and any new/unrecognized art) | — | 256 (`DEFAULT_SIZE_LIMIT`) |

New art you've never named before (e.g. a future `store_` screen) automatically
falls into the 256 default instead of shipping uncapped — nothing needs to be
added for it to be safe. If a specific new image looks soft because it's
genuinely meant to be drawn large, add its prefix to `SIZE_RULES` (or widen an
existing entry) — that's the only manual step this system ever needs.

**The same plugin also forces `mipmaps/generate=true` on every image it caps.**
Godot's importer defaults this to `false`, and every image here is by
definition displayed smaller than its imported size (that's the whole point of
the cap above) — downscaling detailed art with no mip chain is a GPU
minification-aliasing bug, not cosmetic softness: fine detail (outlines, small
highlights, texture) turns to visible noise. Same non-destructive mechanism as
the size cap: only the `.import` is touched, and it re-applies on every
filesystem change so a replaced file can't silently lose it either.

**Generating the mipmaps is not enough on its own — Godot also has to be told
to sample them.** A `CanvasItem`'s `texture_filter` defaults to
`TEXTURE_FILTER_PARENT_NODE`, which resolves to the project-wide
`rendering/textures/canvas_textures/default_texture_filter` setting in
`project.godot`. That setting has its own separate default (`1` = plain
`Linear`), which ignores mip levels entirely regardless of whether the
imported texture has them. So mipmaps existed but were never actually used
until this was also set to `2` (`Linear With Mipmaps`) in `project.godot`'s
`[rendering]` section — that's the line that actually fixed the visible
noise on detailed icons (e.g. the nav bar's map icon — dotted path, compass
rose, paper grain — which looked noisier up close than simpler reference art
even though the source PNG itself was fine at full resolution). The nav tile
background (`nav_button.gd`'s `_make_background()`) explicitly overrides
`texture_filter` to `NEAREST` per-node for an unrelated, intentional reason
(see its comment) — that override is unaffected by the project default.

⚠️ **If you add art that is drawn big, add its prefix to that list**, or the
plugin will downsample it. `ui_chapter_node_frame` is on the list because the
world map draws it at 760px.

### Icons are not the size you think

Every icon PNG is 1254×1254 at source, but the **artwork inside fills wildly different
fractions of that canvas**. Two icons at the same node size therefore do *not*
look the same size. Measured:

| Icon | Art size | Fills (w × h) |
|---|---|---|
| `icon_currency_energy1.png` | 595 × 840 | 47.4% × **67.0%** |
| `icon_currency_materials.png` | 720 × 705 | 57.4% × 56.2% |
| `icon_currency_materials1.png` | 1042 × 1018 | **83.1% × 81.2%** |

That is what `icon_scale` is for. The top bar sets the materials pill to
`icon_scale = 0.82` so the gem's drawn height (0.812 × 0.82 × 124 = 83px) matches
the bolt's (0.670 × 124 = 83px). **Check the fill before blaming the node size.**

### Thin outlines vanish or go lopsided

An outline is only as good as the pixels it lands on. The floating HP bar is
~10px tall on screen, so `rim_width / bar_size.y` decides everything:

- `7` → 1.02px → clean 1px line all round ✔ (current)
- `10` → 1.47px → sits exactly on the rounding boundary and comes out **1px
  vertically, 2px horizontally** — visibly lopsided ✘
- `14` → 2.04px → even, but chunky

Aim for the middle of a pixel bucket, not the edge of one.

### The ornate art cannot be 9-sliced

`ui_play_button_v3.png`, `ui_panel_dark_v2.png` and the button art have frames far
too heavy to 9-slice, so the whole image stretches. **Keep the source aspect** or
the corners distort, and keep content inside the interior rect:

| Art | Size | Aspect | Interior |
|---|---|---|---|
| `ui_play_button_v3.png` | 1905 × 825 | 2.31 | x 152–1735, y 154–627 |
| `ui_panel_dark_v2.png` | 1070 × 1470 | 0.73 | inset ~14.9% × 12.2% |
| `ui_button_primary.png` | 1693 × 929 | 1.82 | — |
| `ui_button_secondary_v3.png` | 2070 × 760 | 2.72 | — |

### Never assign a raw icon to `Button.icon`

The icons are ~1254². A Button's minimum size includes its icon, so one icon once
inflated a row to 1641×1662 and forced a scrollbar. Always pair it with
`expand_icon = true` **and** `theme_override_constants/icon_max_width` (28–30).
`TextureRect`s are safe — they use `expand_mode = 1` + `custom_minimum_size`.

### Don't hand-write generated properties into a scene

The `@tool` widgets build their own textures and styleboxes. Those are marked
non-storable on purpose, and script-drawn nodes are internal children, so Godot
cannot bake them into the scenes that instance them. If a baked copy ever appears
in a `.tscn` (a `StyleBoxFlat` sub-resource or a giant `PackedByteArray`), delete
it — a stale baked copy silently overrides the knobs above. That is how
`game_world.tscn` once reached 1.45 MB.

**This also happens to plain `@export` knobs**, and it is much harder to spot
because the values look legitimate. Opening a screen in the editor can make Godot
write the widget's exported values into that screen as instance overrides. They
are a snapshot: change the widget's defaults later and the screen keeps the OLD
ones, silently, forever.

`world_map.tscn` had exactly this — an entire block of `bar_color`,
`divider_color`, `label_color` … pinned to superseded brown values, plus thirteen
properties written as literal `null`. The nav bar looked wrong on that one screen
only, and no amount of editing `nav_bar.tscn` fixed it.

**If a widget looks right in its own scene but wrong on one screen, open that
screen's `.tscn` in a text editor and look at the instance block.** Anything there
beyond layout (`offset_*`, `anchors_*`, `layout_mode`) and the genuinely
per-screen knob (`selected`) is almost certainly stale — delete it. In the editor
the equivalent is right-click the property → **Revert**.

### A Container silently un-rotates its children

`Container.fit_child_in_rect()` resets `rotation` to 0 **and** `scale` to 1 on every
direct child it lays out. Set either one on a node sitting straight inside an
`HBoxContainer` / `VBoxContainer` / `GridContainer` and it looks right in the
Inspector and wrong on screen, with no error.

Wrap it: put a plain `Control` in the container (a plain Control lays out nothing)
and the rotated node inside that. The garage's ATK sword does exactly this —
`StatsStrip/Row/Atk/IconSlot/Icon`. Delete the `IconSlot` wrapper and the sword
quietly goes upright again.

### Thin lines land on the pixel grid differently across the screen

The design space is 1080×1920 but the window is not, so a 3-unit line is ~1.4 real
pixels, and whether that covers one pixel centre or two depends on where it falls.
Two lines placed symmetrically about the centre have mirror-image fractional
offsets, so they round **opposite ways** — one 2px, one 1px, from identical
numbers. That is why the nav bar's two seams looked different thicknesses.

`nav_bar.gd` fixes this by snapping each seam to whole device pixels
(`_device_scale()` → `round()`), so both are exactly
`round(divider_width × scale)` pixels wide. **If you add another thin line
anywhere, expect this and check both ends of it**, and see the 3D bar's
`rim_width` table above for the same problem in another place.

---

## How to check a change without guessing

- **In the editor** — the fastest loop. `@tool` means the viewport redraws as you
  type. `editor_preview_fill` on the 3D bar exists exactly so you can judge it
  without pressing Play.
- **Measure the art, don't eyeball it** — `Image.get_used_rect()` gives the opaque
  bounding box of a PNG, which is how the fill table above was produced.
- **Look at a rendered frame** — the texture being correct tells you nothing about
  how it lands on the screen's pixel grid. Sub-pixel problems are only visible in
  an actual render.

---

## Related docs

- `components.md` §7 — how the UI layer is wired, and the reasoning behind it
- `ui_assets.md` — the art inventory: what exists, what is unused, what is unmade
- `assets.md` — asset requirements and naming conventions
