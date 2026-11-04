
extends Node2D

func _draw() -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = 42

	for i in range(2500):
		var x = rng.randf_range(10, 2990)
		var y = rng.randf_range(10, 1990)

		var grass_color = Color(
			rng.randf_range(0.25, 0.35),
			rng.randf_range(0.42, 0.55),
			rng.randf_range(0.22, 0.32)
		)

		draw_circle(
			Vector2(x, y),
			rng.randf_range(1.5, 3.0),
			grass_color
		)
