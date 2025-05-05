extends Archer

@onready var tp_timer: Timer = $TeleportTimer

var tp_counter = -1
var tp_nodes = []
var current_tp_id = 0

func _ready() -> void:
	tp_timer.timeout.connect(teleport)
	for node in get_tree().get_root().get_node("Level").get_children():
		if "TeleportPoint" in node.name:
			tp_counter += 1
			tp_nodes.append(node)
	super._ready()
	atk_damage = GameConfig.boss_archer_atk_damage
	MAX_HP = GameConfig.boss_archer_max_hp
	SPEED = GameConfig.archer_speed
	ACCELLERATION = GameConfig.archer_acceleration
	aps = GameConfig.archer_attack_per_second
	hp = MAX_HP

func teleport() -> void:
	var tp_id = null
	var tp_progression = 0

	if tp_counter == -1:
		return
	while(tp_id == null or tp_id == current_tp_id):
		tp_id = randi_range(0, tp_counter)
	current_tp_id = tp_id
	while (tp_progression <= 0.5):
		tp_progression += 0.01
		sprite.material.set_shader_parameter("progress", tp_progression)
		await get_tree().create_timer(0.01).timeout
	global_position = tp_nodes[tp_id].global_position
	while (tp_progression >= 0):
		tp_progression -= 0.01
		sprite.material.set_shader_parameter("progress", tp_progression)
		await get_tree().create_timer(0.01).timeout

func attack_start() -> void:
	teleport()
	tp_timer.stop()
	tp_timer.start()
	super.attack_start()
