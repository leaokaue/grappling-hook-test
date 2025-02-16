extends Control


func _ready() -> void:
	$Checkpoint.pressed.connect(on_checkpoint_pressed)

func _process(delta: float) -> void:
	pass

func on_resume_pressed():
	pass

func on_save_pressed():
	pass

func on_checkpoint_pressed():
	if is_instance_valid(Global.player):
		Global.player.return_to_checkpoint(0)
