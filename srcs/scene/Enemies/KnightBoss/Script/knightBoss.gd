extends Knight

func _ready() -> void:
	super._ready()
	atk_damage = GameConfig.boss_knight_atk_damage
	MAX_HP = GameConfig.boss_knight_max_hp
	CHASE_SPEED = GameConfig.boss_knight_chase_speed
	ACCELLERATION = GameConfig.boss_knight_acceleration
	SPEED = GameConfig.boss_knight_speed
	hp = MAX_HP
	target_cast_distance = GameConfig.boss_knight_target_cast_distance
	bounds_distance = GameConfig.boss_knight_bound
	bounds.set_bounds(self.position + Vector2(-bounds_distance / 2, 0), self.position + Vector2(bounds_distance / 2, 0))

func take_damage(amount: int):
	if sword.is_vulnerable:
		debug_printer.print("Vulerable")
		super.take_damage(amount)
	else:
		debug_printer.print("Not Vulerable")
		if action_sm.get_active_state().name == "idle" || action_sm.get_active_state().name == "wander":
			action_sm.dispatch(&"to_chase")
