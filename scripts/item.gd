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
@export var mystic_stone : Texture 
@export var dash_boots : Texture
@export var jet_pack : Texture
@export var cool_drink : Texture
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
	FastTravel,
	DashBoots,
	JetPack,
	HookCooldownReducer,
	GrappleRopeExtension,
	PoisonResist,
	RetractBoost,
	LatchJumpBoost,
}

func _ready() -> void:
	match_item()
	area.body_entered.connect(on_body_entered)
	tween()

func on_body_entered(body : Node2D):
	if body is Worm:
		collect()

func _physics_process(delta: float) -> void:
	light.rotation_degrees += 20 * delta

func collect():
	Global.unlock_item(current_item,true)
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
	@warning_ignore("unused_variable")
	var t : Texture = sprite.texture
	
	match current_item:
		i.HookThrowBoost:
			t = roids1
			i_name = "Healthy Medicine"
			i_desc = "The Power of Medicine increases the strength of your Grapple Throw!"
		i.JumpBoost:
			t = roids2
		i.SpeedBoost:
			t = roids3
		i.CoinCompass:
			t = compass
		i.CoinTracker:
			t = tracker
		i.FastTravel:
			t = mystic_stone
		i.DashBoots:
			t = dash_boots
		i.JetPack:
			t = jet_pack
		i.HookCooldownReducer:
			t = cool_drink
		i.GrappleRopeExtension:
			t = extra_rope
		i.RetractBoost:
			t = motorized_pulley
		i.LatchJumpBoost:
			t = titanium_glove
	

func tween():
	var t := create_tween()
	
	t.set_trans(Tween.TRANS_SINE)
	t.set_loops()
	t.tween_property(sprite,"position:y",sprite.position.y + 5,0.5)
	t.tween_property(sprite,"position:y",sprite.position.y - 5,0.5)
