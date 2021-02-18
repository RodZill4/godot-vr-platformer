extends Spatial


var perform_runtime_config = false

onready var ovr_init_config
onready var ovr_performance

func _ready():
	var interface = ARVRServer.find_interface("OVRMobile")
	if interface:
		ovr_init_config = preload("res://addons/godot_ovrmobile/OvrInitConfig.gdns").new()
		ovr_init_config.set_render_target_size_multiplier(1)
		if interface.initialize():
			get_viewport().arvr = true
		ovr_performance = preload("res://addons/godot_ovrmobile/OvrPerformance.gdns").new()
		$Player.set_camera($ARVROrigin/ARVRCamera, -0.5*PI)
		$Player.set_keyboard_controls(false)
		$ARVROrigin/ARVRCamera.current = true
		$Camera.queue_free()
	else:
		$Camera.current = true
		$Player.set_camera($Camera)
		$Player.set_keyboard_controls(true)
		$ARVROrigin.queue_free()
		set_process(false)

func _process(_delta):
	if not perform_runtime_config:
		ovr_performance.set_clock_levels(1, 1)
		ovr_performance.set_extra_latency_mode(1)
		perform_runtime_config = true
