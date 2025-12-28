extends Area2D
class_name AudioFadeArea

signal entered

@export var audio : AudioStreamPlayer

@export var duration : float = 5.0

var faded : bool = false

func _ready() -> void:
	set_collision_mask_value(1,false)
	set_collision_mask_value(2,true)
	self.body_entered.connect(_on_body_entered)


func _on_body_entered(body : Node2D):
	if body is Worm:
		if not faded:
			entered.emit()
			faded = true
			fade_music()

func fade_music():
	if audio:
		var t := create_tween()
		t.tween_property(audio,"volume_linear",0.0,5.0)
