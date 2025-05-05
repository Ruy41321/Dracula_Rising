extends Area2D

@export var bridge: AnimatableBody2D

@onready var lever_up_sprite: Sprite2D = $LeverUp
@onready var lever_down_sprite: Sprite2D = $LeverDown

func hit() -> void:
	if bridge.status != "idle":
		return
	if bridge.is_already_fallen:
		lever_down_sprite.hide()
		lever_up_sprite.show()
		bridge.call("reset")
	else:
		lever_down_sprite.show()
		lever_up_sprite.hide()
		bridge.call("fall")
	
