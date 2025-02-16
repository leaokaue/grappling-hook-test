extends Node2D

@onready var sprite := $Polygon2D

@onready var area : Area2D = $Area2D

var is_collected : bool = false

func _ready() -> void:
	self.add_to_group("Coins")
	Global.request_coins.connect(send_coin_type)
	area.body_entered.connect(on_body_entered)
	tween()

func send_coin_type():
	Global.send_coins.emit(0)

func on_body_entered(body : Node2D):
	if body is Worm:
		collect()

func collect():
	if not is_collected:
		is_collected = true
		Global.coins += 1
		sprite.hide()
		Global.update_coins.emit()
		#$Line2D.hide()
		$collect.emitting = true
		$bling.play()
		$exist.emitting = false
		Global.remove_coin_from_array(self.global_position)
		await get_tree().create_timer(3.0,false).timeout
		self.queue_free()

func remove_self_from_coin_list():
	if Global.coin_positions.has(self.global_position):
		var i := Global.coin_positions.find(self.global_position)
		Global.coin_positions.remove_at(i)

func tween():
	var t := create_tween()
	
	t.set_trans(Tween.TRANS_SINE)
	t.set_loops()
	t.tween_property(sprite,"position:y",5,0.5)
	t.tween_property(sprite,"position:y",-5,0.5)
