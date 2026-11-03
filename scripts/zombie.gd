
extends CharacterBody2D

@export var max_health: float = 60.0
@export var speed: float = 75.0

@export var attack_range: float = 48.0
@export var attack_damage: float = 5.0
@export var attack_cooldown: float = 1.5

@export var knockback_strength: float = 180.0
@export var knockback_friction: float = 900.0

var health: float = 60.0
var player: CharacterBody2D = null

var attack_timer: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO
var hit_flash_timer: float = 0.0


func _ready() -> void:
	health = max_health
	add_to_group("zombies")

	player = get_tree().get_first_node_in_group("player") as CharacterBody2D

	queue_redraw()


func _physics_process(delta: float) -> void:
	if attack_timer > 0.0:
		attack_timer -= delta

	if hit_flash_timer > 0.0:
		hit_flash_timer -= delta

		if hit_flash_timer <= 0.0:
			modulate = Color.WHITE

	if not is_instance_valid(player):
		velocity = knockback_velocity
		move_and_slide()
		apply_knockback_friction(delta)
		return

	var distance = global_position.distance_to(player.global_position)
	var direction = global_position.direction_to(player.global_position)

	var movement_velocity = Vector2.ZERO

	if distance > attack_range:
		movement_velocity = direction * speed
	else:
		if attack_timer <= 0.0:
			attack_player()

	velocity = movement_velocity + knockback_velocity

	move_and_slide()

	apply_knockback_friction(delta)


func apply_knockback_friction(delta: float) -> void:
	knockback_velocity = knockback_velocity.move_toward(
		Vector2.ZERO,
		knockback_friction * delta
	)


func attack_player() -> void:
	if not is_instance_valid(player):
		return

	if player.has_method("take_damage"):
		player.take_damage(attack_damage)
		print("Zombie attacked! Player health: ", player.health)

	attack_timer = attack_cooldown


func take_damage(amount: float, attacker_position: Vector2 = Vector2.ZERO) -> void:
	health = maxf(health - amount, 0.0)

	# Update health bar immediately
	queue_redraw()

	# Red damage flash
	hit_flash_timer = 0.12
	modulate = Color("#ff5555")

	# Knockback
	var knockback_direction = (
		global_position - attacker_position
	).normalized()

	if knockback_direction == Vector2.ZERO:
		knockback_direction = Vector2.UP

	knockback_velocity = knockback_direction * knockback_strength

	print("Zombie health: ", health, " / ", max_health)

	if health <= 0.0:
		queue_free()


func _draw() -> void:
	# Shadow
	draw_circle(Vector2(0, 6.5), 7, Color(0, 0, 0, 0.3))

	# Legs
	draw_rect(Rect2(-9.5, -2.5, 4.5, 11.5), Color("#405b36"))
	draw_rect(Rect2(5, -2.5, 4.5, 11.5), Color("#405b36"))

	# Feet
	draw_circle(Vector2(-7.5, 8.5), 2.5, Color("#718c4d"))
	draw_circle(Vector2(7.5, 8.5), 2.5, Color("#718c4d"))

	# Body
	draw_rect(Rect2(-5.5, -2.5, 11, 12), Color("#343b38"))
	draw_rect(Rect2(-4.5, 0.5, 9, 1.5), Color("#59614c"))

	# Arms
	draw_rect(Rect2(-10, -3, 4, 9), Color("#536d43"))
	draw_rect(Rect2(6, -3, 4, 9), Color("#536d43"))

	# Head
	draw_circle(Vector2(0, -8), 6, Color("#718c4d"))
	draw_arc(Vector2(0, -8), 6, PI, TAU, 16, Color("#30342d"), 2)

	# Eyes
	draw_circle(Vector2(-2.5, -9), 1.25, Color("#ff3939"))
	draw_circle(Vector2(2.5, -9), 1.25, Color("#ff3939"))

	# Mouth
	draw_line(Vector2(-2, -5), Vector2(2, -5), Color("#283128"), 1)

	# Health bar
	var health_ratio = 0.0

	if max_health > 0.0:
		health_ratio = health / max_health

	draw_rect(
		Rect2(-12, -20, 24, 3),
		Color("#333333")
	)

	draw_rect(
		Rect2(-12, -20, 24 * health_ratio, 3),
		Color("#e34b4b")
	)
