extends Marker2D

var item: PickableItem = null
var is_flipped: bool = false

func _process(_delta: float) -> void:
	if item == null:
		return
	item.global_position = global_position
	if position.x < 0:
		item.flip(true)
	else:
		item.flip(false)

func set_item(value: PickableItem) -> void:
	item = value

func get_item() -> PickableItem:
	return item
