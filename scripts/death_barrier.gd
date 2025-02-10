extends Area2D
class_name DeathBarrier

func _ready() -> void:
	body_entered.connect(on_body_entered)

func on_body_entered(body : Node2D):
	if body is Worm:
		return_to_checkpoint(body)

func return_to_checkpoint(player : Worm):
	player.return_to_checkpoint()
