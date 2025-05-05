extends CharacterBody2D

@export var debug_mode : bool = true


@onready var atk_area_marker: Marker2D = $AtkAreaMarker
@onready var melee_atk_area: Area2D = $AtkAreaMarker/MeleeAttackArea
@onready var melee_collision: CollisionShape2D = $AtkAreaMarker/MeleeAttackArea/CollisionShape2D
@onready var anim: AnimationPlayer = $AnimationPlayer
##al momento per debugging usiamo raycast
@onready var raycast: RayCast2D = $RayCast2D
@onready var detach_ray : RayCast2D = $DetachRay
@onready var vec: Vector2
@onready var dash_shove_timer: Timer = $DashShoveTimer
@onready var healthbar: ProgressBar = $Control/CanvasLayer/Hp_and_Rage_bar/HBoxContainer/HealthBar
@onready var ragebar: ProgressBar = $Control/CanvasLayer/Hp_and_Rage_bar/HBoxContainer2/RageBar
@onready var weapon_marker : Marker2D = $Marker2D
@onready var camera_remote_transform: RemoteTransform2D = $CameraRemote
@onready var walljump_timer = $WallJumpTimer
@onready var fixed_rage_timer = $FixedRageTimer
@onready var chain_animation_player: AnimationPlayer = $AtkAreaMarker/MeleeAttackArea/AnimationPlayer
@onready var chain_sprite: Sprite2D = $AtkAreaMarker/MeleeAttackArea/Sprite2D

var rage_start_val = 0

var MAX_RAGE = GameConfig.player_max_rage
var bloodrage = clamp(rage_start_val, 0 , MAX_RAGE)
var MAXHP = GameConfig.player_max_hp
var hp = MAXHP
var atk_damage = GameConfig.player_melee_atk_damage
var divekick_damage = GameConfig.player_divekick_damage
var SPEED = GameConfig.player_speed
var JUMP_VELOCITY = GameConfig.player_jump_velocity
var DASH_VELOCITY = GameConfig.player_dash_velocity
var SHOVE_VELOCITY = GameConfig.player_shove_velocity
#questi sono i valori per cui verra moltiplicata la bloodrage in fase di attaco, difesa e velocità
var rage_atk_modifier = GameConfig.player_rage_atk_modifier
var rage_def_modifier = GameConfig.player_rage_def_modifier
var rage_speed_modifier = GameConfig.player_rage_speed_modifier
var rage_incr_from_defense_modifier = GameConfig.player_rage_incr_from_defense_modifier
var rage_incr_from_attack_modifier = GameConfig.player_rage_incr_from_attack_modifier


var debug_printer = DebugPrinter.new(self)

var is_dead = false
var elapsed_time = 0.0
enum states{IDLE, WALKING, RUNNING, JUMPING, KICKDIVING, ATK_WHIP, ATK_OTHER,IS_GRAPPLING,AIR_DASH,SHOVING,WALL_JUMP}
enum aim_directions{UP, DOWN, LEFT, RIGHT, UPLEFT, UPRIGHT, DOWNLEFT, DOWNRIGHT}
var aim: aim_directions = aim_directions.RIGHT
var state: states = states.IDLE
var buff_par : float  #additional damage dealt and speed increased by rage
var debuff_par: float #additional damage received proportionally to rage level
var is_jumping: bool = false
var is_shoving: bool = false
var jumps_count: int = 0
var stop_jumps: bool = false
var dash_count: int = 0
var last_horizontal_direction: int = 1
var bullrun_counter = 0
@onready var mySprite = $Sprite2D

var myEquippedItem
var hitted_objects = []

var collected = 0
var item : Object

static  var myevent = InputEvent
# Ctrl + K per commentare o scommentare un blocco di linee
var can_walljump: bool = false
var walljump_speed = 100

var is_rage_fixed = false

