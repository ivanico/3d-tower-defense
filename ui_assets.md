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
├── hud/          # in-run bars. IN USE: ui_hp_bar_fill_v3.png and
│                 # ui_xp_bar_fill_v5.png (v3 recoloured blue) — the HUD is
│                 # fill-only, no frame. The *_bg_* frames and the generated
│                 # *_fill_v4 squared rectangles are unused but kept.
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

BARS (HUD)
- [x] ui_hp_bar_bg.png
- [x] ui_hp_bar_fill.png
- [x] ui_xp_bar_bg.png
- [x] ui_xp_bar_fill.png

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
## TO MAKE (generate in ChatGPT)
=====================================================================

A. SCHOOL BONUS EMBLEMS — 5
   (shown when all-in on one school)
- [ ] icon_bonus_fire.png  (in progress)
- [ ] icon_bonus_frost.png
- [ ] icon_bonus_poison.png
- [ ] icon_bonus_shadow.png
- [ ] icon_bonus_nature.png

B. GARAGE-HUB STAT READOUT ICONS
   (tower's current ATK / HP shown on the garage screen)
- [ ] icon_stat_atk.png   (sword)
- [ ] icon_stat_hp.png     (heart — OR reuse icon_upgrade_max_hp if you like)
- [ ] icon_tower_ability.png  (your tower's ability — 1)

C. REWARDS & MATERIALS
   Chests (2-3):
   - [ ] icon_chest_common.png
   - [ ] icon_chest_rare.png
   - [ ] icon_chest_epic.png  (optional)
   Spell upgrade scroll-mats (1 per school):
   - [ ] icon_mat_scroll_fire.png
   - [ ] icon_mat_scroll_frost.png
   - [ ] icon_mat_scroll_poison.png
   - [ ] icon_mat_scroll_shadow.png
   - [ ] icon_mat_scroll_nature.png
   Rare tower material:
   - [ ] icon_mat_tower_rare.png

D. BACKGROUNDS (full-screen 2D images, portrait 1080x1920)
- [ ] bg_worldmap.png       (sky/scenery behind the world map)
- [ ] bg_garage.png         (backdrop behind garage screen)
- [ ] bg_menu_generic.png   (reusable backdrop for codex/other menus)
- [ ] bg_victory.png        (optional)
- [ ] bg_defeat.png         (optional)

E. CHAPTER IMAGE
- [ ] chapter_01_image.png  (flat 2D painting of the arena; sits inside
                            ui_chapter_node_frame.png)

F. TOWER ICON
- [ ] icon_tower_default.png (tower portrait for the garage selection grid;
                            +1 per future tower)

G. CHEST KEYS (only if chests need keys to open)
- [ ] icon_key_common.png
- [ ] icon_key_rare.png

H. BUTTONS & PANELS — 3
- [ ] ui_button_primary.png
- [ ] ui_button_secondary.png
- [ ] ui_panel_dark.png

-----
NOTE: Monetization UI (shop packs, subscription cards, battle pass, gems,
ad/"watch video" button, gift icons) is LATER / design-only per mechanics.md
Sec 12 — not built for v1. Say so if you want them pulled into scope.

=====================================================================
## DOWNLOAD (not generated)
=====================================================================
- [ ] Bold display font (Cinzel / Bebas Neue)
- [ ] Clean sans-serif (Nunito / Roboto)
