extends CharacterBody3D
class_name NightmareCoinHunter

@export var hunt_positions : Array[Node3D]

@export var player : Player

@export var sounds : Array[AudioStreamPlayer3D]
@export var areas : Array[Area3D]
@export var pause_screen : PauseScreen3D

@export var heaven_sound : AudioStreamPlayer
@export var enviroment : WorldEnvironment

@onready var kill_area : Area3D = %KillArea
@onready var flashlight_detect : Area3D = %FlashlightDetect
@onready var centerpoint : Marker3D = %Centerpoint
@onready var sprite := %NightmareCoinSprite

@onready var scream_audio : AudioStreamPlayer3D = %Scream
@onready var fake_scream_audio : AudioStreamPlayer3D = %ScreamFake

signal begin_end

var first_hunt : bool = true

var final_hunt : bool = false

enum HUNT_TYPES {
	Fast, ## high speed, large sound radius
	Slow, ## lower speed, small sound radius
	Stalk, ## stands still, sound radius increases, once certain time passes, dashes towards at the end.
	Silent, ## no sound, red vignette creeps in
	End ## sound, vignette, etc, stands still, 
}

var hunt_type : HUNT_TYPES

var previous_hunt_types : Array[HUNT_TYPES]

var stalk_time : float = 0.0

var enraged : bool = false

var hunting : bool = false

var hand_shown : bool = false

##once 0, begin a hunt
var hunt_timer : float = 3

var min_hunt_time : float = 0.0:
	get():
		var value : float = 40
		
		var values : Array[float] = [40,35,30,25,25]
		
		var c :=  clampi(Global.glitch_coins_collected,0,values.size() - 1)
		
		value = values[c]
		
		return value

var max_hunt_time : float = 0.0:
	get():
		var value : float = 90
		
		var values : Array[float] = [75,70,65,60,60]
		
		var c :=  clampi(Global.glitch_coins_collected,0,values.size() - 1)
		
		value = values[c]
		return value

var hunt_timer_modifier : float = 1.0

var lit_up : bool = false

##the amount of power left in a hunt, decreases when flashlight is on the hunter.
var hunt_power : float = 0.0:
	set(value):
		value = clampf(value,0.0,4.5)
		hunt_power = value

##once 0, do fakeout scream, progresses during hunt
var fakeout_timer : float = 20.0

var can_fakeout : bool = false

##when active, counts down hunt timer
var active : bool = false

func _ready() -> void:
	hide_self()
	Global.clear_map.connect(increase_timer_modifier.bind(0.25))
	kill_area.body_entered.connect(kill_player)
	Global.reset_glitched.connect(reset)

func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	
	if (not active) and (not hunting):
		velocity = Vector3()
		return
	
	if Global.glitch_coins_collected >= 5:
		final_hunt = true
	else:
		final_hunt = false
	
	if hand_shown:
		%NightmareCoinSprite.offset = Vector2(randf_range(-10,10),randf_range(-10,10))
	
	_handle_fakeout_timer(delta)
	
	if not hand_shown:
		velocity.y += _gravity(delta).y
	
	_handle_hunt_timer(delta)
	
	_handle_lit_up(delta)
	
	_handle_hunting(delta)
	
	move_and_slide()

func _handle_lit_up(delta : float):
	
	#print(flashlight_detect.get_overlapping_areas().size())
	
	if flashlight_detect.monitoring:
		if flashlight_detect.get_overlapping_areas().size() > 0:
			lit_up = true
		else:
			lit_up = false
	
	if hunting:
		if lit_up:
			enraged = true
			sprite.modulate.v = 1.0
			%Scream.pitch_scale = 0.7
			if not %Scream2.playing:
				%Scream2.play()
			
			if final_hunt: return
			player.flashlight_flickering = true
			
			hunt_power -= delta
			#print(hunt_power)
			if hunt_power <= 0:
				go_away()
		else:
			player.flashlight_flickering = false
			%Scream2.stop()
			%Scream.pitch_scale = 1.0

func _handle_hunt_timer(delta : float):
	if hunting: return
	
	if final_hunt:
		hunt_timer = 0
	
	if hunt_timer > 0:
		hunt_timer -= (delta * hunt_timer_modifier)
	else:
		reset_hunt_timer()
		start_hunt()

func _handle_hunting(delta : float):
	if not hunting: return
	
	match hunt_type:
		HUNT_TYPES.Fast:
			_handle_fast_hunt(delta)
		HUNT_TYPES.Slow:
			_handle_slow_hunt(delta)
		HUNT_TYPES.Stalk:
			_handle_stalk_hunt(delta)
		HUNT_TYPES.Silent:
			_handle_silent_hunt(delta)
		HUNT_TYPES.End:
			_handle_final_hunt(delta)