func _ready():
	raycast.exclude_parent = true
	detach_ray.exclude_parent = true
	healthbar.max_value = hp
	healthbar.value = hp
	ragebar.value = 0
	get_camera_remote_transform().remote_path = get_tree().get_root().get_node("Level").camera.get_path()
	debug_printer.print("HP = " + str(hp))

func _physics_process(delta: float) -> void:
	elapsed_time += delta
	if hp > MAXHP:#questo if va modulato a seconda degli hp massimi, oppure parametrizzato
		hp = MAXHP
	if is_on_floor():
		if is_jumping:
			state = states.IDLE
		jumps_count = 0
		is_jumping = false
		can_walljump = false
		bullrun_counter = 0
	else:
		can_walljump = false
		velocity += get_gravity() * delta
		if is_on_wall() && !is_on_floor():
			debug_printer.print ("ON WALL")
			can_walljump = true
	if Input.is_action_just_pressed("WhipATK"):
		start_attack()
	var direction := Input.get_axis("A", "D")
	if state == states.IS_GRAPPLING:
		velocity.x = vec.x * DASH_VELOCITY 
		velocity.y = vec.y * DASH_VELOCITY 
		if detach_ray.is_colliding():
			state = states.IDLE
	elif is_shoving:
		_dash_or_shove(SHOVE_VELOCITY)
	elif state == states.WALL_JUMP:
		velocity.x = -direction * (walljump_speed + float(walljump_speed) / 100 * bloodrage * rage_speed_modifier)
	else:
		velocity.x = direction * (SPEED + SPEED / 100 * bloodrage * rage_speed_modifier)
	if direction < 0:
		flip_direction(true)
		last_horizontal_direction = -1
	elif direction > 0:
		flip_direction(false)
		last_horizontal_direction = +1
	_rage_handler()
	_flip_raycast()
	_states_handler()
	move_and_slide()

func _process(delta) -> void:
	if !is_rage_fixed:
		update_rage(-2 * delta)
	if chain_animation_player.current_animation == "Attack":
		attacking()
	if Input.is_action_pressed("A"):
		state = states.WALKING
		aim = aim_directions.LEFT
		if Input.is_action_pressed("W"):
			aim = aim_directions.UPLEFT
		elif Input.is_action_pressed("S"):
			aim = aim_directions.DOWNLEFT
	elif Input.is_action_pressed("D"):
		state = states.WALKING
		aim = aim_directions.RIGHT
		if Input.is_action_pressed("W"):
			aim = aim_directions.UPRIGHT
		elif Input.is_action_pressed("S"):
			aim = aim_directions.DOWNRIGHT
	elif Input.is_action_pressed("W"):
		if state == states.WALKING:
			state = states.IDLE
		aim = aim_directions.UP
	elif Input.is_action_pressed("S"):
		if state == states.WALKING:
			state = states.IDLE
		if !is_on_floor() && aim_directions.DOWN == aim:
			state = states.KICKDIVING
			_divekick()
		else:
			aim = aim_directions.DOWN
	else:
		if state == states.WALKING:
			state = states.IDLE
		aim = aim_directions.RIGHT if not mySprite.flip_h else aim_directions.LEFT
	if Input.is_action_just_pressed("Jump"):
		if can_walljump:
			jumps_count = 0
			walljump_timer.start()
			velocity.y =  (JUMP_VELOCITY + JUMP_VELOCITY / 100 * bloodrage * rage_speed_modifier)
			state = states.WALL_JUMP
		elif jumps_count < 1:
			is_jumping = true
			jumps_count += 1
			state = states.JUMPING
			velocity.y =  (JUMP_VELOCITY + JUMP_VELOCITY / 100 * bloodrage * rage_speed_modifier)
		else:
			pass
		debug_printer.print("is_jumpint = " + str(is_jumping) + " jump_count = " + str(jumps_count) + " STATE = " + str(state))
	if Input.is_action_just_pressed("WhipATK"):
		state = states.ATK_WHIP
		start_attack()
	if Input.is_action_just_pressed("OtherATK"):
		state = states.ATK_OTHER
		_secondary_attack()
	if Input.is_action_just_pressed("Dash_Shove"):
		if dash_count < 1:
			dash_shove_timer.start()
			if is_on_floor():
				if !is_shoving:
					is_shoving = true
					state = states.SHOVING
					_dash_or_shove(SHOVE_VELOCITY)
					debug_printer.print("starting SHOVING")
			else:
				is_shoving = true
				_dash_or_shove(DASH_VELOCITY)
				debug_printer.print("starting AIR_DASH")
			dash_count += 1
	#aggiungo Input legati ai tasti 8, 9 e 0 per debugging della rage
	if Input.is_action_just_pressed("rage_down"):
		update_rage(-25)
	if Input.is_action_just_pressed("rage_up"):
		update_rage(25)
	if Input.is_action_just_pressed("rage_zero"):
		update_rage(-bloodrage)
	#fine debug bloodrage
	# tasto 7 per infliggere danno e tasto 6 per ripristinare gli hp
	if Input.is_action_just_pressed("dealdamage"):
		take_damage(20)
	if Input.is_action_just_pressed("HealDebug"):
		heal(20)
	#fine debug HP

