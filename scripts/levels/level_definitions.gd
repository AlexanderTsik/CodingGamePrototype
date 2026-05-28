# Level Definitions - 10x10 Grid Tutorial Levels
# Each level teaches a specific programming concept

extends Node

var all_levels = [
	# ──────────────────────────────────────────────────────────────────────
	# Level 1 — Sequential Commands
	# Concept : Commands execute one at a time, top to bottom.
	#           Getting the ORDER wrong means hitting a wall.
	# Grid    : Tight L-shaped corridor — north 7 cells, then east 4 cells.
	# Solution: move()×7  →  turnRight()  →  move()×4
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 1,
		"level_name": "First Steps",
		"level_description": "Move and turn in the right order to reach the goal",
		"difficulty": 1,
		"layout": """###########
#....G#####
#.#########
#.#########
#.#########
#.#########
#.#########
#.#########
#S#########
###########""",
		"starter_code": """# Your bug starts facing UP.
# move()      — step one cell forward
# turnRight() — turn 90 degrees clockwise
# turnLeft()  — turn 90 degrees counter-clockwise
#
# Navigate the L-shaped corridor to reach the goal!
move()
move()
""",
		"hint_text": """Level 1 — Sequential Commands

Programs run line by line, top to bottom.
Each command does exactly ONE thing.

Your bug faces UP at the bottom of a
narrow corridor. Walk north until you
reach the top, then turn and head east
to the goal (G).

Tip: if you turn too early you'll hit
a wall — order matters!"""
	},
	
	# ──────────────────────────────────────────────────────────────────────
	# Level 2 — For Loops
	# Concept : Repeat a command N times without writing it N times.
	# Grid    : Two long corridors (7 cells each) forming an L.
	#           Without loops you need 14 move() calls — painful.
	# Solution: turnRight()
	#           for (i in range(7)) { move() }
	#           turnLeft()
	#           for (i in range(7)) { move() }
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 2,
		"level_name": "Long March",
		"level_description": "The path is long and repetitive — loops are your friend",
		"difficulty": 1,
		"layout": """##########
########G#
########.#
########.#
########.#
########.#
########.#
########.#
#S.......#
##########""",
		"starter_code": """# Typing move() 14 times is painful!
# Use a for loop to repeat a command N times:
#
#   for (i in range(N)) {
#       move()
#   }
#
# The path goes EAST first, then NORTH.
# Each segment is 7 cells long.
turnRight()
move()
move()
move()
# ...keep going, or replace this with a loop!
""",
		"hint_text": """Level 2 — For Loops

A for loop runs its body N times:

  for (i in range(7)) {
      move()
  }

This is identical to writing move() seven
times, but much shorter!

The path has TWO long segments (7 cells
each). Use one for loop per segment and
you only need 8 lines instead of 16.

Syntax reminder:
  for (variable in range(count)) {
      commands here
  }"""
	},
	
	# ──────────────────────────────────────────────────────────────────────
	# Level 3 — While Loops + Sensors
	# Concept : while(frontIsClear()) { move() } — walk until the wall
	#           stops you, without counting steps in advance.
	# Grid    : Four-segment snake. Each segment is a different length
	#           (3, 4, 3, 3) so counting and using for loops is awkward.
	# Solution: while(frontIsClear()){move()} + turn — repeated 4 times.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 3,
		"level_name": "Blind Alleys",
		"level_description": "The corridors are different lengths — let your sensors guide you",
		"difficulty": 2,
		"layout": """##########
##########
#####...G#
#####.####
#####.####
#.....####
#.########
#.########
#S########
##########""",
		"starter_code": """# Each corridor segment is a different length.
# Instead of counting steps, use a sensor:
#
#   while (frontIsClear()) {
#       move()
#   }
#
# The bug will walk until it hits a wall, then stop.
# Add a turn, then another while loop for the next segment.
while (frontIsClear()) {
    move()
}
turnRight()
""",
		"hint_text": """Level 3 — While Loops + Sensors

A while loop repeats while its condition is true:

  while (frontIsClear()) {
      move()
  }

The bug walks forward until a wall blocks
the way — no counting needed!

This path has FOUR segments of different
lengths. Use one while loop per segment:

  while(frontIsClear()) { move() }
  turnRight()
  while(frontIsClear()) { move() }
  turnLeft()
  while(frontIsClear()) { move() }
  turnRight()
  while(frontIsClear()) { move() }

frontIsClear() — true if the next cell is open
leftIsClear()  — true if the cell to your left is open
rightIsClear() — true if the cell to your right is open"""
	},
	
	# ──────────────────────────────────────────────────────────────────────
	# Level 4 — If / Else
	# Concept : Check a condition and branch: do A if true, B if false.
	# Grid    : Two T-junctions. Junction 1 → turn right.
	#                            Junction 2 → turn left.
	#           The SAME if/else block handles both — the sensor returns
	#           a different value each time, so the code adapts.
	# Solution: while+move → if(rightIsClear){turnRight}else{turnLeft}
	#           → while+move → same if/else → while+move → goal
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 4,
		"level_name": "Fork in the Road",
		"level_description": "Two junctions, one decision — let sensors choose the turn",
		"difficulty": 2,
		"layout": """##########
######G###
######.###
#......###
#.########
#.########
#.########
#.########
#S########
##########""",
		"starter_code": """# The path has two T-junctions.
# At each one, check which way is open:
#
#   if (rightIsClear()) {
#       turnRight()
#   } else {
#       turnLeft()
#   }
#
# The same if/else works at both junctions!
while (frontIsClear()) {
    move()
}
if (rightIsClear()) {
    turnRight()
} else {
    turnLeft()
}
""",
		"hint_text": """Level 4 — If / Else

An if/else runs one block OR the other,
never both:

  if (rightIsClear()) {
      turnRight()   ← runs if right is open
  } else {
      turnLeft()    ← runs if right is blocked
  }

There are TWO junctions on this path.
At junction 1 the right is open.
At junction 2 the right is blocked.

Write the if/else once — it handles
both situations automatically because
the sensor reads the actual environment!

Sensors return true or false:
  rightIsClear() → true if right is open
  leftIsClear()  → true if left is open
  frontIsClear() → true if ahead is open"""
	},
	
	# ──────────────────────────────────────────────────────────────────────
	# Level 5 — Functions (DRY principle)
	# Concept : Define a reusable function and call it instead of
	#           repeating the same block of code multiple times.
	# Grid    : A staircase — three identical 5-command "step" patterns.
	#           Without a function: 16 commands.
	#           With function step(): define once, call 3 times = 9 lines.
	# Solution: function step(){ move();move();turnRight();move();turnLeft() }
	#           step() × 3, then move()
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 5,
		"level_name": "Staircase",
		"level_description": "Three identical patterns — write it once, call it three times",
		"difficulty": 2,
		"layout": """##########
####G#####
###..#####
###.######
##..######
##.#######
#..#######
#.########
#S########
##########""",
		"starter_code": """# Look at the grid — the same "step" pattern repeats 3 times!
# Define a function to avoid copy-pasting:
#
#   function myFunction() {
#       commands here
#   }
#
# Then call it: myFunction()

function step() {
    move()
    move()
    turnRight()
    move()
    turnLeft()
}

step()
# Call step() two more times, then one final move() to the goal.
""",
		"hint_text": """Level 5 — Functions (DRY Principle)

DRY = Don't Repeat Yourself.

When you need the same block of code
multiple times, put it in a function:

  function step() {
      move()
      move()
      turnRight()
      move()
      turnLeft()
  }

Then call it:
  step()
  step()
  step()

The staircase has 3 identical steps.
After the third step, one final move()
brings you to the goal.

Without a function: 16 lines.
With a function: 9 lines."""
	},
	
	# ──────────────────────────────────────────────────────────────────────
	# Level 6 — Nested For Loops ("Comb Run")
	# Concept : A loop inside a loop.
	# Grid    : 4 vertical corridors (5 cells each) joined by a horizontal
	#           connector at y=6. Walk up & back 3 corridors, then walk
	#           the 4th straight to the goal.
	# Solution: move()×2 → turnRight()
	#           for i in range(3):
	#             turnLeft() → for j in range(5): move()
	#             turnBack() → for j in range(5): move()
	#             turnRight() → move()×2
	#           turnLeft() → for j in range(5): move()
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 6,
		"level_name": "Comb Run",
		"level_description": "Four corridors, one loop inside another — explore them all",
		"difficulty": 3,
		"layout": """##########
#.#.#.#G##
#.#.#.#.##
#.#.#.#.##
#.#.#.#.##
#.#.#.#.##
#.......##
#.########
#S########
##########""",
		"starter_code": """# Walk up each corridor and back, then step to the next one.
# A loop inside a loop handles all the return trips!
#
#   for (i in range(3)) {
#       turnLeft()
#       for (j in range(5)) { move() }   <- inner loop
#       turnBack()
#       for (j in range(5)) { move() }
#       turnLeft()
#       move()
#       move()
#   }

# First: walk to the horizontal connector
move()
move()
turnRight()

# Your nested loop goes here...
""",
		"hint_text": """Level 6 — Nested For Loops

A loop can contain another loop:

  for (i in range(3)) {
      for (j in range(5)) {
          move()
      }
  }

Outer loop: 3 times.
Inner loop: 5 times each.
Total moves: 3 x 5 = 15.

The grid has 4 vertical corridors (5 cells
each) joined at the bottom by a corridor.

Walk up → back down → step east → repeat.
Use nested loops for corridors 1-3, then
walk the 4th straight to the goal.

Tip: turnBack() turns you 180 degrees."""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 7 — Variables ("Spiral Out")
	# Concept : Store a value in a variable, use it in range(), increment it.
	# Grid    : 4-arm clockwise spiral — arms of length 1, 2, 3, 4.
	#           S at (5,6) facing north. Arms: N1, E2, S3, W4 → G(3,8).
	# Solution: var n = 1
	#           for i in range(4):
	#             for j in range(n): move()
	#             turnRight()
	#             n = n + 1
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 7,
		"level_name": "Spiral Out",
		"level_description": "Each arm is longer than the last — track the count in a variable",
		"difficulty": 3,
		"layout": """##########
##########
##########
##########
##########
#####...##
#####S#.##
#######.##
###G....##
##########""",
		"starter_code": """# The path spirals outward — each arm is 1 step longer than the last.
# Without a variable you need four separate for loops.
# With a variable, one outer loop handles all four arms!
# (Variables are created by simple assignment — no keyword needed.)
#
#   n = 1
#   for (i in range(4)) {
#       for (j in range(n)) { move() }
#       turnRight()
#       n = n + 1
#   }

n = 1
# Use n inside the inner loop, then increase it each iteration.
""",
		"hint_text": """Level 7 — Variables

Variables store values that can change.
Just assign a value to create one — no keyword needed:

  n = 1
  for (i in range(4)) {
      for (j in range(n)) { move() }
      turnRight()
      n = n + 1    <- grows each loop
  }

Without a variable you'd write:
  for(j in range(1)) { move() } turnRight()
  for(j in range(2)) { move() } turnRight()
  ... (four separate blocks)

The spiral arms:
  1 step north  -> turn right
  2 steps east  -> turn right
  3 steps south -> turn right
  4 steps west  -> goal!"""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 8 — Functions with Parameters ("Three Bridges")
	# Concept : Define walk(n) once, call it with different values.
	# Grid    : S(1,8) → north 2 → east 4 → north 5 → G(5,1).
	#           Three segments of lengths 2, 4, 5.
	# Solution: function walk(n){ for i in range(n): move() }
	#           walk(2) → turnRight() → walk(4) → turnLeft() → walk(5)
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 8,
		"level_name": "Three Bridges",
		"level_description": "Three corridors, three lengths — write walk(n) once, call it three times",
		"difficulty": 3,
		"layout": """##########
#####G####
#####.####
#####.####
#####.####
#####.####
#.....####
#.########
#S########
##########""",
		"starter_code": """# Three corridor segments: 2 steps north, 4 east, 5 north.
# Without a function you'd copy the for-loop three times.
# With a parameter, write it once and call it with different values!
#
#   function walk(n) {
#       for (i in range(n)) { move() }
#   }
#
#   walk(2)
#   turnRight()
#   walk(4)
#   turnLeft()
#   walk(5)

function walk(n) {
    for (i in range(n)) {
        move()
    }
}

walk(2)
# Keep going with turnRight(), walk(4), turnLeft(), walk(5)
""",
		"hint_text": """Level 8 — Functions with Parameters

A function can accept a value (parameter):

  function walk(n) {
      for (i in range(n)) {
          move()
      }
  }

Call it with any number:
  walk(2)   -> moves 2 steps
  walk(4)   -> moves 4 steps
  walk(5)   -> moves 5 steps

The path:
  north 2 -> turn right
  east  4 -> turn left
  north 5 -> goal!

Three calls, zero repeated code.
That's the power of parameters."""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 9 — Boolean Logic ("Right-Hand Rule")
	# Concept : not, and, or in conditions; while(not goalReached()).
	# Grid    : Winding single-path maze. The right-hand follower algorithm
	#           is the natural fit — any hard-coded sequence fails.
	# Solution: while(not goalReached()):
	#               if rightIsClear(): turnRight(); move()
	#               elif frontIsClear(): move()
	#               else: turnLeft()
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 9,
		"level_name": "Right-Hand Rule",
		"level_description": "Navigate the maze with boolean logic — not, and, or",
		"difficulty": 4,
		"layout": """##########
##########
########G#
########.#
########.#
#######..#
#....##.##
#.##....##
#S########
##########""",
		"starter_code": """# The maze twists unpredictably — hard-coding each turn won't work.
# Use the right-hand follower: always try to turn right first.
#
# Key new syntax: not, and, or

while (not goalReached()) {
    if (rightIsClear()) {
        turnRight()
        move()
    } elif (frontIsClear()) {
        move()
    } else {
        turnLeft()
    }
}
""",
		"hint_text": """Level 9 — Boolean Logic

New operators: not, and, or

  while (not goalReached()) { ... }
  <- loop until the goal is reached

  if (frontIsClear() and rightIsClear())
  <- BOTH must be true

  if (frontIsClear() or rightIsClear())
  <- at LEAST ONE must be true

The RIGHT-HAND RULE solves many mazes:

  while (not goalReached()) {
      if (rightIsClear()) {
          turnRight()
          move()
      } elif (frontIsClear()) {
          move()
      } else {
          turnLeft()
      }
  }

It handles every junction automatically
because it reads the real environment
each step — no manual counting needed!"""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 10 — All Concepts ("The Labyrinth")
	# Concept : Functions, while, not, variables, if/elif/else — all together.
	# Grid    : Long winding maze. S(1,8) → north 7 → east 3 → south 3
	#           → east 2 → north 3 → east 2 → G(8,1).
	# Solution: function followWall(){ right-hand step }
	#           var steps = 0
	#           while(not goalReached()): followWall(); steps = steps+1
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 10,
		"level_name": "The Labyrinth",
		"level_description": "Use every concept you've learned to escape the labyrinth",
		"difficulty": 4,
		"layout": """##########
#....#..G#
#.##.#.###
#.##.#.###
#.##...###
#.########
#.########
#.########
#S########
##########""",
		"starter_code": """# The ultimate challenge — use everything you've learned!
#
# Wrap your navigation logic in a function,
# loop until the goal is reached,
# and track your steps with a variable.

function followWall() {
    if (rightIsClear()) {
        turnRight()
        move()
    } elif (frontIsClear()) {
        move()
    } else {
        turnLeft()
    }
}

steps = 0
while (not goalReached()) {
    followWall()
    steps = steps + 1
}
""",
		"hint_text": """Level 10 — All Concepts

This is your graduation exam.
Combine everything:

  function followWall() {      <- function
      if (rightIsClear()) {    <- if/elif/else
          turnRight()
          move()
      } elif (frontIsClear()) {
          move()
      } else {
          turnLeft()
      }
  }

  steps = 0                    <- variable
  while (not goalReached()) {  <- while + not
      followWall()             <- function call
      steps = steps + 1        <- accumulator
  }

The maze is long — sequential commands
will not cut it. You need the full toolkit.

Concepts used:
  Functions with logic inside
  While loop with boolean condition
  If / elif / else branching
  Variables as accumulators
  Sensor functions (rightIsClear, etc.)"""
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
