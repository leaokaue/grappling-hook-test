extends TextureButton
class_name SGGateItem

signal picked_up(int)

signal released(Vector2)

@export var darken : float = 0.9

@onready var dark : Color = Color(darken,darken,darken)

@export var object := Global.EQUIPMENTS.DashBoots

@export var label : Label

@export var hide_completely : bool = false

#@export var behind : TextureRect

@export var bg : TextureRect

@onready var init_pos : Vector2 = self.position
@onready var init_rot : float = self.rotation

@export_category("Audio")
@export var pick_noise : AudioStream
@export var drop_noise : AudioStream
@export var sound : AudioStreamPlayer

var mouse_offset : Vector2
var currently_pressed : bool = false

func _ready() -> void:
	get_label()
	
	if not has_item():
		get_parent().hide()
	
	if not Global.can_switch_equipments:
		disabled = true
		self.modulate *= 0.6
		return
	mouse_entered.connect(on_mouse_enter)
	mouse_exited.connect(on_mouse_exit)
	button_down.connect(on_clicked)
	button_up.connect(on_release)

func _physics_process(_delta: float) -> void:
	if currently_pressed:
		self.global_position = get_global_mouse_position() - mouse_offset

func on_mouse_enter():
	self.modulate = dark

func on_mouse_exit():
	self.modulate = Color(1.0,1.0,1.0)

func on_clicked():
	z_index += 1
	get_mouse_offset()
	currently_pressed = true
	rotation += deg_to_rad(randf_range(-10,10))
	self.modulate = Color(1.0,1.0,1.0)
	picked_up.emit(object)

func on_release():
	z_index -= 1
	currently_pressed = false
	self.rotation = init_rot
	self.position = init_pos
	released.emit(self)

func get_mouse_offset():
	mouse_offset = (get_global_mouse_position() - global_position)

func item_hide():
	self.hide()
	self.label.hide()

func item_show():
	self.show()
	self.label.show()

func get_label():
	for c in get_parent().get_children():
		if c is Label:
			label = c

func has_item() -> bool:
	var a := Global.EQUIPMENTS
	match object:
		a.DashBoots:
			if Global.has_dash_boots:
				return true
			else:
				return false
		a.Tambaqui:
			if Global.has_tambaqui:
				return true
			else:
				return false
		a.HoverStone:
			if Global.has_hover_stone:
				return true
			else:
				return false
		a.Jetpack:
			if Global.has_jetpack:
				return true
			else:
				return false
		a.ErrorCube:
			if Global.has_error_cube:
				return true
			else:
				return false
	return false
