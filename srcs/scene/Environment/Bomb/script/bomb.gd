extends StaticBody2D

@onready var explosion = $ColorRect

var hp = 5
var frame_scope
var is_broken = false

func _ready() -> void:
	frame_scope = explosion.material.get_shader_parameter("frame_scope")

func _process(delta: float) -> void:
	if is_broken:
		frame_scope -= (5 * delta)
		explosion.material.set_shader_parameter("frame_scope", frame_scope)
	if frame_scope <= 1.5:
		queue_free()

func take_damage(amount: int) -> void:
	print("Bomb took damage: ", amount)
	hp -= amount
	if hp <= 0:
		is_broken = true
		explosion.visible = true