func get_camera_remote_transform() -> RemoteTransform2D:
	return camera_remote_transform

func flip_direction(flip):
	mySprite.flip_h = flip
	chain_sprite.flip_h = flip
	melee_atk_area.position.x = -(abs(melee_atk_area.position.x)) if flip else abs(melee_atk_area.position.x)
	weapon_marker.position.x = -(abs(weapon_marker.position.x)) if flip else abs(weapon_marker.position.x)
	
func _flip_raycast():
	match aim:
		aim_directions.RIGHT:
			raycast.rotation_degrees = 270
			atk_area_marker.rotation_degrees = 0
		aim_directions.LEFT:
			raycast.rotation_degrees = 90
			atk_area_marker.rotation_degrees = 0
		aim_directions.UP:
			raycast.rotation_degrees = 180
			atk_area_marker.rotation_degrees = 90 if mySprite.flip_h else -90
		aim_directions.DOWN:
			raycast.rotation_degrees = 0
			atk_area_marker.rotation_degrees = 90 if !mySprite.flip_h else -90
		aim_directions.UPLEFT:
			raycast.rotation_degrees = 135
			atk_area_marker.rotation_degrees = 45
		aim_directions.UPRIGHT:
			raycast.rotation_degrees = 225
			atk_area_marker.rotation_degrees = -45
		aim_directions.DOWNLEFT:
			raycast.rotation_degrees = 45
			atk_area_marker.rotation_degrees = 315
		aim_directions.DOWNRIGHT:
			raycast.rotation_degrees = 315
			atk_area_marker.rotation_degrees = 45
	detach_ray.rotation_degrees = raycast.rotation_degrees

func take_damage(qty :float) -> void:
	var effective_damage

	debug_printer.print("taking damage from " + str(hp) + " HP to " + str(hp - qty))
	effective_damage = qty + (qty / 100 * (bloodrage * rage_def_modifier))
	hp -= effective_damage
	update_rage(effective_damage * rage_incr_from_defense_modifier)
	is_rage_fixed = true
	fixed_rage_timer.stop()
	fixed_rage_timer.start()
	_update_bars()
	if hp <= 0:
		healthbar.value = 0
		is_dead = true
		get_tree().get_root().get_node("Level")._on_lose()

func heal(qty :float) -> void:
	debug_printer.print("from " + str(hp) + " HP to " + str(hp + qty))
	hp += qty
	_update_bars()
	#emit_signal("update_bars")
	if hp > MAXHP:
		hp = MAXHP


func update_rage(qty : float):
	bloodrage += qty
	if (bloodrage) > MAX_RAGE:
		bloodrage = MAX_RAGE
	elif (bloodrage) < 0:
		bloodrage = 0
	_update_bars()

func use_item() -> void:
	pass
	#implementare la logica per l'uso degli oggetti

