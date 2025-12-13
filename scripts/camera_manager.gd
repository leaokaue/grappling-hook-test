extends Camera2D

@onready var init_zoom : Vector2 = Vector2(0.7,0.7)

var target_zoom : Vector2 = Vector2(0.7,0.7)

func _ready() -> void:
	target_zoom = zoom
	init_zoom = zoom
	Global.reset_camera_smoothing.connect(signal_reset_smoothing)
	Global.change_target_zoom.connect(set_zoom_target)
	Global.reset_zoom.connect(reset_zoom)


func _physics_process(delta: float) -> void:
	#print(target_zoom)
	
	if self.zoom != target_zoom:
		self.zoom = self.zoom.lerp(target_zoom,delta * 0.3)

func signal_reset_smoothing():
	print(get_stack())
	reset_smoothing()

func reset_zoom():
	print(get_stack())
	target_zoom = init_zoom

func set_zoom_target(target : float):
	print(get_stack())
	target_zoom = Vector2(target,target)
