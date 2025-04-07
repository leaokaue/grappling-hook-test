extends Control


@export var title : Label

@export var description : Label

var previous_area_name : String = ""

func _ready() -> void:
	Global.show_map_name_intro.connect(show_text) 
	self.modulate.a = 0.0

func _process(delta: float) -> void:
	pass

func show_text(area_name : String, desc : String):
	
	if area_name == previous_area_name:
		return
	
	previous_area_name = area_name
	
	title.text = area_name
	description.text = desc
	
	var t := create_tween()
	
	t.tween_interval(2.5)
	t.tween_property(self,"modulate:a",1.0,2.0)
	t.tween_interval(2.0)
	t.tween_property(self,"modulate:a",0.0,1.0)
