
extends CharacterBody2D

@export var speed: float = 220.0
@export var max_health: float = 100.0

@export var attack_damage: float = 25.0
@export var attack_range: float = 85.0
@export var attack_cooldown: float = 0.45

@onready var character: AnimatedSprite2D = $CharacterVisual

var health: float = 100.0
var last_facing: String = "south"

var attack_timer: float = 0.0
var attack_animation_timer: float = 0.0
var attack_has_hit: bool = false

var damage_flash_timer: float = 0.0

signal health_changed(current_health: float, maximum_health: float)
signal player_died


func _ready() -> void:
	health = max_health
	health_changed.emit(health, max_health)


func _physics_process(delta: float) -> void:
	if attack_timer > 0.0:
		attack_timer -= delta

	if attack_animation_timer > 0.0:
		attack_animation_timer -= delta
		queue_redraw()

	if damage_flash_timer > 0.0:
		damage_flash_timer -= delta

		if damage_flash_timer <= 0.0:
			modulate = Color.WHITE

	var direction = Vector2.ZERO

	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")

	direction = direction.normalized()

	velocity = direction * speed
	move_and_slide()

	update_animation(direction)

	if Input.is_action_just_pressed("attack"):
		perform_attack()


func update_animation(direction: Vector2) -> void:
	if direction.length() > 0:
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				last_facing = "east"
			else:
				last_facing = "west"
		else:
			if direction.y > 0:
				last_facing = "south"
			else:
				last_facing = "north"

		if attack_animation_timer <= 0.0:
			play_animation("walk_" + last_facing)

	else:
		if attack_animation_timer <= 0.0:
			play_animation("idle_" + last_facing)


func play_animation(animation_name: String) -> void:
	if character.sprite_frames.has_animation(animation_name):
		if character.animation != animation_name:
			character.play(animation_name)


func perform_attack() -> void:
	if attack_timer > 0.0:
		return

	attack_timer = attack_cooldown
	attack_animation_timer = 0.32
	attack_has_hit = false

	play_attack_animation()
	queue_redraw()


func play_attack_animation() -> void:
	var animation_name = "idle_" + last_facing

	if character.sprite_frames.has_animation(animation_name):
		character.play(animation_name)


func _process(_delta: float) -> void:
	if attack_animation_timer > 0.0 and not attack_has_hit:
		var progress = 1.0 - attack_animation_timer / 0.32

		if progress >= 0.30:
			attack_has_hit = true
			damage_nearby_zombies()


func damage_nearby_zombies() -> void:
	var facing_direction = get_facing_direction()
	var zombies = get_tree().get_nodes_in_group("zombies")

	for zombie in zombies:
		if not is_instance_valid(zombie):
			continue

		var distance = global_position.distance_to(
			zombie.global_position
		)

		if distance > attack_range:
			continue

		var direction_to_zombie = global_position.direction_to(
			zombie.global_position
		)

		if facing_direction.dot(direction_to_zombie) >= 0.25:
			if zombie.has_method("take_damage"):
				zombie.take_damage(
					attack_damage,
					global_position
				)

				print("Zombie hit! Remaining health: ", zombie.health)


func get_facing_direction() -> Vector2:
	match last_facing:
		"north":
			return Vector2.UP
		"south":
			return Vector2.DOWN
		"east":
			return Vector2.RIGHT
		"west":
			return Vector2.LEFT

	return Vector2.DOWN


func take_damage(amount: float) -> void:
	if health <= 0.0:
		return

	health = maxf(health - amount, 0.0)

	damage_flash_timer = 0.15
	modulate = Color("#ff5555")

	health_changed.emit(health, max_health)

	print("Player health: ", health)

	if health <= 0.0:
		player_died.emit()


func heal(amount: float) -> void:
	if health <= 0.0:
		return

	health = minf(health + amount, max_health)
	health_changed.emit(health, max_health)


func _draw() -> void:
	if attack_animation_timer <= 0.0:
		return

	var progress = 1.0 - attack_animation_timer / 0.32

	# Anticipation, swing and recovery
	var swing_progress = clampf((progress - 0.15) / 0.70, 0.0, 1.0)

	if progress < 0.15:
		swing_progress = 0.0

	var facing = get_facing_direction()
	var base_angle = facing.angle()

	var swing_angle = lerpf(
		base_angle - 1.15,
		base_angle + 1.15,
		swing_progress
	)

	var weapon_direction = Vector2.RIGHT.rotated(swing_angle)

	var weapon_start = facing * 7.0
	var weapon_end = weapon_start + weapon_direction * 29.0

	# Weapon handle
	draw_line(
		weapon_start,
		weapon_end,
		Color("#69452b"),
		4.0,
		true
	)

	# Weapon blade
	var blade_start = weapon_end - weapon_direction * 5.0
	var blade_end = weapon_end + weapon_direction * 7.0

	draw_line(
		blade_start,
		blade_end,
		Color("#d7e1e4"),
		5.0,
		true
	)

	# Blade shine
	draw_line(
		blade_start,
		blade_end,
		Color("#ffffff"),
		1.5,
		true
	)

	# Swing trail
	if progress > 0.2 and progress < 0.85:
		var trail_angle = swing_angle - 0.4

		draw_arc(
			facing * 17.0,
			25.0,
			trail_angle - 0.65,
			trail_angle + 0.65,
			18,
			Color(1.0, 0.85, 0.45, 0.8),
			3.0,
			true
		)
