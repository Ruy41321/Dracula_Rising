extends TextureProgressBar

var parent_node

func _ready() -> void:
	parent_node = get_parent()

func _process(_delta: float) -> void:
	if max_value != parent_node.MAX_HP:
		max_value = parent_node.MAX_HP
	if value != parent_node.hp:
		value = parent_node.hp
