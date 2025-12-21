extends ColorRect

var previously_on : bool = false

var t : Tween

func _ready() -> void:
	Global.toggle_rain.connect(toggle_rain)

func _process(delta: float) -> void:
	set_fps_label()

func toggle_rain(on : bool):
	var alpha : float = 1.0
	
	if (not on) and (not previously_on):
		return
	
	if not on:
		alpha = 0.0
		previously_on = false
	else:
		previously_on = true
	
	animate_tween()
	t.tween_property(self,"modulate:a",alpha,0.8)

func set_fps_label():
	if Global.is_in_finality:
		%Label.hide()
	else:
		%Label.show()
	var t := "FPS: "
	var fps := Engine.get_frames_per_second()
	%Label.text =  t + str(fps)

func animate_tween():
	if t:
		t.kill()
	t = create_tween()
