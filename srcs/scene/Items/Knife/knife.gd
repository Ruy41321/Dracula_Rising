extends Throwable

var equip_rotation_flipeed: float = -105
var equip_rotation: float = -75
var using_rotation: float = 0

var is_already_flipped: int = 0

func _ready() -> void:
	k_incr = 0.1
	k = 0.1
	atk_damage = GameConfig.knife_damage
	super._ready()

func flip(is_flipped):
	if is_flipped && is_already_flipped != 1:
		is_already_flipped = 1
		rotation_degrees = equip_rotation_flipeed
	elif !is_flipped && is_already_flipped != 2:
		is_already_flipped = 2
		rotation_degrees = equip_rotation

func using_start():
	rotation_degrees = throw_direction_angle
	super.using_start()
