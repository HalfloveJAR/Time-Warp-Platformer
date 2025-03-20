extends Node2D

const levels = [
	preload("res://Scenes/Placeholder Scenes/level.tscn"),
	preload("res://Scenes/Placeholder Scenes/level_2.tscn")
	]

var current_level = 0
var final_level = levels.size()

func _ready():
	get_tree().change_scene_to_packed(levels[current_level])

func next_level():
	current_level += 1
	if (final_level >= current_level):
		get_tree().change_scene_to_packed(levels[current_level])
	else:
		print("No more levels")
