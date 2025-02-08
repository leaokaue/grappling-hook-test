extends Node

signal update_coins

signal fade_animation_finished

var coins : int = 0

const max_coins : int = 100

var has_coin_compass : bool = false

var has_chuffed_coin : bool = false

var has_lag_coin : bool = false

var has_jetpack : bool = false

var player : Worm

var t : Tween

func _process(delta: float) -> void:
	pass

func set_fade_screen(fade : bool):
	var s : ColorRect = get_tree().get_first_node_in_group("BlackScreen")
	animate_tween()
	
	var e := func():
		fade_animation_finished.emit()
	
	var start_a : float = 0.0
	var end_a : float = 1.0
	
	if fade:
		start_a = 1.0
		end_a = 0.0
	
	s.modulate.a = start_a
	
	t.set_trans(Tween.TRANS_SINE)
	t.tween_property(s,"modulate:a",end_a,0.4)
	t.tween_callback(e)


func animate_tween():
	if t:
		t.kill()
	t = create_tween()
