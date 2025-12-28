extends Area2D

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body : Node2D):
	if body is FirewallBug:
		body.die()
		var pos := (body.global_position - self.global_position)
		zap(pos)

func zap(pos : Vector2):
	var t : Tween = create_tween()
	
	$AudioStreamPlayer2D.play()
	%Line.set_point_position(1,pos)
	
	t.set_loops(40)
	t.tween_callback(%Line.show)
	t.tween_interval(0.01)
	t.tween_callback(%Line.hide)
	t.tween_interval(0.01)
