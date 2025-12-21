extends Node2D

@export var worm : Worm

@export var intro_rect : TextureRect

@export var ost : AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
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
	ost.play()
	show_map_name()

func show_map_name():
	Global.show_map_name_intro.emit("Terminus","Simulation's Edge")

func set_intro_rect_dissolve(value : float):
	(intro_rect.material as ShaderMaterial).set_shader_parameter("dissolve_value",value)
