extends Node2D

@onready var button := $Node2D/Button

func _ready() -> void:
	button.pressed.connect(play_game)

func _process(delta: float) -> void:
	pass

func play_game():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
