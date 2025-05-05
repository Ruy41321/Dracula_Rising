extends Enemies
class_name Archer

@export var can_move: bool = false

@onready var aggro_area: Area2D = $AggroArea
@onready var change_direction_timer: Timer = $ChangeDirectionTimer
@onready var retrait_timer: Timer = $RetraitTimer
@onready var arrow_ray_cast: RayCast2D = $AttackArea/ArrowRayCast
@onready var marker2D: Node2D = $Marker2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var arrow_tscn = preload("res://scene/Enemies/Arrow/Arrow.tscn")

var in_aggro_area: bool = false
var in_aggro: bool = false
var has_to_change_direction: bool = false

#attack
var aps: float
var last_attack_time = 0.0

func _ready():
	MAX_HP = GameConfig.archer_max_hp
	SPEED = GameConfig.archer_speed
	ACCELLERATION = GameConfig.archer_acceleration
	atk_damage = GameConfig.archer_atk_damage
	aps = GameConfig.archer_attack_per_second

	left_floor_cast = $Sprite/LeftFloorCast
	right_floor_cast = $Sprite/RightFloorCast
	atk_area = $AttackArea
	sprite = $Sprite
	aggro_area.body_entered.connect(_on_aggro_area_body_entered)
	aggro_area.body_exited.connect(_on_aggro_area_body_exited)
	change_direction_timer.timeout.connect(_on_change_direction_timer_timeout)
	retrait_timer.timeout.connect(_on_retrait_timer_timeout)
	super._ready()

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	move_and_slide()

func _on_change_direction_timer_timeout() -> void:
	has_to_change_direction = true

func _on_retrait_timer_timeout() -> void:
	in_aggro = false
	action_sm.dispatch(&"to_idle")

func in_line_of_sight(body: Node2D) -> bool:
	arrow_ray_cast.target_position = body.position - self.position
	if arrow_ray_cast.is_colliding():
		if arrow_ray_cast.get_collider() == body:
			return true
	return false

func attack() -> void:
	var elapsed_time = Time.get_ticks_msec()

	if !elapsed_time - last_attack_time >= 1000 / aps:
		return
	last_attack_time = elapsed_time
	debug_printer.print("Attacking")
	marker2D.look_at(target.global_position)
	var arrow = arrow_tscn.instantiate()
	arrow.rotation = marker2D.rotation
	arrow.global_position = marker2D.global_position
	get_parent().add_child(arrow)
	
func _on_aggro_area_body_entered(body: Node2D) -> void:
	# var dir
	if body == target:
		in_aggro_area = true
		# dir = "left" if target.position.x < self.position.x else "right"
		# if dir == direction_sm.get_active_state().name && in_line_of_sight(target):
		# 	in_aggro = true

func _on_aggro_area_body_exited(body: Node2D) -> void:
	if body == target:
		in_aggro = false
		in_aggro_area = false

func idle_start():
	arrow_ray_cast.target_position = Vector2(0, 0)
	retrait_timer.stop()
	if can_move:
		action_sm.dispatch(&"to_wander")
		return
	animation_player.play("idle")
	debug_printer.print("Passing to idle state")
	change_direction_timer.start()
	direction.x = 0

func idle_update(_delta: float):
	velocity.x = direction.x * SPEED
	if in_aggro:
		action_sm.dispatch(&"to_attack")

func wander_start():
	if !can_move:
		action_sm.dispatch(&"to_idle")
		return
	animation_player.play("walk")
	debug_printer.print("Passing to wander state")

func wander_update(delta: float):
	velocity = velocity.move_toward(direction * SPEED, ACCELLERATION * delta)
	if in_aggro:
		action_sm.dispatch(&"to_attack")

func chase_start():
	action_sm.dispatch(&"to_attack")

func attack_start():
	debug_printer.print("Passing to attack state")
	animation_player.play("idle")
	change_direction_timer.stop()
	direction.x = 0

func attack_update(_delta: float):
	velocity.x = direction.x * SPEED
	if in_line_of_sight(target):
		retrait_timer.stop()
		attack()
	else:
		if retrait_timer.is_stopped():
			retrait_timer.start()
	if !is_target_in_range:
		action_sm.dispatch(&"to_idle")

func left_start():
	debug_printer.print("Passing to left state")
	has_to_change_direction = false
	flip_direction(true)
	if can_move && action_sm.get_active_state().name != "attack":
		direction = Vector2(-1, 0)

func left_update(_delta: float):
	if action_sm.get_active_state().name == "die":
		return
	if in_aggro_area:
		if target.position.x <= self.position.x && in_line_of_sight(target):
			in_aggro = true
	if action_sm.get_active_state().name == "wander":
		if can_move:
			direction = Vector2(-1, 0)
		if is_gonna_fall():
			velocity.x = 0
		elif !is_towards_wall():
			return
		if (is_on_floor()):
			direction_sm.dispatch(&"to_right")
	elif (action_sm.get_active_state().name == "attack"):
		if (target.position.x - self.position.x) > 0:
			direction_sm.dispatch(&"to_right")
	elif action_sm.get_active_state().name == "idle":
		if has_to_change_direction:
			direction_sm.dispatch(&"to_right")

func right_start():
	debug_printer.print("Passing to right state")
	has_to_change_direction = false
	flip_direction(false)
	if can_move && action_sm.get_active_state().name != "attack":
		direction = Vector2(1, 0)
	
func right_update(_delta: float):
	if action_sm.get_active_state().name == "die":
		return
	if in_aggro_area:
		if target.position.x >= self.position.x && in_line_of_sight(target):
			debug_printer.print(in_line_of_sight(target))
			in_aggro = true
	if action_sm.get_active_state().name == "wander":
		if can_move:
			direction = Vector2(1, 0)
		if is_gonna_fall():
			velocity.x = 0
		elif !is_towards_wall():
			return
		if (is_on_floor()):
			direction_sm.dispatch(&"to_left")
	elif (action_sm.get_active_state().name == "attack"):
		if (target.position.x - self.position.x) < 0:
			direction_sm.dispatch(&"to_left")
	elif action_sm.get_active_state().name == "idle":
		if has_to_change_direction:
			direction_sm.dispatch(&"to_left")

func die() -> void:
	action_sm.dispatch(&"to_die")

func die_start():
	velocity.x = 0
	set_collision_mask_value(5, false)
	set_collision_mask_value(3, false)
	set_collision_layer_value(5, false)
	await get_tree().create_timer(1).timeout
	super.die()

func die_update(_delta: float):
	pass
