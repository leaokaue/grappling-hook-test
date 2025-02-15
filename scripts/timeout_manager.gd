extends Node2D
class_name TimeoutManager

## Time in seconds until this node frees its parent from the scene.
@export var timeout : float = 5.0

var parent : Node

func _ready() -> void:
	parent = get_parent()

func _process(delta: float) -> void:
	if timeout > 0:
		timeout -= delta
	else:
		if is_instance_valid(parent):
			parent.queue_free()
