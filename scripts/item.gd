@tool
extends Node2D
class_name Item

@onready var sprite := %Item

@onready var light := %Light

@onready var area := %Area2D

@export var current_item : ITEMS

const ui : PackedScene = preload(("res://scenes/item_pickup_ui.tscn"))

var property_name : StringName = ""

@export_subgroup("Item Textures")

@export var roids1 : Texture
@export var roids2 : Texture
@export var roids3 : Texture
@export var compass : Texture
@export var tracker : Texture
@export var hover_stone : Texture
@export var guiding_light : Texture 
@export var dash_boots : Texture
@export var jet_pack : Texture
@export var cool_drink : Texture
@export var tambaqui : Texture
@export var extra_rope : Texture
@export var green_potion : Texture
@export var motorized_pulley : Texture
@export var titanium_glove : Texture
@export var trash : Texture
@export var cube : Texture

var i_desc : String
var i_name : String

enum ITEMS {
	HookThrowBoost,
	JumpBoost,
	SpeedBoost,
	CoinCompass,
	CoinTracker,
	HoverStone,
	FastTravel,
	DashBoots,
	JetPack,
	HookCooldownReducer,
	WaterDash,
	GrappleRopeExtension,
	PoisonResist,
	RetractBoost,
	LatchJumpBoost,
	Trash,
	ErrorCube
}

func _ready() -> void:
	
	#if Engine.is_editor_hint():
		#return
	
	match_item()
	if is_item_owned(current_item):
		self.queue_free()
	area.body_entered.connect(on_body_entered)
	tween()

func on_body_entered(body : Node2D):
	if body is Worm:
		collect()

func _physics_process(delta: float) -> void:
	light.rotation_degrees += 20 * delta

func collect():
	Global.unlock_item(current_item,true)
	Global.items_collected += 1
	instantiate_ui()
	$blamo.play()
	$Area2D/CollisionShape2D.set_deferred("disabled",true)
	$collect.emitting = true
	Global.player.linear_velocity *= 0.3
	self.hide()
	await get_tree().create_timer(2.0,false).timeout
	self.queue_free()

func instantiate_ui():
	var u := ui.instantiate()
	get_tree().current_scene.add_child(u)
	u.set_item_name(i_name)
	u.set_texture(sprite.texture)
	u.set_item_desc(i_desc)

func match_item():
	var i := ITEMS
	var s := %Item
	var t := s
	
	#print(current_item)
	
	match current_item:
		i.HookThrowBoost:
			s.texture = roids1
			i_name = "Healthy Medicine"
			i_desc = "The Power of Medicine increases the strength of your Grapple Throw!"
		i.JumpBoost:
			s.texture = roids2
			i_name = "Pretty Healthy Medicine"
			i_desc = "The Power of Medicine increases the power of your Jump!!"
		i.SpeedBoost:
			s.texture = roids3
			i_name = "Incredibly Healthy Medicine!"
			i_desc = "The Power of Medicine increases your Movement Speed!"
		i.CoinCompass:
			s.texture = compass
			i_name = "Coin Compass"
			i_desc = "The Coin Compass allows you to find all earthly coins!"
		i.CoinTracker:
			s.texture = tracker
			i_name = "Coin Tracker"
			i_desc = "The Tracker allows you to see how many Coins are left on the map!"
		i.FastTravel:
			s.texture =  guiding_light
			i_name = "Guiding Light"
			i_desc = "The Light guides you, allowing you to travel with Waypoints at any time!"
		i.DashBoots:
			s.texture = dash_boots
			i_name = "Warp Boots"
			i_desc = "They can't shoot an atom! Press Shift to warp forwards. Small chance of being teleported into the void. Must be equipped first."
		i.JetPack:
			s.texture = jet_pack
			i_name = "Jetpack"
			i_desc = "Allows flight. Press Space again mid-air to activate. Must be equipped first."
		i.HookCooldownReducer:
			s.texture = cool_drink
			i_name = "Grape Juice"
			i_desc = "It's been a fun climb. Take a rest and some Grape Juice. It will reduce your Grapple Hook cooldown."
		i.GrappleRopeExtension:
			s.texture = extra_rope
			i_name = "Extra Rope"
			i_desc = "So much rope! Increases the length of your grapple hook!"
		i.RetractBoost:
			s.texture = motorized_pulley
			i_name = "Motorized Pulley"
			i_desc = "The Pulley allows you to retract your grappling hook faster!"
		i.LatchJumpBoost:
			s.texture = titanium_glove
			i_name = "Titanium Glove"
			i_desc = "Fits perfectly for a worm! Increases your latch strength when you land your Grapple."
		i.HoverStone:
			s.texture = hover_stone
			i_name = "Hover Stone"
			i_desc = "It whispers to you, allowing temporary hovering mid-air! Press Shift to hover. Must be equipped first."
		i.PoisonResist:
			s.texture = green_potion
			i_name = "Green Potion"
			i_desc = "Why did you drink that? Allows you to resist acid...."
		i.WaterDash:
			s.texture = tambaqui
			i_name = "Tambaqui"
			i_desc = "Hold RMB underwater to swim gracefully.
			 Outside of water, you will perform a Dolphin Leap.
			 It's quite pleasant. Must be equipped first."
		i.Trash:
			s.texture = trash
			i_name = "Trash Bag"
			i_desc = "Wow! This is worthless! If only you could scrap this."
		i.ErrorCube:
			s.texture = cube
			i_name = "False Cube"
			i_desc = "Materialized from spite.
			Press Shift to put it down on the world.
			It will help you get out of here."
	#sprite.texture = t

