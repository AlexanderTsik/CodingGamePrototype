# LediBug Project

A visual programming game built with Godot 4.5 that teaches programming concepts through interactive character control.

## Overview

LediBug is an educational coding game where players write code to control a character on a grid. It features a custom programming language with support for variables, control flow, functions, and more.

## Features

### Programming Concepts
- ✅ Variables and expressions
- ✅ Arithmetic operators (+, -, *, /, %)
- ✅ Comparison operators (==, !=, <, >, <=, >=)
- ✅ Logical operators (and, or, not)
- ✅ If/elif/else statements
- ✅ For loops with range()
- ✅ While and do-while loops
- ✅ User-defined functions with parameters
- ✅ Return statements
- ✅ Comments (# and //)
- ✅ Nested control structures

### Game Features
- Real-time code execution with smooth animations
- Built-in code editor with syntax completion
- Example code snippets (F1-F6)
- Helpful error messages
- Grid-based movement system

## Project Structure

```
LediBug_Project/
├── scenes/
│   ├── main.tscn          # Main game scene with UI
│   └── player.tscn        # Player character
├── scripts/
│   ├── main.gd            # UI controller
│   ├── player.gd          # Player movement
│   ├── code_executor.gd   # Code execution pipeline
│   ├── token.gd           # Token definitions
│   ├── lexer.gd           # Tokenizer
│   ├── ast_nodes.gd       # AST node classes
│   ├── parser.gd          # Parser (builds AST)
│   ├── interpreter.gd     # Interpreter (executes AST)
│   └── tests/             # Test files
├── LANGUAGE_REFERENCE.md  # Language documentation
└── project.godot          # Godot project file
```

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
3. Try the example code or write your own
4. Click "Run" to execute

### Quick Start Examples

Press F1-F6 in the game to load example code:
- **F1**: Simple movements
- **F2**: For loop
- **F3**: If-else statement
- **F4**: While loop
- **F5**: Function definition
- **F6**: Nested control flow

## Language Documentation

See [LANGUAGE_REFERENCE.md](LANGUAGE_REFERENCE.md) for complete language documentation.

## Development

### Key Classes

#### TokenSystem (token.gd)
Defines all token types and the Token class.

#### Lexer (lexer.gd)
Tokenizes source code. Supports:
- Keywords (if, while, for, etc.)
- Operators (+, -, ==, !=, etc.)
- Identifiers and numbers
- Strings
- Comments (# and //)

#### Parser (parser.gd)
Builds AST using recursive descent parsing with proper operator precedence.

#### Interpreter (interpreter.gd)
Executes AST with:
- Variable scoping (supports nested scopes)
- Async command execution (for smooth animations)
- Function call stack
- Infinite loop protection

### Adding New Commands

To add a new movement command:

1. Add to player.gd:
```gdscript
func move_diagonal():
    var tween = create_tween()
    tween.tween_property(self, "position", position + Vector2(GRID_SIZE, GRID_SIZE), 0.25)
```

2. Add to interpreter.gd in `_execute_builtin_command`:
```gdscript
"moveDiagonal":
    current_player.move_diagonal()
    await get_tree().create_timer(0.3).timeout
```

3. Add to main.gd autocomplete:
```gdscript
var available_commands = [..., "moveDiagonal()"]
```

### Testing

Test files are located in `scripts/tests/`:
- `lexer_test.gd` - Tests tokenization
- `parser_test.gd` - Tests AST generation
- `interpreter_test.gd` - Tests execution

Run these as standalone scenes for testing.

## Future Enhancements

Potential features to add:
- [ ] Arrays and lists
- [ ] String manipulation functions
- [ ] More built-in functions (getX(), getY(), isBlocked(), etc.)
- [ ] Breakpoint debugging
- [ ] Step-through execution mode
- [ ] Multiple levels with challenges
- [ ] Visual feedback for execution flow
- [ ] Save/load code
- [ ] Leaderboards and challenges

## Credits

Built with Godot Engine 4.5

## License

[Add your license here]
