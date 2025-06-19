extends RayCast2D

@export var start_casting = true

var _is_casting := false # Internal variable for the actual state

# Tutorial for this stuff
# https://www.youtube.com/watch?v=dg0CQ6NPDn8
var is_casting := false: # This is now just a property that uses the internal variable
	set(value):  # Custom setter
		set_is_casting(value)
	get:          # Custom getter (optional)
		return _is_casting # Return the internal variable

func _ready() -> void:
	if (start_casting):
		set_physics_process(true)
		$Line2D.visible = true
	else:
		set_physics_process(false)
		$Line2D.points[1] = Vector2.ZERO
		$Line2D.visible = false

func _physics_process(delta: float) -> void:
	var cast_point := target_position
	force_raycast_update()

	if is_colliding():
		cast_point = to_local(get_collision_point())
		var object_hit = get_collider()
		if (object_hit.is_in_group("player")):
			object_hit.respawn()

	$Line2D.points[1] = cast_point

func set_is_casting(cast: bool) -> void:
	# Set the internal variable directly, without triggering the custom setter again
	_is_casting = cast
	set_physics_process(_is_casting)
	$Line2D.visible = _is_casting

func toggle_trigger():
	self.is_casting = !self.is_casting

func appear() -> void:
	var tween := create_tween()
	pass

func disappear() -> void:
	pass

func _on_timer_timeout() -> void:
	toggle_trigger()
