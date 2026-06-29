# Tower's Last Stand (3D) — Assets Reference

> **Scope of this file**: only the assets actually required to build v1.
> No mood-board art direction, no "make it look cool" prose — that's a creative
> decision for you to make with Meshy, not something a doc should dictate.
> What this file DOES define: the Archero-style technical setup (camera,
> proportions, sizing) so models come out of Meshy at the right scale and the
> camera frames them correctly, plus the literal list of files the code
> expects to find.
>
> Pipeline: **Meshy AI → exported `.glb` → imported directly into Godot as a
> real mesh.** No Blender-render-to-spritesheet step. Godot renders the actual
> 3D model every frame; the "2.5D look" comes entirely from the fixed camera
> angle, not from faked sprites.

---

## 1. The Archero-Style Setup (read this before generating anything)

Archero is a genuinely 3D mobile game. The "looks 2D" impression comes from
camera + animation staging choices, not from flat art:

- **Perspective camera, not orthographic.** A slight perspective is what
  makes real 3D shadows/depth read correctly. Orthographic is the
  spritesheet-render trick we explicitly rejected.
- **Fixed pitch, no rotation.** The camera looks down at the arena from a
  consistent angle and never turns. Start at **~60° from horizontal**
  (i.e., steeply downward but not a true bird's-eye 90°) — this is a starting
  value to tune by eye in Epic 01 once a placeholder tower/enemy/camera are in
  scene together, not a value to treat as gospel. Epic 02 Task 02-00
  re-checks this same value against real models as soon as they exist, since
  primitive proportions and real model proportions won't necessarily match.
- **Characters read clearly from above-and-behind.** Faces/fronts don't need
  to be highly detailed since the camera rarely sees them head-on — detail
  budget goes into silhouette (readable from above) and top/shoulder surfaces.
- **Exaggerated, chunky proportions.** Archero-style characters and enemies
  are stylized/chibi-ish — slightly oversized heads relative to body, clear
  simple silhouettes — this reads better at the fixed top-down angle and at
  small on-screen size on a phone than a realistically-proportioned model
  would. Use this as a Meshy prompting guideline, not a hard rule.
- **Bosses are dramatically larger than regular enemies** — both in actual
  model scale and in the space they occupy on screen — so the boss-wave
  moment reads instantly even at the fixed camera distance.

### Reference scale table (tune once a placeholder is in-engine, treat as a starting point)

| Element | Approx. height (meters, Godot units) | Notes |
|---|---|---|
| Tower | 1.4–1.8 m | Should feel sturdy/anchored, slightly larger than a regular enemy |
| Regular ground enemy | 0.9–1.3 m | Chibi-style proportions per above |
| Fast/small enemy variant | 0.7–1.0 m | Visibly smaller than the baseline enemy, reinforces "fast and fragile" at a glance |
| Chapter boss | 2.5–4.0 m | Dramatically larger — should visibly tower over the tower model itself |
| Arena ground plane | ~10–12 m across | Must fully fill the fixed camera's frame in portrait orientation with a small margin |

These numbers are intentionally a range, not exact specs — Meshy output
varies, and final scale gets locked once the first model is actually placed
next to the camera rig (Epic 01 acceptance criteria covers this check).

### Shading

- Use a shared simple toon/cel `ShaderMaterial` (or `StandardMaterial3D`
  with a steep `roughness` + a rim-light boost) across all character/enemy/
  tower models so everything reads as one consistent style regardless of
  which Meshy generation produced which model. One shared shader resource,
  referenced by every model's material slot — not a unique shader per asset.
- Real-time shadows: one `DirectionalLight3D` with shadows enabled, tuned for
  mobile performance in Epic 08 (shadow distance, shadow map size). This is
  the actual problem that sank the 2D version — in 3D, Godot computes real
  shadows for free, so this category of pain goes away as long as the light
  and shadow settings are kept mobile-reasonable (see `epic_08_polish.md`).

---

## 2. Required 3D Models (v1)

All models exported as `.glb` (geometry + material + skeleton + animations
embedded in one file), placed in `res://assets/models/` with the exact
filenames below.

> **When each model actually gets made**: `tower_default.glb` and
> `chap1_enemy_01.glb` are needed early — Epic 02 Task 02-00 swaps them in
> right at the start of that epic, before any combat tasks, as a single
> rough static-pose mesh (no animation clips needed yet), specifically so
> the camera/scale tuning from Epic 01 gets validated against something real
> instead of staying judged against a capsule and a box. `chap1_enemy_02.glb`
> and `chap1_boss_01.glb` aren't needed until Epic 04 (when those enemies are
> actually built) and `arena_chapter_01.glb` isn't needed until Epic 06. The
> **animation clips** (`idle`, `walk`, `attack`, `death`, etc.) for every
> model are an Epic 06 task regardless of when the base mesh was created — a
> static early model is fine to play unanimated for several epics; don't
> block on rigging early.

