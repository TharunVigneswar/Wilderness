
extends StaticBody2D

var player_nearby: bool = false


func _ready() -> void:
	var area = $InteractionArea

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)


func _draw() -> void:
	# Main rock
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-25, 8),
			Vector2(-18, -12),
			Vector2(-5, -23),
			Vector2(17, -18),
			Vector2(27, 3),
			Vector2(18, 17),
			Vector2(-15, 18)
		]),
		Color("#777d82")
	)

	# Lighter rock surface
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-18, -12),
			Vector2(-5, -23),
			Vector2(17, -18),
			Vector2(5, -5),
			Vector2(-8, -3)
		]),
		Color("#a6adb0")
	)

	# Shadow
	draw_arc(
		Vector2.ZERO,
		20,
		0,
		PI,
		20,
		Color("#50565b"),
		2.0
	)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_nearby:
		GameManager.add_stone(2)
		queue_free()
