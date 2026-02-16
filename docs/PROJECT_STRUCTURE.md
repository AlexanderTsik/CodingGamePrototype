# LediBug Project Structure

**Last Updated**: February 2026 | **Status**: Reorganized & Optimized ✨

This document outlines the complete project structure and organization of the LediBug codebase.

---

## 📁 Root Directory Structure

```
LediBug_Project/
├── 📁 assets/              # Game assets (sprites, fonts, themes)
│   ├── fonts/              # Font files for UI
│   │   └── (various .ttf, .otf files)
│   ├── icons/              # Icon images
│   │   ├── icon.svg
│   │   └── icon.svg.import
│   ├── sprites/            # Game sprites (player, tiles, etc.)
│   │   ├── LediBugSprite.png
│   │   └── LediBugSprite.png.import
│   └── default_theme.tres  # Default UI theme
│
├── 📁 scenes/              # Godot scene files (.tscn) - ORGANIZED
│   ├── game/               # Core game scenes
│   │   ├── main.tscn       # Main game controller
│   │   └── player.tscn     # Player entity
│   └── ui/                 # UI/Menu scenes
│       ├── main_menu.tscn  # Main menu screen
│       ├── level_select.tscn  # Level selection browser
│       ├── custom_levels.tscn # Custom level browser
│       └── level_editor.tscn  # Visual level editor
│
├── 📁 scripts/             # GDScript source files - ORGANIZED BY MODULE
│   ├── core/               # Core game systems (3 files)
│   │   ├── player.gd       # Player movement, actions, sensors
│   │   ├── grid_manager.gd # Grid creation, collision, pathfinding
│   │   └── cell_types.gd   # Cell type definitions and behaviors
│   │
│   ├── language/           # Programming language implementation (6 files)
│   │   ├── lexer.gd        # Tokenizes source code
│   │   ├── parser.gd       # Builds Abstract Syntax Tree (AST)
│   │   ├── interpreter.gd  # Executes AST with async support
│   │   ├── ast_nodes.gd    # AST node class definitions
│   │   ├── token.gd        # Token class and types
│   │   └── code_executor.gd # High-level code execution controller
│   │
│   ├── debug/              # Debug system (2 files)
│   │   ├── debug_manager.gd  # Breakpoints, step execution, call stack
│   │   └── watch_manager.gd  # Variable watching and inspection
│   │
│   ├── ui/                 # UI controllers (5 files)
│   │   ├── main.gd         # Main game UI controller
│   │   ├── main_menu.gd    # Main menu controller
│   │   ├── level_select.gd # Level selection logic
│   │   ├── level_editor.gd # Level editor controller
│   │   └── custom_levels.gd # Custom level browser logic
│   │
│   ├── levels/             # Level management (2 files)
│   │   ├── level_definitions.gd # Built-in tutorial levels
│   │   └── simple_grid.gd  # Grid data structure
│   │
│   └── tests/              # Unit tests (3 files)
│       ├── interpreter_test.gd
│       ├── lexer_test.gd
│       └── parser_test.gd
│
├── 📁 docs/                # Documentation (4 files)
│   ├── comprehensive_LediBug_roadmap.md  # Complete 12-18 month roadmap
│   ├── LANGUAGE_REFERENCE.md  # Programming language documentation
│   ├── PROJECT_STRUCTURE.md   # This file
│   └── ENHANCEMENT_SUMMARY.md # Feature changelog
│
├── 📁 exports/             # Build artifacts (gitignored)
│   └── web/                # HTML5 web export
│       ├── CodingGamePrototype.html
│       ├── CodingGamePrototype.js
│       ├── CodingGamePrototype.wasm
│       ├── CodingGamePrototype.pck
│       └── (other export artifacts)
│
├── 📁 backend/             # .NET backend (Phase 1 - To Be Implemented)
│   └── README.md           # Backend implementation guide
│
├── 📁 resources/           # Runtime resources
│   ├── custom_levels/      # User-created levels (JSON files)
│   └── README.md
│
├── 📁 .godot/              # Godot editor metadata (auto-generated)
├── 📁 .git/                # Git version control
│
├── 📄 project.godot        # Godot project configuration
├── 📄 export_presets.cfg   # Export configuration for platforms
├── 📄 .gitignore           # Git ignore rules
├── 📄 .gitattributes       # Git attributes
├── 📄 .editorconfig        # Editor configuration
├── 📄 headers.txt          # HTTP headers for web export (COOP/COEP)
└── 📄 README.md            # Project overview and getting started
```

