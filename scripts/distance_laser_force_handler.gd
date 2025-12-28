extends Node2D

@export var laser : TerminusLaser

@export var min_force : float = 200

@export var max_force : float = 500

@export var min_distance : float = 1000

@export var max_distance : float = 8000

func _physics_process(_delta: float) -> void:
	if laser:
		var dist : float = (Global.player.global_position - self.global_position).length()
		dist = clampf(dist,min_distance,max_distance)
		var x : float = (dist - min_distance) / (max_distance - min_distance)
		x = clampf(x,0.0,1.0)
		var product : float = min_force + ((max_force - min_force) * x)
		laser.cube_move_force = product
		#print(laser.cube_move_force)