func _rage_handler():
	return
	# if bloodrage > 100:
	# 	bloodrage = 100
	# 	buff_par = 100
	# 	debuff_par = 50
	# elif bloodrage < 100 && bloodrage > 75:
	# 	buff_par = 75
	# 	debuff_par = 37.5
	# elif bloodrage < 75 && bloodrage > 50:
	# 	buff_par = 50
	# 	debuff_par = 25
	# elif bloodrage < 50 && bloodrage > 25:
	# 	buff_par = 25
	# 	debuff_par = 12.5
	# else:
	# 	buff_par = 0
	# 	debuff_par = 0

func _grappling_hook():
	state = states.IS_GRAPPLING
	jumps_count = 0
	#da modificare quando ci saranno gli sprite, bisogna aggiungere un collider e muoverlo durante l'animazione
	# oppure lavorare solo di raycast2d
	##debug_printer.print("AIM IS ", aim)
	##debug_printer.print("COLLIDING BODY IS ", raycast.get_collider())
	##debug_printer.print("collision point is ",raycast.get_collision_point())
	##debug_printer.print("velocity is ", velocity," my vec is ", vec)
	##debug_printer.print("velocity after  is ", velocity," my vec is ", vec)
	pass

func apply_damage(body: Node2D, damage: float, incr_rage : bool = true) -> void:
	var effective_damage

	effective_damage = damage + (damage / 100 * (bloodrage * rage_atk_modifier))
	body.call_deferred("take_damage", effective_damage)
	if incr_rage:
		update_rage(effective_damage * rage_incr_from_attack_modifier)
		is_rage_fixed = true
		fixed_rage_timer.stop()
		fixed_rage_timer.start()

func attacking():
	match aim:
		aim_directions.RIGHT :
			vec = Vector2.RIGHT
		aim_directions.LEFT:
			vec = Vector2.LEFT
		aim_directions.UP:
			vec = Vector2.UP
		aim_directions.DOWN:
			vec = Vector2.DOWN
		aim_directions.UPLEFT:
			vec = Vector2(-1,-1)
		aim_directions.UPRIGHT:
			vec = Vector2(1,-1)
		aim_directions.DOWNLEFT:
			vec = Vector2(-1,1)
		aim_directions.DOWNRIGHT:
			vec = Vector2(1,1)
	#debug_printer.print(vec)
	if raycast.is_colliding():
		var current_collider = raycast.get_collider()
		if current_collider.is_in_group("grappable"):
			_grappling_hook()
	#melee_atk_area.position = vec
	for body in melee_atk_area.get_overlapping_bodies():
		if body is Enemies && !hitted_objects.has(body):
			hitted_objects.append(body)
			apply_damage(body, atk_damage)
		if body.is_in_group("box") and !hitted_objects.has(body):
			hitted_objects.append(body)
			apply_damage(body, atk_damage, false)
			#debug_printer.print("Box hit!")
	if melee_atk_area.has_overlapping_areas():
		for o_area in melee_atk_area.get_overlapping_areas():
			if o_area.is_in_group("lever") and !hitted_objects.has(o_area):
				hitted_objects.append(o_area)
				o_area.call("hit")
			elif o_area.is_in_group("rope") and !hitted_objects.has(o_area):
				hitted_objects.append(o_area)
				apply_damage(o_area, atk_damage, false)


func start_attack():
	if chain_animation_player.is_playing():
		return
	debug_printer.print("ATTACKING")
	chain_animation_player.play("Attack")
	chain_animation_player.queue("RESET")
	hitted_objects.clear()
	
