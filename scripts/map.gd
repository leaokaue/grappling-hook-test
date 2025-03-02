extends CanvasLayer
class_name MapUI

@onready var control := %Control

var open_tab : int = 0

var t : Tween

var exiting : bool = false

func _ready() -> void:
	%TabContainer.current_tab = open_tab
	Global.request_coins.emit()
	Global.player_dead.connect(emergency_leave)
	Global.clear_map.connect(empty_leave)
	Global.player.can_control = false
	control.modulate.a = 0.0
	animate_tween()
	t.tween_property(control,"modulate:a",1.0,0.5)

#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("map"):
		#exit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("map") or event.is_action_pressed("menu"):
		if not exiting:
			exit()

func animate_tween():
	if t:
		t.kill()
	t = create_tween()

func exit():
	exiting = true
	
	var c := func():
		Global.player.can_control = true
	
	animate_tween()
	t.tween_property(control,"modulate:a", 0.0,0.4)
	t.parallel().tween_callback(c).set_delay(0.25)
	t.tween_callback(self.queue_free)

func empty_leave():
	exiting = true
	
	#var c := func():
		#Global.player.can_control = true
	
	animate_tween()
	control.process_mode = Node.PROCESS_MODE_DISABLED
	t.tween_property(control,"modulate:a", 0.0,0.4)
	#t.parallel().tween_callback(c).set_delay(0.25)
	t.tween_callback(self.queue_free)

func emergency_leave():
	Global.player.can_control = true
	self.queue_free()
