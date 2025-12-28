extends CanvasLayer
class_name PlayerUI

@export var ui : Array[Control]

@export var ui_2d : Node2D

func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	pass

func hide_ui():
	for u in ui:
		u.hide()
	ui_2d.hide()

func show_ui():
	for u in ui:
		u.show()
	ui_2d.show()
