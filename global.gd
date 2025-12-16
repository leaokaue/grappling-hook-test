extends Node

@warning_ignore("unused_signal")

signal request_coins

signal send_coins(location : Waypoint.WAYPOINTS)

signal set_nightmare_effect(effect : float)

signal update_coins

signal fade_animation_finished

signal create_screen_text(text : String)

signal show_map_name_intro(mname : String, desc : String)

signal show_map_name_intro_small(mname : String, desc : String)

signal change_target_zoom(zoom : float)

signal reset_zoom

signal reset_camera_smoothing

signal toggle_rain(on : bool)

signal teleport_to_waypoint(waypoint : int)

signal player_dead

signal clear_map

signal begin_ending 

signal game_autosaved

signal disable_music

var player : Worm

var background : BackgroundManager

var music_player : MusicManager

var t : Tween

var waypoint_position : Dictionary = {
	"Spawn" : Vector2(),
	"Bog" : Vector2(),
	"Windmill" : Vector2(),
	"Spike" : Vector2(),
	"Spike2" : Vector2(),
	"Space" : Vector2(),
	 
}

enum EQUIPMENTS {
	None,
	DashBoots,
	Tambaqui,
	HoverStone,
	Jetpack,
	ErrorCube
}

var coin_positions : PackedVector2Array

const SAVE_PATH : String = "user://peculiarcoins_save.grapple"

const BASE_SAVE_PATH : String = "user://BASECOINS_SAVE.grapple"

const max_coins : int = 100

#region Save Variables

var start_save : int = 69420

var coins : int = 0

var collected_coin_position : PackedVector2Array

var last_pos_x : float = -780

var last_pos_y : float = 448

var timer_visible : bool = false

var time_elapsed : float = 0.0

var items_collected : int = 0

var deaths : int = 0

var hook_jumps : int = 0

var hooks_thrown : int = 0

var hooks_hit : int = 0

var luck_generated : bool = false

var luck : int = 0

var gumption : int = 0

var ignore_gumption : bool = false

var has_grappling_hook : bool = true

var seen_map : Dictionary = {
	"Spawn" : false,
	"Bog" : false,
	"Windmill" : true,
	"Spike" : false,
	"Space" : false,
	"Spike2" : false,
	"Empty" : false
	 
}

var waypoints_unlocked : Dictionary = {
	"Spawn" : false,
	"Bog" : false,
	"Windmill" : true,
	"Spike" : false,
	"Space" : false,
	"Spike2" : false,
	"Empty" : false,
	 
}

var current_equipment : int = 0

var can_switch_equipments : bool = false

var can_use_waypoints : bool = false

#gives an arrow towards the closest coin
var has_coin_compass : bool = false:
	get():
		if coin_compass_scrapped:
			return false
		return has_coin_compass

#displays how many coins an area has left
var has_coin_tracker : bool = false:
	get():
		if coin_tracker_scrapped:
			return false
		return has_coin_tracker

#chuffed coin!
var has_chuffed_coin : bool = false

#allows you to dash once per jump
var has_dash_boots : bool = false:
	get():
		if dash_boots_scrapped:
			return false
		return has_dash_boots

#is a jetpack
var has_jetpack : bool = false:
	get():
		if jetpack_scrapped:
			return false
		return has_jetpack

#reduces grapple cooldown
var has_cool_drink : bool = false:
	get():
		if cool_drink_scrapped:
			return false
		return has_cool_drink

#increases grapple range
var has_rope_extension : bool = false:
	get():
		if rope_extension_scrapped:
			return false
		return has_rope_extension

#resist poison completely
var has_poison_resist : bool = false:
	get():
		if poison_resist_scrapped:
			return false
		return has_poison_resist

#increases reteacting speed
var has_rope_pulley : bool = false:
	get():
		if rope_pulley_scrapped:
			return false
		return has_rope_pulley

#increases boost from latching the grapple
var has_boost_latch : bool = false:
	get():
		if boost_latch_scrapped:
			return false
		return has_boost_latch

