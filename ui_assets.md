# UI Assets Checklist — Tower's Last Stand (3D)

> [x] = DONE, [ ] = TO MAKE. "Generate" = ChatGPT. "Download" = Google Fonts.

=====================================================================
## FOLDER STRUCTURE (`assets/ui/`) — source of truth
=====================================================================

> Reorganized 2026-07-27. One tree: per-screen folders + shared folders
> (the old flat `assets/ui/` and `assets/ui_spellsdraft/` are gone).
> Many assets still have multiple candidate versions side-by-side
> (`_v2`, `_v3`, `1` suffixes) — the winner gets picked when each widget
> scene is wired; losing versions get archived at that point.

```
assets/ui/
├── common/       # shared across screens: ui_button_primary, ui_button_secondary,
│                 # ui_panel_dark, ui_notification_badge (each + versions)
├── topbar/       # ui_topbar_pill_bg, icon_currency_energy, icon_currency_materials
├── nav/          # icon_nav_worldmap, icon_nav_garage, icon_nav_codex
├── world_map/    # bg_worldmap, ui_play_button, ui_chapter_node_frame,
│                 # ui_locked_overlay, chapter_01_image
├── garage/       # bg_garage, icon_stat_atk, icon_stat_hp, icon_tower_ancient,
│                 # ui_star_filled, ui_star_empty
├── hud/          # in-run bars. NOTHING HERE IS IN USE — all 17 PNGs are dead.
│                 # Both bars are drawn procedurally by value_bar.gd (track +
│                 # fill + rim, from BarTexture.make_capsule) because stretching
│                 # a painted pill to an arbitrary size flattened its round caps.
│                 # Kept only in case the painted look is ever wanted back.
├── draft/        # ui_card_bg_common / _rare / _epic / _legendary
├── spells/       # icon_spell_<spell_id>.png — names match resources/spells/*.tres
│   ├── fire/     #   bolt_fire, orb_embers, lance_flame, area_rain_of_fire,
│   │             #   chain_fire (backlog spell, no .tres yet — spells.md §4)
│   ├── frost/    #   bolt_frost, orb_frost, lance_glacier, area_blizzard
│   ├── void/     #   bolt_void, orb_void, lance_rift, chain_chaos
│   ├── poison/   #   bolt_venom, orb_venom, lance_toxic, chain_contagion
│   └── nature/   #   bolt_thorn, orb_thorn, lance_briar, chain_vines
├── upgrades/     # in-run stat-upgrade icons: icon_upgrade_armor / _max_hp /
│                 # _fire_rate (+ versions) + icon_upgrade_damage_<school> ×5
│                 # (filenames say "shadow" for the void school)
├── bonuses/      # school all-in emblems: icon_bonus_<school> ×5 ("shadow" = void)
└── rewards/      # icon_chest_common/rare/epic (+ _open each), icon_key_common/
                  # rare/epic, icon_mat_scroll_<school> ×5, icon_mat_tower_rare
```

> `codex/` folder doesn't exist yet — create it when its first asset
> (bg_menu_generic) is made. `icon_spell_orb_thorn.png` is blue lightning-orb
> art in a nature-green frame (was "lightning orb.png") — swap it out if a
> Lightning school ever ships and nature gets a real thorn orb icon.

=====================================================================
## DONE
=====================================================================

CURRENCY / TOP BAR
- [x] icon_currency_materials.png
- [x] icon_currency_energy.png
- [x] ui_topbar_pill_bg.png

NAVIGATION
- [x] icon_nav_worldmap.png
- [x] icon_nav_garage.png
- [x] icon_nav_codex.png

WORLD MAP
- [x] ui_play_button.png
- [x] ui_chapter_node_frame.png
- [x] ui_locked_overlay.png
- [x] ui_notification_badge.png

TOWER GARAGE STARS
- [x] ui_star_filled.png
- [x] ui_star_empty.png

