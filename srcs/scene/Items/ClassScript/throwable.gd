class_name Throwable
extends PickableItem

@onready var collision = $Collision
@onready var area: Area2D = $Area2D
@onready var sprite: Sprite2D = $Sprite2D

@export var speed: int = 250
@export var speed_mult: float = 1
@export var speed_mult_incr: float = 0.1

var atk_damage

var throw_direction_angle: float = 0
var start_angle: float = 0
var has_start_falling: bool = false

var has_hit: bool = false

#parabolic trajectory params, defined in the concrete class
var k_incr
var k

func _ready() -> void:
	area.set_collision_mask_value(5, true)
	area.set_collision_mask_value(6, true)
	super._ready()

func flip(is_flipped):
	sprite.flip_h = is_flipped

func activate_triggers() -> void:
	if has_hit:
		return
	if area.has_overlapping_areas():
		for o_area in area.get_overlapping_areas():
			if o_area.is_in_group("lever"):
				o_area.call("hit")
			elif o_area.is_in_group("rope"):
				player.call("apply_damage", o_area, atk_damage, false)

func transform_angle_increment()-> void:
	start_angle = throw_direction_angle
	if throw_direction_angle > 90 and throw_direction_angle < 270:
		k = -k
	elif throw_direction_angle == 90 or throw_direction_angle == 270:
		k = 0

func on_body_behavior():
	has_hit = true
	for body in area.get_overlapping_bodies():
		if body.is_in_group("enemy") or body.is_in_group("box"):
			player.call("apply_damage", body, atk_damage, true if body.is_in_group("enemy") else false)
		reparent(body, true)
	await get_tree().create_timer(2).timeout
	queue_free()

func throw(delta: float) -> void:
	if has_hit:
		return
	activate_triggers()
	if area.has_overlapping_bodies():
		on_body_behavior()
	else:
		speed_mult += speed_mult_incr
		throw_direction_angle += k
		k *= (1 + (k_incr * delta))
		rotation_degrees = throw_direction_angle
		position += (Vector2.RIGHT * speed).rotated(deg_to_rad(throw_direction_angle)) * delta * speed_mult

func equipped_start():
	debug_printer.print("equipped start")
	#hide()
	area.monitoring = false
	collision.disabled = true
	freeze = true
	
func using_start():
	debug_printer.print("using start")
	freeze = true
	show()
	collision.disabled = true
	area.monitoring = true
	transform_angle_increment()

func using_update(delta: float):
	throw(delta)
