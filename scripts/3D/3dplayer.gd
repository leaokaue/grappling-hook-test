class_name Player extends CharacterBody3D

signal intro_finished

@export var sounds : Array[AudioStreamPlayer]
@export var plane_collision : CollisionShape3D
@export var platform : Node3D

@export_range(1, 35, 1) var speed: float = 10 # m/s
@export_range(10, 400, 1) var acceleration: float = 100 # m/s^2

@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m
@export_range(0.1, 3.0, 0.1, "or_greater") var camera_sens: float = 1

var jumping: bool = false
var mouse_captured: bool = false
var flashlight_active : bool = false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var move_dir: Vector2 # Input direction for movement
var look_dir: Vector2 # Input direction for look/aim

var walk_vel: Vector3 # Walking velocity 
var grav_vel: Vector3 # Gravity velocity 
var jump_vel: Vector3 # Jumping velocity

var returning : bool = false

var initial_position : Vector3
var initial_rotation : Vector3

var walk_timer : float = 0.6

var player_paused : bool = false

var quest_begun : bool = false

var quest_completed : bool = false

var terminal_finished : bool = false

var flashlight_flickering : bool = false

var flicker_timer : float = 0.1

var afraid : bool = false

var physics_paused : bool = false

#@export var tube : Intro
@onready var camera : Camera3D = %Camera
@onready var flashlight : SpotLight3D = %Flashlight
@onready var interact_cast : RayCast3D = %InteractCast
@onready var dialogue_label : RichTextLabel = %Dialogue
@onready var flashlight_bar : TextureProgressBar = %FlashlightBar

var flashlight_power : float = 5.0

var max_flashlight_power : float = 5.0

var dialoguing : float = 0.0

var current_interactable : Interactable3D

var hide_interact_prompt : bool = false

func _ready() -> void:
	flashlight_bar.modulate.a = 0.0
	hide_red_vignette()
	get_tree().set_auto_accept_quit(true)
	initial_position = self.global_position
	initial_rotation = camera.rotation
	capture_mouse()
	disable_flashlight(false)
	#begin_intro()

func _unhandled_input(event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("interact"):
		_try_interact()
	
	if player_paused: return
	
	if returning: return
	
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.0015
		if mouse_captured: _rotate_camera()
	if event.is_action_pressed("flashlight"):
		if flashlight_active:
			disable_flashlight()
		else:
			if flashlight_power > 0.5:
				flashlight_power -= 0.25
				enable_flashlight()
			else:
				print(flashlight_power)
				flashlight_power = -1.0
				disable_flashlight()

func _physics_process(delta: float) -> void:
	#if Input.is_action_just_pressed(&"jump"): jumping = true
	if mouse_captured and not player_paused: _handle_joypad_camera_rotation(delta) 
	
	if flashlight_active:
		flashlight_power -= delta
	else:
		flashlight_power += delta
	
	if flashlight_power < 0:
		if flashlight_active:
			flashlight_power -= 1.0
			disable_flashlight(true)
	
	flashlight_power = clampf(flashlight_power,-1.0,max_flashlight_power)
	_handle_flashlight_bar(delta)
	
	if physics_paused: return
	
	handle_interactable_ray()
	
	var vel : Vector3 = Vector3()
	
	if dialoguing > 0:
		dialoguing -= delta
		dialogue_label.show()
	else:
		dialogue_label.hide()
	
	if is_on_floor() and not (player_paused or returning):
		vel += _walk(delta)
	vel += _gravity(delta)
	velocity = vel
	
	if (velocity.z != 0 or velocity.x != 0) and is_on_floor():
		if walk_timer > 0:
			walk_timer -= delta
		else:
			if not afraid:
				walk_timer = 0.55
			else:
				walk_timer = 0.4
			$Footstep.play()
	
	_handle_flickering(delta)
	
	lerp_flashlight_rotation(delta)
	
	move_and_slide()

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func enable_flashlight() -> void:
	flashlight_active = true
	flashlight.light_energy = 5.0
	%FlashlightCollision.disabled = false
	$FlashlightSound.pitch_scale = 0.5
	$FlashlightSound.play()

func disable_flashlight(play_sound : bool = true) -> void:
	flashlight_active = false
	flashlight.light_energy = 0.0
	%FlashlightCollision.set_deferred("disabled",true)
	$FlashlightSound.pitch_scale = 0.3
	if play_sound:
		$FlashlightSound.play()

func _handle_flashlight_bar(delta : float):
	if flashlight_power < 5.0:
		flashlight_bar.modulate.a = move_toward(flashlight_bar.modulate.a,1.0,delta * 5.0)
	else:
		flashlight_bar.modulate.a = move_toward(flashlight_bar.modulate.a,0.0,delta * 5.0)
	
	flashlight_bar.value = (flashlight_power * 20.0)

func _handle_flashlight_area():
	if flashlight_active:
		pass

func _rotate_camera(sens_mod: float = 1.0) -> void:
	camera.rotation.y -= look_dir.x * camera_sens * sens_mod
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)

func _handle_joypad_camera_rotation(delta: float, sens_mod: float = 1.0) -> void:
	var joypad_dir: Vector2 = Input.get_vector(&"look_left", &"look_right", &"look_up", &"look_down")
	if joypad_dir.length() > 0:
		look_dir += joypad_dir * delta
		_rotate_camera(sens_mod)
		look_dir = Vector2.ZERO

func _walk(delta: float) -> Vector3:
	var bonus : float = 0.0
	if afraid:
		bonus += 1.25
	move_dir = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backwards")
	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * (speed + bonus) * move_dir.length(), acceleration * delta)
	return walk_vel

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() or is_on_ceiling_only() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel

