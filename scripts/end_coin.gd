extends Node2D

@onready var sprite := $Polygon2D

@onready var area : Area2D = $Area2D

#@export var location : Waypoint.WAYPOINTS 
 
var is_collected : bool = false

func _ready() -> void:
	self.add_to_group("Coins")
	var index : int = get_parent().get_children().find(self)
	if Global.collected_end_coins.has(index):
		self.free()
	area.body_entered.connect(on_body_entered)
	tween()

func on_body_entered(body : Node2D):
	if body is Worm:
		collect()

func collect():
	if not is_collected:
		is_collected = true
		Global.end_coins += 1
		sprite.hide()
		Global.update_coins.emit()
		#$Line2D.hide()
		var index : int = get_parent().get_children().find(self)
		Global.collected_end_coins.append(index)
		$collect.emitting = true
		$bling.play()
		
		await get_tree().create_timer(3.0,false).timeout
		self.queue_free()

func tween():
	var t := create_tween()
	
	t.set_trans(Tween.TRANS_SINE)
	t.set_loops()
	t.tween_property(sprite,"position:y",5,0.5)
	t.tween_property(sprite,"position:y",-5,0.5)
