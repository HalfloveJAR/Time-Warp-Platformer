extends Area2D

@onready var marker_one = $MoveMarkers/Marker2D
@onready var marker_two = $MoveMarkers/Marker2D2

var current_target = 1
@export var speed = 50

func _physics_process(delta: float) -> void:
	var g_pos = global_position.floor()
	var m1_pos = marker_one.global_position.floor()
	var m2_pos = marker_two.global_position.floor()
	
	if g_pos == m1_pos:
		current_target = 2
	elif g_pos == m2_pos:
		current_target = 1
	
	if g_pos != m1_pos && current_target == 1:
		global_position += global_position.direction_to(marker_one.global_position) * speed * delta
	elif current_target == 2:
		global_position += global_position.direction_to(marker_two.global_position) * speed * delta
