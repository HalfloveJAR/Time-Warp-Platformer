extends AnimatableBody2D

enum PathSetting { LOOP, REVERSE }

@onready var marker_one = $Marker2D
@onready var marker_two = $Marker2D2

var children = []
var total_markers: int
var current_target = 0
var default_speed
var padding = 1.0
@export var speed = 100
@export var unloaded_speed_multiplier = 2
@export var path_setting: PathSetting = PathSetting.LOOP

var forward = true

func _ready() -> void:
	default_speed = speed
	speed *= unloaded_speed_multiplier
	padding *= unloaded_speed_multiplier
	for child in self.get_children():
		if child is Marker2D:
			children.append(child)
	total_markers = children.size()

func _physics_process(delta: float) -> void:
	if path_setting == PathSetting.LOOP:
		loop_pathing(delta)
	elif path_setting == PathSetting.REVERSE:
		reverse_pathing(delta)


func reverse_pathing(delta: float) -> void:
	var g_pos = global_position.floor()
	var marker = children[current_target]
	var target_pos = marker.global_position.floor()

	if !SceneManager.compare_vectors(g_pos, target_pos, padding):
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
	
	if SceneManager.compare_vectors(g_pos, target_pos, padding):
		current_target = (current_target + 1) % total_markers
		return
	
	global_position += global_position.direction_to(marker.global_position) * speed * delta

# Entered viewport
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	print(self.name, " slowing down from: ", speed, " to: ", default_speed)
	speed = default_speed
	padding = 1.0

# Left viewport
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	var new_speed = speed * unloaded_speed_multiplier
	print(self.name, " speeding up from: ", speed, " to: ", new_speed)
	speed = new_speed
	padding *= unloaded_speed_multiplier
