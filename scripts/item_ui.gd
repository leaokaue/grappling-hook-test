extends Control

@onready var dash_bar : TextureProgressBar = %Dashbar

@onready var tambaqui_bar : TextureProgressBar = %TambaquiBar

@onready var hover_bar : TextureProgressBar = %HoverBar

@onready var jetpack_bar : TextureProgressBar = %JetpackBar

func _ready() -> void:
	Global.player.emit_dash_cooldown.connect(update_dash)
	Global.player.emit_fish_cooldown.connect(update_fish)
	Global.player.emit_hover_cooldown.connect(update_hover)
	Global.player.emit_jetpack_cooldown.connect(update_jetpack)

func _process(delta: float) -> void:
	update_bar_visibility()

func update_jetpack(value : float):
	jetpack_bar.value = value

func update_hover(value : float):
	hover_bar.value = value

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
			hover_bar.get_parent().show()
			#dash_bar.show()
		e.Jetpack:
			jetpack_bar.get_parent().show()
			#jetpack.hide()
