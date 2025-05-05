extends Enemies
class_name Eagle

var V_SPEED: float

@onready var dead_area: Area2D = $DeadArea
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var visible_area: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var collision_damage: int = 100
var can_apply_damage: bool = true
var atk_cd: float = 0.5

func _ready() -> void:
	MAX_HP = GameConfig.eagle_max_hp
	SPEED = GameConfig.eagle_speed
	ACCELLERATION = GameConfig.eagle_acceleration
	V_SPEED = GameConfig.eagle_v_speed
	atk_damage = GameConfig.eagle_atk_damage

	sprite = $Sprite2D
	atk_area = $AtkArea
	visible_area.screen_exited.connect(_on_visible_area_screen_exits)
	visible_area.screen_entered.connect(_on_visible_area_screen_entered)
	super._ready()
	debug_printer.print("Eagle hp: " + str(hp))
	set_collision_layer_value(6, true)
	if target.position.x - self.position.x < 0:
		direction_sm.dispatch(&"to_left")
	else:
		direction_sm.dispatch(&"to_right")

func _physics_process(_delta: float) -> void:
	move_and_slide()

func _on_visible_area_screen_exits() -> void:
	debug_printer.print("Eagle is out of screen")
	queue_free()

func _on_visible_area_screen_entered() -> void:
	debug_printer.print("Eagle is in screen")
	if action_sm.get_active_state().name == "idle":
		action_sm.dispatch(&"to_chase")

func die() -> void:
	action_sm.dispatch(&"to_die")

func flip_direction(flip: bool) -> void:
	var right_collision_dead = dead_area.get_node("RightCollision")
	var left_collision_dead = dead_area.get_node("LeftCollision")
	var right_collision_atk = atk_area.get_node("RightCollision")
	var left_collision_atk = atk_area.get_node("LeftCollision")
		
	if flip:
		collision.position.x = -(abs(collision.position.x))
		right_collision_dead.disabled = false
		right_collision_dead.visible = true
		left_collision_dead.disabled = true
		left_collision_dead.visible = false
		
		right_collision_atk.disabled = false
		right_collision_atk.visible = true
		left_collision_atk.disabled = true
		left_collision_atk.visible = false
	else:
		collision.position.x = abs(collision.position.x)
		right_collision_dead.disabled = true
		right_collision_dead.visible = false
		left_collision_dead.disabled = false
		left_collision_dead.visible = true
		
		right_collision_atk.disabled = true
		right_collision_atk.visible = false
		left_collision_atk.disabled = false
		left_collision_atk.visible = true
	super.flip_direction(not flip) # I pass not flip because the eagle sprite is oriented to the left instead all the other are to the right

func left_start():
	debug_printer.print("Passing to left state")
	if action_sm.get_active_state().name != "die":
		flip_direction(true)
	direction = Vector2(-1, 0)

func left_update(_delta: float):
	if action_sm.get_active_state().name == "die":
		return
	# Chase state. Follow player
	direction.y = target.position.y - self.position.y - 40 # 40 is the offset to make the eagle fly above the player
	direction.y = sign(direction.y)
	# if target.position.x > self.position.x:
	# 	# flip to moving right
	# 	await get_tree().create_timer(change_direction_delay).timeout
	# 	direction_sm.dispatch(&"to_right")

func right_start():
	debug_printer.print("Passing to right state")
	if action_sm.get_active_state().name != "die":
		flip_direction(false)
	direction = Vector2(1, 0)

func right_update(_delta: float):
	if action_sm.get_active_state().name == "die":
		return
	# Chase state. Follow player
	direction.y = target.position.y - self.position.y -40 # 40 is the offset to make the eagle fly above the player
	direction.y = sign(direction.y)
	# if target.position.x < self.position.x:
	# 	# flip to moving right
	# 	await get_tree().create_timer(change_direction_delay).timeout
	# 	direction_sm.dispatch(&"to_left")

func idle_start():
	debug_printer.print("Passing to idle state")

func idle_update(_delta: float):
	pass

func wander_start():
	action_sm.dispatch(&"to_idle")

func chase_start():
	debug_printer.print("Passing to chase state")

func chase_update(delta: float):
	velocity = velocity.move_toward(Vector2(direction.x * SPEED, direction.y * V_SPEED), ACCELLERATION * delta)
	if is_target_in_range and can_apply_damage:
		target.take_damage(atk_damage)
		can_apply_damage = false
		await get_tree().create_timer(atk_cd).timeout
		can_apply_damage = true
	if dead_area.has_overlapping_bodies():
		for body in dead_area.get_overlapping_bodies():
			if body != self:
				take_damage(collision_damage)

func die_start():
	debug_printer.print("Passing to die state")
	animation_player.play("die")
	velocity = Vector2(0, 0)
	collision.disabled = true
	await get_tree().create_timer(1.0).timeout
	super.die()

func die_update(delta: float):
	if sprite.rotation_degrees > 110:
		position.y += 300 * delta
