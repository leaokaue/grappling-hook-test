extends Control

@export var color : ColorRect
@export var win : Label
@export var age : Label
@export var completion : Label
@export var time : Label
@export var input : Label

var can_exit : bool = false

func _ready() -> void:
	Global.begin_ending.connect(begin_ending)
	self.show()
	color.modulate.a = 0.0
	win.modulate.a = 0.0
	age.modulate.a = 0.0
	completion.modulate.a = 0.0
	time.modulate.a = 0.0
	input.modulate.a = 0.0 

func begin_ending():
	var t := create_tween()
	var t2 := create_tween()
	
	set_completion_text()
	set_time_text()
	
	var set_audio := func(x):
		AudioServer.set_bus_volume_db(0,x)
	
	var set_exit := func():
		can_exit = true
	
	t2.tween_method(set_audio,0,-70,20.0)
	
	t.tween_interval(14.0)
	t.tween_property(color,"modulate:a",1.0,1.0)
	t.tween_property(win,"modulate:a",1.0,1.0)
	t.tween_interval(2.0)
	#t.tween_property(win,"modulate:a",0.0,1.0)
	t.tween_property(age,"modulate:a",1.0,1.0)
	t.tween_interval(5.0)
	t.tween_property(time,"modulate:a",1.0,1.0)
	t.tween_interval(2.0)
	t.tween_property(completion,"modulate:a",1.0,1.0)
	t.tween_interval(2.0)
	t.tween_property(input,"modulate:a",1.0,1.0)
	t.tween_interval(2.0)
	t.tween_callback(set_exit)

func set_time_text():
	time.text = "Final Time : " + get_time_format(Global.time_elapsed)

func set_completion_text():
	completion.text = "Completion : " + str(get_completion()) + "%"

func get_time_format(time : float) -> String:
	# assuming t has the miliseconds measured value
	
	
	
	var t : int = (snappedf(time,0.001) * 1000)
	
	var hours : int = (t / 60 / 60 / 1000)
	var minutes : int = (t / 60 / 1000) % 60
	var seconds : int = (t / 1000) % 60
	var miliseconds : int = (t) % 1000

	var display_time : String = ("%02d" % hours) + ("h%02d" % minutes) + ("m%02d" % seconds) + ("s%03d" % miliseconds) + "ms"
	
	return display_time

func get_completion() -> float:
	
	var complete := 0.0
	
	#var item_completion : float = 
	
	var coins := (60.0) * (Global.coins / 100.0)
	
	var items := (40.0) * (Global.items_collected / 15.0)
	
	complete += coins + items
	
	return complete


func _process(delta: float) -> void:
	if can_exit:
		if Input.is_anything_pressed():
			can_exit = false
			get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
