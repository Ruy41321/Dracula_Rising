extends Area2D

@export var hp_percentage: int = 100
@export var bridge: AnimatableBody2D

var MAX_HP: int = GameConfig.rope_max_hp
var hp: int = int(MAX_HP / 100.0 * hp_percentage)

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		if !bridge.is_already_fallen:
			bridge.call("fall")
		queue_free()
