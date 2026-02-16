extends Control

@export var grid_size: int = 64
@export var grid_color: Color = Color(0.3, 0.3, 0.3, 0.5)
@export var background_color: Color = Color(0.1, 0.1, 0.15, 1.0)

var grid_manager: GridManager

func _ready():
	queue_redraw()

func _draw():
	# Calculate dynamic size based on grid dimensions
	var width = 640
	var height = 640
	
	if grid_manager and grid_manager.grid_width > 0 and grid_manager.grid_height > 0:
		width = grid_manager.grid_width * grid_size
		height = grid_manager.grid_height * grid_size
	else:
		# Default to 10x10 if no grid manager
		width = 10 * grid_size
		height = 10 * grid_size
	
	# Update size
	custom_minimum_size = Vector2(width, height)
	
	# Draw background
	draw_rect(Rect2(Vector2.ZERO, Vector2(width, height)), background_color, true)
	
	# Draw cells if grid manager exists
	if grid_manager and grid_manager.grid.size() > 0:
		_draw_cells()
	
	# Draw grid lines
	_draw_grid_lines()

func _draw_cells():
	"""Draw colored rectangles for each cell type"""
	for y in range(grid_manager.grid_height):
		for x in range(grid_manager.grid_width):
			var cell_type = grid_manager.grid[y][x]
			var color = CellType.get_color(cell_type)
			
			# Don't skip walls! Only skip EMPTY
			if cell_type == CellType.Type.EMPTY:
				continue
			
			var rect = Rect2(
				Vector2(x * grid_size, y * grid_size),
				Vector2(grid_size, grid_size)
			)
			draw_rect(rect, color, true)
			
			# Add brighter border for all non-empty cells
			draw_rect(rect, color.lightened(0.4), false, 3.0)

func _draw_grid_lines():
	"""Draw grid lines based on current grid dimensions"""
	if not grid_manager:
		return
	
	var grid_width = grid_manager.grid_width if grid_manager.grid_width > 0 else 10
	var grid_height = grid_manager.grid_height if grid_manager.grid_height > 0 else 10
	
	var max_x = grid_width * grid_size
	var max_y = grid_height * grid_size
	
	# Draw vertical lines
	for i in range(grid_width + 1):
		var x = i * grid_size
		draw_line(Vector2(x, 0), Vector2(x, max_y), grid_color, 1.0)
	
	# Draw horizontal lines
	for i in range(grid_height + 1):
		var y = i * grid_size
		draw_line(Vector2(0, y), Vector2(max_x, y), grid_color, 1.0)

func refresh():
	"""Call this when grid changes to redraw"""
	queue_redraw()
