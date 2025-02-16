extends RigidBody2D

@export var sprite : Sprite2D

@export var tex_intact : Texture
@export var tex_broken : Texture
@export var tex_coin : Texture

var break_stage : int = 0

var broken : bool = false

@onready var area : Area2D = $Area2D

var is_collected : bool = false

var t : Tween

func _ready() -> void:
	self.add_to_group("Coins")
	area.body_entered.connect(area_on_body_entered)
	self.body_entered.connect(self_on_body_entered)
	Global.request_coins.connect(send_coin_type)

func send_coin_type():
	Global.send_coins.emit(1)


func area_on_body_entered(body : Node2D):
	if body is Worm:
		if not broken:
			return
		collect()

func self_on_body_entered(body : Node2D):
	if body is Worm:
		if not broken:
			if check_velocity(body):
				set_break_stage(break_stage + 1)
				if break_stage >= 2:
					knockback_body(body)

func collect():
	if not is_collected:
		is_collected = true
		Global.coins += 1
		sprite.hide()
		Global.update_coins.emit()
		#$Line2D.hide()
		$collect.emitting = true
		$bling.play()
		Global.remove_coin_from_array(self.global_position)
		
		await get_tree().create_timer(3.0,false).timeout
		self.queue_free()

func remove_self_from_coin_list():
	if Global.coin_positions.has(self.global_position):
		var i := Global.coin_positions.find(self.global_position)
		Global.coin_positions.remove_at(i)

func _process(delta: float) -> void:
	pass

func check_velocity(body : Worm):
	#print(body.linear_velocity.length())
	
	if not body.is_freefalling:
		return
	
	if body.linear_velocity.length() > 700:
		return true
	else:
		return false

#func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	##if break_stage == 2:
		##$CollisionShape2D.disabled = true

func break_coin(fully : bool):
	if fully:
		$break2.play()
		$break.emitting = true
		sprite.texture = tex_coin
		break_stage = 2
		$CollisionShape2D.set_deferred("disabled",true)
		tween()
		await get_tree().create_timer(3.5,false).timeout
		broken = true
	else:
		$hit.play()
		sprite.texture = tex_broken
		break_stage = 1

func knockback_body(body : Worm):
	var dir := Vector2.UP
	var rot := randf_range(20,60)
	
	if (body.global_position.x - self.global_position.x) > 0:
		rot *= 1
	else:
		rot *= -1
	
	#print(dir)
	#print(dir.angle())
	
	dir = dir.rotated(deg_to_rad(rot))
	body.is_freefalling = true
	body.can_control = false
	body.physics_material_override.bounce = 2.1
	#body.physics_material_override.absorbent = true
	#print(dir)
	#print(dir.angle())
	body.apply_central_impulse(dir * 15700)
	await get_tree().create_timer(3.2,false).timeout
	body.physics_material_override.bounce = 0.0
	body.can_control = true

func set_break_stage(b : int):
	if broken:
		return
	
	break_stage = b
	if b == 1:
		break_coin(false)
	elif b == 2:
		break_coin(true)

func tween():
	var t := create_tween()
	
	t.set_trans(Tween.TRANS_SINE)
	t.set_loops()
	t.tween_property(sprite,"position:y",5,0.5)
	t.tween_property(sprite,"position:y",-5,0.5)
