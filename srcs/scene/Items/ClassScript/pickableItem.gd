class_name PickableItem
extends RigidBody2D

@export var debug_mode: bool = false
var debug_printer: DebugPrinter = DebugPrinter.new(self)

var player: CharacterBody2D

var state_machine: LimboHSM

func _ready() -> void:
	initiatiate_sm()
	set_collision_layer_value(4, true)
	set_collision_mask_value(1, true)

func flip(_is_flipped):
	pass

func initiatiate_sm() -> void:
	state_machine = LimboHSM.new()

	add_child(state_machine)

	var pickup_state = LimboState.new().named("pickup").call_on_enter(pickup_start).call_on_update(pickup_update)
	var equipped_state = LimboState.new().named("equipped").call_on_enter(equipped_start).call_on_update(equipped_update)
	var using_state = LimboState.new().named("using").call_on_enter(using_start).call_on_update(using_update)

	state_machine.add_child(pickup_state)
	state_machine.add_child(equipped_state)
	state_machine.add_child(using_state)

	state_machine.initial_state = pickup_state

	# Aggiunta delle transizioni
	state_machine.add_transition(state_machine.ANYSTATE, pickup_state, &"to_pickup")
	state_machine.add_transition(state_machine.ANYSTATE, equipped_state, &"to_equipped")
	state_machine.add_transition(state_machine.ANYSTATE, using_state, &"to_using")

	state_machine.initialize(self)
	state_machine.set_active(true)

func pickup_start():
	debug_printer.print("pickup start")

func pickup_update(_delta: float):
	pass

func equipped_start():
	debug_printer.print("equipped start")

func equipped_update(_delta: float):
	pass

func using_start():
	debug_printer.print("using start")

func using_update(_delta: float):
	push_error("using_update not implemented")
