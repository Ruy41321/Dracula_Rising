extends Throwable

var equip_rotation_flipeed: float = -105
var equip_rotation: float = -75
var using_rotation: float = 0

var is_already_flipped: int = 0

func _ready() -> void:
	k = 2
	k_incr = 0.3
	atk_damage = GameConfig.spear_damage
	super._ready()

func transform_angle_increment() -> void:
	match int(throw_direction_angle):
		0:
			throw_direction_angle = 315
		180:
			throw_direction_angle = 225
		225:
			throw_direction_angle = 240
		315:
			throw_direction_angle = 300
		45:
			throw_direction_angle = 0
		135:
			throw_direction_angle = 180
	super.transform_angle_increment()

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
