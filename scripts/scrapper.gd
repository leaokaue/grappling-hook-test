extends Area2D
class_name Scrapper

@export var item_list : Array[Control]

var player_inside : bool = false

var ui_active : bool = false

var t : Tween 

func _ready() -> void:
	self.body_entered.connect(_on_player_enter)
	self.body_exited.connect(_on_player_exit)

func _on_player_enter(body : Node2D):
	if body is Worm:
		%Label.show()

func _on_player_exit(body : Node2D):
	if body is Worm:
		%Label.hide()

func _process(delta: float) -> void:
	if player_inside and not ui_active:
		if Input.is_action_just_pressed("scrap"):
			instantiate_scrapper_ui()

func animate_tween():
	if t:
		t.kill()
	t = create_tween()

func instantiate_scrapper_ui():
	pass
