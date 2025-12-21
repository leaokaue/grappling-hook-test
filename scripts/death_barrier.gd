extends Area2D
class_name DeathBarrier

@export_range(0,4) var scream_type : int = 0

@export var destroys_grapple : bool = false

func _init() -> void:
	if destroys_grapple:
		set_collision_mask_value(3,true)
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
	if destroys_grapple:
		if body is GrappleHook:
			body.player.destroy_grapple()

func return_to_checkpoint(player : Worm):
	player.return_to_checkpoint(scream_type,0.8)
