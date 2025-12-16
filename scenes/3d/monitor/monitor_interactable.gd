extends Interactable3D
class_name MonitorInteractable3D

var powered_on : bool = false

func _ready() -> void:
	self.interactable = false

func interact():
	super()
	
	print("yo!")