BARS (HUD) — SUPERSEDED, the bars are drawn in code now, not from these
- [x] ui_hp_bar_bg.png     (unused)
- [x] ui_hp_bar_fill.png   (unused)
- [x] ui_xp_bar_bg.png     (unused)
- [x] ui_xp_bar_fill.png   (unused)

DRAFT CARD BACKGROUNDS
- [x] ui_card_bg_common.png
- [x] ui_card_bg_rare.png
- [x] ui_card_bg_epic.png
- [x] ui_card_bg_legendary.png (spare)

SPELL ICONS (all 5 schools + cross-school)
- [x] Fire, Frost, Poison, Shadow, Nature + Chain etc.

IN-RUN UPGRADE ICONS (drafted during gameplay)
- [x] icon_upgrade_damage_fire.png
- [x] icon_upgrade_damage_frost.png
- [x] icon_upgrade_damage_poison.png
- [x] icon_upgrade_damage_shadow.png
- [x] icon_upgrade_damage_nature.png
- [x] icon_upgrade_armor.png     (shield)
- [x] icon_upgrade_max_hp.png    (heart)
- [x] icon_upgrade_fire_rate.png (attack speed)

=====================================================================
## PAINTED BUT NOT WIRED — art exists on disk, nothing displays it yet
=====================================================================

> Verified against the files on disk 2026-07-28. These are done as ART; what is
> missing is a screen or widget that references them. No more generating needed.

A. SCHOOL BONUS EMBLEMS — all 5 exist in `bonuses/`
   (icon_bonus_fire / _frost / _poison / _shadow / _nature)
   Needs: a synergy "all-in" readout to show them. `tag_row_widget` is the
   natural home. ("shadow" is the void school's filename.)

B. IN-RUN PER-SCHOOL DAMAGE ICONS — all 5 exist in `upgrades/`
   (icon_upgrade_damage_<school>)
   Needs: nothing generated. Note `upgrade_damage.tres` has
   upgrade_id = "upgrade_damage", so SpellRegistry's convention path would be
   `icon_upgrade_damage.png`, which does NOT exist — it falls back to the
   explicit `garage/icon_stat_atk.png` override. Either add the plain-named
   file or split the upgrade per school.

C. REWARDS & MATERIALS — all 16 exist in `rewards/`
   (icon_chest_common/_rare/_epic + each _open, icon_key_common/_rare/_epic,
   icon_mat_scroll_<school> x5, icon_mat_tower_rare + _v2)
   Needs: a rewards / chest-opening screen, which does not exist yet.

=====================================================================
## STILL TO MAKE (generate in ChatGPT)
=====================================================================

> This is the whole remaining art list. Everything else in sections A–H of the
> old list turned out to be on disk already; most of it is wired.

- [ ] icon_tower_ability.png  (your tower's ability — 1)
- [ ] icon_tower_default.png  (portrait for the garage selection grid, +1 per
                              future tower. icon_tower_ancient.png already
                              covers tower #1 via TowerDefinition.icon)
- [ ] bg_menu_generic.png     (reusable backdrop for codex/other menus — the
                              codex currently borrows bg_garage.png)
- [ ] bg_victory.png          (optional)
- [ ] bg_defeat.png           (optional)

Not needed any more: the HUD bar art. `value_bar.gd` and `health_bar_3d.gd`
draw their bars from `BarTexture.make_capsule()`, so track / fill / rim / radius
are inspector knobs, not files to repaint.

-----
NOTE: Monetization UI (shop packs, subscription cards, battle pass, gems,
ad/"watch video" button, gift icons) is LATER / design-only per mechanics.md
Sec 12 — not built for v1. Say so if you want them pulled into scope.

=====================================================================
## DOWNLOAD (not generated)
=====================================================================
- [ ] Bold display font (Cinzel / Bebas Neue)
- [ ] Clean sans-serif (Nunito / Roboto)
