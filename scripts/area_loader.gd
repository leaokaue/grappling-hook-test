extends Area2D

@export var area : Node2D

func _ready() -> void:
	set_collision_mask_value(2,true)
	
	self.body_entered.connect(on_player_enter)
	self.body_exited.connect(on_player_exit)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	check_player()

func check_player():
	
	var player_in : bool = false
	
	for a in get_overlapping_bodies():
		#print(a)
		if a is Worm:
			print("player in")
			player_in = true
	
	if player_in:
		#if not tilemap.collision_enabled:
		if area.process_mode != PROCESS_MODE_INHERIT:
			enable_area()
			print("enabling area")
	else:
		#if tilemap.collision_enabled:
		if area.process_mode != PROCESS_MODE_DISABLED:
			print("disabling area")
			self.disable_area()

func on_player_enter(body : Node2D):
	if area.process_mode != PROCESS_MODE_INHERIT:
		if body is Worm:
			self.enable_area()

func on_player_exit(body : Node2D):
	if area.process_mode != PROCESS_MODE_DISABLED:
		if body is Worm:
			self.disable_area()

func enable_area():
	#print("enabled area ",tilemap.name)
	#self.tilemap.collision_enabled = true
	area.process_mode = Node.PROCESS_MODE_INHERIT

func disable_area():
	#print("disabled area ",tilemap.name)
	#tilemap.collision_enabled = false
	area.process_mode = Node.PROCESS_MODE_DISABLED
