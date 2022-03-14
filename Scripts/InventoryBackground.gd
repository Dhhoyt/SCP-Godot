extends ColorRect

func _can_drop_data(_at_position, _data):
	return true

func _get_drag_data(_at_position):
	return null

func _drop_data(_at_position, data):
	var new_pos = Vector3(0 ,0 ,-1)
	new_pos = new_pos * get_parent().get_parent().global_transform.basis.inverse()
	get_parent().get_parent().get_parent().add_child(data["node"].object)
	data["node"].object.global_transform.origin = new_pos + get_parent().get_parent().global_transform.origin
	data["node"].object.linear_velocity = Vector3(0,-0.1,0)
	data["node"].texture = null
	data["node"].object = null
	
