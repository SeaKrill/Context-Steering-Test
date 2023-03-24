extends KinematicBody2D

var dir = Vector2.ZERO
var speed = 100

func _physics_process(delta):
	dir = get_local_mouse_position()
	
		
	var input_vector = Vector2(
		Input.get_action_strength("Right") - Input.get_action_strength("Left"),
		Input.get_action_strength("Down") - Input.get_action_strength("Up")
	)
	
	_update_movement(input_vector, input_vector)
	
func cartesian_to_isometric(cartesian):
	return Vector2(cartesian.x - cartesian.y, (cartesian.x + cartesian.y) / 2)
	
func _update_movement(_move_direction, _input_vector):
	if _input_vector.x != 0 and _input_vector.y != 0:
		if _input_vector.x > 0 and _input_vector.y < 0 or _input_vector.x < 0 and _input_vector.y > 0:
			var _slide = move_and_slide(cartesian_to_isometric(Vector2(0, _move_direction.y) * speed))
		else:
			var _slide = move_and_slide(cartesian_to_isometric(Vector2(_move_direction.x, 0) * speed))
	else:
		var _slide = move_and_slide(_move_direction * speed)
