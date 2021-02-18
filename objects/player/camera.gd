extends Camera

export(float) var align = 0

func _ready():
	pass

func _physics_process(delta):
	var player = get_node("../Player")
	if player != null:
		var direction = player.translation - translation
		var h_direction = Vector2(direction.x, direction.z)
		rotation.y = -0.5*PI - h_direction.angle()
		h_direction = 2*(h_direction.length() - 1) * h_direction.normalized()
		var v_direction = 4.0*(direction.y + 1)
		translation += delta * Vector3(h_direction.x, v_direction, h_direction.y)
		if align != 0:
			var round_position = Vector3(align*round(translation.x/align), translation.y, align*round(translation.z/align))
			translation += delta * (round_position - translation)
