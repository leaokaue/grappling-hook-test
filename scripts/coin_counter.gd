extends Node2D

@onready var label := $Coins

func _ready() -> void:
	Global.update_coins.connect(update_coins) 
	update_coins()

func update_coins():
	if Global.is_in_finality:
		var text2 : String = ("  " + "%03d" % Global.end_coins)
		
		label.text = text2
		return
	
	var text : String = str(Global.coins) + " / " + str(Global.max_coins)
	
	label.text = text
