extends Line2D
class_name LineTrail2D

@export var active : bool = true

@onready var line_point := Node2D.new()

@onready var curve : Curve2D = Curve2D.new()

@export var max_points : int = 60

@export var max_line_deletal : int = 5

var follow_player : bool = false

var fading_away : bool = false

func _ready() -> void:
	self.top_level = true
	
	self.clear_points()
	self.add_sibling.call_deferred(line_point)
	self.line_point.position = self.position

func _process(_delta: float) -> void:
	manage_curve_points()
	
	if follow_player and is_instance_valid(Global.player):
		self.line_point.position = Global.player.global_position
	
	if fading_away:
		self.modulate.a = move_toward(self.modulate.a,0.0,_delta * 1.3)
		if self.modulate.a <= 0.0:
			line_point.queue_free()
			self.queue_free()
	
	
	clean_curve_ponts()

func manage_curve_points():
	if active:
#		print(curve.get_baked_points().size())
		curve.add_point(line_point.global_position - self.global_position)
		#if points.size() > 0:
			#print(line_point.global_position, " ", self.points[clampi(points.size() - 1,0,600)], " ",self.global_position)
		#print(self.global_position)
		
		if curve.get_baked_points().size() > max_points:
			curve.remove_point(0)
		
		self.points = curve.get_baked_points()

func clean_curve_ponts():
	if not active:
		for n in max_line_deletal:
			if self.points.size() > 0:
				self.remove_point(0)
