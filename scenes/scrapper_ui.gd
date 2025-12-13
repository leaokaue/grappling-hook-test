extends CanvasLayer

@onready var animation := %AnimationPlayer
@export var item_rect : TextureRect

@export var scrap_items : Array[ScrapItem]

@export var hook_scrap_item : ScrapItem

@export var scrapping : bool = false:
	set(value):
		scrapping = value
		if scrapping:
			scrap_button.disabled = true
		else:
			scrap_button.disabled = false

@export var scrap_container : Control

@export var ss_container : Control

@export var main_control : Control

@export var break_1 : TextureRect
@export var break_2 : TextureRect
@export var break_3 : TextureRect

@export_group("Scrap Button Nodes")
@export var scrap_button : Button
@export var scrap_label : Label
@export_multiline var sl_text : String
@export_group("Super Scrap Nodes")
@export var super_scrap : CheckButton
@export var ss_label : Label
@export_multiline var ss_text : String

var is_scrap_selected : bool = false

var is_grapple_hook_selected : bool = false

var selected_item : int 
var selected_node : ScrapItem

@export var shake : float = 0.0

var initial_position : Vector2

@export var shake_strength : float = 3.0

var super_scrap_tries : int = 0

func _ready() -> void:
	initial_position = main_control.global_position
	item_rect.hide()
	on_super_scrap_toggle(false)
	update_trash_labels()
	connect_item_signals()
	%Exit.pressed.connect(on_exit_pressed)
	
	var t := create_tween()
	$Control.modulate.a = 0.0
	t.tween_property($Control,"modulate:a",1.0,0.9)

func _physics_process(delta: float) -> void:
	handle_shake(delta)

func on_exit_pressed():
	self.queue_free()

func on_super_scrap_pressed():
	if scrapping or (not is_scrap_selected):
		return
	
	is_scrap_selected = false
	animation.play("scrap_fail")
	super_scrap_tries += 1

func on_scrap_pressed():
	if is_grapple_hook_selected:
		if scrapping:
			print("is scrapping, returning")
			return
		print("yooo")
		is_scrap_selected = false
		#animation.play("scrap_fail")
		progress_hook_scrap()
		return
	
	if scrapping or (not is_scrap_selected):
		return
	
	is_scrap_selected = false
	animation.play("scrap")
	Global.scrap_item(selected_item,true)
	var i := Item.ITEMS
	var equipments : Array[Item.ITEMS] = [i.DashBoots,i.WaterDash,i.HoverStone,i.JetPack]
	if equipments.has((selected_item as Item.ITEMS)):
		Global.current_equipment = 0
	Global.trash_points += 1
	selected_node.update_ui()
	await get_tree().create_timer(0.2,false).timeout
	update_trash_labels()

func on_grapple_pressed(_empty : int, item_node : ScrapItem):
	if scrapping:
		return
	
	is_grapple_hook_selected = true
	is_scrap_selected = false
	selected_node = item_node
	item_rect.texture = item_node.texture_normal
	item_rect.show()
	animation.play("RESET")

func on_item_pressed(item : Item.ITEMS, item_node : ScrapItem):
	
	if scrapping:
		return
	
	if selected_item == item:
		clear_item_selection()
		return
	
	is_scrap_selected = true
	selected_item = item
	selected_node = item_node
	item_rect.texture = selected_node.texture_normal
	item_rect.show()
	animation.play("RESET")

func clear_item_selection():
	selected_item = -1
	is_scrap_selected  = false
	item_rect.texture = null
	item_rect.hide()
	animation.play("RESET")

func connect_item_signals():
	for i in scrap_items:
		i.item_clicked.connect(on_item_pressed)
	hook_scrap_item.item_clicked.connect(on_grapple_pressed)
	scrap_button.pressed.connect(on_scrap_pressed)
	super_scrap.toggled.connect(on_super_scrap_toggle)

func update_trash_labels():
	var text_trash_points_total : String = sl_text % Global.trash_points
	var text_trash_points_unlock : String = ss_text % clampi(Global.trash_points,0,8)
	
	scrap_label.text = text_trash_points_total
	ss_label.text = text_trash_points_unlock
	
	if Global.trash_points >= 8:
		ss_label.modulate = Color.GOLD
		super_scrap.disabled = false
	else:
		super_scrap.disabled = true
	
	if Global.trash_points >= 16:
		scrap_label.modulate = Color.GOLD

