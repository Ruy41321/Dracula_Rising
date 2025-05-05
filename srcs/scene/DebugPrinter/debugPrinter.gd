class_name DebugPrinter

var caller: Node2D

func _init(node: Node2D) -> void:
	self.caller = node

func print(var_args) -> void:
	if caller.debug_mode:
		print(caller.name, ": ", var_args)
	
