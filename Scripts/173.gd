extends RigidDynamicBody3D

@export var speed: float = 50

@onready var player = get_tree().get_nodes_in_group("player")[0]
@onready var utils = get_node("/root/Utils")

var dest: Vector3 = Vector3()

func _integrate_forces(_state):
	if $NavigationAgent3D.is_target_reachable() and not is_visible_to_player():
		var target = $NavigationAgent3D.get_next_location()
		var velocity = global_transform.origin.direction_to(target).normalized()
		$NavigationAgent3D.set_velocity(velocity * speed)
		$scp173_MESH.look_at(target, Vector3.UP)
		$scp173_MESH.rotation = Vector3(0, $scp173_MESH.rotation.y-PI, 0)
	else:
		set_linear_velocity(Vector3.ZERO)

func set_dest():
	dest = player.global_transform.origin
	$NavigationAgent3D.set_target_location(dest)
	
func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	set_linear_velocity(safe_velocity)

func _on_timer_timeout():
	set_dest()

func _on_navigation_agent_3d_target_reached():
	set_dest()

func is_visible_to_player():
	print("g")
	for i in $VisiblePositions.get_children():
		if utils.is_visible(i.global_transform.origin, [self]):
			return true
	print("g")
	return false
