extends CanvasLayer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		if get_tree().paused:
			get_tree().paused = false
			capture_mouse()
			%PauseUI.hide()
		else:
			release_mouse()
			get_tree().paused = true
			%PauseUI.show()

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#mouse_captured = false
