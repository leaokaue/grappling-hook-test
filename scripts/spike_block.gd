extends StaticBody2D

@export var auto_rotates : bool = true

@onready var downcast : RayCast2D = %Downcast
@onready var rightcast : RayCast2D = %Rightcast 
@onready var upcast : RayCast2D = %Upcast
@onready var leftcast : RayCast2D = %Leftcast

@onready var hsprite : Node2D = %HSprite
@onready var vsprite : Node2D = %VSprite

@onready var hsprite_col : CollisionPolygon2D = %HCol
@onready var vsprite_col : CollisionPolygon2D = %Vcol

func _ready() -> void:
	#print("ready")
	
	if not auto_rotates:
		return
	else:
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().physics_frame
	
	if downcast.is_colliding():
		#print("downcast")
		vsprite.hide()
		hsprite.show()
		vsprite_col.disabled = true
	elif upcast.is_colliding():
		#print("upcast")
		vsprite.hide()
		hsprite.show()
		vsprite_col.disabled = true
		hsprite.scale *= -1
	elif rightcast.is_colliding():
		#print("rightcast")
		hsprite.hide()
		vsprite.show()
		hsprite_col.disabled = true
		vsprite.scale *= -1
	elif leftcast.is_colliding():
		#print("leftcast")
		hsprite.hide()
		vsprite.show()
		hsprite_col.disabled = true
