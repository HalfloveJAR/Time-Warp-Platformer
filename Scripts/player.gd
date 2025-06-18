extends CharacterBody2D

var can_jump = true
var can_start_coyote_time = true
var jump_buffer = false

var camera_bounds_set = false

@onready var death_pos = self.position
@onready var checkpoint = $"../checkpoint"
@onready var coyote_time = $CoyoteTime
@onready var coyote_label = $"../DebugUI/Coyote"
@onready var floor_label = $"../DebugUI/Floor"
@onready var stuck_label = $"../DebugUI/Stuck"
@onready var tilemap_controller = $"../TileMapController"
@onready var camera_bounds: CollisionShape2D = $"../CameraBounds/CollisionShape2D"
@onready var camera = $Camera2D

@export var accel = 90.0
@export var decel = 180.0
@export var max_speed = 220.0
@export var jump_velocity = -315.0
@export var jump_buffer_time = 0.1
@export var coyote_time_val = 0.07
@export var checkpoints_available = 1

func _process(_delta: float) -> void:
	if floor_label == null or stuck_label == null:
		return
	if not is_on_floor():
		floor_label.text = "On floor = false"
		if is_player_stuck():
			stuck_label.text = "Stuck = true"
			respawn()
		else:
			stuck_label.text = "Stuck = false"
	else:
		floor_label.text = "On floor = true"

func _physics_process(delta: float) -> void:
	#coyote_label.text = "Coyote Time: " + str(coyote_time.time_left)
	
	if camera_bounds_set == false: set_camera_bounds()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if coyote_time.is_stopped() and can_start_coyote_time:
			coyote_time.start(coyote_time_val)
			can_start_coyote_time = false
			#print("Timer started")
	else:
		can_jump = true
		can_start_coyote_time = true
		if jump_buffer:
			jump()
			jump_buffer = false

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		if can_jump:
			jump()
		else:
			jump_buffer = true
			get_tree().create_timer(jump_buffer_time).timeout.connect(_on_jump_buffer_timeout)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * max_speed, accel)
	# Slow down and stop
	else:
		velocity.x = move_toward(velocity.x, 0, decel)

	move_and_slide()
	
	if self.position.y > 300:
		respawn()
	
	if Input.is_action_just_pressed("Spawn Checkpoint"):
		spawn_checkpoint()

func jump() -> void:
	velocity.y = jump_velocity
	can_jump = false

func respawn() -> void:
	tilemap_controller.set_layer.call_deferred(2) # Reset current floor layer to default
	self.position = death_pos

func spawn_checkpoint() -> void:
	if (!self.is_on_floor):
		return
	if (checkpoints_available > 0):
		checkpoint.position = self.position
		checkpoints_available -= 1
		print("Spawned a checkpoint")
	else:
		print("You don't have available checkpoints")

func set_camera_bounds() -> void:
	camera_bounds = get_node_or_null("../CameraBounds/CollisionShape2D")
	if camera_bounds != null:
		var pos = camera_bounds.get_parent().global_position
		var width = camera_bounds.shape.size.x
		var height = camera_bounds.shape.size.y
		var top = pos.y - (height/2) 
		var bot = pos.y + (height/2) 
		var left = pos.x - (width/2)
		var right = pos.x + (width/2)
		camera.limit_top = top
		camera.limit_bottom = bot
		camera.limit_left = left
		camera.limit_right = right
		camera_bounds_set = true

func _on_coyote_time_timeout() -> void:
	can_jump = false

func _on_jump_buffer_timeout() -> void:
	jump_buffer = false

func is_player_stuck():
	var tilemap: TileMapLayer
	if $"../TileMapController".HiddenLayer == 2:
		tilemap = $"../TileMapController/Floor1_Blue"
	else:
		tilemap = $"../TileMapController/Floor2_Green"
	
	if not tilemap: # Checks if TileMap is null, kind of redundant
		return false 

	# Convert player's position to tilemap coordinates
	var tile_pos = tilemap.local_to_map(global_position)
	#print(str(global_position) + " -> " + str(tile_pos))
	
	# Get the tile data at that position
	var tile_data = tilemap.get_cell_tile_data(tile_pos)
	
	if tile_data:
		# Check if the tile has the "solid" physics layer set
		return tile_data.get_collision_polygons_count(0) > 0
		
	return false
