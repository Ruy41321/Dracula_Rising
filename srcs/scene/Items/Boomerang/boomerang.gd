extends Throwable

var rotation_speed: float = 3

var equip_rotation_flipeed: float = 0
var equip_rotation: float = 0
var using_rotation: float = 0

var is_already_flipped: int = 0

var throw_direction: Vector2
var starting_position: Vector2
var distance_percentage: float
var max_distance: float
var last_body_hit: Node = null

var can_apply_damage: bool = true
var atk_cd: float = 0.5

func _ready() -> void:
	k = 0
	k_incr = 0
	speed = 150
	atk_damage = GameConfig.boomerang_damage
	super._ready()

func flip(is_flipped):
	if is_flipped && is_already_flipped != 1:
		is_already_flipped = 1
		rotation_speed = -rotation_speed
		rotation_degrees = equip_rotation_flipeed
	elif !is_flipped && is_already_flipped != 2:
		is_already_flipped = 2
		rotation_speed = abs(rotation_speed)
		rotation_degrees = equip_rotation
	super.flip(is_flipped)

func equipped_start():
	is_already_flipped = 0
	super.equipped_start()

func using_start():
	throw_direction = Vector2.RIGHT
	max_distance = 300
	distance_percentage = 0
	speed_mult = 1
	speed_mult_incr = 0.1
	rotation_degrees = throw_direction_angle
	starting_position = position
	has_hit = false
	last_body_hit = null
	super.using_start()

func throw(delta: float) -> void:
	if has_hit:
		return
	activate_triggers()
	if area.has_overlapping_bodies():
		for body in area.get_overlapping_bodies():
			if body.is_in_group("enemy") or body.is_in_group("box"):
				if body != last_body_hit:
					player.call("apply_damage", body, atk_damage, true if body.is_in_group("enemy") else false)
					if throw_direction == Vector2.RIGHT:
						throw_direction = Vector2.LEFT
						collision.disabled = false
						speed_mult_incr *= -1
						speed_mult = 1
					last_body_hit = body
				else:
					continue
			else:
				reparent(body, true)
				has_hit = true
				await get_tree().create_timer(2).timeout
				queue_free()
	var distance = max(abs(position.x - starting_position.x), abs(position.y - starting_position.y))
	distance_percentage = distance / max_distance * 100
	if distance_percentage >= 100 && throw_direction == Vector2.RIGHT:
		throw_direction = Vector2.LEFT
		collision.disabled = false
		speed_mult_incr *= -1
		speed_mult = 1
	if distance_percentage < 50 and throw_direction == Vector2.RIGHT:
		speed_mult += speed_mult_incr
	else:
		speed_mult -= speed_mult_incr
	rotate(rotation_speed * delta)
	throw_direction_angle += k
	k *= (1 + (k_incr * delta))
	position += (throw_direction * speed).rotated(deg_to_rad(throw_direction_angle)) * delta * speed_mult
