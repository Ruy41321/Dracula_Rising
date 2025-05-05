extends Throwable

@export var rotation_speed: float = 6

var is_already_flipped: int = 0

func _ready() -> void:
	k = 1
	k_incr = 0.1
	atk_damage = GameConfig.hatchet_damage
	super._ready()

func transform_angle_increment() -> void:
	match int(throw_direction_angle):
		0:
			throw_direction_angle = 340
		45:
			throw_direction_angle = 15
		135:
			throw_direction_angle = 165
		180:
			throw_direction_angle = 200
		225:
			throw_direction_angle = 215
		315:
			throw_direction_angle = 325
	super.transform_angle_increment()

func flip(is_flipped):
	rotation_degrees = 0
	if is_flipped && is_already_flipped != 1:
		is_already_flipped = 1
		rotation_speed = -rotation_speed
	elif !is_flipped && is_already_flipped != 2:
		is_already_flipped = 2
		rotation_speed = abs(rotation_speed)
	super.flip(is_flipped)

func throw(delta: float) -> void:
	if start_angle == 1000: #only the first time
		transform_angle_increment()
	if has_hit:
		return
	activate_triggers()
	if area.has_overlapping_bodies():
		on_body_behavior()
	else:
		speed_mult += speed_mult_incr
		rotate(rotation_speed * delta)
		throw_direction_angle += k
		k *= (1 + (k_incr * delta))
		position += (Vector2.RIGHT * speed).rotated(deg_to_rad(throw_direction_angle)) * delta * speed_mult
