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
				body.returning = true
				%FogVolume.material.density = 0.0
				%FogVolume.show()
				var t := create_tween()
				t.set_trans(Tween.TRANS_EXPO)
				t.tween_property(%FogVolume,"material:density",10.0,1.5)
				await get_tree().create_timer(1.5,false).timeout
				body.global_position = body.initial_position
				body.camera.rotation = body.initial_rotation
				await get_tree().create_timer(1.0,false).timeout
				%FogVolume.hide()
				body.returning = false
