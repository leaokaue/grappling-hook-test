extends AnimatableBody2D
class_name WindmillSpinner

signal tried_step

signal finished_stepping

@export var is_spinner: bool = true

@export var clockwise : bool = true

@export var spin_speed : float = 40
##The speed that the blocks spin, in rotation degrees.

@onready var area : WindmillDetector = %WindmillBlockDetector

@onready var areas : Array[WindmillDetector] = [area]

@export_category("Moving Platform Logic")

@export var h_cell_distance : int

@export var v_cell_distance : int

@export var platform_speed : float = 1

var tween_started : bool = false

var movement_locker : float = 1.0

var can_step : bool = true

var can_rotate : bool = false

var has_cleaned : bool = false

var longest_area_length : float = 0.0

@export var notifier : VisibleOnScreenNotifier2D

func _ready() -> void:
	if is_instance_valid(notifier):
		notifier.show()
		#if is_spinner:
			#await notifier.screen_entered
	#else:
		#print(self," ",self.name)
	
	find_blocks()

func _physics_process(delta: float) -> void:
	var c := 1
	if not clockwise:
		c = -1
	
	if movement_locker > 0:
		movement_locker -= delta
		return
	
	if is_spinner:
		if is_instance_valid(notifier):
			if not notifier.is_on_screen():
				return
		
		if movement_locker > 0:
			movement_locker -= delta
		else:
			if not has_cleaned:
				clean_areas()
			rotation_degrees += spin_speed * c * delta
	else:
		if movement_locker > 0:
			movement_locker -= delta
			
		else:
			if not has_cleaned:
				clean_areas()
			if not tween_started:
				tween_started = true
				self.z_index = -2
				start_tween()

func find_blocks():
	can_step = false
	
	for a in areas:
		a.check_area()
	
	await tried_step
	
	if can_step:
		find_blocks()

func clean_areas():
	if has_cleaned:
		return
	has_cleaned = true
	
	for a in areas:
		var length := (a.global_position - self.global_position).length()
		if length > longest_area_length:
			print(length)
			longest_area_length = length
		a.queue_free()
	
	set_visibility_rect()

func set_visibility_rect():
	var l := longest_area_length
	
	if is_instance_valid(notifier):
		notifier.rect = Rect2(
			-l,
			-l,
			l * 2,
			l * 2
		)
		
		print(notifier.rect)
		

func start_tween():
	var init_pos : Vector2 = self.global_position
	var target_location : Vector2 = init_pos + Vector2(h_cell_distance * 60,v_cell_distance * 56)
	var t := self.create_tween()
	
	t.bind_node(self)
	
	#print(init_pos)
	#print(target_location)
	
	var h_speed : float = abs(h_cell_distance) / ((1.0) * platform_speed)
	var v_speed : float = abs(v_cell_distance) / ((0.93) * platform_speed)
	
	#print("h_speed", h_speed)
	#
	#print("hspeedist", h_speed / h_cell_distance)
	
	t.set_loops()
	t.tween_property(self,"global_position:x",target_location.x,h_speed)
	t.parallel().tween_property(self,"global_position:y",target_location.y, v_speed)
	t.tween_property(self,"global_position:x",init_pos.x,h_speed)
	t.parallel().tween_property(self,"global_position:y",init_pos.y, v_speed)
