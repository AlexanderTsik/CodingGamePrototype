extends CharacterBody2D

const GRID_SIZE = 64
var start_position: Vector2

func _ready():
	start_position = position

func reset_position():
	position = start_position

func move_right():
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(GRID_SIZE, 0), 0.25)

func move_left():
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(-GRID_SIZE, 0), 0.25)

func move_up():
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -GRID_SIZE), 0.25)

func move_down():
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, GRID_SIZE), 0.25)
