extends Control

@onready var play_button: Button = $MenuContainer/PlayButton
@onready var instructions_button: Button = $MenuContainer/InstructionsButton
@onready var exit_button: Button = $MenuContainer/ExitButton


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	instructions_button.pressed.connect(_on_instructions_pressed)
	exit_button.pressed.connect(_on_exit_pressed)


func _on_play_pressed() -> void:
	GameManager.reset_resources()
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")


func _on_instructions_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/Instructions.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
