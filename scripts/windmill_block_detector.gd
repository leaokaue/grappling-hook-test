extends Area2D
class_name WindmillDetector

@export var spinner : WindmillSpinner

@export var owned_by_spinner : bool = true

@export var collision_shape : CollisionShape2D

var has_checked : bool = false

func try_reparent_collision(wspinner : WindmillSpinner):
	if not owned_by_spinner:
		#print("tried reparent collision")
		owned_by_spinner = true
		spinner = wspinner
		collision_shape.reparent(spinner)
		spinner.areas.append(self)
		spinner.can_step = true
		spinner.movement_locker = 1.0
		spinner.tried_step.emit()
		#await get_tree().physics_frame
		#await get_tree().physics_frame
		#self.queue_free()
		

func check_area():
	
	if has_checked:
		return
	
	has_checked = true
	
	spinner.movement_locker = 1.0
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	#await get_tree().physics_frame
	#await get_tree().physics_frame
	
	for a in get_overlapping_areas():
		if a is WindmillDetector:
			a.try_reparent_collision(spinner)
