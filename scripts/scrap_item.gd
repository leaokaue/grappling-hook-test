@tool
extends TextureButton
class_name ScrapItem

signal item_clicked(item : Item.ITEMS,item_self)

@export var is_toggle_item : bool = false

@export var current_item : Item.ITEMS

@export var is_grappling_hook : bool = false

@export var item_name : String

var item_description : String

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

@export var name_label : Label

var default_modulate_value : float = 1.0

func _ready() -> void:
	
	#match_item()
	
	update_ui()
	
	if Engine.is_editor_hint():
		return
	
	mouse_entered.connect(on_mouse_enter)
	mouse_exited.connect(on_mouse_exit)
	button_up.connect(released)
	button_down.connect(pressed)
	
	if is_grappling_hook:
		show()
		return
	
	if Item.is_item_owned(current_item):
		if not Item.is_item_scrapped(current_item):
			if not is_toggle_item:
				show()
			else:
				self.default_modulate_value = 1.0
				self.modulate.v = 1.0
		else:
			if not is_toggle_item:
				hide()
			else:
				self.default_modulate_value = 0.5
				self.modulate.v = 0.5
	else:
		hide()


func pressed() -> void:
	self.modulate.v = default_modulate_value - 0.4
	item_clicked.emit(current_item,self)

func released() -> void:
	self.modulate.v = default_modulate_value

func on_mouse_enter() -> void:
	self.modulate.v = default_modulate_value - 0.2

func on_mouse_exit() -> void:
	self.modulate.v = default_modulate_value

func _process(delta: float) -> void:
	pass

func update_ui():
	if is_grappling_hook:
		self.texture_normal = grappling_hook
		item_name = "Grappling... Hook?"
		return
	
	match_item()
	
	if not is_toggle_item:
		if not Global.is_item_scrapped(current_item):
			show()
		else:
			hide()
	else:
		if Global.is_item_unlocked(current_item):
			show()
			if not Global.is_item_scrapped(current_item):
				self.default_modulate_value = 1.0
				self.modulate.v = 1.0
			else:
				self.default_modulate_value = 0.7
				self.modulate.v = 0.7
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
			item_description = "Increases your grappling hook throw force by 33%"
		i.JumpBoost:
			s.texture_normal = roids2
			item_name = "Pretty Healthy Medicine"
			item_description = "Increases your jump height by 35%"
		i.SpeedBoost:
			s.texture_normal = roids3
			item_name = "Incredibly Healthy Medicine!"
			item_description = "Increases your movement speed by 35%"
		i.CoinCompass:
			s.texture_normal = compass
			item_name = "Coin Compass"
			item_description = "Points towards the nearest coin. That isn't in space."
		i.CoinTracker:
			s.texture_normal = tracker
			item_name = "Coin Tracker"
			item_description = "Shows you on the map how many coins are left in an area. Every area has 20 coins. Collect them all!"
		i.FastTravel:
			s.texture_normal =  guiding_light
			item_name = "Guiding Light"
			item_description = "Allows you to use your waypoints on the map without needing to use a Waypoint Stone"
		i.DashBoots:
			s.texture_normal = dash_boots
			item_name = "Warp Boots"
			item_description = "Teleports you forward. \n Cooldown : 1.5 seconds"
		i.JetPack:
			s.texture_normal = jet_pack
			item_name = "Jetpack"
			item_description = "Allows flight for a maximum of 2 seconds. \n Cooldown : Instantly refreshes when touching the ground"
		i.HookCooldownReducer:
			s.texture_normal = cool_drink
			item_name = "Grape Juice"
			item_description = "Reduces the cooldown of your Grappling Hook by 50%"
		i.GrappleRopeExtension:
			s.texture_normal = extra_rope
			item_name = "Extra Rope"
			item_description = "Increases the maximum length before the Grappling Hook's rope snaps by 40%"
		i.RetractBoost:
			s.texture_normal = motorized_pulley
			item_name = "Motorized Pulley"
			item_description = "Increases the force when retracting the Grappling Hook by 40%"
		i.LatchJumpBoost:
			s.texture_normal = titanium_glove
			item_name = "Titanium Glove"
			item_description = "Increases the launch force when the Grappling Hook lands by 40%"
		i.HoverStone:
			s.texture_normal = hover_stone
			item_name = "Hover Stone"
			item_description = "While activated, you will hover for up to 2.2 seconds. Can be used at any charge. \n Cooldown : Recharges completely in 7.5s. Does not recharge when Grappled."
		i.PoisonResist:
			s.texture_normal = green_potion
			item_name = "Green Potion"
			item_description = "Reduces poison buildup by 85%. Tastes like lemonade."
		i.WaterDash:
			s.texture_normal = tambaqui
			item_name = "Tambaqui"
			item_description = "Allows you to swim underwater for up to 7 seconds when activated, additionally decreasing your drown buildup.\n Outside of water, you will perform a Dolphin Jump, using up all charge. \n Cooldown : Recharges completely in 6s. This is reduced by 60% underwater."
		i.Trash:
			s.texture_normal = trash
			item_name = "Trash Bag"
			item_description = "Does not increase your Gumption by 50%."
