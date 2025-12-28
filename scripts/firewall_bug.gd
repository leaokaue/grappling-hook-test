extends CharacterBody2D
class_name FirewallBug

signal died

@onready var spin_holder : Node2D = %Spin

@export var sprites : Array[Sprite2D]

var player : Worm

var dead : bool = false

func _ready() -> void:
	player = Global.player
	player.firewall_bug = self
	Global.clear_map.connect(die)
	self.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(self,"modulate:a",1.0,0.5)

func _physics_process(delta: float) -> void:
	if player:
		var speed : float = 125
		
		var to_player : Vector2 = (player.global_position - self.global_position)
		
		if to_player.length() > 800:
			speed = 300
		
		
		self.velocity = ((to_player).normalized()) * speed
		spin_holder.rotation_degrees += delta * (speed * 2.0)
		
		if dead:
			self.velocity *= 0
		
		for s in sprites:
			s.rotation_degrees += delta * 120
		
		%Sprite2D.rotation_degrees += delta * 80
		%Sprite2D2.rotation_degrees += delta * -60
		%Sprite2D3.rotation_degrees += delta * 120
		
	
	move_and_slide()

func die():
	var t := create_tween()
	dead = true
	died.emit()
	%CollisionShape2D.set_deferred("disabled",true)
	t.tween_property(self,"modulate:a",0.0,0.5)
	t.tween_callback(self.queue_free)
