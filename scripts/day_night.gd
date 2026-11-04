
extends CanvasModulate

@export var day_color: Color = Color("#ffffff")
@export var night_color: Color = Color("#8995ad")
@export var transition_duration: float = 1.8

var target_color: Color
var transitioning: bool = false


func _ready() -> void:
	color = day_color
	target_color = day_color


func _process(delta: float) -> void:
	if not transitioning:
		return

	color = color.lerp(
		target_color,
		clampf(delta / transition_duration, 0.0, 1.0)
	)

	if color.is_equal_approx(target_color):
		color = target_color
		transitioning = false


func set_day() -> void:
	target_color = day_color
	transitioning = true


func set_night() -> void:
	target_color = night_color
	transitioning = true
