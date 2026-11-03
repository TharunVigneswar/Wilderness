
extends StaticBody2D

var player_nearby: bool = false


func _ready() -> void:
	var area = $InteractionArea

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)


func _draw() -> void:
	draw_rect(
		Rect2(-9, 0, 18, 30),
		Color("#79502e")
	)

	draw_circle(Vector2(0, -15), 27, Color("#285b35"))
	draw_circle(Vector2(-15, -7), 17, Color("#347443"))
	draw_circle(Vector2(15, -7), 17, Color("#3b8245"))
	draw_circle(Vector2(0, -30), 17, Color("#478d4c"))


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_nearby:
		GameManager.add_wood(3)
		queue_free()