#increases grapple speed
var has_steroids_1 : bool = false:
	get():
		if steroids_1_scrapped:
			return false
		return has_steroids_1

#increases jump speed
var has_steroids_2 : bool = false:
	get():
		if steroids_2_scrapped:
			return false
		return has_steroids_2

#increases move speed
var has_steroids_3 : bool = false:
	get():
		if steroids_3_scrapped:
			return false
		return has_steroids_3

#lets the player hover for a bit
var has_hover_stone : bool = false:
	get():
		if hover_stone_scrapped:
			return false
		return has_hover_stone

#allows player to waypoint anywhere
var has_guiding_light : bool = false:
	get():
		if guiding_light_scrapped:
			return false
		return has_guiding_light

#water dash
var has_tambaqui : bool = false

var game_active : bool = true

var initializing_game : bool = true

var grounded_jumps : int = 0

var cancelling_jump_enabled : bool = true

var last_checkpoint_x : float = -780

var last_checkpoint_y : float = 448

var ended : bool = false

var fullscreen : bool = false

var trash_points : int = 8

var has_trash_bag : bool = false:
	get():
		if trash_bag_scrapped:
			return false
		return has_trash_bag

var trash_bag_scrapped : bool = false

var coin_compass_scrapped : bool = false

var coin_tracker_scrapped : bool = false

var dash_boots_scrapped : bool = false

var jetpack_scrapped : bool = false

var cool_drink_scrapped : bool = false

var rope_extension_scrapped : bool = false

var poison_resist_scrapped : bool = false

var rope_pulley_scrapped : bool = false

var boost_latch_scrapped : bool = false

var steroids_1_scrapped : bool = false

var steroids_2_scrapped : bool = false

var steroids_3_scrapped : bool = false

var hover_stone_scrapped : bool = false

var guiding_light_scrapped : bool = false

var tambaqui_scrapped : bool = false

var has_golden_hook : bool = false

var has_error_cube : bool = false

enum COIN_TYPES {
	Peculiar,
	Chuffed,
	Entombed,
	Confused,
	Nightmare,
	Angel,
}

var collected_coins_list : Array[COIN_TYPES] = [0,0,0,0,0,1]

#endregion

func _ready() -> void:
	save_base_vars()

#func _notification(what: int) -> void:
	#if what == NOTIFICATION_WM_CLOSE_REQUEST:
		#return

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			set_fullscreen(true)
		else:
			set_fullscreen(false)

func set_fullscreen(full : bool):
	fullscreen = full
	
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func set_fade_screen(fade : bool):
	var s : ColorRect = get_tree().get_first_node_in_group("BlackScreen")
	animate_tween()
	
	var e := func():
		fade_animation_finished.emit()
	
	var start_a : float = 0.0
	var end_a : float = 1.0
	
	if fade:
		start_a = 1.0
		end_a = 0.0
	
	s.modulate.a = start_a
	
	t.set_trans(Tween.TRANS_SINE)
	t.tween_property(s,"modulate:a",end_a,0.4)
	t.tween_callback(e)

func unlock_item(item : Item.ITEMS, unlock : bool):
	var i := Item.ITEMS
	
	match item:
		i.HookThrowBoost:
			has_steroids_1 = unlock
		i.JumpBoost:
			has_steroids_2 = unlock
		i.SpeedBoost:
			has_steroids_3 = unlock
		i.CoinCompass:
			has_coin_compass = unlock
		i.CoinTracker:
			has_coin_tracker = unlock
		i.FastTravel:
			has_guiding_light = unlock
		i.DashBoots:
			has_dash_boots = unlock
		i.JetPack:
			has_jetpack = unlock
		i.HookCooldownReducer:
			has_cool_drink = unlock
		i.GrappleRopeExtension:
			has_rope_extension = unlock
		i.RetractBoost:
			has_rope_pulley = unlock
		i.LatchJumpBoost:
			has_boost_latch = unlock
		i.HoverStone:
			has_hover_stone = unlock
		i.WaterDash:
			has_tambaqui = unlock
		i.PoisonResist:
			has_poison_resist = unlock
		i.Trash:
			has_trash_bag = unlock

