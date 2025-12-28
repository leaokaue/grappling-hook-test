extends Node2D

@export var paths : Array[PathFollow2D]
@export var cutscene_player : TerminusCutsceneManager

@onready var sprite : Sprite2D = %Item2

@onready var light : Sprite2D = %Light

@onready var light2 : Sprite2D = %Light2

@onready var area : Area2D = %DetectArea

var current_path : int = -1

var speed : float = 150

var flipped : bool = false

func _ready() -> void:
	if Global.grappling_hook_returned:
		self.queue_free()
	
	current_path = Global.grappling_hook_run_stage
	if current_path >= 0:
		paths[current_path].progress_ratio = 1.0
	area.body_entered.connect(_on_body_entered)
	tween_sprite_position()
	for path in paths:
		path.loop = false

func _physics_process(delta: float) -> void:
	light.rotation_degrees += 20 * delta
	light2.rotation_degrees += -20 * delta
	
	var dir : float = sign(self.global_position.x - Global.player.global_position.x)
	
	if dir > 0:
		sprite.flip_h = flipped
	else:
		sprite.flip_h = !flipped
	
	if current_path >= 0:
		#speed = move_toward(speed,600,delta * 100 + (speed * 0.1))
		speed = lerpf(speed,1200,2.0 * delta)
		self.global_position = paths[current_path].global_position
		paths[current_path].progress += speed * delta

func tween_sprite_position():
	var t := create_tween()
	
	t.set_trans(Tween.TRANS_SINE)
	t.set_loops()
	t.tween_property(sprite,"position:y",sprite.position.y + 5,0.5)
	t.tween_property(sprite,"position:y",sprite.position.y - 5,0.5)

func _on_body_entered(body : Node2D):
	if not body is Worm: return
	
	if current_path > 0:
		if not paths[current_path].progress_ratio == 1.0:
			return
	
	if not current_path >= (paths.size() - 1):
		alerted()
	else:
		begin_cutscene()

func alerted():
	var label := %Label
	var gasp := %gasp
	var flip := func(x : bool):
		flipped = x
	
	label.modulate.a = 0.0
	label.position.y = -50
	
	var t : Tween = create_tween()
	t.tween_callback(flip.bind(true))
	t.tween_callback(gasp.play)
	t.tween_property(label,"modulate:a",1.0,0.5)
	t.parallel().tween_property(label,"position:y",-58,0.5)
	t.tween_property(label,"modulate:a",0.0,0.3)
	t.tween_callback(move_to_next_path)

func move_to_next_path():
	flipped = false
	speed = 150
	current_path += 1
	Global.grappling_hook_run_stage = current_path

func begin_cutscene():
	cutscene_player.begin_cutscene()
