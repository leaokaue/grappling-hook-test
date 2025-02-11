extends RigidBody2D
class_name Worm

var last_checkpoint : Vector2

@onready var animated_sprite_2d = %Sprite2D
@onready var ray_cast_2d = $RayCast2D
@onready var liquid_cast_2d = $LiquidCast

const MOVE_SPEED = 50
const MAX_SPEED = 100
const JUMP_FORCE = -450

var drown_buildup_buffer : float = 0.0

var poison_buffer : float = 0.0

var drown_buildup : float = 0.0 

var max_drown_buildup : float = 2.5

var can_control : bool = true

var in_liquid : bool = false

#var can_jump : bool = true

var is_grappling : bool = false

var is_freefalling : bool = false

var can_scream : bool = true

var time_fallen : float = 0.0

var current_hook_cooldown : float = 0.0

var max_hook_cooldown : float = 1.2

var can_hook : bool = true

var hook : GrappleHook

@onready var line := $Line2D

#var global_joint : PinJoint2D

var global_joint : DampedSpringJoint2D

const ui := preload("res://scenes/ui.tscn")

const gr := preload("res://scenes/grapple.tscn")

const map := preload("res://scenes/map.tscn")

func _ready() -> void:
	create_ui()
	Global.teleport_to_waypoint.connect(teleport_to_waypoint)
	Global.player = self

func _process(delta: float) -> void:
	if not can_hook:
		current_hook_cooldown -= delta
		if current_hook_cooldown < 0:
			can_hook = true

func _physics_process(delta):
	var direction = Input.get_axis("left", "right")
	var force = Vector2.ZERO
	
	handle_non_control(delta)
	
	if (direction != 0) and (not is_grappling) and (not in_liquid):
		is_freefalling = false
	
	if not can_control:
		return
	
	if Input.is_action_just_pressed("grapple"):
		if not is_grappling:
			grapple()
		else:
			destroy_grapple()
	
	if Input.is_action_pressed("retract"):
		if is_grappling:
			if hook.grappled:
				retract(delta)
	
	if direction != 0:
		if (not is_freefalling) or (in_liquid):
			force.x = MOVE_SPEED * direction
			physics_material_override.friction = 0.1
			if abs(linear_velocity.x) > MAX_SPEED:
				linear_velocity.x = MAX_SPEED * direction
				#linear_velocity.x = move_toward(linear_velocity.x,MAX_SPEED * direction, delta * 3)
				#print(linear_velocity.x)
	else:
		physics_material_override.friction = 1.0
	
	if in_liquid:
		var v_direction := Input.get_axis("up", "stop")
		if v_direction != 0:
			var water_speed : float = 0.5
			force.y = (MAX_SPEED * water_speed) * v_direction
			if abs(linear_velocity.y) > (MAX_SPEED * water_speed):
				linear_velocity.y = (MAX_SPEED * water_speed) * v_direction
	
	if Input.is_action_just_pressed("map"):
		instantiate_map()
	
	if Input.is_action_just_pressed("jump"):
		if is_grappling:
			if is_instance_valid(hook):
				if hook.grappled:
					force.y = JUMP_FORCE * 0.8
					destroy_grapple()
		elif _on_floor(): 
			force.y = JUMP_FORCE
	
	if Input.is_action_just_pressed("stop"):
		if _on_floor():
			linear_velocity = Vector2()
	
	_set_animation(direction)
	
	apply_central_impulse(force)

func handle_non_control(delta : float):
	check_length()
	
	#print(Engine.time_scale)
	
	handle_liquids(delta)
	
	if is_grappling:
		rotate_joint()
		
		if is_instance_valid(hook):
			line.set_point_position(0,self.global_position)
			line.set_point_position(1,hook.global_position)
			#print(hook.global_position)
			line.show()
			if hook.grappled:
				self.gravity_scale = 0.7
			else:
				self.gravity_scale = 1.0
	else:
		self.gravity_scale = 1.0
		line.hide()
	
	check_length()
	
	if (not is_grappling) and (not _on_floor()) and (not in_liquid):
		var t : float = 1
		if is_freefalling:
			t = 1.5
		time_fallen += delta * t
		if time_fallen > 2.93:
			scream()
			time_fallen = 0.0
			can_scream = false
	else:
		time_fallen = 0.0
	
	
	if _on_floor():
		can_scream = true
	

