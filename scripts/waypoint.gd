extends Area2D
class_name Waypoint

enum WAYPOINTS {
	Spawn,
	Bog,
	Windmill,
	Spike,
	Space,
	Empty,
	Spike2
}

@export var waypoint : WAYPOINTS

var active : bool = false

var t : Tween 

func _ready() -> void:
	self.body_entered.connect(_on_player_enter)
	self.body_exited.connect(_on_player_exit)
	set_waypoint_pos()
	if is_unlocked():
		animate_lines()

func _on_player_enter(body : Node2D):
	if body is Worm:
		Global.can_use_waypoints = true
		Global.can_switch_equipments = true
		$Obelisk/Label.show()
		
		if not is_unlocked():
			unlock()
			animate_lines()
			set_particles(true)
		else:
			set_particles(true)

func _on_player_exit(body : Node2D):
	if body is Worm:
		Global.can_use_waypoints = false
		Global.can_switch_equipments = false
		$Obelisk/Label.hide()
		set_particles(false)

func is_unlocked() -> bool:
	return Global.waypoints_unlocked[Waypoint.WAYPOINTS.keys()[waypoint]]

func unlock():
	Global.waypoints_unlocked[Waypoint.WAYPOINTS.keys()[waypoint]] = true

func animate_lines():
	set_lines(%Line1.texture.gradient)
	set_lines(%Line2.texture.gradient)

func set_particles(emitting : bool):
	%Ring.emitting = emitting

func set_lines(gradient : Gradient):
	
	var s1 := func(x):
		gradient.set_offset(0,x)
	
	var s2 := func(x):
		gradient.set_offset(1,x)
	
	animate_tween()
	t.tween_method(s2,0.1,1.0,0.5)
	t.tween_method(s1,0.0,0.7,0.5).set_delay(0.1)
	
	#t.set_loops()
	#
	#t.tween_method(s2,1.0,0.7,0.5)
	#t.parallel().tween_method(s1,0.7,0.4,0.5)
	#t.tween_method(s1,0.4,0.7,0.5)
	#
	#t.tween_method(s2,0.7,1.0,0.5)
	#t.parallel().tween_method(s1,0.7,1.0,0.5).set_delay(0.1)

func animate_tween():
	if t:
		t.kill()
	t = create_tween()

func set_waypoint_pos():
	Global.waypoint_position[Waypoint.WAYPOINTS.keys()[waypoint]] = self.global_position
