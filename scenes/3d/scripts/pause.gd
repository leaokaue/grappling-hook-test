extends CanvasLayer
class_name PauseScreen3D

var can_pause : bool = true


func _input(event: InputEvent) -> void:
	if not can_pause: return
	
	if event.is_action_pressed("menu"):
		if get_tree().paused:
			get_tree().paused = false
			capture_mouse()
			%PauseUI.hide()
			%CRT.hide()
		else:
			release_mouse()
			get_tree().paused = true
			%PauseUI.show()
			%CRT.show()

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#mouse_captured = false
