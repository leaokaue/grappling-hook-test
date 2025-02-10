extends Area2D
class_name Water

@export var poisonous : bool = false

func _ready() -> void:
	
	gravity_direction.y = -1
	
	if poisonous:
		gravity = 100
	else:
		gravity = 600

func _physics_process(_delta: float) -> void:
	#for body in get_overlapping_bodies():
		#if body is Worm:
			#body.time_fallen = 0.0
			#body.poison_buildup += delta
	pass
