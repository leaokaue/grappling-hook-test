extends RigidBody2D
class_name Worm

@warning_ignore("unused_signal")
signal emit_dash_cooldown(cooldown : float)

signal emit_fish_cooldown(cooldown : float)

signal emit_hover_cooldown(cooldown : float)

signal emit_jetpack_cooldown(cooldown : float)

var last_checkpoint : Vector2

@export var debug_mode : bool = false

@onready var animated_sprite_2d = %Sprite2D
@onready var ray_cast_2d = $RayCast2D

#PLAYER

const MOVE_SPEED = 50
const MAX_SPEED = 100
const JUMP_FORCE = -450

var can_control : bool = true

var default_gravity : float = 1.0

#EQUIPMENT

@onready var dashcast : RayCast2D = $DashCast

var dash_direction : int = 1

var dash_cooldown : float = 0.0

const max_dash_cooldown : float = 2.0

var previous_tambaqui_state : bool = false

var is_tambaqui : bool = false : set = set_is_tambaqui

var tambaqui_bar : float = 7.0

const tambaqui_max_bar : float = 7.0

var last_fish_trail : Node2D

var hover_position : float = 0.0

var is_hovering : bool = false

var hover_bar : float = 4.0

const max_hover_bar : float = 4.0

var is_jetpacking : bool = false

var jetpack_bar : float = 2.5

const max_jetpack_bar : float = 2.5

#LIQUIDS

var drown_buildup_buffer : float = 0.0

var poison_buffer : float = 0.0

var drown_buildup : float = 0.0 

var max_drown_buildup : float = 2.5

var in_liquid : bool = false

#var can_jump : bool = true

var can_cancel_jump : bool = true

var is_freefalling : bool = false : set = set_is_freefalling

#HOOK / FREEFALL

var is_grappling : bool = false

var previous_freefall_state : bool = false

var can_scream : bool = true

var time_fallen : float = 0.0

var current_hook_cooldown : float = 0.0

var max_hook_cooldown : float = 1.2

var can_hook : bool = true

var hook : GrappleHook

@onready var line := $Line2D

var last_trail : LineTrail2D


#var global_joint : PinJoint2D

var global_joint : DampedSpringJoint2D

const ui := preload("res://scenes/ui.tscn")

const gr := preload("res://scenes/grapple.tscn")

const map := preload("res://scenes/map.tscn")

func _ready() -> void:
	create_ui()
	Global.teleport_to_waypoint.connect(teleport_to_waypoint)
	Global.player = self
	Global.get_coin_vec2_array()
	if debug_mode:
		last_checkpoint = global_position

func _process(delta: float) -> void:
	if not can_hook:
		
		var m : float = 1.0
		
		if Global.has_cool_drink:
			m = 1.5
		
		current_hook_cooldown -= delta * m
		if current_hook_cooldown < 0:
			can_hook = true

