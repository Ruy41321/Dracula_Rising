class_name Fighter
extends CharacterBody2D

var debug_mode: bool = false
var MAX_HP: float = 0
var SPEED: float
var ACCELLERATION: float
var atk_damage: int
# @export var weapon: Weapon

@onready var debug_printer: DebugPrinter = DebugPrinter.new(self)

var key_boss: bool = false

var sprite: Sprite2D
var hp: float

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: Vector2

func _ready():
	hp = MAX_HP

func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		die()

func attack() -> void:
	push_error("Attack method not implemented")

func flip_direction(is_flipping: bool) -> void:
	sprite.flip_h = is_flipping

func die() -> void:
	if key_boss:
		get_parent()._on_win()
	queue_free()
