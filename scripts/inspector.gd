extends Area2D
class_name CoinInspector

var inspector_ui_scene := preload("res://scenes/coin_inspector_ui.tscn")

var player_inside : bool = false

var ui_active : bool = false

var t : Tween 

var inspector_ui : Control

func _ready() -> void:
	print("inspector")
	self.body_entered.connect(_on_player_enter)
	self.body_exited.connect(_on_player_exit)

func _on_player_enter(body : Node2D):
	#print("yo")
	if body is Worm:
		%Label.show()
		player_inside = true

func _on_player_exit(body : Node2D):
	if body is Worm:
		%Label.hide()
		player_inside = false

func _process(_delta: float) -> void:
	#print(get_overlapping_bodies())
	if player_inside and not ui_active:
		if Input.is_action_just_pressed("scrap"):
			instantiate_inspector_ui()

func animate_tween():
	if t:
		t.kill()
	t = create_tween()

func instantiate_inspector_ui():
	var s := inspector_ui_scene.instantiate()
	ui_active = true
	Global.player.can_control = false
	%Label.hide()
	var f := func():
		ui_active = false
		Global.player.can_control = true
	s.tree_exited.connect(f)
	get_tree().current_scene.add_child(s)
