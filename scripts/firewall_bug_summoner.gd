extends Node2D
class_name FirewallBugSummoner

@onready var particles := %Summoning

@onready var sound := %Summoned

@onready var area : Area2D = %Area2D

var enabled : bool = true

var summoned : bool = false

const firewall_bug : PackedScene = preload("res://scenes/firewall_bug.tscn")

func _ready() -> void:
	var s := func():
		summoned = false
		sound.stop()
		particles.emitting = false
	Global.clear_map.connect(s)
	area.body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	pass

func _on_body_entered(body : Node2D):
	if not body is Worm: return
	
	if not summoned:
		if (body as Worm).firewall_bug:
			(body as Worm).firewall_bug.die()
		summoned = true
		summon_firewall_bug()

func summon_firewall_bug():
	sound.play()
	particles.emitting = true
	
	var timer : SceneTreeTimer = get_tree().create_timer(3.8,false)
	
	await timer.timeout
	
	if not summoned: return
	
	var b : FirewallBug = firewall_bug.instantiate()
	
	var s := func():
		summoned = false
	
	b.died.connect(s)
	
	b.global_position = $Squares.global_position
	get_tree().root.add_child(b)
	
	%Summoned2.play()
	particles.emitting = false

func set_enabled(enable : bool):
	enabled = enable
	if enabled:
		$Squares.emitting = true
		$Squares2.emitting = true
		%CollisionShape2D.disabled = false
	else:
		$Squares2.emitting = false
		$Squares.emitting = false
		%CollisionShape2D.disabled = true
