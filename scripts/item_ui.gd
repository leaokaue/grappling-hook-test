extends Control

@onready var dash_bar : TextureProgressBar = %Dashbar

@onready var tambaqui_bar : TextureProgressBar = %TambaquiBar

func _ready() -> void:
	Global.player.emit_dash_cooldown.connect(update_dash)
	Global.player.emit_fish_cooldown.connect(update_fish)

func _process(delta: float) -> void:
	update_bar_visibility()

func update_dash(value : float):
	dash_bar.value = value

func update_fish(value : float):
	tambaqui_bar.value = value

func update_bar_visibility():
	var e := Global.EQUIPMENTS
	
	dash_bar.get_parent().hide()
	tambaqui_bar.get_parent().hide()
	self.show()
	
	match Global.current_equipment:
		e.None:
			self.hide()
		e.DashBoots:
			dash_bar.get_parent().show()
		e.Tambaqui:
			tambaqui_bar.get_parent().show()
			#dash_bar.show()
		e.HoverStone:
			pass
			#dash_bar.show()
		e.Jetpack:
			pass
			#jetpack.hide()