func scrap_item(item : Item.ITEMS, scrap : bool):
	var i := Item.ITEMS
	
	match item:
		i.HookThrowBoost:
			has_steroids_1 = !scrap
			steroids_1_scrapped = scrap
		i.JumpBoost:
			has_steroids_2 = !scrap
			steroids_2_scrapped = scrap
		i.SpeedBoost:
			has_steroids_3 = !scrap
			steroids_3_scrapped = scrap
		i.CoinCompass:
			has_coin_compass = !scrap
			coin_compass_scrapped = scrap
		i.CoinTracker:
			has_coin_tracker = !scrap
			coin_tracker_scrapped = scrap
		i.FastTravel:
			has_guiding_light = !scrap
			guiding_light_scrapped = scrap
		i.DashBoots:
			has_dash_boots = !scrap
			dash_boots_scrapped = scrap
			if (current_equipment == 1) and scrap:
				current_equipment == 0
		i.JetPack:
			has_jetpack = !scrap
			jetpack_scrapped = scrap
			if (current_equipment == 4) and scrap:
				current_equipment == 0
		i.HookCooldownReducer:
			has_cool_drink = !scrap
			cool_drink_scrapped = scrap
		i.GrappleRopeExtension:
			has_rope_extension = !scrap
			rope_extension_scrapped = scrap
		i.RetractBoost:
			has_rope_pulley = !scrap
			rope_pulley_scrapped = scrap
		i.LatchJumpBoost:
			has_boost_latch = !scrap
			boost_latch_scrapped = scrap
		i.HoverStone:
			has_hover_stone = !scrap
			hover_stone_scrapped = scrap
			if (current_equipment == 3) and scrap:
				current_equipment == 0
		i.WaterDash:
			has_tambaqui = !scrap
			tambaqui_scrapped = scrap
			if (current_equipment == 2) and scrap:
				current_equipment == 0
		i.PoisonResist:
			has_poison_resist = !scrap
			poison_resist_scrapped = scrap
		i.Trash:
			has_trash_bag = !scrap
			trash_bag_scrapped = scrap

func set_area_seen(area : int):
	#if n'ot seen_map[Waypoint.WAYPOINTS.keys()[area]]:
		
		var seen : bool = seen_map[Waypoint.WAYPOINTS.keys()[area]]
		var shows : bool = false
		var mname : String
		var mdesc : String
		
		
		match area:
			0: #Spawn Island
				shows = true
				mname = "Spawn Island"
				mdesc = "Welcome to Aleksander Wormchelt's Quest for The Peculiar Coins"
			1: #Weeping Bogs
				shows = true
				mname = "Weeping Bogs"
				mdesc = "Land of Fungi and Acid."
			2: #Windmillian Recluse
				shows = true
				mname = "Windmillian Recluse"
				mdesc = "Enjoy the windy breeze."
			3: #Really Dangerous Spike Zone
				shows = true
				var c := (max_coins - coins)
				mname = "Dangerous Spike Zone"
				mdesc = "This Really Dangerous Spike Zone is dangerous, watch out. Don't ragequit now. %02d coins left."
				mdesc %= c
			4: #Black Hole District
				shows = true
				mname = "Black Hole District"
				mdesc = "Wormchelt’s Big Day Out With The Big Black Holes: Herald of Armageddon"
		
		seen_map[Waypoint.WAYPOINTS.keys()[area]] = true
		
		if shows:
			if not seen:
				show_map_name_intro.emit(mname,mdesc)
			else:
				show_map_name_intro_small.emit(mname,mdesc)
		
		#Spawn,
		#Bog,
		#Windmill,
		#Spike,
		#Space,
		#Empty,
		#Spike2

func add_coin_to_list(type : COIN_TYPES):
	collected_coins_list.append(type)

func set_background(bg : BackgroundManager.BACKGROUNDS):
	background.set_current_background(bg)

