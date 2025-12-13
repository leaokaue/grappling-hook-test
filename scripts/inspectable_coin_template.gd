extends Button

var coin_type : Global.COIN_TYPES = Global.COIN_TYPES.Peculiar

@onready var tex : TextureRect = %TextureRect

@export var peculiar_texture : Texture

@export var chuffed_texture : Texture

@export var entombed_texture : Texture

@export var confused_texture : Texture

@export var nightmare_texture : Texture

@export var angel_coin : Texture

func _ready() -> void:
	match_coin_type()
	var h := func():
		tex.modulate.v = 0.9
	
	var l := func():
		tex.modulate.v = 1.0
	
	var c := func():
		tex.modulate.v = 0.7
	
	mouse_entered.connect(h)
	mouse_exited.connect(l)
	button_down.connect(c)
	button_up.connect(h)

func match_coin_type():
	var c := Global.COIN_TYPES
	match coin_type:
		c.Peculiar:
			tex.texture = peculiar_texture
		c.Chuffed:
			tex.texture = chuffed_texture
		c.Entombed:
			tex.texture = entombed_texture
		c.Confused:
			tex.texture = confused_texture
		c.Nightmare:
			tex.texture = nightmare_texture
		c.Angel:
			tex.texture = angel_coin
