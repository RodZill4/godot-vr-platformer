extends Spatial

onready var animation_player : AnimationPlayer = $AnimationPlayer

func _ready():
	pass

func anim(a):
	if animation_player.current_animation != a:
		animation_player.play(a)

func get_current_anim() -> String:
	return animation_player.current_animation if animation_player.playback_active else ""
