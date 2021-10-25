extends CollisionPolygon2D

export (int) var detect_radius
export var FOV = 90

# Called when the node enters the scene tree for the first time.
func _ready():
	set_poly(Vector2.ZERO, detect_radius, -(FOV / 2), (FOV / 2))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_poly(center, radius, angle_from, angle_to):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	set_polygon(points_arc)
