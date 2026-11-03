
extends Node

signal wave_started(wave_number: int, enemy_count: int)
signal wave_completed(wave_number: int)
signal game_won

const ZOMBIE_SCENE = preload("res://scenes/enemies/zombie.tscn")

const TOTAL_WAVES = 5
const INITIAL_PREPARATION_TIME = 30.0
const INTER_WAVE_PREPARATION_TIME = 15.0

const PREPARATION = 0
const IN_PROGRESS = 1
const VICTORY = 2

const ENEMIES_PER_WAVE = [4, 7, 10, 13, 16]

const WAVE_WOOD_REWARDS = [6, 8, 10, 12, 15]
const WAVE_STONE_REWARDS = [4, 5, 6, 8, 10]

const SPAWN_INTERVAL = 0.8

var current_wave: int = 0
var time_remaining: float = INITIAL_PREPARATION_TIME
var current_preparation_time: float = INITIAL_PREPARATION_TIME
var state: int = PREPARATION

var enemies_to_spawn: int = 0
var enemies_spawned: int = 0
var spawn_timer: float = 0.0


func _process(delta: float) -> void:
	if state == PREPARATION:
		time_remaining -= delta

		if time_remaining <= 0.0:
			time_remaining = 0.0
			start_wave()

	elif state == IN_PROGRESS:
		if enemies_spawned < enemies_to_spawn:
			spawn_timer -= delta

			if spawn_timer <= 0.0:
				spawn_zombie()
				spawn_timer = SPAWN_INTERVAL

		elif get_tree().get_nodes_in_group("zombies").is_empty():
			end_wave()


func start_wave() -> void:
	if current_wave >= TOTAL_WAVES:
		return

	current_wave += 1

	state = IN_PROGRESS
	get_tree().current_scene.get_node("DayNightOverlay").set_night()
	current_preparation_time = INITIAL_PREPARATION_TIME
	enemies_to_spawn = ENEMIES_PER_WAVE[current_wave - 1]
	enemies_spawned = 0
	spawn_timer = 0.0

	print("Wave ", current_wave, " started! Zombies: ", enemies_to_spawn)

	wave_started.emit(current_wave, enemies_to_spawn)


func spawn_zombie() -> void:
	var zombie = ZOMBIE_SCENE.instantiate()

	get_parent().add_child(zombie)
	zombie.global_position = get_random_spawn_position()

	enemies_spawned += 1

	print("Spawned zombie ", enemies_spawned, " / ", enemies_to_spawn)


func get_random_spawn_position() -> Vector2:
	var spawn_position = Vector2.ZERO
	var attempts = 0

	while attempts < 30:
		spawn_position = Vector2(
			randf_range(180.0, 1100.0),
			randf_range(120.0, 600.0)
		)

		var player = get_tree().get_first_node_in_group("player")

		if is_instance_valid(player):
			var distance_from_player = spawn_position.distance_to(
				player.global_position
			)

			if distance_from_player < 220.0:
				attempts += 1
				continue

		return spawn_position

	return Vector2(180.0, 120.0)


func end_wave() -> void:
	get_tree().current_scene.get_node("DayNightOverlay").set_day()
	print("Wave ", current_wave, " completed!")

	GameManager.add_wood(WAVE_WOOD_REWARDS[current_wave - 1])
	GameManager.add_stone(WAVE_STONE_REWARDS[current_wave - 1])

	print("Wave reward: ",
		WAVE_WOOD_REWARDS[current_wave - 1], " wood and ",
		WAVE_STONE_REWARDS[current_wave - 1], " stone."
	)

	wave_completed.emit(current_wave)

	if current_wave >= TOTAL_WAVES:
		state = VICTORY
		print("All waves completed! Victory!")
		game_won.emit()
	else:
		state = PREPARATION
		current_preparation_time = INTER_WAVE_PREPARATION_TIME
		time_remaining = current_preparation_time
		print("Next wave preparation started.")


func skip_preparation() -> void:
	if state != PREPARATION:
		return

	time_remaining = 0.0
	start_wave()
