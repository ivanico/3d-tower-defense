extends "res://scenes/component/tower_ult_component.gd"

## Fire's ult, Ring of Fire (09-13): a ring of flame around the tower; each
## enemy crossing it takes a Fire hit + burn. Star 3: lasts longer. Star 5: the
## ring's hit deals more to enemies already burning. The ring is
## ring_of_fire.tscn.

const RING_OF_FIRE_SCENE := preload("res://scenes/game_object/ring_of_fire/ring_of_fire.tscn")


func _get_school() -> int:
	return Constants.DamageType.FIRE


func _activate(tier: int) -> void:
	var ring := RING_OF_FIRE_SCENE.instantiate()
	tower.get_parent().add_child(ring)
	ring.start(Vector3(tower.global_position.x, 0.0, tower.global_position.z),
			Constants.RING_OF_FIRE_RADIUS,
			tier_value(Constants.RING_OF_FIRE_DURATION),
			scaled_damage(Constants.RING_OF_FIRE_DAMAGE),
			Constants.RING_OF_FIRE_BURNING_BONUS if tier >= 3 else 0.0)
