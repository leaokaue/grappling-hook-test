extends Area3D
class_name Interactable3D

var interact_button : String = "[E]"

@export_multiline var description : String = ""

@export var can_see_description : bool = true

@export var interactable : bool = true

var interact_blocked : bool = false

func interact():
	if not interactable: return
	
	if interact_blocked: return

func get_description() -> String:
	var d : String = ""
	if interactable:
		d += interact_button + " "
	if can_see_description:
		d += description
	else:
		d = ""
	
	return d
