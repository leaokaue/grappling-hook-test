extends RigidBody2D
class_name Worm

var last_checkpoint : Vector2

@onready var animated_sprite_2d = %Sprite2D
@onready var ray_cast_2d = $RayCast2D

const MOVE_SPEED = 50
const MAX_SPEED = 100
const JUMP_FORCE = -450

var can_control : bool = true

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

func _ready() -> void:
	create_ui()
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
	
	if (direction != 0) and (not is_grappling):
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
		if not is_freefalling:
			force.x = MOVE_SPEED * direction
			physics_material_override.friction = 0.1
			if abs(linear_velocity.x) > MAX_SPEED:
				linear_velocity.x = MAX_SPEED * direction
				#linear_velocity.x = move_toward(linear_velocity.x,MAX_SPEED * direction, delta * 3)
				#print(linear_velocity.x)
	else:
		physics_material_override.friction = 1.0
	
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
	
	if (not is_grappling) and (not _on_floor()):
		var t : float = 1
		if is_freefalling:
			t = 1.5
		time_fallen += delta * t
		if time_fallen > 5.0:
			scream()
			time_fallen = 0.0
			can_scream = false
	else:
		time_fallen = 0.0
	
	
	if _on_floor():
		can_scream = true
	

func _integrate_forces(state):
	if not is_freefalling:
		rotation_degrees = 0

func _set_animation(direction):
	if direction > 0: animated_sprite_2d.flip_h = false
	elif direction < 0: animated_sprite_2d.flip_h = true
	
	#if not _on_floor(): animated_sprite_2d.play("jump")
	#elif abs(linear_velocity.x) > 0.1: animated_sprite_2d.play("run")
	#else: animated_sprite_2d.play("idle")

func _on_floor():
	if is_freefalling:
		if $RagddollCast.is_colliding():
			return true
	else:
		if ray_cast_2d.is_colliding():
			return true

func grapple():
	
	if not can_hook:
		return
	
	current_hook_cooldown = max_hook_cooldown
	can_hook = false
	
	var g := gr.instantiate()
	var dir := (get_global_mouse_position() - self.global_position).normalized() * 500 * 3
	
	is_grappling = true
	is_freefalling = true
	
	g.hit.connect(impulse_to_grapple)
	g.hit.connect(create_joint)
	g.global_position = self.global_position
	g.apply_central_impulse(dir)
	
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
		var length := dir.length()
		
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
			
			print("is_retracting")
			
			global_joint.rest_length -= 50 * delta
			global_joint.rest_length = clampf(global_joint.rest_length,30,1000)
			
			global_joint.length -= 50 * delta
			global_joint.length = clampf(global_joint.length,30,1000)
		
		if not is_instance_valid(hook):
			return
		
		print("trying to retract")
		
		var dir := (hook.global_position - self.global_position)
		var speed := 1000.0
		var length := dir.length()
		if length > 20:
			print("applying speed")
			apply_central_force(dir.normalized() * speed)

func check_length():
	if is_instance_valid(hook):
		var dir := (hook.global_position - self.global_position)
		var length := dir.length()
		
		var max_length := 500
		
		if is_instance_valid(hook):
			if hook.grappled:
				max_length = 650
		
		if length > max_length:
			destroy_grapple()

func impulse_to_grapple():
	var dir := (hook.global_position - self.global_position)
	var speed := 500.0
	apply_central_impulse(dir.normalized() * speed)

func create_ui():
	var u := ui.instantiate()
	get_tree().current_scene.add_child.call_deferred(u)

func scream():
	if not can_scream:
		return
	
	%scream.play()
	

func return_to_checkpoint():
	can_control = false
	scream()
	Global.set_fade_screen(false)
	await Global.fade_animation_finished
	linear_velocity *= 0
	self.global_position = last_checkpoint
	self.rotation = 0
	await  get_tree().create_timer(1.5,false).timeout
	Global.set_fade_screen(true)
	await Global.fade_animation_finished
	can_control = true

func teleport_to_waypoint(waypoint : int):
	pass
