extends Eagle

var DECEL: float = 1000

func _ready() -> void:
	super._ready()
	atk_damage = GameConfig.boss_eagle_atk_damage
	MAX_HP = GameConfig.boss_eagle_max_hp
	SPEED = GameConfig.boss_eagle_speed
	ACCELLERATION = GameConfig.boss_eagle_acceleration
	V_SPEED = GameConfig.boss_eagle_v_speed
	hp = MAX_HP

func _on_visible_area_screen_exits() -> void:
	debug_printer.print("Eagle is out of screen")
	if direction_sm.get_active_state().name == "left":
		direction_sm.dispatch(&"to_right")
	else:
		direction_sm.dispatch(&"to_left")

func chase_update(delta: float):
	if ((direction.x < 0 && velocity.x > 0) or (direction.x > 0 && velocity.x < 0)):
		velocity = velocity.move_toward(Vector2(direction.x * SPEED, direction.y * V_SPEED), DECEL * delta)
	else:
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
