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

| What you see | Scene | Script |
|---|---|---|
| Home / world map (the screen the game opens on) | `scenes/ui/world_map.tscn` | `scenes/ui/world_map.gd` |
| Tower Garage | `scenes/ui/tower_garage.tscn` | `scenes/ui/tower_garage.gd` |
| Spell Codex | `scenes/ui/spell_codex.tscn` | `scenes/ui/spell_codex.gd` |
| Victory screen | `scenes/ui/victory_screen.tscn` | `scenes/ui/victory_screen.gd` |
| Defeat screen | `scenes/ui/defeat_screen.tscn` | `scenes/ui/defeat_screen.gd` |
| In-run HUD (pause, wave, Lv bar) | `scenes/main/game_world.tscn` → `HUD` node | `scenes/main/hud.gd` |
| Draft card popup | `scenes/ui/draft_ui.tscn`, `scenes/ui/draft_card.tscn` | `scenes/ui/draft_card.gd` |
| Synergy banner / tag row | `scenes/ui/synergy_banner.tscn`, `scenes/ui/tag_row_widget.tscn` | — |

### Widgets (the reusable pieces)

| Widget | Folder |
|---|---|
| Currency pill (icon + amount) | `scenes/ui/widget/currency_pill/` |
| Top bar (holds two pills) | `scenes/ui/widget/top_bar/` |
| Nav bar (bottom 3 buttons) | `scenes/ui/widget/nav_bar/` |
| Nav button (one entry, no script) | `scenes/ui/widget/nav_button/` |
| Play button | `scenes/ui/widget/play_button/` |
| Chapter artwork | `scenes/ui/widget/chapter_node/` |
| Pause button | `scenes/ui/widget/pause_button/` |
| HP / XP bar (2D, in the HUD) | `scenes/ui/widget/hp_bar/`, `scenes/ui/widget/xp_bar/` |
| ↳ their shared script | `scenes/ui/widget/value_bar.gd` |
| Floating HP bar over the tower (3D) | `scenes/ui/widget/health_bar_3d/` |
| ↳ shared bar drawing code | `scenes/ui/widget/bar_texture.gd` |
| Star row (garage) | `scenes/ui/widget/star_row/` |
| Meta row (garage + codex list rows) | `scenes/ui/widget/meta_row/` |
| Primary / secondary buttons | `scenes/ui/widget/primary_button/`, `secondary_button/` |

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
| `text_gap` `[10]` | Extra space between icon and the number. |
| `font_size` `[40]` | Size of the amount text. |
| `icon`, `amount` | Per-instance. Set in `top_bar.tscn`, not here. |

### Top bar — `scenes/ui/widget/top_bar/top_bar.tscn`

Holds the two pills. This is where you say *which* currency each pill shows.
`separation` `[40]` is the gap between them. Its height (124) is the **icon's**
height, not the pill's.

### Nav bar — `scenes/ui/widget/nav_bar/nav_bar.tscn`

Order is **Garage · Worldmap · Codex** — worldmap in the middle on purpose,
because it is the screen the game opens on.

| Knob | What it does |
|---|---|
| `selected` | Which entry is highlighted. **Set per screen**, not here. |
| `normal_size` `[130]` | Icon size for the two you are not on. |
| `selected_size` `[180]` | Icon size for the one you are on. |
| `selected_rise` `[0]` | Pixels to lift the selected entry above the others. |
| `separation` `[48]` | Horizontal gap between entries. |
| `row_offset` `[0, 0]` | Free nudge for the whole row. +y moves down. |

To change which *image* an entry uses, select that button inside `nav_bar.tscn`
and set `texture_normal`.

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

### Floating HP bar over the tower — `scenes/ui/widget/health_bar_3d/health_bar_3d.tscn`

Tune it **here** and all five tower star-levels update at once.

| Knob | What it does |
|---|---|
| `bar_size` `[480, 68]` | Texture resolution, **not** screen size. |
| `pixel_size` `[0.003]` | World units per texture pixel. **This is the on-screen size knob.** |
| `height_offset` `[2.8]` | How high it floats above the tower. |
| `rim_width` `[7]` | The outline. See the sub-pixel warning below. |
| `corner_radius` `[12]`, colours, `track_*` | Same meaning as the 2D bar. |
| `show_value`, `value_font_size` `[48]` | The number on the bar. |
| `value_raise` `[0.5]` | In bar heights: 0 centres the number on the bar, 0.5 centres it on the top edge, 1.0 clears the bar. |
| `always_on_top` `[off]` | Draw through geometry. Only if the bar gets clipped. |
| `editor_preview_fill` `[0.7]` | **Editor only.** Lets you judge a part-full bar without running the game. |
| `follow_game_state` `[on]` | Tracks the tower's HP by itself. Enemies set this off and call `set_hp()`. |

---

## Recipes

**Make an icon bigger or smaller** → `icon_scale` on `currency_pill`, or
`cost_icon_size` on `play_button`, or `normal_size`/`selected_size` on `nav_bar`.

**Move an icon a few pixels** → `icon_offset` on `currency_pill`,
`content_offset` on `play_button`, `row_offset` on `nav_bar`.

**Move a whole element on a screen** → open the screen scene, select the node,
change its Layout → Transform → Position (or the offsets). E.g. the Play button's
place on the world map is `world_map.tscn` → `PlayButton` offsets.

**Make the selected nav entry stand out more** → raise `selected_size`, and/or
set `selected_rise` to lift it above the others.

**Change the Lv bar's colours** → `xp_bar.tscn` → `color_top` / `color_bottom`.

**Make a bar's outline thicker** → `rim_width`. For the 3D bar read the sub-pixel
warning first.

**Swap a piece of art** → each texture is referenced in exactly ONE widget scene,
so change it there and it updates everywhere. `ui_assets.md` lists what exists.

**Change all body text at once** → `resources/theme/ui_theme.tres`
(`default_font_size`, label colour, outline). Do *not* add per-node font
overrides for ordinary text.

---

## Gotchas that will otherwise waste your time

### Icons are not the size you think

Every icon PNG is 1254×1254, but the **artwork inside fills wildly different
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
