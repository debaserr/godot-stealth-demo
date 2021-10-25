extends KinematicBody2D

export (int) var detect_radius
export var FOV = 90

export var ACCELERATION = 500
export var MAX_SPEED = 100

const RAY_COLOR_HIT = Color(.9, .1, .1, .9)
const RAY_COLOR_MISS = Color(.1, .9, .1, .9)
const FOV_COLOR_NEUTRAL = Color(.3, .3, .3, .3)
const FOV_COLOR_DETECTED = Color(.8, .2, .2, .3)

onready var animationPlayer = $AnimationPlayer
onready var collisionPolygon2D = $Visibility/CollisionPolygon2D
onready var nav = get_tree().get_root().find_node("Navigation2D", true, false)

var facing = Vector2.ZERO
var sees_player = false
var angleToPlayer = 0
var target
var hit_pos
var path

func _ready():
	facing = Vector2.UP
	var shape = CircleShape2D.new()
	shape.radius = detect_radius
	$Visibility/CollisionShape2D.shape = shape
	animationPlayer.play("Idle")

func _physics_process(delta):
	update()
	sees_player = false
	if target != null:
		var vectorToPlayer = target.position - position
		angleToPlayer = rad2deg(acos(vectorToPlayer.normalized().dot(facing)))
		if angleToPlayer < FOV / 2:
			var space_state = get_world_2d().direct_space_state
			var result = space_state.intersect_ray(position, target.position, [self], collision_mask)
			if result:
				hit_pos = result
				if result.collider.name == "Player":
					sees_player = true
					facing = position.direction_to(target.position)
					look_at(target.position)
					path = nav.get_simple_path(position, target.position)
			else:
				hit_pos = null
	collisionPolygon2D.rotation_degrees = rotation_degrees
#	if path != null:
#		var distanceToMove = MAX_SPEED * delta
#		while distanceToMove > 0 && path.size() > 0:
#			var distanceToNextPoint = position.distance_to(path[0])
#			if distanceToMove <= distanceToNextPoint:
#				position += position.direction_to(path[0]) * distanceToMove
#			else:
#				position = path[0]
#				path.remove(0)
#			distanceToMove -= distanceToNextPoint

func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)

func _draw():
	var fov_color = FOV_COLOR_NEUTRAL
	var ray_color = RAY_COLOR_MISS
	if sees_player:
		fov_color = FOV_COLOR_DETECTED
		ray_color = RAY_COLOR_HIT	
	if hit_pos:
		var v = (hit_pos.position - position)
		draw_line(Vector2.ZERO, v, ray_color)
		
	# draw_circle_arc_poly(Vector2.ZERO, detect_radius, -(FOV / 2), (FOV / 2), fov_color)

func _on_Visibility_body_entered(body):
	if target != null:
		return
	target = body

func _on_Visibility_body_exited(body):
	if body == target:
		target = null
