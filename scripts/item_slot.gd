extends Control
class_name EquipmentSlot

#signal completed

signal item_chosen

@onready var label := $Label

static var label_text : String

@export var clear_button : Button

@export var bg : Control
@export var item_rect : TextureRect

@export var dash_boots : SGGateItem
@export var tambaqui : SGGateItem
@export var hover_stone : SGGateItem
@export var jetpack : SGGateItem

@export var checker : Panel

#@export var blocker : Panel

@onready var item_array : Array[SGGateItem] = [dash_boots,tambaqui]#tambaqui,hover_stone,jetpack]

var holding_object : bool = false

var held_object : Global.EQUIPMENTS

var hovering_panel : bool = false

func _ready() -> void:
	connect_item_signals()
	
	checker.mouse_entered.connect(panel_hover)
	checker.mouse_exited.connect(panel_leave)
	clear_button.pressed.connect(clear_item)
	
	if Global.current_equipment == Global.EQUIPMENTS.None:
		clear_button.disabled = true
	
	check_texture(Global.current_equipment)
	#await get_tree().create_timer(2.5,false).timeout
	#item_rect.hide()

func _exit_tree() -> void:
	pass

func connect_item_signals():
	for item in item_array:
		item.picked_up.connect(on_item_pickup)
		item.released.connect(on_item_release)

func on_item_pickup(item : Global.EQUIPMENTS):
	holding_object = true
	held_object = item

func on_item_release(item_node : SGGateItem):
	holding_object = false
	if hovering_panel:
		check_panel(item_node,held_object)

func panel_hover():
	hovering_panel = true

func panel_leave():
	hovering_panel = false

func check_panel(item_node : SGGateItem, item : Global.EQUIPMENTS):
	
	var e := Global.EQUIPMENTS
	
	for i in item_array:
		i.item_show()
	
	Global.current_equipment = item
	item_rect.texture = item_node.texture_normal
	item_node.item_hide()
	label_text = item_node.label.text
	label.text = label_text
	clear_button.disabled = false

func check_texture(item : Global.EQUIPMENTS):
	var e := Global.EQUIPMENTS
	
	for i in item_array:
		i.show()
	
	label.text = label_text
	
	match item:
		e.None:
			item_rect.texture = Texture.new()
		e.DashBoots:
			item_rect.texture = dash_boots.texture_normal
			dash_boots.hide()
		e.Tambaqui:
			item_rect.texture = tambaqui.texture_normal
			tambaqui.hide()
		e.HoverStone:
			item_rect.texture = hover_stone.texture_normal
			hover_stone.hide()
		e.Jetpack:
			item_rect.texture = jetpack.texture_normal
			jetpack.hide()

func clear_item():
	for i in item_array:
		i.show()
	
	var e := Global.EQUIPMENTS
	
	item_rect.texture = Texture.new()
	label_text = ""
	label.text = label_text
	
	clear_button.disabled = true
	
	Global.current_equipment = e.None
	

	#if item == OBJECTS.Crystal:
		#print("dash_boots in")
		#complete_animation()
	#else:
		#var t := item_array[item].text
		#t.hide_lines = true
		#t.instantiate_textbox()
		#blocker.mouse_filter = Control.MOUSE_FILTER_STOP
		#await SignalBus.textbox_finished
		#blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_equipment():
	pass

#func enter_animation():
	#hide_all()
	#blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	#modulate_node_smooth(lines,1.0,2.9)
	#await get_tree().create_timer(1.2,false).timeout
	#modulate_node_smooth(bg,1.0,2.3)
	#await get_tree().create_timer(2.2,false).timeout
	#for item in item_array:
		#if item_array.find(item) > 1:
			#if not PlayerVariables.trash_obtained[item.name]:
				#item.mouse_filter = Control.MOUSE_FILTER_IGNORE
				#continue
		#modulate_node_smooth(item,1.0,0.4)
		#modulate_node_smooth(item.behind,0.69,0.4)
		#modulate_bg(item.bg,0.0,1.0,0.6)
		#await get_tree().create_timer(0.35,false).timeout
	#modulate_node_smooth(leave,1.0,0.3)
	#await get_tree().create_timer(0.35,false).timeout
	#blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE

#func complete_animation():
	#var s := func():
		#PlayerVariables.sacred_gate_open = true
		#SignalBus.shake_boss_camera.emit(3.0,8.0)
		#completed.emit()
	#blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	#modulate_node_smooth(leave,0.0,0.2)
	#item_rect.show()
	#for item in item_array:
		#if item_array.find(item) > 1:
			#if not PlayerVariables.trash_obtained[item.name]:
				#continue
		#modulate_node_smooth(item,0.0,0.2)
		#modulate_node_smooth(item.behind,0.0,0.2)
		#modulate_bg(item.bg,1.0,0.0,0.2)
		#await get_tree().create_timer(0.05,false).timeout
	#var t := self.create_tween()
	#t.tween_property(item_rect,"scale",Vector2(1.35,1.35),0.25)
	#t.tween_callback(s)
	#t.tween_interval(2.0)
	#await get_tree().create_timer(0.5,false).timeout
	#modulate_node_smooth(lines,0.0,1.9)
	#await get_tree().create_timer(2.5,false).timeout
	#modulate_node_smooth(bg,0.0,1.9)
	#await get_tree().create_timer(3.5,false).timeout
	#if is_instance_valid(interactbox):
		#interactbox.finish()
	#self.queue_free()

#func exit_animation():
	#blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	#modulate_node_smooth(lines,0.0,0.4)
	#await get_tree().create_timer(0.1,false).timeout
	#modulate_node_smooth(bg,0.0,0.4)
	#for item in item_array:
		#if item_array.find(item) > 1:
			#if not PlayerVariables.trash_obtained[item.name]:
				#continue
		#modulate_node_smooth(item,0.0,0.2)
		#modulate_node_smooth(item.behind,0.0,0.2)
		#modulate_bg(item.bg,1.0,0.0,0.2)
		#await get_tree().create_timer(0.05,false).timeout
	#modulate_node_smooth(leave,0.0,0.2)
	#await get_tree().create_timer(0.75,false).timeout
	#if is_instance_valid(interactbox):
		#interactbox.finish()
	#queue_free()

#func hide_all():
	#lines.modulate.a = 0
	#leave.modulate.a = 0
	#bg.modulate.a = 0
	#for item in item_array:
		#item.behind.modulate.a = 0
		#item.bg.material.set_shader_parameter("alpha",0.0)
		#item.modulate.a = 0

func modulate_bg(node : Control, begin : float,end : float, time : float):
	var t := self.create_tween()
	var s := node.material as ShaderMaterial
	var f := func(x):
		s.set_shader_parameter("alpha",x)
	t.tween_method(f,begin,end,time)

func modulate_node_smooth(node : Control ,end_alpha : float,time : float):
	var t := self.create_tween()
	t.tween_property(node,"modulate:a",end_alpha,time)
