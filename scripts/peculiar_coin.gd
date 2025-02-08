extends Node2D

@onready var sprite := $Polygon2D

@onready var area : Area2D = $Area2D

var is_collected : bool = false

func _ready() -> void:
	area.body_entered.connect(on_body_entered)
	tween()

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
		
		await get_tree().create_timer(2.0,false).timeout
		self.queue_free()

func tween():
	var t := create_tween()
	
	t.set_trans(Tween.TRANS_SINE)
	t.set_loops()
	t.tween_property(sprite,"position:y",5,0.5)
	t.tween_property(sprite,"position:y",-5,0.5)
