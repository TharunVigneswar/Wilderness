
extends Control

func _ready() -> void:
	$Content/PlayAgainButton.pressed.connect(_on_play_again)
	$Content/MainMenuButton.pressed.connect(_on_main_menu)


func _on_play_again() -> void:
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")


func _on_main_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