func _handle_flickering(delta : float):
	if not flashlight_active: return
	
	if not flashlight_flickering: return
	
	if flicker_timer > 0:
		flicker_timer -= delta
	else:
		flicker_timer = randf_range(0.3,0.15)
		flicker_flashlight()

func flicker_flashlight():
	if not flashlight_active: return
	flashlight.light_energy = 0.0
	flashlight.light_indirect_energy = 0.0
	flashlight.light_volumetric_fog_energy = 0.0
	await get_tree().create_timer(randf_range(0.01,0.08),false).timeout
	if not flashlight_active: return
	flashlight.light_energy = 6.0
	flashlight.light_indirect_energy = 1.0
	flashlight.light_volumetric_fog_energy = 1.556

func lerp_flashlight_rotation(delta : float) -> void:
	var camrot := camera.rotation
	flashlight.rotation = flashlight.rotation.lerp(camrot,(0.2 / 0.025) * delta)

func handle_interactable_ray():
	if interact_cast.is_colliding():
		var c := interact_cast.get_collider()
		#print(c)
		if c is Interactable3D:
			current_interactable = c
			%InteractLabel.text = c.get_description()
			if not c.can_see_description:
				%InteractLabel.hide()
			else:
				if not dialoguing > 0:
					
					%InteractLabel.show()
				else:
					%InteractLabel.hide() # holy nest
		else:
			%InteractLabel.hide()
			current_interactable = null
	else:
		%InteractLabel.hide()
		current_interactable = null

func _try_interact():
	if current_interactable:
		if current_interactable.interactable:
			current_interactable.interact()

func return_to_spawn():
	returning = true
	velocity *= 0.0
	flashlight_power = 5.0
	%FogVolume.material.density = 0.0
	%FogVolume.show()
	var t := create_tween()
	t.set_trans(Tween.TRANS_EXPO)
	t.tween_property(%FogVolume,"material:density",10.0,1.5)
	await get_tree().create_timer(1.5,false).timeout
	global_position = initial_position
	camera.rotation = initial_rotation
	await get_tree().create_timer(1.0,false).timeout
	var t2 := create_tween()
	t2.set_trans(Tween.TRANS_EXPO)
	t2.tween_property(%FogVolume,"material:density",0.0,0.5)
	await get_tree().create_timer(1.4,false).timeout
	returning = false

func pop_black_screen():
	print("popping black screen")
	var t := create_tween()
	%Nightmare.hide()
	t.set_trans(Tween.TRANS_EXPO)
	t.tween_property(%KilledRect,"modulate:a",1.0,0.2)
	t.tween_property(%KilledRect,"modulate:a",0.0,0.5)

func return_kill():
	returning = true
	velocity *= 0.0
	var t := create_tween()
	%Nightmare.show()
	t.tween_property(%KilledRect,"modulate:a",1.0,0.15)
	await get_tree().create_timer(4.0,false).timeout
	global_position = initial_position
	camera.rotation = initial_rotation
	Global.reset_glitched.emit()
	%Nightmare.hide()
	await get_tree().create_timer(0.1,false).timeout
	var t2 := create_tween()
	t2.set_trans(Tween.TRANS_EXPO)
	t2.tween_property(%KilledRect,"modulate:a",0.0,1.5)
	await get_tree().create_timer(1.4,false).timeout
	returning = false

func begin_intro():
	$Machine.play()
	handle_intro_fade()
	player_paused = true
	physics_paused = true
	disable_collision(15.0)
	self.global_position.y -= 60
	var t := create_tween()
	var t2 := create_tween()
	set_sound_db(-90)
	t.tween_property(self,"global_position:y",initial_position.y,20.0)
	t2.set_trans(Tween.TRANS_EXPO)
	t2.set_ease(Tween.EASE_OUT)
	t2.tween_method(set_sound_db,-90.0,-45.0,7.5).set_delay(10.0)
	await t.finished
	$Machine.stop()
	$Klunk.play()
	intro_finished.emit()
	plane_collision.disabled = false
	platform.show()
	player_paused = false
	physics_paused = false

func handle_intro_fade():
	%Fade.show()
	%IntroLabel.show()
	var t : Tween = create_tween()
	t.tween_interval(1.0)
	t.tween_property(%Fade,"modulate:a",0.0,4.0)
	t.parallel().tween_property(%IntroLabel,"modulate:a",0.0,2.0).set_delay(3.0)

func set_sound_db(db : float):
	for s in sounds:
		s.volume_db = db

func disable_collision(delay : float):
	await get_tree().create_timer(delay,false).timeout
	plane_collision.disabled = true

func set_dialogue(dialogue : String,time : float = 5.0):
	dialoguing = time
	dialogue_label.text = dialogue

func set_red_vignette_strength(value : float):
	(%RedVignette.material as ShaderMaterial).set_shader_parameter("vignette_strength",value)

var v_tween : Tween

func animate_v_tween():
	if v_tween:
		v_tween.kill()
	v_tween = create_tween()

func show_red_vignette(time : float = 0.0):
	animate_v_tween()
	v_tween.set_trans(Tween.TRANS_EXPO)
	v_tween.tween_method(set_red_vignette_strength,0.0,1.0,time)

func hide_red_vignette(time : float = 0.0):
	animate_v_tween()
	v_tween.tween_method(set_red_vignette_strength,1.0,0.0,time)

var fov_tween : Tween

func set_camera_fov(fov : float = 75.0):
	if fov_tween:
		fov_tween.kill()
	fov_tween = create_tween()
	fov_tween.tween_property(camera,"fov",fov,0.2)

func begin_end():
	pass
