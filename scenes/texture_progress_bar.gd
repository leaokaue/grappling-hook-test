extends TextureProgressBar

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var p := Global.player
	
	if not is_instance_valid(p):
		return
	
	var c := p.current_hook_cooldown
	var m := p.max_hook_cooldown
	
	max_value = m
	
	value = (c - m) * -1
