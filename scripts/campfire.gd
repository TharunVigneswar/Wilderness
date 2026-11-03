
extends Node2D

@export var effect_range: float = 100.0
@export var zombie_damage: float = 5.0
@export var player_healing: float = 2.0
@export var effect_interval: float = 1.0
@export var lifetime: float = 90.0

var effect_timer: float = 0.0
var remaining_lifetime: float = 90.0

var range_visible: bool = false
var fire_animation: float = 0.0


func _ready() -> void:
	remaining_lifetime = lifetime


func _process(delta: float) -> void:
	remaining_lifetime -= delta
	effect_timer -= delta
	fire_animation += delta

	var mouse_position = get_global_mouse_position()
	range_visible = global_position.distance_to(mouse_position) <= 22.0

	if effect_timer <= 0.0:
		effect_timer = effect_interval
		apply_campfire_effects()

	if remaining_lifetime <= 0.0:
		queue_free()

	queue_redraw()


func apply_campfire_effects() -> void:
	# Damage nearby zombies
	var zombies = get_tree().get_nodes_in_group("zombies")

	for zombie in zombies:
		if not is_instance_valid(zombie):
			continue

		var distance = global_position.distance_to(
			zombie.global_position
		)

		if distance <= effect_range:
			if zombie.has_method("take_damage"):
				zombie.take_damage(
					zombie_damage,
					global_position
				)

	# Heal the player
	var player = get_tree().get_first_node_in_group("player")

	if is_instance_valid(player):
		var player_distance = global_position.distance_to(
			player.global_position
		)

		if player_distance <= effect_range:
			if player.has_method("heal"):
				player.heal(player_healing)


func _draw() -> void:
	# Stone base
	draw_circle(Vector2.ZERO, 16, Color("#777d82"))
	draw_circle(Vector2.ZERO, 11, Color("#a4a9a0"))

	# Animated flames
	var flame_height = sin(fire_animation * 8.0) * 2.0

	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-7, 9),
			Vector2(-3, -7 - flame_height),
			Vector2(2, -14),
			Vector2(7, 8)
		]),
		Color("#ff8c24")
	)

	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-3, 7),
			Vector2(0, -7 + flame_height),
			Vector2(4, 7)
		]),
		Color("#ffdc55")
	)

	# Range circle
	if range_visible:
		draw_circle(
			Vector2.ZERO,
			effect_range,
			Color(1.0, 0.5, 0.1, 0.07)
		)

		draw_arc(
			Vector2.ZERO,
			effect_range,
			0,
			TAU,
			80,
			Color(1.0, 0.5, 0.1, 0.8),
			2.0
		)

	# Lifetime bar
	var ratio = clampf(remaining_lifetime / lifetime, 0.0, 1.0)

	draw_rect(
		Rect2(-15, -30, 30, 4),
		Color("#333333")
	)

	var bar_color = Color("#55d66b")

	if ratio < 0.3:
		bar_color = Color("#e34b4b")
	elif ratio < 0.6:
		bar_color = Color("#e5b84b")

	draw_rect(
		Rect2(-15, -30, 30 * ratio, 4),
		bar_color
	)
	