func _handle_slow_hunt(_delta : float):
	if not enraged:
		move_towards_player(1.5)
	else:
		move_towards_player(3.0)

func _handle_fast_hunt(_delta : float):
	if not enraged:
		move_towards_player(2.5)
	else:
		move_towards_player(10.0)

func _handle_stalk_hunt(_delta : float):
	
	stalk_time += _delta
	
	if enraged or (stalk_time > 12.0):
		#print("fast as fok")
		move_towards_player(41.0)
	else:
		move_towards_player(0.0)

func _handle_silent_hunt(_delta : float):
	
	stalk_time += _delta
	
	if enraged or (stalk_time > 15.0):
		#print("fast as fok")
		move_towards_player(9.0)
	else:
		move_towards_player(0.0)

func _handle_final_hunt(delta : float):
	
	if lit_up:
		stalk_time += delta
	
	if stalk_time > 1.5:
		if not hand_shown:
			show_hand()

func move_towards_player(speed : float = 10):
	#print("moving towards player with speed ",speed)
	var to_player : Vector3 = (player.global_position - self.global_position).normalized()
	self.velocity = to_player * speed
	#print(velocity)

func start_hunt():
	hunt_timer_modifier = 1.0
	can_fakeout = true
	show_self()
	player.afraid = true
	lit_up = false
	hunting = true
	
	
	var modes : Array[HUNT_TYPES] = [HUNT_TYPES.Slow,HUNT_TYPES.Fast,HUNT_TYPES.Stalk,HUNT_TYPES.Silent]
	#modes.erase(previous_hunt_type)
	for i in previous_hunt_types:
		modes.erase(i)
	hunt_type = modes.pick_random()
	
	if first_hunt:
		first_hunt = false
		hunt_type = HUNT_TYPES.Slow
	
	previous_hunt_types.append(hunt_type)
	if previous_hunt_types.size() > 2:
		previous_hunt_types.remove_at(0)
	
	self.global_position = hunt_positions.pick_random().global_position
	
	if final_hunt:
		hunt_type = HUNT_TYPES.End
		self.global_position = hunt_positions[2].global_position
	
	match hunt_type:
		HUNT_TYPES.Fast:
			hunt_power = 1.2
			scream_audio.play()
			var t := create_tween()
			scream_audio.max_distance = 6
			t.tween_property(scream_audio,"max_distance",15,2.0)
		HUNT_TYPES.Slow:
			hunt_power = 4.0
			scream_audio.play()
			var t := create_tween()
			scream_audio.max_distance = 4
			t.tween_property(scream_audio,"max_distance",9,10.0)
			
		HUNT_TYPES.Stalk:
			stalk_time = 0
			hunt_power = 0.285
			scream_audio.play()
			var t := create_tween()
			scream_audio.max_distance = 1
			t.tween_property(scream_audio,"max_distance",25,10.0)
		HUNT_TYPES.Silent:
			hunt_power = 2.0
			stalk_time = 0.0
			set_sounds_paused(true)
			sprite.modulate.v = 0.0
			await get_tree().create_timer(5.0,false).timeout
			player.show_red_vignette(6.0)
		HUNT_TYPES.End:
			hunt_power = 99999
			stalk_time = 0.0
			#%Scream2.max_distance = 30
			%ScreamFake.max_distance = 30
			set_sounds_paused(false)
			scream_audio.max_distance = 20
			player.show_red_vignette(5.0)
			sprite.modulate.v = 1.0
			kill_area.monitoring = false
			kill_area.monitorable = false

func reset_hunt_timer():
	hunt_timer = randf_range(min_hunt_time,max_hunt_time)
	#hunt_timer = 5 #debug

func _gravity(delta: float) -> Vector3:
	var grav_vel : Vector3
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - 9.8, 0), 9.8 * delta)
	return grav_vel

func get_speed():
	pass

func reset():
	active = false
	enraged = false
	hunting = false
	stalk_time = 0.0
	reset_hunt_timer()
	set_areas_monitor(false)
	hide_self()

#temporarily
func go_away():
	lit_up = false
	enraged = false
	hunting = false
	player.flashlight_flickering = false
	player.pop_black_screen()
	set_areas_monitor(false)
	await get_tree().create_timer(0.2,false).timeout
	player.set_red_vignette_strength(0.0)
	%Scream2.stop()
	hide_self()

func show_self():
	sprite.modulate.v = 1.0
	set_areas_monitor(true)
	set_sounds_paused(false)
	self.show()