func _physics_process(delta):
	var direction : float = Input.get_axis("left", "right")
	var force = Vector2.ZERO
	
	
	if is_freefalling:
		if linear_velocity.x > 1:
			dash_direction = 1
		elif linear_velocity.x < -1:
			dash_direction = -1
		elif linear_velocity.x == 0:
			dash_direction = 0
	elif direction != 0:
		dash_direction = round(direction)
	
	#print(dash_direction)
	
	handle_non_control(delta)
	
	if (direction != 0) and (not is_grappling) and (not in_liquid):
		is_freefalling = false
	
	if not can_control:
		return
	
	if Input.is_action_just_pressed("grapple"):
		if is_tambaqui:
			apply_tambaqui_dash()
		elif not is_grappling:
			grapple()
		else:
			destroy_grapple()
	
	if Input.is_action_pressed("dash"): #and Input.is_action_pressed("stop"):
		if Global.current_equipment == Global.EQUIPMENTS.HoverStone:
			if not is_hovering:
				if hover_bar > 1.0:
					is_hovering = true
	else:
		if Global.current_equipment == Global.EQUIPMENTS.HoverStone:
			if is_hovering:
				is_hovering = false
	
	apply_hoverstone(delta)
	
	if Input.is_action_just_pressed("retract"):
		if Global.current_equipment == Global.EQUIPMENTS.Tambaqui:
			if not is_grappling:
				if tambaqui_bar > 1.2:
					is_tambaqui = true
					print("Entering Tambaqui Mode")
	
	elif Input.is_action_pressed("retract"):
		if is_grappling:
			if hook.grappled:
				retract(delta)
	
	apply_tambaqui(delta)
	
	
	if Input.is_action_just_released("retract"):
		#print("Exiting")
		if is_tambaqui:
			is_tambaqui = false
	
	if Input.is_action_just_pressed("dash"):
			if Global.current_equipment == Global.EQUIPMENTS.DashBoots:
				if dash_cooldown >= max_dash_cooldown:
					#%LineTrail2D.show()
					#%LineTrail2D.set_point_position(0,dashcast.global_position)
					apply_dash()
	
	# UPGRADE /////////////////////////////////////////////////////////////
	
	var m_bonus : float = 1.0
	
	if Global.has_steroids_3:
		m_bonus = 1.35
		m_bonus = 1.35
	# UPGRADE /////////////////////////////////////////////////////////////
	
	if is_hovering:
		m_bonus += 0.40
	
	if direction != 0:
		if (not is_freefalling) or (in_liquid):
			force.x = (MOVE_SPEED * m_bonus) * direction
			physics_material_override.friction = 0.1
			if abs(linear_velocity.x) > (MAX_SPEED * m_bonus):
				linear_velocity.x = (MAX_SPEED * m_bonus) * direction
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
	
	# UPGRADE /////////////////////////////////////////////////////////////
	var j_bonus : float = 1.0
	
	if Global.has_steroids_2:
		j_bonus = 1.35
	# UPGRADE /////////////////////////////////////////////////////////////
	
	if Input.is_action_just_pressed("jump"):
		if is_grappling:
			if is_instance_valid(hook):
				if hook.grappled:
					force.y = (JUMP_FORCE * j_bonus)* 0.8
					destroy_grapple()
		elif _on_floor(): 
			force.y = (JUMP_FORCE * j_bonus)
	
	if Input.is_action_just_released("jump"):
		if linear_velocity.y < 0:
			if can_cancel_jump:
				can_cancel_jump = false
				linear_velocity.y *= 0.5
		
	
	if Input.is_action_just_pressed("stop"):
		if _on_floor():
			linear_velocity = Vector2()
		
	
	_set_animation(direction)
	
	#print(force)
	
	apply_central_impulse(force)

func apply_dash():
	#print(dash_direction)
	
	%LineTrail2D.set_point_position(0,Vector2(0,0))
	
	if dash_direction == 0:
		return
	
	var length : float = (dashcast.get_collision_point() - dashcast.global_position).length()
	
	print(length)
	
	if length < 20:
		return
	
	%teleport1.emitting = true
	
	dash_cooldown = 0.0
	
	await get_tree().physics_frame
	
	%teleport1.show()
	
	#var dash_length : float = 125
	
	var col_decrease : float = 10
	
	if dash_direction > 0:
		#dashcast.target_position.x = 175
		col_decrease = 25
	else:
		#dashcast.target_position.x = -175
		col_decrease = 5
	
	await get_tree().physics_frame
	
	var col : Vector2
	
	if dashcast.is_colliding():
		col = dashcast.get_collision_point() - Vector2(col_decrease,0.0)
		self.global_position = col
	else:
		self.global_position += dashcast.target_position
		col = dashcast.target_position + dashcast.global_position
	
	print(linear_velocity.y)
	
	if linear_velocity.y > 0:
		linear_velocity.y = 0
	
	print(linear_velocity.y)
	
	%LineTrail2D.set_point_position(1,dashcast.global_position - col)
	
	%teleport2.emitting = true
	
	#%LineTrail2D.set_point_position(1,Vector2(0,0))

