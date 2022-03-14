extends Node

var player
var player_cam

func set_player(new_player):
	player = new_player
	player_cam = player.get_node("Camera3D")

func is_visible(position :Vector3, exclusions: Array = [], collision_mask: int = 4294967295):
	if player.blinking:
		return false
	if not player_cam.is_position_in_frustum(position):
		return false
	var space_state = player_cam.get_world_3d().direct_space_state
	var ray_params = PhysicsRayQueryParameters3D.new()
	exclusions.append(player)
	ray_params.from = position
	ray_params.to = player_cam.global_transform.origin
	ray_params.exclude = exclusions
	ray_params.collision_mask = collision_mask
	return space_state.intersect_ray(ray_params).is_empty()
