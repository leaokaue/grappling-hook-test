extends Control

@export var location : Waypoint.WAYPOINTS

var coins : int = 0

func _ready() -> void:
	if not Global.has_coin_tracker:
		hide()
	
	Global.send_coins.connect(set_coins) 

func set_coins(coin_type  : Waypoint.WAYPOINTS):
	
	#print(coin_type, location)
	
	if coin_type != location:
		return
	
	print(Waypoint.WAYPOINTS.keys()[location], coins)
	
	coins += 1
	
	#print(coins)
	
	$Label.text = str(coins)
	print($Label.text)
