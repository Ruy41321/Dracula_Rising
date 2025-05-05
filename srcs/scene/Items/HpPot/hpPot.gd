class_name HpPot
extends PickableItem

@onready var collision: CollisionShape2D = $CollisionShape2D

var healing_amount

func _ready():
	healing_amount = GameConfig.pot_healing_amount
	super._ready()

func use():
	player.heal(healing_amount)

func using_start():
	use()
	queue_free()
	
func equipped_start():
	debug_printer.print("equipped start")
	freeze = true
	hide()
	collision.disabled = true
	
