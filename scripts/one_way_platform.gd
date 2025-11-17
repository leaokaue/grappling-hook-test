extends StaticBody2D



func _physics_process(_delta: float) -> void:
	if Global.player:
		if Global.player.global_position.y > (self.global_position.y - 28):
			$CollisionShape2D.disabled = true
		else:
			$CollisionShape2D.disabled = false
