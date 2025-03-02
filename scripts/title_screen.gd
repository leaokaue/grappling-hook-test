extends Node2D

@onready var button := %Button

@onready var timer : CheckBox = %CheckBox

func _ready() -> void:
	Global.load_base_vars()
	button.pressed.connect(play_game)
	timer.toggled.connect(on_timer_checked)

func on_timer_checked(pressed : bool):
	Global.timer_visible = pressed

func play_game():
	Global.load_all()
	get_tree().change_scene_to_file("res://scenes/main.tscn")