@warning_ignore("unused_parameter")
func _integrate_forces(state):
	if not is_freefalling:
		rotation_degrees = lerp(rotation_degrees,0.0,0.8)

func _set_animation(direction):
	if direction > 0: animated_sprite_2d.flip_h = false
	elif direction < 0: animated_sprite_2d.flip_h = true
	
	#if not _on_floor(): animated_sprite_2d.play("jump")
	#elif abs(linear_velocity.x) > 0.1: animated_sprite_2d.play("run")
	#else: animated_sprite_2d.play("idle")

func _on_floor():
	
	if in_liquid:
		return false
	
	if is_freefalling:
		if $RagddollCast.is_colliding():
			return true
	else:
		if ray_cast_2d.is_colliding():
			return true

func instantiate_map():
	var m := map.instantiate()
	
	get_tree().current_scene.add_child(m)
	#can_control = false

func grapple():
	if not can_hook:
		return
	
	current_hook_cooldown = max_hook_cooldown
	can_hook = false
	
	var speed : float = 2.0
	
	if Global.has_steroids_1:
		speed = 3.0
	
	var g := gr.instantiate()
	var dir := (get_global_mouse_position() - self.global_position).normalized() * 500 * speed
	
	is_grappling = true
	is_freefalling = true
	
	g.player = self
	g.hit.connect(impulse_to_grapple)
	g.hit.connect(create_joint)
	g.global_position = self.global_position
	g.apply_central_impulse(dir)
	g.rotation = dir.angle()
	
	hook = g
	
	get_tree().current_scene.add_child(g)

func destroy_grapple():
	if is_instance_valid(hook):
		is_grappling = false
		hook.die()
		destroy_joint()

#func create_joint():
	#var j := DampedSpringJoint2D.new()
	#global_joint = j
	#get_tree().root.add_child(j)

func rotate_joint():
	var j := global_joint
	
	if is_instance_valid(j):
		var dir := (hook.global_position - self.global_position)
		
		var rot := dir.angle() + Vector2.DOWN.angle()
		
		j.rotation = rot
		
		j.global_position = hook.global_position

func create_joint():
	var j := DampedSpringJoint2D.new()
	global_joint = j
	#j.softness = 16.0
	#j.angular_limit_enabled = true
	#j.angular_limit_lower = -40
	#j.angular_limit_upper = 40
	j.stiffness = 5.0
	j.damping = 0.5
	j.global_position = hook.global_position
	#hook.add_child(j)
	get_tree().root.add_child(j)
	
	#if not is_instance_valid(global_joint):
		#return
	
	if is_instance_valid(hook):
		var dir := (hook.global_position - self.global_position)
		var length := dir.length()
		j.rotation = dir.angle()
		j.rotation += Vector2.DOWN.angle()
		j.length = length * 0.5
		j.rest_length = length * 0.2
	
	global_joint.node_b = self.get_path()
	
	
	global_joint.node_a = hook.get_path()

func destroy_joint():
	if not is_instance_valid(global_joint):
		return
	
	global_joint.queue_free()

func retract(delta):
	if is_grappling:
		if is_instance_valid(global_joint):
			
			#print("is_retracting")
			
			global_joint.rest_length -= 50 * delta
			global_joint.rest_length = clampf(global_joint.rest_length,30,1000)
			
			global_joint.length -= 50 * delta
			global_joint.length = clampf(global_joint.length,30,1000)
		
		if not is_instance_valid(hook):
			return
		
		#print("trying to retract")
		
		var dir := (hook.global_position - self.global_position)
		var speed := 1000.0
		var length := dir.length()
		if length > 20:
			#print("applying speed")
			apply_central_force(dir.normalized() * speed)

func check_length():
	if is_instance_valid(hook):
		var dir := (hook.global_position - self.global_position)
		var length := dir.length()
		
		var upgraded : float = 0.0
		
		var max_length := 500 + upgraded
		
		if is_instance_valid(hook):
			if hook.grappled:
				max_length = 650 + (upgraded * 0.25)
		
		if length > max_length:
			destroy_grapple()

