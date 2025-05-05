extends AnimatableBody2D

## type "left" or "right"
@export_enum("left", "right") var falling_direction: String = "left"
@export var is_already_fallen: bool = false
@export var degree_to_rotate: int = 90

var speed = 2
var speed_increment = 0.1
var status: String = "idle"

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

func _ready() -> void:
	if falling_direction == "left":
		sprite.position.x = 7
		sprite.flip_v = false
		collision_shape.position.x = 7
	else:
		sprite.position.x = -7
		sprite.flip_v = true
		collision_shape.position.x = -7

var is_rotation_goal_set = false
var rotation_goal

func _process(delta: float) -> void:
	match status:
		"idle":
			speed = 2
		"falling":
			speed += speed_increment
			if falling_direction == "left":
				if !(is_rotation_goal_set):
					is_rotation_goal_set = true
					rotation_goal = rotation_degrees - degree_to_rotate
				rotate(-speed * delta)
				if abs(rotation_goal) - abs(rotation_degrees) <= 2:
					rotation_degrees = rotation_goal
					is_rotation_goal_set = false
					status = "idle"
					is_already_fallen = true
			else:
				if !(is_rotation_goal_set):
					is_rotation_goal_set = true
					rotation_goal = rotation_degrees + degree_to_rotate
				rotate(speed * delta)
				if abs(rotation_goal) - abs(rotation_degrees) <= 2:
					rotation_degrees = rotation_goal
					is_rotation_goal_set = false
					status = "idle"
					is_already_fallen = true
		"resetting":
			speed += speed_increment
			if falling_direction == "left":
				if !(is_rotation_goal_set):
					is_rotation_goal_set = true
					rotation_goal = rotation_degrees + degree_to_rotate
					if abs(int(rotation_goal) - 270) <= 2:
						rotation_goal = -90
				rotate(speed * delta)
				print(rotation_degrees," ", rotation_goal)
				if abs(rotation_degrees) - abs(rotation_goal) <= 2:
					rotation_degrees = rotation_goal
					is_rotation_goal_set = false
					status = "idle"
					is_already_fallen = false
			else:
				if !(is_rotation_goal_set):
					is_rotation_goal_set = true
					rotation_goal = rotation_degrees - degree_to_rotate
					if abs(int(rotation_goal) + 270) <= 2:
						rotation_goal = 90
				rotate(-speed * delta)
				print(rotation_degrees," ", rotation_goal)
				if abs(rotation_degrees) - abs(rotation_goal) <= 2:
					rotation_degrees = rotation_goal
					is_rotation_goal_set = false
					status = "idle"
					is_already_fallen = false

func fall() -> void:
	status = "falling"

func reset() -> void:
	status = "resetting"
	