func hide_self():
	player.hide_red_vignette(0.1)
	sprite.modulate.v = 1.0
	set_areas_monitor(false)
	set_sounds_paused(true)
	self.hide()

func set_sounds_paused(paused : bool):
	for s in sounds:
		if paused:
			s.stop()
		else:
			s.play()

func set_areas_monitor(monitor : bool):
	for a in areas:
		a.set_deferred("monitorable",monitor)
		a.set_deferred("monitoring",monitor)

func kill_player(body : Node3D):
	if not body is Player:
		print(body)
		return
	
	if final_hunt:
		if not hand_shown:
			show_hand()
		return
	
	active = false
	hunting = false ##i am a bad programmer
	player.call_deferred("disable_flashlight",false)
	print("just killed le player!")
	set_areas_monitor(false)
	hide_self()
	%Shriek.play()
	player.return_kill()

func _handle_fakeout_timer(delta : float):
	if not can_fakeout: return
	
	if hunting: return
	
	if fakeout_timer > 0:
		fakeout_timer -= delta * 1.2
	else:
		fakeout_timer = randf_range(40,70)
		play_fakeout_sound()
		decrease_hunt_timer(10.0)

func play_fakeout_sound():
	self.global_position = hunt_positions.pick_random().global_position
	var r := randi_range(0,1)
	if r > 0:
		%Snap.play()
	else:
		%ScreamFake2.play()
		await get_tree().create_timer(1.5,false).timeout
		%ScreamFake2.stop()

func increase_timer_modifier(amount : float = 0.2):
	hunt_timer_modifier += amount
	if hunt_timer > 15.0:
		hunt_timer -= 10

func decrease_hunt_timer(amount : float = 10.0):
	if hunt_timer > 15.0:
		hunt_timer -= amount

func show_hand():
	Global.purified = true
	hand_shown = true
	player.max_flashlight_power = 99999
	player.flashlight_power = 99999
	await get_tree().create_timer(2.0,false).timeout
	var t : Tween = create_tween()
	var hand := %HandCover
	var scream : AudioStreamPlayer3D = %Scream
	var scream2 : AudioStreamPlayer3D = %Scream2
	hand.show()
	hand.modulate.a = 0.0
	t.tween_property(scream,"volume_linear",0,1.5)
	t.parallel().tween_property(scream2,"volume_linear",0,1.5)
	t.parallel().tween_property(hand,"modulate:a",1.0,1.5)
	await t.finished
	begin_end.emit()
	player.hide_red_vignette(1.0)
	await get_tree().create_timer(2.0,false).timeout
	heaven_sound.play()
	heaven_sound.volume_linear = 0.0
	var t2 := create_tween()
	t2.tween_property(heaven_sound,"volume_linear",1.0,15.0)
	t2.parallel().tween_property(enviroment.environment,"fog_light_energy",16,15.0)
	await get_tree().create_timer(7.0,false).timeout
	scream.volume_linear = 5.0
	scream.max_distance = 200
	self.floor_snap_length = 0.0
	var set_velocity_high := func():
		self.velocity.y = 100
	var to_player : Vector3 = -(player.global_position - self.global_position).normalized()
	self.velocity.x = to_player.x * 40
	self.velocity.z = to_player.z * 40
	await get_tree().create_timer(1.0,false).timeout
	var t3 := create_tween()
	player.set_dialogue("[b][i]Return[/i][/b]",9999)
	t3.tween_property(enviroment.environment,"fog_depth_begin",0.0,35.0)
	t3.parallel().tween_property(heaven_sound,"pitch_scale",1.1,35.0)
	t3.parallel().tween_callback(set_velocity_high).set_delay(5.0)
	t3.parallel().tween_property(enviroment.environment,"fog_depth_end",0.001,35.0).set_delay(1.0)
	await t3.finished
	var s := func(x : float):
		player.player_paused = true
		pause_screen.can_pause = false
		AudioServer.set_bus_volume_linear(0,x)
	
	var t4 := create_tween()
	t4.tween_interval(2.0)
	t4.tween_method(s,1.0,0.0,5.0)
	t4.tween_callback(go_to_transition)

func go_to_transition():
	const  n := preload("res://scenes/3d/secret_zone_transition.tscn")
	var rect := ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	var t6 := rect.create_tween()
	rect.modulate.a = 0
	get_tree().root.add_child(rect)
	t6.tween_property(rect,"modulate:a",1.0,1.0)
	t6.tween_interval(0.25)
	t6.tween_callback(rect.free)
	get_tree().change_scene_to_packed(n)