func impulse_to_grapple():
	var dir := (hook.global_position - self.global_position)
	var speed := 500.0
	apply_central_impulse(dir.normalized() * speed)

func create_ui():
	var u := ui.instantiate()
	get_tree().current_scene.add_child.call_deferred(u)

func handle_liquids(delta : float):
	if not can_control:
		drown_buildup = 0.0
		return
	
	var p : TextureProgressBar = %poison
	
	p.max_value = max_drown_buildup
	p.value = drown_buildup
	p.show()
	
	var area2d : Area2D = $LiquidReg
	var a := area2d.get_overlapping_areas()
	
	var in_water : bool = false
	var in_poison : bool = false
	
	in_liquid = false
	
	for area in a:
		if area is Water:
			if area.poisonous:
				in_poison = true
			else:
				in_water = true
			
			in_liquid = true
	
	if in_poison:
		poison_buffer = 0.3
		if poison_buffer > 0:
			if not Global.has_poison_resist:
				drown_buildup += delta * 1.5
				drown_buildup_buffer = 0.3
		#apply_central_force(Vector2(0,-1) * 600)
	elif in_water:
		drown_buildup += delta * 0.3
		drown_buildup_buffer = 0.3
		#apply_central_force(Vector2(0,-1) * 1100)
	else:
		if poison_buffer > 0:
			poison_buffer -= delta
			drown_buildup += delta * 2.0
			drown_buildup_buffer = 0.3
		
		if drown_buildup_buffer > 0:
			drown_buildup_buffer -= delta
		else:
			drown_buildup -= delta 
	
	var death_sound : int = 2
	var multiplier : float = 3.5
	
	var s : AudioStreamPlayer2D = %sizzle
	
	if (in_poison) or (poison_buffer > 0):
		death_sound = 3
		multiplier = 1.0
		
		if not s.playing:
			s.play()
	else:
		if s.playing:
			s.stop()
	
	if drown_buildup >= max_drown_buildup:
		return_to_checkpoint(death_sound,multiplier)
	
	if drown_buildup > 0:
		p.modulate.a = move_toward(p.modulate.a,1.0,delta * 3.0)
	else:
		p.modulate.a = 0.0
	
	drown_buildup = clampf(drown_buildup,0,max_drown_buildup)

func scream(scream_type : int = 0):
	if not can_scream:
		return
	
	match scream_type:
		0:
			%scream.play()
		1:
			%scream2.play()
		2:
			%scream3.play()
		3:
			%scream4.play()
	

func return_to_checkpoint(scream_type : int = 0,duration_multiplier : float = 1.0):
	can_control = false
	scream(scream_type)
	destroy_grapple()
	can_scream = false
	drown_buildup = 0.0
	drown_buildup_buffer = 0.0
	poison_buffer = 0.0
	Global.set_fade_screen(false)
	await Global.fade_animation_finished
	await  get_tree().create_timer(1.4 * duration_multiplier,false).timeout
	linear_velocity *= 0
	self.global_position = last_checkpoint
	self.rotation = 0
	drown_buildup = 0.0
	
	for n in get_children():
		if n is Camera2D:
			n.reset_smoothing()
	
	await  get_tree().create_timer(0.5,false).timeout
	Global.set_fade_screen(true)
	await Global.fade_animation_finished
	can_control = true

func teleport_to_waypoint(waypoint : int):
	var waypoint_pos : Vector2 = Global.waypoint_position[Waypoint.WAYPOINTS.keys()[waypoint]]
	
	Global.clear_map.emit()
	can_control = false
	#scream(scream_type)
	destroy_grapple()
	can_scream = false
	drown_buildup = 0.0
	drown_buildup_buffer = 0.0
	poison_buffer = 0.0
	Global.set_fade_screen(false)
	await Global.fade_animation_finished
	await  get_tree().create_timer(1.0).timeout
	linear_velocity *= 0
	self.global_position = waypoint_pos
	self.rotation = 0
	drown_buildup = 0.0
	
	for n in get_children():
		if n is Camera2D:
			n.reset_smoothing()
	
	await  get_tree().create_timer(1.6,false).timeout
	Global.set_fade_screen(true)
	await Global.fade_animation_finished
	Global.can_use_waypoints = true
	can_control = true
