
extends Node2D

const TURRET_SCENE = preload("res://scenes/buildings/turret.tscn")
const CAMPFIRE_SCENE = preload("res://scenes/buildings/campfire.tscn")

const TURRET_WOOD_COST = 8
const TURRET_STONE_COST = 5

const CAMPFIRE_WOOD_COST = 5
const CAMPFIRE_STONE_COST = 3

const BUILDING_RANGE = 38.0
const PLACEMENT_CHECK_RADIUS = 22.0

@onready var crafting_menu = $"../HUD/CraftingMenu"
@onready var player = $"../Player"

var selected_building: String = ""
var buildings: Array[Node2D] = []

var preview_position: Vector2 = Vector2.ZERO
var placement_valid: bool = false


func _ready() -> void:
	crafting_menu.building_selected.connect(_on_building_selected)


func _process(_delta: float) -> void:
	if selected_building == "":
		return

	preview_position = get_global_mouse_position()
	placement_valid = can_place_building(preview_position)

	queue_redraw()


func _draw() -> void:
	if selected_building == "":
		return

	var local_position = to_local(preview_position)

	var preview_color = Color(0.2, 1.0, 0.3, 0.4)

	if not placement_valid:
		preview_color = Color(1.0, 0.2, 0.2, 0.4)

	draw_circle(local_position, 20, preview_color)
	draw_arc(
		local_position,
		24,
		0,
		TAU,
		48,
		preview_color,
		2.0
	)


func _on_building_selected(building_type: String) -> void:
	selected_building = building_type



func can_place_building(position_to_check: Vector2) -> bool:

	if position_to_check.x < 20 or position_to_check.x > 1260:
		return false

	if position_to_check.y < 20 or position_to_check.y > 700:
		return false

	if player.global_position.distance_to(position_to_check) < BUILDING_RANGE:
		return false

	for building in buildings:
		if is_instance_valid(building):
			if building.global_position.distance_to(position_to_check) < 55:
				return false

	var space_state = get_world_2d().direct_space_state

	var query = PhysicsShapeQueryParameters2D.new()

	var shape = CircleShape2D.new()
	shape.radius = PLACEMENT_CHECK_RADIUS

	query.shape = shape
	query.transform = Transform2D(0, position_to_check)
	query.collision_mask = 1
	query.exclude = [player.get_rid()]
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var results = space_state.intersect_shape(query)

	if not results.is_empty():
		return false

	return true


func _unhandled_input(event: InputEvent) -> void:

	if selected_building == "":
		return

	if event.is_action_pressed("ui_cancel"):
		selected_building = ""
		queue_redraw()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			selected_building = ""
			queue_redraw()
			get_viewport().set_input_as_handled()
			return

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			if not placement_valid:
				return

			place_building()

			get_viewport().set_input_as_handled()


func place_building() -> void:

	var wood_cost = TURRET_WOOD_COST
	var stone_cost = TURRET_STONE_COST

	var building_scene = TURRET_SCENE

	if selected_building == "Campfire":
		wood_cost = CAMPFIRE_WOOD_COST
		stone_cost = CAMPFIRE_STONE_COST
		building_scene = CAMPFIRE_SCENE

	if not GameManager.spend_resources(wood_cost, stone_cost):
		print("Not enough resources!")
		return

	var new_building = building_scene.instantiate()

	get_parent().add_child(new_building)

	new_building.global_position = preview_position

	buildings.append(new_building)

	print(selected_building + " placed!")

	selected_building = ""
	queue_redraw()
