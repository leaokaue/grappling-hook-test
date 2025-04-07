extends Texture2D
class_name ModulatedTexture2D

@export var texture : Texture

@export var modulate : Color = Color.WHITE

func _init() -> void:
	draw(get_rid(),Vector2(get_width(),get_height()),modulate,false)
