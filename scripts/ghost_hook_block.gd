extends StaticBody2D

var time : float = 2.0

var dissapeared : bool = false

@onready var rect := $ColorRect

@onready var hook_area := $HookDetector

@onready var player_area := $PlayerDetector

@onready var base_color : Color = $ColorRect.color

@onready var collision := $CollisionShape2D

var t : Tween

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if is_player_inside():
		if not dissapeared:
			dissapear()
	
	if dissapeared:
		if time <= 2.0:
			time += delta
			if is_player_inside():
				#if Global.player.is_grappling:
					#Global.player.destroy_grapple()
				time = clampf(time,0.0,1.8)
		else:
			reappear()

func dissapear():
	animate_tween()
	
	if is_hook_inside():
		Global.player.destroy_grapple()
	
	time = 0
	dissapeared = true
	t.tween_callback(set_collision.bind(true))
	t.tween_property(rect,"color",Color(1.0,1.0,1.0,0.9),0.2)
	t.tween_property(rect,"color",Color(base_color.r,base_color.g,base_color.b,0.0),0.2)

func is_hook_inside():
	#print("trying to find hook")
	
	for i in hook_area.get_overlapping_bodies():
		#print(i)
		if i is GrappleHook:
			return true
	
	return false

func is_player_inside() -> bool:
	for i in player_area.get_overlapping_bodies():
		if i is Worm:
			return true
	
	return false

func reappear():
	animate_tween()
	
	time = 2.0
	dissapeared = false
	t.tween_callback(set_collision.bind(false))
	t.tween_property(rect,"color",Color(1.0,1.0,1.0,0.2),0.1)
	t.tween_property(rect,"color",base_color,0.2)

func set_collision(disabled : bool):
	collision.disabled = disabled

func animate_tween():
	if t:
		t.kill()
	t = create_tween()
