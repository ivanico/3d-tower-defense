# UI Assets Checklist — Tower's Last Stand (3D)

> Everything you need to make/source in a 2D art tool for the UI layer.
> Source: `assets.md` Section 4 (+ cross-refs from epics 03/05/06/08).
> All UI is a flat 2D `CanvasLayer` concern — no 3D pipeline needed for
> anything on this list.

---

## 1. Bars

- [ ] `ui_hp_bar_bg.png` — Tower HP bar background
- [ ] `ui_hp_bar_fill.png` — Tower HP bar fill
- [ ] `ui_xp_bar_bg.png` — XP bar background
- [ ] `ui_xp_bar_fill.png` — XP bar fill

---

## 2. Draft Card Backgrounds (9-slice, one per rarity)

- [ ] `ui_card_bg_common.png`
- [ ] `ui_card_bg_rare.png`
- [ ] `ui_card_bg_epic.png`

---

## 3. Spell Icons (one per v1 spell)

- [ ] `icon_spell_basic_bolt.png`
- [ ] `icon_spell_basic_aoe.png`
- [ ] `icon_spell_basic_passive.png`

> Extend later: new spells follow `icon_spell_<id>.png` naming.

---

## 4. Stat Upgrade Icons (one per v1 upgrade)

- [ ] `icon_upgrade_damage.png`
- [ ] `icon_upgrade_fire_rate.png`
- [ ] `icon_upgrade_max_hp.png`

> Extend later: new upgrades follow `icon_upgrade_<id>.png` naming.

---

## 5. Synergy Tag Icons (one per v1 tag)

- [ ] `icon_tag_offense.png`
- [ ] `icon_tag_armor.png`
- [ ] `icon_tag_utility.png`

> Extend later: new tags follow `icon_tag_<id>.png` naming.

---

## 6. Buttons & Panels (9-slice)

- [ ] `ui_button_primary.png`
- [ ] `ui_button_secondary.png`
- [ ] `ui_panel_dark.png`

---

## 7. Tower Garage Extras

Not named as files in `assets.md`, but called out as needed in Epic 05:

- [ ] Filled star icon (tower star rating)
- [ ] Empty star icon (tower star rating)

---

## 8. Fonts

- [ ] Bold display font — title screen, wave/level-up banners
      (e.g. **Cinzel** or **Bebas Neue**, Google Fonts, OFL license)
- [ ] Clean sans-serif — card text, stat text, body UI
      (e.g. **Nunito** or **Roboto**, Google Fonts)

---

## 9. Where each asset gets used (scene reference)

| Asset group | Used in scene |
|---|---|
| HP bar, XP bar, tag icons | `HUD.tscn`, `TagRowWidget.tscn` |
| Card backgrounds, spell/upgrade icons | `DraftCard.tscn`, `DraftUI.tscn` |
| Tag icon (single) | `SynergyBanner.tscn` |
| Buttons, dark panel | `victory_screen.tscn`, `defeat_screen.tscn`, generic UI dialogs |
| Star icons | `tower_garage.tscn` |
| Both fonts | Title screen, HUD, draft cards, banners, victory/defeat screens |

---

## 10. NOT on this list (don't make these as flat sprites)

These look like "UI" but are actually 3D/world-space, built in Epic 06/08 —
not flat art:

- Enemy/boss floating HP bars → billboarded `Sprite3D`/`Label3D` in 3D space
- Damage numbers → `Label3D` in 3D world space
- Hit sparks / death burst / level-up ring → `GPUParticles3D` textures
  (tracked separately in `assets.md` Section 3, not this file)

---

## 11. Free / fallback sources

- [Google Fonts](https://fonts.google.com) — both fonts above, OFL license
- [kenney.nl](https://kenney.nl) — pre-made UI kit if you don't want to
  hand-make 9-slice panels/buttons

---

**Total flat 2D files to make: 18** (4 bars + 3 card backs + 3 spell icons +
3 upgrade icons + 3 tag icons + 2 buttons + 1 panel) **+ 2 star icons + 2 fonts.**
