class_name Bounds

var left_bounds: Vector2
var right_bounds: Vector2

func is_in_left_bound(position: Vector2) -> bool:
	if position.x <= left_bounds.x:
		return false
	return true

func is_in_right_bound(position: Vector2) -> bool:
	if position.x >= right_bounds.x:
		return false
	return true

func set_bounds(left: Vector2, right: Vector2) -> void:
	left_bounds = left
	right_bounds = right