extends Node

@onready var TileLayerBlue = $Floor1_Blue
@onready var TileLayerGreen = $Floor2_Green
@onready var player = $"../Player"

var HiddenLayer = 2

func _ready():
	set_layer(HiddenLayer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("Swap Layer")):
		if (HiddenLayer == 1):
			set_layer(2)
		else:
			set_layer(1)

func set_layer(layer: int) -> void:
	if (layer == 1):
		HiddenLayer = 1
		TileLayerGreen.visible = true
		TileLayerBlue.visible = false
		TileLayerBlue.collision_enabled = false
		TileLayerGreen.collision_enabled = true
		
		for node in $"../Hazards".get_children():
			if node.is_in_group("Blue"):
				node.visible = false
				if node.get_child(1) != null:
					node.get_child(1).disabled = true
				elif node.is_in_group("Laser"):
					node.set_is_casting(false)
			if node.is_in_group("Green"):
				node.visible = true
				if node.get_child(1) != null:
					node.get_child(1).disabled = false
				elif node.is_in_group("Laser"):
					node.set_is_casting(true)
		
		print("Blue layer now hidden")
	else:
		HiddenLayer = 2
		TileLayerGreen.visible = false
		TileLayerBlue.visible = true
		TileLayerBlue.collision_enabled = true
		TileLayerGreen.collision_enabled = false
		
		for node in $"../Hazards".get_children():
			if node.is_in_group("Blue"):
				node.visible = true
				if node.get_child(1) != null:
					node.get_child(1).disabled = false
				elif node.is_in_group("Laser"):
					node.set_is_casting(true)
			if node.is_in_group("Green"):
				node.visible = false
				if node.get_child(1) != null:
					node.get_child(1).disabled = true
				elif node.is_in_group("Laser"):
					node.set_is_casting(false)
		
		print("Green layer now hidden")
