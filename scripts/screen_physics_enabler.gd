@tool
extends VisibleOnScreenNotifier2D
class_name ScreenPhysicsEnabler

var collision : Node2D

var parent : Node2D

func _ready() -> void:
	get_collision()
	screen_entered.connect(on_view_enter)
	screen_exited.connect(on_view_exit)
	self.scale = Vector2(12,12)
	if Engine.is_editor_hint():
		collision.disabled = true
		collision.hide()
		self.hide()
	else:
		self.show()

func get_collision():
	var c := get_parent().get_children()
	
	parent = get_parent()
	
	for child in c:
		if child is CollisionPolygon2D:
			collision = child
		elif child is CollisionShape2D:
			collision = child

func on_view_enter():
	toggle_state(false)

func on_view_exit():
	toggle_state(true)

func toggle_state(disabled : bool):
	if not is_instance_valid(collision):
		return
	
	if disabled:
		parent.hide()
	else:
		parent.show()
	
	collision.disabled = disabled

#func _process(delta: float) -> void:
	#pass