---

## 📂 Detailed Module Descriptions

### **Core Module** (`scripts/core/`)
The foundation of the game engine, handling player mechanics and grid systems.

**Files:**
- **player.gd** (600+ lines)
  - Turn-based movement system (`move()`, `turnRight()`, `turnLeft()`, `turnBack()`)
  - Sensor functions (`frontIsClear()`, `leftIsClear()`, `rightIsClear()`)
  - Goal detection, collision handling
  - Persistent facing direction across moves
  
- **grid_manager.gd** (400+ lines)
  - Dynamic grid creation (3x3 to 15x15)
  - Cell type management (walls, goals, hazards)
  - Pathfinding algorithms
  - Collision detection
  
- **cell_types.gd** (200+ lines)
  - Cell type enum definitions
  - Cell behavior logic
  - Visual rendering properties

### **Language Module** (`scripts/language/`)
Complete programming language interpreter with lexer → parser → interpreter pipeline.

**Files:**
- **lexer.gd** (200+ lines) - Tokenizes source code into tokens
- **parser.gd** (800+ lines) - Builds Abstract Syntax Tree from tokens
- **interpreter.gd** (600+ lines) - Executes AST with async support
- **ast_nodes.gd** (400+ lines) - Node classes for AST
- **token.gd** (100 lines) - Token class and TokenType enum
- **code_executor.gd** (300+ lines) - High-level execution controller

**Language Features:**
- Variables, arithmetic, comparisons, logic operators
- Control flow: `if/elif/else`, `for`, `while`, `do-while`
- Functions with parameters and return values
- Recursion support
- Error handling with colored feedback
- Infinite loop protection (10,000 iteration limit)

### **Debug Module** (`scripts/debug/`)
Professional debugging tools for step-through execution and variable inspection.

**Files:**
- **debug_manager.gd** (500+ lines)
  - Breakpoint management
  - Step execution (into, over, out)
  - Call stack visualization
  - Execution log with color coding
  
- **watch_manager.gd** (300+ lines)
  - Variable monitoring
  - Watch expressions
  - Value change tracking
  - Real-time variable viewer UI

### **UI Module** (`scripts/ui/`)
Controllers for all user interface screens and interactions.

**Files:**
- **main.gd** (1600+ lines) - Main game controller, IDE, syntax highlighting
- **main_menu.gd** (150 lines) - Main menu navigation
- **level_select.gd** (200 lines) - Level browser with filtering
- **level_editor.gd** (500+ lines) - Visual level editor with tile painting
- **custom_levels.gd** (300 lines) - Custom level management (save/load/delete)

### **Levels Module** (`scripts/levels/`)
Level data structures and built-in level definitions.

**Files:**
- **level_definitions.gd** (500+ lines) - 7 tutorial levels with progressive difficulty
- **simple_grid.gd** (200 lines) - Grid data structure and serialization

### **Tests Module** (`scripts/tests/`)
Unit tests for language components.

**Files:**
- **interpreter_test.gd** - Interpreter execution tests
- **lexer_test.gd** - Tokenization tests
- **parser_test.gd** - AST parsing tests

---

## 🎨 Assets Organization

### **Fonts** (`assets/fonts/`)
- UI fonts for code editor and menus
- Monospace fonts for code display

### **Icons** (`assets/icons/`)
- Application icons (SVG format)
- UI icons (buttons, controls)

### **Sprites** (`assets/sprites/`)
- **LediBugSprite.png** - Player character sprite (animated)
- Grid tile sprites (walls, goals, hazards)
- UI element sprites

### **Themes** (`assets/`)
- **default_theme.tres** - Base theme resource
- Dark/Light mode color schemes

---

## 📚 Documentation

### **comprehensive_LediBug_roadmap.md** (166 KB, 5,279 lines)
**The master implementation guide** covering:
- Complete current state analysis
- Phase 1-9 detailed implementation plans
- .NET backend architecture with full code examples
- C# entity models and API controllers
- Godot HTTP client integration
- Database schema (PostgreSQL)
- 12-18 month timeline with weekly breakdown
- Success metrics, team requirements, budget estimates
- Launch checklist and marketing strategy

### **LANGUAGE_REFERENCE.md**
Complete programming language documentation:
- Syntax reference for all language features
- Function documentation (movement, sensors, control flow)
- Code examples and common patterns
- Keyboard shortcuts
- Grid symbol legend

