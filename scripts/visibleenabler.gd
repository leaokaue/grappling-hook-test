@tool
extends VisibleOnScreenNotifier2D
class_name VisibleEnabler

var override : bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		hide()
	else:
		show()
		if get_parent():
			#SignalBus.disable_enemies.connect(override_enemy_disable)
			self.process_mode = Node.PROCESS_MODE_ALWAYS
			screen_entered.connect(on_screen_enter)
			screen_exited.connect(on_screen_exit)

func override_enemy_disable():
	override = !override
	if override:
		get_parent().z_index -= 1
		get_parent().process_mode = Node.PROCESS_MODE_DISABLED
	else:
		get_parent().z_index += 1
		get_parent().process_mode = Node.PROCESS_MODE_INHERIT

func on_screen_enter():
	if get_parent():
		if override:
			return
		get_parent().process_mode = Node.PROCESS_MODE_INHERIT
		#get_parent().show()

func on_screen_exit():
	if get_parent():
		if override:
			return
		get_parent().process_mode = Node.PROCESS_MODE_DISABLED
		#get_parent().hide()