func apply_tambaqui(delta : float):
	if is_tambaqui:
		is_freefalling = true
		
		var speed : float = 125
		var vel_dec : float = 0.5
		
		drown_buildup -= delta * 0.5
		
		if is_instance_valid(last_fish_trail):
			last_fish_trail.global_position = self.global_position
			last_fish_trail.global_rotation = self.global_rotation
		
		if in_liquid:
			vel_dec = 0.0
			speed = 375
		
		if Global.has_steroids_3:
			speed += 100
		
		var dir := (get_global_mouse_position() - self.global_position).normalized()
		self.rotation = dir.rotated(Vector2.DOWN.angle()).angle()
		
		linear_velocity *= vel_dec * delta
		apply_central_impulse(dir * speed)

func apply_hoverstone(_delta : float):
	if is_hovering:
		%hover.emitting = true
		#linear_velocity.y = lerp(linear_velocity.y,0.0,1.5)
		linear_velocity.y = 0.0
		#print(linear_velocity.y)
		apply_central_impulse(25 * Vector2.UP)
	else:
		%hover.emitting = false

func apply_jetpack(delta : float):
	pass

func apply_tambaqui_dash():
	if is_tambaqui:
		if tambaqui_bar < 1.2:
			return
		
		tambaqui_bar -= 1.2
		is_freefalling = true
		
		var speed : float = 220
		%splash.emitting = true
		if (drown_buildup_buffer > 0) or (in_liquid):
			speed = 330
		
		var dir := (get_global_mouse_position() - self.global_position).normalized()
		self.rotation = dir.rotated(Vector2.DOWN.angle()).angle()
		
		is_tambaqui = false
		
		
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().physics_frame
		
		apply_central_impulse(dir * (speed * 4))
		
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().physics_frame
		
		set_fish_trail(true)
		
		await get_tree().create_timer(2.0,false).timeout
		
		if not is_tambaqui:
			set_fish_trail(false)
		

func handle_dashcast():
	
	if not Global.current_equipment == Global.EQUIPMENTS.DashBoots:
		$Marker.hide()
		return
	
	
	var col_decrease : float
	
	var col : Vector2
	
	if dash_direction > 0:
		dashcast.target_position.x = 175
		col_decrease = 25
	else:
		dashcast.target_position.x = -175
		col_decrease = -25
	
	if dashcast.is_colliding():
		col = dashcast.get_collision_point() - Vector2(col_decrease,0.0)
	else:
		col = dashcast.target_position + dashcast.global_position
	
	#print(dash_direction)
	
	if (abs(col - dashcast.global_position).length() > 25) and (dash_direction != 0):
		$Marker.show()
	else:
		#print("hiding marker")
		$Marker.hide()
	
	%Marker.global_position.y = lerp(%Marker.global_position.y,col.y,0.9)
	%Marker.global_position.x = lerp(%Marker.global_position.x,col.x,0.3)

func handle_non_control(delta : float):
	check_length()
	
	handle_coin_compass()
	
	handle_dashcast()
	
	handle_failsafes(delta)
	
	#print(Engine.time_scale)
	
	handle_liquids(delta)
	
	handle_equipment_cooldowns(delta)
	
	if is_grappling:
		rotate_joint()
		
		if is_instance_valid(hook):
			line.set_point_position(0,self.global_position)
			line.set_point_position(1,hook.global_position)
			#print(hook.global_position)
			line.show()
			if hook.grappled:
				self.default_gravity = 0.7
			else:
				self.default_gravity = 1.0
	else:
		self.default_gravity = 1.0
		line.hide()
	
	check_length()
	
	if (not is_grappling) and (not _on_floor()) and (not in_liquid) and (not is_tambaqui) and (not is_hovering):
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
	

