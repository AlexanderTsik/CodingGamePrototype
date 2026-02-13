extends Node2D
class_name LevelManager

signal level_completed
signal player_hit_hazard
signal player_out_of_bounds

@export var level_data: LevelData
@export var tile_size: int = 64

var tilemap: TileMap
var walls: Array[Vector2i] = []
var goals: Array[Vector2i] = []
var hazards: Array[Vector2i] = []
var start_pos: Vector2i

func _ready():
	if level_data:
		load_level(level_data)

func load_level(data: LevelData):
	level_data = data
	clear_level()
	parse_layout()
	create_visual_grid()

func clear_level():
	walls.clear()
	goals.clear()
	hazards.clear()
	
	# Clear existing tilemap if present
	if tilemap and is_instance_valid(tilemap):
		tilemap.queue_free()

func parse_layout():
	"""Parse the level layout and categorize tiles"""
	var layout = level_data.get_layout_array()
	
	for y in range(layout.size()):
		for x in range(layout[y].size()):
			var cell = layout[y][x]
			var pos = Vector2i(x, y)
			
			match cell:
				'#':
					walls.append(pos)
				'S':
					start_pos = pos
				'G':
					goals.append(pos)
				'X':
					hazards.append(pos)

func create_visual_grid():
	"""Create a TileMap to visualize the level"""
	tilemap = TileMap.new()
	tilemap.tile_set = create_tile_set()
	add_child(tilemap)
	
	var layout = level_data.get_layout_array()
	
	for y in range(layout.size()):
		for x in range(layout[y].size()):
			var cell = layout[y][x]
			var pos = Vector2i(x, y)
			
			match cell:
				'.':
					tilemap.set_cell(0, pos, 0, Vector2i(0, 0))  # Floor
				'#':
					tilemap.set_cell(0, pos, 0, Vector2i(1, 0))  # Wall
				'S':
					tilemap.set_cell(0, pos, 0, Vector2i(2, 0))  # Start
				'G':
					tilemap.set_cell(0, pos, 0, Vector2i(3, 0))  # Goal
				'X':
					tilemap.set_cell(0, pos, 0, Vector2i(4, 0))  # Hazard

func create_tile_set() -> TileSet:
	"""Create a simple procedural tileset"""
	var ts = TileSet.new()
	ts.tile_size = Vector2i(tile_size, tile_size)
	
	# Create a single atlas source
	var atlas = TileSetAtlasSource.new()
	atlas.texture = create_tileset_texture()
	atlas.texture_region_size = Vector2i(tile_size, tile_size)
	
	# Define tiles
	for i in range(5):
		atlas.create_tile(Vector2i(i, 0))
	
	ts.add_source(atlas, 0)
	return ts

func create_tileset_texture() -> ImageTexture:
	"""Create a procedural texture with colored tiles"""
	var img_width = tile_size * 5
	var img_height = tile_size
	var img = Image.create(img_width, img_height, false, Image.FORMAT_RGBA8)
	
	# Define colors for each tile type
	var colors = [
		Color(0.3, 0.3, 0.3),  # Floor - dark gray
		Color(0.5, 0.3, 0.2),  # Wall - brown
		Color(0.2, 0.6, 1.0),  # Start - blue
		Color(0.2, 1.0, 0.3),  # Goal - green
		Color(1.0, 0.2, 0.2),  # Hazard - red
	]
	
	# Fill each tile with its color
	for tile_idx in range(5):
		var color = colors[tile_idx]
		for y in range(tile_size):
			for x in range(tile_size):
				var px = tile_idx * tile_size + x
				# Add a border effect
				if x < 2 or x >= tile_size - 2 or y < 2 or y >= tile_size - 2:
					img.set_pixel(px, y, color.darkened(0.3))
				else:
					img.set_pixel(px, y, color)
	
	return ImageTexture.create_from_image(img)

func get_start_world_position() -> Vector2:
	"""Get the world position for the start tile"""
	return Vector2(start_pos) * tile_size + Vector2(tile_size / 2, tile_size / 2)

func is_walkable(grid_pos: Vector2i) -> bool:
	"""Check if a grid position is walkable"""
	return not (grid_pos in walls)

func is_valid_position(grid_pos: Vector2i) -> bool:
	"""Check if position is within level bounds"""
	return (grid_pos.x >= 0 and grid_pos.x < level_data.grid_width and
			grid_pos.y >= 0 and grid_pos.y < level_data.grid_height)

func is_goal(grid_pos: Vector2i) -> bool:
	"""Check if position is a goal"""
	return grid_pos in goals

func is_hazard(grid_pos: Vector2i) -> bool:
	"""Check if position is a hazard"""
	return grid_pos in hazards

func check_player_position(grid_pos: Vector2i):
	"""Check player position for win/lose conditions"""
	if not is_valid_position(grid_pos):
		player_out_of_bounds.emit()
		return
	
	if is_hazard(grid_pos):
		player_hit_hazard.emit()
		return
	
	if is_goal(grid_pos):
		level_completed.emit()

func world_to_grid(world_pos: Vector2) -> Vector2i:
	"""Convert world coordinates to grid coordinates"""
	return Vector2i(floor(world_pos.x / tile_size), floor(world_pos.y / tile_size))

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	"""Convert grid coordinates to world coordinates (center of tile)"""
	return Vector2(grid_pos) * tile_size + Vector2(tile_size / 2, tile_size / 2)
