extends Control

@export var debug_mode: bool = false

@onready var main_menu = $ColorRect/MainMenu
@onready var level_menu = $ColorRect/LevelMenu
@onready var completed_game_panel = $ColorRect/CompletedGamePanel
@onready var credits_panel = $ColorRect/CreditsPanel
@onready var settings_panel = $ColorRect/SettingsPanel

@onready var debug_box: CheckBox = $ColorRect/SettingsPanel/DebugBox

@onready var play_button: Button = $ColorRect/MainMenu/Play
@onready var settings_button: Button = $ColorRect/MainMenu/Settings
@onready var credits_button: Button = $ColorRect/MainMenu/Credits
@onready var quit_button: Button = $ColorRect/MainMenu/Quit
@onready var back_button: Button = $ColorRect/LevelMenu/Back
@onready var close_panel_button: TextureButton = $ColorRect/CompletedGamePanel/CloseCompletedPanelButton
@onready var close_credits_button: TextureButton = $ColorRect/CreditsPanel/CloseCreditsPanelButton
@onready var close_settings_button: TextureButton = $ColorRect/SettingsPanel/CloseSettingsPanelButton
@onready var level1_button: Button = $ColorRect/LevelMenu/Level1
@onready var level2_button: Button = $ColorRect/LevelMenu/Level2
@onready var level3_button: Button = $ColorRect/LevelMenu/Level3
@onready var level4_button: Button = $ColorRect/LevelMenu/Level4

func _ready():
	play_button.pressed.connect(_on_Play_pressed)
	settings_button.pressed.connect(_on_Settings_pressed)
	credits_button.pressed.connect(_on_Credits_pressed)
	quit_button.pressed.connect(_on_Quit_pressed)
	level1_button.pressed.connect(_on_Level1_pressed)
	level2_button.pressed.connect(_on_level_2_pressed)
	level3_button.pressed.connect(_on_level3_pressed)
	level4_button.pressed.connect(_on_level4_pressed)
	back_button.pressed.connect(_on_Back_pressed)
	close_panel_button.pressed.connect(_on_Back_pressed)
	close_credits_button.pressed.connect(_on_Back_pressed)
	close_settings_button.pressed.connect(_on_Back_pressed)
	debug_box.toggled.connect(_on_DebugBox_toggled)

	credits_panel.hide()
	level_menu.hide()
	if GlobalVariables.is_game_completed:
		main_menu.hide()
		completed_game_panel.show()
	else:
		completed_game_panel.hide()
		main_menu.show()

func _on_Play_pressed():
	if debug_mode:
		main_menu.hide()
		level_menu.show()
	else:
		if GlobalVariables.higher_completed_level_id == 0:
			_on_Level1_pressed()
		else:
			main_menu.hide()
			var showed_levels = 0
			for button in level_menu.get_children():
				if showed_levels > GlobalVariables.higher_completed_level_id:
					button.hide()
				else:
					showed_levels += 1
			level_menu.show()

func _on_Settings_pressed():
	main_menu.hide()
	settings_panel.show()

func _on_Credits_pressed():
	main_menu.hide()
	credits_panel.show()

func _on_Quit_pressed():
	get_tree().quit()

func _on_Level1_pressed():
	GlobalVariables.current_level_id = 1
	get_tree().change_scene_to_file("res://scene/Levels/Level1.tscn")

func _on_level_2_pressed() -> void:
	GlobalVariables.current_level_id = 2
	get_tree().change_scene_to_file("res://scene/Levels/Level2.tscn")
func _on_level3_pressed():
	GlobalVariables.current_level_id = 3
	get_tree().change_scene_to_file("res://scene/Levels/Level3.tscn")

func _on_level4_pressed():
	GlobalVariables.current_level_id = 4
	get_tree().change_scene_to_file("res://scene/Levels/Level4.tscn")

func _on_Back_pressed():
	settings_panel.hide()
	completed_game_panel.hide()
	credits_panel.hide()
	level_menu.hide()
	main_menu.show()

func _on_DebugBox_toggled(checked: bool) -> void:
	debug_mode = checked
