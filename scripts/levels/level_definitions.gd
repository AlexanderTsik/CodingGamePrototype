# Level Definitions — Tutorial Levels
#
# Curriculum overview (one concept at a time, several levels per concept):
#   Phase 1 — Sequencing        levels 1–3   (move, turnRight, turnLeft)
#   Phase 2 — Loops             levels 4–7   (for, then while + sensors)
#   Phase 3 — Conditionals      levels 8–10  (if/else, elif, goalReached)
#   Phase 4 — State & Variables levels 11–13 (teleporters, counting, reuse)
#   Phase 5 — Functions         levels 14–15 (function, parameters)
#   Phase 6 — Keys & Doors      levels 16–18 (sequencing state, hasKey)
#   Phase 7 — Capstones         levels 19–20 (right-hand rule, everything)
#
# Anti-cheat design rules used throughout:
#   • Levels 1–5 are single-layout warm-ups (the engine only activates
#     variants for levels 6+), so they stay small enough that hand-typing
#     commands is the LESSON, not a shortcut.
#   • From level 6 on, every level ships multiple `variants` whose corridor
#     lengths / open directions / key positions differ. One program must
#     solve ALL variants in a single run, so hard-coded step counts and
#     memorized turn sequences cannot work — loops, sensors and logic are
#     genuinely required.
#   • LAVA (L) caps corridors at turning points. A wall silently forgives an
#     over-counted program (the bug just bumps); lava does not. This is what
#     makes "type move() 15 times" a losing strategy instead of a tedious one.

extends Node

# Set to true during development to pre-fill levels with working solutions.
# Set to false before production / release builds.
const DEV_MODE = true

