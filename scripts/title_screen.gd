extends Node2D

@onready var button := %Button

@onready var timer : CheckBox = %CheckBox

@onready var clear_button := %ClearSave

@onready var bar := %ProgressBar

var clear_progress : float = 0.0

var mouse_hovering : bool = false

func _ready() -> void:
	Global.load_base_vars()
	AudioServer.set_bus_volume_db(0,0)
	button.pressed.connect(play_game)
	clear_button.mouse_entered.connect(set_mouse_hover.bind(true))
	clear_button.mouse_exited.connect(set_mouse_hover.bind(false))
	timer.toggled.connect(on_timer_checked)

func on_timer_checked(pressed : bool):
	Global.timer_visible = pressed

func _process(delta: float) -> void:
	
	if mouse_hovering and clear_button.button_pressed:
		clear_progress += delta * 40
	else:
		clear_progress -= delta * 50
	
	clear_progress = clampf(clear_progress,0,100)
	
	bar.value = clear_progress
	
	if clear_progress >= 100:
		clear_progress = 0
		#clear_button.mouse_filter = clear_button.MOUSE_FILTER_IGNORE
		mouse_hovering = false
		clear_button.button_pressed = false
		#Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
		clear_save()
		#await get_tree().create_timer(0.1,false).timeout
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#clear_button.mouse_filter = clear_button.MOUSE_FILTER_STOP
	
func play_game():
	Global.load_all()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func clear_save():
	if FileAccess.file_exists("user://peculiarcoins_save.grapple"):
		Global.save_all()

func set_mouse_hover(hovering : bool):
	mouse_hovering = hovering
	print(hovering)
