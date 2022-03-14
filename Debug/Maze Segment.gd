extends MeshInstance3D

var x
var y

var visited = false

var up_in_list = false
var left_in_list = false

func get_up():
	return $Up
	
func get_left():
	return $Left
	

