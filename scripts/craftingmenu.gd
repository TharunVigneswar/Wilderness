
extends Control

signal building_selected(building_type: String)

@onready var turret_button: Button = $CraftingPanel/BuildingList/TurretButton
@onready var campfire_button: Button = $CraftingPanel/BuildingList/CampfireButton


func _ready() -> void:
	visible = false

	turret_button.pressed.connect(_on_turret_pressed)
	campfire_button.pressed.connect(_on_campfire_pressed)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("crafting"):
		visible = !visible

	if visible and Input.is_action_just_pressed("ui_cancel"):
		visible = false


func _on_turret_pressed() -> void:
	building_selected.emit("Turret")
	visible = false


func _on_campfire_pressed() -> void:
	building_selected.emit("Campfire")
	visible = false
