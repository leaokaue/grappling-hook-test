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
}

func _ready() -> void:
	match_item()
	if is_item_owned():
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
	var t := sprite
	
	#print(current_item)
	
	match current_item:
		i.HookThrowBoost:
			sprite.texture = roids1
			i_name = "Healthy Medicine"
			i_desc = "The Power of Medicine increases the strength of your Grapple Throw!"
		i.JumpBoost:
			sprite.texture = roids2
			i_name = "Pretty Healthy Medicine"
			i_desc = "The Power of Medicine increases the power of your Jump!!"
		i.SpeedBoost:
			sprite.texture = roids3
			i_name = "Incredibly Healthy Medicine!"
			i_desc = "The Power of Medicine increases your Movement Speed!"
		i.CoinCompass:
			sprite.texture = compass
			i_name = "Coin Compass"
			i_desc = "The Coin Compass allows you to find all earthly coins!"
		i.CoinTracker:
			sprite.texture = tracker
			i_name = "Coin Tracker"
			i_desc = "The Tracker allows you to see how many Coins are left on the map!"
		i.FastTravel:
			sprite.texture =  guiding_light
			i_name = "Guiding Light"
			i_desc = "The Light guides you, allowing you to travel with Waypoints at any time!"
		i.DashBoots:
			sprite.texture = dash_boots
			i_name = "Warp Boots"
			i_desc = "They can't shoot an atom! Press Shift to warp forwards. Small chance of being teleported into the void."
		i.JetPack:
			sprite.texture = jet_pack
			i_name = "Jetpack"
			i_desc = "Allows flight. Press Space again mid-air to activate."
		i.HookCooldownReducer:
			sprite.texture = cool_drink
			i_name = "Grape Juice"
			i_desc = "It's been a fun climb. Take a rest and some Grape Juice. It will reduce your Grapple Hook cooldown."
		i.GrappleRopeExtension:
			sprite.texture = extra_rope
			i_name = "Extra Rope"
			i_desc = "So much rope! Increases the length of your grapple hook!"
		i.RetractBoost:
			sprite.texture = motorized_pulley
			i_name = "Motorized Pulley"
			i_desc = "The Pulley allows you to retract your grappling hook faster!"
		i.LatchJumpBoost:
			sprite.texture = titanium_glove
			i_name = "Titanium Glove"
			i_desc = "Fits perfectly for a worm! Increases your latch strength when you land your Grapple."
		i.HoverStone:
			sprite.texture = hover_stone
			i_name = "Hover Stone"
			i_desc = "It whispers to you, allowing temporary hovering mid-air! Press Shift to hover."
		i.PoisonResist:
			sprite.texture = green_potion
			i_name = "Green Potion"
			i_desc = "Why did you drink that? Allows you to resist acid...."
		i.WaterDash:
			sprite.texture = tambaqui
			i_name = "Tambaqui"
			i_desc = "It graces you with its presence. Press RMB to swim underwater. While swmming, press LMB to perform a Dolphin Dash"
	
	#sprite.texture = t

func is_item_owned() -> bool:
	var i := ITEMS
	var t := sprite
	var g := Global
	#print(current_item)
	
	match current_item:
		i.HookThrowBoost:
			if Global.has_steroids_1:
				return true
			else:
				return false
		i.JumpBoost:
			if Global.has_steroids_2:
				return true
			else:
				return false
		i.SpeedBoost:
			if Global.has_steroids_3:
				return true
			else:
				return false
		i.CoinCompass:
			if Global.has_coin_compass:
				return true
			else:
				return false
		i.CoinTracker:
			if Global.has_coin_tracker:
				return true
			else:
				return false
		i.FastTravel:
			if Global.has_guiding_light:
				return true
			else:
				return false
		i.DashBoots:
			if Global.has_dash_boots:
				return true
			else:
				return false
		i.JetPack:
			if Global.has_jetpack:
				return true
			else:
				return false
		i.HookCooldownReducer:
			if Global.has_cool_drink:
				return true
			else:
				return false
		i.GrappleRopeExtension:
			if Global.has_rope_extension:
				return true
			else:
				return false
		i.RetractBoost:
			if Global.has_rope_pulley:
				return true
			else:
				return false
		i.LatchJumpBoost:
			if Global.has_boost_latch:
				return true
			else:
				return false
		i.HoverStone:
			if Global.has_hover_stone:
				return true
			else:
				return false
		i.PoisonResist:
			if Global.has_poison_resist:
				return true
			else:
				return false
		i.WaterDash:
			if Global.has_tambaqui:
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
