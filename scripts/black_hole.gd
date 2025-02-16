extends Node2D

@onready var area : Area2D = %Area2D

func _ready() -> void:
	area.body_entered.connect(on_body_entered)
	area.body_exited.connect(on_body_exited)

func _process(delta: float) -> void:
	pass

func on_body_entered(body : Node2D):
	if body is Worm:
		print("body entered")
		body.is_freefalling = true
		body.force_freefall = true

func on_body_exited(body : Node2D):
	if body is Worm:
		print("body entered")
		body.is_freefalling = false
		body.force_freefall = false
