extends Enemies
class_name Knight

var CHASE_SPEED
var bounds_distance
var target_cast_distance

@onready var target_cast: RayCast2D = $Sprite/TargetRayCast
@onready var sword: Sword = $Sword
@onready var anim : AnimationPlayer = $AnimationPlayer

var bounds: Bounds = Bounds.new()
var retrait_timer: Timer
var can_try_to_move: bool = false

func _ready():
	MAX_HP = GameConfig.knight_max_hp
	CHASE_SPEED = GameConfig.knight_chase_speed
	ACCELLERATION = GameConfig.knight_acceleration
	SPEED = GameConfig.knight_speed
	atk_damage = GameConfig.knight_atk_damage
	bounds_distance = GameConfig.knight_bound
	target_cast_distance = GameConfig.knight_target_cast_distance

	retrait_timer = $RetraitTimer
	retrait_timer.timeout.connect(_on_retrait_timer_timeout)
	left_floor_cast = $Sprite/LeftFloorCast
	right_floor_cast = $Sprite/RightFloorCast
	atk_area = $Sword/AttackArea
	bounds.set_bounds(self.position + Vector2(-bounds_distance/2, 0), self.position + Vector2(bounds_distance/2, 0))
	sprite = $Sprite
	sword.get_area().body_entered.connect(_on_player_hit)
	super._ready()

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	move_and_slide()

func start_retrait():
	if retrait_timer.time_left <= 0:
		retrait_timer.start()

func flip_direction(is_flipping: bool) -> void:
	if is_flipping != sprite.flip_h:
		sword.position.x *= -1
		sword.flip(is_flipping)
	super.flip_direction(is_flipping)
	#flip the target rayCast
	target_cast.target_position = Vector2(-target_cast_distance, 0) if is_flipping \
		else Vector2(target_cast_distance, 0)
	#flip the attack area
	atk_area.position.x = -(abs(atk_area.position.x)) if is_flipping else abs(atk_area.position.x)

func _on_player_hit(body: Node) -> void:
	if body.is_in_group("player"):
		body.take_damage(atk_damage)
		debug_printer.print("Knight has hit Player!")

func attack() -> void:
	if not sword.is_attacking():
		sword.attack()

func _on_retrait_timer_timeout() -> void:
	action_sm.dispatch(&"to_wander")
	if direction_sm.get_active_state().name == "left":
		direction_sm.dispatch(&"to_right")
	else:
		direction_sm.dispatch(&"to_left")

func idle_start():
	debug_printer.print("Passing to idle state")
	anim.play("Idle")
	if is_on_wall() || is_gonna_fall():
		can_try_to_move = true
	direction.x = 0
	start_retrait()

func idle_update(_delta: float):
	velocity.x = direction.x * SPEED
	if is_target_in_range:
		action_sm.dispatch(&"to_attack")
	elif direction.x != 0:
		action_sm.dispatch(&"to_chase")

func wander_start():
	debug_printer.print("Passing to wander state")
	anim.play("Walk")

func wander_update(delta: float):
	velocity = velocity.move_toward(direction * SPEED, ACCELLERATION * delta)
	if target_cast.is_colliding():
		if target == target_cast.get_collider():
			action_sm.dispatch(&"to_chase")
	if is_target_in_range:
		action_sm.dispatch(&"to_attack")
		
func chase_start():
	debug_printer.print("Passing to chase state")
	anim.play("Walk")
	retrait_timer.stop()

func chase_update(delta: float):
	if (is_gonna_fall() || (is_on_wall() && !is_on_enemy() && !is_target_in_range)) && is_on_floor():
		action_sm.dispatch(&"to_idle")
		return
	velocity = velocity.move_toward(direction * CHASE_SPEED, ACCELLERATION * delta)
	if target_cast.is_colliding() && target == target_cast.get_collider():
		retrait_timer.stop()
	else:
		start_retrait()
	if is_target_in_range:
		action_sm.dispatch(&"to_attack")

func attack_start():
	debug_printer.print("Passing to attack state")
	attack()

func attack_update(delta: float):
	if not (is_gonna_fall() || (is_on_wall() && !is_on_enemy() && !is_target_in_range)) && is_on_floor():
		velocity = velocity.move_toward(direction * CHASE_SPEED, ACCELLERATION * delta)
	if !sword.is_attacking():
		action_sm.dispatch(&"to_chase")
	if target_cast.is_colliding() && target == target_cast.get_collider():
		retrait_timer.stop()
	if is_gonna_fall():
		velocity.x = 0

func left_start():
	debug_printer.print("Passing to left state")
	flip_direction(true)
	direction = Vector2(-1, 0)

func left_update(_delta: float):
	if action_sm.get_active_state().name == "die":
		return
	if action_sm.get_active_state().name == "wander":
		if is_gonna_fall():
			velocity.x = 0
		elif bounds.is_in_left_bound(position) && !is_towards_wall():
			return
		if (is_on_floor()):
			direction_sm.dispatch(&"to_right")
	else:
		# Chase state. Follow player
		var new_direction = (target.position.x - self.position.x)
		new_direction = sign(new_direction)
		if new_direction == 1 && sword.is_attacking():
			new_direction = 0
		direction.x = new_direction
		if direction.x == 1:
			# flip to moving right
			direction_sm.dispatch(&"to_right")
		elif action_sm.get_active_state().name == "idle":
			if can_try_to_move:
				direction.x = 0

func right_start():
	debug_printer.print("Passing to right state")
	flip_direction(false)
	direction = Vector2(1, 0)

func right_update(_delta: float):
	if action_sm.get_active_state().name == "die":
		return
	if action_sm.get_active_state().name == "wander":
		if is_gonna_fall():
			velocity.x = 0
		elif bounds.is_in_right_bound(position) && !is_towards_wall():
			return
		if (is_on_floor()):
			direction_sm.dispatch(&"to_left")
	else:
		# Chase state. Follow player
		var new_direction = (target.position.x - self.position.x)
		new_direction = sign(new_direction)
		if new_direction == -1 && sword.is_attacking():
			new_direction = 0
		direction.x = new_direction
		if direction.x == -1:
			# flip to moving right
			direction_sm.dispatch(&"to_left")
		elif action_sm.get_active_state().name == "idle":
			if can_try_to_move:
				direction.x = 0

func die() -> void:
	action_sm.dispatch(&"to_die")

func die_start():
	velocity.x = 0
	sword.stop_attack()
	set_collision_mask_value(5, false)
	set_collision_mask_value(3, false)
	set_collision_layer_value(5, false)
	await get_tree().create_timer(1).timeout
	super.die()

func die_update(_delta: float):
	pass
