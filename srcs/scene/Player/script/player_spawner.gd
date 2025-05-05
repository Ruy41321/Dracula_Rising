extends Marker2D

@export var spawn_id: int = -1
@onready var area: Area2D = $Area2D

var player_path: String = "res://scene/Player/Player.tscn"
var player_instance: CharacterBody2D

var nodes_with_player: Array = []

func _ready() -> void:
	if spawn_id == -1:
		return
	if GlobalVariables.current_level_id != GlobalVariables.current_level_spawn_id:
		GlobalVariables.current_level_spawn_id = GlobalVariables.current_level_id
		GlobalVariables.active_spawn_id = 0
	if spawn_id == GlobalVariables.active_spawn_id:
		GlobalVariables.set_player_spawn(self)
		area.hide()
		player_instance = load(player_path).instantiate()
		GlobalVariables.set_player(player_instance)
		add_player_to_nodes()
		get_tree().get_root().get_node("Level").player = player_instance
		player_instance.global_position = global_position
		get_tree().get_root().get_node("Level").call_deferred("add_child", player_instance)
	elif spawn_id > GlobalVariables.active_spawn_id:
		area.body_entered.connect(_on_area_body_entered)
	
func add_node_to_nodes_with_player(node: Node2D):
	if player_instance:
		if node.has_method("set_player"):
			node.set_player(player_instance)
		elif node.get_property_list().any(func f(property): return property.name == "player"):
			node.player = player_instance
	else:
		nodes_with_player.append(node)

func add_player_to_nodes() -> void:
	if !player_instance:
		return
	for node: Node2D in nodes_with_player:
		if node.has_method("set_player"):
			node.set_player(player_instance)
		elif node.get_property_list().any(func f(property): return property.name == "player"):
			node.player = player_instance

func _on_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		GlobalVariables.active_spawn_id = spawn_id
		GlobalVariables.current_level_spawn_id = GlobalVariables.current_level_id
		area.body_entered.disconnect(_on_area_body_entered)
		area.hide()
