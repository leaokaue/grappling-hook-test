extends Node2D

var previous_platform : CoinPlatform

@export var coin_platform : CoinPlatform

@export var mplayer : AudioStreamPlayer

var plat_pos : Vector2

var has_coin_platform : bool = false

const platform := preload("res://scenes/coin_platform.tscn")

func _ready() -> void:
	coin_platform.player_sent.connect(replace_coin_platform)
	coin_platform.player_sent.connect(play_music)
	plat_pos = coin_platform.global_position

func _process(delta: float) -> void:
	pass

func play_music():
	if is_instance_valid(mplayer):
		mplayer.stop()
		mplayer.play(128.0)

func replace_coin_platform():
	await %VisibleOnScreenNotifier2D.screen_exited
	
	coin_platform.player_sent.disconnect(replace_coin_platform)
	
	var p := platform.instantiate()
	p.global_position = plat_pos
	p.player_sent.connect(replace_coin_platform)
	p.player_sent.connect(remove_previous_platform)
	previous_platform = coin_platform
	coin_platform = p
	
	get_tree().current_scene.add_child(p)

func remove_previous_platform():
	if is_instance_valid(previous_platform):
		previous_platform.queue_free()
