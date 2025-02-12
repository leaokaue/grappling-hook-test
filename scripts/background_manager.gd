extends ParallaxBackground
class_name BackgroundManager

enum BACKGROUNDS {
	Sunny,
	Rainy,
	Clouds,
	Night,
	Space
}

@onready var sunny_bg := %BgHappy

@onready var rainy_bg := %BgSad

@onready var clouds_bg := %BgWindy

@onready var night_bg := %BgDark

@onready var space_bg := %BgVOID

var current_background : BACKGROUNDS

var previous_background : BACKGROUNDS

var t : Tween

func _ready() -> void:
	Global.background = self 
	current_background = BACKGROUNDS.Sunny
	previous_background = current_background

func set_current_background(bg : BACKGROUNDS):
	#print("attempting background change")
	previous_background = current_background
	current_background = bg
	
	var p := get_background(previous_background)
	var c := get_background(current_background)
	
	if previous_background == current_background:
		return
	
	Global.set_music(bg)
	
	p.z_index = 1
	c.z_index = 0
	
	c.modulate.a = 1.0
	
	animate_tween()
	
	t.tween_property(p,"modulate:a",0.0,1.5)

func animate_tween():
	if t:
		t.kill()
	t = create_tween()

func get_background(bg : BACKGROUNDS) -> Sprite2D:
	match bg:
		0:
			return sunny_bg
		1:
			return rainy_bg
		2:
			return clouds_bg
		3:
			return night_bg
		4:
			return space_bg
	
	push_error("SOMETHING HAS GONE TERRIBLY WRONG")
	return null
