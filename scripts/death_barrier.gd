extends Area2D
class_name DeathBarrier

@export_range(0,3) var scream_type : int = 0


func _ready() -> void:
	body_entered.connect(on_body_entered)

func on_body_entered(body : Node2D):
	if body is Worm:
		return_to_checkpoint(body)
		body.destroy_grapple()

func return_to_checkpoint(player : Worm):
	player.return_to_checkpoint(scream_type,0.8)
