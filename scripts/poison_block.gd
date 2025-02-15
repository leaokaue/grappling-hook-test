extends Area2D
class_name Water

@export var poisonous : bool = false

func _ready() -> void:
	gravity_direction.y = -1
	linear_damp_space_override = SPACE_OVERRIDE_COMBINE_REPLACE
	
	if poisonous:
		gravity = -150
		linear_damp = 12
	else:
		linear_damp = 2
		gravity = -450
