# Level Definitions - 10x10 Grid Tutorial Levels
# Each level teaches a specific programming concept

extends Node

var all_levels = [
	# Level 1: Sequential Commands
	{
		"level_id": 1,
		"level_name": "First Steps",
		"level_description": "Learn basic movement commands",
		"difficulty": 1,
		"layout": """##########
#S.......#
#........#
#........#
#........#
#........#
#........#
#........#
#.......G#
##########""",
		"starter_code": "# Move to the goal\nmove()\nturnRight()\nmove()\n",
		"hint_text": "Use move(), turnRight(), and turnLeft() to reach the green goal!"
	},
	
	# Level 2: For Loops
	{
		"level_id": 2,
		"level_name": "Long Journey",
		"level_description": "Use for loops to avoid repetition",
		"difficulty": 1,
		"layout": """##########
#S.......#
#........#
#........#
#........#
#........#
#........#
#........#
#.......G#
##########""",
		"starter_code": "# Use a for loop\nfor(i in range(7)) {\n    move()\n}\nturnRight()\nmove()\n",
		"hint_text": "Instead of typing move() 7 times, use a for loop!"
	},
	
	# Level 3: While Loops & Sensing
	{
		"level_id": 3,
		"level_name": "Wall Detection",
		"level_description": "Use frontIsClear() with while loops",
		"difficulty": 2,
		"layout": """##########
#S......##
#.......##
#.......##
#.......##
####....##
##.......#
##.......#
##......G#
##########""",
		"starter_code": "# Move until blocked\nwhile(frontIsClear()) {\n    move()\n}\nturnRight()\nmove()\n",
		"hint_text": "Use while(frontIsClear()) to move until you hit a wall, then turn and navigate!"
	},
	
	# Level 4: If-Else
	{
		"level_id": 4,
		"level_name": "Choose Your Path",
		"level_description": "Make decisions with if-else",
		"difficulty": 2,
		"layout": """##########
#S...#...#
#....#...#
#....#...#
#........#
#....#...#
#....#...#
#....#...#
#....#..G#
##########""",
		"starter_code": "# Navigate smartly\nif(rightIsClear()) {\n    turnRight()\n    move()\n} else {\n    turnRight()\n    move()\n}\n",
		"hint_text": "Check if you can turn right and move, otherwise find another path!"
	},
	
	# Level 5: Hazards
	{
		"level_id": 5,
		"level_name": "Danger Zone",
		"level_description": "Avoid hazards to survive",
		"difficulty": 3,
		"layout": """##########
#S.......#
#.XXX....#
#.X.X....#
#.XXX....#
#........#
#........#
#........#
#.......G#
##########""",
		"starter_code": "# Avoid the red hazards!\n",
		"hint_text": "Hazards (red X) are deadly! Navigate around them to reach the goal."
	},
	
	# Level 6: Complex Conditions
	{
		"level_id": 6,
		"level_name": "Smart Navigation",
		"level_description": "Combine loops and sensing",
		"difficulty": 3,
		"layout": """##########
#S.#.....#
#..#.....#
#..#.....#
#........#
#..####..#
#........#
#.....#..#
#.....#.G#
##########""",
		"starter_code": "# Navigate to goal\nwhile(!goalReached()) {\n    if(frontIsClear()) {\n        move()\n    } else if(rightIsClear()) {\n        turnRight()\n        move()\n    } else {\n        turnLeft()\n    }\n}\n",
		"hint_text": "Use goalReached() to check if you've won, and sensor functions to navigate!"
	},
	
	# Level 7: Functions
	{
		"level_id": 7,
		"level_name": "Pattern Maker",
		"level_description": "Create reusable functions",
		"difficulty": 3,
		"layout": """##########
#S.#.#.#.#
#..#.#.#.#
#........#
#........#
#........#
#........#
#........#
#.......G#
##########""",
		"starter_code": "# Define a function\nfunction stepOver() {\n    move()\n    move()\n}\n\n# Call it\nstepOver()\n",
		"hint_text": "Create a function that moves in a pattern, then call it multiple times!"
	},
	
	# Level 8: Final Challenge
	{
		"level_id": 8,
		"level_name": "The Maze",
		"level_description": "Use everything you've learned",
		"difficulty": 4,
		"layout": """##########
#S.#..#..#
#..#..#..#
#..#.....#
#..####..#
#........#
#.####.#.#
#.#....#.#
#.#.####G#
##########""",
		"starter_code": "# Solve the maze!\n",
		"hint_text": "Combine loops, conditions, and sensing to solve this complex maze!"
	}
]

func get_level(level_id: int) -> Dictionary:
	"""Get level definition by ID (1-based)"""
	if level_id >= 1 and level_id <= all_levels.size():
		return all_levels[level_id - 1]
	return {}

func get_level_count() -> int:
	"""Get total number of levels"""
	return all_levels.size()