func _secondary_attack():
	#debug_printer.print("collected = ", collected)
	#debug_printer.print("secondary ATK ")
	if collected && myEquippedItem:
		myEquippedItem.global_position = weapon_marker.global_position
		match aim:
			aim_directions.RIGHT:
				myEquippedItem.throw_direction_angle = 0
			aim_directions.DOWNRIGHT:
				myEquippedItem.throw_direction_angle = 45
			aim_directions.DOWN:
				myEquippedItem.throw_direction_angle = 90 
			aim_directions.DOWNLEFT:
				myEquippedItem.throw_direction_angle = 135
			aim_directions.LEFT:
				myEquippedItem.throw_direction_angle = 180
			aim_directions.UPLEFT:
				myEquippedItem.throw_direction_angle = 225
			aim_directions.UP:
				myEquippedItem.throw_direction_angle = 270
			aim_directions.UPRIGHT:
				myEquippedItem.throw_direction_angle = 315
		weapon_marker.set_item(null)
		myEquippedItem.state_machine.dispatch(&"to_using")
		collected = 0

##NON CANCELLATE LA FUNZIONE _input ! ! ! !
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("A") and event.is_action_pressed("W"):
		#aim = aim_directions.UPLEFT
	#elif event.is_action_pressed("D") and event.is_action_pressed("W"):
		#aim = aim_directions.UPRIGHT
	#elif event.is_action_pressed("S") and event.is_action_pressed("A"):
		#aim = aim_directions.DOWNLEFT
	#elif event.is_action_pressed("S") and event.is_action_pressed("D"):
		#aim = aim_directions.DOWNRIGHT
	#elif event.is_action_pressed("A"):
		#state = states.WALKING
		#aim = aim_directions.LEFT
	#elif event.is_action_pressed("D"):
		#state = states.WALKING
		#aim = aim_directions.RIGHT
	#elif event.is_action_pressed("W"):
			#aim = aim_directions.UP
	#elif event.is_action_pressed("S"):
		#if !is_on_floor() && aim_directions.DOWN == aim:
			#state = states.KICKDIVING
			#_divekick()
		#else:
			#aim = aim_directions.DOWN
	#elif event.is_action_pressed("Jump"):
		#if can_walljump:
			#walljump_timer.start()
			#velocity.y =  (JUMP_VELOCITY + JUMP_VELOCITY / 100 * buff_par)
			#state = states.WALL_JUMP
			#debug_printer.print("walljump")
		#elif jumps_count < 1:
			#is_jumping = true
			#jumps_count += 1
			#state = states.JUMPING
			#velocity.y =  (JUMP_VELOCITY + JUMP_VELOCITY / 100 * buff_par)
		#else:
			#pass
		##debug_printer.print("is_jumpint = ", is_jumping, " jump_count = ", jumps_count, " STATE = ", state)
	#elif event.is_action_pressed("WhipATK"):
		#state = states.ATK_WHIP
		#attack()
	#elif event.is_action_pressed("OtherATK"):
		#state = states.ATK_OTHER
		#_secondary_attack()
	#elif event.is_action_pressed("Dash_Shove"):
		#if dash_count < 1:
			#dash_shove_timer.start()
			#if is_on_floor():
				#if state != states.SHOVING:
					#state = states.SHOVING
					#_dash_or_shove(SHOVE_VELOCITY)
					##debug_printer.print("starting SHOVING")
			#else:
				#state = states.AIR_DASH
				#_dash_or_shove(DASH_VELOCITY)
				##debug_printer.print("starting AIR_DASH")
			#dash_count += 1
##aggiungo eventi legati ai tasti 8, 9 e 0 per debugging della rage
	#elif event.is_action_pressed("rage_down"):
		#update_rage(-25)
		##debug_printer.print("BLOODRAGE = ", bloodrage)
	#elif event.is_action_pressed("rage_up"):
		#update_rage(25)
		##debug_printer.print("BLOODRAGE = ", bloodrage)
	#elif event.is_action_pressed("rage_zero"):
		#update_rage(-bloodrage)
		##debug_printer.print("BLOODRAGE = ", bloodrage)
##fine debug bloodrage
## tasto 7 per infliggere danno e tasto 6 per ripristinare gli hp
	#elif event.is_action_pressed("dealdamage"):
		#take_damage(20)
	#elif event.is_action_pressed("HealDebug"):
		#heal(20)
##fine debug HP

