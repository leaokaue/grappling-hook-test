extends Camera2D

@onready var init_zoom : Vector2 = self.zoom

var target_zoom : Vector2 = init_zoom

func _ready() -> void:
	Global.reset_camera_smoothing.connect(signal_reset_smoothing)
	Global.change_target_zoom.connect(set_zoom_target)
	Global.reset_zoom.connect(reset_zoom)


func _physics_process(delta: float) -> void:
	if self.zoom != target_zoom:
		self.zoom = self.zoom.lerp(target_zoom,delta * 0.3)

func signal_reset_smoothing():
	reset_smoothing()

func reset_zoom():
	target_zoom = init_zoom

func set_zoom_target(target : float):
	target_zoom = Vector2(target,target)
