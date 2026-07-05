# Level Definitions - 10x10 Grid Tutorial Levels
# Each level teaches a specific programming concept

extends Node

# Set to true during development to pre-fill levels with working solutions.
# Set to false before production / release builds.
const DEV_MODE = true

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
		"level_description": "Learn sequencing: commands run top-to-bottom, so the order of move and turn matters.",
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
		"solution_code": """for (i in range(7)) { move() }
turnRight()
for (i in range(4)) { move() }
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
		"level_description": "Learn for loops: repeat a command N times instead of typing it out by hand.",
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
		"solution_code": """turnRight()
for (i in range(7)) { move() }
turnLeft()
for (i in range(7)) { move() }
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
	# Level 3 — If / Else
	# Concept : Check a condition and branch: do A if true, B if false.
	# Grid    : Two T-junctions. Junction 1 → turn right.
	#                            Junction 2 → turn left.
	#           The SAME if/else block handles both — the sensor returns
	#           a different value each time, so the code adapts.
	# Solution: while+move → if(rightIsClear){turnRight}else{turnLeft}
	#           → while+move → same if/else → while+move → goal
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 3,
		"level_name": "Fork in the Road",
		"level_description": "Learn if / else: choose which way to turn based on what a sensor sees.",
		"difficulty": 1,
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
		"solution_code": """while (frontIsClear()) { move() }
if (rightIsClear()) { turnRight() } else { turnLeft() }
while (frontIsClear()) { move() }
if (rightIsClear()) { turnRight() } else { turnLeft() }
while (frontIsClear()) { move() }
""",
		"hint_text": """Level 3 — If / Else

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
	# Level 4 — While Loops + Sensors
	# Concept : while(frontIsClear()) { move() } — walk until the wall
	#           stops you, without counting steps in advance.
	# Grid    : Four-segment snake. Each segment is a different length
	#           (3, 4, 3, 3) so counting and using for loops is awkward.
	# Solution: while(frontIsClear()){move()} + turn — repeated 4 times.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 4,
		"level_name": "Blind Alleys",
		"level_description": "Learn while loops + sensors: walk until a wall stops you, with no counting.",
		"difficulty": 1,
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
		"solution_code": """while (frontIsClear()) { move() }
turnRight()
while (frontIsClear()) { move() }
turnLeft()
while (frontIsClear()) { move() }
turnRight()
while (frontIsClear()) { move() }
""",
		"hint_text": """Level 4 — While Loops + Sensors

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
		"level_description": "Learn functions: name a block of code once, then reuse it (Don't Repeat Yourself).",
		"difficulty": 1,
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
		"solution_code": """function step() {
    move()
    move()
    turnRight()
    move()
    turnLeft()
}
step()
step()
step()
move()
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
	# Level 6 — Variables ("Measure & Mirror")
	# Concept : Store a measured value in a variable, then reuse it.
	# Grid    : Symmetric L — walk UP an unknown distance, then turn and
	#           walk the SAME distance EAST to the goal.
	# Why force: The leg length changes every variant (3, 5, 7), so a
	#            hard-coded count fails. You MUST measure and reuse.
	# Solution: n = 0
	#           while (frontIsClear()) { move(); n = n + 1 }
	#           turnRight()
	#           for (i in range(n)) { move() }
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 6,
		"level_name": "Measure & Mirror",
		"level_description": "Learn variables: count the steps you take, store the number, then reuse it.",
		"difficulty": 2,
		"layout": """##########
