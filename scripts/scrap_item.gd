@tool
extends TextureButton
class_name ScrapItem

signal item_clicked(item : Item.ITEMS,item_self)

@export var current_item : Item.ITEMS

@export var is_grappling_hook : bool = false

@export var item_name : String

@export_group("Textures")
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
@export var grappling_hook : Texture

func _ready() -> void:
	
	match_item()
	
	update_ui()
	
	if Engine.is_editor_hint():
		return
	
	mouse_entered.connect(on_mouse_enter)
	mouse_exited.connect(on_mouse_exit)
	button_up.connect(released)
	button_down.connect(pressed)
	
	if Item.is_item_owned(current_item):
		show()
	else:
		hide()
	

func pressed() -> void:
	self.modulate.v = 0.6
	item_clicked.emit(current_item,self)

func released() -> void:
	self.modulate.v = 1.0

func on_mouse_enter() -> void:
	self.modulate.v = 0.8

func on_mouse_exit() -> void:
	self.modulate.v = 1.0

func _process(delta: float) -> void:
	pass

func update_ui():
	if is_grappling_hook:
		self.texture_normal = grappling_hook
		item_name = "Grappling... Hook?"
		return
	
	match_item()
	
	if Item.is_item_owned(current_item):
		show()
	else:
		hide()
	
	%Label.text = item_name

func match_item():
	var i := Item.ITEMS
	var s := self
	
	#print(current_item)
	
	match current_item:
		i.HookThrowBoost:
			s.texture_normal = roids1
			item_name = "Healthy Medicine"
		i.JumpBoost:
			s.texture_normal = roids2
			item_name = "Pretty Healthy Medicine"
		i.SpeedBoost:
			s.texture_normal = roids3
			item_name = "Incredibly Healthy Medicine!"
		i.CoinCompass:
			s.texture_normal = compass
			item_name = "Coin Compass"
		i.CoinTracker:
			s.texture_normal = tracker
			item_name = "Coin Tracker"
		i.FastTravel:
			s.texture_normal =  guiding_light
			item_name = "Guiding Light"
		i.DashBoots:
			s.texture_normal = dash_boots
			item_name = "Warp Boots"
		i.JetPack:
			s.texture_normal = jet_pack
			item_name = "Jetpack"
		i.HookCooldownReducer:
			s.texture_normal = cool_drink
			item_name = "Grape Juice"
		i.GrappleRopeExtension:
			s.texture_normal = extra_rope
			item_name = "Extra Rope"
		i.RetractBoost:
			s.texture_normal = motorized_pulley
			item_name = "Motorized Pulley"
		i.LatchJumpBoost:
			s.texture_normal = titanium_glove
			item_name = "Titanium Glove"
		i.HoverStone:
			s.texture_normal = hover_stone
			item_name = "Hover Stone"
		i.PoisonResist:
			s.texture_normal = green_potion
			item_name = "Green Potion"
		i.WaterDash:
			s.texture_normal = tambaqui
			item_name = "Tambaqui"
		i.Trash:
			s.texture_normal = trash
			item_name = "Trash Bag"
