
extends Node2D

@export var attack_range: float = 180.0
@export var attack_damage: float = 15.0
@export var attack_interval: float = 1.0
@export var lifetime: float = 120.0

var attack_timer: float = 0.0
var remaining_lifetime: float = 120.0
var target: Node2D = null

var range_visible: bool = false
var shot_flash_timer: float = 0.0


func _ready() -> void:
	remaining_lifetime = lifetime


func _process(delta: float) -> void:
	remaining_lifetime -= delta
	attack_timer -= delta

	if shot_flash_timer > 0.0:
		shot_flash_timer -= delta

	var mouse_position = get_global_mouse_position()
	range_visible = global_position.distance_to(mouse_position) <= 22.0

	if attack_timer <= 0.0:
		attack_timer = attack_interval
		attack_nearest_zombie()

	if remaining_lifetime <= 0.0:
		queue_free()

	queue_redraw()


func attack_nearest_zombie() -> void:
	var zombies = get_tree().get_nodes_in_group("zombies")

	var nearest_zombie: Node2D = null
	var nearest_distance = attack_range

	for zombie in zombies:
		if not is_instance_valid(zombie):
			continue

		var distance = global_position.distance_to(
			zombie.global_position
		)

		if distance <= nearest_distance:
			nearest_distance = distance
			nearest_zombie = zombie

	if nearest_zombie == null:
		return

	target = nearest_zombie
	shot_flash_timer = 0.12

	if target.has_method("take_damage"):
		target.take_damage(attack_damage, global_position)

		print("Turret hit zombie for ", attack_damage, " damage!")


func _draw() -> void:
	# Turret body
	draw_rect(
		Rect2(-12, -8, 24, 22),
		Color("#79502e")
	)

	draw_rect(
		Rect2(-5, -19, 10, 14),
		Color("#a77b43")
	)

	draw_rect(
		Rect2(-4, -23, 24, 7),
		Color("#555e66")
	)

	draw_circle(Vector2.ZERO, 15, Color("#966a38"))
	draw_arc(Vector2.ZERO, 16, 0, TAU, 32, Color("#49351f"), 2)

	# Range circle
	if range_visible:
		draw_circle(
			Vector2.ZERO,
			attack_range,
			Color(0.2, 0.8, 1.0, 0.08)
		)

		draw_arc(
			Vector2.ZERO,
			attack_range,
			0,
			TAU,
			80,
			Color(0.2, 0.8, 1.0, 0.8),
			2.0
		)

	# Shot indicator
	if shot_flash_timer > 0.0 and is_instance_valid(target):
		draw_line(
			Vector2.ZERO,
			to_local(target.global_position),
			Color("#ffe08a"),
			3.0
		)

	# Lifetime bar
	var ratio = clampf(remaining_lifetime / lifetime, 0.0, 1.0)

	draw_rect(
		Rect2(-15, -34, 30, 4),
		Color("#333333")
	)

	var bar_color = Color("#55d66b")

	if ratio < 0.3:
		bar_color = Color("#e34b4b")
	elif ratio < 0.6:
		bar_color = Color("#e5b84b")

	draw_rect(
		Rect2(-15, -34, 30 * ratio, 4),
		bar_color
	)
