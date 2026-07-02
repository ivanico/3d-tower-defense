# Project Structure Template

Reusable organizational pattern extracted from the **2d-survival** Godot 4.4
project (a Vampire-Survivors-style arena game). This document is
read-only reference — nothing in the project was changed to produce it.

The goal is to let you reproduce this *exact* folder + wiring convention in a
new project, and to hand someone a recipe for adding a new object without them
having to reverse-engineer anything.

---

## 1. Full `res://` directory tree

```
res://
├── project.godot                      # single autoload: GameEvents; main_scene = main.tscn
├── icon.svg
├── assets/                            # raw imported art, NOT per-object
│   ├── env/
│   │   └── tilemap_packed.png
│   └── ui/
│       └── ui.png
│
├── resources/                        # shared/data resources (.tres, tilesets, theme)
│   ├── tileset.tres
│   ├── theme/
│   │   ├── theme.tres
│   │   └── Rockboxcond12.ttf
│   └── upgrades/                     # DATA-driven upgrade definitions
│       ├── ability.gd               # class_name Ability  (extends AbilityUpgrade)
│       ├── ability_upgrade.gd       # class_name AbilityUpgrade (extends Resource)
│       ├── axe.tres                 # an Ability resource
│       ├── axe_dmg.tres             # AbilityUpgrade resources
│       ├── sword_dmg.tres
│       ├── sword_rate.tres
│       └── player_speed.tres
│
├── scripts/                          # global, class_name'd helper scripts
│   └── weighted_table.gd            # class_name WeihtedTable  (weighted random picker)
│
└── scenes/
    ├── main/
    │   └── main.tscn / main.gd       # root scene: wires all managers + UI + tilemap
    │
    ├── autoload/
    │   └── game_events.tscn / .gd    # GameEvents singleton (global signal bus)
    │
    ├── manager/                      # one Node per system, all children of Main
    │   ├── enemy_manager.tscn / .gd
    │   ├── exp_manager.tscn / .gd
    │   ├── upgrade_manager.tscn / .gd
    │   └── arena_time_manager.tscn / .gd
    │
    ├── component/                    # FLAT reusable building blocks (composition)
    │   ├── health_component.tscn / .gd
    │   ├── death_component.tscn / .gd
    │   ├── hit_flash_component.tscn / .gd / .gdshader / _material.tres
    │   ├── hitbox_component.tscn / .gd
    │   ├── hurtbox_componenet.tscn / .gd   (sic — misspelled everywhere)
    │   ├── velocity_component.tscn / .gd
    │   └── vial_drop_component.tscn / .gd
    │
    ├── game_object/                  # ONE FOLDER PER SPAWNABLE OBJECT
    │   ├── basic_enemy/
    │   │   ├── basic_enemy.tscn
    │   │   ├── basic_enemy.gd
    │   │   └── basic_enemy.png
    │   ├── ghost_enemy/
    │   │   ├── ghost_enemy.tscn
    │   │   ├── ghost_enemy.gd
    │   │   └── ghost_enemy.png
    │   ├── exp_vial/
    │   │   ├── exp_vial.tscn / .gd / .png
    │   ├── player/
    │   │   ├── player.tscn / .gd / .png
    │   └── game_camera/
    │       └── game_camera.tscn / .gd
    │
    ├── ability/                      # PAIRED FOLDERS: controller (logic) + ability (visual)
    │   ├── sword_ability/
    │   │   ├── sword_ability.tscn / .gd / sword.png
    │   ├── sword_ability_controller/
    │   │   ├── sword_ability_controller.tscn / .gd
    │   ├── axe_ability/
    │   │   ├── axe_ability.tscn / .gd / axe.png
    │   └── axe_ability_controller/
    │       └── axe_ability_controller.tscn / .gd
    │
    └── ui/                           # flat, one file-set per widget/screen
        ├── ability_upgrade_card.tscn / .gd
        ├── arena_time_ui.tscn / .gd
        ├── end_screen.tscn / .gd
        ├── exp_bar.tscn / .gd
        ├── floating_text.tscn / .gd
        ├── upgrade_screen.tscn / .gd
        └── vignette.tscn / .gd / .gdshader
```

> Every `.gd` / `.gdshader` also has a sibling `.uid` file and every imported
> texture a sibling `.png.import` file — both are Godot-generated. You never
> edit them by hand; they travel with their asset when you copy a folder.

---

## 2. The "object folder" pattern

There are **two** object-folder patterns in this project. Both live one level
deep and are named in `snake_case`.

