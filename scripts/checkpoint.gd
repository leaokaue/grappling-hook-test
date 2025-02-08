extends Area2D
class_name Checkpoint

var active : bool = false

func _ready() -> void:
	#self.add_to_group("Checkpoints")
	body_entered.connect(on_body_entered)

func on_body_entered(body : Node2D):
	if body is Worm:
		set_checkpoint(body)
		var checkpoints := get_tree().get_nodes_in_group("Checkpoints")
		checkpoints.erase(self)
		for point in checkpoints:
			if point is Checkpoint:
				point.set_active(false)
		set_active(true)

func set_checkpoint(player : Worm):
	player.last_checkpoint = self.global_position

func set_active(active : bool):
	active = active
	
	var obelisk := %Obelisk
	
	var particles := func(emitting : bool):
		%In.emitting = emitting
		%Ring.emitting = emitting
	
	var t := create_tween()
	
	var pos : int = -55
	
	if not active:
		pos = 0
	
	t.tween_property(obelisk,"position:y",pos,0.8)
	t.tween_callback(particles.bind(active))
