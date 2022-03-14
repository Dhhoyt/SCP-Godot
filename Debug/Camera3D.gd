extends Camera3D

@export var normal_speed = 10
@export var run_speed = 50
@export var sensitivity : float = 0.2

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotation.y -= deg2rad(event.relative.x * sensitivity)
		rotation.x -= deg2rad(event.relative.y * sensitivity)
		rotation.x = clamp(rotation.x, -PI/2, PI/2)

func _process(delta):
	if Input.is_action_just_pressed("player_pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var speed2d = Input.get_vector("player_up", "player_down", "player_left", "player_right").rotated(PI/2)
	var speed = Vector3(-speed2d.x, 0, speed2d.y) * global_transform.basis.inverse()
	var temp_speed
	if Input.is_action_pressed("player_run"):
		temp_speed = run_speed
	else:
		temp_speed = normal_speed
	global_transform.origin += speed * temp_speed * delta
