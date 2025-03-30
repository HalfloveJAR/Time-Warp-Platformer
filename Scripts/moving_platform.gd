extends AnimatableBody2D

enum PathSetting { LOOP, REVERSE }

@onready var marker_one = $Marker2D
@onready var marker_two = $Marker2D2

var children = []
var total_markers: int
var current_target = 0
@export var speed = 100
@export var path_setting: PathSetting = PathSetting.LOOP

var forward = true

func _ready() -> void:
	for child in self.get_children():
		if child is Marker2D:
			children.append(child)
	total_markers = children.size()

func _physics_process(delta: float) -> void:
	
	if path_setting == PathSetting.LOOP:
		loop_pathing(delta)
	elif path_setting == PathSetting.REVERSE:
		reverse_pathing(delta)

func compare_vectors(v1: Vector2, v2: Vector2) -> bool:
	return abs(v1.x - v2.x) <= 1.0 and abs(v1.y - v2.y) <= 1.0

func reverse_pathing(delta: float) -> void:
	var g_pos = global_position.floor()
	var marker = children[current_target]
	var target_pos = marker.global_position.floor()

	if !compare_vectors(g_pos, target_pos):
		global_position += global_position.direction_to(marker.global_position) * speed * delta
		return
	
	var at_end: bool = current_target >= total_markers - 1
	var at_start: bool = current_target <= 0
	
	if forward:
		forward = !at_end
		current_target += 1 if !at_end else 0
	else:
		forward = at_start
		current_target -= 1 if !at_start else 0


func loop_pathing(delta: float) -> void:
	var g_pos = global_position.floor()
	var marker = children[current_target]
	var target_pos = marker.global_position.floor()
	
	if compare_vectors(g_pos, target_pos):
		current_target = (current_target + 1) % total_markers
		return
	
	global_position += global_position.direction_to(marker.global_position) * speed * delta
