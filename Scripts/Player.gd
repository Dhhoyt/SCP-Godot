extends CharacterBody3D

@export var sensitivity : float = 0.2
@export var friction : float = 50

@export var air_coeff : float = 0.25

@export var max_walk_speed : float = 2
@export var walk_accel : float = 50

@export var max_run_speed : float = 4
@export var run_accel : float = 50

@export var max_stamina : float = 5
@export var stamina_recharge : float = 1

@export var slot_num = 10

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity_vector : Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
var gravity_magnitude : int = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var standing_height : float = $CollisionShape3D.get_shape().get_height()
@onready var cam_stand_height : float = $Camera3D.position.y
@onready var radius : float = $CollisionShape3D.get_shape().get_radius()
@onready var utils = get_node("/root/Utils")


var last = 0
var total = 0
var crouching : bool = false
var occupied = false
var current_stamina : float = max_stamina
var stamina_tolerance = 0.1
var ray_params = PhysicsRayQueryParameters3D.new()
var slots = []

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	utils.set_player(self)
	ray_params.exclude = [self]
	ray_params.collision_mask = 4294967295

func _physics_process(delta):
	if not is_on_floor():
		motion_velocity += (gravity_magnitude * delta) * gravity_vector
	var multiplier : float = 1
	if !is_on_floor():
		multiplier = air_coeff
	var move_accel : float
	var max_speed : float
	if Input.is_action_pressed("player_run") and current_stamina > stamina_tolerance and Input.get_vector("player_up", "player_down", "player_left", "player_right").length() > 0:
		move_accel = run_accel
		max_speed = max_run_speed
		current_stamina -= delta
		if current_stamina < stamina_tolerance:
			current_stamina = 0
	else:
		move_accel = walk_accel
		max_speed = max_walk_speed
		current_stamina = clamp(current_stamina + (delta * stamina_recharge), 0, max_stamina)
	apply_friction(delta, multiplier)
	var walkvector : Vector2 = walk(delta, move_accel, max_speed, multiplier)
	motion_velocity = Vector3(walkvector.x, motion_velocity.y, -walkvector.y)
	move_and_slide()
	
func _process(_delta):
	if Input.is_action_just_pressed("player_blink"):
		close_eyes()
	$UI/Stamina.text = str(current_stamina/max_stamina)
	$UI/BlinkMeter.text = str($EyesOpen.time_left)
	if Input.is_action_just_pressed("player_inv"):
		$Inventory.visible = not $Inventory.visible
		if $Inventory.visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	test_pickup()

func walk(delta, move_accel, max_speed, multiplier):
	var frame_accel = (move_accel + friction) * multiplier
	var new_walkvector : Vector2 = Vector2()
	new_walkvector.x += motion_velocity.x
	new_walkvector.y -= motion_velocity.z
	new_walkvector += frame_accel * delta * Input.get_vector("player_up", "player_down", "player_left", "player_right").rotated(rotation.y - PI/2)
	var walkvector : Vector2
	var old_walkvector : Vector2 = Vector2(motion_velocity.x, -motion_velocity.z)
	if new_walkvector.length() > max_speed:
		if old_walkvector.length() < max_speed:
			walkvector = new_walkvector.limit_length(max_speed)
		elif new_walkvector.length() < old_walkvector.length(): 
			walkvector = new_walkvector
		else:
			walkvector = old_walkvector
	else:
		walkvector = new_walkvector
	return walkvector

func apply_friction(delta, multiplier):
	var frame_friction : float = friction * multiplier
	var vel_2d : Vector2 = Vector2(motion_velocity.x, motion_velocity.z)
	var power : float = vel_2d.length()
	if power > frame_friction * delta:
		power -= frame_friction * delta
	else:
		power = 0
	vel_2d = vel_2d.normalized() * power
	motion_velocity.x = vel_2d.x
	motion_velocity.z = vel_2d.y
	
func _input(event):
	if event is InputEventMouseMotion and not $Inventory.visible:
		rotation.y -= deg2rad(event.relative.x * sensitivity)
		$Camera3D.rotation.x -= deg2rad(event.relative.y * sensitivity)
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x, -PI/3, PI/3)
		

func test_pickup():
	var space_state = get_world_3d().direct_space_state
	ray_params.from = $Camera3D.global_transform.origin
	ray_params.to = $Camera3D/Pickup.global_transform.origin
	var res = space_state.intersect_ray(ray_params)
	if not res.is_empty():
		if res["collider"].is_in_group("pickup"):
			$UI/IdentifierText.visible = true
			$UI/IdentifierText.text = "Pickup " + str(res["collider"].name)
			if Input.is_action_just_pressed("player_pickup") and not occupied:
				for slot in $Inventory/GridContainer.get_children():
					var item = slot.get_child(0)
					if not item.object:
						item.object = res["collider"]
						item.texture = res["collider"].texture
						res["collider"].get_parent().remove_child(res["collider"])
						break
		else:
			$UI/IdentifierText.visible = false
	else:
		$UI/IdentifierText.visible = false

var blinking = false

func open_eyes():
	if Input.is_action_pressed("player_blink"):
		$EyesClosed.start()
		return
	blinking = false
	$UI/BlinkRect.visible = false
	$EyesOpen.start()
	$EyesClosed.stop()

func close_eyes():
	blinking = true
	$UI/BlinkRect.visible = true
	$EyesClosed.start()
	$EyesOpen.stop()
