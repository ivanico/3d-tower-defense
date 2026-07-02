extends Node

# Combat
signal enemy_died(enemy: Node, position: Vector3)
signal enemy_reached_tower(enemy: Node)
signal tower_damaged(amount: float)
signal tower_healed(amount: float)
signal tower_died

# XP
signal xp_gained(amount: int)
signal level_up(new_level: int)

# Wave
signal start_wave_requested(wave_number: int)
signal wave_started(wave_number: int)
signal wave_cleared(wave_number: int)
signal phase_changed(phase: int)
signal boss_spawned
signal boss_died

# Draft
signal draft_opened(trigger: String)
signal draft_closed
signal card_selected(card: Resource)

# Synergy
signal synergy_threshold_reached(tag: int, level: int)

# Meta
signal run_reset
signal run_ended(victory: bool)
signal materials_earned(amount: int)
signal tower_upgraded(tower_id: String, star: int)
signal spell_ranked_up(spell_id: String, rank: int)
