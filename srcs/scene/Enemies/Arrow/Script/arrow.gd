extends Area2D

var speed: int = 200
var speed_multiplier: float = 1
var speed_multiplier_incr: float = 0.1
var atk_damage: int = 100

var target_group: String = "player"

@onready var visible_on_screen_enabler: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler2D

var has_hit: bool = false

func _ready() -> void:
	visible_on_screen_enabler.screen_exited.connect(_on_screen_exited)

func _process(delta: float) -> void:
	throw(delta)

func throw(delta: float) -> void:
	if has_hit:
		return
	if has_overlapping_bodies():
		has_hit = true
		for body in get_overlapping_bodies():
			if body.is_in_group(target_group):
				body.take_damage(atk_damage)
			reparent(body, true)
		await get_tree().create_timer(2).timeout
		queue_free()
	else:
		speed_multiplier += speed_multiplier_incr
		position += (Vector2.RIGHT * speed).rotated(rotation) * delta * speed_multiplier

func _on_screen_exited() -> void:
	queue_free()
