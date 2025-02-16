extends AnimatableBody2D

@export var spin_speed : float = 40

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	self.rotation_degrees += spin_speed
