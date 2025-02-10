extends Node2D

@onready var sprite := $Polygon2D

@onready var area : Area2D = $Area2D

@onready var confusion := %Confusion

var is_collected : bool = false

func _ready() -> void:
	area.body_entered.connect(on_body_entered)
	tween()

func _physics_process(delta: float) -> void:
	sprite.rotation_degrees += 40 * delta
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
		
		await get_tree().create_timer(2.0,false).timeout
		self.queue_free()

func tween():
	var t := create_tween()
	
	t.set_trans(Tween.TRANS_SINE)
	t.set_loops()
	t.tween_property(sprite,"position:y",5,0.5)
	t.tween_property(sprite,"position:y",-5,0.5)

func handle_confusion(delta : float):
	var min_confusion_scale : float = 5.5
	var max_confusion_scale : float = 25.5
	
	var min_sound_db : float = -30
	var max_sound_db : float = 15
	
	var min_pitch : float = 1.0
	var max_pitch : float = 0.45
	
	var min_time_scale : float = 1.0
	var max_time_scale : float = 0.1
	
	var min_frequency : float = 10
	var max_frequency : float = 25
	
	var min_ripple : int = 5
	var max_ripple : int = 6
	
	var min_music_bus_db : float = 0.0
	var max_music_bus_db : float = -25.0
	
	var l := get_length_to_player()
	
	var max_player_range : float = 1000
	var min_player_range : float = 100
	
	l = clampf(l,min_player_range,max_player_range)
	
	var mod : float = (min_player_range / l)
	
	var confusion_scale := min_confusion_scale + ((max_confusion_scale - min_confusion_scale) * mod) 
	var sound_db := min_sound_db + ((max_sound_db - min_sound_db) * mod)
	var pitch := min_pitch + ((max_pitch - min_pitch) * mod)
	var time_scale := min_time_scale + ((max_time_scale - min_time_scale) * mod)
	var frequency := min_frequency + ((max_frequency - min_frequency) * mod)
	var ripple := min_ripple + ((max_ripple - min_ripple) * mod)
	var music_db := min_music_bus_db + ((max_music_bus_db - min_music_bus_db) * mod)
	
	%Confusion.scale = Vector2(confusion_scale,confusion_scale)
	%exist.volume_db = sound_db
	%exist.pitch_scale = pitch
	Engine.time_scale = time_scale
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),music_db)
	
	var m : ShaderMaterial = %Confusion.material
	m.set_shader_parameter("frequency",frequency)
	m.set_shader_parameter("ripple_rate",ripple)
	

func get_length_to_player() -> float:
	var length := (self.global_position - Global.player.global_position).length()
	return length
