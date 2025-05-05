extends Node2D
class_name Level

@onready var camera: Camera2D = $Camera
@onready var pause_menu: Control = $Camera/CanvasLayer/PauseMenu
@onready var end_game_menu: Control = $Camera/CanvasLayer/EndGameMenu

var player: CharacterBody2D #viene settato dallo spawner
var current_room: int = 0

var room_boundaries: Dictionary = {
	"Left": 0,
	"Right": 0
}

func _ready() -> void:
	set_current_room()
	set_room_boundaries()

func _on_win() -> void:
	end_game_menu.show_banner(true)

func _on_lose() -> void:
	end_game_menu.show_banner(false)

func set_current_room() -> void:
	var camera_limit_count = -1

	for child in get_children():
		if "CameraLimit" in child.name:
			camera_limit_count += 1
			if child.global_position.x <= player.global_position.x:
				current_room = camera_limit_count


func set_room_boundaries() -> void:
	var room_found: bool = false

	for child in get_children():
		if "CameraLimit" + str(current_room) in child.name:
			room_found = true
			room_boundaries.Left = child.position.x
			if not child.body_exited.is_connected(_on_camera_limit_body_exited):
				child.body_exited.connect(_on_camera_limit_body_exited)
		elif "CameraLimit" + str(current_room + 1) in child.name:
			room_found = true
			room_boundaries.Right = child.position.x
			if not child.body_exited.is_connected(_on_camera_limit_body_exited):
				child.body_exited.connect(_on_camera_limit_body_exited)
	if room_found:
		apply_camera_limit()

func apply_camera_limit():
	camera.limit_left = room_boundaries.Left
	camera.limit_right = room_boundaries.Right
	
func _on_camera_limit_body_exited(body: Node2D) -> void:
	if body == player:
		if player.global_position.x <= room_boundaries.Left:
			current_room -= 1
			set_room_boundaries()
		elif player.global_position.x > room_boundaries.Right:
			current_room += 1
			set_room_boundaries()

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("COLLIDED WITH TRAP")
	print("body", body, "name", body.name)
	if body.name == "Player":
		_on_lose()
	pass # Replace with function body.