func _states_handler():#principalemnte per gestire le animazioni
	if state != states.AIR_DASH or state != states.SHOVING:
		dash_count = 0
	match state:
		states.IDLE:
			anim.play("idle_anim")
			pass
		states.WALKING:
			anim.play("walk")
			pass
		states.RUNNING:
			#anim.play("RUNNING")
			pass
		states.JUMPING:
			anim.play("jump")
			pass
		states.KICKDIVING:
			#anim.play("KICKDIVING")
			pass
		states.ATK_WHIP:
			#anim.play("ATK_WHIP")
			pass
		states.ATK_OTHER:
			#anim.play("ATK_OTHER")
			pass
		states.IS_GRAPPLING:
			#anim.play("GRAPPLING")
			pass
		states.AIR_DASH:
			#anim.play("DASH")
			#_dash_or_shove(dash_speed)
			pass
		states.SHOVING:
			#_dash_or_shove(SHOVE_VELOCITY)
			#anim.play("SHOVE")
			pass
		states.WALL_JUMP:
			#_dash_or_shove(SHOVE_VELOCITY)
			#anim.play("WALLJUMP")
			pass



func _dash_or_shove(n : int):
	velocity.x = last_horizontal_direction * ( n + n / 100.0 * bloodrage * rage_speed_modifier)
	debug_printer.print("CURRENT VELOCITY IS " + str(velocity.x))

func _on_melee_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("grappable"):
		pass

func _on_dash_shove_timer_timeout() -> void:
	debug_printer.print("CURRENT VELOCITY IS " + str(velocity.x))
	debug_printer.print("TIMER STOPPED")
	velocity.x = 0
	is_shoving = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("state is ", state)
	if body is Enemies && state == states.KICKDIVING:
		apply_damage(body, atk_damage)
		#debug_printer.print("Enemy hit with divekick for ", atk_damage + (atk_damage / 100 * buff_par) , " points of damage!!! ")
	elif body is Enemies && is_shoving:
		print("hello")
		apply_damage(body, atk_damage)
		#debug_printer.print("Enemy hit with shoving for ", atk_damage + (atk_damage / 100 * buff_par) , " points of damage!!! ")

func _update_bars():
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(healthbar,"value",hp,1)
	tween.tween_property(ragebar,"value",bloodrage,1)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Enemies && state == states.KICKDIVING:
		apply_damage(area.get_parent(), atk_damage)
		#debug_printer.print("Enemy hit with divekick for ", atk_damage + (atk_damage * buff_par) , " points of damage!!! ")
	elif area.get_parent() is Enemies && state == states.SHOVING:
		apply_damage(area.get_parent(), atk_damage)
		#debug_printer.print("Enemy hit with shoving for ", atk_damage + (atk_damage * buff_par) , " points of damage!!! ")
	pass # Replace with function body.

func _divekick():
	#debug_printer.print("DIVEKICK")
	if aim == aim_directions.DOWN && raycast.is_colliding() :
		var current_collider = raycast.get_collider()
		if current_collider is Enemies or current_collider.is_in_group("box"):
			apply_damage(current_collider, atk_damage)
	
func _on_area_2d_2_body_entered(body: Node2D) -> void:
	#debug_printer.print("entered ", body.get, "CURRENT HP is ", hp)
	if body is PickableItem:
		if body is Throwable && collected == 0:
			myEquippedItem = body
			collected = 1
			pickup_item()
		elif body is HpPot && hp < MAXHP:
			heal(body.healing_amount)
			body.queue_free()
		elif body is RagePot && bloodrage < MAX_RAGE:
			update_rage(body.rage_amount)
			body.queue_free()
		#debug_printer.print("collected item ", body.get_class())

func pickup_item():
	weapon_marker.set_item(myEquippedItem)
	myEquippedItem.player = self
	myEquippedItem.state_machine.call_deferred("dispatch", &"to_equipped")

func _on_wall_jump_timer_timeout() -> void:
	state = states.IDLE
	pass # Replace with function body.

func _on_fixed_rage_timer_timeout() -> void:
	is_rage_fixed = false
