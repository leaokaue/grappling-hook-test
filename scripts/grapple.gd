extends RigidBody2D
class_name GrappleHook

signal hit

var player : Worm

static var grappled : bool = false

var frozen : bool = false

var locked_position : Vector2

var looks : bool = true

var grappled_body : CollisionObject2D

var body_offset : Vector2 

@onready var send := %Send
@onready var hits := %Hit

func _ready() -> void:
	$Send.play()
	#look_at_dir()
	self.body_shape_entered.connect(_on_body_collision)
	#self.body_entered.connect(_on_body_collision)

func _physics_process(delta: float) -> void:
	if looks:
		look_at_dir()
	
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
		
		
		if body is TileMapLayer:
			var c := PhysicsServer2D.body_get_collision_layer(body_rid)
			if c == 9:
				player.destroy_grapple()
				#print("destroing grapple - tilemaplayer")
				return
		
		elif body is CollisionObject2D:
			
			grappled_body = body
			#print(grappled_body)
			body_offset = self.global_position - body.global_position
			
			if body is AnimatableBody2D or body is StaticBody2D:
				#self.reparent(body)
				
				var reparent_node := body
				
				#if body is StaticBody2D:
					#while reparent_node is not AnimatableBody2D:
						#reparent_node = reparent_node.get_parent()
				#
				self.call_deferred("reparent",body)
				await get_tree().physics_frame
				await get_tree().physics_frame
				await get_tree().physics_frame
				
				var i : GrappleHook
				
				for s in body.get_children():
					if s is GrappleHook:
						i = s
						#print(i)
						if is_instance_valid(Global.player.global_joint):
							Global.player.global_joint.node_a = i.get_path()
			
			
			
			if body.get_collision_layer_value(4):
				#print("dying")
				player.destroy_grapple()
				return
		
		$Hit.play()
		looks = false
		#self.global_position = locked_position
		frozen = true
		set_deferred("freeze",true)
		#self.lock_rotation = true
		hit.emit()
		#self.call_deferred("reparent",body)

#func _on_body_collision(body : Node2D):
	##print("BALLS")
	#if not grappled:
		#
		##print(body)
		#
		#if body is CollisionObject2D:
			#
			#grappled_body = body
			#body_offset = self.global_position - body.global_position
			#
			#if body.get_collision_layer_value(4):
				##print("dying")
				#player.destroy_grapple()
				#return
		#
		#$Hit.play()
		#looks = false
		##self.global_position = locked_position
		#grappled = true
		#frozen = true
		#set_deferred("freeze",true)
		##self.lock_rotation = true
		#hit.emit()
		##self.call_deferred("reparent",body)

func die():
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