func set_music(track : BackgroundManager.BACKGROUNDS):
	music_player.change_track(track)

func set_player_control(can_control : bool):
	player.can_control = can_control

func animate_tween():
	if t:
		t.kill()
	t = create_tween()

func remove_coin_from_array(pos : Vector2):
	if coin_positions.has(pos):
		var i := Global.coin_positions.find(pos)
		coin_positions.remove_at(i)
		if not collected_coin_position.has(pos):
			collected_coin_position.append(pos)

func remove_collected_coins_from_scene():
	if not collected_coin_position.size() > 0:
		return
	
	for coin in get_tree().get_nodes_in_group("Coins"):
		if coin is Node2D:
			if collected_coin_position.has(coin.global_position):
				coin.queue_free()
				remove_coin_from_array(coin.global_position)

func get_coin_vec2_array():
	for coin in get_tree().get_nodes_in_group("Coins"):
		if coin is Node2D:
			#print(coin)
			if not coin_positions.has(coin.global_position):
				coin_positions.append(coin.global_position)

func save_all():
	save_self_vars()

func load_all():
	if FileAccess.file_exists(SAVE_PATH):
		load_self_vars()
	else:
		save_all()
		load_self_vars()

func save_self_vars():
	var file = FileAccess.open(SAVE_PATH,FileAccess.WRITE)
	
	var saving : bool = false
	
	for property in self.get_property_list():
		#
		#print("saving")
		#print(property.hint," ", property.type, " ", property.name, " ",property.usage)
		
		if property.usage == PROPERTY_USAGE_SCRIPT_VARIABLE:
			var var_name : String = property.name
			var sel_var = get(var_name)
			file.store_var(sel_var)
			
	file.close()

func generate_luck():
	if not luck_generated:
		luck_generated = true
		luck = randi_range(1,100)

func load_self_vars():
	
	
	var file = FileAccess.open(SAVE_PATH,FileAccess.READ)
	for property in self.get_property_list():
		if property.usage == PROPERTY_USAGE_SCRIPT_VARIABLE:
			var var_name : String = property.name
			var loaded_var = file.get_var()
			#print(property.hint," ", property.type, " ", property.name)
			#print("loaded var is ",loaded_var)
			
			if loaded_var is Array:
				var v = get(var_name)
				if v is Array:
					v.clear()
					v.append_array(loaded_var)
				#print(loaded_var.size(), " size")
			elif loaded_var is PackedVector2Array:
				var v = get(var_name)
				if v is PackedVector2Array:
					v.clear()
					v.append_array(loaded_var)
				#print(loaded_var.size(), " size")
			else:
				set(var_name,loaded_var)
	file.close()

func save_base_vars():
	var file = FileAccess.open(BASE_SAVE_PATH,FileAccess.WRITE)
	for property in self.get_property_list():
		#print(property.hint," ", property.type, " ", property.name, " ",property.usage)
		if property.usage == PROPERTY_USAGE_SCRIPT_VARIABLE:
			var var_name : String = property.name
			var sel_var = get(var_name)
			#print(sel_var)
			file.store_var(sel_var)
	file.close()

func load_base_vars():
	var file = FileAccess.open(BASE_SAVE_PATH,FileAccess.READ)
	for property in self.get_property_list():
		if property.usage == PROPERTY_USAGE_SCRIPT_VARIABLE:
			var var_name : String = property.name
			var loaded_var = file.get_var()
			#print(property.hint," ", property.type, " ", property.name)
			#print("loaded var is ",loaded_var)
			if loaded_var is Array:
				var v = get(var_name)
				if v is Array:
					v.clear()
					v.append_array(loaded_var)
				#print(loaded_var.size(), " size")
			elif loaded_var is PackedVector2Array:
				var v = get(var_name)
				if v is PackedVector2Array:
					v.clear()
					v.append_array(loaded_var)
				#print(loaded_var.size(), " size")
			else:
				set(var_name,loaded_var)
	file.close()