func handle_equipment_cooldowns(delta : float):
	
	if _on_floor():
		if dash_cooldown < max_dash_cooldown:
			dash_cooldown += delta * 1.5
	elif not is_grappling:
		if dash_cooldown < max_dash_cooldown:
			dash_cooldown += delta * 1.4
	
	dash_cooldown = clampf(dash_cooldown,0.0,max_dash_cooldown)

	emit_dash_cooldown.emit(dash_cooldown)
	
	if not is_tambaqui:
		if in_liquid:
			if tambaqui_bar < tambaqui_max_bar:
				tambaqui_bar += delta * 0.75
		else:
			if tambaqui_bar < tambaqui_max_bar:
				tambaqui_bar += delta * 0.01
	else:
		if tambaqui_bar > 0:
			if in_liquid:
				tambaqui_bar -= delta
			else:
				tambaqui_bar -= delta * 1.15
		else:
			is_tambaqui = false
	
	tambaqui_bar = clampf(tambaqui_bar,0.0,tambaqui_max_bar)
	
	emit_fish_cooldown.emit(tambaqui_bar)
	
	if not is_hovering:
		if  not is_grappling:
			if hover_bar < max_hover_bar:
				hover_bar += delta * 0.35
		#elif is_grappling:
			#if hover_bar < max_hover_bar:
				#hover_bar += delta * 0.1 
	else:
		if hover_bar > 0:
			hover_bar -= delta * 0.55
		else:
			is_hovering = false
	
	hover_bar = clampf(hover_bar,0.0,max_hover_bar)
	
	emit_hover_cooldown.emit(hover_bar)

func set_is_freefalling(freefalling : bool):
	if previous_freefall_state == freefalling:
		return
	
	is_freefalling = freefalling
	
	previous_freefall_state = is_freefalling
	
	if freefalling:
		#print("created line")
		var t := $LineTrail2D.duplicate()
		t.active = true
		t.follow_player = true
		last_trail = t
		get_tree().current_scene.add_child(t)
	else:
		if is_instance_valid(last_trail):
			#print("killed  line")
			last_trail.fading_away = true
			last_trail.follow_player = false

func set_is_tambaqui(tambaqui : bool):
	if previous_tambaqui_state == tambaqui:
		return
	
	is_tambaqui = tambaqui
	
	previous_tambaqui_state = is_tambaqui
	
	if not tambaqui:
		linear_velocity *= 0
	
	set_fish_trail(tambaqui)

func set_fish_trail(tambaqui : bool):
	var f : Node2D = $FishTrails
	
	var fd := f.duplicate()
	
	if tambaqui:
		for child in fd.get_children():
			if child is LineTrail2D:
				child.active = true
				#child.follow_player = true
		
		last_fish_trail = fd
		get_tree().current_scene.add_child(fd)
	else:
		if is_instance_valid(last_fish_trail):
			for child in last_fish_trail.get_children():
				if child is LineTrail2D:
					child.fading_away = true
					#child.follow_player = false

@warning_ignore("unused_parameter")
func _integrate_forces(state):
	if not is_freefalling:
		rotation_degrees = lerp(rotation_degrees,0.0,0.8)

func _set_animation(direction):
	if direction > 0: animated_sprite_2d.flip_h = false
	elif direction < 0: animated_sprite_2d.flip_h = true

func _on_floor():
	
	if in_liquid:
		return false
	
	if is_freefalling:
		if $RagddollCast.is_colliding():
			can_cancel_jump = true
			return true
	else:
		if ray_cast_2d.is_colliding():
			can_cancel_jump = true
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
	
	g.grappled = false
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

func handle_liquids(delta : float):
	if not can_control:
		drown_buildup = 0.0
		return
	
	var p : TextureProgressBar = %poison
	
	p.max_value = max_drown_buildup
	p.value = drown_buildup
	p.show()
	
	var in_water : bool = false
	var in_poison : bool = false
	
	in_liquid = false
	
	if $PoisonCast.is_colliding():
		in_liquid = true
		in_poison = true
	elif $WaterCast.is_colliding():
		in_liquid = true
		in_water = true
	
	handle_liquid_gravity(delta,in_water,in_poison)
	
	
	if in_poison:
		poison_buffer = 0.3
		if poison_buffer > 0:
			if not Global.has_poison_resist:
				drown_buildup += delta * 1.5
				drown_buildup_buffer = 0.3
			else:
				drown_buildup += delta * 0.2
				drown_buildup_buffer = 0.1
		#apply_central_force(Vector2(0,-1) * 600)
	elif in_water:
		drown_buildup += delta * 0.15
		drown_buildup_buffer = 0.3
		#apply_central_force(Vector2(0,-1) * 1100)
	else:
		if poison_buffer > 0:
			poison_buffer -= delta
			
			if not Global.has_poison_resist:
				drown_buildup += delta * 1.5
				drown_buildup_buffer = 0.3
			else:
				drown_buildup += delta * 0.45
				drown_buildup_buffer = 0.1
		
		if drown_buildup_buffer > 0:
			drown_buildup_buffer -= delta
		else:
			drown_buildup -= delta 
	
	var death_sound : int = 2
	var multiplier : float = 3.5
	
	var s : AudioStreamPlayer2D = %sizzle
	
	if Global.has_poison_resist:
		s.pitch_scale = 0.65
	else:
		s.pitch_scale = 1.0
	
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

