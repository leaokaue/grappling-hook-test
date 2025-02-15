extends ColorRect

@export_range(0.0,1.0) var effect : float = 0.0

func _ready() -> void:
	Global.set_nightmare_effect.connect(set_effect) 

func set_effect(eff : float):
	effect = eff

func _physics_process(delta: float) -> void:
	set_shaders(effect)

func set_shaders(f : float):
	var v := self
	var c := %ChromaticAberration
	
	var min_color : Vector2 = Vector2()
	
	var max_r := Vector2(5,0)
	var max_g := Vector2(0,5)
	var max_b := Vector2(-3,0)
	
	var r := max_r * f
	var g := max_g * f
	var b := max_b * f
	
	var m1 := self.material as ShaderMaterial
	var m2 := c.material as ShaderMaterial
	
	m1.set_shader_parameter("MainAlpha",f)
	m2.set_shader_parameter("r_displacement",r)
	m2.set_shader_parameter("g_displacement",g)
	m2.set_shader_parameter("b_displacement",b)
	
	
	
