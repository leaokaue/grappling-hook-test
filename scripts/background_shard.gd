@tool
extends PointLight2D


func _ready() -> void:
	if Engine.is_editor_hint():
		var s := Sprite2D.new()
		s.texture = self.texture
		s.modulate.a = 0.2
		self.add_child(s)
		return
	
	var t := create_tween()
	
	t.set_trans(Tween.TRANS_SINE)
	t.set_loops()
	t.tween_property(self,"position:y",self.position.y + 10,2.5)
	t.tween_property(self,"position:y",self.position.y + -10,2.5)
