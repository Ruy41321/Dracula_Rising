extends Node2D
@onready var width = $Area2D/CollisionShape2D
@onready var height = $Area2D/CollisionShape2D
@onready var center = $Marker2D
signal lock_enter
signal lock_exit
@onready var current_scene = get_tree().current_scene
@onready var myCam : PackedScene = preload("res://scene/Levels/Camera/Camera.tscn")
@onready var cam = current_scene.get_node("Camera")

var player: CharacterBody2D
var newCam
var collision_point
@export var has_boss: bool = false

func _ready() -> void:
	GlobalVariables.add_node_to_nodes_with_player(self)

func set_player(node: CharacterBody2D):
	player = node

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		collision_point = body.global_position
		emit_signal("lock_enter")
	pass # Replace with function body.
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		collision_point = body.global_position
		emit_signal("lock_exit")
	pass # Replace with function body.

func _on_lock_enter() -> void:
	newCam = myCam.instantiate()
	current_scene.add_child(newCam)
	newCam.global_position = collision_point
	newCam.scale = cam.scale
	newCam.set_zoom(cam.get_zoom())
	if has_boss:
		newCam.set_zoom(0.6 * cam.get_zoom())
	newCam.make_current()
	newCam.set_position_smoothing_enabled(true)
	newCam.set_position_smoothing_speed(0.7)
	newCam.global_position = center.global_position
	pass

func _on_lock_exit() -> void:
	#var smoothing_point : Vector2
	#var k
	#if player.global_position.x > center.global_position.x:
		#k = -1
		#smoothing_point = Vector2(center.global_position.x + (( player.global_position.x - center.global_position.x) / 2), center.global_position.y +
		#( player.global_position.y - center.global_position.y)/2)
	#else:
		#k = 1
		#smoothing_point = Vector2(center.global_position.x - (( center.global_position.x - player.global_position.x)/ 2), center.global_position.y +
		#( player.global_position.y - center.global_position.y) /2)
	##cam.global_position = smoothing_point
	cam.global_position = collision_point
	cam.make_current()
	newCam.queue_free()
	#print("SMOOTHING_POINT = ", smoothing_point, "CENTER = ", center.global_position, "PLAYER PO = ", player.global_position )
	cam.call_deferred("reparent", get_tree().current_scene)