### Tower
| File | Notes |
|---|---|
| `tower_default.glb` | The single v1 tower. **Base mesh needed by Epic 02** (Task 02-00, static pose is fine). Needs an `idle` animation loop and an `attack` animation (fires on every shot, can be brief — a small recoil/flash pose is enough) wired in **Epic 06**. |

> **Extend later by:** adding `tower_<id>.glb` + a matching `TowerDefinition`
> `.tres` (see `components.md` Section 5). No code changes.

### Enemies (Chapter 1)
| File | Notes |
|---|---|
| `chap1_enemy_01.glb` | Baseline ground enemy. **Base mesh needed by Epic 02** (Task 02-00). Needs `walk`, `attack`, `death` animations wired in **Epic 06**. |
| `chap1_enemy_02.glb` | Fast/small variant. Needed by **Epic 04** (when this enemy type is actually built). Same animation set as `chap1_enemy_01` (can reuse the same animation clips retargeted, or have its own — either is fine, the `EnemyDefinition` resource just points at this file). |
| `chap1_boss_01.glb` | Chapter boss. **Base mesh needed by Epic 04** (when the boss is built). Needs `walk`, `attack`, a distinct heavier `attack_heavy` (the boss's one v1-simple special move), and `death` — animations wired in **Epic 06** like every other model. Significantly larger scale per the table above. |

> **Extend later by:** `chap2_enemy_01.glb`, `chap1_enemy_03.glb`, etc., plus
> a matching `EnemyDefinition` `.tres`. The flyer-type hook
> (`hold_height` field) exists in the data already — when a flying enemy is
> actually added, it just needs a model + that one field set.

### Arena
| File | Notes |
|---|---|
| `arena_chapter_01.glb` | Ground plane + simple border/fence geometry. Flat, walkable, sized per the scale table above. Visual theme (grass/stone/whatever) is your call — not specified here since it's a creative choice, not a technical requirement. |

> **Extend later by:** `arena_chapter_02.glb`, etc.

---

## 3. Projectile & VFX Models/Textures (v1)

Projectiles in 3D can be either a tiny mesh (a sphere/capsule primitive is
often enough and avoids a Meshy round-trip for something this small) or a
simple billboarded sprite — pick whichever is faster to iterate on; the
`HitboxComponent` doesn't care which.

| Asset | Type | Notes |
|---|---|---|
| `proj_bolt` | Primitive mesh (capsule/sphere) or tiny `.glb` | Default tower projectile, straight-line travel |
| `proj_aoe_marker` | Simple ground decal/texture | Shows the AoE burst's target radius for one frame before/during impact |
| `vfx_hit_spark` | `GPUParticles3D` using a small billboard texture | Generic hit impact |
| `vfx_death_burst` | `GPUParticles3D` using a small billboard texture | Plays on enemy death |
| `vfx_levelup_ring` | Simple expanding ring mesh or particle ring | Plays on level-up at the tower |

> **Extend later by:** new spell categories may need their own
> `vfx_*`/`proj_*` — same pattern, drop in a file, reference it from the new
> `SpellDefinition`.

---

## 4. UI Assets (v1)

UI stays a flat 2D `CanvasLayer` concern regardless of the 3D game world —
no 3D pipeline involved here.

| File | Notes |
|---|---|
| `ui_hp_bar_bg.png` / `ui_hp_bar_fill.png` | Tower HP bar |
| `ui_xp_bar_bg.png` / `ui_xp_bar_fill.png` | XP bar |
| `ui_card_bg_common.png` / `ui_card_bg_rare.png` / `ui_card_bg_epic.png` | 9-slice draft card backgrounds, one per rarity |
| `icon_spell_basic_bolt.png` / `icon_spell_basic_aoe.png` / `icon_spell_basic_passive.png` | One icon per v1 spell |
| `icon_upgrade_damage.png` / `icon_upgrade_fire_rate.png` / `icon_upgrade_max_hp.png` | One icon per v1 stat upgrade |
| `icon_tag_offense.png` / `icon_tag_armor.png` / `icon_tag_utility.png` | One icon per v1 synergy tag |
| `ui_button_primary.png` / `ui_button_secondary.png` | 9-slice buttons |
| `ui_panel_dark.png` | 9-slice generic dark panel |

> **Extend later by:** new spell/upgrade/tag icons follow the same naming —
> `icon_spell_<id>.png`, `icon_upgrade_<id>.png`, `icon_tag_<id>.png` — so the
> draft UI can look up an icon by ID convention rather than a hardcoded map.

---

## 5. Fonts (v1)

| Font | Usage |
|---|---|
| A bold display font (e.g. `Cinzel` or `Bebas Neue`, Google Fonts, OFL license) | Title screen, wave/level-up banners |
| A clean sans-serif (e.g. `Nunito` or `Roboto`, Google Fonts) | Card text, stat text, body UI |

---

## 6. Audio (v1)

Keep this minimal at v1 — full SFX coverage is Epic 07's job once gameplay is
proven. These are the files needed to not have *silent* core actions during
earlier epics' integration tests.

### Music
| File | Loop | Usage |
|---|---|---|
| `music_wave.ogg` | Yes | Default combat music |
| `music_draft.ogg` | Yes | Draft screen (calmer) |
| `music_victory.ogg` | No | Victory stinger |
| `music_defeat.ogg` | No | Defeat stinger |

### SFX
| File | Usage |
|---|---|
| `sfx_proj_bolt.wav` | Default tower shot |
| `sfx_aoe_impact.wav` | AoE burst impact |
| `sfx_enemy_hit.wav` | Any enemy taking damage |
| `sfx_enemy_death.wav` | Any enemy dying |
| `sfx_tower_hit.wav` | Tower taking damage |
| `sfx_level_up.wav` | Level-up |
| `sfx_synergy_unlock.wav` | Synergy threshold reached |
| `sfx_draft_card_select.wav` | Card picked |
| `sfx_ui_button.wav` | Generic UI tap |
| `sfx_boss_spawn.wav` | Boss entrance |

> **Extend later by:** per-damage-type SFX variants, per-enemy-type death
> SFX, etc. — same naming pattern, more files, no engine changes. Full
> expanded list is Epic 07's job, not v1's.

---

## 7. Free / AI Asset Sources

| Source | What to use it for |
|---|---|
| [meshy.ai](https://meshy.ai) | Primary model generation pipeline — text/image to 3D, exports `.glb` directly |
| [Tripo3D](https://tripo3d.ai) | Fallback if a Meshy result isn't usable |
| [Google Fonts](https://fonts.google.com) | All fonts, OFL license |
| [freesound.org](https://freesound.org) | SFX, filter by CC0 |
| [incompetech.com](https://incompetech.com) | Royalty-free music |
| [kenney.nl](https://kenney.nl) | UI kit elements if you don't want to hand-make 9-slice panels/buttons |
