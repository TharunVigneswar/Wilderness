extends Control


func _ready() -> void:
	$ScrollArea/Content/BackButton.pressed.connect(_on_back_pressed)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
