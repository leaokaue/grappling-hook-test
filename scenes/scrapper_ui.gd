extends CanvasLayer

@onready var animation := %AnimationPlayer
@export var item_rect : TextureRect

@export var scrap_items : Array[ScrapItem]

@export var hook_scrap_item : ScrapItem

@export var scrapping : bool = false

@export var scrap_container : Control

@export var ss_container : Control

@export_group("Scrap Button Nodes")
@export var scrap_button : Button
@export var scrap_label : Label
@export_multiline var sl_text : String
@export_group("Super Scrap Nodes")
@export var super_scrap : CheckButton
@export var ss_label : Label
@export_multiline var ss_text : String

var is_scrap_selected : bool = false

var selected_item : int 
var selected_node : ScrapItem

func _ready() -> void:
	item_rect.hide()
	on_super_scrap_toggle(false)
	update_trash_labels()
	connect_item_signals()
	%Exit.pressed.connect(on_exit_pressed)
	
	var t := create_tween()
	$Control.modulate.a = 0.0
	t.tween_property($Control,"modulate:a",1.0,0.9)


func on_exit_pressed():
	self.queue_free()

func on_scrap_pressed():
	
	if scrapping or (not is_scrap_selected):
		return
	
	is_scrap_selected = false
	animation.play("scrap")
	Global.scrap_item(selected_item,true)
	Global.trash_points += 1
	selected_node.update_ui()
	await get_tree().create_timer(0.2,false).timeout
	update_trash_labels()

func on_item_pressed(item : Item.ITEMS, item_node : ScrapItem):
	
	if scrapping:
		return
	
	is_scrap_selected = true
	selected_item = item
	selected_node = item_node
	item_rect.texture = selected_node.texture_normal
	item_rect.show()
	animation.play("RESET")

func connect_item_signals():
	for i in scrap_items:
		i.item_clicked.connect(on_item_pressed)
	scrap_button.pressed.connect(on_scrap_pressed)
	super_scrap.toggled.connect(on_super_scrap_toggle)

func update_trash_labels():
	var text_trash_points_total : String = sl_text % Global.trash_points
	var text_trash_points_unlock : String = ss_text % clampi(Global.trash_points,0,10)
	
	scrap_label.text = text_trash_points_total
	ss_label.text = text_trash_points_unlock
	
	if Global.trash_points >= 10:
		ss_label.modulate = Color.GOLD
		super_scrap.disabled = false
	else:
		super_scrap.disabled = true
	
	if Global.trash_points >= 16:
		scrap_label.modulate = Color.GOLD

func on_super_scrap_toggle(toggled_on : bool):
	ss_container.visible = toggled_on
	scrap_container.visible = !toggled_on
