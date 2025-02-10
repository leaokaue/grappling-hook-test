extends CanvasLayer
class_name ItemUI

@onready var control : Control = %Control

@onready var item_name := %ItemName

@onready var item_desc := %ItemDesc

@onready var texture := %Item

func _ready() -> void:
	control.modulate.a = 0.0
	Global.set_player_control(false)

func _physics_process(delta: float) -> void:
	control.modulate.a = move_toward(control.modulate.a,1.0,0.6 * delta)
	
	if Input.is_action_just_pressed("grapple"):
		Global.set_player_control(true)
		self.queue_free()

func set_item_name(i_name : String):
	var c1 := "[center]"
	var c2 := "[/center]"
	var c3 := c1 + i_name + c2
	item_name.text = c3

func set_item_desc(i_desc : String):
	var c1 := "[center]"
	var c2 := "[/center]"
	var c3 := c1 + i_desc + c2
	item_desc.text = c3

func set_texture(tex : Texture):
	texture.texture = tex
