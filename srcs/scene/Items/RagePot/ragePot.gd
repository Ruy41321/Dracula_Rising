class_name RagePot
extends PickableItem

@onready var collision: CollisionShape2D = $CollisionShape2D

var rage_amount

func _ready():
	rage_amount = GameConfig.pot_rage_amount
	super._ready()
	
func use():
	player.update_rage(rage_amount) #to_implement

func using_start():
	use()
	queue_free()
	
func equipped_start():
	debug_printer.print("equipped start")
	freeze = true
	hide()
	collision.disabled = true
	