func on_super_scrap_toggle(toggled_on : bool):
	clear_item_selection()
	ss_container.visible = toggled_on
	scrap_container.visible = !toggled_on

func handle_shake(delta : float):
	if shake > 0:
		shake -= delta
		shake_ui()
	else:
		main_control.global_position = initial_position

func shake_ui():
	var offs : Vector2 = Vector2(
		randf_range(-shake_strength,shake_strength),
		randf_range(-shake_strength,shake_strength)
	)
	main_control.global_position = initial_position + offs

func progress_hook_scrap():
	super_scrap_tries += 1
	match super_scrap_tries:
		1:
			animation.play("scrap_fail")
			set_vignette(0.33)
			disable_all_exits()
			if Global.music_player:
				var t := create_tween()
				t.tween_property(Global.music_player,"volume_db",-80,5)
			
			%ScaryBG.play()
			#set in vignette, disable buttons
			#suspense sound effect
			#break grapple 1
			await get_tree().create_timer(0.13,false).timeout
			break_1.show()
			
		2:
			animation.play("scrap_fail")
			set_vignette(0.66)
			#start hook screaming
			#break grapple 2, particles coming off
			await get_tree().create_timer(0.13,false).timeout
			%Label2.text = "IT HURTS. IT HURTS. IT HURTS. IT HURTS. IT HURTS. IT HURTS SO MUCH."
			break_2.show()
			%Breaking.emitting = true
			%BreathHeavy.stop()
			await get_tree().create_timer(2.6,false).timeout
			%TrashPoints.text = "01010010 01000101 01010100 01010010 01001001 01000010 01010101 01010100 01001001 01001111 01001110"
			
			%CryPain.stop()
			%BreathHeavy.play()
		3:
			animation.play("scrap_fail")
			set_vignette(1.0)
			#break grapple 3, particles coming off, doesnt stop screaming
			#change label
			%GName.text = "###################################################"
			await get_tree().create_timer(0.13,false).timeout
			%BreathHeavy.stop()
			%CryPain.play(2.0)
			%TPl1.text = "NO NO NO NO NO NO"
			await get_tree().create_timer(2.6,false).timeout
			%CryPain.stop()
			%BreathHeavy.play()
			%Glitch.show()
		4:
			animation.play("scrap_fail")
			set_vignette(1.0)
			#break grapple 3, particles coming off, doesnt stop screaming
			#change label
			scrap_button.text = "STOP"
			%TPl2.text = "I DON'T WANT TO #####"
			await get_tree().create_timer(0.13,false).timeout
			%CryPain.play()
			break_3.show()
			%BreathHeavy.stop()
			%CryPain.play(randf_range(0.0,0.2))
			await get_tree().create_timer(2.6,false).timeout
			%CryPain.stop()
			%BreathHeavy.play()
		5:
			animation.play("scrap_fail_success")
			%CryPain.play(1.5)
			%BreathHeavy.stop()
			%Label3.text = "%s, IT DOESN'T END HERE" % get_user_name()
			await get_tree().create_timer(2.4,false).timeout
			go_into_darkness()
			%ScaryBG.stop()
			%CryPain.stop()
			#grapple finally goes in, fade to black, cut to scary load scren.

func go_into_darkness():
	var t : Tween = create_tween()
	var o_radius : float = (%Vignette.material as ShaderMaterial).get_shader_parameter("outer_radius")
	var i_radius : float = (%Vignette.material as ShaderMaterial).get_shader_parameter("inner_radius")
	var s_o := func(x : float):
		(%Vignette.material as ShaderMaterial).set_shader_parameter("outer_radius",x)
	var s_i := func(x : float):
		(%Vignette.material as ShaderMaterial).set_shader_parameter("inner_radius",x)
	
	t.tween_method(s_i,i_radius,0.0,0.1)
	t.parallel().tween_method(s_o,o_radius,0.0,0.2)

func set_vignette(strength : float):
	var t : Tween = create_tween()
	var init = (%Vignette.material as ShaderMaterial).get_shader_parameter("vignette_strength")
	t.tween_method(set_vignette_strength,init,strength,1.0)

func disable_all_exits():
	super_scrap.disabled = true
	%Exit.disabled = true

func set_vignette_strength(value : float):
	(%Vignette.material as ShaderMaterial).set_shader_parameter("vignette_strength",value)

func get_user_name() -> String:
	var username : String
	if OS.has_environment("USERNAME"):
		username = OS.get_environment("USERNAME")
	else:
		username = "Player"
	return username
