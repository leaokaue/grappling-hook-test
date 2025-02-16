extends Node2D

@onready var sprite := $Polygon2D

@onready var area : Area2D = $Area2D

@onready var confusion := %Confusion

var is_collected : bool = false

var min_scale_collected : float = 0.0

var fake_dist : float = 100

func _ready() -> void:
	self.add_to_group("Coins")
	#print(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	Global.request_coins.connect(send_coin_type)
	area.body_entered.connect(on_body_entered)
	tween()

func send_coin_type():
	Global.send_coins.emit(3)

func _physics_process(delta: float) -> void:
	if get_length_to_player(delta) > 1000:
		return
	
	handle_confusion(delta)

func on_body_entered(body : Node2D):
	if body is Worm:
		collect()

func collect():
	if not is_collected:
		is_collected = true
		Global.coins += 1
		sprite.hide()
		Global.update_coins.emit()
		#$Line2D.hide()
		$collect.emitting = true
		$bling.play()
		Global.remove_coin_from_array(self.global_position)
		%aura.emitting = false
		%exist.stop()
		%exist2.stop()
		await get_tree().create_timer(5.0,false).timeout
		self.queue_free()

func remove_self_from_coin_list():
	if Global.coin_positions.has(self.global_position):
		var i := Global.coin_positions.find(self.global_position)
		Global.coin_positions.remove_at(i)

func tween():
	var t := create_tween()
	
	t.set_trans(Tween.TRANS_SINE)
	t.set_loops()
	t.tween_property(sprite,"position:y",5,0.5)
	t.tween_property(sprite,"position:y",-5,0.5)

func handle_confusion(delta : float):
	#var min_confusion_scale : float = 5.5
	#var max_confusion_scale : float = 25.5
	
	var min_sound_db : float = -30
	var max_sound_db : float = 8
	
	var min_pitch : float = 1.0
	var max_pitch : float = 0.65
	
	#var min_time_scale : float = 1.0
	#var max_time_scale : float = -0.11
	
	var min_frequency : float = 1
	var max_frequency : float = 1
	
	var min_ripple : int = 1
	var max_ripple : int = 1
	
	var min_music_bus_db : float =  0.0
	var max_music_bus_db : float = -40.0
	
	var l := get_length_to_player(delta)
	
	var max_player_range : float = 500
	var min_player_range : float = 10
	
	var min_force : float = 100
	var max_force : float = 1550
	
	l = clampf(l,min_player_range,max_player_range)
	
	
	var mod : float = ((l / max_player_range) -1) * -1
	
	#print(l)
	#print(mod)
	
	if is_collected:
		#min_confusion_scale = min_scale_collected
		#min_ripple = 0
		#min_frequency = 0
		pass
	
	var to := (self.global_position - Global.player.global_position).normalized()
	
	#var confusion_scale := min_confusion_scale + ((max_confusion_scale - min_confusion_scale) * mod) 
	var sound_db := min_sound_db + ((max_sound_db - min_sound_db) * mod)
	var pitch := min_pitch + ((max_pitch - min_pitch) * mod)
	#var time_scale := min_time_scale + ((max_time_scale - min_time_scale) * mod)
	var frequency := min_frequency + ((max_frequency - min_frequency) * mod)
	var force := min_force + ((max_force - min_force) * mod)
	var ripple := min_ripple + ((max_ripple - min_ripple) * mod)
	var effect := mod
	var music_db := min_music_bus_db + ((max_music_bus_db - min_music_bus_db) * mod)
	
	#%Confusion.scale = Vector2(confusion_scale,confusion_scale)
	Global.player.apply_central_force(to * -force)
	Global.set_nightmare_effect.emit(effect)
	%exist.volume_db = sound_db
	%exist2.volume_db = sound_db
	%exist2.pitch_scale = pitch
	#Engine.time_scale = time_scale
	
	print(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),music_db)
	
	var m : ShaderMaterial = %Confusion.material
	m.set_shader_parameter("frequency",frequency)
	m.set_shader_parameter("ripple_rate",ripple)
	



func get_length_to_player(delta : float) -> float:
	if not is_collected:
		var length := (self.global_position - Global.player.global_position).length()
		return length
	else:
		fake_dist += delta * 350
		return fake_dist
