extends Control

@onready var dash_bar : TextureProgressBar = %Dashbar

func _ready() -> void:
	Global.player.emit_dash_cooldown.connect(update_dash)

func _process(delta: float) -> void:
	pass

func update_dash(value : float):
	dash_bar.value = value
