extends StaticBody2D
class_name CoinDoorBlock

@export var coin_requirement : int = 45

var opened : bool = false

func _ready() -> void:
	$PlayerDetector.body_entered.connect(on_player_enter)

func on_player_enter(body : Node2D):
	if body is Worm:
		if not opened:
			check_door()

func check_door():
	if Global.coins >= coin_requirement:
		dissapear()
		for a in $PlayerDetector.get_overlapping_bodies():
			if (a is CoinDoorBlock):
				if not a.opened:
					a.check_door()

func dissapear():
	if opened:
		return
	opened = true
	$collect.emitting = true
	await get_tree().create_timer(1.3,false).timeout
	
	var t := create_tween()
	t.tween_property($ColorRect,"modulate:a",0.0,0.7)
	$CollisionShape2D.disabled = true
	await get_tree().create_timer(5.0,false).timeout
	self.queue_free()
