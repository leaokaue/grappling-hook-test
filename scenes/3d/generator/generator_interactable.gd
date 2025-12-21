extends Interactable3D
class_name GeneratorInteractable3D

@export var monitor : MonitorInteractable3D

@export var dialogue_area : DialogueArea

@export var sound : AudioStreamPlayer3D

@export var music : AudioStreamPlayer

@export var ambience : AudioStreamPlayer

@export var parent : Node3D

var shaking : bool = false

var initial_position : Vector3

func _ready() -> void:
	if parent:
		initial_position = parent.global_position
	var d := func():
		var t := create_tween()
		t.tween_property(music,"volume_db",-80,5.0)
		t.parallel().tween_property(ambience,"volume_db",-80,5.0)
	dialogue_area.dialogue_sent.connect(d)

func _physics_process(delta: float) -> void:
	#shaking = true
	if shaking and parent:
		#print("yo")
		parent.global_position = initial_position + get_random_pos()

func interact():
	super()
	
	interactable = false
	
	if monitor:
		monitor.power_on()
	
	sound.play()
	sound.volume_db = -80
	var t := create_tween()
	t.tween_property(sound,"volume_db",-15,0.4)
	
	shaking = true
	
	dialogue_area.enabled = true
	
	description = "The Terminal should be fully functional now."

func get_random_pos() -> Vector3:
	var strength : float = 0.003
	var vec := Vector3(
		randf_range(-strength,strength),
		randf_range(-strength,strength),
		randf_range(-strength,strength),
	)
	return vec
