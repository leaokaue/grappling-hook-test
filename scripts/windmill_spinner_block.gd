extends AnimatableBody2D
class_name WindmillSpinner

signal tried_step

signal finished_stepping

@export var clockwise : bool = true

@export var spin_speed : float = 40
##The speed that the blocks spin, in rotation degrees.

@onready var area : WindmillDetector = %WindmillBlockDetector

@onready var areas : Array[WindmillDetector] = [area]

var can_step : bool = true

var can_rotate : bool = false

func _ready() -> void:
	find_blocks()
	
	await get_tree().create_timer(1.0,false).timeout
	
	can_rotate = true

func _physics_process(delta: float) -> void:
	var c := 1
	if not clockwise:
		c = -1
	
	if can_rotate:
		rotation_degrees += spin_speed * c * delta

func find_blocks():
	can_step = false
	
	for a in areas:
		a.check_area()
	
	await tried_step
	
	if can_step:
		find_blocks()
