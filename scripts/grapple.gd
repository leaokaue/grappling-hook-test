extends RigidBody2D
class_name GrappleHook

signal hit

var grappled : bool = false

var frozen : bool = false

var locked_position : Vector2

var looks : bool = true

var grappled_body : CollisionObject2D

var body_offset : Vector2 

func _ready() -> void:
	$Send.play()
	self.body_entered.connect(_on_body_collision)

func _physics_process(delta: float) -> void:
	if looks:
		look_at_dir()
	
	if grappled:
		#if grappled_body is AnimatableBody2D:
		self.global_position = grappled_body.global_position + body_offset
	
	#print(self.global_position)
	
	#print(freeze)
	
	#if frozen:
		###print("locking")
		##self.global_position = locked_position

func _on_body_collision(body : Node2D):
	print("BALLS")
	if not grappled:
		$Hit.play()
		looks = false
		#self.global_position = locked_position
		grappled = true
		frozen = true
		set_deferred("freeze",true)
		#self.lock_rotation = true
		hit.emit()
		grappled_body = body
		body_offset = self.global_position - body.global_position
		#self.call_deferred("reparent",body)

func die():
	self.queue_free()

func look_at_dir():
	self.rotation = self.linear_velocity.normalized().angle()
