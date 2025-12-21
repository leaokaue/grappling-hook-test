extends Interactable3D
class_name MonitorInteractable3D

@export var noise_audio : AudioStreamPlayer3D

@export var noise_monitor : Node3D

@export var game_monitor : Node3D

@export var light : SpotLight3D

@export var player : Player

@export var nightmare_coin : NightmareCoinHunter

#@export var worm : Worm

var powered_on : bool = false

var being_used : bool = false

func _ready() -> void:
	noise_monitor.show()
	Global.reset_glitched.connect(reset)
	self.interactable = false
	power_on()

func _physics_process(_delta: float) -> void:
	if not being_used:
		Global.toggle_worm_control.emit(false)

func interact():
	super()
	
	if not powered_on:
		return
	
	if not being_used:
		being_used = true
		self.description = "Leave Terminal"
		nightmare_coin.active = true
		use_terminal()
	else:
		being_used = false
		nightmare_coin.active = false
		self.description = "Use Terminal"
		leave_terminal()

func use_terminal():
	player.set_camera_fov(70)
	player.player_paused = true
	Global.toggle_worm_control.emit(true)

func leave_terminal():
	player.set_camera_fov()
	player.player_paused = false
	Global.toggle_worm_control.emit(false)

func power_on():
	powered_on = true
	
	if noise_audio:
		noise_audio.stop()
	
	if noise_monitor:
		noise_monitor.hide()
	
	light.light_energy = 0.5
	light.light_volumetric_fog_energy = 1.0
	
	game_monitor.show()
	
	self.interactable = true
	
	self.description = "Use Terminal"

func reset():
	leave_terminal()
