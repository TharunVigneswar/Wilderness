
extends Control

func _ready() -> void:
	$Content/RetryButton.pressed.connect(_on_retry)
	$Content/MainMenuButton.pressed.connect(_on_main_menu)


func _on_retry() -> void:
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")


func _on_main_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
