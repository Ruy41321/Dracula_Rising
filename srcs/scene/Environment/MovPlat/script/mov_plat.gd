extends Path2D

## set to true if its a looped path like a circle
@export var loop: bool = false
## speed for the looped path
@export var speed: float = 2.0
## speed for the animation (open path):
@export var speed_scale: float = 1.0

@onready var path: PathFollow2D = $PathFollow2D
@onready var animation: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if not loop:
		animation.play("moving")
		animation.speed_scale = speed_scale
		set_process(false)

func _process(delta: float) -> void:
	path.progress_ratio += speed * delta
