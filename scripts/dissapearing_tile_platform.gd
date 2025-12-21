extends TileMapLayer

@export var area : Area2D

var dissapeared : bool = false

func _ready() -> void:
	if area:
		area.body_entered.connect(_on_body_entered)
	set_material_value(1.0) 

func _on_body_entered(body : Node2D):
	print(body)
	if not body is Worm: return
	
	if not Global.has_error_cube: return
	
	if not dissapeared:
		dissapeared = true
	else:
		return
	
	dissapear()

func dissapear():
	var t : Tween = create_tween()
	#t.set_trans(Tween.TRANS_EXPO)
	#t.set_ease(Tween.EASE_OUT)
	t.tween_callback(disable_collision)
	t.tween_method(set_material_value,1.0,0.0,1.2)

func set_material_value(value : float):
	(self.material as ShaderMaterial).set_shader_parameter("dissolve_value",value)

func disable_collision():
	collision_enabled = false
