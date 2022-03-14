extends TextureRect

var object

func _ready():
	texture = null
	object = null

func _get_drag_data(_at_position):
	if texture:
		var data = {}
		data["node"] = self
		data["texture"] = texture
		data["object"] = object
		
		var drag_texture = TextureRect.new()
		drag_texture.ignore_texture_size = true
		drag_texture.texture = texture
		drag_texture.rect_size = Vector2(128,128)
		
		var control = Control.new()
		control.add_child(drag_texture)
		drag_texture.rect_position = -0.5 * drag_texture.rect_size
		set_drag_preview(control)
		
		return data

func _can_drop_data(_at_position, _data):
	return true

func _drop_data(_at_position, data):
	data["node"].texture = texture
	data["node"].object = object
	texture = data["texture"]
	object = data["object"]
	
