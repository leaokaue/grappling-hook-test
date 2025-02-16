extends Node

@warning_ignore("unused_signal")

signal request_coins

signal send_coins(location : Waypoint.WAYPOINTS)

signal set_nightmare_effect(effect : float)

signal update_coins

signal fade_animation_finished

signal change_target_zoom(zoom : float)

signal reset_zoom

signal reset_camera_smoothing

signal toggle_rain(on : bool)

signal teleport_to_waypoint(waypoint : int)

signal player_dead

signal clear_map

var coins : int = 0

const max_coins : int = 100

var coin_positions : PackedVector2Array

var collected_coin_position : PackedVector2Array

var seen_map : Dictionary = {
	"Spawn" : true,
	"Bog" : true,
	"Windmill" : false,
	"Spike" : false,
	"Space" : false,
	"Spike2" : false,
	"Empty" : false
	 
}

var waypoints_unlocked : Dictionary = {
	"Spawn" : true,
	"Bog" : false,
	"Windmill" : false,
	"Spike" : false,
	"Space" : false,
	"Empty" : false,
	"Spike2" : false
	 
}

var waypoint_position : Dictionary = {
	"Spawn" : Vector2(),
	"Bog" : Vector2(),
	"Windmill" : Vector2(),
	"Spike" : Vector2(),
	"Space" : Vector2(),
	 
}

enum EQUIPMENTS {
	None,
	DashBoots,
	Tambaqui,
	HoverStone,
	Jetpack
}

var current_equipment : EQUIPMENTS = EQUIPMENTS.None

var can_switch_equipments : bool = false

var can_use_waypoints : bool = false

#gives an arrow towards the closest coin
var has_coin_compass : bool = false

#displays how many coins an area has left
var has_coin_tracker : bool = false

#chuffed coin!
var has_chuffed_coin : bool = false

#allows you to dash once per jump
var has_dash_boots : bool = false

#is a jetpack
var has_jetpack : bool = false

#reduces grapple cooldown
var has_cool_drink : bool = false

#increases grapple range
var has_rope_extension : bool = false

#resist poison completely
var has_poison_resist : bool = false

#increases reteacting speed
var has_rope_pulley : bool = false

#increases boost from latching the grapple
var has_boost_latch : bool = false

#increases grapple speed
var has_steroids_1 : bool = false

#increases jump speed
var has_steroids_2 : bool = false

#increases move speed
var has_steroids_3 : bool = false

#lets the player hover for a bit
var has_hover_stone : bool = false

#allows player to waypoint anywhere
var has_guiding_light : bool = false

#water dash
var has_tambaqui : bool = false

var player : Worm

var background : BackgroundManager

var music_player : MusicManager

var t : Tween


func _process(_delta: float) -> void:
	pass

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

func set_area_seen(area : int):
	seen_map[Waypoint.WAYPOINTS.keys()[area]] = true

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
		collected_coin_position.append(pos)

func remove_collected_coins_from_scene():
	if not collected_coin_position.size() > 0:
		return
	
	for coin in get_tree().get_nodes_in_group("Coins"):
		if coin is Node2D:
			if collected_coin_position.has(coin.global_position):
				coin.queue_free()

func get_coin_vec2_array():
	for coin in get_tree().get_nodes_in_group("Coins"):
		if coin is Node2D:
			print(coin)
			coin_positions.append(coin.global_position)
