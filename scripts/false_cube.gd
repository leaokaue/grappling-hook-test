extends RigidBody2D
class_name FalseCube2D

signal dissapeared

@export var gear_sprite : Sprite2D

var life_time : float = 10.0

var dissapearing : bool = false

var t : Tween

func _ready() -> void:
	self.modulate.a = 0.0
	animate_tween()
	t.tween_property(self,"modulate:a",1.0,0.2)
	%Sound.play()
	%Sound2.play()
	%Entered2.emitting = true
	%Entered.emitting = true

func _process(delta: float) -> void:
	gear_sprite.rotation_degrees += 120 * delta
	
	if life_time > 0:
		life_time -= delta
	else:
		dissapear()

func dissapear():
	if not dissapearing:
		dissapearing = true
	else:
		return
	
	animate_tween()
	
	disable_collision()
	
	dissapeared.emit()
	
	t.tween_property(self,"modulate:a",0.0,0.2)
	t.tween_callback(self.free)


func animate_tween():
	if t:
		t.kill()
	t = create_tween()

func disable_collision():
	%CollisionShape2D.set_deferred("disabled",true)
