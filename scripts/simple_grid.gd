extends Control

@export var grid_size: int = 64
@export var grid_color: Color = Color(0.3, 0.3, 0.3, 0.5)
@export var background_color: Color = Color(0.1, 0.1, 0.15, 1.0)

func _ready():
	queue_redraw()

func _draw():
	# Draw background
	draw_rect(Rect2(Vector2.ZERO, size), background_color, true)
	
	# Draw vertical lines
	var x = 0
	while x <= size.x:
		draw_line(Vector2(x, 0), Vector2(x, size.y), grid_color, 1.0)
		x += grid_size
	
	# Draw horizontal lines
	var y = 0
	while y <= size.y:
		draw_line(Vector2(0, y), Vector2(size.x, y), grid_color, 1.0)
		y += grid_size
