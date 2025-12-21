extends Node2D

@onready var sprite := $Polygon2D

@onready var area : Area2D = $Area2D

@export var location : Waypoint.WAYPOINTS 
 
var is_collected : bool = false

func _ready() -> void:
	#self.add_to_group("Coins")
	#Global.request_coins.connect(send_coin_type)
	Global.reset_glitched.connect(reset_coin)
	area.body_entered.connect(on_body_entered)
	tween()

#func send_coin_type():
	#if not is_collected:
		#Global.send_coins.emit(self.location)

func on_body_entered(body : Node2D):
	if body is Worm:
		collect()

func collect():
	if not is_collected:
		is_collected = true
		Global.glitch_coins_collected += 1
		sprite.hide()
		Global.update_coins.emit()
		$collect.emitting = true
		$bling.play()

func reset_coin():
	is_collected = false
	sprite.show()
	$collect.emitting = false

func tween():
	var t := create_tween()
	
	t.set_trans(Tween.TRANS_SINE)
	t.set_loops()
	t.tween_property(sprite,"position:y",5,0.5)
	t.tween_property(sprite,"position:y",-5,0.5)
