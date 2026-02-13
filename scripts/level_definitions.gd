# Level Definitions
# This file contains level layouts that can be converted to LevelData resources

## Tutorial Levels

### Level 1 - First Steps
var level_01 = {
	"level_id": 1,
	"level_name": "First Steps",
	"level_description": "Learn to move right to reach the goal",
	"difficulty": 1,
	"grid_width": 8,
	"grid_height": 6,
	"layout": """########
#S.....#
#......#
#......#
#.....G#
########""",
	"starter_code": "# Move to the green goal!\n",
	"hint_text": "Use moveRight() and moveDown() to reach the goal"
}

### Level 2 - Simple Loop
var level_02 = {
	"level_id": 2,
	"level_name": "Repeat Yourself",
	"level_description": "Use a loop to move multiple times",
	"difficulty": 1,
	"grid_width": 10,
	"grid_height": 6,
	"layout": """##########
#S.......#
#........#
#........#
#.......G#
##########""",
	"starter_code": "# Use a for loop to move efficiently\n",
	"hint_text": "Try: for (i in range(7)) { moveRight() }"
}

### Level 3 - Obstacles
var level_03 = {
	"level_id": 3,
	"level_name": "Around the Wall",
	"level_description": "Navigate around obstacles",
	"difficulty": 2,
	"grid_width": 8,
	"grid_height": 8,
	"layout": """########
#S.....#
#.#####.#
#......#
#.#####.#
#......#
#.....G#
########""",
	"starter_code": "# Go around the walls\n",
	"hint_text": "You need to move right, down, right, down, then right again"
}

### Level 4 - Conditional Movement
var level_04 = {
	"level_id": 4,
	"level_name": "Make a Choice",
	"level_description": "Use if statements to pick the right path",
	"difficulty": 2,
	"grid_width": 10,
	"grid_height": 8,
	"layout": """##########
#S.......#
#..####..#
#........#
#........#
#..####..#
#.......G#
##########""",
	"starter_code": """# Use variables and conditions
x = 2
if (x > 1) {
	# Pick the right path
}
""",
	"hint_text": "Use an if statement to choose between going through the top or bottom opening"
}

### Level 5 - Function Time
var level_05 = {
	"level_id": 5,
	"level_name": "Reuse Your Code",
	"level_description": "Create functions to avoid repetition",
	"difficulty": 2,
	"grid_width": 12,
	"grid_height": 8,
	"layout": """############
#S.........#
#..#..#..#.#
#..#..#..#.#
#..#..#..#.#
#..#..#..#.#
#.........G#
############""",
	"starter_code": """# Define a function to move over an obstacle
function stepOver() {
	# Your code here
}
""",
	"hint_text": "Create a function that moves right, down, right, up and call it 3 times"
}

### Level 6 - While Loop Challenge
var level_06 = {
	"level_id": 6,
	"level_name": "Count Your Steps",
	"level_description": "Use while loops for dynamic movement",
	"difficulty": 3,
	"grid_width": 10,
	"grid_height": 10,
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
	"starter_code": """# Use a while loop with a counter
count = 0
while (count < 7) {
	# Your code here
}
""",
	"hint_text": "Move right 7 times and down 7 times using while loops"
}

### Level 7 - Nested Loops
var level_07 = {
	"level_id": 7,
	"level_name": "Double Loop",
	"level_description": "Master nested loops",
	"difficulty": 3,
	"grid_width": 10,
	"grid_height": 8,
	"layout": """##########
#S.......#
#.#.#.#.#.#
#........#
#.#.#.#.#.#
#........#
#.......G#
##########""",
	"starter_code": """# Use nested loops to navigate
for (i in range(3)) {
	# Outer loop
	for (j in range(2)) {
		# Inner loop
	}
}
""",
	"hint_text": "Use nested loops: outer loop for rows, inner for columns"
}

### Level 8 - Complex Conditionals
var level_08 = {
	"level_id": 8,
	"level_name": "Multiple Paths",
	"level_description": "Navigate using elif and else",
	"difficulty": 3,
	"grid_width": 12,
	"grid_height": 10,
	"layout": """############
#S.........#
#...####...#
#...#..#...#
#...#..#...#
#...#..#...#
#...####...#
#.........#
#.........G#
############""",
	"starter_code": """# Choose the right path
path = 1
if (path == 1) {
	# Top path
} elif (path == 2) {
	# Middle path
} else {
	# Bottom path
}
""",
	"hint_text": "Go around the obstacle box - you can go left, through the middle, or right"
}

# Export all levels
var all_levels = [
	level_01,
	level_02,
	level_03,
	level_04,
	level_05,
	level_06,
	level_07,
	level_08
]
