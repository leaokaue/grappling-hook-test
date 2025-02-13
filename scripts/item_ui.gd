extends Control

@onready var dash_bar : TextureProgressBar = %Dashbar

func _ready() -> void:
	Global.player.emit_dash_cooldown.connect(update_dash)

func _process(delta: float) -> void:
	update_bar_visibility()

func update_dash(value : float):
	dash_bar.value = value

func update_bar_visibility():
	var e := Global.EQUIPMENTS
	
	dash_bar.get_parent().hide()
	self.show()
	
	match Global.current_equipment:
		e.None:
			self.hide()
		e.DashBoots:
			dash_bar.get_parent().show()
		e.Tambaqui:
			pass
			#dash_bar.show()
		e.HoverStone:
			pass
			#dash_bar.show()
		e.Jetpack:
			pass
			#jetpack.hide()
