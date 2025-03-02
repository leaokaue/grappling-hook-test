extends Control

@export var map : MapUI

@export var speedrun : CheckBox

@export var completion : SpinBox

@export var deaths : SpinBox

@export var notcoins : SpinBox

@export var gjumps : SpinBox

@export var hjumps : SpinBox

@export var thrown : SpinBox

@export var accuracy : SpinBox

@export var luck : SpinBox

@export var gump : SpinBox

@export var ignore_gump : CheckBox

func _ready() -> void:
	speedrun.set_pressed_no_signal(Global.timer_visible)
	deaths.value = Global.deaths
	notcoins.value = 100 - Global.coins
	completion.value = get_completion()
	gjumps.value = Global.grounded_jumps
	hjumps.value = Global.hook_jumps
	thrown.value = Global.hooks_thrown
	var hit : float = Global.hooks_hit
	var throw : float = Global.hooks_thrown
	var acc : float = (hit / throw) * 100.0
	accuracy.value = acc
	luck.value = Global.luck
	gump.value = Global.gumption
	ignore_gump.set_pressed_no_signal(Global.ignore_gumption)
	
	speedrun.toggled.connect(on_timer_pressed)
	ignore_gump.toggled.connect(on_gump_pressed)
	
	%Resume.pressed.connect(on_resume_pressed)
	%Save.pressed.connect(on_save_pressed)
	%Checkpoint.pressed.connect(on_checkpoint_pressed)
	%Menu.pressed.connect(on_menu_pressed)
	%Quit.pressed.connect(on_quit_pressed)

func get_completion() -> float:
	
	var complete := 0.0
	
	#var item_completion : float = 
	
	var coins := (60.0) * (Global.coins / 100.0)
	
	var items := (40.0) * (Global.items_collected / 15.0)
	
	complete += coins + items
	
	return complete

func _process(delta: float) -> void:
	pass

func on_resume_pressed():
	if not map.exiting:
		map.exit()

func on_save_pressed():
	Global.save_all()

func on_menu_pressed():
	Global.save_all()
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func on_quit_pressed():
	Global.save_all()
	get_tree().quit()

func on_checkpoint_pressed():
	if is_instance_valid(Global.player):
		Global.player.return_to_checkpoint(0)

func on_timer_pressed(pressed : bool):
	Global.timer_visible = pressed

func on_gump_pressed(pressed : bool):
	Global.ignore_gumption = pressed
