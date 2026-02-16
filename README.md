# LediBug Project

A visual programming game built with Godot 4.5 that teaches programming concepts through interactive character control and puzzle-solving.

## Overview

LediBug is an educational coding game where players write code to control a bug character on a grid. Players must navigate through levels, avoid hazards, and reach goals using a custom programming language. The game features a professional IDE-style interface with multiple levels, a level editor, and real-time debugging tools.

## Features

### Programming Language
- ✅ Variables and expressions
- ✅ Arithmetic operators (+, -, *, /, %)
- ✅ Comparison operators (==, !=, <, >, <=, >=)
- ✅ Logical operators (and, or, not, !)
- ✅ If/elif/else statements
- ✅ For loops with range()
- ✅ While and do-while loops
- ✅ User-defined functions with parameters and return values
- ✅ Comments (# single-line)
- ✅ Nested control structures
- ✅ Turn-based movement system (move, turnRight, turnLeft, turnBack)
- ✅ Sensor functions (frontIsClear, leftIsClear, rightIsClear, onGoal, goalReached, onHazard)

### Game Features
- 🎮 **7 Built-in Levels** with progressive difficulty
- 🛠️ **Level Editor** with custom grid sizes (3x3 to 15x15)
- 💾 **Save/Load Custom Levels** with persistent storage
- 🐞 **Debug Mode** with breakpoints, call stack, and variable inspection
- ▶️ **Run/Debug/Stop Controls** for precise code execution
- 🎨 **Dark/Light Themes** with professional syntax highlighting
- 📱 **Resizable IDE Panels** for customizable workspace
- 📚 **Interactive Help System** with command reference
- ✨ **Smooth Animations** with visual feedback
- 🚫 **Infinite Loop Protection** (10,000 iteration limit)

## Project Structure

```
LediBug_Project/
├── assets/
│   ├── icons/              # Project icons
│   └── sprites/            # Game sprites (LediBug character)
├── docs/
│   ├── ENHANCEMENT_SUMMARY.md   # Feature changelog
│   ├── LANGUAGE_REFERENCE.md    # Complete language docs
│   └── PROJECT_STRUCTURE.md     # Detailed folder structure
├── resources/
│   └── cell_highlight.tres      # Grid highlight resource
├── scenes/
│   ├── main.tscn               # Main game scene with IDE UI
│   ├── main_menu.tscn          # Main menu with level select
│   ├── level_editor.tscn       # Visual level editor
│   ├── custom_levels.tscn      # Custom level browser
│   ├── level_select.tscn       # Built-in level selector
│   └── player.tscn             # Player character
├── scripts/
│   ├── main.gd                 # Main game controller & UI
│   ├── player.gd               # Turn-based movement & sensors
│   ├── code_executor.gd        # Code execution pipeline
│   ├── lexer.gd                # Tokenizer
│   ├── parser.gd               # AST parser
│   ├── interpreter.gd          # AST interpreter
│   ├── ast_nodes.gd            # AST node definitions
│   ├── debug_manager.gd        # Breakpoint & debug tools
│   ├── watch_manager.gd        # Watch expressions
│   ├── grid_manager.gd         # Grid & collision system
│   ├── simple_grid.gd          # Grid rendering
│   ├── level_definitions.gd    # Built-in level data
│   ├── level_editor.gd         # Level editor logic
│   ├── custom_levels.gd        # Custom level management
│   ├── main_menu.gd            # Menu controller
│   └── cell_types.gd           # Grid cell type enum
└── project.godot               # Godot project config
```

See [docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md) for detailed information.

## Architecture

The interpreter follows a classic compiler architecture:

1. **Lexer** (`lexer.gd`) - Converts source code into tokens
2. **Parser** (`parser.gd`) - Builds an Abstract Syntax Tree (AST) from tokens
3. **Interpreter** (`interpreter.gd`) - Executes the AST with async support for animations

### Pipeline Flow

```
User Code → Lexer → Tokens → Parser → AST → Interpreter → Player Movement
```

## Getting Started

### Prerequisites
- Godot 4.5 or higher
- Basic understanding of programming concepts

### Running the Project
1. Open the project in Godot
2. Run the main scene (F5)
3. Select a level from the main menu
4. Write code in the editor or use starter code
5. Click "Run" to execute, "Debug" for step-through mode
6. Press "❓" for help with available commands

### Controls
- **Run Button (▶)**: Execute code normally
- **Debug Button (🐞)**: Execute with debugging features enabled
- **Stop Button (⏹)**: Halt execution mid-run
- **Help Button (❓)**: View command reference
- **Theme Toggle (☀️/🌙)**: Switch between dark/light themes
- **Menu Button**: Return to main menu

### Level Editor
1. From main menu, select "Level Editor"
2. Use toolbar buttons to place: Start (S), Goal (G), Walls (#), Hazards (X)
3. Click "Resize Grid" to adjust dimensions (3x3 to 15x15)
4. Set starter code and hint text
5. Click "Save Level" to store in custom levels
6. Play custom levels from "Custom Levels" menu

## Language Documentation

See [docs/LANGUAGE_REFERENCE.md](docs/LANGUAGE_REFERENCE.md) for complete language documentation including:
- Turn-based movement commands
- Sensor functions for navigation
- Control flow structures
- Functions and variables
- Code examples for each level

## Development

### Architecture

The interpreter follows a classic compiler architecture:

1. **Lexer** (`lexer.gd`) - Converts source code into tokens
2. **Parser** (`parser.gd`) - Builds an Abstract Syntax Tree (AST) from tokens
3. **Interpreter** (`interpreter.gd`) - Executes the AST with async support for animations
4. **CodeExecutor** (`code_executor.gd`) - Manages execution flow and debugging

### Pipeline Flow

```
User Code → Lexer → Tokens → Parser → AST → Interpreter → Player Actions
                                              ↓
                                        Debug Manager
                                      (Breakpoints, Watch)
```

### Key Systems

#### Turn-Based Movement System
The player maintains a `current_direction` vector that persists between moves:
- `move()` - Moves forward in current direction
- `turnRight()` - Rotates 90° clockwise
- `turnLeft()` - Rotates 90° counter-clockwise
- `turnBack()` - Rotates 180°

Visual rotation is handled by `_update_facing_rotation()` which smoothly animates the character sprite.

#### Sensor System
All sensors work relative to the player's current facing direction:
- `frontIsClear()` - Checks if space ahead is walkable
- `leftIsClear()` - Checks left side (relative to facing)
- `rightIsClear()` - Checks right side (relative to facing)
- `goalReached()` / `onGoal()` - Returns true if on goal tile
- `onHazard()` - Returns true if on hazard tile

#### Debug System
- **Breakpoints**: Click line gutter to toggle (red circle icon)
- **Step Execution**: Pauses at each line in debug mode
- **Variable Viewer**: Shows all variables in current scope
- **Watch Expressions**: Evaluate custom expressions during execution
- **Call Stack**: Displays function call hierarchy
- **Execution Log**: Records all executed commands

### Key Classes

#### Lexer (lexer.gd)
Tokenizes source code. Supports:
- Keywords (if, while, for, function, etc.)
- Operators (+, -, ==, !=, !, etc.)
- Identifiers and numbers
- Strings (single and double quotes)
- Comments (#)

#### Parser (parser.gd)
Builds AST using recursive descent parsing with proper operator precedence.

#### Interpreter (interpreter.gd)
Executes AST with:
- Variable scoping (supports nested scopes)
- Async command execution (for smooth animations)
- Function call stack
- Infinite loop protection (10,000 iterations)
- Built-in command routing

### Adding New Commands

To add a new movement command:

1. **Add to player.gd:**
```gdscript
func jump():
    """Jump over one cell"""
    var jump_pos = grid_position + (current_direction * 2)
    if grid_manager and grid_manager.is_walkable(jump_pos):
        grid_position = jump_pos
        position = grid_manager.grid_to_world(grid_position)
```

2. **Add to interpreter.gd in `_execute_builtin_command`:**
```gdscript
"jump":
    current_player.jump()
    await get_tree().create_timer(0.3).timeout
```

3. **Add to main.gd autocomplete:**
```gdscript
var available_commands = [..., "jump()"]
```

4. **Add to syntax highlighter in `_setup_syntax_highlighting`:**
```gdscript
syntax_highlighter.add_keyword_color("jump", function_color)
```

### Adding New Levels

Create levels in `scripts/level_definitions.gd`:

```gdscript
{
    "level_id": 8,
    "level_name": "Advanced Maze",
    "layout": """
########
#S....G#
########
""",
    "starter_code": "# Your solution here\n",
    "hint_text": "Use sensors to navigate!"
}
```

Or use the visual Level Editor to create custom levels!

## Features Implemented

### Core Language Features ✅
- [x] Complete lexer, parser, and interpreter
- [x] Variables and all operator types
- [x] If/elif/else, for, while, do-while loops
- [x] User-defined functions with parameters and returns
- [x] Comments and proper error handling

### Game Systems ✅
- [x] Turn-based movement system (move, turnRight, turnLeft, turnBack)
- [x] Relative sensor system (frontIsClear, leftIsClear, rightIsClear)
- [x] Goal detection (goalReached, onGoal)
- [x] Hazard detection (onHazard)
- [x] 7 built-in levels with progressive difficulty
- [x] Level editor with variable grid sizes (3x3 to 15x15)
- [x] Custom level save/load system

### IDE Features ✅
- [x] Dark and light theme support
- [x] Professional syntax highlighting (theme-aware)
- [x] Resizable panels (horizontal and vertical)
- [x] Debug mode with breakpoints
- [x] Variable inspection and watch expressions
- [x] Call stack viewer
- [x] Execution log
- [x] Run/Debug/Stop controls
- [x] Interactive help system with command reference
- [x] Code completion

## Future Enhancements

Potential features to add:
- [ ] Arrays and lists
- [ ] String manipulation functions
- [ ] More sensor functions (backIsClear, distanceToGoal)
- [ ] Sound effects and music
- [ ] Achievement system
- [ ] Hint system for stuck players
- [ ] Code sharing/export feature
- [ ] Multiplayer challenges
- [ ] Visual execution speed control
- [ ] Code optimization metrics (step counter)

## Credits

Built with Godot Engine 4.5

## License

[Add your license here]
