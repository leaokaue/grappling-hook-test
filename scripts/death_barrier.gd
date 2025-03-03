extends Area2D
class_name DeathBarrier

@export_range(0,4) var scream_type : int = 0

func _init() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func _ready() -> void:
	body_entered.connect(on_body_entered)

func on_body_entered(body : Node2D):
	if body is Worm:
		if body.is_teleporting:
			print("body is teleporting, not killing")
			return
		return_to_checkpoint(body)
		body.destroy_grapple()

func return_to_checkpoint(player : Worm):
	player.return_to_checkpoint(scream_type,0.8)
