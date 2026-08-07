class_name Bar3DStyle
extends Resource

## The shared LOOK for a `ValueBar3D`, as a Resource instead of inline
## per-scene property values. Assigning this to `ValueBar3D.style` is what
## lets many scenes (every enemy, every boss, ...) reuse one look and change
## it in exactly one place instead of editing the same ~12 property lines in
## every scene that wants it. See `resources/ui/*.tres` for the actual presets.
##
## Deliberately excludes anything that's genuinely per-instance rather than
## "look": `height_offset` (depends on each unit's own model height),
## `show_value`, `follow_game_state`, and the number's own styling (only the
## tower currently shows a number, tuned inline on that one scene).

## Bar size in TEXTURE pixels. See `ValueBar3D.bar_size` for the supersampling note.
@export var bar_size: Vector2i = Vector2i(480, 68)

## World units per texture pixel -- the "how big on screen" knob.
@export var pixel_size: float = 0.003

## Colour at the top edge of the fill.
@export var color_top: Color = Color(0.45, 0.90, 0.35)

## Colour at the bottom edge of the fill.
@export var color_bottom: Color = Color(0.16, 0.62, 0.18)

## Where the fill's gradient finishes, as a fraction of its height. `1.0` is a
## plain gradient over the whole height.
@export_range(0.05, 1.0) var color_split: float = 1.0

## Colour at the top edge of the empty track behind the fill.
@export var track_color_top: Color = Color(0.16, 0.18, 0.24)

## Colour at the bottom edge of the empty track.
@export var track_color_bottom: Color = Color(0.09, 0.10, 0.14)

## Glossy top-edge highlight blended onto the track. Alpha 0 turns it off.
@export var track_highlight_color: Color = Color(1.0, 1.0, 1.0, 0.0)

## Height of that highlight band, in TEXTURE pixels. Needs to clear `rim_width`
## to actually show -- the rim is drawn on top and hides a thinner highlight.
@export var track_highlight_height: int = 0

## Colour of the outline framing the bar. Alpha 0 removes it.
@export var rim_color: Color = Color(0.04, 0.04, 0.06)

## Outline thickness in TEXTURE pixels, and also how far the fill is inset.
@export var rim_width: int = 7

## Corner radius in TEXTURE pixels. At or above half the height = full capsule.
@export var corner_radius: int = 12