### 2a. `scenes/game_object/<name>/` — a spawnable world entity

**Files inside (naming convention = folder name repeated):**

| File | Role |
|------|------|
| `<name>.tscn` | The scene. Root node is named in `PascalCase` (`BasicEnemy`, `GhostEnemy`, `ExpVial`). |
| `<name>.gd`   | The script attached to the scene root. `extends CharacterBody2D` (enemies/player) or `Node2D` (vial). |
| `<name>.png`  | The sprite texture, referenced by the `Sprite`/`Sprite2D` child. |
| `<name>.gd.uid`, `<name>.png.import` | Auto-generated sidecars. |

**How the files reference each other** (all paths are absolute `res://`, each
carries a `uid://` too):

- The scene's root node stores `script = ExtResource("…")` →
  `res://scenes/game_object/<name>/<name>.gd` (script lives in the same folder).
- The `Sprite` node stores `texture = ExtResource("…")` →
  `res://scenes/game_object/<name>/<name>.png` (texture in same folder).
- Behaviour is **composition, not inheritance**: the root instances component
  scenes from `res://scenes/component/*.tscn` (absolute paths, shared folder,
  *not* copied per object). Example from `basic_enemy.tscn`:
  ```
  [node name="HealthComponent" parent="." instance=ExtResource("2_dqq52")]
  [node name="VelocityComponent" parent="." instance=ExtResource("4_rw011")]
  [node name="HitFlashComponent" ... instance=ExtResource("8_p4ba4")]
  [node name="DeathComponent"  ... instance=ExtResource("4_em7wn")]
  [node name="VialDropComponent" ... instance=ExtResource("3_lmmt8")]
  [node name="HurtboxComponenet" ... instance=ExtResource("4_760sa")]
  ```
- Components are wired to each other **inside the scene** via
  `node_paths=PackedStringArray("health_component", …)` + `NodePath("../HealthComponent")`.
  (Godot exported-node references, relative to the node.)
- Per-object tuning is done by **overriding exported properties** on the
  instanced component, not by editing the component:
  `max_health = 30.0`, `max_speed = 60`, `drop_percent = 0.35`.
- Discovery hook: the root node declares `groups=["enemy"]`. This group — not a
  path — is how managers and abilities find live instances at runtime
  (`get_tree().get_nodes_in_group("enemy")`).

The scripts themselves are thin; they delegate to components:
```gdscript
# basic_enemy.gd
extends CharacterBody2D
@onready var velocity_component = $VelocityComponent
func _process(delta):
    velocity_component.accelerate_to_player()
    velocity_component.move(self)
```

### 2b. `scenes/ability/<name>/` + `scenes/ability/<name>_controller/` — paired object

Each weapon is **two** folders:

- `…/<name>_ability/` — the short-lived visual+hitbox scene that is spawned on
  every attack (`sword_ability.tscn` = sprite + `AnimationPlayer` "swing" +
  `HitboxComponent`; frees itself via an animation method track).
- `…/<name>_ability_controller/` — a persistent logic `Node` that holds a
  `Timer` and spawns the ability. It exposes
  `@export var <name>_ability: PackedScene`, set in the controller's `.tscn` to
  the paired ability scene:
  ```
  # sword_ability_controller.tscn
  sword_ability = ExtResource("2_ce61g")   # → sword_ability.tscn
  ```

The controller instantiates the ability into a runtime group node
(`get_tree().get_first_node_in_group("foreground_layer")`), sets its damage from
the controller's own state, and positions it — it never hard-codes a parent path.

---

## 3. Spawning & management

All managers are plain `Node`s instanced as children of `Main` in `main.tscn`,
wired to each other through `@export` node references
(`arena_time_manager = NodePath("../ArenaTimeManager")`).

### Enemy spawning — `scenes/manager/enemy_manager.gd`

- **Object references:** `@export var basic_enemy_scene: PackedScene` and
  `@export var ghost_enemy_scene: PackedScene`. These are assigned **in
  `enemy_manager.tscn`** to the `game_object` `.tscn` files — a manual, per-scene
  wiring, *not* a directory scan and *not* a resource array.
  ```
  # enemy_manager.tscn
  basic_enemy_scene = ExtResource("2_ub7xu")   # basic_enemy.tscn
  ghost_enemy_scene = ExtResource("3_3hvph")   # ghost_enemy.tscn
  ```
