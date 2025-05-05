extends Node2D
class_name Sword

@onready var area: Area2D = $Sprite2D/Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $Sprite2D/Area2D/CollisionShape2D

var is_vulnerable: bool = false
var is_flipped: bool = false

func _ready() -> void:
	if is_flipped:
		animation_player.play("LeftReset")
	else:
		animation_player.play("RightReset")

func get_area() -> Area2D:
	return area

func get_animation_player() -> AnimationPlayer:
	return animation_player

func is_attacking() -> bool:
	return animation_player.is_playing()

func stop_attack() -> void:
	if animation_player.is_playing():
		animation_player.stop()

func attack():
	if animation_player.is_playing():
		return
	if is_flipped:
		animation_player.play("LeftAttack")
		animation_player.queue("LeftReset")
	else:
		animation_player.play("RightAttack")
		animation_player.queue("RightReset")

func flip(is_flipping: bool) -> void:
	sprite.flip_h = is_flipping
	is_flipped = is_flipping
	if is_flipping:
		animation_player.play("LeftReset")
	else:
		animation_player.play("RightReset")

func set_vulnerable(vulnerable: bool) -> void:
	is_vulnerable = vulnerable
