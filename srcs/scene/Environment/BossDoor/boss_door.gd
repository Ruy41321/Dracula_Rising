extends Node2D

@export_enum ("Purple", "Grey", "Green", "Brown") var tileset_color: String
@onready var tileset1 = $TileMapLayer1
@onready var tileset2 = $TileMapLayer2
@onready var tileset3 = $TileMapLayer3
@onready var tileset4 = $TileMapLayer4
@onready var collider = $StaticBody2D/CollisionShape2D
@onready var timer = $Timer
@onready var tile_source = 0
@onready var my_vec : Vector2
@onready var source_vec: Vector2
@onready var i = 10
var mytile

func _ready() -> void:
	tileset1.hide()
	tileset2.hide()
	tileset3.hide()
	tileset4.hide()
	collider.set_disabled(true)
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.position.x += 100
		

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		collider.set_deferred("disabled", false)
		match tileset_color:
			"Purple":
				mytile = tileset1
				tileset1.show()
				#print("PURPLE")
			"Grey":
				mytile = tileset2
				tile_source = 2
				tileset2.show()
				#print("GREY")
			"Green":
				mytile = tileset3
				tile_source = 4
				#timer.start(0.2)
				tileset3.show()
				#print("GREEN")
			"Brown":
				mytile = tileset4
				tile_source = 6
				tileset4.show()
				#print("BROWN")
		timer.start(0.2)
		
	pass # Replace with function body.

func animate_door(tmlayer : TileMapLayer):
	if i % 2:
		my_vec = Vector2(-1, -i)
		source_vec = Vector2(0,tile_source)
		tmlayer.set_cell(my_vec,0,source_vec)
		my_vec = Vector2(0,-i)
		source_vec = Vector2(0, tile_source)
		tmlayer.set_cell(my_vec,0,source_vec)
	else:
		my_vec = Vector2(-1,-i)
		source_vec = Vector2(0,tile_source +1)
		tmlayer.set_cell(my_vec,0,source_vec)
		my_vec = Vector2(0,-i)
		source_vec = Vector2(0, tile_source +1)
		tmlayer.set_cell(my_vec,0,source_vec)
	i -= 1
	if i > 0:
		timer.start(0.1)
	else:
		timer.queue_free()
		
		
	#var y_size = tmlayer.get_used_cells().height
	
	pass


func _on_timer_timeout() -> void:
	animate_door(mytile)
	pass # Replace with function body.