func handle_liquid_gravity(_delta : float,in_water : bool,in_poison : bool):
	var _gravity : float = 1.0
	var _damp : float = 0.0
	
	if in_poison:
		_gravity *= 0.2
		linear_damp = 12
	elif in_water:
		linear_damp = 2
		gravity_scale *= 0.6
	else:
		linear_damp = 0.0
		gravity_scale = default_gravity

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
	
	var timeout := TimeoutManager.new()
	timeout.timeout = 60
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
	
	if Global.has_boost_latch:
		speed = 700
	
	apply_central_impulse(dir.normalized() * speed)

func create_ui():
	var u := ui.instantiate()
	get_tree().current_scene.add_child.call_deferred(u)

func scream(scream_type : int = 0):
	if not can_scream:
		return
	
	match scream_type:
		0:
			%scream.play()
		1:
			%scream2.play()
			explode_animation()
		2:
			%scream3.play()
		3:
			%scream4.play()
	

var is_teleporting : bool = false

@onready var previous_pos : Vector2 = self.global_position

@onready var current_pos : Vector2 = self.global_position

func handle_failsafes(_delta : float):
	current_pos = self.global_position
	
	if ((previous_pos - current_pos).length() > 500) and (not is_teleporting):
		self.global_position = previous_pos
		Global.reset_camera_smoothing.emit()
		#self.linear_velocity *= 0
		
	
	previous_pos = self.global_position

func return_to_checkpoint(scream_type : int = 0,duration_multiplier : float = 1.0):
	can_control = false
	is_teleporting = true
	scream(scream_type)
	destroy_grapple()
	can_scream = false
	drown_buildup = 0.0
	drown_buildup_buffer = 0.0
	poison_buffer = 0.0
	is_tambaqui = false
	set_is_freefalling(false)
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
	
	unexplode_animation()
	
	await  get_tree().create_timer(0.5,false).timeout
	Global.set_fade_screen(true)
	await Global.fade_animation_finished
	is_teleporting = false
	can_control = true

var exploded : bool = false

func explode_animation():
	if not exploded:
		exploded = true
		%explode.emitting = true
		%Sprite.hide()
		#print("exploding")
		self.set_deferred("freeze",true)

func unexplode_animation():
	if exploded:
		#print("not exploding")
		exploded = false
		%Sprite.show()
		self.set_deferred("freeze",false)

func teleport_to_waypoint(waypoint : int):
	var waypoint_pos : Vector2 = Global.waypoint_position[Waypoint.WAYPOINTS.keys()[waypoint]]
	
	Global.clear_map.emit()
	can_control = false
	is_teleporting = true
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
	unexplode_animation()
	self.rotation = 0
	drown_buildup = 0.0
	
	for n in get_children():
		if n is Camera2D:
			n.reset_smoothing()
	
	
	await  get_tree().create_timer(1.6,false).timeout
	Global.set_fade_screen(true)
	await Global.fade_animation_finished
	Global.can_use_waypoints = true
	is_teleporting = false
	can_control = true

func handle_coin_compass():
	if Global.has_coin_compass:
		%CoinCompass.show()
		
		
		var shortest_pos : Vector2 = Vector2(0,0)
		
		for p in Global.coin_positions:
			var pp := (shortest_pos - self.global_position).length()
			
			if (p - self.global_position).length() < pp:
				shortest_pos = p 
		
		var a : float = (shortest_pos - self.global_position).angle()
		
		%CoinCompass.rotation = a
		
	else:
		%CoinCompass.hide()
