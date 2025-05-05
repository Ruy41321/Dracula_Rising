extends Control

@onready var game_over_label = $ColorRect/GameOverLabel
@onready var win_label = $ColorRect/WinLabel
@onready var game_time = $ColorRect/GameTime

@onready var back_button = $ColorRect/HBoxContainer/Back
@onready var retry_button = $ColorRect/HBoxContainer/Retry
@onready var continue_button = $ColorRect/HBoxContainer/Continue

var starting_time: int = 0

func _ready() -> void:
	starting_time = Time.get_ticks_msec()
	hide()

	back_button.pressed.connect(_on_back_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	continue_button.pressed.connect(_on_continue_pressed)

func show_banner(has_win) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	set_game_time_text()
	game_time.show()
	back_button.show()
	if has_win:
		win_label.show()
		game_over_label.hide()
		retry_button.hide()
		continue_button.show()
	else:
		win_label.hide()
		game_over_label.show()
		retry_button.show()
		continue_button.hide()
	visible = 1
	get_tree().paused = 1

func set_game_time_text() -> void:
	var elapsed_time = Time.get_ticks_msec() - starting_time
	var seconds = int(float(elapsed_time) / 1000.0)
	var minutes = int(float(seconds) / 60)
	seconds = seconds % 60
	game_time.text = "La partita è durata:\n\t\t" + str(minutes) + "min e " + str(seconds) + "sec"

func _on_back_pressed() -> void:
	get_tree().paused = 0
	visible = 0
	get_tree().change_scene_to_file("res://scene/StartScreen/StartScreen.tscn")

func _on_retry_pressed() -> void:
	if get_tree().paused == true:
		get_tree().paused = 0
	get_tree().reload_current_scene()

func _on_continue_pressed() -> void:
	get_tree().paused = 0
	visible = 0
	get_tree().change_scene_to_file(GlobalVariables.advance_to_next_level().scene_path)
