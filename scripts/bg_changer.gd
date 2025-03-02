extends Area2D

@export var bg : BackgroundManager.BACKGROUNDS

func _ready() -> void:
	self.set_collision_mask_value(1,false)
	self.set_collision_mask_value(2,true)
	self.body_entered.connect(self.on_body_entered)

func on_body_entered(body : Node2D):
	if body is Worm:
		var b := BackgroundManager.BACKGROUNDS
		Global.set_background(bg)
		Global.set_area_seen(bg)
		if bg == b.Rainy:
			Global.toggle_rain.emit(true)
		else:
			Global.toggle_rain.emit(false)
		
		if bg == b.Night:
			Global.set_area_seen(6)
		
		if bg == b.Empty:
			Global.change_target_zoom.emit(0.95)
		elif bg == b.Space:
			Global.change_target_zoom.emit(0.7)
		elif bg == b.Clouds:
			Global.change_target_zoom.emit(0.5)
		else:
			Global.reset_zoom.emit()

#func ready_check_player():
	#for i in get_overlapping_bodies():
		#print(i.get_class())
		#if i is Worm:
			#on_body_entered(i)
