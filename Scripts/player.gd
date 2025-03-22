extends CharacterBody2D

var can_jump = true
var can_start_coyote_time = true
var jump_buffer = false
@onready var death_pos = self.position
@onready var checkpoint = $"../checkpoint"
@onready var coyote_time = $CoyoteTime
@onready var coyote_label = $"../DebugUI/Coyote"
@onready var jump_label = $"../DebugUI/JumpBuffer"
@onready var tilemap_controller = $"../TileMapController"

@export var accel = 90.0
@export var decel = 180.0
@export var max_speed = 220.0
@export var jump_velocity = -315.0
@export var jump_buffer_time = 0.1
@export var coyote_time_val = 0.07
@export var checkpoints_available = 1

func _physics_process(delta: float) -> void:
	coyote_label.text = "Coyote Time: " + str(coyote_time.time_left)
	# Add the gravity.
	if not is_on_floor():
		jump_label.text = "On Floor: False"
		velocity += get_gravity() * delta
		if coyote_time.is_stopped() and can_start_coyote_time:
			coyote_time.start(coyote_time_val)
			can_start_coyote_time = false
			#print("Timer started")
	else:
		jump_label.text = "On Floor: True"
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
	# Get highest value checkpoint
	# Set health to max health
	# Set location to highest val checkpoint
	tilemap_controller.set_layer.call_deferred(2)
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


func _on_coyote_time_timeout() -> void:
	can_jump = false

func _on_jump_buffer_timeout() -> void:
	jump_buffer = false
