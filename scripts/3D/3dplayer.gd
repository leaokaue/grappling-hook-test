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

var can_run : bool = false

var physics_paused : bool = false

#@export var tube : Intro
@onready var camera : Camera3D = %Camera
@onready var flashlight : SpotLight3D = %Flashlight
@onready var interact_cast : RayCast3D = %InteractCast

var current_interactable : Interactable3D

var hide_interact_prompt : bool = false

func _ready() -> void:
	get_tree().set_auto_accept_quit(true)
	initial_position = self.global_position
	initial_rotation = camera.rotation
	capture_mouse()
	disable_flashlight(false)
	#begin_intro()

func _unhandled_input(event: InputEvent) -> void:
	
	if player_paused: return
	
	if returning: return
	
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.0015
		if mouse_captured: _rotate_camera()
	if event.is_action_pressed("flashlight"):
		if flashlight_active:
			disable_flashlight()
		else:
			enable_flashlight()
	
	if Input.is_action_just_pressed("interact"):
		_try_interact()

func _physics_process(delta: float) -> void:
	#if Input.is_action_just_pressed(&"jump"): jumping = true
	if mouse_captured and not player_paused: _handle_joypad_camera_rotation(delta) 
	
	if physics_paused: return
	
	handle_interactable_ray()
	
	var vel : Vector3 = Vector3()
	
	if is_on_floor() and not player_paused:
		vel += _walk(delta)
	vel += _gravity(delta)
	velocity = vel
	
	if (velocity.z != 0 or velocity.x != 0) and is_on_floor():
		if walk_timer > 0:
			walk_timer -= delta
		else:
			walk_timer = 0.55
			$Footstep.play()
	
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
	$FlashlightSound.pitch_scale = 0.5
	$FlashlightSound.play()

func disable_flashlight(play_sound : bool = true) -> void:
	flashlight_active = false
	flashlight.light_energy = 0.0
	$FlashlightSound.pitch_scale = 0.3
	if play_sound:
		$FlashlightSound.play()

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
	move_dir = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backwards")
	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
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

func lerp_flashlight_rotation(delta : float) -> void:
	var camrot := camera.rotation
	flashlight.rotation = flashlight.rotation.lerp(camrot,0.2)

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
				%InteractLabel.show()
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
