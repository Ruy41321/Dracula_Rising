extends Marker2D

@export var debug_mode: bool = false
@export_enum("Knight", "Archer", "Eagle", "KnightBoss", "ArcherBoss", "EagleBoss") var enemy_type: int
## if true the player will win when defeating this enemy
@export var key_boss: bool = false
@export var personal_name: String
@export var archer_can_move: bool = true

@onready var area: Area2D = $Area2D

var knight_path: String = "res://scene/Enemies/Knight/knight.tscn"
var archer_path: String = "res://scene/Enemies/Archer/Archer.tscn"
var eagle_path: String = "res://scene/Enemies/Eagle/Eagle.tscn"
var knight_boss_path: String = "res://scene/Enemies/KnightBoss/KnightBoss.tscn"
var archer_boss_path: String = "res://scene/Enemies/ArcherBoss/ArcherBoss.tscn"
var eagle_boss_path: String = "res://scene/Enemies/EagleBoss/EagleBoss.tscn"

var enemy_path: String
var enemy_instance: Enemies

func _ready() -> void:
	area.body_entered.connect(_on_area_body_entered)
	match enemy_type:
		0:
			enemy_path = knight_path
		1:
			enemy_path = archer_path
		2:
			enemy_path = eagle_path
		3:
			enemy_path = knight_boss_path
		4:
			enemy_path = archer_boss_path
		5:
			enemy_path = eagle_boss_path
	enemy_instance = load(enemy_path).instantiate()
	if enemy_type == 1:
		enemy_instance.can_move = archer_can_move
	if personal_name != "":
		enemy_instance.name = personal_name
	enemy_instance.key_boss = key_boss
	enemy_instance.debug_mode = debug_mode

func _on_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		enemy_instance.position = position
		get_tree().get_root().get_node("Level").call_deferred("add_child", enemy_instance)
		queue_free()