var all_levels = [
	# ──────────────────────────────────────────────────────────────────────
	# Level 1 — move()
	# Concept : A program is a list of commands, executed top to bottom.
	# Grid    : Straight corridor, 3 cells. Nothing can go wrong — the
	#           whole point is typing your very first commands.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 1,
		"level_name": "First Steps",
		"level_description": "Your first program: move() steps one cell forward. Three steps to the flag.",
		"difficulty": 1,
		"layout": """##########
##########
##########
####G#####
####.#####
####.#####
####S#####
##########
##########
##########""",
		"starter_code": """# Welcome! LediBug always starts facing UP.
# move() — take one step forward.
#
# The goal (G) is 3 cells ahead. One move() is
# already written — add the rest!
move()
""",
		"solution_code": """move()
move()
move()
""",
		"hint_text": """Level 1 — move()

A program is a list of commands.
The computer runs them one at a time,
from the top line to the bottom line.

move() makes LediBug take exactly ONE
step forward in the direction it faces.

The bug starts facing UP, and the goal
is 3 cells straight ahead. So you need
move() three times — once per cell.

Type it, press Run, and watch each line
execute in order!"""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 2 — turnRight()
	# Concept : Turning changes direction WITHOUT moving. Order matters:
	#           turn too early or too late and you face a wall.
	# Grid    : L-shape — up 2, then east 3.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 2,
		"level_name": "Turn the Corner",
		"level_description": "Learn turnRight(): turning changes your direction but not your position.",
		"difficulty": 1,
		"layout": """##########
##########
##########
####...G##
####.#####
####S#####
##########
##########
##########
##########""",
		"starter_code": """# New command:
# turnRight() — rotate 90 degrees clockwise (no step!)
#
# The corridor goes UP 2 cells, then RIGHT 3 cells.
# Walk up, turn, then walk to the goal.
move()
move()
""",
		"solution_code": """move()
move()
turnRight()
move()
move()
move()
""",
		"hint_text": """Level 2 — turnRight()

turnRight() spins LediBug 90 degrees
clockwise. It does NOT take a step —
turning and moving are separate commands.

The corridor is an L:
  • 2 cells UP
  • then 3 cells RIGHT

So the program is:
  move()  move()          <- walk up
  turnRight()             <- face east
  move()  move()  move()  <- walk to G

Try turning after only one move() and
you'll bump into the wall — the ORDER
of commands matters!"""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 3 — turnLeft()
	# Concept : Both turn directions; a zig-zag needs opposite turns.
	# Grid    : Zig-zag — up 2, right 2, up 2.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 3,
		"level_name": "Zig, Then Zag",
		"level_description": "Learn turnLeft(): steer through a zig-zag using both turn directions.",
		"difficulty": 1,
		"layout": """##########
##########
##########
#####G####
#####.####
###...####
###.######
###S######
##########
##########""",
		"starter_code": """# New command:
# turnLeft() — rotate 90 degrees counter-clockwise.
#
# The path zig-zags: UP 2, RIGHT 2, then UP 2 again.
# After going right you'll need turnLeft() to face
# up again. Finish the program!
move()
move()
turnRight()
""",
		"solution_code": """move()
move()
turnRight()
move()
move()
turnLeft()
move()
move()
""",
		"hint_text": """Level 3 — turnLeft()

turnLeft() is the mirror of turnRight():
90 degrees counter-clockwise.

The corridor zig-zags:
  • UP 2      (you start facing up)
  • RIGHT 2   (turnRight, then move)
  • UP 2      (turnLeft, then move)

After walking RIGHT, you are facing east.
To face up again you turn LEFT — not right!
Picture yourself walking the path and ask
at each corner: which way do I rotate?

  move() move()
  turnRight()
  move() move()
  turnLeft()
  move() move()"""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 4 — for loops
	# Concept : Repeat a command N times without typing it N times.
	# Grid    : One straight 7-cell corridor. Typing move() seven times
	#           works but hurts — the loop is the better tool.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 4,
		"level_name": "The Long March",
		"level_description": "Learn for loops: repeat a command N times with three lines of code.",
		"difficulty": 1,
		"layout": """##########
####G#####
####.#####
####.#####
####.#####
####.#####
####.#####
####.#####
####S#####
##########""",
		"starter_code": """# The goal is SEVEN cells ahead. You could type
# move() seven times... or teach the computer to
# repeat for you:
#
#   for (i in range(7)) {
#       move()
#   }
#
# This runs move() exactly 7 times. Try it!
""",
		"solution_code": """for (i in range(7)) {
    move()
}
""",
		"hint_text": """Level 4 — for loops

A for loop repeats its body a fixed
number of times:

  for (i in range(7)) {
      move()
  }

Everything between { and } is the BODY.
range(7) means "run the body 7 times".

This does exactly what seven move() lines
do — but it's three lines, and changing
one number changes the distance.

Programmers hate repeating themselves.
Loops are how they avoid it!"""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 5 — for loops with a multi-command body
	# Concept : A loop body can hold SEVERAL commands; the whole block
	#           repeats as a unit.
	# Grid    : A 4-step staircase — the same up-right motif four times,
	#           then one last step to the goal.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 5,
		"level_name": "Loop the Loop",
		"level_description": "Put several commands inside one for loop — the whole block repeats as a unit.",
		"difficulty": 1,
		"layout": """##########
##########
##########
######G###
#####..###
####..####
###..#####
##..######
##S#######
##########""",
		"starter_code": """# A staircase! Look at the shape: the SAME pattern
# repeats 4 times —
#     up 1, turn right, right 1, turn left
#
# A loop body can hold many commands:
#
#   for (i in range(4)) {
#       move()
#       turnRight()
#       move()
#       turnLeft()
#   }
#
# After the loop, ONE more move() reaches the goal.
""",
		"solution_code": """for (i in range(4)) {
    move()
    turnRight()
    move()
    turnLeft()
}
move()
""",
		"hint_text": """Level 5 — bigger loop bodies

A loop body isn't limited to one command.
ALL the lines between { and } repeat
together, in order, every time around.

One stair-step of this staircase is:
  move()        <- up 1
  turnRight()
  move()        <- right 1
  turnLeft()    <- face up again

The staircase has 4 identical steps, so:

  for (i in range(4)) {
      move()
      turnRight()
      move()
      turnLeft()
  }
  move()          <- final step onto G

Without the loop that's 17 lines.
With it: 7. See the pattern, loop it!"""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 6 — while + frontIsClear()   (FIRST MULTI-VARIANT LEVEL)
	# Concept : Repeat while a condition holds — walk until blocked.
	# Grid    : A straight corridor whose LENGTH CHANGES each variant
	#           (3 / 5 / 6). Lava sits past the goal, so over-counted
	#           programs burn. Only a sensor loop solves all three.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 6,
		"level_name": "Trust Your Sensors",
		"level_description": "Learn while loops and frontIsClear(): walk until blocked — no counting allowed, the corridor length changes every variant!",
		"difficulty": 2,
		"layout": """##########
##########
##########
##########
####G.####
####L.####
####..####
####S#####
##########
##########""",
		"variants": [
			"""##########
##########
##########
##########
####G.####
####L.####
####..####
####S#####
##########
##########""",
			"""##########
##########
##########
####G.####
####L.####
####..####
####.#####
####.#####
####S#####
##########""",
			"""##########
##########
####G.####
####L.####
####..####
####.#####
####.#####
####.#####
####S#####
##########"""
		],
		"starter_code": """# BIG CHANGE: this level has THREE variants. Your ONE
# program must solve all of them — and the corridor is a
# different length in each! Counting steps cannot work.
#
# Meet your first SENSOR:
#   frontIsClear() — true if the cell ahead is safe to enter
#
# And a new loop that repeats WHILE a condition is true:
#
#   while (frontIsClear()) {
#       move()
#   }
#
# One more thing: the orange cell past the goal is LAVA.
# Walk one step too far and the run ends. Sensors see lava
# as blocked — so trust them, not your step count!
""",
		"solution_code": """while (frontIsClear()) {
       move()
   }
   turnRight()
   move()
   turnLeft()
   move()
   move()
   turnLeft()
   move()
""",
		"hint_text": """Level 6 — while + sensors

A while loop repeats AS LONG AS its
condition is true:

  while (frontIsClear()) {
      move()
  }

frontIsClear() is a SENSOR — it looks at
the cell directly ahead and answers true
(open) or false (wall or lava).

Why not for (i in range(...))? Because
this level has 3 VARIANTS with corridor
lengths 3, 5 and 6. A fixed count that
works on one variant walks straight into
the LAVA past the goal on another.

The while loop doesn't care about length:
it walks, checks, walks, checks... and
stops exactly when the way is blocked —
which happens right on the goal.

Code that READS the world beats code
that memorizes it."""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 7 — while loops around a corner
	# Concept : Chain sensor loops: walk-until-blocked, turn, repeat.
	# Grid    : L-shape; BOTH leg lengths change per variant (3+3 / 5+2 /
	#           2+5). Lava caps the corner and the goal, so any hard-coded
	#           count dies on at least one variant.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 7,
		"level_name": "Bend After Bend",
		"level_description": "Chain while loops: walk until blocked, turn, walk again. Leg lengths change every variant.",
		"difficulty": 2,
		"layout": """##########
##########
##########
##L#######
##...GL###
##.#######
##.#######
##S#######
##########
##########""",
		"variants": [
			"""##########
##########
##########
##L#######
##...GL###
##.#######
##.#######
##S#######
##########
##########""",
			"""##########
##########
##L#######
##..GL####
##.#######
##.#######
##.#######
##.#######
##S#######
##########""",
			"""##########
##########
##########
##########
##L#######
##.....GL#
##.#######
##S#######
##########
##########"""
		],
		"starter_code": """# An L-shaped corridor — but BOTH legs change length
# across the three variants (3+3, 5+2, 2+5). And both
# the corner and the goal are capped with LAVA, so a
# wrong count is fatal.
#
# The pattern that always works:
#   1. while the front is clear — walk.
#   2. blocked? turn toward the goal.
#   3. walk again until blocked.
#
while (frontIsClear()) {
    move()
}
turnRight()
# ... one more while loop finishes the job
""",
		"solution_code": """while (frontIsClear()) {
    move()
}
turnRight()
while (frontIsClear()) {
    move()
}
""",
		"hint_text": """Level 7 — chaining sensor loops

One while loop walks ONE straight segment.
For a corridor with a corner, chain them:

  while (frontIsClear()) {
      move()
  }
  turnRight()
  while (frontIsClear()) {
      move()
  }

The first loop stops at the corner (the
lava ahead reads as blocked — sensors
treat lava exactly like a wall).
Then you turn and the second loop walks
the east leg, stopping on the goal.

Each variant has different leg lengths:
3+3, 5+2, 2+5. The SAME two loops handle
all of them, because they measure nothing
and sense everything."""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 8 — if / else
	# Concept : Branch on a sensor: turn toward whichever side is open.
	# Grid    : T-junction. The open side SWAPS between variants, and the
	#           closed side is LAVA — guessing a fixed turn kills the run
	#           on the other variant.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 8,
		"level_name": "Fork in the Road",
		"level_description": "Learn if/else: sense which side of the junction is open — it changes every variant, and the wrong side is lava.",
		"difficulty": 2,
		"layout": """##########
##########
##########
##########
##########
###L..G###
####.#####
####.#####
####S#####
##########""",
		"variants": [
			"""##########
##########
##########
##########
##########
###L..G###
####.#####
####.#####
####S#####
##########""",
			"""##########
##########
##########
##########
##########
##G..L####
####.#####
####.#####
####S#####
##########""",
			"""##########
##########
##########
##########
###L...G##
####.#####
####.#####
####.#####
####S#####
##########"""
		],
		"starter_code": """# The corridor ends at a T-junction. One side leads to
# the goal, the other side is LAVA — and which is which
# SWAPS between variants! Guessing means burning.
#
# New sensors:
#   rightIsClear() — true if the cell to your right is open
#   leftIsClear()  — true if the cell to your left is open
#
# New statement — do one thing OR the other:
#
#   if (rightIsClear()) {
#       turnRight()
#   } else {
#       turnLeft()
#   }
#
while (frontIsClear()) {
    move()
}
# ... now decide which way to turn, then walk to the goal
""",
		"solution_code": """while (frontIsClear()) {
    move()
}
if (rightIsClear()) {
    turnRight()
} else {
    turnLeft()
}
while (frontIsClear()) {
    move()
}
""",
		"hint_text": """Level 8 — if / else

An if/else runs exactly ONE of its two
blocks, chosen by a condition:

  if (rightIsClear()) {
      turnRight()     <- right side open
  } else {
      turnLeft()      <- right side blocked
  }

At this T-junction one side is open and
the other is LAVA. In variant 1 the goal
is to the RIGHT; in variant 2 it's to the
LEFT. Hard-coding turnRight() means
walking into lava on variant 2!

rightIsClear() reads lava as blocked, so
the if/else always picks the safe side.

Full plan:
  1. while + move — walk to the junction
  2. if/else — turn toward the open side
  3. while + move — walk to the goal

One program, three variants, zero guesses."""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 9 — if / elif
	# Concept : More than two possibilities: straight, right or left.
	# Grid    : A crossroads ringed with lava. Across the variants the safe
	#           exit is AHEAD, RIGHT or LEFT — the code must test each.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 9,
		"level_name": "Lava Crossroads",
		"level_description": "Learn elif: the safe exit is ahead, right, or left — a chain of checks finds it.",
		"difficulty": 2,
		"layout": """##########
##########
####L#####
####G#####
####.#####
###L.L####
####.#####
####.#####
####S#####
##########""",
		"variants": [
			"""##########
##########
####L#####
####G#####
####.#####
###L.L####
####.#####
####.#####
####S#####
##########""",
			"""##########
##########
##########
##########
####L#####
###L...GL#
####.#####
####.#####
####S#####
##########""",
			"""##########
##########
##########
##########
####L#####
#G...L####
####.#####
####.#####
####S#####
##########"""
		],
		"starter_code": """# A crossroads walled with LAVA. The one safe exit is:
#   variant 1 — straight ahead
#   variant 2 — to the right
#   variant 3 — to the left
#
# When there are MORE than two cases, chain checks
# with elif ("else if"):
#
#   if (rightIsClear()) {
#       turnRight()
#   } elif (leftIsClear()) {
#       turnLeft()
#   }
#
# If BOTH checks fail nothing happens — you're already
# facing the open way. Walk first, decide, walk again.
""",
		"solution_code": """while (frontIsClear()) {
    move()
}
if (rightIsClear()) {
    turnRight()
} elif (leftIsClear()) {
    turnLeft()
}
while (frontIsClear()) {
    move()
}
""",
		"hint_text": """Level 9 — elif chains

elif means "else, if". It lets one
decision handle many cases, checked
top to bottom, first match wins:

  if (rightIsClear()) {
      turnRight()
  } elif (leftIsClear()) {
      turnLeft()
  }

Note the trick in variant 1: the way is
open STRAIGHT ahead, so the first while
loop walks right through the junction to
the goal. Both sensor checks then fail —
and that's fine, no turn happens and the
final while has nothing left to do.

The full shape:
  while + move     <- walk as far as possible
  if / elif        <- turn only if needed
  while + move     <- finish the walk

Three variants, three different safe
exits, one honest program."""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 10 — goalReached() + the corridor follower
	# Concept : Nest the tools into a loop that follows ANY snaking
	#           corridor: walk until blocked, turn to the open side,
	#           repeat until standing on the goal.
	# Grid    : Winding single-path snakes, different shape every variant.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 10,
		"level_name": "Snake Path",
		"level_description": "Combine everything: a loop of walk-turn-repeat that follows any winding corridor until goalReached().",
		"difficulty": 2,
		"layout": """##########
####L#####
####G#####
####.#####
####.#####
##...#####
##.#######
##.#######
##S#######
##########""",
		"variants": [
			"""##########
####L#####
####G#####
####.#####
####.#####
##...#####
##.#######
##.#######
##S#######
##########""",
			"""##########
####L#####
####G#####
####.#####
####.#####
####.#####
####...###
######.###
######S###
##########""",
			"""##########
##########
##########
##LG..####
#####.####
#####.####
##....####
##.#######
##S#######
##########"""
		],
		"starter_code": """# These corridors snake back and forth, and every variant
# bends differently. Writing one while-turn pair per bend
# would mean rewriting the program for each variant...
#
# Instead, LOOP the whole idea. New sensor:
#   goalReached() — true once LediBug stands on the goal
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
# Walk. Turn toward the opening. Repeat until done.
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
		"hint_text": """Level 10 — the corridor follower

New sensor: goalReached() is true when
LediBug is standing on the goal.
`not` flips true/false, so
`while (not goalReached())` means
"keep going until you arrive".

The follower:

  while (not goalReached()) {
      while (frontIsClear()) {
          move()               <- straightaway
      }
      if (rightIsClear()) {
          turnRight()          <- corner: turn
      } else {                    toward the
          turnLeft()              open side
      }
  }

The inner while walks one straight
segment (lava and walls both stop it).
At each corner exactly one side is open,
so the if/else picks correctly.

This ONE program follows every snake in
all three variants — it reads the maze
instead of memorizing it. That's the
whole philosophy of this game in nine
lines of code."""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 11 — Teleporters
	# Concept : New tile, same logic. The swirl teleports you to its twin;
	#           your program just keeps running. goalReached() as the only
	#           loop condition you need.
	# Grid    : Corridor with a teleporter, then a second corridor to the
	#           goal. Both corridor lengths change per variant.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 11,
		"level_name": "The Wormhole",
		"level_description": "Meet teleporters: step on the swirl, pop out at its twin, and your code keeps running.",
		"difficulty": 3,
		"layout": """##########
##########
##########
######L###
######G###
##T###.###
##.###.###
##.###T###
##S#######
##########""",
		"variants": [
			"""##########
##########
##########
######L###
######G###
##T###.###
##.###.###
##.###T###
##S#######
##########""",
			"""##########
##########
##########
######L###
######T###
######.###
##T###.###
##.###G###
##S#######
##########""",
			"""##########
##########
##########
#######L##
##T####G##
##.####.##
##.####.##
##.####.##
##S####T##
##########"""
		],
		"starter_code": """# The purple swirl is a TELEPORTER. Step on it and
# LediBug instantly pops out at its twin — still facing
# the same direction — and your program keeps running
# as if nothing happened.
#
# Both corridors are straight, but their lengths change
# every variant. You know what that means by now:
#
#   while (not goalReached()) {
#    move()
#	if(not frontIsClear()){
#		turnBack()
#	}
#}
#
#
# Walk until you stand on the goal — the wormhole is
# just part of the road.
""",
		"solution_code": """while (not goalReached()) {
    move()
	if(not frontIsClear()){
		turnBack()
	}
}

""",
		"hint_text": """Level 11 — teleporters

The swirl tile is a TELEPORTER. Walking
onto it transports LediBug to the twin
swirl elsewhere on the grid. Direction
is kept, and your program never notices —
the next move() simply happens at the
new location.

Both corridors point straight up, so the
simplest loop yet does the whole job:

  while (not goalReached()) {
      move()
  }

Why not count steps? The corridor lengths
differ in every variant, and the cell
past the goal is lava. Counting burns;
sensing wins.

Lesson: new tiles don't always need new
code. Good programs shrug at surprises."""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 12 — Variables ("Measure & Mirror")
	# Concept : Store a measured value, then reuse it.
	# Grid    : Walk UP an unknown distance, then EAST the SAME distance.
	#           N is 3 / 5 / 6 across variants; lava punishes any
	#           mismatch, so the count must be measured, not guessed.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 12,
		"level_name": "Measure & Mirror",
		"level_description": "Learn variables: count your steps into n, then walk exactly n cells the other way.",
		"difficulty": 3,
		"layout": """##########
##########
##########
##########
##L#######
##...GL###
##.#######
##.#######
##S#######
##########""",
		"variants": [
			"""##########
##########
##########
##########
##L#######
##...GL###
##.#######
##.#######
##S#######
##########""",
			"""##########
##########
##L#######
##.....GL#
##.#######
##.#######
##.#######
##.#######
##S#######
##########""",
			"""##########
##L#######
##......GL
##.#######
##.#######
##.#######
##.#######
##.#######
##S#######
##########"""
		],
		"starter_code": """# The path goes UP some distance, then EAST the exact
# SAME distance — and lava sits one step past the goal.
# The distance is different in every variant, so you
# can't type a number... you have to MEASURE it.
#
# A variable stores a value. Make one by assigning:
#
#   n = 0
#   while (frontIsClear()) {
#       move()
#       n = n + 1        <- count each step
#   }
#   turnRight()
#   for (i in range(n)) {
#       move()           <- replay the count
#   }
#
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
		"hint_text": """Level 12 — variables

A variable is a named box for a value:

  n = 0        <- create it
  n = n + 1    <- add one to it

Here the trick is to MEASURE while you
walk: every time the first loop moves,
it also counts.

  n = 0
  while (frontIsClear()) {
      move()
      n = n + 1
  }

When the loop stops, n holds the exact
length of the first leg. Then:

  turnRight()
  for (i in range(n)) {
      move()
  }

...walks EXACTLY that far east, stopping
right on the goal — one step short of
the lava.

The three variants use n = 3, 5 and 6.
No single hard-coded number survives all
three; a measurement always does."""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 13 — Variables, reused twice ("Echo Canyon")
	# Concept : Measure once, reuse many times.
	# Grid    : Z-shape with THREE equal legs — up n, east n, up n.
	#           n is 2 / 3 / 4 per variant; every corner is lava-capped.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 13,
		"level_name": "Echo Canyon",
		"level_description": "One measurement, two echoes: walk a Z whose three legs all share the same secret length.",
		"difficulty": 3,
		"layout": """##########
##########
##########
####L#####
####G#####
##L#.#####
##...L####
##.#######
##S#######
##########""",
		"variants": [
			"""##########
##########
##########
####L#####
####G#####
##L#.#####
##...L####
##.#######
##S#######
##########""",
			"""##########
#####L####
#####G####
#####.####
##L##.####
##....L###
##.#######
##.#######
##S#######
##########""",
			"""##########
######L###
######G###
######.###
######.###
##L###.###
##.....L##
##.#######
##.#######
##.#######
##S#######
##########"""
		],
		"starter_code": """# A Z-shaped canyon: UP n, EAST n, then UP n again.
# All three legs share the same length n — but n changes
# every variant (2, 3, 4), and every corner is capped
# with lava. Guessing is not an option.
#
# Measure the first leg into a variable, then REPLAY it
# twice:
#
#   n = 0
#   while (frontIsClear()) {
#       move()
#       n = n + 1
#   }
#   turnRight()
#   for (i in range(n)) { move() }
#   turnLeft()
#   for (i in range(n)) { move() }
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
turnLeft()
for (i in range(n)) {
    move()
}
""",
		"hint_text": """Level 13 — reuse a measurement

Level 12 used a variable once. The real
power shows when you use it AGAIN:

  n = 0
  while (frontIsClear()) {
      move()
      n = n + 1        <- measure leg 1
  }
  turnRight()
  for (i in range(n)) { move() }   <- leg 2
  turnLeft()
  for (i in range(n)) { move() }   <- leg 3

The variable REMEMBERS. Measure once at
the start, and every later leg can trust
that number.

Careful with the turns: right at the
first corner, LEFT at the second — trace
the Z with your finger if unsure.

Why not while loops for legs 2 and 3?
Look closely: the corners are capped
with lava but the second corner is OPEN
on the far side — only the measured
count stops in the right place."""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 14 — Functions
	# Concept : Name a block of code once; call it three times. The body
	#           uses sensor loops, so it survives stairs of any size.
	# Grid    : 3-step staircases + a final climb. Step sizes differ per
	#           variant (2/2, 3/3, mixed 1–2), so the function body must
	#           sense, not count.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 14,
		"level_name": "The Stair Master",
		"level_description": "Learn functions: define step() once, call it three times. Sensors inside make it fit any staircase.",
		"difficulty": 3,
		"layout": """##########
#######L##
#######G##
#####...##
#####.####
###...####
###.######
#...######
#.########
#S########""",
		"variants": [
			"""#######L##
#######G##
#####...##
#####.####
###...####
###.######
#...######
#.########
#S########
##########""",
			"""##########L#
##########G#
#######....#
#######.####
#######.####
####....####
####.#######
####.#######
#....#######
#.##########
#.##########
#S##########""",
			"""##########
#######L##
#######G##
#######.##
#####...##
####..####
####.#####
##...#####
##S#######
##########"""
		],
		"starter_code": """# Three staircases, one per variant — and the steps are
# DIFFERENT SIZES in each (and even within one!).
#
# One stair-step is always the same IDEA though:
#   climb until blocked, turn right, cross until blocked,
#   turn left.
#
# Name that idea with a FUNCTION, then call it by name:
#
#   function step() {
#       while (frontIsClear()) { move() }
#       turnRight()
#       while (frontIsClear()) { move() }
#       turnLeft()
#   }
#
#   step()
#   step()
#   step()
#   while (frontIsClear()) { move() }   <- final climb
""",
		"solution_code": """function step() {
    while (frontIsClear()) {
        move()
    }
    turnRight()
    while (frontIsClear()) {
        move()
    }
    turnLeft()
}
step()
step()
step()
while (frontIsClear()) {
    move()
}
""",
		"hint_text": """Level 14 — functions

A function gives a NAME to a block of
code. Define it once:

  function step() {
      while (frontIsClear()) { move() }
      turnRight()
      while (frontIsClear()) { move() }
      turnLeft()
  }

Call it as often as you like:

  step()
  step()
  step()

Each call runs the whole body. Because
the body uses while + sensors instead of
counts, the SAME step() climbs a 1-cell
riser or a 3-cell riser — whatever the
current variant throws at it.

Don't forget the last climb after the
third step: one more sensor loop walks
you up to the goal (the lava cap stops
it exactly there).

DRY — Don't Repeat Yourself. If you
write the same lines twice, wrap them
in a function and call it twice instead."""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 15 — Function parameters
	# Concept : walk(n) — a function that takes an input. Measure the
	#           first leg, then hand the number to the function.
	# Grid    : FOUR equal legs (up n, east n, up n, east n). n is 2/3/4
	#           per variant; corners lava-capped as usual.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 15,
		"level_name": "Walk This Way",
		"level_description": "Learn parameters: write walk(n) once, measure the leg length, and call it for every leg.",
		"difficulty": 3,
		"layout": """##########
##########
##########
####L#####
####..GL##
##L#.#####
##...L####
##.#######
##S#######
##########""",
		"variants": [
			"""##########
##########
##########
####L#####
####..GL##
##L#.#####
##...L####
##.#######
##S#######
##########""",
			"""##########
##########
#####L####
#####...GL
#####.####
##L##.####
##....L###
##.#######
##.#######
##S#######
##########""",
			"""############
######L#####
######....GL
######.#####
######.#####
##L###.#####
##.....L####
##.#########
##.#########
##.#########
##S#########
############"""
		],
		"starter_code": """# Four legs this time — up n, east n, up n, east n —
# all the SAME length, which changes per variant (2/3/4).
#
# You could write for (i in range(n)) three times... or
# teach a function to accept an INPUT:
#
#   function walk(n) {
#       for (i in range(n)) {
#           move()
#       }
#   }
#
# walk(3) walks 3 cells. walk(n) walks n cells — whatever
# n currently holds. Measure the first leg, then:
#
#   turnRight()  walk(n)
#   turnLeft()   walk(n)
#   turnRight()  walk(n)
function walk(n) {
    for (i in range(n)) {
        move()
    }
}

n = 0
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
turnRight()
walk(n)
""",
		"hint_text": """Level 15 — parameters

A parameter is an input slot on a
function:

  function walk(n) {
      for (i in range(n)) {
          move()
      }
  }

Now walk(2) takes two steps, walk(7)
takes seven — one function, any
distance.

The plan for the four equal legs:

  n = 0
  while (frontIsClear()) {   <- leg 1,
      move()                    measured
      n = n + 1
  }
  turnRight()
  walk(n)                    <- leg 2
  turnLeft()
  walk(n)                    <- leg 3
  turnRight()
  walk(n)                    <- leg 4, ends on G

Compare with level 13: the loop code for
"walk n cells" now lives in ONE place.
Change it once, every call benefits.
That's why parameters exist."""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 16 — Keys & Doors
	# Concept : New tiles teaching SEQUENCE-AS-STATE: walking over a key
	#           picks it up; walking into a door spends a key to open it.
	# Grid    : Straight corridor S→K→D→G. Spacing/length changes per
	#           variant, so the goalReached loop is still the only answer.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 16,
		"level_name": "The Locked Gate",
		"level_description": "Meet keys and doors: grab the key on your way and the door opens as you walk into it.",
		"difficulty": 4,
		"layout": """##########
##########
##########
##########
##########
####L#####
###K.DG###
####.#####
####S#####
##########""",
		"variants": [
			"""##########
##########
##########
##########
##########
####L#####
###K.DG###
####.#####
####S#####
##########""",
			"""##########
##########
##########
##########
####L#####
###K.DG###
####.#####
####.#####
####S#####
##########""",
			"""##########
##########
##########
####L#####
###K.DG###
####.#####
####.#####
####.#####
####S#####
##########"""
		],
		"starter_code": """# Two new tiles:
#   🔑 KEY  — LediBug picks it up just by walking over it.
#   🚪 DOOR — locked. Walking into it spends ONE key and
#             the door swings open. Without a key it
#             blocks you like a wall.
#
# The key sits on the path BEFORE the door, so the loop
# you already trust handles everything:
#
#   while (frontIsClear()) {
#       move()
#   }
#   turnLeft()
#   move()
#   turnBack()
#   move()
#   move()
#   move()
#
# (The corridor length changes per variant, of course.)
""",
		"solution_code": """   while (frontIsClear()) {
       move()
   }
   turnLeft()
   move()
   turnBack()
   move()
   move()
   move()
""",
		"hint_text": """Level 16 — keys and doors

New tiles, new STATE:

  🔑 KEY  — step on it and it's yours,
            automatically.
  🚪 DOOR — locked. Walking into it
            spends one key and opens it.
            With no key it's just a wall.

Order matters: key first, THEN door.
Here the key is always on the corridor
before the door, so plain forward motion
collects and spends it correctly:

  while (not goalReached()) {
      move()
  }

Watch the run: the key vanishes into
LediBug's pocket, then the door pops
open on contact.

There's also a matching sensor you'll
need soon:
  hasKey() — true while carrying a key."""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 17 — hasKey() and the detour
	# Concept : Sensors about STATE, not just walls. The door blocks the
	#           way up; the key waits down a side corridor of unknown
	#           depth. Fetch, return, unlock.
	# Grid    : T-junction: door above, key-corridor to the east (depth
	#           2/3/4 per variant), lava capping every wrong step.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 17,
		"level_name": "Detour for the Key",
		"level_description": "Use hasKey(): the door bars the way and the key hides down a side corridor of unknown depth.",
		"difficulty": 4,
		"layout": """##########
##########
####L#####
####G#####
####.#####
####D#####
###L..KL##
####.#####
####S#####
##########""",
		"variants": [
			"""##########
##########
####L#####
####G#####
####.#####
####D#####
###L..KL##
####.#####
####S#####
##########""",
			"""##########
##########
####L#####
####G#####
####D#####
###L...KL#
####.#####
####.#####
####S#####
##########""",
			"""##########
####L#####
####G#####
####.#####
####.#####
####D#####
###L....KL
####.#####
####S#####
##########"""
		],
		"starter_code": """# The door is straight ahead — but you have no key, and
# a keyless door reads as BLOCKED to your sensors. The
# key lies down the side corridor, at a different depth
# in every variant.
#
# New sensor for your STATE (not the world):
#   hasKey() — true once you're carrying a key
#
# The plan:
#   1. walk until blocked (that's the locked door ahead)
#   2. turnRight() into the side corridor
#   3. while (not hasKey()) { move() }   <- fetch!
#   4. turnBack() and walk back until blocked
#   5. turnRight() — now facing the door WITH a key
#   6. while (not goalReached()) { move() }
#
# turnBack() spins 180 degrees.
""",
		"solution_code": """while (frontIsClear()) {
    move()
}
turnRight()
while (not hasKey()) {
    move()
}
turnBack()
while (frontIsClear()) {
    move()
}
turnRight()
while (not goalReached()) {
    move()
}
""",
		"hint_text": """Level 17 — hasKey()

Until now sensors described the WORLD
(walls, lava). hasKey() describes YOU:
it turns true the moment a key is in
LediBug's pocket.

That makes it a perfect loop condition
for fetching:

  while (not hasKey()) {
      move()
  }

...walks down the side corridor exactly
as far as the key — depth 2, 3 or 4
depending on the variant — and stops
right on it.

Subtle detail: a locked door reads as
NOT clear, so the opening
`while (frontIsClear())` stops at the
junction. After you fetch the key, the
SAME door reads as clear — sensors know
you can open it now!

Full journey: up, right to the key,
turnBack(), return to the junction
(lava stops you), turnRight() to face
the door, then walk to the goal."""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 18 — The Locked Gatekeeper
	# Concept : The key is NOT on the direct path — you must consciously
	#           detour into a dead-end branch to collect it, then return
	#           to the main path. hasKey() is the only reliable way.
	# Grid    : T-shaped corridor. The door blocks upward progress; the
	#           key rests in a side branch at varying distances. Lava
	#           caps the key's corridor so over-counting burns.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 18,
		"level_name": "The Locked Gatekeeper",
		"level_description": "The key hides in a dead-end branch. Detour, grab it, then backtrack through the door.",
		"difficulty": 4,
		"layout": """##########
##########
##########
##T...DG##
##########
##########
######K###
##S....T##
######L###
##########""",
		"variants": [
			"""##########
##########
##########
##T...DG##
##########
##########
######K###
##S....T##
######L###
##########""",
			"""##########
##########
##########
##T...DG##
##########
##########
#####L####
##S....T##
#####K####
##########""",
			"""##########
##########
##########
#T.D....G#
##########
##########
######L###
#S......T#
######K###
##########"""
		],
		"starter_code": """# The path ahead is blocked by a locked door. The key
# isn't on the main road — it hides in a dead-end side
# branch. You must navigate to the key, collect it, and
# RETURN to the main path before the door will open.
#
# hasKey() tells you when you're carrying a key.
# Use it with while loops to fetch:
#
#   while (not hasKey()) {
#       move()
#   }
#
# That loop walks until a key lands in your pocket —
# no matter how far down the side branch it sits.
# Then backtrack and the door ahead reads as clear.
#
# The side branch changes length in every variant,
# so counting steps cannot work. Only hasKey() tells
# you when to turn around.
""",
		"solution_code": """turnRight()
while(frontIsClear()){
	move()
	if(leftIsClear()){
		turnLeft()
		move()
		turnBack()
		move()
		turnLeft()
	}
	if(rightIsClear()){
		turnRight()
		move()
		turnBack()
		move()
		turnRight()
	}
}
""",
		"hint_text": """No hints from level 18. You can do this on your own!"""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 19 — The Right-Hand Rule
	# Concept : Branching mazes with dead ends defeat the corridor
	#           follower — the classic fix is wall-following: prefer
	#           right, then straight, else turn left.
	# Grid    : Three genuine mazes with junctions and dead-end spurs.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 19,
		"level_name": "Going in circles",
		"level_description": "Learn the right-hand rule: prefer right, else straight, else turn left — it solves ANY maze.",
		"difficulty": 5,
		"layout": """#S########
#.#.....##
#.#.###.##
#.#.#G#.##
#.#.#.#.##
#.#.#.#.##
#.#...#.##
#.#####.##
#.......##
##########""",
		"variants": [
			"""#S########
#.#.....##
#.#.###.##
#.#.#G#.##
#.#.#.#.##
#.#.#.#.##
#.#...#.##
#.#####.##
#.......##
##########""",
			"""########
#S######
#.#...##
#.#.#.##
#.#G#.##
#.###.##
#.....##
########""",
			"""############
#S##########
#.#........#
#.#.######.#
#.#.#....#.#
#.#.#.##.#.#
#.#.#.##.#.#
#.#.#.G#.#.#
#.#.####.#.#
#.#......#.#
#.########.#
#..........#
############"""
		],
		"starter_code": """# Real mazes now: junctions where BOTH ways are open,
# and dead-end corridors that go nowhere. A follower
# that only reacts to walls can pick wrong and wander.
#
# The classic answer is 700 years older than computers:
# put your right hand on the wall and never let go.
#
#   while (not goalReached()) {
#       if (rightIsClear()) {
#           turnRight()
#           move()
#       } elif (frontIsClear()) {
#           move()
#       } else {
#           turnLeft()
#       }
#   }
#
# Prefer right. Else straight. Else turn left.
# Dead ends? It walks in, turns around, walks out.
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
		"hint_text": """No hints from level 18. You can do this on your own!"""
	},

	# ──────────────────────────────────────────────────────────────────────
	# Level 20 — The Grand Vault (capstone)
	# Concept : Everything at once: right-hand rule + keys + doors + lava
	#           + dead-end spurs, in three different vault layouts.
	# ──────────────────────────────────────────────────────────────────────
	{
		"level_id": 20,
		"level_name": "The Grand Vault",
		"level_description": "The final exam: lava labyrinths, two locked doors, dead-end traps — one algorithm to rule them all.",
		"difficulty": 5,
		"layout": """############
############
############
#S########T#
#......L##.#
#.##.#####.#
#.##D#####.#
#T##G#####K#
############
############""",
		"variants": [
			"""############
############
############
#S########T#
#......L##.#
#.##.#####.#
#.##D#####.#
#T##G#####K#
############
############""",
			"""############
############
############
#S########T#
#......T##.#
#.##.#####.#
#.##D#####.#
#L##G#####K#
####L#######
############""",
			"""############
############
############
#S########T#
#......T##.#
#.##.#####.#
#.##D#####.#
#L##.G####K#
####L#######
############"""
		],
		"starter_code": """# THE GRAND VAULT — everything you've learned, at once:
#
#   🔥 lava labyrinths     — sensors read lava as walls
#   🔑 two keys, 🚪 two doors — collected and spent en route
#   ↩  dead-end spurs      — explored and escaped
#   🌀 three vault layouts — one program for all
#
# The right-hand rule doesn't care. Doors read as open
# exactly when you carry a key; lava reads as wall; dead
# ends resolve themselves.
#
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
		"hint_text": """Level 20 — The Grand Vault

The final level changes nothing — and
that's the point. The right-hand rule
you built on level 19 already handles
every mechanic in the game:

  🔥 LAVA — rightIsClear() and friends
	 report it as blocked, so the rule
	 hugs the safe corridor.
  🔑 KEYS — picked up by walking, and
	 the vaults place each key on the
	 path before its door.
  🚪 DOORS — read as walls until you
	 hold a key, then as open corridor.
	 The rule opens them in stride.
  ↩ DEAD ENDS — entered, reversed,
	 exited. No extra code.

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

What you learned on the way here:
  1–3   sequencing and turns
  4–5   for loops
  6–7   while loops and sensors
  8–9   if / elif / else
  10–11 goalReached and teleporters
  12–13 variables
  14–15 functions and parameters
  16–18 keys, doors and state
  19–20 the right-hand rule

One small set of rules, endless mazes.
That's programming. Congratulations!"""
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
