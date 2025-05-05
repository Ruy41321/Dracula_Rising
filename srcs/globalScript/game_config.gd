extends Node

# Player stats
var player_max_hp: int = 500
var player_max_rage: int = 100
var player_melee_atk_damage: int = 100
var player_divekick_damage: int = 30
var player_speed: float = 120
var player_jump_velocity: float = -300
var player_dash_velocity: float = 300
var player_shove_velocity: float = 250
var player_rage_atk_modifier = 1.0
var player_rage_def_modifier = 0.5
var player_rage_speed_modifier = 0.5
var player_rage_lifesteal_modifier = 0.5
var player_rage_incr_from_defense_modifier = 0.1
var player_rage_incr_from_attack_modifier = 0.05


# Weapon damage
var boomerang_damage: int = 50
var knife_damage: int = 80
var hatchet_damage: int = 120
var spear_damage: int = 150

# Potions
var pot_healing_amount: int = 200
var pot_rage_amount: int = 50

# Environmental objects
var box_max_hp: int = 100
var rope_max_hp: int = 100

# Enemy stats
# Knight
var knight_atk_damage: int = 100
var knight_max_hp: int = 400
var knight_speed: float = 35
var knight_chase_speed: float = 80
var knight_acceleration: float = 300
var knight_bound: float = 250
var knight_target_cast_distance: float = 300.0

# Archer
var archer_atk_damage: int = 80
var archer_max_hp: int = 300
var archer_speed: float = 35
var archer_acceleration: float = 300
var archer_attack_per_second: float = 1

# Eagle
var eagle_atk_damage: int = 250
var eagle_max_hp: int = 100
var eagle_speed: float = 1000
var eagle_acceleration: float = 400
var eagle_v_speed: float = 100.0

# Boss Knight
var boss_knight_atk_damage: int = 250
var boss_knight_max_hp: int = 800
var boss_knight_speed: float = 45
var boss_knight_acceleration: float = 150
var boss_knight_bound: float = 500
var boss_knight_chase_speed: float = 70
var boss_knight_target_cast_distance: float = 500.0

# Boss Archer
var boss_archer_atk_damage: int = 120
var boss_archer_max_hp: int = 600
var boss_archer_speed: float = 35
var boss_archer_acceleration: float = 300
var boss_archer_attack_per_second: float = 0.8

# Boss Eagle
var boss_eagle_atk_damage: int = 200
var boss_eagle_max_hp: int = 300
var boss_eagle_speed: float = 1000
var boss_eagle_acceleration: float = 400
var boss_eagle_v_speed: float = 300
