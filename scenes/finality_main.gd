extends Node2D
class_name FinalityMain

@export var worm : Worm

@export var intro_rect : TextureRect

@export var music_fade_handler : AudioFadeArea 

@export var ost : AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.timer_visible = false
	
	var s := func():
		Global.terminus_can_switch_equipment = true
	
	music_fade_handler.entered.connect(s)
	
	handle_on_save_properties()
	remove_all_items()
	set_intro_rect_dissolve(1.0)
	give_player_control()
	hide_intro_rect()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func give_player_control():
	#await get_tree().create_timer(3.0,false).timeout
	worm.can_control = false

func hide_intro_rect():
	var t : Tween = create_tween()
	t.tween_method(set_intro_rect_dissolve,1.0,0.0,3.0)
	await t.finished
	worm.can_control = true
	play_ost()
	show_map_name()
	Global.terminus_visited = true

func show_map_name():
	if not Global.terminus_visited:
		Global.terminus_visited = true
		Global.show_map_name_intro.emit("Terminus","Simulation's Edge")
	else:
		Global.show_map_name_intro_small.emit("Terminus","Simulation's Edge")

func set_intro_rect_dissolve(value : float):
	(intro_rect.material as ShaderMaterial).set_shader_parameter("dissolve_value",value)

func make_background_happy(time : float = 0.5):
	var hex := Color("4a41d8")
	var t := create_tween()
	t.tween_property(%Screen,"modulate",hex,time)

func play_ost():
	if not Global.grappling_hook_returned:
		%OST1.play()
	else:
		%OST2.play(120)

func remove_all_items():
	for i in range(Item.ITEMS.size()):
		#print(i as Item.ITEMS)
		Global.scrap_item(i,false)
		Global.unlock_item(i,false)

func handle_on_save_properties():
	if Global.grappling_hook_returned:
		make_background_happy()