- **Selection:** a `WeihtedTable` (`res://scripts/weighted_table.gd`). Enemies
  are registered into it **manually in code**:
  ```gdscript
  func _ready():
      enemy_table.add_item(basic_enemy_scene, 10)
      ...
  func on_arena_difficulty_increased(arena_difficulty):
      ...
      if arena_difficulty == 6:
          enemy_table.add_item(ghost_enemy_scene, 20)   # gated by difficulty
  ```
- **Spawn:** a one-shot `Timer` restarts itself; on timeout it picks a scene,
  `instantiate()`s it, adds it to the `entities_layer` group node, and places it
  on a ring around the player (with a raycast to avoid walls).

### Exp vials — decentralized (no manager)

There is **no** exp-vial spawner. Vials are dropped by
`vial_drop_component.gd`, which each enemy carries. On the enemy's
`HealthComponent.died` signal it rolls `drop_percent` and, if it hits,
instantiates its own `@export var vial_scene` into the `entities_layer` group
node. Collection is signalled globally via `GameEvents.emit_exp_vial_collected`.

### Exp / level — `exp_manager.gd`

Listens to `GameEvents.exp_vial_collected`, accumulates exp, and emits `lvl_up`.

### Upgrades — `scenes/manager/upgrade_manager.gd`

- References upgrade **data** resources via **hard-coded `preload()` constants**,
  one per `.tres`:
  ```gdscript
  var upgrade_axe          = preload("res://resources/upgrades/axe.tres")
  var upgrade_sword_rate   = preload("res://resources/upgrades/sword_rate.tres")
  var upgrade_sword_damage = preload("res://resources/upgrades/sword_dmg.tres")
  var upgrade_player_speed = preload("res://resources/upgrades/player_speed.tres")
  ...
  ```
- Registers them into another `WeihtedTable` **manually in `_ready()`**.
- On `lvl_up` it pops an `upgrade_screen`, offers 2 picks, applies the choice,
  and re-broadcasts `GameEvents.ability_upgrade_added`.

### The glue: `GameEvents` autoload (`scenes/autoload/game_events.gd`)

A global **signal bus** (registered as the only autoload in `project.godot`).
Systems never call each other directly for cross-cutting events; they emit /
subscribe on `GameEvents` (`exp_vial_collected`, `ability_upgrade_added`,
`player_damaged`). This is what keeps the managers loosely coupled.

**Summary of the "how does X find Y" conventions:**

| Mechanism | Used for |
|-----------|----------|
| `@export PackedScene` set in the manager's `.tscn` | manager → spawnable scenes (enemies) |
| `preload("res://…tres")` const in script | manager → data resources (upgrades) |
| `WeihtedTable.add_item(...)` in `_ready()` | manual registry / weighted pool |
| Node **groups** (`get_first_node_in_group`, `get_nodes_in_group`) | runtime lookup of player, `entities_layer`, `foreground_layer`, `enemy` instances |
| `GameEvents` signals | cross-system events |

There is **no** runtime directory scanning and **no** auto-discovery anywhere.
Adding an object is always an explicit edit in 2–3 places.

---

## 4. Naming, ID, and path conventions

- **Files & folders:** `snake_case`. A file-set is named after its folder
  (`basic_enemy/basic_enemy.tscn|.gd|.png`).
- **Node names & `class_name`:** `PascalCase` (`BasicEnemy`, `HealthComponent`,
  `SwordAbility`, `WeihtedTable`, `AbilityUpgrade`, `Ability`).
- **Paths:** always absolute `res://…`, paired with a Godot `uid://…`. Scripts,
  scenes, and textures for one object share the same folder; **shared**
  components/resources are referenced across folders by absolute path.
- **IDs are string fields inside `.tres`, not derived from filenames.** Each
  upgrade resource declares its own `id`:
  ```
  # sword_dmg.tres
  id = "sword_dmg"
  max_quantity = 0
  name = "Sword Damage"
  description = "Increases sword damage by 15%"
  ```
  The string is the source of truth and is matched with **magic-string
  comparisons** scattered across the code:
  ```gdscript
  if upgrade.id == "sword_rate": ...        # sword_ability_controller.gd
  elif upgrade.id == "sword_dmg": ...
  if ability_upgrade.id == "player_speed":  # player.gd
  ```
  ⚠️ **There is no central enum / constants file for these IDs.** The id string,
  the `.tres` filename, and the folder name usually agree by convention but are
  maintained independently — keep them in sync yourself.
