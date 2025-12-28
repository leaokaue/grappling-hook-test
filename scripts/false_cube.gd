extends RigidBody2D
class_name FalseCube2D

signal dissapeared

@export var gear_sprite : Sprite2D

@export var inner_area : Area2D

@export var outer_detectors : Array[ShapeCast2D]

var life_time : float = 30.0

var dissapearing : bool = false

var t : Tween

func _ready() -> void:
	self.modulate.a = 0.0
	_handle_collision()
	animate_tween()
	t.tween_property(self,"modulate:a",1.0,0.2)
	
	%Sound.play()
	%Sound2.play()
	%Entered2.emitting = true
	%Entered.emitting = true

func _process(delta: float) -> void:
	gear_sprite.rotation_degrees += 120 * delta
	
	#if life_time: return
	
	#print(inner_area.get_overlapping_bodies().size())
	
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

func _handle_collision():
	var player_inside : bool = false
	
	await get_tree().physics_frame
	
	if inner_area.get_overlapping_bodies().size() > 0:
		player_inside = true
	
	print(player_inside)
	
	if player_inside:
		await get_tree().physics_frame
		var i : int = 0
		for o in outer_detectors:
			if o.is_colliding():
				i += 1
		
		print(i)
		
		if i >= 2:
			%CollisionShape2D.disabled = false
			return
	
	%CollisionShape2D3.disabled = false
