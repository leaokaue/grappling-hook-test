extends Node2D
class_name TerminusCutsceneManager

@export var coin_player : AnimationPlayer

@export var camera : Camera2D

@export var hook_item : Node2D

@export var hook_sprite : Sprite2D

@export var worm_sprite : Node2D

@export var light1 : Sprite2D

@export var light2 : Sprite2D

@export var animation_player : AnimationPlayer

@export var impact : ColorRect

@export var laser_section : Node2D

@export var ost1 : AudioStreamPlayer

@export var ost2 : AudioStreamPlayer

@export var main : FinalityMain

#var player : Worm

func _ready() -> void:
	tween_hook_sprite()
	#player = Global.player
	hook_sprite.hide()
	worm_sprite.hide()

func _process(delta: float) -> void:
	rotate_hook_light(delta)

func begin_cutscene():
	Global.set_fade_screen(false)
	Global.player.can_control = false
	Global.player.linear_velocity *= 0.0
	if Global.player.current_cube:
		Global.player.current_cube.dissapear()
	
	await get_tree().create_timer(1.4,false).timeout
	Global.set_fade_screen(true)
	Global.player.ui_instance.hide_ui()
	
	
	camera.enabled = true
	camera.make_current()
	#hook_item.hide()
	hook_item.free()
	Global.player.hide()
	
	hook_sprite.show()
	worm_sprite.show()
	
	await get_tree().create_timer(1.2,false).timeout
	
	start_animation()

func start_animation():
	animation_player.play("apology")
	
	await animation_player.animation_finished
	
	end_cutscene()
	
	Global.has_grappling_hook = true
	Global.grappling_hook_returned = true
	
	set_fade_hidden()
	
	await get_tree().create_timer(1.2,false).timeout
	
	Global.player.can_control = true

func end_cutscene():
	Global.player.ui_instance.show_ui()
	Global.player.show()
	Global.player.camera.make_current()
	camera.enabled = false
	hook_sprite.hide()
	worm_sprite.hide()

func tween_hook_sprite():
	var t := create_tween()
	
	t.set_trans(Tween.TRANS_SINE)
	t.set_loops()
	t.tween_property(hook_sprite,"position:y",hook_sprite.position.y + 5,0.5)
	t.tween_property(hook_sprite,"position:y",hook_sprite.position.y - 5,0.5)

func rotate_hook_light(delta : float):
	light1.rotation_degrees += 20 * delta
	light2.rotation_degrees += -20 * delta

func set_fade_visible():
	Global.set_fade_screen(false)

func set_fade_hidden():
	Global.set_fade_screen(true)

func make_wormchelt_scream():
	Global.player.scream(0)
	worm_sprite.hide()
	await get_tree().create_timer(1.0,false).timeout
	worm_sprite.show()

var speed : float = 1.8

func give_coins():
	Global.end_coins = 20
	var t := create_tween()
	
	#var s : float = 1.0
	
	var increase_speed_scale := func():
		speed += 0.1
		t.set_speed_scale(speed)
	
	t.set_loops(20)
	t.tween_interval(0.65)
	t.tween_callback(give_coin)
	t.tween_callback(increase_speed_scale)

func give_coin():
	var c : AnimationPlayer = coin_player.duplicate(8)
	get_tree().root.add_child(c)
	c.play("new_animation")
	await c.animation_finished
	await get_tree().create_timer(0.25,false).timeout
	Global.update_coins.emit()
	c.queue_free()

func dap_up():
	impact.show()
	var s := func(x : float):
		(impact.material as ShaderMaterial).set_shader_parameter("size",x)
	var t := create_tween()
	t.tween_method(s,0.0,4.0,2.5)
	t.parallel().tween_property(camera,"zoom",Vector2(0.85,0.85),0.5)
	t.parallel().tween_property(ost1,"volume_linear",0.0,1.5)
	t.parallel().tween_callback(disable_lasers)
	t.parallel().tween_callback(main.make_background_happy.bind(0.5))

func disable_lasers():
	for n in laser_section.get_children():
		if n is TerminusLaser:
			if n.it:
				n.it.kill()
			n.dissipate_laser()
		elif n is FirewallBugSummoner:
			n.set_enabled(false)

func enable_music_2():
	ost2.play()
