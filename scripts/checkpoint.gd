extends Area2D
class_name Checkpoint

signal toggled(on : bool)

var active : bool = false

@export var ignore_finality : bool = false

func _ready() -> void:
	
	if Global.is_in_finality:
		var s := func(b : bool):
			%FirewallKiller.monitoring = b
		toggled.connect(s)
		(%ColorRect2.color as Color).b = 1.0
	else:
		%FirewallKiller.free()
	#self.add_to_group("Checkpoints")
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)

func on_body_entered(body : Node2D):
	if body is Worm:
		set_checkpoint(body)
		Global.can_switch_equipments = true
		var checkpoints := get_tree().get_nodes_in_group("Checkpoints")
		checkpoints.erase(self)
		for point in checkpoints:
			if point is Checkpoint:
				point.set_active(false)
		set_active(true)
		Global.save_all()
		Global.game_autosaved.emit()

func on_body_exited(body : Node2D):
	if body is Worm:
		Global.can_switch_equipments = false

func set_checkpoint(_player : Worm):
	if _player.finality_mode:
		Global.last_finality_x = self.global_position.x
		Global.last_finality_y = self.global_position.y
	Global.last_checkpoint_x = self.global_position.x
	Global.last_checkpoint_y = self.global_position.y

func set_active(act : bool):
	active = act
	
	toggled.emit(act)
	
	var obelisk := %Obelisk
	
	var particles := func(emitting : bool):
		if (not Global.is_in_finality) or (ignore_finality):
			%In.emitting = emitting
			%Ring.emitting = emitting
		else:
			%PurifiedIn.emitting = emitting
			%PurifiedRing.emitting = emitting
	
	var t := create_tween()
	
	var pos : int = -55
	
	if not active:
		pos = 0
	
	t.tween_property(obelisk,"position:y",pos,0.8)
	t.tween_callback(particles.bind(active))
