# LediBug Programming Game - Language Reference

## Overview
LediBug uses a simple programming language to control a character on a grid. This document describes all available features.

## Basic Commands

### Movement
- `moveRight()` - Move one grid cell to the right
- `moveLeft()` - Move one grid cell to the left
- `moveUp()` - Move one grid cell up
- `moveDown()` - Move one grid cell down

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
3. **Use meaningful variable names** (e.g., `count` instead of `x`)
4. **Indent properly** for readability
5. **Test incrementally** - start simple and build up

## Examples

### Example 1: Draw a Square
```javascript
function square() {
    for (i in range(4)) {
        moveRight()
        moveDown()
        moveLeft()
        moveUp()
    }
}

square()
```

### Example 2: Conditional Movement
```javascript
steps = 5
for (i in range(steps)) {
    if (i % 2 == 0) {
        moveRight()
    } else {
        moveUp()
    }
}
```

### Example 3: Spiral Pattern
```javascript
function spiral() {
    size = 1
    while (size < 5) {
        for (i in range(size)) {
            moveRight()
        }
        for (i in range(size)) {
            moveUp()
        }
        size = size + 1
    }
}

spiral()
```

## Limitations

- Maximum 10,000 iterations to prevent infinite loops
- No arrays or complex data structures (yet)
- No string manipulation functions (yet)
- Function calls in expressions not yet supported

## Tips for Beginners

1. Start with the F1-F6 example shortcuts
2. Use the autocomplete feature (Ctrl+Space)
3. Read error messages carefully - they tell you what went wrong
4. Break complex problems into smaller functions
5. Test your code frequently with the Run button

## Keyboard Shortcuts

- **F1-F6**: Load example code
- **Ctrl+Space**: Trigger autocomplete
- **Run Button**: Execute your code

Enjoy coding!