### **PROJECT_STRUCTURE.md** (This file)
Project organization and architecture overview.

### **ENHANCEMENT_SUMMARY.md**
Feature changelog and implementation notes.

---

## 🚀 Exports

### **Web Export** (`exports/web/`)
HTML5 build artifacts for web deployment:
- **CodingGamePrototype.html** - Main HTML page
- **CodingGamePrototype.js** - JavaScript loader
- **CodingGamePrototype.wasm** - WebAssembly binary
- **CodingGamePrototype.pck** - Game data package
- **headers.txt** - Required for COOP/COEP headers

**⚠️ Note**: This folder is gitignored. Export artifacts should not be committed.

---

## 🔧 Backend (Future)

### **Backend Folder** (`backend/`)
Placeholder for Phase 1 .NET backend implementation:

**Planned Structure:**
```
backend/
├── LediBug.API/           # ASP.NET Core Web API
├── LediBug.Core/          # Domain entities
├── LediBug.Application/   # Business logic
└── LediBug.Infrastructure/ # Data access
```

See `docs/comprehensive_LediBug_roadmap.md` Phase 1 for full implementation details.

---

## 📦 Resources

### **Custom Levels** (`resources/custom_levels/`)
User-created levels stored as JSON files:
- Created via in-game level editor
- Saved locally (desktop) or IndexedDB (web)
- Format: JSON with grid data, metadata, starter code

---

## 🔑 Key Configuration Files

### **project.godot**
Main Godot project configuration:
- Project settings (name, icon, version)
- Input mappings
- Display settings
- Physics settings

### **export_presets.cfg**
Export configurations for:
- HTML5 (Web)
- Windows Desktop
- Linux Desktop
- macOS Desktop

### **.gitignore**
Excludes from version control:
- `.godot/` - Editor metadata
- `exports/` - Build artifacts
- `backend/**/bin/`, `backend/**/obj/` - .NET build files
- `resources/custom_levels/*.json` - User data

### **headers.txt**
Required HTTP headers for web export:
```
Cross-Origin-Embedder-Policy: require-corp
Cross-Origin-Opener-Policy: same-origin
```

---

## 📊 Project Statistics

- **Total Scripts**: 21 GDScript files (~8,000+ lines of code)
- **Total Scenes**: 6 scene files
- **Total Assets**: Fonts, icons, sprites organized in subfolders
- **Documentation**: 4 comprehensive markdown files (200+ KB total)
- **Test Coverage**: 3 test suites for language components

---

## 🗺️ Navigation Tips

**Finding Specific Features:**
- **Player movement**: `scripts/core/player.gd`
- **Programming language**: `scripts/language/` (all 6 files)
- **Debug system**: `scripts/debug/` (both files)
- **UI/IDE**: `scripts/ui/main.gd` (main game controller)
- **Level editor**: `scripts/ui/level_editor.gd`
- **Tutorial levels**: `scripts/levels/level_definitions.gd`

**Common Tasks:**
- **Add new language feature**: Modify `lexer.gd`, `parser.gd`, `interpreter.gd`
- **Create new level**: Add to `level_definitions.gd` or use level editor
- **Add UI screen**: Create scene in `scenes/ui/` + script in `scripts/ui/`
- **Implement new cell type**: Modify `cell_types.gd` and `grid_manager.gd`

---

## ✨ Recent Reorganization (February 2026)

**Changes Made:**
1. ✅ **Organized scripts/** into 6 logical modules (core, language, debug, ui, levels, tests)
2. ✅ **Organized scenes/** into 2 categories (game, ui)
3. ✅ **Created exports/** folder for build artifacts (keeps root clean)
4. ✅ **Created backend/** placeholder for Phase 1 implementation
5. ✅ **Created resources/** for user-generated content
6. ✅ **Updated .gitignore** to exclude exports and build artifacts
7. ✅ **Moved all .uid files** with their corresponding scripts

**Benefits:**
- 🎯 **Easy navigation** - Related files grouped together
- 🧹 **Clean root directory** - Only essential config files
- 📦 **Module isolation** - Clear separation of concerns
- 🔍 **Quick file finding** - Know exactly where to look
- 🚀 **Scalable structure** - Ready for backend integration

---

*This structure is designed for scalability and maintainability as LediBug grows from a prototype to a full-featured platform with backend integration, community features, and competitive gameplay.*
