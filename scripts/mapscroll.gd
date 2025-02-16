extends Control

@onready var init_pos : Vector2 = self.global_position

var init_mouse_pos : Vector2

func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("ui_text_scroll_down"):
		pass
	if Input.is_action_just_pressed("ui_text_scroll_up"):
		pass
	
	if Input.is_action_just_pressed("grapple"):
		init_mouse_pos = get_global_mouse_position()
	
	if Input.is_action_pressed("grapple"):
		global_position = init_pos + -(init_mouse_pos - get_global_mouse_position())
	else:
		init_pos = global_position

func get_mouse_offset():
	pass
