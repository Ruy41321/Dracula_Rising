extends StaticBody2D

@export var hp_percentage: int = 100
@export_enum("empty", "boomerang", "knife", "spear", "hatchet", "hp_pot", "rage_pot") var item: String

var MAX_HP: int = GameConfig.box_max_hp
var hp = int(MAX_HP / 100.0 * hp_percentage)
var item_instance

func _ready() -> void:
	match item:
		"boomerang":
			item_instance = preload("res://scene/Items/Boomerang/Boomerang.tscn")
		"knife":
			item_instance = preload("res://scene/Items/Knife/Knife.tscn")
		"spear":
			item_instance = preload("res://scene/Items/Spear/Spear.tscn")
		"hatchet":
			item_instance = preload("res://scene/Items/Hatchet/Hatchet.tscn")
		"hp_pot":
			item_instance = preload("res://scene/Items/HpPot/HpPot.tscn")
		"rage_pot":
			item_instance = preload("res://scene/Items/RagePot/RagePot.tscn")
		_:
			item_instance = null

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		get_broken()

func get_broken() -> void:
	if item_instance:
		var instance = item_instance.instantiate()
		instance.position = position
		# to insert animation of destruction
		hide()
		get_parent().add_child(instance)
	queue_free()
