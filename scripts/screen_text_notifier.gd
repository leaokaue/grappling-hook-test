extends Control

@export var sample_label : Label

@export var vbox : VBoxContainer

func _ready() -> void:
	Global.create_screen_text.connect(create_label)

func create_label(text : String): 
	var l : Label = sample_label.duplicate()
	
	var t := create_tween()
	
	l.text = text
	
	l.modulate.a = 0.0
	l.show()
	
	vbox.add_child(l)
	
	t.tween_property(l,"modulate:a",1.0,0.2)
	t.tween_interval(4.0)
	t.tween_property(l,"modulate:a",0.0,0.2)
	t.tween_callback(l.queue_free)
	
