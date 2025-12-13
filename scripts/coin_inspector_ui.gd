extends CanvasLayer

const coin_template : PackedScene = preload("res://scenes/inspectable_coin_template.tscn")

@onready var control :  Control = %Control

@onready var coin_container : FlowContainer = %CoinContainer

@onready var on_coin_hover : AudioStreamPlayer = %OnCoinHover

@onready var on_coin_clicked : AudioStreamPlayer = %OnCoinClick

@onready var exit : Button = %Exit

@export_group("Coin Audios")

@export var peculiar_audio : AudioStream

@export var chuffed_audio : AudioStream

@export var entombed_audio : AudioStream

@export var confused_audio : AudioStream

@export var nightmare_audio : AudioStream

@export var angel_audio : AudioStream

var entered : bool = false

var exiting : bool = false

var t : Tween

func _ready() -> void:
	#for i in range(90):
		#Global.collected_coins_list.append(0)
	exit.pressed.connect(on_exit_pressed)
	fade_in()
	add_all_coins()

func add_coin_to_container(coin_type : Global.COIN_TYPES):
	var c : Button = coin_template.instantiate()
	c.coin_type = coin_type
	coin_container.add_child(c)
	
	var audios : Array = [peculiar_audio,chuffed_audio,entombed_audio,confused_audio,nightmare_audio,angel_audio]
	var audio : AudioStream = audios[coin_type] 
	
	var play_hover := func():
		if not on_coin_clicked.playing:
			on_coin_hover.play()
	
	var play_audio := func():
		on_coin_hover.stop()
		on_coin_clicked.stream = audio
		on_coin_clicked.play()
	
	c.mouse_entered.connect(play_hover)
	c.pressed.connect(play_audio)

func add_all_coins():
	for c in Global.collected_coins_list:
		add_coin_to_container(c)

func on_exit_pressed():
	fade_out()

func fade_in():
	animate_tween()
	control.modulate.a = 0.0
	t.tween_property(control,"modulate:a",1.0,0.5)
	await t.finished
	entered = true

func fade_out():
	entered = false
	exiting = true
	control.modulate.a = 1.0
	animate_tween()
	t.tween_property(control,"modulate:a",0.0,0.5)
	await t.finished
	self.queue_free()

func animate_tween():
	if t:
		t.kill()
	t = create_tween()