##########
##########
##########
##########
#...G#####
#.########
#.########
#S########
##########""",
		"variants": [
			"""##########
##########
##########
##########
##########
#...G#####
#.########
#.########
#S########
##########""",
			"""##########
##########
##########
#.....G###
#.########
#.########
#.########
#.########
#S########
##########""",
			"""##########
#.......G#
#.########
#.########
#.########
#.########
#.########
#.########
#S########
##########"""
		],
		"starter_code": """# The path goes UP an unknown distance, then the SAME
# distance EAST. The length changes every run, so you
# cannot just type a fixed number!
#
# Solution: COUNT your steps into a variable, then reuse it.
# (Variables are created by assignment — no keyword needed.)
#
#   n = 0
#   while (frontIsClear()) {
#       move()
#       n = n + 1        <- count each step
#   }
#   turnRight()
#   for (i in range(n)) {
#       move()           <- reuse the count
#   }

n = 0
""",
		"solution_code": """n = 0
while (frontIsClear()) {
    move()
    n = n + 1
}
turnRight()
for (i in range(n)) {
    move()
}
""",
		"hint_text": """Level 6 — Variables

A variable stores a value you can read back
later. Create one by assigning to it:

  n = 0
  n = n + 1     <- add one to n

The corridor goes UP an unknown number of
cells, then EAST the SAME number. Because
the distance changes every variation, you
cannot hard-code it. Instead, MEASURE it:

  n = 0
  while (frontIsClear()) {
      move()
      n = n + 1     <- count steps going up
  }
  turnRight()
  for (i in range(n)) {
      move()        <- walk that many east
  }

The variable 'remembers' how far you walked
so you can mirror the distance. Try a fixed
number instead and it will fail on another
variation — that's why variables matter!"""
	},
		
	# ──────────────────────────────────────────────────────────────────────
	# Level 7 — Corridor Follower ("Snake Path")
	# Concept : Combine while + if/else + the goalReached() sensor to follow
	#           a single winding corridor: walk straight until a wall stops
	#           you, then turn toward whichever side is open. Repeat until
	#           you reach the goal. A gentle first taste of "code that reads
	#           the maze" before the full right-hand rule at Level 10.
	# Grid    : Single-path snakes (no branches), different shapes per variant.
	# Solution: while (not goalReached()) {
	#             while (frontIsClear()) { move() }
	#             if (rightIsClear()) { turnRight() } else { turnLeft() }
	#           }
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 7,
		"level_name": "Snake Path",
		"level_description": "Combine while, if/else and goalReached(): follow a winding corridor until you reach the goal.",
		"difficulty": 2,
		"layout": """##########
####G#####
####.#####
####.#####
#....#####
#.########
#.########
#.########
#S########
##########""",
		"variants": [
			"""##########
####G#####
####.#####
####.#####
#....#####
#.########
#.########
#.########
#S########
##########""",
			"""##########
######G###
######.###
######.###
#......###
#.########
#.########
#.########
#S########
##########""",
			"""##########
####G#####
####.#####
####.#####
####.#####
#....#####
#.########
#.########
#S########
##########"""
		],
		"starter_code": """# This is a single winding corridor — a "snake".
# You don't know how long each straight part is,
# so COUNT nothing: just let the bug READ the maze.
#
# The plan, repeated until you reach the goal:
#   1. Walk straight until a wall blocks you.
#   2. Turn toward whichever side is open.
#
#   while (not goalReached()) {
#       while (frontIsClear()) {
#           move()
#       }
#       if (rightIsClear()) {
#           turnRight()
#       } else {
#           turnLeft()
#       }
#   }
#
# goalReached() — true once the bug stands on the goal (G).
while (not goalReached()) {
    while (frontIsClear()) {
        move()
    }
    if (rightIsClear()) {
        turnRight()
    } else {
        turnLeft()
    }
}
""",
		"solution_code": """while (not goalReached()) {
    while (frontIsClear()) {
        move()
    }
    if (rightIsClear()) {
        turnRight()
    } else {
        turnLeft()
    }
}
""",
		"hint_text": """Level 7 — Snake Path

This corridor twists and turns, and each
straight part is a different length. Counting
steps would be a nightmare — so don't!

Instead, write code that FOLLOWS the corridor:

  while (not goalReached()) {
      while (frontIsClear()) {   <- walk straight
          move()
      }
      if (rightIsClear()) {      <- corner: turn
          turnRight()            <- toward the open side
      } else {
          turnLeft()
      }
  }

How it works:
  • The inner while walks forward until a wall.
  • At a corner exactly one side is open, so the
    if/else picks the correct turn.
  • The outer while keeps going until goalReached().

New sensor:
  goalReached() — true when the bug is on the goal.

Because the code reads the maze as it goes, the
SAME program solves every snake, no matter its
shape. This is your first "smart" solver —
Level 10 will make it even more powerful!"""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 8 — Functions with Parameters ("Bridge Builder")
	# Concept : Define walk(n) once, call it with a measured value twice.
	# Grid    : Z-shape — three equal legs: UP n, EAST n, UP n to the goal.
	# Why force: The leg length changes every variant (2, 3, 4). Measure it
	#            into a variable, then pass it to a reusable function.
	# Solution: function walk(n){ for i in range(n): move() }
	#           n = (count up); turnRight(); walk(n); turnLeft(); walk(n)
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 8,
		"level_name": "Bridge Builder",
		"level_description": "Learn function parameters: write walk(n) once, then call it with any distance.",
		"difficulty": 2,
		"layout": """##########
##########
##########
###G######
###.######
#...######
#.########
#S########
##########
##########""",
		"variants": [
			"""##########
##########
##########
###G######
###.######
#...######
#.########
#S########
##########
##########""",
			"""##########
##########
####G#####
####.#####
####.#####
#....#####
#.########
#.########
#S########
##########""",
			"""##########
#####G####
#####.####
#####.####
#####.####
#.....####
#.########
#.########
#.########
#S########
##########"""
		],
		"starter_code": """# The path is a Z: UP n cells, EAST n cells, then UP n again.
# All three legs are the SAME length, but that length changes
# every run. Measure it once, then reuse it.
#
# A function PARAMETER lets you pass the distance in:
#
#   function walk(n) {
#       for (i in range(n)) { move() }
#   }
#
# Then call walk(n) with your measured value.

function walk(n) {
    for (i in range(n)) {
        move()
    }
}

n = 0
# Count the first leg, then: turnRight(), walk(n), turnLeft(), walk(n)
""",
		"solution_code": """function walk(n) {
    for (i in range(n)) {
        move()
    }
}
n = 0
while (frontIsClear()) {
    move()
    n = n + 1
}
turnRight()
walk(n)
turnLeft()
walk(n)
""",
		"hint_text": """Level 8 — Functions with Parameters

A parameter is an input to a function.
The function uses whatever value you give it:

  function walk(n) {
      for (i in range(n)) {
          move()
      }
  }

Now one function handles ANY distance:
  walk(2)   -> moves 2 steps
  walk(5)   -> moves 5 steps

The path is a Z with three EQUAL legs
(up, east, up). Measure the first leg into
a variable, then reuse it for the others:

  n = 0
  while (frontIsClear()) {
      move()
      n = n + 1
  }
  turnRight()
  walk(n)
  turnLeft()
  walk(n)

One function, called twice with a measured
value — no repeated loop code!"""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 9 — Nested Loops ("The Comb")
	# Concept : A loop inside a loop. Inner while climbs a tooth; outer
	#           for repeats across teeth.
	# Grid    : Comb with 3 vertical teeth on a base corridor. Tooth heights
	#           change per variant (so a fixed count fails), but the count
	#           of teeth stays 3.
	# Solution: for t in range(2): climb + descend + step to next tooth;
	#           then climb the final tooth to the goal.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 9,
		"level_name": "The Comb",
		"level_description": "Learn nested loops: a loop inside a loop sweeps each tooth of the comb.",
		"difficulty": 2,
		"layout": """##########
##########
##########
##########
#.#.#G####
#.#.#.####
#.#.#.####
#S....####
##########
##########""",
		"variants": [
			"""##########
##########
##########
##########
#.#.#G####
#.#.#.####
#.#.#.####
#S....####
##########
##########""",
			"""##########
##########
##########
###.######
###.#G####
#.#.#.####
#.#.#.####
#S....####
##########
##########""",
			"""##########
##########
##########
#####G####
#.###.####
#.#.#.####
#.#.#.####
#S....####
##########
##########"""
		],
		"starter_code": """# The comb has 3 vertical "teeth" joined by a base corridor.
# Climb each tooth, come back down, step to the next one,
# then climb the LAST tooth straight to the goal.
#
# This needs a loop INSIDE a loop:
#   - inner while: walk to the end of a tooth (any height)
#   - outer for:   repeat for each tooth
#
#   for (t in range(2)) {
#       while (frontIsClear()) { move() }   <- climb
#       turnBack()
#       while (frontIsClear()) { move() }   <- descend
#       turnLeft()
#       move()
#       move()
#       turnLeft()
#   }
#   while (frontIsClear()) { move() }        <- last tooth -> goal

for (t in range(2)) {
}
""",
		"solution_code": """for (t in range(2)) {
    while (frontIsClear()) {
        move()
    }
    turnBack()
    while (frontIsClear()) {
        move()
    }
    turnLeft()
    move()
    move()
    turnLeft()
}
while (frontIsClear()) {
    move()
}
""",
		"hint_text": """Level 9 — Nested Loops

A loop can live inside another loop. The
INNER loop runs to completion on every
pass of the OUTER loop.

This comb has 3 teeth joined at the base.
For each of the first two teeth: climb up,
climb back down, then step across the base
to the next tooth. Finally, climb the last
tooth to the goal.

  for (t in range(2)) {          <- outer
      while (frontIsClear()) {   <- inner: climb
          move()
      }
      turnBack()
      while (frontIsClear()) {   <- inner: descend
          move()
      }
      turnLeft()
      move()
      move()
      turnLeft()
  }
  while (frontIsClear()) {       <- last tooth
      move()
  }

The inner while handles teeth of ANY height,
so one piece of code clears every variation.
turnBack() spins you 180 degrees."""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 10 — Boolean Logic ("The Right Wall")
	# Concept : not / and / or, and the named right-hand-rule maze solver.
	# Grid    : Winding mazes (3 variants). Hard-coded turns fail; the
	#           sensor-driven follower adapts to each shape.
	# Solution: the right-hand rule.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 10,
		"level_name": "The Right Wall",
		"level_description": "Learn boolean logic (not, and, or) and the right-hand rule that solves any maze.",
		"difficulty": 2,
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
		"variants": [
			"""##########
#....#..G#
#.##.#.###
#.##.#.###
#.##...###
#.########
#.########
#.########
#S########
##########""",
			"""############
#.....#...G#
#.###.#.####
#...#.#.####
###.#...####
###.########
###.########
###.########
#S..########
############""",
			"""##########
#......#G#
#.####.#.#
#.#..#.#.#
#.#..#...#
#.#..#####
#.#.......#
#.########
#S########
##########"""
		],
		"starter_code": """# These mazes twist unpredictably — a fixed list of turns
# can never solve all three. You need a rule that READS the
# maze and decides as it goes.
#
# New operators:
#   not  -> flips true/false:   while (not goalReached())
#   and  -> true if BOTH true:  frontIsClear() and rightIsClear()
#   or   -> true if EITHER true
#
# The RIGHT-HAND RULE: keep your right hand on the wall.
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
		"solution_code": """while (not goalReached()) {
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
		"hint_text": """Level 10 — Boolean Logic

A boolean is a true/false value. Sensors
return booleans, and operators combine them:

  not goalReached()          <- flip: true until you arrive
  frontIsClear() and rightIsClear()   <- both true
  frontIsClear() or  rightIsClear()   <- at least one true

THE RIGHT-HAND RULE
Imagine dragging your right hand along the
wall. You always try to turn right; if you
can't, go straight; if you can't, turn left.
Loop that until you reach the goal:

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

Because it reads the real maze each step, the
SAME code solves all three variations — no
counting, no memorizing turns."""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 11 — Hazard Dodge ("Danger Zone")
	# Concept : Navigate mazes with hazards — wrong turns kill you.
	#           The right-hand rule still works because hazards are walls
	#           to the algorithm (not walkable), but the student must
	#           understand that sensors treat hazards as blocked.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 11,
		"level_name": "Danger Zone",
		"level_description": "Apply the right-hand rule with hazards: sensors treat danger cells as walls.",
		"difficulty": 4,
		"layout": """##########
#G..#.####
#.#.#.####
#.#...####
#.#X######
#.#.######
#...######
###..#####
#S...#####
##########""",
		"variants": [
			"""##########
#G..#.####
#.#.#.####
#.#...####
#.#X######
#.#.######
#...######
###..#####
#S...#####
##########""",
			"""##########
####..G###
####.#.###
#....#.###
#.#X.#.###
#.##.#.###
#....#.###
######.###
#S.....###
##########""",
			"""############
###G.....###
###.####.###
###.#..#.###
###.#.X#.###
###.#..#.###
###.####.###
###......###
#S..########
############"""
		],
		"starter_code": """# Hazards (X) will kill LediBug!
# Sensors treat hazards as walls — frontIsClear() returns false.
# The safe path avoids all hazards.
#
# The right-hand rule still works here:
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
		"solution_code": """while (not goalReached()) {
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
		"hint_text": """Level 11 — Hazard Dodge

Hazards (red X cells) kill LediBug instantly!

But here's the key insight:
  frontIsClear() returns FALSE for hazards.
  rightIsClear() returns FALSE for hazards.
  leftIsClear() returns FALSE for hazards.

Sensors treat hazards like walls — so the
right-hand rule naturally avoids them!

The challenge: each variation has hazards
in different spots, blocking the 'obvious'
path. Your code must handle all three.

  while (not goalReached()) {
      if (rightIsClear()) {
          turnRight()
          move()
      } elif (frontIsClear()) {
          move()
      } else {
          turnLeft()
      }
  }"""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 12 — Dead Ends ("Backtracker")
	# Concept : Mazes with dead ends that require the bug to turn around.
	#           Tests that the student's algorithm handles the case where
	#           right is blocked AND front is blocked — must turn left
	#           (possibly multiple times) to escape a dead end.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 12,
		"level_name": "Backtracker",
		"level_description": "Master dead ends: watch the right-hand rule turn around and escape on its own.",
		"difficulty": 4,
		"layout": """##########
##G..#####
##.#.#####
##.#.#####
##.#..####
##.##.####
##....####
##.#######
#S.#######
##########""",
		"variants": [
			"""##########
##G..#####
##.#.#####
##.#.#####
##.#..####
##.##.####
##....####
##.#######
#S.#######
##########""",
			"""##########
#######G##
#######.##
###.....##
###.##.###
###.##.###
#......###
#.########
#S########
##########""",
			"""############
########G.##
########.###
##.......###
##.##.######
##.##.######
##....######
##.#########
#S.#########
############"""
		],
		"starter_code": """# Dead ends are tricky — LediBug must turn around.
# When front is blocked AND right is blocked, turnLeft().
# If left is also blocked? turnLeft() again (turns 180°).
#
# The right-hand rule handles dead ends naturally:
# it keeps turning left until a path opens up.

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
		"solution_code": """while (not goalReached()) {
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
		"hint_text": """Level 12 — Dead Ends

Dead ends are corridors with only one exit.
When LediBug enters one, it must turn around.

How the right-hand rule handles this:
  1. rightIsClear()? No → skip
  2. frontIsClear()? No → skip
  3. else: turnLeft()

On the next loop iteration:
  1. rightIsClear()? No → skip
  2. frontIsClear()? Maybe! If yes, move.
     If not, turnLeft() again (now facing back).

Eventually LediBug faces the exit and moves.
The algorithm handles 1, 2, or 3 turn-arounds
automatically — no special dead-end code needed!

Each variant has dead ends in different places.
One code solves all three."""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 13 — Structuring with Functions + LAVA ("Lava Field")
	# Concept : Move the right-hand-rule step into a named function and call
	#           it from a small loop — clean, readable structure at scale.
	#           NEW HAZARD: the corridor walls are LAVA (L). Sensors treat
	#           lava exactly like a wall, so the wall-follower steers clear.
	# Solution: function step(){ right-hand step }; while(not goal) step()
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 13,
		"level_name": "Lava Field",
		"level_description": "Structure code with a function — and meet LAVA. Your wall-follower avoids the deadly cells automatically.",
		"difficulty": 5,
		"layout": """##########
#........#
#LLLLLLL.#
#........#
#.LLLLLLL#
#........#
#LLLLLLL.#
#......G.#
#.LLLLLLL#
#S.......#
##########""",
		"variants": [
			"""##########
#........#
#LLLLLLL.#
#........#
#.LLLLLLL#
#........#
#LLLLLLL.#
#......G.#
#.LLLLLLL#
#S.......#
##########""",
			"""##########
#........#
#.LLLL.L.#
#.L..L.L.#
#.L..L.L.#
#.L..L.LG#
#.L..L...#
#.LLLL.LL#
#S.......#
##########""",
			"""############
#..........#
#LLLLLLLLL.#
#..........#
#.LLLLLLLLL#
#..........#
#LLLLLLLLL.#
#........G.#
#.LLLLLLLLL#
#S.........#
############"""
		],
		"starter_code": """# These mazes are large and open — and the walls are now
# LAVA (the red cells). Touching lava ends the run!
#
# Good news: rightIsClear(), frontIsClear() and leftIsClear()
# treat lava EXACTLY like a wall, so the right-hand rule keeps
# you safely in the open corridors without any extra code.
#
# The right-hand rule still works, but a long loop body gets
# hard to read. Good practice: give the rule a NAME by putting
# it in a function, then call it from a tiny loop.
#
#   function step() {
#       ... one right-hand-rule step ...
#   }
#   while (not goalReached()) {
#       step()
#   }

function step() {
    if (rightIsClear()) {
        turnRight()
        move()
    } elif (frontIsClear()) {
        move()
    } else {
        turnLeft()
    }
}
while (not goalReached()) {
    step()
}
""",
		"solution_code": """function step() {
    if (rightIsClear()) {
        turnRight()
        move()
    } elif (frontIsClear()) {
        move()
    } else {
        turnLeft()
    }
}
while (not goalReached()) {
    step()
}
""",
		"hint_text": """Level 13 — Structuring with Functions

As programs grow, readability matters.
Instead of one big loop body, give your
logic a NAME by wrapping it in a function:

  function step() {
      if (rightIsClear()) {
          turnRight()
          move()
      } elif (frontIsClear()) {
          move()
      } else {
          turnLeft()
      }
  }

Now the main loop reads like plain English:

  while (not goalReached()) {
      step()
  }

The corridors here are lined with LAVA — but
rightIsClear() and frontIsClear() see lava just
like a wall, so the SAME wall-follower steers
around it safely. No extra danger-handling code!

Same behaviour as before, but the intent is
obvious at a glance. These lava mazes still
yield to the right-hand rule — you're just
organizing it more cleanly. One function,
called every step, solves all variations."""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 14 — Do-While ("Inward Spiral")
	# Concept : do { ... } while (cond) — run the body once, THEN check.
	# Grid    : Spiral mazes; the bug always takes at least one step before
	#           it could possibly be on the goal.
	# Solution: do { right-hand step } while (not goalReached())
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 14,
		"level_name": "Inward Spiral",
		"level_description": "Learn do-while: run the body once before checking the condition.",
		"difficulty": 5,
		"layout": """##########
#........#
#.######.#
#.#....#.#
#.#.G#.#.#
#.#..#.#.#
#.####.#.#
#......#.#
########.#
#S.......#
##########""",
		"variants": [
			"""##########
#........#
#.######.#
#.#....#.#
#.#.G#.#.#
#.#..#.#.#
#.####.#.#
#......#.#
########.#
#S.......#
##########""",
			"""############
#..........#
##########.#
#..........#
#.##########
#..........#
##########.#
#.......G..#
#.##########
#..........#
##########.#
#S.........#
############""",
			"""##########
#........#
########.#
#......#.#
#.####.#.#
#.#G.#.#.#
#.##.#.#.#
#....#.#.#
######.#.#
#S.....#.#
##########"""
		],
		"starter_code": """# The goal is at the CENTER of a spiral, so LediBug always
# has to take at least one step before it could be on the goal.
#
# A do-while loop fits perfectly: it runs the body ONCE,
# and only THEN checks whether to repeat.
#
#   do {
#       ... one right-hand-rule step ...
#   } while (not goalReached())
#
# Compare to a while loop, which checks the condition FIRST.

do {
    if (rightIsClear()) {
        turnRight()
        move()
    } elif (frontIsClear()) {
        move()
    } else {
        turnLeft()
    }
} while (not goalReached())
""",
		"solution_code": """do {
    if (rightIsClear()) {
        turnRight()
        move()
    } elif (frontIsClear()) {
        move()
    } else {
        turnLeft()
    }
} while (not goalReached())
""",
		"hint_text": """Level 14 — Do-While

A normal while loop checks its condition
BEFORE running the body:

  while (not goalReached()) { ... }

A do-while loop runs the body ONCE FIRST,
then checks whether to repeat:

  do {
      ... step ...
  } while (not goalReached())

The difference: the body always runs at
least once. That fits a spiral perfectly —
the goal is at the center, so you must move
before you could ever arrive.

  do {
      if (rightIsClear()) {
          turnRight()
          move()
      } elif (frontIsClear()) {
          move()
      } else {
          turnLeft()
      }
  } while (not goalReached())

Same right-hand rule, new loop shape. Each
variant is a different spiral; one do-while
solves them all."""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 15 — Ultimate Maze ("Gauntlet")
	# Concept : Everything combined — large complex mazes with hazards,
	#           dead ends, wide areas, and spirals. The final challenge.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 15,
		"level_name": "The Gauntlet",
		"level_description": "Capstone: combine loops, functions, sensors and the right-hand rule on the biggest mazes.",
		"difficulty": 5,
		"layout": """############
#..........#
#.########.#
#.#......#.#
#.#.####.#.#
#.#.#..#.#.#
#.#.#G.#.#.#
#.#.##.#.#.#
#.#....#.#.#
#.######.#.#
#........#.#
##########.#
#S.........#
############""",
		"variants": [
			"""############
#..........#
#.########.#
#.#......#.#
#.#.####.#.#
#.#.#..#.#.#
#.#.#G.#.#.#
#.#.##.#.#.#
#.#....#.#.#
#.######.#.#
#........#.#
##########.#
#S.........#
############""",
			"""############
#..........#
#.######.#.#
#.#....#.#.#
#.#.##.#.#.#
#.#..#.#.#.#
#.#..#.#.#G#
#.####.#...#
#......#.###
########.###
#S.......###
############""",
			"""##############
#............#
#.##########.#
#.#........#.#
#.#.######.#.#
#.#.#....#.#.#
#.#.#.G#.#.#.#
#.#.#..#.#.#.#
#.#.####.#.#.#
#.#......#.#.#
#.########.#.#
#..........#.#
############.#
#S...........#
##############"""
		],
		"starter_code": """# The Gauntlet — the final test of your algorithm.
# These are the largest and most complex mazes.
# Multiple layers of walls, nested corridors,
# and the goal buried deep inside.
#
# If your right-hand rule works here,
# it works EVERYWHERE.
#
# function navigate() — wrap it in a function
# to show you've mastered the concept!

function navigate() {
    if (rightIsClear()) {
        turnRight()
        move()
    } elif (frontIsClear()) {
        move()
    } else {
        turnLeft()
    }
}

while (not goalReached()) {
    navigate()
}
""",
		"solution_code": """while (not goalReached()) {
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
		"hint_text": """Level 15 — The Gauntlet

Congratulations on reaching the final level!

These are large, multi-layered mazes.
The goal is deeply nested inside concentric
walls — the longest paths yet.

By now you know the secret:
  The right-hand rule solves ANY maze
  that has a connected path from start
  to goal (no islands).

What you've learned across all levels:
  1. Sequential commands (levels 1-2)
  2. Loops: for and while (levels 2-3)
  3. Sensors and conditions (levels 3-4)
  4. If/elif/else branching (level 4)
  5. Functions (level 5)
  6. Nested loops (level 6)
  7. Variables (level 7)
  8. Parameters (level 8)
  9. Boolean logic (level 9)
  10-15. Combining everything!

One algorithm. Infinite mazes. That's
the power of programming."""
	},

	# ──────────────────────────────────────────────────────────────────────
	# LEVEL 16: The Locked Gate — introduces KEYS and DOORS
	# A 🔑 KEY is picked up automatically just by walking over it.
	# A 🚪 DOOR is locked: stepping into it spends one key to open it.
	# A wall-follower solves these because the key always sits on the
	# path BEFORE the door it unlocks.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 16,
		"level_name": "The Locked Gate",
		"level_description": "Meet KEYS and DOORS. Grab the key, then the door opens itself when you walk into it.",
		"difficulty": 4,
		"layout": """##########
####G#####
####D#####
####.#####
####.#####
####K#####
####.#####
####.#####
####S#####
##########""",
		"variants": [
			"""##########
####G#####
####D#####
####.#####
####.#####
####K#####
####.#####
####.#####
####S#####
##########""",
			"""##########
##.K.D.G##
##.#######
##.#######
##.#######
##.#######
##.#######
##S#######
##########"""
		],
		"starter_code": """# NEW: keys and doors!
#   🔑 KEY  — walk over it and LediBug grabs it automatically.
#   🚪 DOOR — locked. Walk into it and it spends ONE key to open.
#
# The key always sits on the path BEFORE the door, so you don't
# need anything fancy — just follow the corridor to the goal.
#
# You can also ASK if you're carrying a key with the new sensor:
#       hasKey()   ->  true once you've picked one up
#
# Walk forward until a wall stops you, then turn to follow the path:

while (not goalReached()) {
    while (frontIsClear()) {
        move()
    }
    if (rightIsClear()) {
        turnRight()
    } else {
        turnLeft()
    }
}
""",
		"solution_code": """while (not goalReached()) {
    while (frontIsClear()) {
        move()
    }
    if (rightIsClear()) {
        turnRight()
    } else {
        turnLeft()
    }
}
""",
		"hint_text": """Level 16 — The Locked Gate

Two new tiles appear here:
  🔑 KEY  — you collect it just by stepping on it.
  🚪 DOOR — locked until you spend a key on it.
            Walking into a door opens it automatically
            (it uses up one key).

The key is always on the path before its door,
so a normal wall-follower walks right through:

  1. Move forward while the way ahead is clear.
  2. When a wall blocks you, turn toward the
     open side (right if you can, otherwise left).
  3. Repeat until you reach the goal.

Tip: the new sensor hasKey() reports true once
you're carrying a key — handy for making choices."""
	},

	# ──────────────────────────────────────────────────────────────────────
	# LEVEL 17: Double Lock — two keys, two doors on one winding corridor.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 17,
		"level_name": "Double Lock",
		"level_description": "Two keys, two doors. Each key opens the next gate — collect them in order along the path.",
		"difficulty": 4,
		"layout": """############
#####G######
#####D######
#####.######
#####K######
#####.######
#####D######
#####.######
#####K######
#####.######
#####S######
############""",
		"variants": [
			"""############
#####G######
#####D######
#####.######
#####K######
#####.######
#####D######
#####.######
#####K######
#####.######
#####S######
############""",
			"""############
#...K..D..G#
#.##########
#D##########
#.##########
#K##########
#.##########
#S##########
############"""
		],
		"starter_code": """# Two locks this time! There are TWO keys and TWO doors.
# Every key sits just before the door it opens, so if you
# keep following the corridor you'll always be holding a key
# right when you reach a gate.
#
# Same wall-follower as before — it doesn't care how many
# doors there are:

while (not goalReached()) {
    while (frontIsClear()) {
        move()
    }
    if (rightIsClear()) {
        turnRight()
    } else {
        turnLeft()
    }
}
""",
		"solution_code": """while (not goalReached()) {
    while (frontIsClear()) {
        move()
    }
    if (rightIsClear()) {
        turnRight()
    } else {
        turnLeft()
    }
}
""",
		"hint_text": """Level 17 — Double Lock

Now there are TWO keys and TWO doors.

Each door spends exactly one key, and the keys are
laid out so you always pick one up just before you
need it. That means the same simple rule still works:

  • Go forward while you can.
  • Turn at every wall.
  • Walk straight into the doors — each one opens
    itself with the key you're carrying.

You never have to count keys yourself; LediBug
spends them automatically, one per door."""
	},

	# ──────────────────────────────────────────────────────────────────────
	# LEVEL 18: The Vault Run — a longer Z-shaped corridor with keys/doors.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 18,
		"level_name": "The Vault Run",
		"level_description": "A longer, winding route with keys and doors around every corner. Trust your wall-follower.",
		"difficulty": 5,
		"layout": """##########
########G#
########.#
########D#
########.#
#...D.K..#
#.########
#K########
#.########
#S########
##########""",
		"variants": [
			"""##########
########G#
########.#
########D#
########.#
#...D.K..#
#.########
#K########
#.########
#S########
##########""",
			"""##########
#G########
#.########
#D########
#.########
#..K.D...#
########.#
########K#
########.#
########S#
##########"""
		],
		"starter_code": """# The route twists around several corners now, and the
# keys and doors are spread along the way. Don't try to
# plan every turn by hand — let the wall-follower do it.
#
# As long as you turn at every wall and walk straight into
# the doors, you'll collect each key in time to open the
# next gate.

while (not goalReached()) {
    while (frontIsClear()) {
        move()
    }
    if (rightIsClear()) {
        turnRight()
    } else {
        turnLeft()
    }
}
""",
		"solution_code": """while (not goalReached()) {
    while (frontIsClear()) {
        move()
    }
    if (rightIsClear()) {
        turnRight()
    } else {
        turnLeft()
    }
}
""",
		"hint_text": """Level 18 — The Vault Run

A longer, Z-shaped corridor with keys and doors
tucked around the bends.

The trick is the same one you already know:
follow the corridor. Move forward until a wall
stops you, turn toward the opening, and repeat.

Because every key is placed before the door it
unlocks, you'll always be carrying what you need
exactly when you reach a gate.

One algorithm handles every twist."""
	},

	# ──────────────────────────────────────────────────────────────────────
	# LEVEL 19: Lava Locks — keys/doors plus deadly LAVA lining the path.
	# Sensors treat lava like a wall, so the follower stays safe.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 19,
		"level_name": "Lava Locks",
		"level_description": "Keys, doors AND lava together. Your sensors avoid lava like a wall, so the same rule keeps you safe.",
		"difficulty": 5,
		"layout": """##########
###LGL####
###LDL####
###L.L####
###LKL####
###L.L####
###L.L####
###LSL####
##########""",
		"variants": [
			"""##########
###LGL####
###LDL####
###L.L####
###LKL####
###L.L####
###L.L####
###LSL####
##########""",
			"""##########
##....D.G#
##.LLLLLL#
#L.L######
#LKL######
#L.L######
#L.L######
#LSL######
##########"""
		],
		"starter_code": """# Everything at once: keys, doors, AND lava (the red cells).
# Touching lava ends the run instantly!
#
# Good news — frontIsClear(), rightIsClear() and leftIsClear()
# treat lava EXACTLY like a wall, so the wall-follower keeps you
# safely on the open path. And the key still sits before the
# door, so the gate opens as you walk into it.
#
# No new code needed — your trusty corridor follower handles it:

while (not goalReached()) {
    while (frontIsClear()) {
        move()
    }
    if (rightIsClear()) {
        turnRight()
    } else {
        turnLeft()
    }
}
""",
		"solution_code": """while (not goalReached()) {
    while (frontIsClear()) {
        move()
    }
    if (rightIsClear()) {
        turnRight()
    } else {
        turnLeft()
    }
}
""",
		"hint_text": """Level 19 — Lava Locks

This level combines three ideas:
  🔑 keys, 🚪 doors, and 🔥 LAVA.

Lava is deadly — one step ends the run. But your
sensors already know that: they report lava as
"not clear", just like a wall. So a wall-follower
naturally hugs the safe corridor and never steps
into the fire.

The key is on the path before the door, so the
gate opens itself as you pass through.

Same loop, more danger — and you're ready for it."""
	},

	# ──────────────────────────────────────────────────────────────────────
	# LEVEL 20: The Grand Vault — capstone: 2 keys, 2 doors, lava, winding.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 20,
		"level_name": "The Grand Vault",
		"level_description": "The final challenge: two keys, two doors, lava and twisting corridors. One algorithm to rule them all.",
		"difficulty": 5,
		"layout": """##########
###LGL####
###LDL####
###L.L####
###LKL####
###L.L####
###LDL####
###L.L####
###LKL####
###L.L####
###LSL####
##########""",
		"variants": [
			"""##########
###LGL####
###LDL####
###L.L####
###LKL####
###L.L####
###LDL####
###L.L####
###LKL####
###L.L####
###LSL####
##########""",
			"""##########
#G########
#.L#######
#D########
#.L#######
#..K.D...#
######L#.#
#######LK#
########.#
########S#
##########"""
		],
		"starter_code": """# THE GRAND VAULT — the final test.
# Two keys, two doors, lava walls, and winding corridors,
# all in one maze.
#
# You have everything you need. The same algorithm you've
# trusted all along solves it: keys are collected on the way,
# doors open when you walk into them, and lava reads as a wall
# to your sensors.
#
# Optional flourish: wrap the rule in a function to show you've
# mastered it.

function step() {
    while (frontIsClear()) {
        move()
    }
    if (rightIsClear()) {
        turnRight()
    } else {
        turnLeft()
    }
}

while (not goalReached()) {
    step()
}
""",
		"solution_code": """while (not goalReached()) {
    while (frontIsClear()) {
        move()
    }
    if (rightIsClear()) {
        turnRight()
    } else {
        turnLeft()
    }
}
""",
		"hint_text": """Level 20 — The Grand Vault

The grand finale! This maze brings together
everything you've learned:

  🔑 two keys to collect
  🚪 two doors to open
  🔥 lava to avoid
  ↪ corridors that twist and turn

And yet the solution hasn't changed. One simple
wall-following loop:

  • move forward while the path is clear
  • turn at every wall
  • walk straight into the doors

Keys are gathered automatically, doors spend them
for you, and lava counts as a wall to your sensors.

That's the real lesson of LediBug:
a good algorithm solves a whole family of puzzles,
not just one. Congratulations — you've mastered it!"""
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

func get_level_variants(level_id: int) -> Array[String]:
	"""Return all layouts for a level; falls back to single-layout levels."""
	var lv = get_level(level_id)
	if lv.is_empty():
		return []
	if lv.has("variants") and lv["variants"] is Array and lv["variants"].size() > 0:
		var variants: Array[String] = []
		for layout in lv["variants"]:
			variants.append(str(layout))
		return variants
	return [str(lv.get("layout", ""))]

func get_level_variant_count(level_id: int) -> int:
	return get_level_variants(level_id).size()

func get_solution_code(level_id: int) -> String:
	"""Return the working solution for a level (used for DEV_MODE and automated testing)."""
	var lv = get_level(level_id)
	return lv.get("solution_code", "") if not lv.is_empty() else ""

func get_starter_or_solution(level_id: int) -> String:
	"""Return solution_code if DEV_MODE is on, otherwise starter_code."""
	var lv = get_level(level_id)
	if lv.is_empty():
		return ""
	if DEV_MODE:
		return lv.get("solution_code", lv.get("starter_code", ""))
	return lv.get("starter_code", "")
