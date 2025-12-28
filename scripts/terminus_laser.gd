@tool
extends Node2D
class_name TerminusLaser

@export var laser_range : float = 100 :
	set(value):
		laser_range = value
		call_deferred("set_laser_visuals")

enum CUBE_MODE {
	Block, 
	Push,
	Pull,
	Ignore
}

var laser_alpha : float = 1.0

@export var cube_mode : CUBE_MODE:
	set(value):
		cube_mode = value
		request_ready()

@export var pushes_cube : bool = false

@export var cube_move_force : float = 100

var activated : bool = true

@export_group("Intervals")

@export var intervals_enabled : bool = false

@export var initial_offset : float = 0.0

var i_offset : float = initial_offset

@export var activated_interval : float = 10.0

@export var activate_buffer : float = 0.0

var a_interval : float = 0.0

@export var disabled_interval : float = 5.0

@export var disabled_buffer : float = 0.0

var d_interval : float = 0.0

@export var cycle_delay : float = 0

var c_delay : float

@export_group("Internal Variables")

@onready var collisions : Array[CollisionShape2D] = [%Segment,%Segment2,%Segment3]

@onready var line : Line2D = %LaserLine

@onready var impact : Node2D = %LaserPoint

@onready var raycast : RayCast2D = %RayCast2D

@onready var constant_particles : GPUParticles2D = %Constant

@onready var end_particles : GPUParticles2D = %End

var t : Tween

var it : Tween

var enabled : bool = true

func _ready() -> void:
	i_offset = initial_offset
	laser_alpha = 0.9
	line.modulate.a = 0.9
	impact.modulate.a = 0.9
	if cube_mode == CUBE_MODE.Ignore:
		laser_alpha = 0.3
		line.modulate.a = 0.3
		raycast.set_collision_mask_value(10,false)
	if cube_mode == CUBE_MODE.Push:
		line.modulate = Color.CRIMSON
		impact.modulate = Color.CRIMSON
	
	if cube_mode == CUBE_MODE.Pull:
		(line.material as ShaderMaterial).set_shader_parameter("scroll_speed",-12.606)
		line.modulate = Color.AQUA
		impact.modulate = Color.AQUA
	dissipate_laser(true)
	
	if intervals_enabled:
		_set_interval_tween()
	else:
		activate_laser()
	
	#if Engine.is_editor_hint():
		#line.material = null
	
	raycast.target_position.y = -abs(laser_range) 

func _process(delta: float) -> void:
	#if intervals_enabled:
		#_handle_intervals(delta)
	pass

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	set_laser_visuals()
	_handle_collision_segment_range()
	_detect_and_handle_cube(delta)

func _set_interval_tween():
	var tt := create_tween()
	tt.tween_interval(i_offset)
	await tt.finished
	
	it = create_tween()
	it.set_loops()
	it.tween_callback(activate_laser)
	it.tween_interval(activated_interval)
	it.tween_callback(dissipate_laser)
	it.tween_interval(disabled_interval)
	it.tween_interval(cycle_delay)

func set_laser_visuals():
	var length := get_laser_length()
	
	impact.position.y = -length
	line.set_point_position(1,Vector2(0,-length))

func get_laser_length() -> float:
	if raycast.is_colliding():
		return abs((raycast.get_collision_point() - raycast.global_position).length())
	else:
		return laser_range

func _handle_collision_segment_range():
	var length := get_laser_length()
	for c in collisions:
		var shape := c.shape
		if shape is SegmentShape2D:
			#print(shape.b)
			shape.b = Vector2(0,-length + 20)

func set_collisions_disabled(disabled : bool):
	for c in collisions:
		c.disabled = disabled

func dissipate_laser(instant : bool = false):
	animate_tween()
	
	#activated = false
	
	var emit := func():
		constant_particles.emitting = false
		end_particles.emitting = true
	
	
	t.tween_property(impact,"modulate:a",0.0,0.6)
	t.parallel().tween_property(line,"width",0.0,0.6).set_delay(0.2)
	t.parallel().tween_property(line,"modulate:a",(line.modulate.a / 2.0),0.1).set_delay(0.45)
	t.parallel().tween_callback(set_collisions_disabled.bind(true)).set_delay(0.45)
	t.parallel().tween_callback(set.bind("activated",false)).set_delay(0.45)
	t.tween_callback(emit)
	
	if instant:
		t.custom_step(2.0)

func activate_laser():
	animate_tween()
	
	#activated = true
	
	var emit := func():
		constant_particles.emitting = true
	
	t.tween_property(line,"width",61.0,0.6)
	t.parallel().tween_property(impact,"modulate:a",laser_alpha,0.4).set_delay(0.2)
	t.parallel().tween_property(line,"modulate:a",laser_alpha,0.3).set_delay(0.45)
	t.parallel().tween_callback(set_collisions_disabled.bind(false)).set_delay(0.45)
	t.parallel().tween_callback(set.bind("activated",true)).set_delay(0.45)
	t.tween_callback(emit)

func animate_tween():
	if t:
		t.kill()
	t = create_tween()

func _detect_and_handle_cube(delta : float):
	if not (cube_mode == CUBE_MODE.Pull or cube_mode == CUBE_MODE.Push): return
	
	if not activated: return
	
	if not raycast.is_colliding(): return
	
	var force : float = cube_move_force
	
	if cube_mode == CUBE_MODE.Pull:
		force *= -1
	
	var c := raycast.get_collider()
	
	var dir := Vector2.UP.rotated(self.rotation)
	
	if c is FalseCube2D:
		if cube_mode == CUBE_MODE.Pull:
			c.linear_damp = 10.0
		c.life_time = 15.0
		#c.global_position += dir * force * delta
		c.linear_velocity = dir * force
		#c.apply_central_force(dir * force * delta * 10)
	
