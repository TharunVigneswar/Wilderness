
extends CanvasLayer

@onready var wood_label: Label = $WoodLabel
@onready var stone_label: Label = $StoneLabel

@onready var inventory_panel: Panel = $InventoryPanel
@onready var wood_inventory: Label = $InventoryPanel/WoodInventoryLabel
@onready var stone_inventory: Label = $InventoryPanel/StoneInventoryLabel

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthLabel

@onready var wave_label: Label = $WaveLabel
@onready var timer_label: Label = $TimerLabel
@onready var wave_progress_bar: ProgressBar = $WaveProgressBar

@onready var skip_wave_button: Button = $SkipWaveButton

@onready var player = $"../Player"
@onready var wave_manager = $"../WaveManager"

@onready var reward_notification: Label = $RewardNotification

var reward_tween: Tween


func _ready() -> void:
	GameManager.resources_changed.connect(update_hud)

	player.health_changed.connect(update_health_bar)
	player.player_died.connect(_on_player_died)

	wave_manager.wave_started.connect(update_wave_display)
	wave_manager.wave_completed.connect(_on_wave_completed)
	wave_manager.game_won.connect(_on_game_won)

	skip_wave_button.pressed.connect(wave_manager.skip_preparation)

	update_hud()
	update_health_bar(player.health, player.max_health)
	update_wave_display(wave_manager.current_wave, 0)
	update_countdown_display()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		inventory_panel.visible = !inventory_panel.visible

	skip_wave_button.visible = (
		wave_manager.state == wave_manager.PREPARATION
	)

	update_countdown_display()


func update_hud() -> void:
	wood_label.text = "Wood: " + str(GameManager.wood)
	stone_label.text = "Stone: " + str(GameManager.stone)

	wood_inventory.text = "Wood: " + str(GameManager.wood)
	stone_inventory.text = "Stone: " + str(GameManager.stone)


func update_health_bar(
	current_health: float,
	maximum_health: float
) -> void:
	health_bar.max_value = maximum_health
	health_bar.value = current_health

	health_label.text = (
		str(int(current_health)) + " / " + str(int(maximum_health))
	)


func update_wave_display(
	wave_number: int,
	_enemy_count: int
) -> void:
	wave_label.text = (
		"WAVE " + str(wave_number) + " / " + str(wave_manager.TOTAL_WAVES)
	)


func update_countdown_display() -> void:
	if wave_manager.state == wave_manager.PREPARATION:
		var seconds_left: int = ceili(wave_manager.time_remaining)

		timer_label.text = "PREPARATION: " + str(seconds_left)

		wave_progress_bar.max_value = (
			wave_manager.current_preparation_time
		)

		wave_progress_bar.value = wave_manager.time_remaining

	elif wave_manager.state == wave_manager.IN_PROGRESS:
		timer_label.text = "WAVE IN PROGRESS"
		wave_progress_bar.value = 0

	elif wave_manager.state == wave_manager.VICTORY:
		timer_label.text = "VICTORY!"
		wave_progress_bar.value = 0


func _on_wave_completed(wave_number: int) -> void:
	var wood_reward = wave_manager.WAVE_WOOD_REWARDS[wave_number - 1]
	var stone_reward = wave_manager.WAVE_STONE_REWARDS[wave_number - 1]

	show_reward_notification(wood_reward, stone_reward)

	print("Wave ", wave_number, " completed! Resources awarded.")


func _on_game_won() -> void:
	get_tree().change_scene_to_file(
        "res://scenes/ui/WinScreen.tscn"
	)


func _on_player_died() -> void:
	get_tree().change_scene_to_file(
        "res://scenes/ui/LoseScreen.tscn"
	)
	
func show_reward_notification(wood_amount: int, stone_amount: int) -> void:
	if reward_tween and reward_tween.is_running():
		reward_tween.kill()

	reward_notification.text = (
        "WAVE COMPLETED!\n"
		+ "+" + str(wood_amount) + " Wood"
		+ "     "
		+ "+" + str(stone_amount) + " Stone"
	)

	reward_notification.visible = true
	reward_notification.modulate.a = 0.0

	reward_tween = create_tween()

	reward_tween.tween_property(
		reward_notification,
		"modulate:a",
		1.0,
		0.4
	)

	reward_tween.tween_interval(2.5)

	reward_tween.tween_property(
		reward_notification,
		"modulate:a",
		0.0,
		0.6
	)

	reward_tween.tween_callback(
		func():
			reward_notification.visible = false
	)
