extends KinematicBody2D

export var max_speed = 80

export var num_rays = 8
export var look_ahead = 50

var interest = []
var danger = []

var rays = []
var lines = []

onready var target = global_position
var target_offset = Vector2.ZERO
var offset = Vector2.ZERO
var player = Vector2.ZERO

var dir_line = Line2D.new()
var sight = RayCast2D.new()
var sight_line = RayCast2D.new()

func _ready():
	randomize()
	interest.resize(num_rays)
	danger.resize(num_rays)

	for i in num_rays:
		var _ray = RayCast2D.new()
		add_child(_ray)
		rays.append(_ray)
		_ray.enabled = true

		var angle = i * 2 * PI / num_rays
		var cartesian = Vector2(cos(angle), sin(angle)) * look_ahead
		var isometric = Vector2(cartesian.x - cartesian.y, (cartesian.x + cartesian.y) / 2)
		_ray.cast_to = isometric * -1

		var _line = Line2D.new()
		add_child(_line)
		lines.append(_line)
		_line.add_point(Vector2.ZERO, 0)
		_line.add_point((Vector2.RIGHT * look_ahead).rotated(angle), 1)
		_line.width = 2
	
	add_child(sight)
	sight.enabled = true
	
	add_child(sight_line)
	sight.enabled = true
	
	add_child(dir_line)
	dir_line.add_point(Vector2.ZERO, 0)
	dir_line.add_point(Vector2.ZERO, 1)
	dir_line.default_color = "fdff00"
	dir_line.width = 2

func _physics_process(delta):
	_get_target()
	
	_set_interest()
	_set_danger()
	var dir = _choose_dir()
	if Vector2(round(target.x), round(target.y)) == Vector2(round(global_position.x), round(global_position.y)):
		dir = Vector2.ZERO
	move_and_slide(dir * max_speed)

func _get_target():
	player = get_parent().get_node("B").global_position
	
	if player.distance_to(global_position) < 1000:
		sight_line.cast_to = player - global_position
		if !sight.is_colliding():
			target = player
			offset = (target - global_position).tangent().normalized() * 100
			
			target_offset = target + offset
		
		else:
			target = target_offset
			sight_line.cast_to = target - global_position
			
			var _origin = global_position
			var _target = target_offset - global_position
			
			dir_line.set_point_position(0, player - global_position)
			dir_line.set_point_position(1, target_offset - global_position)
			
	sight.cast_to = target - global_position

func cartesian_to_isometric(cartesian):
	return Vector2(cartesian.x - cartesian.y, (cartesian.x + cartesian.y) / 2)
	
	
func _set_interest():
	for i in num_rays:
		var normal = (target - global_position).normalized()
		var away_vector = rays[i].cast_to.normalized()
		var d = away_vector.dot(normal)
		interest[i] = max(0, d)

func _set_danger():
	for i in num_rays:
		if rays[i].is_colliding():
			var away_vector = rays[i].cast_to.normalized()
			var normal = (rays[i].get_collision_point() - global_position).normalized()
			var d = away_vector.dot(normal)
			danger[i] = d
		else:
			danger[i] = 0.0

		interest[i] = max(0, interest[i] - danger[i])

func _choose_dir():
	var chosen_dir = Vector2.ZERO
	for i in num_rays:
		chosen_dir += rays[i].cast_to * interest[i]

		if interest[i] > danger[i]:
			lines[i].set_point_position(1, rays[i].cast_to * Vector2(interest[i], interest[i]))
			lines[i].modulate = "ffffff"
		else:
			lines[i].set_point_position(1, rays[i].cast_to * Vector2(danger[i], danger[i]))
			lines[i].modulate = "ff0000"

#	dir_line.set_point_position(1, (Vector2.RIGHT * look_ahead).rotated(chosen_dir.angle()))
	return chosen_dir.normalized()
