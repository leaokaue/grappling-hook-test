extends CanvasLayer
class_name SecretZoneTransition

signal container_finished

signal label_finished

var secret_zone_scene_path : StringName = "res://scenes/3d/secret_zone.tscn"

var secret_zone : PackedScene

var final_area_scene_path : StringName  = "res://scenes/finality_main.tscn"

var final_area : PackedScene

var purified : bool = false

@export var label_containers : Array[VBoxContainer]

@export var purified_containers : Array[VBoxContainer]

var current_label : Label

var processing_label : bool = false

var key_count : int = 0

var key_speed : int = 3

var wps : float = 20

var wpt : int = 1

var time_to_key : float = 0

func _ready() -> void:
	show_and_decrease_labels()
	AudioServer.set_bus_volume_linear(0,1.0)
	if Global.purified:
		%Invert.show()
		start_purified_sequence()
	else:
		start_sequence()
	
	load_next_scene()

func load_next_scene():
	if not Global.purified:
		ResourceLoader.load_threaded_request(secret_zone_scene_path)
	else:
		ResourceLoader.load_threaded_request(final_area_scene_path)

func _process(delta: float) -> void:
	if current_label:
		if current_label.visible_ratio >= 1.0:
			if processing_label:
				processing_label = false
				label_finished.emit()
		time_to_key += delta
		#print(time_to_key)
		if time_to_key >= ((wps / 60) / 10):
			if current_label:
				if ((current_label.visible_characters + wpt) > current_label.get_total_character_count()):
					current_label.visible_ratio = 1.0
				else:
					current_label.visible_characters += wpt
			time_to_key = 0
			%KeyPress.stop()
			%KeyPress.play(0.0)

func show_and_decrease_labels():
	for c in label_containers:
		for child in c.get_children():
			if child is Label:
				child.show()
				child.visible_characters = 0
	for c in purified_containers:
		for child in c.get_children():
			if child is Label:
				child.show()
				child.visible_characters = 0

func handle_container(container : VBoxContainer, delay : float = 1.0,line_delay : float = 0.5):
	await get_tree().create_timer(delay,false).timeout
	
	var labels : Array[Label]
	
	container.show()
	
	var leftover_containers : Array[VBoxContainer ] = label_containers.duplicate() + purified_containers.duplicate()
	leftover_containers.erase(container)
	
	for c in leftover_containers:
		c.hide()
	
	for c in container.get_children():
		if c is Label:
			c.visible_characters = 0
			labels.append(c)
	
	for l in labels:
		current_label = l
		processing_label = true
		await label_finished
		current_label = null
		await get_tree().create_timer(line_delay,false).timeout
	
	container_finished.emit()

func start_sequence():
	handle_container(label_containers[0])
	
	await container_finished
	
	handle_container(label_containers[1])
	
	await container_finished
	
	handle_container(label_containers[2])
	
	await  container_finished
	
	handle_container(label_containers[3])
	
	await  container_finished
	
	for i in range(30):
		
		var modifier : float = 1.0 / (10.0 / (10 - i) + 10)
		var delay : float = 0.8 * modifier
		var line_delay : float = 0.4 * modifier
		wps = 18.0 - (i * 2.0)
		if i >= 10:
			modifier = 0.0
			delay = 0.0
			line_delay = 0.0
			wps = 2.0
			wpt = (i - 10)
			wpt = clampi(wpt,1,1000)
			print(wpt)
		#if i >= 15:
			#wpt = 2
		%KeyPress.pitch_scale = 1.0 - (i / 30.0)
		#if i < 3:
			#key_speed = 2
		#elif i < 6:
			#key_speed = 1
		#elif i < 9:	
			#key_speed = 0
		#else:
			#key_speed = 3
		
		#print("loop ",i," modifier ",modifier," delay ", delay," line delay ", line_delay," wps ", wps)
		
		handle_container(label_containers[2],delay,line_delay)
		await container_finished
		
		handle_container(label_containers[3],delay,line_delay)
		await container_finished
	
	%KeyPress.pitch_scale = 1.0
	wps = 20
	wpt = 1
	
	handle_container(label_containers[4],2.0)
	await container_finished
	
	handle_container(label_containers[5],2.0)
	await container_finished
	
	go_to_secret_zone()

func start_purified_sequence():
	handle_container(purified_containers[0])
	
	await container_finished
	
	handle_container(purified_containers[1],2.0)
	
	await container_finished
	
	await get_tree().create_timer(2.0,false).timeout
	
	go_to_final_area()

func go_to_secret_zone():
	reparent_ui()
	
	var p := ResourceLoader.load_threaded_get(secret_zone_scene_path)
	get_tree().change_scene_to_packed(p)

func go_to_final_area():
	reparent_ui()
	
	Global.is_in_finality = true
	
	var p := ResourceLoader.load_threaded_get(final_area_scene_path)
	get_tree().change_scene_to_packed(p)

func reparent_ui():
	var i := %Invert
	var d := %Dark
	var l := %LabelContainer6
	var p := %LabelPurified2
	d.reparent(get_tree().root)
	l.reparent(get_tree().root)
	i.reparent(get_tree().root)
	p.reparent(get_tree().root)
	var c := func():
		d.free()
		p.free()
		l.free()
		i.free()
	var t := get_tree().create_tween()
	t.tween_interval(1.0)
	t.tween_callback(c)
