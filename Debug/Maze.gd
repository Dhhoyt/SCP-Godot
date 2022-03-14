extends Node3D

var maze_segment = preload("res://Debug/Maze Segment.tscn")
var thread

var segments = []

var walls = []

@export var max_proportion_blank: float = 0.5
@export var size: Vector2i = Vector2i(10,10)

func _ready():
	#Thread.new().start(generate_maze)
	generate_maze()
	$NavigationRegion3D.bake_navigation_mesh()
	$Player.global_transform.origin = 5 * Vector3(size.x - 1, 1, size.y - 1)
	$Camera3D.global_transform.origin = 2.5 * Vector3(size.x, 30, size.y)
	
func generate_maze():
	for x in range(size.x):
		var temp_segments = []
		for y in range(size.y):
			var new_segment = maze_segment.instantiate()
			$NavigationRegion3D.add_child(new_segment)
			new_segment.global_transform.origin = Vector3(x * 5, 0, y * 5)
			new_segment.x = x
			new_segment.y = y
			temp_segments.append(new_segment)
		segments.append(temp_segments)
		
	var first_x = randi() % size.x
	var first_y = randi() % size.y
	print(first_x, first_y)
	visit(first_x, first_y)
	while(len(walls) > 0):
		var rand_index = randi() % len(walls)
		var current_wall = walls[rand_index]
		var x = current_wall.get_parent().x
		var y = current_wall.get_parent().y
		if current_wall.get_name() == "Up":
			if (not segments[x][y].visited or not segments[x][y + 1].visited):
				current_wall.queue_free()
				visit(x, y)
				visit(x, y + 1)
		elif not segments[x][y].visited or not segments[x + 1][y].visited:
			current_wall.queue_free()
			visit(x, y)
			visit(x + 1, y)
		walls.pop_at(rand_index)
	
	for i in range(int(max_proportion_blank * size.x * size.y)):
		var x = randi() % size.x
		var y = randi() % size.y
		if x >= size.x - 1 or y >= size.y - 1:
			continue
		if randi() % 2 == 0:
			segments[x][y].get_left().queue_free()
		else:
			segments[x][y].get_up().queue_free()
func visit(x, y):
	if  x >= size.x or y >= size.y or segments[x][y].visited:
		return
	segments[x][y].visited = true
	if x != 0 and !segments[x - 1][y].left_in_list:
		walls.append(segments[x - 1][y].get_left())
		segments[x - 1][y].left_in_list = true
	if y != 0 and !segments[x][y - 1].up_in_list:
		walls.append(segments[x][y - 1].get_up())
		segments[x][y - 1].up_in_list = true
	if x < size.x - 1 and !segments[x][y].left_in_list:
		walls.append(segments[x][y].get_left())
		segments[x][y].left_in_list = true
	if y < size.y - 1 and !segments[x][y].up_in_list:
		walls.append(segments[x][y].get_up())
		segments[x][y].up_in_list = true
