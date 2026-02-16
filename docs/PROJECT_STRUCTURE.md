# LediBug Project Structure

```
LediBug_Project/
├── assets/                  # Game assets
│   ├── icons/              # Application icons
│   │   ├── icon.svg
│   │   └── icon.svg.import
│   └── sprites/            # Character and UI sprites
│       ├── LediBugSprite.png
│       └── LediBugSprite.png.import
│
├── docs/                    # Documentation
│   ├── ENHANCEMENT_SUMMARY.md
│   └── LANGUAGE_REFERENCE.md
│
├── resources/               # Godot resources
│   └── levels/             # Level resource files (.tres)
│       ├── level_01.tres
│       ├── level_02.tres
│       └── ...
│
├── scenes/                  # Godot scene files (.tscn)
│   ├── custom_levels.tscn  # Custom level browser
│   ├── level_editor.tscn   # Level editor scene
│   ├── level_select.tscn   # Level selection menu
│   ├── main.tscn           # Main game scene
│   ├── main_menu.tscn      # Main menu
│   └── player.tscn         # Player character
│
├── scripts/                 # GDScript files
│   ├── tests/              # Unit tests
│   │   ├── interpreter_test.gd
│   │   ├── lexer_test.gd
│   │   └── parser_test.gd
│   │
│   ├── ast_node.gd         # AST node definitions
│   ├── cell_types.gd       # Grid cell type definitions
│   ├── code_executor.gd    # Code execution controller
│   ├── custom_levels.gd    # Custom level browser logic
│   ├── debug_manager.gd    # Debug system manager
│   ├── grid_manager.gd     # Grid/level manager
│   ├── interpreter.gd      # Code interpreter
│   ├── level_data.gd       # Level data resource
│   ├── level_definitions.gd # Built-in level definitions
│   ├── level_editor.gd     # Level editor logic
│   ├── level_select.gd     # Level selection logic
│   ├── lexer.gd            # Lexical analyzer
│   ├── main.gd             # Main game controller
│   ├── main_menu.gd        # Main menu logic
│   ├── parser.gd           # Syntax parser
│   ├── player.gd           # Player movement & sensors
│   ├── simple_grid.gd      # Grid rendering
│   ├── token.gd            # Token definitions
│   └── watch_manager.gd    # Debug watch expressions
│
├── .godot/                  # Godot editor cache (gitignored)
├── .editorconfig           # Editor configuration
├── .gitattributes          # Git attributes
├── .gitignore              # Git ignore rules
├── node_2d.tscn            # Empty template scene
├── project.godot           # Godot project file
└── README.md               # Project readme

## User Data Directory Structure

Custom levels are saved in the user data directory:
```
user://
└── custom_levels/          # User-created levels
    ├── my_level.json
    ├── maze_1.json
    └── ...
```

Location varies by platform:
- **Windows**: `%APPDATA%\Godot\app_userdata\LediBug/`
- **macOS**: `~/Library/Application Support/Godot/app_userdata/LediBug/`
- **Linux**: `~/.local/share/godot/app_userdata/LediBug/`

## File Types

- **.tscn** - Godot scene files (text format)
- **.tres** - Godot resource files (text format)
- **.gd** - GDScript files
- **.json** - Custom level data files
- **.import** - Godot import configuration files
