extends Node

signal resources_changed

var wood: int = 0
var stone: int = 0


func add_wood(amount: int) -> void:
	wood += amount
	resources_changed.emit()


func add_stone(amount: int) -> void:
	stone += amount
	resources_changed.emit()


func spend_resources(wood_cost: int, stone_cost: int) -> bool:
	if wood < wood_cost or stone < stone_cost:
		return false

	wood -= wood_cost
	stone -= stone_cost

	resources_changed.emit()
	return true


func reset_resources() -> void:
	wood = 0
	stone = 0
	resources_changed.emit()
