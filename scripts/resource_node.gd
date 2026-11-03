
extends StaticBody2D

@export_enum("Wood", "Stone") var resource_type: String = "Wood"
@export var resource_amount: int = 3

@onready var interaction_area: Area2D = $InteractionArea
@onready var prompt_label: Label = $PromptLabel

var player_nearby: bool = false


func _ready() -> void:
	prompt_label.visible = false

	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)

	update_prompt()


func update_prompt() -> void:
	if resource_type == "Wood":
		prompt_label.text = "E - Collect Wood"
	else:
		prompt_label.text = "E - Collect Stone"


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		prompt_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		prompt_label.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_nearby:

		if resource_type == "Wood":
			GameManager.add_wood(resource_amount)

		elif resource_type == "Stone":
			GameManager.add_stone(resource_amount)

		prompt_label.visible = false

		get_viewport().set_input_as_handled()
		queue_free()
