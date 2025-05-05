class_name Enemies
extends Fighter

var target: CharacterBody2D

var is_target_in_range: bool = false
var left_floor_cast: RayCast2D
var right_floor_cast: RayCast2D
var action_sm: LimboHSM
var direction_sm: LimboHSM
var atk_area: Area2D

var last_collision_time: int = 0

func _ready() -> void:
	if not target:
		target = GlobalVariables.player
	initiatiate_action_sm()
	initiate_direction_sm()
	if (self is not Eagle):
		set_collision_layer_value(5,true)
		set_collision_mask_value(1,true)
		set_collision_mask_value(5,true)
		set_collision_mask_value(3,true)
	if atk_area:
		atk_area.body_entered.connect(_on_attack_area_body_entered)
		atk_area.body_exited.connect(_on_attack_area_body_exited)
	super._ready()

func is_towards_wall() -> bool:
	if is_on_wall():
		var current_time = Time.get_ticks_msec()
		if current_time - last_collision_time > 1000:
			last_collision_time = current_time
			return true
		else:
			return false
	return false

func is_on_enemy() -> bool:
	for body in atk_area.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			return true
	return false

func is_gonna_fall() -> bool:
	if velocity.x < 0:
		return !left_floor_cast.is_colliding()
	elif velocity.x > 0:
		return !right_floor_cast.is_colliding()
	if direction_sm.get_active_state().name == "left":
		return !left_floor_cast.is_colliding()
	else:
		return !right_floor_cast.is_colliding()

func take_damage(amount: int) -> void:
	debug_printer.print("Taking damage: " + str(amount))
	if (action_sm.get_active_state().name == "idle" || action_sm.get_active_state().name == "wander"):
		action_sm.dispatch(&"to_chase")
	super.take_damage(amount)

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body == target:
		debug_printer.print("Body entered attack area")
		is_target_in_range = true

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body == target:
		debug_printer.print("Body exited attack area")
		is_target_in_range = false

func initiate_direction_sm() -> void:
	direction_sm = LimboHSM.new()

	add_child(direction_sm)

	var left_state = LimboState.new().named("left").call_on_enter(left_start).call_on_update(left_update)
	var right_state = LimboState.new().named("right").call_on_enter(right_start).call_on_update(right_update)

	direction_sm.add_child(left_state)
	direction_sm.add_child(right_state)

	direction_sm.initial_state = right_state

	# Aggiunta delle transizioni
	direction_sm.add_transition(left_state, right_state, &"to_right")
	direction_sm.add_transition(right_state, left_state, &"to_left")

	direction_sm.initialize(self)
	direction_sm.set_active(true)

func initiatiate_action_sm() -> void:
	action_sm = LimboHSM.new()

	add_child(action_sm)

	var idle_state = LimboState.new().named("idle").call_on_enter(idle_start).call_on_update(idle_update)
	var wander_state = LimboState.new().named("wander").call_on_enter(wander_start).call_on_update(wander_update)
	var chase_state = LimboState.new().named("chase").call_on_enter(chase_start).call_on_update(chase_update)
	var attack_state = LimboState.new().named("attack").call_on_enter(attack_start).call_on_update(attack_update)
	var die_state = LimboState.new().named("die").call_on_enter(die_start).call_on_update(die_update)

	action_sm.add_child(idle_state)
	action_sm.add_child(wander_state)
	action_sm.add_child(chase_state)
	action_sm.add_child(attack_state)
	action_sm.add_child(die_state)

	action_sm.initial_state = wander_state

	# Aggiunta delle transizioni
	action_sm.add_transition(action_sm.ANYSTATE, idle_state, &"to_idle")
	action_sm.add_transition(action_sm.ANYSTATE, wander_state, &"to_wander")
	action_sm.add_transition(action_sm.ANYSTATE, chase_state, &"to_chase")
	action_sm.add_transition(action_sm.ANYSTATE, attack_state, &"to_attack")
	action_sm.add_transition(action_sm.ANYSTATE, die_state, &"to_die")

	action_sm.initialize(self)
	action_sm.set_active(true)

func left_start():
	push_error("left start not implemented")

func left_update(_delta: float):
	push_error("left update not implemented")

func right_start():
	push_error("right start not implemented")

func right_update(_delta: float):
	push_error("right update not implemented")

func idle_start():
	push_error("idle start not implemented")

func idle_update(_delta: float):
	push_error("idle update not implemented")

func wander_start():
	push_error("wander start not implemented")

func wander_update(_delta: float):
	push_error("wander update not implemented")

func chase_start():
	push_error("chase start not implemented")

func chase_update(_delta: float):
	push_error("chase update not implemented")

func attack_start():
	push_error("attack start not implemented")

func attack_update(_delta: float):
	push_error("attack update not implemented")

func die_start():
	push_error("die start not implemented")

func die_update(_delta: float):
	push_error("die update not implemented")