static func is_item_scrapped(item : Item.ITEMS) -> bool:
	var i := ITEMS
	#print(current_item)
	
	if Engine.is_editor_hint():
		return false
	
	match item:
		i.HookThrowBoost:
			if Global.steroids_1_scrapped:
				return true
			else:
				return false
		i.JumpBoost:
			if Global.steroids_2_scrapped:
				return true
			else:
				return false
		i.SpeedBoost:
			if Global.steroids_3_scrapped:
				return true
			else:
				return false
		i.CoinCompass:
			if Global.coin_compass_scrapped:
				return true
			else:
				return false
		i.CoinTracker:
			if Global.coin_tracker_scrapped:
				return true
			else:
				return false
		i.FastTravel:
			if Global.guiding_light_scrapped:
				return true
			else:
				return false
		i.DashBoots:
			if Global.dash_boots_scrapped:
				return true
			else:
				return false
		i.JetPack:
			if Global.jetpack_scrapped:
				return true
			else:
				return false
		i.HookCooldownReducer:
			if Global.cool_drink_scrapped:
				return true
			else:
				return false
		i.GrappleRopeExtension:
			if Global.rope_extension_scrapped:
				return true
			else:
				return false
		i.RetractBoost:
			if Global.rope_pulley_scrapped:
				return true
			else:
				return false
		i.LatchJumpBoost:
			if Global.boost_latch_scrapped:
				return true
			else:
				return false
		i.HoverStone:
			if Global.hover_stone_scrapped:
				return true
			else:
				return false
		i.PoisonResist:
			if Global.poison_resist_scrapped:
				return true
			else:
				return false
		i.WaterDash:
			if Global.tambaqui_scrapped:
				return true
			else:
				return false
		i.Trash:
			if Global.trash_bag_scrapped:
				return true
			else:
				return false
	
	return true

static func is_item_owned(item : Item.ITEMS) -> bool:
	var i := ITEMS
	#print(current_item)
	
	if Engine.is_editor_hint():
		return false
	
	match item:
		i.HookThrowBoost:
			if Global.has_steroids_1 or Global.steroids_1_scrapped:
				return true
			else:
				return false
		i.JumpBoost:
			if Global.has_steroids_2 or Global.steroids_2_scrapped:
				return true
			else:
				return false
		i.SpeedBoost:
			if Global.has_steroids_3 or Global.steroids_3_scrapped:
				return true
			else:
				return false
		i.CoinCompass:
			if Global.has_coin_compass or Global.coin_compass_scrapped:
				return true
			else:
				return false
		i.CoinTracker:
			if Global.has_coin_tracker or Global.coin_tracker_scrapped:
				return true
			else:
				return false
		i.FastTravel:
			if Global.has_guiding_light or Global.guiding_light_scrapped:
				return true
			else:
				return false
		i.DashBoots:
			if Global.has_dash_boots or Global.dash_boots_scrapped:
				return true
			else:
				return false
		i.JetPack:
			if Global.has_jetpack or Global.jetpack_scrapped:
				return true
			else:
				return false
		i.HookCooldownReducer:
			if Global.has_cool_drink or Global.cool_drink_scrapped:
				return true
			else:
				return false
		i.GrappleRopeExtension:
			if Global.has_rope_extension or Global.rope_extension_scrapped:
				return true
			else:
				return false
		i.RetractBoost:
			if Global.has_rope_pulley or Global.rope_pulley_scrapped:
				return true
			else:
				return false
		i.LatchJumpBoost:
			if Global.has_boost_latch or Global.boost_latch_scrapped:
				return true
			else:
				return false
		i.HoverStone:
			if Global.has_hover_stone or Global.hover_stone_scrapped:
				return true
			else:
				return false
		i.PoisonResist:
			if Global.has_poison_resist or Global.poison_resist_scrapped:
				return true
			else:
				return false
		i.WaterDash:
			if Global.has_tambaqui or Global.tambaqui_scrapped:
				return true
			else:
				return false
		i.Trash:
			if Global.has_trash_bag or Global.trash_bag_scrapped:
				return true
			else:
				return false
		i.ErrorCube:
			if Global.has_error_cube:
				return true
			else:
				return false
	
	return true

func tween():
	var t := create_tween()
	
	t.set_trans(Tween.TRANS_SINE)
	t.set_loops()
	t.tween_property(sprite,"position:y",sprite.position.y + 5,0.5)
	t.tween_property(sprite,"position:y",sprite.position.y - 5,0.5)
