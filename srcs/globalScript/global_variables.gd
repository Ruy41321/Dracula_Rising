extends Node2D

var current_level_id: int = 1
var is_game_completed: bool = false
var higher_completed_level_id: int = 0

var active_spawn_id: int = 0
var current_level_spawn_id: int = 0

var player: CharacterBody2D

var player_spawn: Node2D
var nodes_with_player: Array = []

func set_player(new_player: CharacterBody2D) -> void:
	player = new_player

func set_player_spawn(new_player_spawn: Node2D) -> void:
	player_spawn = new_player_spawn
	for node in nodes_with_player:
		player_spawn.add_node_to_nodes_with_player(node)
	nodes_with_player.clear()

func add_node_to_nodes_with_player(node: Node2D) -> void:
	if !player_spawn:
		nodes_with_player.append(node)
	else:
		player_spawn.add_node_to_nodes_with_player(node)

var levels: Dictionary = {
	1: {"scene_path": "res://scene/Levels/Level1.tscn"},
	2: {"scene_path": "res://scene/Levels/Level2.tscn"},
	3: {"scene_path": "res://scene/Levels/Level3.tscn"},
	4: {"scene_path": "res://scene/Levels/Level4.tscn"},
	5: {"scene_path": "res://scene/StartScreen/StartScreen.tscn"},
}

func get_current_level() -> Dictionary:
	return levels["level_" + str(current_level_id)]

func advance_to_next_level() -> Dictionary:
	if current_level_id > higher_completed_level_id:
		higher_completed_level_id = current_level_id
	current_level_id += 1
	if current_level_id == levels.size():
		is_game_completed = true
	return levels[current_level_id]