- **Two resource classes** drive upgrades (`resources/upgrades/`):
  - `AbilityUpgrade` (`ability_upgrade.gd`) — `id`, `max_quantity`, `name`,
    `description`. Used for stat upgrades (`sword_dmg`, `axe_dmg`, `sword_rate`,
    `player_speed`).
  - `Ability` (`ability.gd`, `extends AbilityUpgrade`) — adds
    `ability_controller_scene: PackedScene`. Used for *new weapons* (`axe.tres`).
    When such an upgrade is chosen, `player.gd` detects `is Ability` and
    instantiates its controller under the player's `Abilities` node:
    ```gdscript
    if ability_upgrade is Ability:
        abilities.add_child(ability_upgrade.ability_controller_scene.instantiate())
    ```
- **Physics layers** are named in `project.godot` (`Terrain`, `Player`, `Enemy`,
  `EnemyCollision`, `PlayerPickup`) and referenced by numeric
  `collision_layer` / `collision_mask` bitmasks in scenes.

---

## 5. Recipe — add a new object

### A. Add a new enemy (`ghost_enemy` → `spider_enemy`)

1. **Copy the folder.** Duplicate `scenes/game_object/basic_enemy/` →
   `scenes/game_object/spider_enemy/`. Rename all three files to
   `spider_enemy.tscn` / `.gd` / `.png` (drop the stray `tile_0121.png`).
   Delete the copied `.uid`/`.import` sidecars or let Godot regenerate them on
   next import.
2. **Rename the root node** in `spider_enemy.tscn` to `SpiderEnemy`, keep
   `groups=["enemy"]`, and point its `script` + `Sprite.texture` at the new
   in-folder `.gd` and `.png`. (If you copied, just fix the two paths — the
   component instances can stay pointed at `res://scenes/component/…`.)
3. **Tune** by overriding exported component props (`max_health`, `max_speed`,
   `drop_percent`, collision-shape radii). Swap in the new art.
4. **Register with the spawner** — `scenes/manager/enemy_manager.gd`:
   - add `@export var spider_enemy_scene: PackedScene`,
   - assign it in `enemy_manager.tscn` to `spider_enemy.tscn`,
   - `enemy_table.add_item(spider_enemy_scene, <weight>)` in `_ready()` (or gate
     it behind a difficulty check like `ghost_enemy`).

That's the whole loop — no other file needs to know the enemy exists, because
runtime lookups use the `"enemy"` group.

### B. Add a new weapon/ability (`sword` → `bow`)

1. **Copy two folders:** `sword_ability/` → `bow_ability/` and
   `sword_ability_controller/` → `bow_ability_controller/`; rename files to
   match. Update each scene's `script`/`texture` paths and root node names
   (`BowAbility`, `BowAbilityController`).
2. In `bow_ability_controller.tscn`, set the exported
   `bow_ability = <bow_ability.tscn>`. Adjust the `Timer.wait_time`, base
   damage, targeting logic in `bow_ability_controller.gd`.
3. **Create the upgrade resource** in `resources/upgrades/`:
   - `bow.tres` using **`Ability`** — set `id = "bow"`, `name`, `description`,
     `max_quantity = 1`, and `ability_controller_scene = bow_ability_controller.tscn`.
   - optional stat upgrades `bow_dmg.tres` / `bow_rate.tres` using
     **`AbilityUpgrade`** with matching `id` strings.
4. **Register with `upgrade_manager.gd`:** add
   `var upgrade_bow = preload("res://resources/upgrades/bow.tres")` and
   `upgrade_pool.add_item(upgrade_bow, <weight>)` in `_ready()`; if the weapon
   unlocks its own stat upgrade, mirror the `update_upgrade_pool()` pattern used
   by `axe`.
5. **Handle the id** wherever its stat effect applies (e.g. in
   `bow_ability_controller.gd`, `if upgrade.id == "bow_dmg": …`) — remember these
   are hand-matched magic strings.

Player wiring is automatic: because `bow.tres` is an `Ability`, `player.gd`
instantiates its controller under `Abilities` the moment the upgrade is picked —
you don't touch `player.tscn`.

### Golden rules when reusing this pattern

- One folder per spawnable object; the file-set is named after the folder.
- Behaviour = shared component scenes instanced + tuned via exported overrides,
  never subclassed.
- Managers reference concrete scenes explicitly (`@export` in `.tscn`) or data
  explicitly (`preload` const) and register them by hand into a `WeihtedTable`.
- Runtime discovery is via **groups**, not paths.
- Cross-system events go through the `GameEvents` autoload.
- IDs are authored strings in `.tres` files — there is no enum, so keep
  `id` / filename / folder name in agreement yourself.
```
