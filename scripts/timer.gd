extends Node2D


@export var label : Label

func _ready() -> void:
	pass



func _process(delta: float) -> void:
	if Global.timer_visible:
		self.show()
	else:
		self.hide()
	
	label.text = get_time_format(Global.time_elapsed)

func get_time_format(time : float) -> String:
	# assuming t has the miliseconds measured value
	
	
	
	var t : int = (snappedf(time,0.001) * 1000)
	
	var hours : int = (t / 60 / 60 / 1000)
	var minutes : int = (t / 60 / 1000) % 60
	var seconds : int = (t / 1000) % 60
	var miliseconds : int = (t) % 1000

	var display_time : String = ("%02d" % hours) + (":%02d" % minutes) + (":%02d" % seconds) + (".%03d" % miliseconds)
	
	return display_time
