extends AnimatableBody2D

@onready var marker_one = $Marker2D
@onready var marker_two = $Marker2D2

var current_target = 1
@export var speed = 50

func compare_vectors(v1: Vector2, v2: Vector2) -> bool:
	return abs(v1.x - v2.x) <= 1.0 and abs(v1.y - v2.y) <= 1.0

func _physics_process(delta: float) -> void:
	var g_pos = global_position.floor()
	var m1_pos = marker_one.global_position.floor()
	var m2_pos = marker_two.global_position.floor()
	
	#print(str(g_pos) + "; " + str(m1_pos) + "; " + str(m2_pos))
	
	if compare_vectors(g_pos, m1_pos) && current_target == 1:
		current_target = 2
	elif compare_vectors(g_pos, m2_pos) && current_target == 2:
		current_target = 1
	
	if !compare_vectors(g_pos, m1_pos) && current_target == 1:
		global_position += global_position.direction_to(marker_one.global_position) * speed * delta
	elif current_target == 2:
		global_position += global_position.direction_to(marker_two.global_position) * speed * delta


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		pass
	print(str(body))
