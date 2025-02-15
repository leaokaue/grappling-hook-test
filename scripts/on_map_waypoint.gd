extends Control
class_name MapButton

@export var waypoint : Waypoint.WAYPOINTS

@onready var button := get_button_child()

var seen : bool = false

var unlocked : bool = false

var pressed : bool = false

func _ready() -> void:
	Global
	button.pressed.connect(_on_button_pressed)
	
	if is_area_waypoint_unlocked():
		button.show()
	else:
		button.hide()
	
	if is_area_seen():
		show()
	else:
		hide()

func _on_button_pressed():
	if pressed:
		return
	
	Global.teleport_to_waypoint.emit(waypoint)
	pressed = true

func _process(delta: float) -> void:
	if is_area_waypoint_unlocked():
		if Global.can_use_waypoints:
			button.disabled = false
		else:
			button.disabled = true

func is_area_seen() -> bool:
	if Global.seen_map[Waypoint.WAYPOINTS.keys()[waypoint]]:
		return true
	else:
		return false

func is_area_waypoint_unlocked() -> bool:
	if Global.waypoints_unlocked[Waypoint.WAYPOINTS.keys()[waypoint]]:
		return true
	else:
		return false

func get_button_child() -> Button:
	for c in get_children():
		if c is Button:
			return c
	return null

func teleport_player():
	Global.teleport_to_waypoint.emit(waypoint)
