extends Area3D

@export var edge : bool = false

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body : Node3D):
	if body is Player:
		if not edge:
			print("body was player!")
			body.global_position = body.initial_position
			body.global_position.y += 400
		else:
			if not body.returning: 
				body.return_to_spawn()
