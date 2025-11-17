extends TextureProgressBar

var has_played_sound : bool = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var p := Global.player
	
	if not is_instance_valid(p):
		return
	
	if Global.has_cool_drink:
		tint_progress = Color(1.0,0.0,1.0)
	
	var c := p.current_hook_cooldown
	var m := p.max_hook_cooldown
	
	max_value = m
	
	if value < max_value:
		has_played_sound = false
	else:
		if not has_played_sound:
			has_played_sound = true
			print("yo")
			if not Global.ignore_gumption:
				$AudioStreamPlayer2D.play()
	
	value = (c - m) * -1
