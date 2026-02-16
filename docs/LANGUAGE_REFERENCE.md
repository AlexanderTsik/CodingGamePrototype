# LediBug Programming Game - Language Reference

## Overview
LediBug uses a simple but powerful programming language to control a bug character on a grid. The language features turn-based movement, sensor functions for navigation, and full programming constructs including variables, functions, and control flow.

## Movement Commands

### Turn-Based System
The bug maintains a facing direction that persists between commands. All movement is relative to this direction.

- **`move()`** - Move forward one cell in the current facing direction
- **`turnRight()`** - Rotate 90° clockwise (changes facing, doesn't move)
- **`turnLeft()`** - Rotate 90° counter-clockwise (changes facing, doesn't move)
- **`turnBack()`** - Rotate 180° to face opposite direction (changes facing, doesn't move)

**Example:**
```javascript
// Start facing UP
move()          // Move up
turnRight()     // Now facing RIGHT
move()          // Move right
turnLeft()      // Now facing UP again
```

## Sensor Functions

All sensors work relative to the bug's current facing direction and return boolean values (true/false).

### Direction Sensors
- **`frontIsClear()`** - Returns true if the cell ahead is walkable (not a wall)
- **`leftIsClear()`** - Returns true if the cell to the left is walkable
- **`rightIsClear()`** - Returns true if the cell to the right is walkable

### Goal Detection
- **`goalReached()`** - Returns true if standing on a goal tile
- **`onGoal()`** - Alias for goalReached()

### Hazard Detection
- **`onHazard()`** - Returns true if standing on a hazard tile (causes failure)

## Variables

Variables are dynamically typed and don't need declaration:

```javascript
x = 5
y = 10
result = x + y
```

## Operators

### Arithmetic
- `+` - Addition
- `-` - Subtraction
- `*` - Multiplication
- `/` - Division
- `%` - Modulo

### Comparison
- `==` - Equal to
- `!=` - Not equal to
- `<` - Less than
- `>` - Greater than
- `<=` - Less than or equal
- `>=` - Greater than or equal

### Logical
- `and` - Logical AND
- `or` - Logical OR
- `not` - Logical NOT
- `!` - Logical NOT (alternative syntax)

**Examples:**
```javascript
if (frontIsClear() and rightIsClear()) {
    move()
}

if (!goalReached()) {
    move()
}

if (not onHazard() or onGoal()) {
    move()
}
```

## Control Flow

### If Statements

```javascript
if (x > 5) {
    moveRight()
}

if (x > 10) {
    moveUp()
} else {
    moveDown()
}

if (x < 0) {
    moveLeft()
} elif (x == 0) {
    moveUp()
} else {
    moveRight()
}
```

### For Loops

Loop with a range:

```javascript
for (i in range(5)) {
    moveRight()
}

// range(start, end)
for (i in range(2, 8)) {
    moveUp()
}

// range(start, end, step)
for (i in range(0, 10, 2)) {
    moveDown()
}
```

### While Loops

```javascript
count = 0
while (count < 5) {
    moveRight()
    count = count + 1
}
```

### Do-While Loops

```javascript
x = 0
do {
    moveUp()
    x = x + 1
} while (x < 3)
```

## Functions

Define reusable functions:

```javascript
function square() {
    moveRight()
    moveDown()
    moveLeft()
    moveUp()
}

square()
square()
```

Functions can have parameters:

```javascript
function repeat(times) {
    for (i in range(times)) {
        moveRight()
    }
}

repeat(5)
```

Functions can return values:

```javascript
function add(a, b) {
    return a + b
}

result = add(3, 7)
```

## Comments

Two styles of comments are supported:

```javascript
# Python-style comment
moveRight()  # Inline comment

// C-style comment
moveLeft()  // Also inline
```

## Nested Structures

You can nest any control flow structures:

```javascript
for (i in range(3)) {
    if (i == 1) {
        moveUp()
    } else {
        for (j in range(2)) {
            moveRight()
        }
    }
}
```

## Best Practices

1. **Use comments** to explain your logic
2. **Use functions** for repeated patterns
3. **Use meaningful variable names** (e.g., `stepCount` instead of `x`)
4. **Use sensors** to make adaptive navigation code
5. **Test with small grids first** before scaling up
6. **Use while loops with sensors** for flexible navigation

## Navigation Examples

### Example 1: Wall Following (Right-Hand Rule)
```javascript
// Follow right wall until goal is reached
while (!goalReached()) {
    if (rightIsClear()) {
        turnRight()
        move()
    } else if (frontIsClear()) {
        move()
    } else {
        turnLeft()
    }
}
```

### Example 2: Smart Navigation
```javascript
// Navigate using sensor priorities
while (!goalReached()) {
    if (frontIsClear()) {
        move()
    } else if (rightIsClear()) {
        turnRight()
        move()
    } else if (leftIsClear()) {
        turnLeft()
        move()
    } else {
        turnBack()
    }
}
```

### Example 3: Square Patrol Pattern
```javascript
function square(size) {
    for (i in range(4)) {
        for (j in range(size)) {
            move()
        }
        turnRight()
    }
}

square(3)
```

### Example 4: Spiral Search
```javascript
// Search in expanding spiral
distance = 1
while (!goalReached() and distance < 10) {
    for (i in range(2)) {
        for (j in range(distance)) {
            if (frontIsClear()) {
                move()
            }
        }
        turnRight()
    }
    distance = distance + 1
}
```

## Examples

### Example 1: Draw a Square
```javascript
function square() {
    for (i in range(4)) {
        for (j in range(3)) {
            move()
        }
        turnRight()
    }
}

square()
```

### Example 2: Conditional Movement
```javascript
steps = 5
for (i in range(steps)) {
    if (i % 2 == 0) {
        move()
    } else {
        turnRight()
        move()
        turnLeft()
    }
}
```

### Example 3: Adaptive Navigation
```javascript
// Navigate to goal using sensors
function navigateToGoal() {
    while (!goalReached()) {
        if (frontIsClear()) {
            move()
        } else {
            turnRight()
        }
    }
}

navigateToGoal()
```

## Limitations

- Maximum 10,000 iterations to prevent infinite loops
- No arrays or complex data structures (yet)
- No string manipulation functions (yet)
- Sensors only check immediate adjacent cells
- No diagonal movement

## Tips for Beginners

1. **Start simple** - Get to the goal with basic moves first
2. **Use the help button (❓)** in-game for quick command reference
3. **Learn sensors** - They're key to solving complex levels
4. **Debug mode is your friend** - Use breakpoints to understand execution
5. **Read error messages** - They tell you exactly what went wrong
6. **Test iteratively** - Add one command at a time
7. **Use while loops with sensors** - Much better than counting steps!

## Common Patterns

### Pattern: Navigate Until Goal
```javascript
while (!goalReached()) {
	// Your navigation logic
	if (frontIsClear()) {
		move()
	}
}
```

### Pattern: Safe Movement Check
```javascript
if (frontIsClear() and !onHazard()) {
	move()
} else {
	turnRight()
}
```

### Pattern: Explore All Directions
```javascript
for (i in range(4)) {
	if (frontIsClear()) {
		move()
		break
	}
	turnRight()
}
```

## Keyboard Shortcuts

- **Ctrl+Space**: Trigger autocomplete
- **Click line gutter**: Toggle breakpoint
- **Run Button (▶)**: Execute code
- **Debug Button (🐞)**: Execute with debug UI
- **Stop Button (⏹)**: Halt execution
- **Help Button (❓)**: Show command reference
- **Theme Toggle (☀️/🌙)**: Switch dark/light theme

## Grid Symbols

When viewing level layouts:
- `.` - Empty walkable floor
- `#` - Wall (impassable)
- `S` - Start position (where bug spawns)
- `G` - Goal (reach this to complete level)
- `X` - Hazard (stepping here causes failure)

Enjoy coding and happy bug hunting! 🐞
