extends AnimatableBody2D
class_name CoinPlatform

signal player_sent

var target_y : float = -(210 * 56)

var sent : bool = false

func _ready() -> void:
	$Area2D.body_entered.connect(on_player_enter)

func _process(delta: float) -> void:
	pass

func on_player_enter(body : Node2D):
	if body is Worm:
		if not sent:
			if not Global.coins >= 80:
				return
			sent = true
			tween_position(body)

func tween_position(player : Worm):
	var t := create_tween()
	
	var c := func(x : bool):
		player.can_control = x
		player.linear_velocity *= 0
	
	player_sent.emit()
	
	t.tween_callback(c.bind(false))
	t.tween_property(%Glow,"modulate:a",1.0,0.7)
	t.tween_property(self,"global_position:y",global_position.y + target_y,30.0)
	t.tween_property(%Glow,"modulate:a",0.0,0.7)
	t.tween_callback(c.bind(true))
