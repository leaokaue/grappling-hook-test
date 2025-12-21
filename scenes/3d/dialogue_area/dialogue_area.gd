extends Area3D
class_name DialogueArea

signal dialogue_sent

@export_multiline var dialogue : String = ""

@export var time : float = 4.0

@export var one_shot : bool = true

@export var on_exit : bool = false

@export var enabled : bool = true

var fired : bool = false

func _ready() -> void:
	if not on_exit:
		body_entered.connect(_on_body_entered)
	else:
		body_exited.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	if body is Player:
		if one_shot:
			if fired:
				return
			fired = true
		body.set_dialogue(dialogue,time)
		dialogue_sent.emit()
