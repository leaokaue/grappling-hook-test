extends AudioStreamPlayer
class_name MusicManager

@export var spawn_track : AudioStream

@export var bog_track : AudioStream

@export var windmill_track : AudioStream

@export var spike_track : AudioStream

@export var blackhole_track : AudioStream

@export var empty_track : AudioStream

var current_track : BackgroundManager.BACKGROUNDS

var previous_track : BackgroundManager.BACKGROUNDS

var t : Tween

var track_pos_array : Array[float] = [0,0,0,0,0,0]

func _ready() -> void:
	Global.music_player = self

func change_track(track : BackgroundManager.BACKGROUNDS):
	var next_track := get_track(track)
	
	set_track_pos(stream,get_playback_position())
	
	var s := func():
		stream = next_track.stream
		play(get_track_pos(stream))
	
	#print(self)
	
	animate_tween()
	t.tween_property(self,"volume_db",-60,0.75)
	t.tween_callback(s)
	t.tween_property(self,"volume_db",next_track.max_db,0.75)
	

func get_track(track : BackgroundManager.BACKGROUNDS) -> Dictionary:
	match track:
		0:
			return {
				"stream" : spawn_track,
				"max_db" : -30
				
			}
		1:
			return {
				"stream" : bog_track,
				"max_db" : -30
			}
		2:
			return {
				"stream" : windmill_track,
				"max_db" : -25
			}
		3:
			return {
				"stream" : spike_track,
				"max_db" : -20
			}
		4:
			return {
				"stream" : blackhole_track,
				"max_db" : -20
			}
		5:
			return {
				"stream" : empty_track,
				"max_db" : -23
			}
	
	return {}

func set_track_pos(track : AudioStream,pos : float):
	match track:
		spawn_track:
			track_pos_array[0] = pos
		bog_track:
			track_pos_array[1] = pos
		windmill_track:
			track_pos_array[2] = pos
		spike_track:
			track_pos_array[3] = pos
		blackhole_track:
			track_pos_array[4] = pos
		empty_track:
			track_pos_array[5] = pos

func get_track_pos(track : AudioStream) -> float:
	match track:
		spawn_track:
			return track_pos_array[0]
		bog_track:
			return track_pos_array[1]
		windmill_track:
			return track_pos_array[2] 
		spike_track:
			return track_pos_array[3]
		blackhole_track:
			return track_pos_array[4]
	
	return 0.0

func animate_tween():
	if t:
		t.kill()
	t = create_tween()
