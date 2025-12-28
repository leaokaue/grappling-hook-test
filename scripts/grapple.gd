extends RigidBody2D
class_name GrappleHook
@warning_ignore("unused_signal")

signal hit

var player : Worm

static var grappled : bool = false

var frozen : bool = false

var locked_position : Vector2

var looks : bool = true

var grappled_body : CollisionObject2D

var body_offset : Vector2 

var cube : FalseCube2D

@onready var line_point := %LinePoint
@onready var send := %Send
@onready var hits := %Hit

func _ready() -> void:
	if is_instance_valid($Send):
		$Send.play()
	var p := func():
		print("entering tree")
	tree_entered.connect(p)
	self.modulate.a = 0.0
	if Global.grappling_hook_returned:
		%GrappleBreak3.show()
	#look_at_dir()
	self.body_shape_entered.connect(_on_body_collision)
	#self.body_entered.connect(_on_body_collision)

func _physics_process(delta: float) -> void:
	if looks:
		look_at_dir()
	modulate.a = move_toward(modulate.a,1.0,delta * 15.0)
	
	#if grappled:
		#if grappled_body is AnimatableBody2D:
			#print("going through")
		##if is_instance_valid(grappled_body):
			#self.global_position = grappled_body.global_position + body_offset
	
	#print(self.global_position)
	
	#print(freeze)
	
	#if frozen:
		###print("locking")
		##self.global_position = locked_position

func _on_body_collision(body_rid : RID,body : Node,_bsp : int,lsi : int):
	if not grappled:
		grappled = true
	else:
		return
	
	if body is TileMapLayer:
		var c := PhysicsServer2D.body_get_collision_layer(body_rid)
		if c == 9:
			player.destroy_grapple()
			#print("destroing grapple - tilemaplayer")
			return
	
	elif body is CollisionObject2D:
		grappled_body = body
		body_offset = self.global_position - body.global_position
		
		if ((body is AnimatableBody2D) or (body is StaticBody2D) or (body is FalseCube2D)):
			self.call_deferred("reparent",body)
			
			if body is FalseCube2D:
				cube = body
				if not body.dissapeared.is_connected(Global.player.destroy_grapple):
					body.dissapeared.connect(Global.player.destroy_grapple)
		
		if body.get_collision_layer_value(4):
			player.destroy_grapple()
			return
	
	if is_instance_valid($Hit):
		$Hit.play()
	
	looks = false
	frozen = true
	Global.hooks_hit += 1
	self.modulate.a = 1.0
	set_deferred("freeze",true)
	call_deferred("emit_signal","hit")


func die():
	if cube:
		if cube.dissapeared.is_connected(Global.player.destroy_grapple):
			cube.dissapeared.disconnect(Global.player.destroy_grapple)
	
	if is_instance_valid(send):
		var t := send.create_tween()
		t.tween_interval(2.0)
		t.tween_callback(send.queue_free)
		send.reparent(get_tree().current_scene)
	
	if is_instance_valid(hits):
		var t2 := hits.create_tween()
		t2.tween_interval(2.0)
		t2.tween_callback(hits.queue_free)
		hits.reparent(get_tree().current_scene)
	
	self.queue_free()

func look_at_dir():
	self.rotation = self.linear_velocity.normalized().angle()
