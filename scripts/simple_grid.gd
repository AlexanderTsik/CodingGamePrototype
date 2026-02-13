extends Control

@export var grid_size: int = 64
@export var grid_color: Color = Color(0.3, 0.3, 0.3, 0.5)
@export var background_color: Color = Color(0.1, 0.1, 0.15, 1.0)

var grid_manager: GridManager

func _ready():
	# Force exact size
	custom_minimum_size = Vector2(640, 640)
	size = Vector2(640, 640)
	queue_redraw()

func _draw():
	# Draw background (exactly 640x640)
	draw_rect(Rect2(Vector2.ZERO, Vector2(640, 640)), background_color, true)
	
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
	"""Draw grid lines"""
	var max_x = 10 * grid_size  # Exactly 10 cells wide
	var max_y = 10 * grid_size  # Exactly 10 cells tall
	
	# Draw vertical lines
	for i in range(11):  # 0-10 = 11 lines for 10 cells
		var x = i * grid_size
		draw_line(Vector2(x, 0), Vector2(x, max_y), grid_color, 1.0)
	
	# Draw horizontal lines
	for i in range(11):  # 0-10 = 11 lines for 10 cells
		var y = i * grid_size
		draw_line(Vector2(0, y), Vector2(max_x, y), grid_color, 1.0)

func refresh():
	"""Call this when grid changes to redraw"""
	queue_redraw()
