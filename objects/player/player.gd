extends KinematicBody

export(float) var run_speed = 100.0
export(float) var jump_strength = 4.0

var camera : Spatial = null
var offset_angle : float = 0

var map = null

var motion = Vector3(0, 0, 0)
var previous_position = Vector3(0, 0, 0)

var dead = false

onready var model = $Robot

func _ready():
	set_process_unhandled_input(true)

# Player control

var direction : Vector2 = Vector2(0, 0)
var next_action : int = 0
var keyboard_controls : bool = false

const ACTION_NONE     = 0
const ACTION_JUMP     = 1
const ACTION_PUNCH    = 2
const ACTION_THUMBSUP = 3
const ACTION_DANCE    = 4

func set_keyboard_controls(b):
	keyboard_controls = b

func input_keyboard_controls():
	direction = Vector2(0, 0)
	if Input.is_action_pressed("ui_up"):
		direction.y += run_speed
	if Input.is_action_pressed("ui_down"):
		direction.y -= run_speed
	if Input.is_action_pressed("ui_left"):
		direction.x -= run_speed
	if Input.is_action_pressed("ui_right"):
		direction.x += run_speed
	if Input.is_action_just_pressed("jump"):
		next_action = ACTION_JUMP
	elif Input.is_action_just_pressed("punch"):
		next_action = ACTION_PUNCH
	elif Input.is_action_just_pressed("dance"):
		next_action = ACTION_DANCE
	elif Input.is_action_just_pressed("thumbsup"):
		next_action = ACTION_THUMBSUP

func set_camera(c, oa = 0):
	camera = c
	offset_angle = oa

func _physics_process(delta):
	motion.y += -9.8*delta
	move_and_slide(motion, Vector3(0, 1, 0))
	if global_transform.origin.y < -10:
		kill()
	if keyboard_controls:
		input_keyboard_controls()
	var corrected_direction = direction
	if corrected_direction.length() > run_speed:
		corrected_direction /= corrected_direction.length()
		corrected_direction *= run_speed
	if camera != null:
		var camera_vector : Vector3 = camera.global_transform.basis.xform(Vector3(1, 0, 0))
		var camera_rotation : float = Vector2(camera_vector.z, camera_vector.x).angle()
		if !is_nan(camera_rotation):
			corrected_direction = corrected_direction.rotated(camera_rotation+offset_angle)
	var h_motion_influence = delta
	if is_on_floor():
		h_motion_influence *= 10.0
		motion.y = 0
		match next_action:
			ACTION_JUMP:
				motion.y = jump_strength
			ACTION_DANCE:
				model.anim("Robot_Dance")
			ACTION_PUNCH:
				model.anim("Robot_Punch")
			ACTION_THUMBSUP:
				model.anim("Robot_ThumbsUp")
	var h_motion = Vector2(motion.z, motion.x)
	h_motion.x = lerp(h_motion.x, corrected_direction.x, h_motion_influence)
	h_motion.y = lerp(h_motion.y, corrected_direction.y, h_motion_influence)
	if (previous_position-translation).length()/delta > 0.2:
		model.anim("Robot_Running")
		rotation.y = h_motion.angle()
	elif next_action == ACTION_NONE and model.get_current_anim() in [ "", "Robot_Running" ]:
		model.anim("Robot_Idle")
	previous_position = translation
	motion.z = h_motion.x
	motion.x = h_motion.y
	next_action = ACTION_NONE

func kill():
	if dead == false:
		dead = true
		set_physics_process(false)
		#model.anim("Die")
		$RespawnTimer.start()

func _on_RespawnTimer_timeout():
	transform = get_node("../Respawn").transform
	set_physics_process(true)
	dead = false

func _unhandled_input(event):
	# Quest controls
	if event is InputEventJoypadButton:
		if ! event.pressed:
			return
		match event.device:
			0:
				match event.button_index:
					7:
						next_action = ACTION_DANCE
					1:
						next_action = ACTION_THUMBSUP
					_:
						print(event.button_index)
			1:
				match event.button_index:
					7:
						next_action = ACTION_JUMP
					1:
						next_action = ACTION_PUNCH
					_:
						print(event.button_index)
	elif event is InputEventJoypadMotion:
		match event.device:
			0:
				match event.axis:
					0:
						direction.y = event.axis_value*run_speed
					1:
						direction.x = -event.axis_value*run_speed
				print(direction)
