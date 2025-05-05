extends Control

var player

@onready var resume: Button = $MarginContainer/VBoxContainer/Resume
@onready var next_level: Button = $MarginContainer/VBoxContainer/Continue
@onready var retry: Button = $MarginContainer/VBoxContainer/Retry
@onready var restart: Button = $MarginContainer/VBoxContainer/Restart
@onready var back: Button = $MarginContainer/VBoxContainer/Back
@onready var quit: Button = $MarginContainer/VBoxContainer/Quit

func _ready() -> void:
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	resume.pressed.connect(_on_resume_pressed)
	next_level.pressed.connect(_on_continue_pressed)
	retry.pressed.connect(_on_retry_pressed)
	restart.pressed.connect(_on_restart_pressed)
	back.pressed.connect(_on_back_pressed)
	quit.pressed.connect(_on_quit_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Esc"):
		if resume.disabled == true:
			return
		if !visible:
			show()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_tree().paused = 1
		else:
			hide()
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			get_tree().paused = 0

func _on_resume_pressed() -> void:
	get_tree().paused = 0
	visible = 0

func _on_continue_pressed() -> void:
	get_tree().paused = 0
	visible = 0
	get_tree().change_scene_to_file(GlobalVariables.advance_to_next_level().scene_path)

func _on_retry_pressed() -> void:
	if get_tree().paused == true:
		get_tree().paused = 0
	get_tree().reload_current_scene()

func _on_restart_pressed() -> void:
	if get_tree().paused == true:
		get_tree().paused = 0
	GlobalVariables.active_spawn_id = 0
	get_tree().reload_current_scene()

func _on_back_pressed() -> void:
	get_tree().paused = 0
	visible = 0
	get_tree().change_scene_to_file("res://scene/StartScreen/StartScreen.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
