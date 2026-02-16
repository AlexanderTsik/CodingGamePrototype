# LediBug: Comprehensive Feature Roadmap & Implementation Guide
## 🚀 Updated: February 2026 | Version 2.0

---

## 🎯 Vision Statement

Transform LediBug into a **world-class web-based competitive programming platform** where players learn real programming concepts through engaging puzzle-solving, share custom levels with a global community, and compete on algorithm efficiency - combining the educational depth of **LeetCode** with the accessibility of **gamification** for beginners and enthusiasts alike.

### Core Pillars:
1. **Educational Excellence** - Progressive learning with instant feedback
2. **Competitive Spirit** - Real-time leaderboards and challenges
3. **Community Driven** - User-generated content and collaboration
4. **Accessibility First** - Web-based, mobile-friendly, multilingual
5. **Technical Depth** - Real programming concepts, not simplified abstractions

---

## 📊 Current State Analysis (February 2026)

### ✅ IMPLEMENTED FEATURES (Current Build)

#### 🎮 **Core Game Engine**
- ✅ **Turn-Based Movement System**
  - `move()` - Move forward one cell in current facing direction
  - `turnRight()` - Rotate 90° clockwise
  - `turnLeft()` - Rotate 90° counter-clockwise
  - `turnBack()` - Rotate 180°
  - Persistent facing direction between moves
  - Smooth rotation animations with sprite updates
  
- ✅ **Advanced Sensor System**
  - `frontIsClear()` - Check if forward cell is walkable
  - `leftIsClear()` - Check if left cell is walkable (relative to facing)
  - `rightIsClear()` - Check if right cell is walkable (relative to facing)
  - `goalReached()` / `onGoal()` - Check if standing on goal tile
  - `onHazard()` - Check if standing on hazard (death tile)
  - All sensors work **relative to player's current facing direction**
  
- ✅ **Grid System**
  - Dynamic grid sizing (3x3 to 15x15)
  - Collision detection
  - Cell types: Empty, Wall, Start, Goal, Hazard
  - Grid manager with pathfinding capabilities
  - Visual grid rendering with customizable colors

- ✅ **Level System**
  - 7 built-in tutorial levels with progressive difficulty
  - Custom level editor with visual tile placement
  - Save/load custom levels (JSON format, local storage)
  - Level browser with Play/Edit/Delete functionality
  - Starter code and hints per level
  - Grid resize in editor (3x3 to 15x15)

#### 💻 **Programming Language Implementation**

- ✅ **Complete Interpreter Pipeline**
  - **Lexer** (lexer.gd): Tokenizes source code
  - **Parser** (parser.gd): Builds Abstract Syntax Tree (AST)
  - **Interpreter** (interpreter.gd): Executes AST with async support
  - **AST Nodes** (ast_nodes.gd): Complete node definitions
  
- ✅ **Language Features**
  - **Variables**: Dynamic typing, no declaration needed
  - **Arithmetic Operators**: `+`, `-`, `*`, `/`, `%`
  - **Comparison Operators**: `==`, `!=`, `<`, `>`, `<=`, `>=`
  - **Logical Operators**: `and`, `or`, `not`, `!`
  - **Control Flow**:
    - `if` / `elif` / `else` statements
    - `for` loops with `range(start, end, step)`
    - `while` loops
    - `do-while` loops
    - Nested structures support
  - **Functions**:
    - User-defined functions with parameters
    - Return statements
    - Function call stack
    - Recursive functions support
  - **Comments**: `#` single-line comments
  - **Error Handling**:
    - Colored error messages (red with ❌)
    - Success feedback (green with ✓)
    - Death feedback (orange with 💀)
    - Line number tracking in errors
  - **Infinite Loop Protection**: 10,000 iteration limit

#### 🛠️ **IDE Features (Professional-Grade)**

- ✅ **Code Editor**
  - Full-featured CodeEdit component
  - Line numbers with gutter
  - Syntax highlighting (theme-aware):
    - **Keywords** (if/for/while): Bright magenta (dark) / Dark purple (light)
    - **Functions** (move/turnRight): Bright cyan (dark) / Dark blue (light)
    - **Strings**: Bright yellow (dark) / Dark olive (light)
    - **Numbers**: Bright orange (dark) / Dark brown (light)
    - **Comments**: Gray-green (dark) / Dark gray (light)
    - **Symbols/Brackets**: Light gray (dark) / Dark gray (light)
  - Code completion with autocomplete dropdown
  - Current line highlighting
  - Caret positioning and navigation
  
- ✅ **Themes System**
  - Dark theme (default): Professional dark code editor
  - Light theme: High contrast for accessibility
  - Toggle button (☀️ Light / 🌙 Dark)
  - Theme-aware syntax highlighting
  - Persistent theme preference

- ✅ **Resizable Panels**
  - Horizontal split (code editor ↔ game view)
  - Vertical split (top section ↔ debug panels)
  - Adjustable panel sizes with drag handles
  - Minimum size constraints
  - Responsive layout

- ✅ **Interactive Help System**
  - Help button (❓) with comprehensive command reference
  - Scrollable popup (700x600px)
  - Organized sections:
    - Movement Commands
    - Sensor Functions
    - Control Flow
    - Functions & Variables
    - Code Examples
  - Keyboard shortcut display

#### 🐞 **Debug System (Full-Featured)**

- ✅ **Debug Mode**
  - Separate Run (▶️) and Debug (🐞) buttons
  - Stop button (⏹) to halt execution
  - Debug toolbar with controls
  - Step-by-step execution
  - Visual debug panels (show/hide on mode switch)
  
- ✅ **Breakpoints**
  - Click line gutter to toggle breakpoints
  - Visual red circle icons
  - Pause execution at breakpoint lines
  - Continue/step after breakpoint hit
  
- ✅ **Variable Viewer**
  - Shows all variables in current scope
  - Updates in real-time during execution
  - Displays variable names and values
  - Tree view for nested scopes
  
- ✅ **Watch Expressions**
  - Add custom expressions to watch
  - Evaluates expressions during execution
  - Shows results in real-time
  - Add/remove watch entries
  
- ✅ **Call Stack Viewer**
  - Displays function call hierarchy
  - Shows current execution context
  - Clickable stack frames
  - Function parameters visible
  
- ✅ **Execution Log**
  - Records all executed commands
  - Timestamped entries
  - Scrollable history
  - Clear log functionality
  
- ✅ **Line Highlighting**
  - Blue highlight on currently executing line
  - Smooth scrolling to current line
  - Visual feedback during step execution

#### 🎨 **Visual Polish**

- ✅ **Animations**
  - Smooth player movement (tween-based)
  - Rotation animations for turning
  - Sprite updates based on facing direction
  - Grid cell highlighting
  
- ✅ **UI Styling**
  - Professionally styled buttons:
    - Run button: Green (#28A745)
    - Debug button: Orange (#FD7E14)
    - Stop button: Red (#DC3545)
  - Rounded corners on panels
  - Consistent color scheme
  - Responsive button states (hover, pressed, disabled)
  
- ✅ **Feedback Systems**
  - Color-coded output messages
  - Emoji indicators (✓, ❌, 💀, 🎉)
  - Success/failure animations
  - Level completion celebration

#### 📁 **Project Structure**

- ✅ **Organized File Structure**
  ```
  LediBug_Project/
  ├── assets/
  │   ├── icons/              # Project icons
  │   └── sprites/            # Game sprites
  ├── docs/
  │   ├── ENHANCEMENT_SUMMARY.md
  │   ├── LANGUAGE_REFERENCE.md
  │   ├── PROJECT_STRUCTURE.md
  │   └── comprehensive_LediBug_roadmap.md
  ├── resources/
  │   └── cell_highlight.tres
  ├── scenes/
  │   ├── main.tscn           # Main game scene
  │   ├── main_menu.tscn      # Main menu
  │   ├── level_editor.tscn   # Level editor
  │   ├── custom_levels.tscn  # Custom level browser
  │   ├── level_select.tscn   # Level selector
  │   └── player.tscn         # Player character
  └── scripts/
      ├── main.gd             # Main game controller (1600+ lines)
      ├── player.gd           # Turn-based movement
      ├── code_executor.gd    # Execution pipeline
      ├── lexer.gd            # Tokenizer
      ├── parser.gd           # AST parser
      ├── interpreter.gd      # AST interpreter
      ├── ast_nodes.gd        # AST definitions
      ├── debug_manager.gd    # Breakpoint system
      ├── watch_manager.gd    # Watch expressions
      ├── grid_manager.gd     # Grid & collision
      ├── simple_grid.gd      # Grid rendering
      ├── level_definitions.gd # Built-in levels
      ├── level_editor.gd     # Editor logic
      ├── custom_levels.gd    # Custom level management
      ├── main_menu.gd        # Menu controller
      └── cell_types.gd       # Cell type enum
  ```

- ✅ **Documentation**
  - Complete README.md
  - Language Reference Guide
  - Project Structure Documentation
  - Enhancement Summary

---

### ⚠️ CURRENT LIMITATIONS (Need Implementation)

#### 🌐 **Platform & Distribution**
- ❌ **Desktop only** - No web browser access
- ❌ **No mobile support** - Not optimized for touch devices
- ❌ **No cloud deployment** - Runs locally only
- ❌ **No cross-platform saves** - Local storage only

#### 👤 **User Management**
- ❌ **No user accounts** - No authentication system
- ❌ **No progress tracking** - Can't save progress across devices
- ❌ **No profile system** - No user stats or achievements
- ❌ **No user preferences** - Theme resets on restart

#### 🌍 **Social & Community**
- ❌ **No level sharing** - Custom levels are local only
- ❌ **No online leaderboards** - No competition system
- ❌ **No ratings/reviews** - Can't rate or review levels
- ❌ **No comments** - No community feedback mechanism
- ❌ **No level discovery** - Can't browse others' levels
- ❌ **No search/filter** - Can't find levels by tags

#### 💻 **Language Limitations**
- ❌ **No arrays/lists** - Can't store collections
- ❌ **No objects/dictionaries** - No complex data structures
- ❌ **No string manipulation** - Limited string operations
- ❌ **No math library** - No sqrt, abs, min, max, etc.
- ❌ **No advanced control** - No break, continue in loops
- ❌ **No error handling** - No try/catch mechanism

#### 📚 **Educational Gaps**
- ❌ **No tutorial system** - No guided learning path
- ❌ **No hints system** - No progressive help
- ❌ **No code analysis** - No efficiency metrics
- ❌ **No solution comparison** - Can't see optimal solutions
- ❌ **No concept explanations** - No algorithm education
- ❌ **No achievement badges** - No learning milestones

#### 🎮 **Game Features Missing**
- ❌ **No test cases** - Levels don't validate properly
- ❌ **No level verification** - Can't ensure levels are solvable
- ❌ **No thumbnail generation** - Levels have no preview images
- ❌ **No difficulty ratings** - No automatic difficulty assessment
- ❌ **Limited cell types** - No portals, switches, collectibles, etc.
- ❌ **No sound effects** - Silent gameplay
- ❌ **No music** - No background audio
- ❌ **No particle effects** - Limited visual feedback

---

## 🚀 PHASE 1: Web Deployment & .NET Backend Foundation
### **Priority: CRITICAL** | **Timeline: 3-4 weeks**

---

### 1.1 Export to Web (Godot HTML5) ⚡
**Timeline: 3-5 days** | **Difficulty: Medium**

#### **Goal**
Make LediBug accessible via web browser without any installation, supporting all major desktop and mobile browsers.

#### **Prerequisites**
1. Godot 4.3+ with HTML5 export templates
2. Understanding of web limitations (IndexedDB, no native file system)
3. Web hosting provider selected (Netlify/Vercel/Cloudflare Pages)
4. SSL certificate for HTTPS (required for SharedArrayBuffer)

#### **Step-by-Step Implementation**

##### **Step 1: Install Export Templates**
```gdscript
# In Godot Editor
Editor → Manage Export Templates → Download

# Verify installation
Project → Export → Add → Web
```

##### **Step 2: Configure Export Preset**

Create `export_presets.cfg`:
```ini
[preset.0]

name="Web"
platform="Web"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="build/web/index.html"
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false

[preset.0.options]

custom_template/debug=""
custom_template/release=""
variant/extensions_support=false
vram_texture_compression/for_desktop=true
vram_texture_compression/for_mobile=false
html/export_icon=true
html/custom_html_shell=""
html/head_include=""
html/canvas_resize_policy=2
html/focus_canvas_on_start=true
html/experimental_virtual_keyboard=false
progressive_web_app/enabled=true
progressive_web_app/offline_page=""
progressive_web_app/display=1
progressive_web_app/orientation=0
progressive_web_app/icon_144x144=""
progressive_web_app/icon_180x180=""
progressive_web_app/icon_512x512=""
progressive_web_app/background_color=Color(0, 0, 0, 1)
```

##### **Step 3: Modify for Web Compatibility**

**File: `scripts/custom_levels.gd`**
```gdscript
extends Control

const SAVE_DIR = "user://custom_levels/"
var is_web_platform: bool = false

func _ready():
	# Detect platform
	is_web_platform = OS.has_feature("web")
	
	if is_web_platform:
		_setup_web_storage()
	else:
		_setup_native_storage()
	
	_load_levels()

func _setup_web_storage():
	print("Using IndexedDB for web storage")
	# Web uses IndexedDB automatically with user:// prefix
	# Godot 4.x handles this internally

func _setup_native_storage():
	print("Using native file system")
	# Ensure directory exists
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func save_level(level_data: Dictionary) -> bool:
	var file_name = level_data.get("level_name", "Untitled").replace(" ", "_")
	var file_path = SAVE_DIR + file_name + ".json"
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("Failed to save level: " + file_path)
		return false
	
	file.store_string(JSON.stringify(level_data, "\t"))
	file.close()
	
	if is_web_platform:
		# Sync IndexedDB to persistent storage
		_sync_web_storage()
	
	return true

func _sync_web_storage():
	# Force IndexedDB sync on web
	if OS.has_feature("web"):
		# Godot automatically syncs user:// to IndexedDB
		pass

func load_level(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		push_error("Level file does not exist: " + file_path)
		return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error != OK:
		push_error("JSON Parse Error: " + json.get_error_message())
		return {}
	
	return json.data

func get_all_custom_levels() -> Array:
	var levels = []
	var dir = DirAccess.open(SAVE_DIR)
	
	if not dir:
		return levels
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			levels.append(SAVE_DIR + file_name)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	return levels
```

**File: `scripts/main.gd`** (Add platform detection)
```gdscript
var is_web_platform: bool = false

func _ready():
	is_web_platform = OS.has_feature("web")
	
	if is_web_platform:
		print("Running on Web platform")
		_configure_for_web()
	else:
		print("Running on Desktop platform")
	
	# ... existing _ready code ...

func _configure_for_web():
	# Disable features not supported on web
	# Adjust UI for web environment
	
	# Example: Disable file dialogs that don't work on web
	# Use in-game file browsers instead
	pass
```

##### **Step 4: Build for Web**

```bash
# Export from Godot Editor
Project → Export → Web → Export Project

# Or via command line
godot --export-release "Web" build/web/index.html
```

##### **Step 5: Deploy to Netlify**

**Create `netlify.toml`:**
```toml
[build]
  publish = "build/web"
  command = "echo 'No build needed'"

[[headers]]
  for = "/*"
  [headers.values]
    Cross-Origin-Embedder-Policy = "require-corp"
    Cross-Origin-Opener-Policy = "same-origin"
    X-Content-Type-Options = "nosniff"
    X-Frame-Options = "DENY"
    X-XSS-Protection = "1; mode=block"

[[headers]]
  for = "/*.wasm"
  [headers.values]
    Content-Type = "application/wasm"

[[headers]]
  for = "/*.pck"
  [headers.values]
    Content-Type = "application/octet-stream"
```

**Deploy:**
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login to Netlify
netlify login

# Deploy
netlify deploy --prod --dir=build/web
```

##### **Step 6: Test Checklist**

- [ ] Game loads in Chrome (desktop)
- [ ] Game loads in Firefox (desktop)
- [ ] Game loads in Safari (desktop)
- [ ] Game loads in Edge (desktop)
- [ ] Custom levels save and load
- [ ] Code execution works correctly
- [ ] Debug mode functions properly
- [ ] Themes persist across sessions
- [ ] Mobile browser compatibility (Chrome/Safari iOS/Android)
- [ ] Touch controls work (if implemented)
- [ ] No console errors
- [ ] 60 FPS performance
- [ ] SharedArrayBuffer enabled (check browser console)

#### **Alternative Deployment Options**

**Vercel:**
```json
// vercel.json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "Cross-Origin-Embedder-Policy", "value": "require-corp" },
        { "key": "Cross-Origin-Opener-Policy", "value": "same-origin" }
      ]
    }
  ]
}
```

**Cloudflare Pages:**
```toml
# _headers file in build/web/
/*
  Cross-Origin-Embedder-Policy: require-corp
  Cross-Origin-Opener-Policy: same-origin
  X-Content-Type-Options: nosniff
```

**GitHub Pages:**
```html
<!-- Add to index.html head -->
<meta http-equiv="Cross-Origin-Embedder-Policy" content="require-corp">
<meta http-equiv="Cross-Origin-Opener-Policy" content="same-origin">
```

#### **Files to Create/Modify**
- ✅ `export_presets.cfg` - Export configuration
- ✅ `netlify.toml` - Deployment config
- ✅ `scripts/custom_levels.gd` - Web storage compatibility
- ✅ `scripts/main.gd` - Platform detection
- ✅ `.gitignore` - Ignore build folder

#### **Common Issues & Solutions**

| Issue | Solution |
|-------|----------|
| SharedArrayBuffer not available | Ensure proper COOP/COEP headers |
| Custom levels don't persist | IndexedDB needs explicit sync on web |
| Slow loading | Enable gzip compression on server |
| Mobile touch issues | Implement touch input handling |
| Audio doesn't work | User gesture required to start audio |

---

### 1.2 Backend Architecture with .NET 🏗️
**Timeline: 2-3 weeks** | **Difficulty: High**

#### **Why .NET for LediBug Backend?**

##### **✅ Technical Advantages**

| Feature | .NET Benefit | Impact on LediBug |
|---------|--------------|-------------------|
| **Performance** | Faster than Node.js, especially under load | Handle thousands of concurrent users |
| **Type Safety** | C# strong typing prevents runtime errors | Fewer bugs, easier refactoring |
| **Async/Await** | Built-in, first-class support | Smooth handling of DB queries & API calls |
| **Entity Framework** | Powerful ORM with LINQ | Clean database code, easy migrations |
| **SignalR** | Built-in real-time WebSocket library | Real-time leaderboards without extra setup |
| **ASP.NET Identity** | Complete auth system out-of-the-box | User accounts, roles, JWT in < 1 day |
| **Dependency Injection** | Built into framework | Clean architecture, testable code |
| **Cross-Platform** | Runs on Windows, Linux, macOS | Deploy anywhere (Azure, AWS, Docker) |
| **Free & Open Source** | MIT license | No licensing costs ever |
| **Excellent Tooling** | VS Code, Visual Studio, Rider | Great debugging, IntelliSense, refactoring |

##### **🎯 Perfect for Game Backend**

1. **High Concurrency**: Handles 10,000+ simultaneous users easily
2. **Low Latency**: <50ms API response times typical
3. **Minimal Memory**: 50-100MB base memory footprint
4. **Easy Scaling**: Horizontal scaling with minimal config
5. **WebSocket Native**: SignalR for real-time features (leaderboards, multiplayer)
6. **PostgreSQL Integration**: First-class support with Npgsql

##### **📊 Comparison**

| Aspect | .NET | Node.js | Python/FastAPI |
|--------|------|---------|----------------|
| Performance | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| Type Safety | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ |
| Learning Curve | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Built-in Auth | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| Real-time Support | ⭐⭐⭐⭐⭐ (SignalR) | ⭐⭐⭐⭐ (Socket.io) | ⭐⭐⭐ |
| ORM Quality | ⭐⭐⭐⭐⭐ (EF Core) | ⭐⭐⭐ (Sequelize) | ⭐⭐⭐⭐ (SQLAlchemy) |
| Game Backend Examples | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |

**Verdict: .NET is the BEST choice for LediBug!** ✅

---

#### **Complete .NET Backend Architecture**

##### **Tech Stack**

```yaml
Framework: ASP.NET Core 8.0 (LTS)
Language: C# 12
Database: PostgreSQL 16
ORM: Entity Framework Core 8
Caching: Redis (StackExchange.Redis)
Authentication: ASP.NET Core Identity + JWT
OAuth: Google, GitHub, Discord
Real-time: SignalR
API Style: REST + SignalR Hubs
File Storage: Azure Blob Storage / AWS S3
Hosting: Azure App Service / Railway / AWS
CI/CD: GitHub Actions
Monitoring: Application Insights / Sentry
Testing: xUnit + Moq + FluentAssertions
```

##### **Project Structure**

```
LediBugBackend/
├── src/
│   ├── LediBug.API/                    # ASP.NET Core Web API
│   │   ├── Controllers/                # REST API endpoints
│   │   │   ├── AuthController.cs
│   │   │   ├── LevelsController.cs
│   │   │   ├── SolutionsController.cs
│   │   │   ├── LeaderboardsController.cs
│   │   │   ├── UsersController.cs
│   │   │   └── ChallengesController.cs
│   │   ├── Hubs/                       # SignalR real-time hubs
│   │   │   ├── LeaderboardHub.cs
│   │   │   └── NotificationHub.cs
│   │   ├── Middleware/                 # Custom middleware
│   │   │   ├── ExceptionHandlingMiddleware.cs
│   │   │   ├── RequestLoggingMiddleware.cs
│   │   │   └── RateLimitingMiddleware.cs
│   │   ├── Filters/                    # Action filters
│   │   │   ├── ValidationFilter.cs
│   │   │   └── AuthorizationFilter.cs
│   │   ├── Program.cs                  # Application entry point
│   │   ├── appsettings.json            # Configuration
│   │   └── appsettings.Development.json
│   │
│   ├── LediBug.Core/                   # Business logic (no dependencies)
│   │   ├── Entities/                   # Domain models
│   │   │   ├── User.cs
│   │   │   ├── Level.cs
│   │   │   ├── Solution.cs
│   │   │   ├── Leaderboard.cs
│   │   │   ├── Achievement.cs
│   │   │   ├── Challenge.cs
│   │   │   └── Comment.cs
│   │   ├── Interfaces/                 # Abstractions
│   │   │   ├── Repositories/
│   │   │   │   ├── IUserRepository.cs
│   │   │   │   ├── ILevelRepository.cs
│   │   │   │   └── ISolutionRepository.cs
│   │   │   └── Services/
│   │   │       ├── IAuthService.cs
│   │   │       ├── ILevelService.cs
│   │   │       ├── ILeaderboardService.cs
│   │   │       └── IChallengeService.cs
│   │   ├── DTOs/                       # Data Transfer Objects
│   │   │   ├── Auth/
│   │   │   ├── Levels/
│   │   │   ├── Solutions/
│   │   │   └── Users/
│   │   ├── Enums/                      # Enumerations
│   │   │   ├── CellType.cs
│   │   │   ├── Difficulty.cs
│   │   │   └── ChallengeType.cs
│   │   ├── Exceptions/                 # Custom exceptions
│   │   │   ├── NotFoundException.cs
│   │   │   ├── ValidationException.cs
│   │   │   └── UnauthorizedException.cs
│   │   └── Validators/                 # FluentValidation validators
│   │       ├── CreateLevelValidator.cs
│   │       └── SubmitSolutionValidator.cs
│   │
│   ├── LediBug.Application/            # Application services
│   │   ├── Services/                   # Business logic implementation
│   │   │   ├── AuthService.cs
│   │   │   ├── LevelService.cs
│   │   │   ├── SolutionService.cs
│   │   │   ├── LeaderboardService.cs
│   │   │   ├── AchievementService.cs
│   │   │   └── ChallengeService.cs
│   │   ├── Mappings/                   # AutoMapper profiles
│   │   │   └── MappingProfile.cs
│   │   └── Helpers/                    # Utility classes
│   │       ├── JwtHelper.cs
│   │       ├── PasswordHasher.cs
│   │       └── ScoreCalculator.cs
│   │
│   └── LediBug.Infrastructure/         # Data access & external services
│       ├── Data/                       # Database context
│       │   ├── LediBugDbContext.cs
│       │   └── Configurations/         # Entity configurations
│       │       ├── UserConfiguration.cs
│       │       ├── LevelConfiguration.cs
│       │       └── SolutionConfiguration.cs
│       ├── Repositories/               # Repository implementations
│       │   ├── UserRepository.cs
│       │   ├── LevelRepository.cs
│       │   ├── SolutionRepository.cs
│       │   └── GenericRepository.cs
│       ├── Migrations/                 # EF Core migrations
│       ├── Services/                   # External service integrations
│       │   ├── EmailService.cs
│       │   ├── BlobStorageService.cs
│       │   └── CacheService.cs
│       └── Identity/                   # ASP.NET Identity setup
│           └── ApplicationUser.cs
│
├── tests/
│   ├── LediBug.UnitTests/              # Unit tests
│   │   ├── Services/
│   │   └── Validators/
│   ├── LediBug.IntegrationTests/       # Integration tests
│   │   ├── Controllers/
│   │   └── Repositories/
│   └── LediBug.E2ETests/               # End-to-end tests
│
├── docker/
│   ├── Dockerfile                      # Docker image definition
│   └── docker-compose.yml              # Local development setup
│
├── .github/
│   └── workflows/
│       ├── ci.yml                      # Continuous integration
│       └── cd.yml                      # Continuous deployment
│
├── scripts/
│   ├── setup-database.sql              # Database initialization
│   └── seed-data.sql                   # Sample data
│
├── LediBugBackend.sln                  # Solution file
├── .gitignore
├── README.md
└── LICENSE
```

---

#### **Database Schema (PostgreSQL)**

##### **Complete SQL Schema**

```sql
-- =====================================================
-- LediBug Database Schema
-- PostgreSQL 16+
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For text search

-- =====================================================
-- USERS & AUTHENTICATION
-- =====================================================

CREATE TABLE "Users" (
    "UserId" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "Username" VARCHAR(50) UNIQUE NOT NULL,
    "Email" VARCHAR(255) UNIQUE NOT NULL,
    "PasswordHash" VARCHAR(255),              -- NULL for OAuth users
	"OAuthProvider" VARCHAR(50),              -- 'Google', 'GitHub', 'Discord', NULL
    "OAuthId" VARCHAR(255),
    "DisplayName" VARCHAR(100) NOT NULL,
    "AvatarUrl" TEXT,
    "Bio" TEXT,
    "CountryCode" CHAR(2),
    "TotalXP" INTEGER NOT NULL DEFAULT 0,
    "PlayerLevel" INTEGER NOT NULL DEFAULT 1,
    "IsEmailVerified" BOOLEAN NOT NULL DEFAULT FALSE,
    "IsBanned" BOOLEAN NOT NULL DEFAULT FALSE,
	"Role" VARCHAR(20) NOT NULL DEFAULT 'Player', -- 'Player', 'Moderator', 'Admin'
    "CreatedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    "UpdatedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    "LastLogin" TIMESTAMP,
    
    CONSTRAINT "CK_Users_PlayerLevel" CHECK ("PlayerLevel" >= 1),
    CONSTRAINT "CK_Users_TotalXP" CHECK ("TotalXP" >= 0)
);

-- Indexes for Users
CREATE INDEX "IX_Users_Username" ON "Users"("Username");
CREATE INDEX "IX_Users_Email" ON "Users"("Email");
CREATE INDEX "IX_Users_TotalXP" ON "Users"("TotalXP" DESC);
CREATE INDEX "IX_Users_CreatedAt" ON "Users"("CreatedAt" DESC);
CREATE INDEX "IX_Users_OAuthProvider_OAuthId" ON "Users"("OAuthProvider", "OAuthId") WHERE "OAuthProvider" IS NOT NULL;

-- =====================================================
-- LEVELS
-- =====================================================

CREATE TABLE "Levels" (
    "LevelId" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "CreatorId" UUID NOT NULL REFERENCES "Users"("UserId") ON DELETE CASCADE,
    "Title" VARCHAR(100) NOT NULL,
    "Description" TEXT,
    "GridWidth" INTEGER NOT NULL CHECK ("GridWidth" BETWEEN 3 AND 15),
    "GridHeight" INTEGER NOT NULL CHECK ("GridHeight" BETWEEN 3 AND 15),
    "LayoutData" TEXT NOT NULL,               -- JSON string of grid layout
    "StarterCode" TEXT,
    "HintText" TEXT,
    "Difficulty" INTEGER CHECK ("Difficulty" BETWEEN 1 AND 5),
    "Tags" TEXT[],                            -- Array of tags
    "IsOfficial" BOOLEAN NOT NULL DEFAULT FALSE,
    "IsPublished" BOOLEAN NOT NULL DEFAULT FALSE,
    "IsFeatured" BOOLEAN NOT NULL DEFAULT FALSE,
    "ThumbnailUrl" TEXT,
    "PlayCount" INTEGER NOT NULL DEFAULT 0,
    "CompletionCount" INTEGER NOT NULL DEFAULT 0,
    "AverageRating" DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    "RatingCount" INTEGER NOT NULL DEFAULT 0,
    "AverageSteps" INTEGER,
    "AverageTime" INTEGER,                    -- Milliseconds
    "CreatedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    "UpdatedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    
    CONSTRAINT "CK_Levels_AverageRating" CHECK ("AverageRating" BETWEEN 0 AND 5),
    CONSTRAINT "CK_Levels_Counts" CHECK (
        "PlayCount" >= "CompletionCount" AND 
        "CompletionCount" >= 0 AND 
        "RatingCount" >= 0
    )
);

-- Indexes for Levels
CREATE INDEX "IX_Levels_CreatorId" ON "Levels"("CreatorId");
CREATE INDEX "IX_Levels_Difficulty" ON "Levels"("Difficulty");
CREATE INDEX "IX_Levels_IsOfficial" ON "Levels"("IsOfficial") WHERE "IsOfficial" = TRUE;
CREATE INDEX "IX_Levels_IsPublished" ON "Levels"("IsPublished") WHERE "IsPublished" = TRUE;
CREATE INDEX "IX_Levels_IsFeatured" ON "Levels"("IsFeatured") WHERE "IsFeatured" = TRUE;
CREATE INDEX "IX_Levels_Tags" ON "Levels" USING GIN("Tags");  -- GIN index for array searches
CREATE INDEX "IX_Levels_PlayCount" ON "Levels"("PlayCount" DESC);
CREATE INDEX "IX_Levels_AverageRating" ON "Levels"("AverageRating" DESC);
CREATE INDEX "IX_Levels_CreatedAt" ON "Levels"("CreatedAt" DESC);
CREATE INDEX "IX_Levels_Title_Trgm" ON "Levels" USING GIN("Title" gin_trgm_ops); -- Full-text search

-- =====================================================
-- SOLUTIONS
-- =====================================================

CREATE TABLE "Solutions" (
    "SolutionId" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "LevelId" UUID NOT NULL REFERENCES "Levels"("LevelId") ON DELETE CASCADE,
    "UserId" UUID NOT NULL REFERENCES "Users"("UserId") ON DELETE CASCADE,
    "Code" TEXT NOT NULL,
    "IsCompleted" BOOLEAN NOT NULL DEFAULT FALSE,
    "ExecutionTime" INTEGER,                  -- Milliseconds
    "StepCount" INTEGER,                      -- Number of moves
    "CodeLength" INTEGER,                     -- Character count
    "CommandCount" INTEGER,                   -- Number of commands executed
    "TestCasesPassed" INTEGER,
    "TestCasesTotal" INTEGER,
    "Score" INTEGER,                          -- Composite score
    "SubmittedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    "IsBestSolution" BOOLEAN NOT NULL DEFAULT FALSE,
    
    CONSTRAINT "CK_Solutions_Metrics" CHECK (
        ("ExecutionTime" IS NULL OR "ExecutionTime" >= 0) AND
        ("StepCount" IS NULL OR "StepCount" >= 0) AND
        ("CodeLength" IS NULL OR "CodeLength" >= 0) AND
        ("CommandCount" IS NULL OR "CommandCount" >= 0)
    ),
    
    -- Only one best solution per user per level
    CONSTRAINT "UQ_Solutions_BestPerUserLevel" 
        UNIQUE ("LevelId", "UserId") 
        WHERE "IsBestSolution" = TRUE
);

-- Indexes for Solutions
CREATE INDEX "IX_Solutions_LevelId" ON "Solutions"("LevelId");
CREATE INDEX "IX_Solutions_UserId" ON "Solutions"("UserId");
CREATE INDEX "IX_Solutions_IsCompleted" ON "Solutions"("IsCompleted");
CREATE INDEX "IX_Solutions_SubmittedAt" ON "Solutions"("SubmittedAt" DESC);
CREATE INDEX "IX_Solutions_LevelId_Score" ON "Solutions"("LevelId", "Score" DESC);
CREATE INDEX "IX_Solutions_IsBestSolution" ON "Solutions"("IsBestSolution") WHERE "IsBestSolution" = TRUE;

-- =====================================================
-- LEADERBOARDS
-- =====================================================

CREATE TABLE "Leaderboards" (
    "LeaderboardId" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "LevelId" UUID NOT NULL REFERENCES "Levels"("LevelId") ON DELETE CASCADE,
    "UserId" UUID NOT NULL REFERENCES "Users"("UserId") ON DELETE CASCADE,
    "SolutionId" UUID NOT NULL REFERENCES "Solutions"("SolutionId") ON DELETE CASCADE,
    "Rank" INTEGER NOT NULL,
    "StepCount" INTEGER NOT NULL,
    "ExecutionTime" INTEGER NOT NULL,
    "CodeLength" INTEGER NOT NULL,
    "Score" INTEGER NOT NULL,
    "SubmittedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    "UpdatedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    
    CONSTRAINT "UQ_Leaderboards_LevelUser" UNIQUE ("LevelId", "UserId"),
    CONSTRAINT "CK_Leaderboards_Rank" CHECK ("Rank" > 0)
);

-- Indexes for Leaderboards
CREATE INDEX "IX_Leaderboards_LevelId_Rank" ON "Leaderboards"("LevelId", "Rank" ASC);
CREATE INDEX "IX_Leaderboards_UserId" ON "Leaderboards"("UserId");
CREATE INDEX "IX_Leaderboards_Score" ON "Leaderboards"("LevelId", "Score" DESC);
CREATE INDEX "IX_Leaderboards_StepCount" ON "Leaderboards"("LevelId", "StepCount" ASC);
CREATE INDEX "IX_Leaderboards_ExecutionTime" ON "Leaderboards"("LevelId", "ExecutionTime" ASC);

-- =====================================================
-- USER PROGRESS
-- =====================================================

CREATE TABLE "UserProgress" (
    "ProgressId" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "UserId" UUID NOT NULL REFERENCES "Users"("UserId") ON DELETE CASCADE,
    "LevelId" UUID NOT NULL REFERENCES "Levels"("LevelId") ON DELETE CASCADE,
    "IsCompleted" BOOLEAN NOT NULL DEFAULT FALSE,
    "BestStepCount" INTEGER,
    "BestExecutionTime" INTEGER,
    "BestScore" INTEGER,
    "AttemptCount" INTEGER NOT NULL DEFAULT 0,
    "FirstAttemptAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    "FirstCompletedAt" TIMESTAMP,
    "LastAttemptAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    
    CONSTRAINT "UQ_UserProgress_UserLevel" UNIQUE ("UserId", "LevelId"),
    CONSTRAINT "CK_UserProgress_Attempts" CHECK ("AttemptCount" >= 0)
);

-- Indexes for UserProgress
CREATE INDEX "IX_UserProgress_UserId" ON "UserProgress"("UserId");
CREATE INDEX "IX_UserProgress_LevelId" ON "UserProgress"("LevelId");
CREATE INDEX "IX_UserProgress_IsCompleted" ON "UserProgress"("IsCompleted");
CREATE INDEX "IX_UserProgress_LastAttemptAt" ON "UserProgress"("LastAttemptAt" DESC);

-- =====================================================
-- LEVEL RATINGS
-- =====================================================

CREATE TABLE "LevelRatings" (
    "RatingId" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "LevelId" UUID NOT NULL REFERENCES "Levels"("LevelId") ON DELETE CASCADE,
    "UserId" UUID NOT NULL REFERENCES "Users"("UserId") ON DELETE CASCADE,
    "Rating" INTEGER NOT NULL CHECK ("Rating" BETWEEN 1 AND 5),
    "Review" TEXT,
    "IsEdited" BOOLEAN NOT NULL DEFAULT FALSE,
    "CreatedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    "UpdatedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    
    CONSTRAINT "UQ_LevelRatings_LevelUser" UNIQUE ("LevelId", "UserId")
);

-- Indexes for Level Ratings
CREATE INDEX "IX_LevelRatings_LevelId" ON "LevelRatings"("LevelId");
CREATE INDEX "IX_LevelRatings_UserId" ON "LevelRatings"("UserId");
CREATE INDEX "IX_LevelRatings_Rating" ON "LevelRatings"("Rating");
CREATE INDEX "IX_LevelRatings_CreatedAt" ON "LevelRatings"("CreatedAt" DESC);

-- =====================================================
-- ACHIEVEMENTS
-- =====================================================

CREATE TABLE "Achievements" (
    "AchievementId" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "Name" VARCHAR(100) UNIQUE NOT NULL,
    "Description" TEXT NOT NULL,
    "IconUrl" TEXT,
	"Category" VARCHAR(50) NOT NULL,         -- 'Completion', 'Efficiency', 'Community', 'Special'
	"RequirementType" VARCHAR(50) NOT NULL,   -- 'COMPLETE_N_LEVELS', 'BEST_SOLUTION', etc.
    "RequirementValue" INTEGER,
    "XPReward" INTEGER NOT NULL DEFAULT 0,
	"Rarity" VARCHAR(20) NOT NULL DEFAULT 'Common', -- 'Common', 'Rare', 'Epic', 'Legendary'
    "IsHidden" BOOLEAN NOT NULL DEFAULT FALSE,
    "CreatedAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes for Achievements
CREATE INDEX "IX_Achievements_Category" ON "Achievements"("Category");
CREATE INDEX "IX_Achievements_Rarity" ON "Achievements"("Rarity");

-- =====================================================
-- USER ACHIEVEMENTS
-- =====================================================

CREATE TABLE "UserAchievements" (
    "UserAchievementId" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "UserId" UUID NOT NULL REFERENCES "Users"("UserId") ON DELETE CASCADE,
    "AchievementId" UUID NOT NULL REFERENCES "Achievements"("AchievementId") ON DELETE CASCADE,
    "UnlockedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    "Progress" INTEGER,                       -- For progressive achievements
    
    CONSTRAINT "UQ_UserAchievements_UserAchievement" UNIQUE ("UserId", "AchievementId")
);

-- Indexes for User Achievements
CREATE INDEX "IX_UserAchievements_UserId" ON "UserAchievements"("UserId");
CREATE INDEX "IX_UserAchievements_AchievementId" ON "UserAchievements"("AchievementId");
CREATE INDEX "IX_UserAchievements_UnlockedAt" ON "UserAchievements"("UnlockedAt" DESC);

-- =====================================================
-- CHALLENGES
-- =====================================================

CREATE TABLE "Challenges" (
    "ChallengeId" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "Title" VARCHAR(100) NOT NULL,
    "Description" TEXT NOT NULL,
    "LevelId" UUID NOT NULL REFERENCES "Levels"("LevelId") ON DELETE CASCADE,
	"Type" VARCHAR(20) NOT NULL,              -- 'Daily', 'Weekly', 'Event', 'Tournament'
    "Requirements" JSONB NOT NULL,            -- JSON requirements (maxSteps, noLoops, etc.)
    "XPReward" INTEGER NOT NULL DEFAULT 0,
    "BadgeUrl" TEXT,
    "StartDate" TIMESTAMP NOT NULL,
    "EndDate" TIMESTAMP NOT NULL,
    "IsActive" BOOLEAN NOT NULL DEFAULT TRUE,
    "ParticipantCount" INTEGER NOT NULL DEFAULT 0,
    "CompletionCount" INTEGER NOT NULL DEFAULT 0,
    "CreatedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    
    CONSTRAINT "CK_Challenges_Dates" CHECK ("EndDate" > "StartDate"),
    CONSTRAINT "CK_Challenges_Counts" CHECK ("ParticipantCount" >= "CompletionCount")
);

-- Indexes for Challenges
CREATE INDEX "IX_Challenges_Type" ON "Challenges"("Type");
CREATE INDEX "IX_Challenges_IsActive" ON "Challenges"("IsActive") WHERE "IsActive" = TRUE;
CREATE INDEX "IX_Challenges_StartDate" ON "Challenges"("StartDate" DESC);
CREATE INDEX "IX_Challenges_EndDate" ON "Challenges"("EndDate");
CREATE INDEX "IX_Challenges_Requirements" ON "Challenges" USING GIN("Requirements");

-- =====================================================
-- CHALLENGE COMPLETIONS
-- =====================================================

CREATE TABLE "ChallengeCompletions" (
    "CompletionId" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "ChallengeId" UUID NOT NULL REFERENCES "Challenges"("ChallengeId") ON DELETE CASCADE,
    "UserId" UUID NOT NULL REFERENCES "Users"("UserId") ON DELETE CASCADE,
    "SolutionId" UUID NOT NULL REFERENCES "Solutions"("SolutionId") ON DELETE CASCADE,
    "Score" INTEGER NOT NULL,
    "Rank" INTEGER,
    "CompletedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    
    CONSTRAINT "UQ_ChallengeCompletions_ChallengeUser" UNIQUE ("ChallengeId", "UserId")
);

-- Indexes for Challenge Completions
CREATE INDEX "IX_ChallengeCompletions_ChallengeId_Score" ON "ChallengeCompletions"("ChallengeId", "Score" DESC);
CREATE INDEX "IX_ChallengeCompletions_UserId" ON "ChallengeCompletions"("UserId");
CREATE INDEX "IX_ChallengeCompletions_CompletedAt" ON "ChallengeCompletions"("CompletedAt" DESC);

-- =====================================================
-- COMMENTS
-- =====================================================

CREATE TABLE "Comments" (
    "CommentId" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "LevelId" UUID NOT NULL REFERENCES "Levels"("LevelId") ON DELETE CASCADE,
    "UserId" UUID NOT NULL REFERENCES "Users"("UserId") ON DELETE CASCADE,
    "ParentCommentId" UUID REFERENCES "Comments"("CommentId") ON DELETE CASCADE,
    "Content" TEXT NOT NULL,
    "IsEdited" BOOLEAN NOT NULL DEFAULT FALSE,
    "IsDeleted" BOOLEAN NOT NULL DEFAULT FALSE,
    "LikeCount" INTEGER NOT NULL DEFAULT 0,
    "CreatedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    "UpdatedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    
    CONSTRAINT "CK_Comments_LikeCount" CHECK ("LikeCount" >= 0)
);

-- Indexes for Comments
CREATE INDEX "IX_Comments_LevelId" ON "Comments"("LevelId");
CREATE INDEX "IX_Comments_UserId" ON "Comments"("UserId");
CREATE INDEX "IX_Comments_ParentCommentId" ON "Comments"("ParentCommentId");
CREATE INDEX "IX_Comments_CreatedAt" ON "Comments"("CreatedAt" DESC);
CREATE INDEX "IX_Comments_IsDeleted" ON "Comments"("IsDeleted") WHERE "IsDeleted" = FALSE;

-- =====================================================
-- COMMENT LIKES
-- =====================================================

CREATE TABLE "CommentLikes" (
    "LikeId" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "CommentId" UUID NOT NULL REFERENCES "Comments"("CommentId") ON DELETE CASCADE,
    "UserId" UUID NOT NULL REFERENCES "Users"("UserId") ON DELETE CASCADE,
    "CreatedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    
    CONSTRAINT "UQ_CommentLikes_CommentUser" UNIQUE ("CommentId", "UserId")
);

-- Indexes for Comment Likes
CREATE INDEX "IX_CommentLikes_CommentId" ON "CommentLikes"("CommentId");
CREATE INDEX "IX_CommentLikes_UserId" ON "CommentLikes"("UserId");

-- =====================================================
-- FOLLOWERS
-- =====================================================

CREATE TABLE "Followers" (
    "FollowerId" UUID NOT NULL REFERENCES "Users"("UserId") ON DELETE CASCADE,
    "FollowingId" UUID NOT NULL REFERENCES "Users"("UserId") ON DELETE CASCADE,
    "CreatedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    
    PRIMARY KEY ("FollowerId", "FollowingId"),
    CONSTRAINT "CK_Followers_NoSelfFollow" CHECK ("FollowerId" != "FollowingId")
);

-- Indexes for Followers
CREATE INDEX "IX_Followers_FollowerId" ON "Followers"("FollowerId");
CREATE INDEX "IX_Followers_FollowingId" ON "Followers"("FollowingId");

-- =====================================================
-- NOTIFICATIONS
-- =====================================================

CREATE TABLE "Notifications" (
    "NotificationId" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "UserId" UUID NOT NULL REFERENCES "Users"("UserId") ON DELETE CASCADE,
	"Type" VARCHAR(50) NOT NULL,              -- 'Achievement', 'Comment', 'Follow', 'Challenge', etc.
    "Title" VARCHAR(200) NOT NULL,
    "Message" TEXT NOT NULL,
    "LinkUrl" TEXT,
    "IsRead" BOOLEAN NOT NULL DEFAULT FALSE,
    "CreatedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    "ReadAt" TIMESTAMP
);

-- Indexes for Notifications
CREATE INDEX "IX_Notifications_UserId_IsRead" ON "Notifications"("UserId", "IsRead");
CREATE INDEX "IX_Notifications_CreatedAt" ON "Notifications"("CreatedAt" DESC);
CREATE INDEX "IX_Notifications_Type" ON "Notifications"("Type");

-- =====================================================
-- LEVEL REPORTS (Moderation)
-- =====================================================

CREATE TABLE "LevelReports" (
    "ReportId" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "LevelId" UUID NOT NULL REFERENCES "Levels"("LevelId") ON DELETE CASCADE,
    "ReporterId" UUID NOT NULL REFERENCES "Users"("UserId") ON DELETE CASCADE,
	"Reason" VARCHAR(50) NOT NULL,            -- 'Inappropriate', 'Unsolvable', 'Spam', 'Other'
    "Description" TEXT NOT NULL,
	"Status" VARCHAR(20) NOT NULL DEFAULT 'Pending', -- 'Pending', 'Reviewed', 'Resolved', 'Dismissed'
    "ReviewedBy" UUID REFERENCES "Users"("UserId"),
    "ReviewNotes" TEXT,
    "CreatedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    "ReviewedAt" TIMESTAMP
);

-- Indexes for Level Reports
CREATE INDEX "IX_LevelReports_LevelId" ON "LevelReports"("LevelId");
CREATE INDEX "IX_LevelReports_ReporterId" ON "LevelReports"("ReporterId");
CREATE INDEX "IX_LevelReports_Status" ON "LevelReports"("Status");
CREATE INDEX "IX_LevelReports_CreatedAt" ON "LevelReports"("CreatedAt" DESC);

-- =====================================================
-- LEVEL COLLECTIONS (Playlists)
-- =====================================================

CREATE TABLE "LevelCollections" (
    "CollectionId" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "CreatorId" UUID NOT NULL REFERENCES "Users"("UserId") ON DELETE CASCADE,
    "Title" VARCHAR(100) NOT NULL,
    "Description" TEXT,
    "IsPublic" BOOLEAN NOT NULL DEFAULT TRUE,
    "LevelCount" INTEGER NOT NULL DEFAULT 0,
    "FollowerCount" INTEGER NOT NULL DEFAULT 0,
    "CreatedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    "UpdatedAt" TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes for Level Collections
CREATE INDEX "IX_LevelCollections_CreatorId" ON "LevelCollections"("CreatorId");
CREATE INDEX "IX_LevelCollections_IsPublic" ON "LevelCollections"("IsPublic") WHERE "IsPublic" = TRUE;
CREATE INDEX "IX_LevelCollections_CreatedAt" ON "LevelCollections"("CreatedAt" DESC);

-- =====================================================
-- COLLECTION LEVELS (Junction Table)
-- =====================================================

CREATE TABLE "CollectionLevels" (
    "CollectionId" UUID NOT NULL REFERENCES "LevelCollections"("CollectionId") ON DELETE CASCADE,
    "LevelId" UUID NOT NULL REFERENCES "Levels"("LevelId") ON DELETE CASCADE,
    "OrderIndex" INTEGER NOT NULL,
    "AddedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    
    PRIMARY KEY ("CollectionId", "LevelId")
);

-- Indexes for Collection Levels
CREATE INDEX "IX_CollectionLevels_CollectionId_OrderIndex" ON "CollectionLevels"("CollectionId", "OrderIndex");

-- =====================================================
-- TRIGGERS FOR AUTOMATIC UPDATES
-- =====================================================

-- Update timestamp on row modification
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW."UpdatedAt" = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to tables with UpdatedAt column
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON "Users"
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_levels_updated_at BEFORE UPDATE ON "Levels"
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_leaderboards_updated_at BEFORE UPDATE ON "Leaderboards"
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_level_ratings_updated_at BEFORE UPDATE ON "LevelRatings"
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON "Comments"
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Update level average rating on new rating
CREATE OR REPLACE FUNCTION update_level_avg_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE "Levels"
    SET 
        "AverageRating" = (
            SELECT COALESCE(AVG("Rating"), 0)
            FROM "LevelRatings"
            WHERE "LevelId" = NEW."LevelId"
        ),
        "RatingCount" = (
            SELECT COUNT(*)
            FROM "LevelRatings"
            WHERE "LevelId" = NEW."LevelId"
        )
    WHERE "LevelId" = NEW."LevelId";
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_level_rating_after_insert AFTER INSERT ON "LevelRatings"
    FOR EACH ROW EXECUTE FUNCTION update_level_avg_rating();

CREATE TRIGGER update_level_rating_after_update AFTER UPDATE ON "LevelRatings"
    FOR EACH ROW EXECUTE FUNCTION update_level_avg_rating();

-- Update comment like count
CREATE OR REPLACE FUNCTION update_comment_like_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE "Comments"
    SET "LikeCount" = (
        SELECT COUNT(*)
        FROM "CommentLikes"
        WHERE "CommentId" = COALESCE(NEW."CommentId", OLD."CommentId")
    )
    WHERE "CommentId" = COALESCE(NEW."CommentId", OLD."CommentId");
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_comment_likes_after_insert AFTER INSERT ON "CommentLikes"
    FOR EACH ROW EXECUTE FUNCTION update_comment_like_count();

CREATE TRIGGER update_comment_likes_after_delete AFTER DELETE ON "CommentLikes"
    FOR EACH ROW EXECUTE FUNCTION update_comment_like_count();

-- =====================================================
-- INITIAL DATA SEEDING
-- =====================================================

-- Seed achievement templates
INSERT INTO "Achievements" ("AchievementId", "Name", "Description", "Category", "RequirementType", "RequirementValue", "XPReward", "Rarity") VALUES
	(uuid_generate_v4(), 'First Steps', 'Complete your first level', 'Completion', 'COMPLETE_N_LEVELS', 1, 10, 'Common'),
	(uuid_generate_v4(), 'Getting Started', 'Complete 5 levels', 'Completion', 'COMPLETE_N_LEVELS', 5, 50, 'Common'),
	(uuid_generate_v4(), 'Problem Solver', 'Complete 10 levels', 'Completion', 'COMPLETE_N_LEVELS', 10, 100, 'Rare'),
	(uuid_generate_v4(), 'Code Master', 'Complete 25 levels', 'Completion', 'COMPLETE_N_LEVELS', 25, 250, 'Epic'),
	(uuid_generate_v4(), 'Legend', 'Complete 50 levels', 'Completion', 'COMPLETE_N_LEVELS', 50, 500, 'Legendary'),
	(uuid_generate_v4(), 'Efficiency Expert', 'Achieve #1 ranking on any level', 'Efficiency', 'RANK_1_ANY_LEVEL', 1, 100, 'Rare'),
	(uuid_generate_v4(), 'Creator', 'Create your first custom level', 'Community', 'CREATE_N_LEVELS', 1, 20, 'Common'),
	(uuid_generate_v4(), 'Level Designer', 'Create 10 custom levels', 'Community', 'CREATE_N_LEVELS', 10, 200, 'Epic'),
	(uuid_generate_v4(), 'Community Star', 'Receive 100 likes on your levels', 'Community', 'RECEIVE_N_LIKES', 100, 300, 'Epic'),
	(uuid_generate_v4(), 'Daily Grind', 'Complete a daily challenge', 'Special', 'COMPLETE_DAILY_CHALLENGE', 1, 50, 'Rare');

-- =====================================================
-- VIEWS FOR COMMON QUERIES
-- =====================================================

-- Global Leaderboard (Top Players by XP)
CREATE OR REPLACE VIEW "GlobalLeaderboard" AS
SELECT 
    "UserId",
    "Username",
    "DisplayName",
    "AvatarUrl",
    "TotalXP",
    "PlayerLevel",
    ROW_NUMBER() OVER (ORDER BY "TotalXP" DESC, "CreatedAt" ASC) AS "Rank"
FROM "Users"
WHERE "IsBanned" = FALSE
ORDER BY "TotalXP" DESC
LIMIT 100;

-- Level Statistics View
CREATE OR REPLACE VIEW "LevelStatistics" AS
SELECT 
    l."LevelId",
    l."Title",
    l."CreatorId",
    u."Username" AS "CreatorUsername",
    l."Difficulty",
    l."PlayCount",
    l."CompletionCount",
    CASE 
        WHEN l."PlayCount" > 0 THEN (l."CompletionCount"::DECIMAL / l."PlayCount" * 100)
        ELSE 0
    END AS "CompletionRate",
    l."AverageRating",
    l."RatingCount",
    l."AverageSteps",
    l."AverageTime",
    l."CreatedAt"
FROM "Levels" l
JOIN "Users" u ON l."CreatorId" = u."UserId"
WHERE l."IsPublished" = TRUE;

-- User Statistics View
CREATE OR REPLACE VIEW "UserStatistics" AS
SELECT 
    u."UserId",
    u."Username",
    u."DisplayName",
    u."TotalXP",
    u."PlayerLevel",
    COUNT(DISTINCT up."LevelId") AS "LevelsCompleted",
    COUNT(DISTINCT l."LevelId") AS "LevelsCreated",
    COUNT(DISTINCT lb."LevelId") AS "Rank1Count",
    COUNT(DISTINCT ua."AchievementId") AS "AchievementsUnlocked",
    (SELECT COUNT(*) FROM "Followers" WHERE "FollowingId" = u."UserId") AS "FollowerCount",
    (SELECT COUNT(*) FROM "Followers" WHERE "FollowerId" = u."UserId") AS "FollowingCount"
FROM "Users" u
LEFT JOIN "UserProgress" up ON u."UserId" = up."UserId" AND up."IsCompleted" = TRUE
LEFT JOIN "Levels" l ON u."UserId" = l."CreatorId" AND l."IsPublished" = TRUE
LEFT JOIN "Leaderboards" lb ON u."UserId" = lb."UserId" AND lb."Rank" = 1
LEFT JOIN "UserAchievements" ua ON u."UserId" = ua."UserId"
GROUP BY u."UserId";

-- =====================================================
-- STORED PROCEDURES
-- =====================================================

-- Update Leaderboard Rankings
CREATE OR REPLACE FUNCTION update_leaderboard_rankings(p_level_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE "Leaderboards" l
    SET "Rank" = ranked."NewRank"
    FROM (
        SELECT 
            "LeaderboardId",
            ROW_NUMBER() OVER (ORDER BY "Score" DESC, "SubmittedAt" ASC) AS "NewRank"
        FROM "Leaderboards"
        WHERE "LevelId" = p_level_id
    ) ranked
    WHERE l."LeaderboardId" = ranked."LeaderboardId";
END;
$$ LANGUAGE plpgsql;

-- Calculate User Level from XP
CREATE OR REPLACE FUNCTION calculate_player_level(p_xp INTEGER)
RETURNS INTEGER AS $$
DECLARE
    v_level INTEGER;
BEGIN
    -- Simple formula: Level = sqrt(XP / 100)
    v_level := FLOOR(SQRT(p_xp::FLOAT / 100.0)) + 1;
    RETURN v_level;
END;
$$ LANGUAGE plpgsql;

-- Update User Level (trigger on XP change)
CREATE OR REPLACE FUNCTION update_user_level()
RETURNS TRIGGER AS $$
BEGIN
    NEW."PlayerLevel" := calculate_player_level(NEW."TotalXP");
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_level_on_xp_change BEFORE UPDATE ON "Users"
    FOR EACH ROW 
    WHEN (OLD."TotalXP" IS DISTINCT FROM NEW."TotalXP")
    EXECUTE FUNCTION update_user_level();

-- =====================================================
-- PERFORMANCE OPTIMIZATION
-- =====================================================

-- Analyze tables for query optimization
ANALYZE "Users";
ANALYZE "Levels";
ANALYZE "Solutions";
ANALYZE "Leaderboards";
ANALYZE "UserProgress";

-- Set table statistics targets for better query planning
ALTER TABLE "Levels" ALTER COLUMN "Tags" SET STATISTICS 1000;
ALTER TABLE "Challenges" ALTER COLUMN "Requirements" SET STATISTICS 1000;

COMMENT ON DATABASE postgres IS 'LediBug Game Backend Database';
```

This schema provides a complete, production-ready database for LediBug with:
- ✅ All core tables with proper constraints
- ✅ Comprehensive indexing for performance
- ✅ Triggers for automatic updates
- ✅ Views for common queries
- ✅ Stored procedures for complex operations
- ✅ Full-text search capability
- ✅ Achievement system
- ✅ Challenge system
- ✅ Social features (followers, comments, likes)
- ✅ Moderation system

---

Would you like me to continue with the C# Entity Models and API implementation? The file is getting large, so I can either:

1. **Continue in this file** with all remaining phases detailed
2. **Create separate files** for each major section
3. **Provide a summary** of remaining phases with links to detailed implementations

Which would you prefer?
### 🏗️ 1.6 Complete C# Entity Models

**Location**: `LediBug.Core/Entities/`

```csharp
// User.cs - Complete User Entity with Relationships
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace LediBug.Core.Entities
{
    public class User : BaseEntity
    {
        [Required, MaxLength(50)]
        public string Username { get; set; } = string.Empty;
        
        [Required, EmailAddress, MaxLength(100)]
        public string Email { get; set; } = string.Empty;
        
        [Required]
        public string PasswordHash { get; set; } = string.Empty;
        
        [MaxLength(500)]
        public string? Bio { get; set; }
        
        [Url, MaxLength(200)]
        public string? Avatar { get; set; }
        
        [MaxLength(100)]
        public string? Country { get; set; }
        
        public DateTime? BirthDate { get; set; }
        
        public bool EmailConfirmed { get; set; }
        
        public bool IsPremium { get; set; }
        
        public DateTime? PremiumExpiresAt { get; set; }
        
        public int XP { get; set; } = 0;
        
        public int Level { get; set; } = 1;
        
        public int CoinsEarned { get; set; } = 0;
        
        public int TotalSolutions { get; set; } = 0;
        
        public int SolutionsEasy { get; set; } = 0;
        
        public int SolutionsMedium { get; set; } = 0;
        
        public int SolutionsHard { get; set; } = 0;
        
        public DateTime? LastLoginAt { get; set; }
        
        public int LoginStreak { get; set; } = 0;
        
        public string[] Badges { get; set; } = Array.Empty<string>();
        
        public Dictionary<string, object>? Settings { get; set; }
        
        // Navigation Properties
        public virtual ICollection<Level> CreatedLevels { get; set; } = new List<Level>();
        public virtual ICollection<Solution> Solutions { get; set; } = new List<Solution>();
        public virtual ICollection<UserAchievement> Achievements { get; set; } = new List<UserAchievement>();
        public virtual ICollection<Comment> Comments { get; set; } = new List<Comment>();
        public virtual ICollection<LevelRating> Ratings { get; set; } = new List<LevelRating>();
        public virtual ICollection<Follow> Followers { get; set; } = new List<Follow>();
        public virtual ICollection<Follow> Following { get; set; } = new List<Follow>();
        public virtual ICollection<Notification> Notifications { get; set; } = new List<Notification>();
        public virtual ICollection<ChallengeParticipant> Challenges { get; set; } = new List<ChallengeParticipant>();
        
        // Computed Properties
        public int GetRank()
        {
            return (Level - 1) * 1000 + XP;
        }
        
        public string GetTitle()
        {
            return Level switch
            {
                >= 50 => "🏆 Grand Master",
                >= 40 => "💎 Legend",
                >= 30 => "⭐ Master",
                >= 20 => "🥇 Expert",
                >= 10 => "🥈 Advanced",
                >= 5 => "🥉 Intermediate",
                _ => "🌱 Beginner"
            };
        }
    }
    
    public abstract class BaseEntity
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}
```

```csharp
// Level.cs - Complete Level Entity
namespace LediBug.Core.Entities
{
    public class Level : BaseEntity
    {
        [Required, MaxLength(100)]
        public string Title { get; set; } = string.Empty;
        
        [Required, MaxLength(1000)]
        public string Description { get; set; } = string.Empty;
        
        [Required]
        public string GridData { get; set; } = string.Empty; // JSON
        
        public int GridWidth { get; set; }
        
        public int GridHeight { get; set; }
        
        [MaxLength(5000)]
        public string? StarterCode { get; set; }
        
        [MaxLength(5000)]
        public string? SolutionCode { get; set; }
        
        public LevelDifficulty Difficulty { get; set; }
        
        public LevelType Type { get; set; }
        
        public bool IsPublished { get; set; }
        
        public bool IsFeatured { get; set; }
        
        public bool IsOfficial { get; set; }
        
        public int PlayCount { get; set; } = 0;
        
        public int CompletionCount { get; set; } = 0;
        
        public int LikeCount { get; set; } = 0;
        
        public double AverageRating { get; set; } = 0.0;
        
        public int RatingCount { get; set; } = 0;
        
        public int OptimalMoves { get; set; }
        
        public int OptimalLines { get; set; }
        
        public string[] Tags { get; set; } = Array.Empty<string>();
        
        public string[] Concepts { get; set; } = Array.Empty<string>();
        
        public int XPReward { get; set; } = 10;
        
        public int CoinsReward { get; set; } = 5;
        
        // Foreign Keys
        public Guid CreatorId { get; set; }
        
        // Navigation Properties
        public virtual User Creator { get; set; } = null!;
        public virtual ICollection<Solution> Solutions { get; set; } = new List<Solution>();
        public virtual ICollection<Comment> Comments { get; set; } = new List<Comment>();
        public virtual ICollection<LevelRating> Ratings { get; set; } = new List<LevelRating>();
        public virtual ICollection<Challenge> Challenges { get; set; } = new List<Challenge>();
    }
    
    public enum LevelDifficulty
    {
        Easy = 1,
        Medium = 2,
        Hard = 3,
        Expert = 4
    }
    
    public enum LevelType
    {
        Tutorial,
        Practice,
        Challenge,
        Community,
        Daily,
        Contest
    }
}
```

```csharp
// Solution.cs - Complete Solution Entity
namespace LediBug.Core.Entities
{
    public class Solution : BaseEntity
    {
        public Guid UserId { get; set; }
        public Guid LevelId { get; set; }
        
        [Required, MaxLength(10000)]
        public string Code { get; set; } = string.Empty;
        
        public bool IsCompleted { get; set; }
        
        public int Moves { get; set; }
        
        public int LinesOfCode { get; set; }
        
        public int ExecutionTimeMs { get; set; }
        
        public int StarsEarned { get; set; } // 1-3 stars based on efficiency
        
        public bool IsPublic { get; set; }
        
        public int LikeCount { get; set; } = 0;
        
        [MaxLength(500)]
        public string? Notes { get; set; }
        
        // Leaderboard rankings
        public int? MoveRank { get; set; }
        public int? LineRank { get; set; }
        
        // Navigation Properties
        public virtual User User { get; set; } = null!;
        public virtual Level Level { get; set; } = null!;
        public virtual ICollection<Comment> Comments { get; set; } = new List<Comment>();
    }
}
```


### 🎯 1.7 Complete API Controllers with Full Implementation

**Location**: `LediBug.API/Controllers/`

```csharp
// UserController.cs - Complete User Management API
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using LediBug.Application.DTOs;
using LediBug.Application.Services;

namespace LediBug.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly IAuthService _authService;
        
        public UserController(IUserService userService, IAuthService authService)
        {
            _userService = userService;
            _authService = authService;
        }
        
        // POST /api/user/register
        [HttpPost("register")]
        public async Task<ActionResult<AuthResponse>> Register([FromBody] RegisterRequest request)
        {
            try
            {
                var result = await _authService.RegisterAsync(request.Username, request.Email, request.Password);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }
        
        // POST /api/user/login
        [HttpPost("login")]
        public async Task<ActionResult<AuthResponse>> Login([FromBody] LoginRequest request)
        {
            try
            {
                var result = await _authService.LoginAsync(request.UsernameOrEmail, request.Password);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return Unauthorized(new { error = ex.Message });
            }
        }
        
        // GET /api/user/me
        [Authorize]
        [HttpGet("me")]
        public async Task<ActionResult<UserDTO>> GetCurrentUser()
        {
            var userId = _authService.GetCurrentUserId(User);
            var user = await _userService.GetByIdAsync(userId);
            return Ok(user);
        }
        
        // GET /api/user/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<UserPublicDTO>> GetUser(Guid id)
        {
            var user = await _userService.GetPublicProfileAsync(id);
            if (user == null) return NotFound();
            return Ok(user);
        }
        
        // PUT /api/user/me
        [Authorize]
        [HttpPut("me")]
        public async Task<ActionResult<UserDTO>> UpdateProfile([FromBody] UpdateProfileRequest request)
        {
            var userId = _authService.GetCurrentUserId(User);
            var updated = await _userService.UpdateProfileAsync(userId, request);
            return Ok(updated);
        }
        
        // GET /api/user/{id}/stats
        [HttpGet("{id}/stats")]
        public async Task<ActionResult<UserStatsDTO>> GetUserStats(Guid id)
        {
            var stats = await _userService.GetStatsAsync(id);
            return Ok(stats);
        }
        
        // GET /api/user/leaderboard
        [HttpGet("leaderboard")]
        public async Task<ActionResult<List<LeaderboardEntryDTO>>> GetLeaderboard(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 50)
        {
            var leaderboard = await _userService.GetLeaderboardAsync(page, pageSize);
            return Ok(leaderboard);
        }
    }
}
```

```csharp
// LevelController.cs - Complete Level Management API
namespace LediBug.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class LevelController : ControllerBase
    {
        private readonly ILevelService _levelService;
        private readonly IAuthService _authService;
        
        public LevelController(ILevelService levelService, IAuthService authService)
        {
            _levelService = levelService;
            _authService = authService;
        }
        
        // GET /api/level - Get all levels with filters
        [HttpGet]
        public async Task<ActionResult<PagedResult<LevelPreviewDTO>>> GetLevels(
            [FromQuery] string? search = null,
            [FromQuery] LevelDifficulty? difficulty = null,
            [FromQuery] LevelType? type = null,
            [FromQuery] string? tag = null,
            [FromQuery] string? sortBy = "popular", // popular, newest, hardest, easiest
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            var levels = await _levelService.SearchLevelsAsync(
                search, difficulty, type, tag, sortBy, page, pageSize);
            return Ok(levels);
        }
        
        // GET /api/level/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<LevelDetailDTO>> GetLevel(Guid id)
        {
            var level = await _levelService.GetByIdAsync(id);
            if (level == null) return NotFound();
            
            // Increment play count
            await _levelService.IncrementPlayCountAsync(id);
            
            return Ok(level);
        }
        
        // POST /api/level - Create new level
        [Authorize]
        [HttpPost]
        public async Task<ActionResult<LevelDetailDTO>> CreateLevel([FromBody] CreateLevelRequest request)
        {
            var userId = _authService.GetCurrentUserId(User);
            var level = await _levelService.CreateAsync(userId, request);
            return CreatedAtAction(nameof(GetLevel), new { id = level.Id }, level);
        }
        
        // PUT /api/level/{id}
        [Authorize]
        [HttpPut("{id}")]
        public async Task<ActionResult<LevelDetailDTO>> UpdateLevel(Guid id, [FromBody] UpdateLevelRequest request)
        {
            var userId = _authService.GetCurrentUserId(User);
            var level = await _levelService.UpdateAsync(id, userId, request);
            if (level == null) return NotFound();
            return Ok(level);
        }
        
        // DELETE /api/level/{id}
        [Authorize]
        [HttpDelete("{id}")]
        public async Task<ActionResult> DeleteLevel(Guid id)
        {
            var userId = _authService.GetCurrentUserId(User);
            var success = await _levelService.DeleteAsync(id, userId);
            if (!success) return NotFound();
            return NoContent();
        }
        
        // POST /api/level/{id}/like
        [Authorize]
        [HttpPost("{id}/like")]
        public async Task<ActionResult> LikeLevel(Guid id)
        {
            var userId = _authService.GetCurrentUserId(User);
            await _levelService.ToggleLikeAsync(id, userId);
            return Ok();
        }
        
        // POST /api/level/{id}/rate
        [Authorize]
        [HttpPost("{id}/rate")]
        public async Task<ActionResult> RateLevel(Guid id, [FromBody] RateLevelRequest request)
        {
            var userId = _authService.GetCurrentUserId(User);
            await _levelService.RateLevelAsync(id, userId, request.Rating);
            return Ok();
        }
        
        // GET /api/level/{id}/solutions
        [HttpGet("{id}/solutions")]
        public async Task<ActionResult<List<SolutionPreviewDTO>>> GetLevelSolutions(
            Guid id,
            [FromQuery] string? sortBy = "moves", // moves, lines, newest, popular
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            var solutions = await _levelService.GetSolutionsAsync(id, sortBy, page, pageSize);
            return Ok(solutions);
        }
    }
}
```

```csharp
// SolutionController.cs - Complete Solution Submission API
namespace LediBug.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class SolutionController : ControllerBase
    {
        private readonly ISolutionService _solutionService;
        private readonly IAuthService _authService;
        
        public SolutionController(ISolutionService solutionService, IAuthService authService)
        {
            _solutionService = solutionService;
            _authService = authService;
        }
        
        // POST /api/solution - Submit solution
        [HttpPost]
        public async Task<ActionResult<SolutionResultDTO>> SubmitSolution([FromBody] SubmitSolutionRequest request)
        {
            var userId = _authService.GetCurrentUserId(User);
            var result = await _solutionService.SubmitAsync(userId, request);
            return Ok(result);
        }
        
        // GET /api/solution/my - Get my solutions
        [HttpGet("my")]
        public async Task<ActionResult<List<SolutionPreviewDTO>>> GetMySolutions(
            [FromQuery] Guid? levelId = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            var userId = _authService.GetCurrentUserId(User);
            var solutions = await _solutionService.GetUserSolutionsAsync(userId, levelId, page, pageSize);
            return Ok(solutions);
        }
        
        // GET /api/solution/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<SolutionDetailDTO>> GetSolution(Guid id)
        {
            var solution = await _solutionService.GetByIdAsync(id);
            if (solution == null) return NotFound();
            
            // Check if solution is public or belongs to current user
            var userId = _authService.GetCurrentUserId(User);
            if (!solution.IsPublic && solution.UserId != userId)
            {
                return Forbid();
            }
            
            return Ok(solution);
        }
        
        // PUT /api/solution/{id}/visibility
        [HttpPut("{id}/visibility")]
        public async Task<ActionResult> UpdateVisibility(Guid id, [FromBody] UpdateVisibilityRequest request)
        {
            var userId = _authService.GetCurrentUserId(User);
            var success = await _solutionService.UpdateVisibilityAsync(id, userId, request.IsPublic);
            if (!success) return NotFound();
            return Ok();
        }
        
        // POST /api/solution/{id}/like
        [HttpPost("{id}/like")]
        public async Task<ActionResult> LikeSolution(Guid id)
        {
            var userId = _authService.GetCurrentUserId(User);
            await _solutionService.ToggleLikeAsync(id, userId);
            return Ok();
        }
    }
}
```


### 🔌 1.8 Godot HTTP Client Integration

**Location**: `scripts/api_client.gd` (NEW FILE)

```gdscript
# api_client.gd - Complete HTTP Client for .NET Backend
extends Node

const BASE_URL = "https://api.ledibug.com/api"  # Production
# const BASE_URL = "http://localhost:5000/api"  # Development

var http_client = HTTPRequest.new()
var auth_token: String = ""
var current_user: Dictionary = {}

signal login_success(user_data)
signal login_failed(error)
signal level_loaded(level_data)
signal solution_submitted(result)
signal leaderboard_loaded(entries)

func _ready():
    add_child(http_client)
    http_client.request_completed.connect(_on_request_completed)
    _load_saved_token()

# ============== AUTHENTICATION ==============

func register(username: String, email: String, password: String):
    var body = JSON.stringify({
        "username": username,
        "email": email,
        "password": password
    })
    return _post("/user/register", body, false)

func login(username_or_email: String, password: String):
    var body = JSON.stringify({
        "usernameOrEmail": username_or_email,
        "password": password
    })
    var result = await _post("/user/login", body, false)
    if result.success:
        auth_token = result.data.token
        current_user = result.data.user
        _save_token(auth_token)
        login_success.emit(current_user)
    else:
        login_failed.emit(result.error)
    return result

func logout():
    auth_token = ""
    current_user = {}
    _delete_saved_token()

func get_current_user():
    return await _get("/user/me")

# ============== LEVELS ==============

func get_levels(filters: Dictionary = {}):
    var query = _build_query_string(filters)
    return await _get("/level" + query)

func get_level(level_id: String):
    var result = await _get("/level/" + level_id)
    if result.success:
        level_loaded.emit(result.data)
    return result

func create_level(level_data: Dictionary):
    return await _post("/level", JSON.stringify(level_data))

func update_level(level_id: String, level_data: Dictionary):
    return await _put("/level/" + level_id, JSON.stringify(level_data))

func delete_level(level_id: String):
    return await _delete("/level/" + level_id)

func like_level(level_id: String):
    return await _post("/level/" + level_id + "/like", "{}")

func rate_level(level_id: String, rating: int):
    var body = JSON.stringify({"rating": rating})
    return await _post("/level/" + level_id + "/rate", body)

# ============== SOLUTIONS ==============

func submit_solution(level_id: String, code: String, moves: int, lines: int, time_ms: int, completed: bool):
    var body = JSON.stringify({
        "levelId": level_id,
        "code": code,
        "moves": moves,
        "linesOfCode": lines,
        "executionTimeMs": time_ms,
        "isCompleted": completed
    })
    var result = await _post("/solution", body)
    if result.success:
        solution_submitted.emit(result.data)
    return result

func get_my_solutions(level_id: String = ""):
    var query = "?levelId=" + level_id if level_id != "" else ""
    return await _get("/solution/my" + query)

func get_solution(solution_id: String):
    return await _get("/solution/" + solution_id)

func get_level_solutions(level_id: String, sort_by: String = "moves"):
    return await _get("/level/" + level_id + "/solutions?sortBy=" + sort_by)

# ============== LEADERBOARD ==============

func get_leaderboard(page: int = 1, page_size: int = 50):
    var result = await _get("/user/leaderboard?page=" + str(page) + "&pageSize=" + str(page_size))
    if result.success:
        leaderboard_loaded.emit(result.data)
    return result

func get_user_stats(user_id: String):
    return await _get("/user/" + user_id + "/stats")

func get_user_profile(user_id: String):
    return await _get("/user/" + user_id)

# ============== HELPER METHODS ==============

func _get(endpoint: String):
    var url = BASE_URL + endpoint
    var headers = _get_headers()
    http_client.request(url, headers, HTTPClient.METHOD_GET)
    return await http_client.request_completed

func _post(endpoint: String, body: String, use_auth: bool = true):
    var url = BASE_URL + endpoint
    var headers = _get_headers(use_auth)
    http_client.request(url, headers, HTTPClient.METHOD_POST, body)
    return await http_client.request_completed

func _put(endpoint: String, body: String):
    var url = BASE_URL + endpoint
    var headers = _get_headers()
    http_client.request(url, headers, HTTPClient.METHOD_PUT, body)
    return await http_client.request_completed

func _delete(endpoint: String):
    var url = BASE_URL + endpoint
    var headers = _get_headers()
    http_client.request(url, headers, HTTPClient.METHOD_DELETE)
    return await http_client.request_completed

func _get_headers(use_auth: bool = true) -> PackedStringArray:
    var headers = PackedStringArray([
        "Content-Type: application/json",
        "Accept: application/json"
    ])
    if use_auth and auth_token != "":
        headers.append("Authorization: Bearer " + auth_token)
    return headers

func _build_query_string(params: Dictionary) -> String:
    if params.is_empty():
        return ""
    var query = "?"
    for key in params:
        query += str(key) + "=" + str(params[key]) + "&"
    return query.substr(0, query.length() - 1)

func _on_request_completed(result_code, response_code, headers, body):
    var response = {
        "success": response_code >= 200 and response_code < 300,
        "status_code": response_code,
        "data": null,
        "error": null
    }
    
    if body.size() > 0:
        var json = JSON.parse_string(body.get_string_from_utf8())
        if response.success:
            response.data = json
        else:
            response.error = json.get("error", "Unknown error")
    
    return response

func _save_token(token: String):
    if OS.has_feature("web"):
        # Use localStorage on web
		JavaScriptBridge.eval("localStorage.setItem('ledibug_token', '" + token + "')")
    else:
        # Use config file on desktop
        var config = ConfigFile.new()
        config.set_value("auth", "token", token)
        config.save("user://auth.cfg")

func _load_saved_token():
    if OS.has_feature("web"):
		var token = JavaScriptBridge.eval("localStorage.getItem('ledibug_token')")
        if token != null:
            auth_token = str(token)
    else:
        var config = ConfigFile.new()
        if config.load("user://auth.cfg") == OK:
            auth_token = config.get_value("auth", "token", "")

func _delete_saved_token():
    if OS.has_feature("web"):
		JavaScriptBridge.eval("localStorage.removeItem('ledibug_token')")
    else:
        DirAccess.remove_absolute("user://auth.cfg")

func is_logged_in() -> bool:
    return auth_token != "" and not current_user.is_empty()
```

**Usage in Main Game (main.gd)**:

```gdscript
# main.gd - Integration Example
extends Control

@onready var api = $APIClient  # Add APIClient node to scene

func _ready():
    # Connect signals
    api.login_success.connect(_on_login_success)
    api.level_loaded.connect(_on_level_loaded)
    api.solution_submitted.connect(_on_solution_submitted)
    
    # Check if already logged in
    if api.is_logged_in():
        var user = await api.get_current_user()
        if user.success:
            _show_user_profile(user.data)

func _on_login_button_pressed():
    var username = $UsernameInput.text
    var password = $PasswordInput.text
    await api.login(username, password)

func _on_login_success(user_data):
    print("Welcome ", user_data.username)
    $LoginPanel.hide()
    $MainMenu.show()

func _on_play_level_button_pressed(level_id: String):
    var level_result = await api.get_level(level_id)
    if level_result.success:
        _load_level(level_result.data)

func _on_level_completed():
    # Submit solution when player completes level
    var code = code_editor.text
    var moves = player.total_moves
    var lines = code.split("\n").size()
    var time_ms = execution_time_ms
    
    await api.submit_solution(
        current_level_id,
        code,
        moves,
        lines,
        time_ms,
        true  # completed
    )

func _on_solution_submitted(result_data):
    print("Solution submitted! Stars: ", result_data.starsEarned)
    print("XP earned: ", result_data.xpEarned)
    $ResultsPanel.show_results(result_data)

func _on_leaderboard_button_pressed():
    var leaderboard = await api.get_leaderboard()
    if leaderboard.success:
        _display_leaderboard(leaderboard.data)
```



---

## 🎮 PHASE 2: Core Gameplay Enhancements

**Duration**: 4-6 weeks | **Priority**: High | **Team**: 2 developers

### 🎯 Goals

Make LediBug's language more powerful and gameplay more engaging with:
- Advanced programming features (arrays, nested loops, math library)
- New grid cell types for complex puzzles
- Improved tutorial system with progressive difficulty
- Achievement system for motivation

---

### 2.1 Enhanced Programming Language Features

#### Arrays & Lists

```gdscript
# lexer.gd - Add array token types
enum TokenType {
	# ... existing tokens
	LEFT_BRACKET,    # [
	RIGHT_BRACKET,   # ]
	COMMA,           # ,
}

# New Array Operations
var items = [1, 2, 3]
var grid = [[0,0,0], [0,1,0], [0,0,0]]

items.append(4)              # Add to end
items.insert(0, 99)          # Insert at index
var first = items[0]         # Access by index
var length = items.size()    # Get length
items.remove_at(1)           # Remove by index

# Example: Collect multiple items
var collected = []
while(frontIsClear()) {
	if(onItem()) {
		collected.append(getItemType())
	}
	move()
}
print("Collected: " + str(collected.size()) + " items")
```

#### Math Library

```gdscript
# interpreter.gd - Add math functions
func _register_builtin_functions():
	builtin_functions["abs"] = func(x): return abs(x)
	builtin_functions["min"] = func(a, b): return min(a, b)
	builtin_functions["max"] = func(a, b): return max(a, b)
	builtin_functions["floor"] = func(x): return floor(x)
	builtin_functions["ceil"] = func(x): return ceil(x)
	builtin_functions["sqrt"] = func(x): return sqrt(x)
	builtin_functions["pow"] = func(x, y): return pow(x, y)
	builtin_functions["random"] = func(): return randf()
	builtin_functions["randomInt"] = func(min_val, max_val): return randi_range(min_val, max_val)

# Usage in player code
var distance = sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2))
var randomTurn = randomInt(1, 4)
if(randomTurn == 1) turnLeft()
else if(randomTurn == 2) turnRight()
```

#### String Manipulation

```gdscript
# Built-in string functions
var text = "LediBug"
var length = text.length()           # 7
var upper = text.toUpper()          # "LEDIBUG"
var lower = text.toLower()          # "ledibug"
var sub = text.substr(0, 4)         # "Ledi"
var contains = text.contains("Bug") # true
var split = "a,b,c".split(",")      # ["a","b","c"]
var joined = ["a","b"].join("-")    # "a-b"
```

#### Try-Catch Error Handling

```gdscript
# lexer.gd - Add try/catch keywords
const KEYWORDS = {
	# ... existing
	"try": TokenType.TRY,
	"catch": TokenType.CATCH,
	"throw": TokenType.THROW,
}

# Usage
try {
	move()
	if(!frontIsClear()) {
		throw("Path blocked!")
	}
} catch(error) {
	print("Error: " + error)
	turnRight()  # Try different direction
}
```

---

### 2.2 New Grid Cell Types & Mechanics

#### Cell Type Definitions

```gdscript
# grid_cell.gd (NEW FILE)
class_name GridCell
extends Node2D

enum CellType {
	EMPTY,
	WALL,
	GOAL,
	START,
	WATER,      # Can't cross unless on bridge
    LAVA,       # Instant death
    ICE,        # Slide until wall/edge
    TELEPORTER, # Transport to paired teleporter
    SWITCH,     # Toggle doors/walls
    DOOR,       # Opens with switch or key
    KEY,        # Pickup to unlock doors
    SPRING,     # Jump 2 cells forward
    ARROW,      # Forces direction change
    TRAP,       # Triggers after N steps
    CHECKPOINT, # Save progress point
    COIN,       # Collect for points
    GEM,        # Rare valuable item
}

var type: CellType = CellType.EMPTY
var properties: Dictionary = {}  # Type-specific data
var sprite: Sprite2D
var animation: AnimationPlayer

func _ready():
    _setup_visuals()
    _setup_behavior()

func _setup_visuals():
    sprite = Sprite2D.new()
    add_child(sprite)
    
    match type:
        CellType.WATER:
            sprite.texture = preload("res://assets/cells/water.png")
            sprite.modulate = Color(0.3, 0.5, 1.0)
        CellType.LAVA:
            sprite.texture = preload("res://assets/cells/lava.png")
            sprite.modulate = Color(1.0, 0.3, 0.0)
            _add_particle_effect("lava_bubbles")
        CellType.ICE:
            sprite.texture = preload("res://assets/cells/ice.png")
            sprite.modulate = Color(0.7, 0.9, 1.0)
        CellType.TELEPORTER:
            sprite.texture = preload("res://assets/cells/teleporter.png")
            _add_animated_glow()
        # ... etc

func on_player_enter(player: Player):
    match type:
        CellType.WATER:
            if not player.has_item("bridge"):
                player.die("Fell in water!")
                return false
        CellType.LAVA:
            player.die("Burned by lava!")
            return false
        CellType.ICE:
            _slide_player(player)
        CellType.TELEPORTER:
            _teleport_player(player)
        CellType.KEY:
            player.add_item(properties.get("key_id", "default"))
            queue_free()  # Remove key from grid
    return true

func _slide_player(player: Player):
    # Keep moving in same direction until wall/edge
    while player.can_move_forward():
        await player.move()
        var current_cell = get_cell_at_player()
        if current_cell.type != CellType.ICE:
            break

func _teleport_player(player: Player):
    var target_id = properties.get("target_teleporter_id")
    var target = get_teleporter_by_id(target_id)
    if target:
        player.position = target.position
        target._play_teleport_effect()
```

#### New Language Functions for Cell Types

```gdscript
# player.gd - Add cell interaction functions
func onWater() -> bool:
    return _get_cell_at_position(grid_position).type == GridCell.CellType.WATER

func onIce() -> bool:
    return _get_cell_at_position(grid_position).type == GridCell.CellType.ICE

func onSwitch() -> bool:
    return _get_cell_at_position(grid_position).type == GridCell.CellType.SWITCH

func getCellType() -> String:
    var cell = _get_cell_at_position(grid_position)
    return GridCell.CellType.keys()[cell.type]

func hasItem(item_name: String) -> bool:
    return item_name in inventory

func useItem(item_name: String) -> bool:
    if item_name in inventory:
        inventory.erase(item_name)
        emit_signal("item_used", item_name)
        return true
    return false

func activateSwitch():
    var cell = _get_cell_at_position(grid_position)
    if cell.type == GridCell.CellType.SWITCH:
        cell.activate()
        emit_signal("switch_activated", cell.properties.get("id"))
```

#### Example Puzzle: Water Crossing

```gdscript
# Level with water cells - player must find bridge
function solvePuzzle() {
    // Move to bridge pickup
    repeat(3) {
        move()
    }
    turnRight()
    move()
    // Now have bridge item
    
    // Return to water
    turnLeft()
    move()
    turnLeft()
    repeat(3) {
        move()
    }
    
    // Can now cross water
    if(onWater() && hasItem("bridge")) {
        move()  // Successfully crosses
    }
}
```

---

### 2.3 Enhanced Tutorial System

#### Progressive Tutorial Levels

```gdscript
# tutorial_manager.gd (NEW FILE)
extends Node

const TUTORIALS = [
    {
        "id": "movement_basics",
        "title": "Movement Basics",
        "lessons": [
            {
                "title": "Your First Step",
                "description": "Call move() to move forward one cell",
                "starter_code": "// Try moving forward\n",
                "hint": "Type: move()",
                "solution": "move()",
                "grid": "3x3_simple",
            },
            {
                "title": "Multiple Moves",
                "description": "Move 3 times to reach the goal",
                "starter_code": "// Move 3 times\n",
                "hint": "Call move() three times",
                "solution": "move()\nmove()\nmove()",
            },
            {
                "title": "Loops",
                "description": "Use repeat() to move efficiently",
                "starter_code": "// Use repeat to move 5 times\n",
                "hint": "repeat(5) { move() }",
                "solution": "repeat(5) {\n    move()\n}",
            },
        ]
    },
    {
        "id": "turning",
        "title": "Turning & Navigation",
        "lessons": [...],
    },
    {
        "id": "sensors",
        "title": "Using Sensors",
        "lessons": [...],
    },
    {
        "id": "conditions",
        "title": "If Statements",
        "lessons": [...],
    },
    {
        "id": "loops_advanced",
        "title": "While Loops",
        "lessons": [...],
    },
    {
        "id": "functions",
        "title": "Creating Functions",
        "lessons": [...],
    },
]

func get_tutorial(id: String) -> Dictionary:
    for tutorial in TUTORIALS:
        if tutorial.id == id:
            return tutorial
    return {}

func get_next_tutorial(completed_ids: Array) -> Dictionary:
    for tutorial in TUTORIALS:
        if tutorial.id not in completed_ids:
            return tutorial
    return {}  # All complete

func check_solution(user_code: String, expected_solution: String) -> bool:
    # Can do fuzzy matching or exact matching
    return user_code.strip_edges() == expected_solution.strip_edges()
```

#### Hint System

```gdscript
# hint_system.gd
extends Node

var hints_shown: Array = []
var hint_cooldown: float = 30.0  # Show hint after 30s of inactivity

func show_hint_if_stuck(level_id: String, time_stuck: float):
    if time_stuck < hint_cooldown:
        return
    
    if level_id in hints_shown:
        return  # Already showed hint for this level
    
    var hint = get_hint_for_level(level_id)
    if hint:
        _display_hint_popup(hint)
        hints_shown.append(level_id)

func get_hint_for_level(level_id: String) -> String:
    var hints = {
        "level_1": "Try using move() to move forward",
        "level_2": "Remember to turn before moving",
        "level_3": "Use frontIsClear() to check if you can move",
        "level_4": "A while loop can repeat until a condition is met",
        "level_5": "You can call turnRight() or turnLeft() to change direction",
    }
    return hints.get(level_id, "")

func _display_hint_popup(hint_text: String):
    var popup = AcceptDialog.new()
    popup.dialog_text = "💡 Hint: " + hint_text
    popup.title = "Need Help?"
    add_child(popup)
    popup.popup_centered()
```

---

### 2.4 Achievement System

#### Achievement Definitions

```gdscript
# achievement_system.gd
extends Node

signal achievement_unlocked(achievement)

const ACHIEVEMENTS = {
    "first_steps": {
        "title": "First Steps",
        "description": "Complete your first level",
        "icon": "res://assets/achievements/first_steps.png",
        "requirement": {"type": "levels_completed", "count": 1},
        "xp_reward": 10,
    },
    "speed_demon": {
        "title": "Speed Demon",
        "description": "Complete a level in under 5 seconds",
        "icon": "res://assets/achievements/speed.png",
        "requirement": {"type": "time_under", "seconds": 5},
        "xp_reward": 50,
    },
    "efficient_coder": {
        "title": "Efficient Coder",
        "description": "Solve a level with optimal lines of code",
        "icon": "res://assets/achievements/efficient.png",
        "requirement": {"type": "optimal_lines"},
        "xp_reward": 25,
    },
    "perfectionist": {
        "title": "Perfectionist",
        "description": "Earn 3 stars on 10 levels",
        "icon": "res://assets/achievements/perfect.png",
        "requirement": {"type": "three_stars", "count": 10},
        "xp_reward": 100,
    },
    "bug_master": {
        "title": "Bug Master",
        "description": "Complete all tutorial levels",
        "icon": "res://assets/achievements/master.png",
        "requirement": {"type": "tutorials_complete"},
        "xp_reward": 150,
    },
}

var unlocked_achievements: Array = []

func check_achievement(achievement_id: String, progress_data: Dictionary) -> bool:
    if achievement_id in unlocked_achievements:
        return false  # Already unlocked
    
    var achievement = ACHIEVEMENTS.get(achievement_id)
    if not achievement:
        return false
    
    var req = achievement.requirement
    var unlocked = false
    
    match req.type:
        "levels_completed":
            unlocked = progress_data.get("levels_completed", 0) >= req.count
        "time_under":
            unlocked = progress_data.get("completion_time", 999) < req.seconds
        "optimal_lines":
            unlocked = progress_data.get("lines", 999) == progress_data.get("optimal_lines", 0)
        "three_stars":
            unlocked = progress_data.get("three_star_count", 0) >= req.count
        "tutorials_complete":
            unlocked = progress_data.get("tutorials_done", 0) == progress_data.get("total_tutorials", 99)
    
    if unlocked:
        _unlock_achievement(achievement_id, achievement)
    
    return unlocked

func _unlock_achievement(id: String, achievement: Dictionary):
    unlocked_achievements.append(id)
    achievement_unlocked.emit(achievement)
    _show_achievement_popup(achievement)
    _save_progress()

func _show_achievement_popup(achievement: Dictionary):
    # Show animated popup with achievement details
    var popup = preload("res://scenes/achievement_popup.tscn").instantiate()
    popup.set_achievement_data(achievement)
    get_tree().root.add_child(popup)
    popup.animate_in()

func _save_progress():
    var save_data = {"achievements": unlocked_achievements}
    var file = FileAccess.open("user://achievements.dat", FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(save_data))
        file.close()

func load_progress():
    var file = FileAccess.open("user://achievements.dat", FileAccess.READ)
    if file:
        var json = JSON.parse_string(file.get_as_text())
        if json:
            unlocked_achievements = json.get("achievements", [])
        file.close()
```

---

### 2.5 Daily Challenges

```gdscript
# daily_challenge.gd
extends Node

var current_challenge: Dictionary = {}
var challenge_completed_today: bool = false

func _ready():
    _load_daily_challenge()

func _load_daily_challenge():
    # Daily challenge changes every 24 hours based on date
    var date = Time.get_date_dict_from_system()
    var seed_value = date.year * 10000 + date.month * 100 + date.day
    
    # Generate deterministic challenge based on date
    seed(seed_value)
    
    var challenge_types = ["speed_run", "minimal_code", "no_sensors", "backwards_only"]
    var challenge_type = challenge_types[randi() % challenge_types.size()]
    
    var level_pool = _get_suitable_levels_for_challenge(challenge_type)
    var selected_level = level_pool[randi() % level_pool.size()]
    
    current_challenge = {
        "date": "%04d-%02d-%02d" % [date.year, date.month, date.day],
        "type": challenge_type,
        "level_id": selected_level,
        "title": _get_challenge_title(challenge_type),
        "description": _get_challenge_description(challenge_type),
        "reward_xp": 100,
        "reward_coins": 50,
    }
    
    _check_if_completed_today()

func _get_challenge_title(type: String) -> String:
    match type:
        "speed_run": return "⚡ Speed Run"
        "minimal_code": return "📝 Code Golf"
        "no_sensors": return "🙈 Blind Navigation"
        "backwards_only": return "🔄 Backwards Challenge"
        _: return "Daily Challenge"

func _get_challenge_description(type: String) -> String:
    match type:
        "speed_run": return "Complete the level in under 10 seconds"
        "minimal_code": return "Solve using 5 lines or less"
        "no_sensors": return "Solve without using sensor functions"
        "backwards_only": return "Only use turnBack() and move()"
		_: return "Complete today's challenge"

func attempt_challenge(user_code: String, stats: Dictionary) -> Dictionary:
	var result = {"success": false, "reason": ""}
    
    match current_challenge.type:
		"speed_run":
            if stats.time_ms < 10000:
                result.success = true
            else:
				result.reason = "Too slow! Try to complete faster."
        
		"minimal_code":
            if stats.lines <= 5:
                result.success = true
            else:
				result.reason = "Code too long! Use 5 lines or less."
        
		"no_sensors":
            if not _uses_sensors(user_code):
                result.success = true
            else:
				result.reason = "You used sensor functions! Try without them."
        
		"backwards_only":
            if _only_uses_backwards(user_code):
                result.success = true
            else:
				result.reason = "Only turnBack() and move() allowed!"
    
    if result.success:
        _mark_challenge_complete()
		result["rewards"] = {
			"xp": current_challenge.reward_xp,
			"coins": current_challenge.reward_coins
        }
    
    return result

func _uses_sensors(code: String) -> bool:
	var sensors = ["frontIsClear", "leftIsClear", "rightIsClear", "backClear", "goalReached"]
    for sensor in sensors:
        if sensor in code:
            return true
    return false

func _only_uses_backwards(code: String) -> bool:
	var forbidden = ["turnLeft", "turnRight"]
    for f in forbidden:
        if f in code:
            return false
    return true

func _mark_challenge_complete():
    challenge_completed_today = true
    var save_data = {
		"date": current_challenge.date,
		"completed": true
    }
	var file = FileAccess.open("user://daily_challenge.dat", FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(save_data))
        file.close()
```



---

## 🏆 PHASE 3: Competitive Features (LeetCode-Style)

**Duration**: 6-8 weeks | **Priority**: HIGH | **Team**: 2-3 developers

This phase transforms LediBug into a competitive platform with leaderboards, challenges, and tournaments.

---

### 3.1 Global & Level Leaderboards

#### Leaderboard Types

```gdscript
# leaderboard_manager.gd
extends Node

enum LeaderboardType {
    GLOBAL_XP,          # Ranked by total XP
    GLOBAL_SOLUTIONS,   # Ranked by solutions count
    LEVEL_MOVES,        # Fewest moves for specific level
    LEVEL_LINES,        # Fewest lines for specific level
    LEVEL_TIME,         # Fastest completion
    WEEKLY_CHALLENGE,   # Weekly challenge rankings
    MONTHLY_CONTEST,    # Monthly contest rankings
}

# Leaderboard UI Component
func display_leaderboard(type: LeaderboardType, level_id: String = ""):
    var leaderboard_data = await _fetch_leaderboard(type, level_id)
    _populate_leaderboard_ui(leaderboard_data)

func _fetch_leaderboard(type: LeaderboardType, level_id: String = "") -> Array:
    match type:
        LeaderboardType.GLOBAL_XP:
			return await APIClient.get_leaderboard("xp", 1, 100)
        
        LeaderboardType.LEVEL_MOVES:
			return await APIClient.get_level_leaderboard(level_id, "moves", 1, 50)
        
        LeaderboardType.LEVEL_LINES:
			return await APIClient.get_level_leaderboard(level_id, "lines", 1, 50)
        
        LeaderboardType.LEVEL_TIME:
			return await APIClient.get_level_leaderboard(level_id, "time", 1, 50)
        
        LeaderboardType.WEEKLY_CHALLENGE:
            return await APIClient.get_weekly_challenge_leaderboard()
    
    return []

func _populate_leaderboard_ui(data: Array):
    var container = $LeaderboardContainer/ScrollContainer/VBoxContainer
    
    # Clear existing entries
    for child in container.get_children():
        child.queue_free()
    
    # Add header
    var header = _create_header()
    container.add_child(header)
    
    # Add entries
    for i in range(data.size()):
        var entry = data[i]
        var entry_ui = _create_leaderboard_entry(i + 1, entry)
        container.add_child(entry_ui)
        
        # Highlight current user
        if entry.user_id == APIClient.current_user.id:
            entry_ui.modulate = Color(1.0, 1.0, 0.7)  # Yellow tint

func _create_leaderboard_entry(rank: int, entry: Dictionary) -> Control:
    var entry_node = HBoxContainer.new()
    
    # Rank with medal icons for top 3
    var rank_label = Label.new()
    match rank:
		1: rank_label.text = "🥇"
		2: rank_label.text = "🥈"
		3: rank_label.text = "🥉"
        _: rank_label.text = str(rank)
    rank_label.custom_minimum_size = Vector2(50, 0)
    entry_node.add_child(rank_label)
    
    # User avatar
    var avatar = TextureRect.new()
    avatar.custom_minimum_size = Vector2(32, 32)
    avatar.texture = await _load_avatar(entry.avatar_url)
    entry_node.add_child(avatar)
    
    # Username with title
    var name_label = Label.new()
	name_label.text = entry.username + " " + _get_user_title(entry.level)
    name_label.custom_minimum_size = Vector2(200, 0)
    entry_node.add_child(name_label)
    
    # Score/Stat
    var score_label = Label.new()
    score_label.text = str(entry.score)
    score_label.custom_minimum_size = Vector2(100, 0)
    score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    entry_node.add_child(score_label)
    
    return entry_node
```

#### Backend Leaderboard Queries

```csharp
// LeaderboardService.cs
namespace LediBug.Application.Services
{
    public class LeaderboardService : ILeaderboardService
    {
        private readonly AppDbContext _db;
        private readonly IMemoryCache _cache;
        
        public async Task<List<LeaderboardEntryDTO>> GetGlobalLeaderboardAsync(
			string sortBy = "xp", 
            int page = 1, 
            int pageSize = 100)
        {
			var cacheKey = $"leaderboard_global_{sortBy}_{page}";
            
            if (_cache.TryGetValue(cacheKey, out List<LeaderboardEntryDTO> cached))
                return cached;
            
            IQueryable<User> query = _db.Users
                .Where(u => !u.IsBanned && u.IsActive);
            
            query = sortBy switch
            {
				"xp" => query.OrderByDescending(u => u.XP),
				"solutions" => query.OrderByDescending(u => u.TotalSolutions),
				"level" => query.OrderByDescending(u => u.Level),
                _ => query.OrderByDescending(u => u.XP)
            };
            
            var leaderboard = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(u => new LeaderboardEntryDTO
                {
                    UserId = u.Id,
                    Username = u.Username,
                    AvatarUrl = u.Avatar,
                    Level = u.Level,
                    XP = u.XP,
                    TotalSolutions = u.TotalSolutions,
                    Country = u.Country
                })
                .ToListAsync();
            
            // Cache for 5 minutes
            _cache.Set(cacheKey, leaderboard, TimeSpan.FromMinutes(5));
            
            return leaderboard;
        }
        
        public async Task<List<LevelLeaderboardEntryDTO>> GetLevelLeaderboardAsync(
            Guid levelId,
			string sortBy = "moves",
            int page = 1,
            int pageSize = 50)
        {
			var cacheKey = $"leaderboard_level_{levelId}_{sortBy}_{page}";
            
            if (_cache.TryGetValue(cacheKey, out List<LevelLeaderboardEntryDTO> cached))
                return cached;
            
            IQueryable<Solution> query = _db.Solutions
                .Where(s => s.LevelId == levelId && s.IsCompleted)
                .Include(s => s.User);
            
            query = sortBy switch
            {
				"moves" => query.OrderBy(s => s.Moves).ThenBy(s => s.LinesOfCode),
				"lines" => query.OrderBy(s => s.LinesOfCode).ThenBy(s => s.Moves),
				"time" => query.OrderBy(s => s.ExecutionTimeMs),
                _ => query.OrderBy(s => s.Moves)
            };
            
            var leaderboard = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(s => new LevelLeaderboardEntryDTO
                {
                    SolutionId = s.Id,
                    UserId = s.UserId,
                    Username = s.User.Username,
                    AvatarUrl = s.User.Avatar,
                    Moves = s.Moves,
                    LinesOfCode = s.LinesOfCode,
                    ExecutionTimeMs = s.ExecutionTimeMs,
                    StarsEarned = s.StarsEarned,
                    CreatedAt = s.CreatedAt
                })
                .ToListAsync();
            
            // Cache for 2 minutes (updates more frequently)
            _cache.Set(cacheKey, leaderboard, TimeSpan.FromMinutes(2));
            
            return leaderboard;
        }
        
        public async Task<UserRankDTO> GetUserRankAsync(Guid userId)
        {
            var user = await _db.Users.FindAsync(userId);
            if (user == null) return null;
            
            // Calculate global rank
            var globalRank = await _db.Users
                .Where(u => u.XP > user.XP)
                .CountAsync() + 1;
            
            // Calculate percentile
            var totalUsers = await _db.Users.CountAsync();
            var percentile = (1.0 - (double)globalRank / totalUsers) * 100;
            
            return new UserRankDTO
            {
                GlobalRank = globalRank,
                Percentile = Math.Round(percentile, 2),
                TotalUsers = totalUsers,
                XP = user.XP,
                Level = user.Level,
                Title = GetUserTitle(user.Level)
            };
        }
    }
}
```

---

### 3.2 Weekly Challenges & Monthly Contests

#### Challenge System

```csharp
// Challenge.cs - Entity
namespace LediBug.Core.Entities
{
    public class Challenge : BaseEntity
    {
        [Required, MaxLength(100)]
        public string Title { get; set; } = string.Empty;
        
        [Required, MaxLength(1000)]
        public string Description { get; set; } = string.Empty;
        
        public ChallengeType Type { get; set; }
        
        public ChallengeDifficulty Difficulty { get; set; }
        
        public DateTime StartDate { get; set; }
        
        public DateTime EndDate { get; set; }
        
        public bool IsActive { get; set; }
        
        // Challenge requirements
        public Guid? LevelId { get; set; }  // Specific level (optional)
        public int? MaxMoves { get; set; }
        public int? MaxLines { get; set; }
        public int? MaxTime { get; set; }
		public string[]? Constraints { get; set; }  // e.g., "no_sensors", "backwards_only"
        
        // Rewards
        public int XPReward { get; set; }
        public int CoinsReward { get; set; }
        public string? BadgeReward { get; set; }
        
        // Prize pool for top performers
        public Dictionary<string, object>? Prizes { get; set; }  // JSON
        
        // Stats
        public int ParticipantCount { get; set; } = 0;
        public int CompletionCount { get; set; } = 0;
        
        // Navigation
        public virtual Level? Level { get; set; }
        public virtual ICollection<ChallengeParticipant> Participants { get; set; } = new List<ChallengeParticipant>();
    }
    
    public enum ChallengeType
    {
        Daily,
        Weekly,
        Monthly,
        Special,      // Holiday/event challenges
        Contest       // Competitive tournament
    }
    
    public enum ChallengeDifficulty
    {
        Easy = 1,
        Medium = 2,
        Hard = 3,
        Expert = 4,
        Master = 5
    }
    
    public class ChallengeParticipant : BaseEntity
    {
        public Guid ChallengeId { get; set; }
        public Guid UserId { get; set; }
        public Guid? SolutionId { get; set; }
        
        public bool IsCompleted { get; set; }
        public DateTime? CompletedAt { get; set; }
        
        public int Score { get; set; }  // Based on efficiency
        public int Rank { get; set; }
        
        public int Moves { get; set; }
        public int LinesOfCode { get; set; }
        public int ExecutionTimeMs { get; set; }
        
        // Navigation
        public virtual Challenge Challenge { get; set; } = null!;
        public virtual User User { get; set; } = null!;
        public virtual Solution? Solution { get; set; }
    }
}
```

#### Challenge Controller

```csharp
// ChallengeController.cs
namespace LediBug.API.Controllers
{
    [ApiController]
	[Route("api/[controller]")]
    public class ChallengeController : ControllerBase
    {
        private readonly IChallengeService _challengeService;
        
        // GET /api/challenge/active
		[HttpGet("active")]
        public async Task<ActionResult<List<ChallengeDTO>>> GetActiveChallenges()
        {
            var challenges = await _challengeService.GetActiveChallengesAsync();
            return Ok(challenges);
        }
        
        // GET /api/challenge/daily
		[HttpGet("daily")]
        public async Task<ActionResult<ChallengeDTO>> GetDailyChallenge()
        {
            var challenge = await _challengeService.GetDailyChallengeAsync();
            return Ok(challenge);
        }
        
        // GET /api/challenge/weekly
		[HttpGet("weekly")]
        public async Task<ActionResult<ChallengeDTO>> GetWeeklyChallenge()
        {
            var challenge = await _challengeService.GetWeeklyChallengeAsync();
            return Ok(challenge);
        }
        
        // POST /api/challenge/{id}/participate
        [Authorize]
		[HttpPost("{id}/participate")]
        public async Task<ActionResult> ParticipateInChallenge(Guid id)
        {
            var userId = _authService.GetCurrentUserId(User);
            await _challengeService.RegisterParticipantAsync(id, userId);
            return Ok();
        }
        
        // POST /api/challenge/{id}/submit
        [Authorize]
		[HttpPost("{id}/submit")]
        public async Task<ActionResult<ChallengeResultDTO>> SubmitChallengeSolution(
            Guid id,
            [FromBody] SubmitChallengeRequest request)
        {
            var userId = _authService.GetCurrentUserId(User);
            var result = await _challengeService.SubmitSolutionAsync(id, userId, request);
            return Ok(result);
        }
        
        // GET /api/challenge/{id}/leaderboard
		[HttpGet("{id}/leaderboard")]
        public async Task<ActionResult<List<ChallengeLeaderboardEntryDTO>>> GetChallengeLeaderboard(
            Guid id,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 50)
        {
            var leaderboard = await _challengeService.GetLeaderboardAsync(id, page, pageSize);
            return Ok(leaderboard);
        }
        
        // GET /api/challenge/{id}/my-rank
        [Authorize]
		[HttpGet("{id}/my-rank")]
        public async Task<ActionResult<ChallengeRankDTO>> GetMyRank(Guid id)
        {
            var userId = _authService.GetCurrentUserId(User);
            var rank = await _challengeService.GetUserRankAsync(id, userId);
            return Ok(rank);
        }
    }
}
```

#### Godot Challenge UI

```gdscript
# challenge_menu.gd
extends Control

@onready var daily_panel = $DailyPanel
@onready var weekly_panel = $WeeklyPanel
@onready var monthly_panel = $MonthlyPanel
@onready var special_panel = $SpecialPanel

func _ready():
    _load_challenges()

func _load_challenges():
    # Load daily challenge
    var daily = await APIClient.get_daily_challenge()
    if daily.success:
        _populate_challenge_panel(daily_panel, daily.data)
    
    # Load weekly challenge
    var weekly = await APIClient.get_weekly_challenge()
    if weekly.success:
        _populate_challenge_panel(weekly_panel, weekly.data)
    
    # Load active challenges
    var active = await APIClient.get_active_challenges()
    if active.success:
        _populate_special_challenges(active.data)

func _populate_challenge_panel(panel: Control, challenge: Dictionary):
	panel.get_node("Title").text = challenge.title
	panel.get_node("Description").text = challenge.description
	panel.get_node("Difficulty").text = "Difficulty: " + challenge.difficulty
	panel.get_node("Participants").text = str(challenge.participant_count) + " participants"
    
    # Time remaining
    var time_left = _calculate_time_remaining(challenge.end_date)
	panel.get_node("TimeRemaining").text = time_left
    
    # Rewards
	panel.get_node("Rewards").text = "Rewards: %d XP, %d Coins" % [challenge.xp_reward, challenge.coins_reward]
    
    # Check if already completed
    var my_participation = await APIClient.get_my_challenge_participation(challenge.id)
    if my_participation.success and my_participation.data.is_completed:
		panel.get_node("Status").text = "✓ Completed"
		panel.get_node("Rank").text = "Rank: #" + str(my_participation.data.rank)
    else:
		panel.get_node("PlayButton").disabled = false

func _on_play_challenge_pressed(challenge_id: String):
    # Register participation
    await APIClient.participate_in_challenge(challenge_id)
    
    # Load challenge level
    var challenge = await APIClient.get_challenge(challenge_id)
    if challenge.success:
		get_tree().change_scene_to_file("res://scenes/game.tscn")
        # Pass challenge data to game scene
        await get_tree().create_timer(0.1).timeout
        var game = get_tree().current_scene
        game.load_challenge(challenge.data)

func _on_view_leaderboard_pressed(challenge_id: String):
	var leaderboard_scene = preload("res://scenes/challenge_leaderboard.tscn").instantiate()
    leaderboard_scene.challenge_id = challenge_id
    add_child(leaderboard_scene)
    leaderboard_scene.popup_centered()
```

---

### 3.3 Rating System & Competitive Ranks

#### ELO-Style Rating System

```csharp
// RatingService.cs
namespace LediBug.Application.Services
{
    public class RatingService : IRatingService
    {
        private const int DEFAULT_RATING = 1500;
        private const int K_FACTOR = 32;  // How much ratings change
        
        public async Task<int> CalculateNewRatingAsync(
            Guid userId,
            bool wonChallenge,
            int opponentRating = 1500)
        {
            var user = await _db.Users.FindAsync(userId);
            if (user == null) return DEFAULT_RATING;
            
            var currentRating = user.CompetitiveRating ?? DEFAULT_RATING;
            
            // Calculate expected score
            var expectedScore = 1.0 / (1.0 + Math.Pow(10, (opponentRating - currentRating) / 400.0));
            
            // Actual score (1 for win, 0 for loss)
            var actualScore = wonChallenge ? 1.0 : 0.0;
            
            // New rating
            var newRating = currentRating + (int)(K_FACTOR * (actualScore - expectedScore));
            
            // Update user rating
            user.CompetitiveRating = newRating;
            await _db.SaveChangesAsync();
            
            // Update rank tier
            await _updateRankTier(user);
            
            return newRating;
        }
        
        private async Task _updateRankTier(User user)
        {
            var rating = user.CompetitiveRating ?? DEFAULT_RATING;
            
            var tier = rating switch
            {
				>= 2400 => "Grandmaster",
				>= 2200 => "Master",
				>= 2000 => "Diamond",
				>= 1800 => "Platinum",
				>= 1600 => "Gold",
				>= 1400 => "Silver",
				>= 1200 => "Bronze",
				_ => "Unranked"
            };
            
            user.CompetitiveRank = tier;
            await _db.SaveChangesAsync();
        }
        
        public async Task<RankDistributionDTO> GetRankDistributionAsync()
        {
            var distribution = await _db.Users
                .Where(u => u.CompetitiveRating != null)
                .GroupBy(u => u.CompetitiveRank)
                .Select(g => new { Rank = g.Key, Count = g.Count() })
                .ToListAsync();
            
            var total = distribution.Sum(d => d.Count);
            
            return new RankDistributionDTO
            {
                Distribution = distribution.ToDictionary(
                    d => d.Rank,
                    d => (double)d.Count / total * 100
                ),
                TotalRankedPlayers = total
            };
        }
    }
}
```

---

### 3.4 Tournament System

```gdscript
# tournament.gd
extends Node

enum TournamentFormat {
    SINGLE_ELIMINATION,
    DOUBLE_ELIMINATION,
    ROUND_ROBIN,
    SWISS
}

var current_tournament: Dictionary = {}

func create_tournament(config: Dictionary):
    current_tournament = {
		"id": _generate_id(),
		"title": config.title,
		"format": config.format,
		"max_participants": config.max_participants,
		"entry_fee_coins": config.get("entry_fee", 0),
		"prize_pool": config.prize_pool,
		"levels": config.levels,  # List of level IDs
		"start_time": config.start_time,
		"participants": [],
		"brackets": [],
		"current_round": 0,
		"status": "registration"
    }

func register_participant(user_id: String) -> bool:
	if current_tournament.status != "registration":
        return false
    
    if current_tournament.participants.size() >= current_tournament.max_participants:
        return false
    
    # Check entry fee
    if current_tournament.entry_fee_coins > 0:
        var has_coins = await APIClient.check_user_coins(user_id)
        if not has_coins:
            return false
        await APIClient.deduct_coins(user_id, current_tournament.entry_fee_coins)
    
    current_tournament.participants.append({
		"user_id": user_id,
		"seed": current_tournament.participants.size() + 1,
		"score": 0,
		"matches_won": 0,
		"matches_lost": 0
    })
    
    return true

func start_tournament():
	current_tournament.status = "in_progress"
    
    match current_tournament.format:
        TournamentFormat.SINGLE_ELIMINATION:
            _generate_single_elimination_brackets()
        TournamentFormat.ROUND_ROBIN:
            _generate_round_robin_matches()

func _generate_single_elimination_brackets():
    var participants = current_tournament.participants.duplicate()
    participants.shuffle()
    
    var round_matches = []
    for i in range(0, participants.size(), 2):
        if i + 1 < participants.size():
            round_matches.append({
				"player1": participants[i],
				"player2": participants[i + 1],
				"winner": null,
				"level_id": _select_random_level()
            })
    
    current_tournament.brackets.append(round_matches)

func submit_match_result(match_id: int, winner_id: String, stats: Dictionary):
    var match = _get_match(match_id)
    if match:
        match.winner = winner_id
        match.stats = stats
        
        # Check if round is complete
        if _is_round_complete():
            _advance_to_next_round()

func _advance_to_next_round():
    current_tournament.current_round += 1
    
    var winners = []
    for match in current_tournament.brackets[-1]:
        winners.append(match.winner)
    
    if winners.size() == 1:
        _end_tournament(winners[0])
    else:
        _generate_next_round_brackets(winners)

func _end_tournament(winner_id: String):
	current_tournament.status = "completed"
    current_tournament.winner = winner_id
    
    # Distribute prizes
    await _distribute_prizes()
    
    # Save tournament results
    await APIClient.save_tournament_results(current_tournament)

func _distribute_prizes():
    var prizes = current_tournament.prize_pool
    
    # 1st place: 50% of pool
    # 2nd place: 30% of pool
    # 3rd place: 20% of pool
    pass  # Implementation details
```



---

## 👥 PHASE 4: Community & Social Features

**Duration**: 4-6 weeks | **Priority**: Medium-High | **Team**: 2 developers

### 4.1 Level Sharing & Discovery

```gdscript
# level_browser.gd
extends Control

var current_filter = {
	"difficulty": [],
	"tags": [],
	"sort_by": "popular",  # popular, newest, highest_rated
	"search": ""
}

func _ready():
    _load_community_levels()

func _load_community_levels():
    var levels = await APIClient.get_levels(current_filter)
    if levels.success:
        _populate_level_grid(levels.data)

func _populate_level_grid(levels: Array):
    var grid = $LevelGrid
    
    for level in levels:
		var card = preload("res://scenes/level_card.tscn").instantiate()
        card.set_level_data(level)
        card.play_clicked.connect(_on_level_play)
        card.favorite_clicked.connect(_on_level_favorite)
        grid.add_child(card)

# Level Card UI
# level_card.gd
extends PanelContainer

signal play_clicked(level_id)
signal favorite_clicked(level_id)

var level_data: Dictionary = {}

func set_level_data(data: Dictionary):
    level_data = data
    _update_ui()

func _update_ui():
    $VBox/Title.text = level_data.title
	$VBox/Author.text = "by " + level_data.creator_username
	$VBox/Stats/Plays.text = "▶ " + str(level_data.play_count)
	$VBox/Stats/Likes.text = "❤ " + str(level_data.like_count)
	$VBox/Stats/Rating.text = "⭐ %.1f" % level_data.average_rating
    $VBox/Difficulty.text = _get_difficulty_text(level_data.difficulty)
    
    # Tags
    var tags_container = $VBox/Tags
    for tag in level_data.tags:
        var tag_label = Label.new()
		tag_label.text = "#" + tag
		tag_label.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))
        tags_container.add_child(tag_label)

func _on_play_button_pressed():
    play_clicked.emit(level_data.id)

func _on_favorite_button_pressed():
    favorite_clicked.emit(level_data.id)
```

### 4.2 Comments & Ratings

```csharp
// Comment.cs
namespace LediBug.Core.Entities
{
    public class Comment : BaseEntity
    {
        public Guid UserId { get; set; }
        
        public Guid? LevelId { get; set; }
        public Guid? SolutionId { get; set; }
        
        [Required, MaxLength(2000)]
        public string Content { get; set; } = string.Empty;
        
        public Guid? ParentCommentId { get; set; }  // For replies
        
        public int LikeCount { get; set; } = 0;
        
        public bool IsEdited { get; set; }
        
        public bool IsDeleted { get; set; }
        
        // Navigation
        public virtual User User { get; set; } = null!;
        public virtual Level? Level { get; set; }
        public virtual Solution? Solution { get; set; }
        public virtual Comment? ParentComment { get; set; }
        public virtual ICollection<Comment> Replies { get; set; } = new List<Comment>();
    }
    
    public class LevelRating : BaseEntity
    {
        public Guid UserId { get; set; }
        public Guid LevelId { get; set; }
        
        [Range(1, 5)]
        public int Rating { get; set; }
        
        [MaxLength(500)]
        public string? Review { get; set; }
        
        // Navigation
        public virtual User User { get; set; } = null!;
        public virtual Level Level { get; set; } = null!;
    }
}

// CommentController.cs
namespace LediBug.API.Controllers
{
    [ApiController]
	[Route("api/[controller]")]
    public class CommentController : ControllerBase
    {
        // GET /api/comment/level/{levelId}
		[HttpGet("level/{levelId}")]
        public async Task<ActionResult<List<CommentDTO>>> GetLevelComments(
            Guid levelId,
			[FromQuery] string sortBy = "newest",
            [FromQuery] int page = 1)
        {
            var comments = await _commentService.GetLevelCommentsAsync(levelId, sortBy, page);
            return Ok(comments);
        }
        
        // POST /api/comment
        [Authorize]
        [HttpPost]
        public async Task<ActionResult<CommentDTO>> PostComment([FromBody] CreateCommentRequest request)
        {
            var userId = _authService.GetCurrentUserId(User);
            var comment = await _commentService.CreateAsync(userId, request);
            return CreatedAtAction(nameof(GetComment), new { id = comment.Id }, comment);
        }
        
        // PUT /api/comment/{id}
        [Authorize]
		[HttpPut("{id}")]
        public async Task<ActionResult<CommentDTO>> EditComment(
            Guid id,
            [FromBody] EditCommentRequest request)
        {
            var userId = _authService.GetCurrentUserId(User);
            var comment = await _commentService.UpdateAsync(id, userId, request.Content);
            if (comment == null) return NotFound();
            return Ok(comment);
        }
        
        // DELETE /api/comment/{id}
        [Authorize]
		[HttpDelete("{id}")]
        public async Task<ActionResult> DeleteComment(Guid id)
        {
            var userId = _authService.GetCurrentUserId(User);
            var success = await _commentService.DeleteAsync(id, userId);
            if (!success) return NotFound();
            return NoContent();
        }
        
        // POST /api/comment/{id}/like
        [Authorize]
		[HttpPost("{id}/like")]
        public async Task<ActionResult> LikeComment(Guid id)
        {
            var userId = _authService.GetCurrentUserId(User);
            await _commentService.ToggleLikeAsync(id, userId);
            return Ok();
        }
    }
}
```

### 4.3 Follow System & Activity Feed

```csharp
// Follow.cs
namespace LediBug.Core.Entities
{
    public class Follow : BaseEntity
    {
        public Guid FollowerId { get; set; }     // User who follows
        public Guid FollowingId { get; set; }    // User being followed
        
        // Navigation
        public virtual User Follower { get; set; } = null!;
        public virtual User Following { get; set; } = null!;
    }
    
    public class Notification : BaseEntity
    {
        public Guid UserId { get; set; }
        
        public NotificationType Type { get; set; }
        
        [Required, MaxLength(500)]
        public string Message { get; set; } = string.Empty;
        
        public Guid? RelatedUserId { get; set; }
        public Guid? RelatedLevelId { get; set; }
        public Guid? RelatedSolutionId { get; set; }
        public Guid? RelatedCommentId { get; set; }
        
        public bool IsRead { get; set; }
        
        // Navigation
        public virtual User User { get; set; } = null!;
    }
    
    public enum NotificationType
    {
        NewFollower,
        LevelLiked,
        LevelCommented,
        SolutionLiked,
        SolutionCommented,
        CommentReply,
        AchievementUnlocked,
        ChallengeInvite,
        TournamentStarting
    }
}
```

```gdscript
# activity_feed.gd
extends ScrollContainer

func _ready():
    _load_activity_feed()
    # Real-time updates via SignalR/WebSocket
    APIClient.notification_received.connect(_on_notification)

func _load_activity_feed():
    var activities = await APIClient.get_activity_feed(1, 20)
    if activities.success:
        _populate_feed(activities.data)

func _populate_feed(activities: Array):
    var container = $VBox
    
    for activity in activities:
        var item = _create_activity_item(activity)
        container.add_child(item)

func _create_activity_item(activity: Dictionary) -> Control:
    var item = HBoxContainer.new()
    
    # Icon
    var icon = TextureRect.new()
    icon.texture = _get_icon_for_type(activity.type)
    item.add_child(icon)
    
    # Message
    var message = RichTextLabel.new()
    message.bbcode_enabled = true
    message.text = _format_activity_message(activity)
    item.add_child(message)
    
    # Timestamp
    var time = Label.new()
    time.text = _format_time_ago(activity.created_at)
    item.add_child(time)
    
    return item

func _on_notification(notification: Dictionary):
    # Add new notification to top of feed
    var item = _create_activity_item(notification)
    $VBox.add_child(item)
    $VBox.move_child(item, 0)
    
    # Show popup toast
    _show_notification_toast(notification)
```

### 4.4 User Profiles & Stats

```gdscript
# user_profile.gd
extends Control

var viewing_user_id: String = ""

func _ready():
    viewing_user_id = get_parent().user_id
    _load_profile()

func _load_profile():
    var profile = await APIClient.get_user_profile(viewing_user_id)
    if profile.success:
        _populate_profile(profile.data)
    
    var stats = await APIClient.get_user_stats(viewing_user_id)
    if stats.success:
        _populate_stats(stats.data)
    
    var solutions = await APIClient.get_user_solutions(viewing_user_id, 1, 10)
    if solutions.success:
        _populate_recent_solutions(solutions.data)

func _populate_profile(user: Dictionary):
    $Header/Avatar.texture = await _load_texture(user.avatar_url)
    $Header/Username.text = user.username
    $Header/Title.text = user.title
    $Header/Bio.text = user.bio
	$Header/Country.text = "🌍 " + user.country
    
    # Follow button
    if viewing_user_id != APIClient.current_user.id:
        $Header/FollowButton.visible = true
        var is_following = await APIClient.check_following(viewing_user_id)
		$Header/FollowButton.text = "Following" if is_following else "Follow"

func _populate_stats(stats: Dictionary):
	$Stats/XP.text = "XP: " + str(stats.xp)
	$Stats/Level.text = "Level: " + str(stats.level)
	$Stats/GlobalRank.text = "Rank: #" + str(stats.global_rank)
	$Stats/TotalSolutions.text = "Solutions: " + str(stats.total_solutions)
	$Stats/Easy.text = "Easy: " + str(stats.solutions_easy)
	$Stats/Medium.text = "Medium: " + str(stats.solutions_medium)
	$Stats/Hard.text = "Hard: " + str(stats.solutions_hard)
    
    # Achievement badges
    var badge_container = $Stats/Badges
    for badge in stats.badges:
        var badge_icon = TextureRect.new()
        badge_icon.texture = await _load_badge_texture(badge)
        badge_icon.tooltip_text = badge
        badge_container.add_child(badge_icon)

func _on_follow_button_pressed():
    await APIClient.toggle_follow(viewing_user_id)
    # Refresh button state
    var is_following = await APIClient.check_following(viewing_user_id)
	$Header/FollowButton.text = "Following" if is_following else "Follow"
```


---

## 📚 PHASE 5: Educational Enhancement

**Duration**: 4-5 weeks | **Priority**: Medium | **Team**: 1-2 developers + Content Creator

### 5.1 Interactive Concept Explanations

```gdscript
# concept_library.gd
extends Node

const CONCEPTS = {
	"loops": {
		"title": "Loops & Repetition",
		"description": "Loops let you repeat actions without writing the same code multiple times.",
		"examples": [
            {
				"code": "repeat(5) {\n    move()\n}",
				"explanation": "Move forward 5 times"
            },
            {
				"code": "while(frontIsClear()) {\n    move()\n}",
				"explanation": "Keep moving until blocked"
            }
        ],
		"practice_levels": ["loop_basics_1", "loop_basics_2"],
		"video_url": "https://youtube.com/...",
    },
	"conditionals": {
		"title": "If Statements",
		"description": "Make decisions in your code based on conditions.",
		"examples": [...],
    },
    # ... more concepts
}

func get_concept(concept_id: String) -> Dictionary:
    return CONCEPTS.get(concept_id, {})

func show_concept_explainer(concept_id: String):
	var popup = preload("res://scenes/concept_explainer.tscn").instantiate()
    popup.set_concept(get_concept(concept_id))
    add_child(popup)
    popup.popup_centered()
```

### 5.2 Adaptive Difficulty

```csharp
// AdaptiveLearningService.cs
namespace LediBug.Application.Services
{
    public class AdaptiveLearningService
    {
        public async Task<Level> GetNextRecommendedLevelAsync(Guid userId)
        {
            var user = await _db.Users
                .Include(u => u.Solutions)
                .FirstOrDefaultAsync(u => u.Id == userId);
            
            // Analyze user's performance
            var recentSolutions = user.Solutions
                .OrderByDescending(s => s.CreatedAt)
                .Take(10)
                .ToList();
            
            var averageStars = recentSolutions.Average(s => s.StarsEarned);
            var struggleTopics = _identifyStruggleTopics(recentSolutions);
            
            // Recommend level based on performance
            Level recommendedLevel;
            
            if (averageStars < 2.0)
            {
                // Struggling - recommend easier level on same topic
                recommendedLevel = await _findReinforcementLevel(struggleTopics);
            }
            else if (averageStars >= 2.8)
            {
                // Doing well - challenge with harder level
                recommendedLevel = await _findChallengeLevel(user.CurrentSkillLevel + 1);
            }
            else
            {
                // Steady progress - next level in sequence
                recommendedLevel = await _findNextSequentialLevel(user);
            }
            
            return recommendedLevel;
        }
        
        private List<string> _identifyStruggleTopics(List<Solution> solutions)
        {
            var lowScoreLevels = solutions
                .Where(s => s.StarsEarned < 2)
                .Select(s => s.Level)
                .ToList();
            
            var topicCounts = lowScoreLevels
                .SelectMany(l => l.Concepts)
                .GroupBy(c => c)
                .OrderByDescending(g => g.Count())
                .Select(g => g.Key)
                .Take(3)
                .ToList();
            
            return topicCounts;
        }
    }
}
```

### 5.3 Video Tutorials & Documentation

```gdscript
# tutorial_video_player.gd
extends Control

var current_video: Dictionary = {}

func play_tutorial(tutorial_id: String):
    current_video = await APIClient.get_tutorial_video(tutorial_id)
    if current_video.success:
        _load_video(current_video.data)

func _load_video(video_data: Dictionary):
	if OS.has_feature("web"):
        # Use HTML5 video on web
        _load_web_video(video_data.url)
    else:
        # Use VideoStreamPlayer on desktop
        var video = $VideoPlayer
        video.stream = load(video_data.local_path)
        video.play()
    
    # Show transcript
    $Transcript/RichTextLabel.text = video_data.transcript
    
    # Show code examples
    _populate_code_examples(video_data.examples)

func _load_web_video(url: String):
	var iframe = '<iframe width="100%%" height="400" src="%s"></iframe>' % url
	JavaScriptBridge.eval('document.getElementById("video-container").innerHTML = `%s`' % iframe)
```

### 5.4 Progress Tracking & Learning Path

```gdscript
# learning_path.gd
extends Control

var learning_paths = {
	"beginner": [
		"movement_basics",
		"turning_basics",
		"loops_intro",
		"conditionals_intro",
		"functions_intro"
    ],
	"intermediate": [
		"sensors_advanced",
		"nested_loops",
		"complex_conditions",
		"recursion_intro"
    ],
	"advanced": [
		"optimization",
		"algorithms",
		"problem_solving"
    ]
}

func _ready():
    _load_progress()

func _load_progress():
    var progress = await APIClient.get_learning_progress()
    if progress.success:
        _visualize_progress(progress.data)

func _visualize_progress(progress: Dictionary):
    var path_container = $PathContainer
    
    for path_name in learning_paths:
        var path_node = _create_path_visualization(path_name, progress)
        path_container.add_child(path_node)

func _create_path_visualization(path_name: String, progress: Dictionary) -> Control:
    var path_panel = VBoxContainer.new()
    
    # Title
    var title = Label.new()
    title.text = path_name.capitalize()
    path_panel.add_child(title)
    
    # Progress nodes
    var levels = learning_paths[path_name]
    for i in range(levels.size()):
        var level_id = levels[i]
        var node = _create_level_node(level_id, progress.completed_levels.has(level_id))
        path_panel.add_child(node)
        
        # Connection line
        if i < levels.size() - 1:
            path_panel.add_child(_create_connector())
    
    return path_panel

func _create_level_node(level_id: String, completed: bool) -> Control:
    var node = PanelContainer.new()
    
    if completed:
        node.modulate = Color(0.5, 1.0, 0.5)  # Green
		node.get_node("Icon").text = "✓"
    else:
        node.modulate = Color(0.7, 0.7, 0.7)  # Gray
		node.get_node("Icon").text = "🔒"
    
    return node
```


---

## 🎨 PHASE 6: Polish & User Experience

**Duration**: 3-4 weeks | **Priority**: Medium | **Team**: 2 developers + Designer

### 6.1 Animations & Visual Feedback

```gdscript
# animation_manager.gd
extends Node

func play_move_animation(player: Node2D, from: Vector2i, to: Vector2i):
    var tween = create_tween()
    tween.set_trans(Tween.TRANS_CUBIC)
    tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(player, "position", _grid_to_world(to), 0.3)
    await tween.finished

func play_turn_animation(player: Node2D, direction: Vector2i):
    var target_rotation = _direction_to_rotation(direction)
    var tween = create_tween()
	tween.tween_property(player, "rotation_degrees", target_rotation, 0.2)
    await tween.finished

func play_death_animation(player: Node2D):
    var tween = create_tween()
	tween.tween_property(player, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(player, "scale", Vector2(1.5, 1.5), 0.5)
    await tween.finished

func play_goal_reached_animation(player: Node2D):
    # Particle burst
    var particles = CPUParticles2D.new()
    particles.amount = 50
    particles.lifetime = 1.0
    particles.explosiveness = 1.0
    particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
    player.add_child(particles)
    particles.emitting = true
    
    # Player bounce
    var tween = create_tween()
	tween.tween_property(player, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(player, "scale", Vector2(1.0, 1.0), 0.2)
    await tween.finished

func play_coin_collect_animation(coin_position: Vector2):
    var coin = Sprite2D.new()
	coin.texture = preload("res://assets/coin.png")
    coin.position = coin_position
    add_child(coin)
    
    var tween = create_tween()
	tween.tween_property(coin, "position:y", coin_position.y - 100, 0.5)
	tween.parallel().tween_property(coin, "modulate:a", 0.0, 0.5)
    await tween.finished
    coin.queue_free()
```

### 6.2 Sound Effects & Music

```gdscript
# audio_manager.gd
extends Node

var sfx_bus = AudioServer.get_bus_index("SFX")
var music_bus = AudioServer.get_bus_index("Music")

var sounds = {
	"move": preload("res://assets/audio/move.wav"),
	"turn": preload("res://assets/audio/turn.wav"),
	"death": preload("res://assets/audio/death.wav"),
	"goal": preload("res://assets/audio/goal_reached.wav"),
	"button_click": preload("res://assets/audio/button_click.wav"),
	"coin_collect": preload("res://assets/audio/coin.wav"),
	"achievement": preload("res://assets/audio/achievement.wav"),
}

var music_tracks = {
	"menu": preload("res://assets/music/menu_theme.ogg"),
	"gameplay": preload("res://assets/music/gameplay_theme.ogg"),
	"challenge": preload("res://assets/music/challenge_theme.ogg"),
}

var current_music: AudioStreamPlayer = null

func play_sound(sound_name: String):
    if sound_name in sounds:
        var player = AudioStreamPlayer.new()
        player.stream = sounds[sound_name]
		player.bus = "SFX"
        add_child(player)
        player.play()
        player.finished.connect(player.queue_free)

func play_music(track_name: String, fade_duration: float = 1.0):
    if track_name in music_tracks:
        # Fade out current music
        if current_music:
            var tween = create_tween()
			tween.tween_property(current_music, "volume_db", -80, fade_duration)
            await tween.finished
            current_music.stop()
            current_music.queue_free()
        
        # Fade in new music
        current_music = AudioStreamPlayer.new()
        current_music.stream = music_tracks[track_name]
		current_music.bus = "Music"
        current_music.volume_db = -80
        add_child(current_music)
        current_music.play()
        
        var tween = create_tween()
		tween.tween_property(current_music, "volume_db", 0, fade_duration)

func set_sfx_volume(volume_percent: float):
    AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(volume_percent / 100.0))

func set_music_volume(volume_percent: float):
    AudioServer.set_bus_volume_db(music_bus, linear_to_db(volume_percent / 100.0))
```

### 6.3 Internationalization (i18n)

```gdscript
# translation_manager.gd
extends Node

const SUPPORTED_LANGUAGES = {
	"en": "English",
	"es": "Español",
	"fr": "Français",
	"de": "Deutsch",
	"ja": "日本語",
	"zh": "中文",
	"ru": "Русский",
}

var current_language = "en"

func _ready():
    _load_saved_language()
    _apply_language(current_language)

func set_language(lang_code: String):
    if lang_code in SUPPORTED_LANGUAGES:
        current_language = lang_code
        _apply_language(lang_code)
        _save_language(lang_code)

func _apply_language(lang_code: String):
    TranslationServer.set_locale(lang_code)
    # Force UI refresh
	get_tree().call_group("translatable", "_update_text")

func _load_saved_language():
    var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		current_language = config.get_value("locale", "language", "en")

func _save_language(lang_code: String):
    var config = ConfigFile.new()
	config.set_value("locale", "language", lang_code)
	config.save("user://settings.cfg")

# Translation files: res://locales/en.translation, es.translation, etc.
# Use tr() function: $Label.text = tr("PLAY_BUTTON")
```

### 6.4 Accessibility Features

```gdscript
# accessibility_manager.gd
extends Node

var settings = {
	"high_contrast": false,
	"large_text": false,
	"reduce_motion": false,
	"screen_reader": false,
	"colorblind_mode": "none",  # "protanopia", "deuteranopia", "tritanopia"
}

func enable_high_contrast(enabled: bool):
    settings.high_contrast = enabled
    if enabled:
        # Increase contrast in UI
        _apply_high_contrast_theme()

func enable_large_text(enabled: bool):
    settings.large_text = enabled
    var scale = 1.5 if enabled else 1.0
    get_tree().root.content_scale_factor = scale

func enable_reduce_motion(enabled: bool):
    settings.reduce_motion = enabled
    AnimationManager.animations_enabled = not enabled

func set_colorblind_mode(mode: String):
    settings.colorblind_mode = mode
    _apply_color_correction(mode)

func _apply_color_correction(mode: String):
	var shader = preload("res://shaders/colorblind_correction.gdshader")
    # Apply shader to viewport
    pass
```


---

## 💰 PHASE 7: Monetization & Sustainability

**Duration**: 2-3 weeks | **Priority**: Low (After User Base) | **Team**: 1 developer + Marketing

### 7.1 Premium Membership

```csharp
// PremiumFeatures.cs
namespace LediBug.Core
{
    public class PremiumFeatures
    {
        public const decimal MONTHLY_PRICE = 4.99m;
        public const decimal YEARLY_PRICE = 39.99m;  // 2 months free
        
        public static readonly string[] Features = new[]
        {
			"Unlimited custom levels",
			"Advanced analytics & stats",
			"Priority support",
			"Exclusive themes & skins",
			"Ad-free experience",
			"Early access to new features",
			"Custom badges & titles",
			"Download solutions offline"
        };
        
        public static bool HasFeature(User user, string feature)
        {
            if (!user.IsPremium) return false;
            if (user.PremiumExpiresAt < DateTime.UtcNow) return false;
            return true;
        }
    }
}

// SubscriptionController.cs
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class SubscriptionController : ControllerBase
{
    // POST /api/subscription/subscribe
	[HttpPost("subscribe")]
    public async Task<ActionResult<SubscriptionDTO>> Subscribe([FromBody] SubscribeRequest request)
    {
        var userId = _authService.GetCurrentUserId(User);
        
        // Create Stripe checkout session
        var sessionId = await _paymentService.CreateCheckoutSessionAsync(
            userId,
			request.Plan,  // "monthly" or "yearly"
            request.PaymentMethod
        );
        
        return Ok(new { sessionId });
    }
    
    // POST /api/subscription/cancel
	[HttpPost("cancel")]
    public async Task<ActionResult> CancelSubscription()
    {
        var userId = _authService.GetCurrentUserId(User);
        await _subscriptionService.CancelAsync(userId);
        return Ok();
    }
    
    // GET /api/subscription/status
	[HttpGet("status")]
    public async Task<ActionResult<SubscriptionStatusDTO>> GetStatus()
    {
        var userId = _authService.GetCurrentUserId(User);
        var status = await _subscriptionService.GetStatusAsync(userId);
        return Ok(status);
    }
}
```

### 7.2 Virtual Currency & Cosmetics

```gdscript
# shop_manager.gd
extends Control

var shop_items = {
	"themes": [
		{"id": "dark_blue", "name": "Ocean Theme", "price_coins": 100, "premium_only": false},
		{"id": "sunset", "name": "Sunset Theme", "price_coins": 150, "premium_only": false},
		{"id": "matrix", "name": "Matrix Theme", "price_coins": 200, "premium_only": true},
    ],
	"skins": [
		{"id": "robot", "name": "Robot Bug", "price_coins": 300},
		{"id": "ninja", "name": "Ninja Bug", "price_coins": 500},
		{"id": "golden", "name": "Golden Bug", "price_coins": 1000, "premium_only": true},
    ],
	"badges": [
		{"id": "veteran", "name": "Veteran Badge", "price_coins": 250},
		{"id": "legend", "name": "Legend Badge", "price_coins": 1000},
    ]
}

func _ready():
    _load_shop_items()

func _load_shop_items():
    var user_coins = APIClient.current_user.coins
    var is_premium = APIClient.current_user.is_premium
    
    for category in shop_items:
        for item in shop_items[category]:
			if item.get("premium_only", false) and not is_premium:
                continue  # Skip premium items for free users
            
            var item_ui = _create_shop_item_ui(item, user_coins)
            $ShopGrid.add_child(item_ui)

func _on_purchase_item(item_id: String, price: int):
    var result = await APIClient.purchase_shop_item(item_id)
    if result.success:
        _show_purchase_success(item_id)
        # Refresh coins
        APIClient.current_user.coins -= price
        _update_coin_display()
    else:
        _show_error(result.error)
```

### 7.3 Non-Intrusive Ads (Free Tier)

```gdscript
# ad_manager.gd
extends Node

var ad_provider: AdInterface = null
var ads_enabled: bool = true

func _ready():
	if OS.has_feature("web"):
        ad_provider = WebAdProvider.new()
    else:
        ad_provider = MobileAdProvider.new()  # AdMob
    
    _check_ad_eligibility()

func _check_ad_eligibility():
    # Don't show ads to premium users
    ads_enabled = not APIClient.current_user.is_premium

func show_rewarded_ad(reward_callback: Callable):
    if not ads_enabled:
        reward_callback.call()  # Give reward anyway for premium
        return
    
    ad_provider.show_rewarded_ad(func(success):
        if success:
            reward_callback.call()
    )

func show_interstitial_ad():
    if not ads_enabled:
        return
    
    # Only show between level completions, max once per 5 minutes
    if Time.get_ticks_msec() - last_ad_time < 300000:
        return
    
    ad_provider.show_interstitial_ad()
    last_ad_time = Time.get_ticks_msec()

# Example: Reward double XP for watching ad
func _on_double_xp_button_pressed():
    AdManager.show_rewarded_ad(func():
        $XPMultiplier.multiplier = 2.0
        $XPMultiplier.duration = 3600  # 1 hour
    )
```


---

## 🔧 PHASE 8: Technical Infrastructure

**Duration**: Ongoing | **Priority**: High | **Team**: DevOps + Backend Developer

### 8.1 Backend Deployment (Azure)

```yaml
# docker-compose.yml
version: '3.8'

services:
  api:
    build:
      context: ./LediBug.API
      dockerfile: Dockerfile
    ports:
	  - "5000:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ConnectionStrings__DefaultConnection=${DB_CONNECTION}
      - JWT__Secret=${JWT_SECRET}
      - Redis__ConnectionString=${REDIS_CONNECTION}
    depends_on:
      - postgres
      - redis
    restart: unless-stopped

  postgres:
    image: postgres:16
    environment:
      - POSTGRES_DB=ledibug
      - POSTGRES_USER=${DB_USER}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
	  - "5432:5432"
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    ports:
	  - "6379:6379"
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
	  - "80:80"
	  - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - api
    restart: unless-stopped

volumes:
  postgres_data:
```

```dockerfile
# LediBug.API/Dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["LediBug.API/LediBug.API.csproj", "LediBug.API/"]
COPY ["LediBug.Application/LediBug.Application.csproj", "LediBug.Application/"]
COPY ["LediBug.Core/LediBug.Core.csproj", "LediBug.Core/"]
COPY ["LediBug.Infrastructure/LediBug.Infrastructure.csproj", "LediBug.Infrastructure/"]
RUN dotnet restore "LediBug.API/LediBug.API.csproj"
COPY . .
WORKDIR "/src/LediBug.API"
RUN dotnet build "LediBug.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "LediBug.API.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "LediBug.API.dll"]
```

### 8.2 CI/CD Pipeline (GitHub Actions)

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup .NET
      uses: actions/setup-dotnet@v3
      with:
        dotnet-version: 8.0.x
    
    - name: Restore dependencies
      run: dotnet restore
    
    - name: Build
      run: dotnet build --no-restore
    
    - name: Test
      run: dotnet test --no-build --verbosity normal

  build-and-push:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Login to Docker Hub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
    
    - name: Build and push Docker image
      uses: docker/build-push-action@v4
      with:
        context: .
        push: true
        tags: ledibug/api:latest,ledibug/api:${{ github.sha }}

  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest
    
    steps:
    - name: Deploy to Azure
      uses: azure/webapps-deploy@v2
      with:
        app-name: 'ledibug-api'
        publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
        images: 'ledibug/api:${{ github.sha }}'
```

### 8.3 Monitoring & Logging

```csharp
// Program.cs - Add Serilog & Application Insights
using Serilog;
using Serilog.Events;

var builder = WebApplication.CreateBuilder(args);

// Configure Serilog
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
	.MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
    .Enrich.FromLogContext()
    .WriteTo.Console()
	.WriteTo.File("logs/ledibug-.txt", rollingInterval: RollingInterval.Day)
    .WriteTo.ApplicationInsights(
		builder.Configuration["ApplicationInsights:InstrumentationKey"],
        TelemetryConverter.Traces)
    .CreateLogger();

builder.Host.UseSerilog();

// Add Application Insights
builder.Services.AddApplicationInsightsTelemetry();

// Health checks
builder.Services.AddHealthChecks()
	.AddNpgSql(builder.Configuration.GetConnectionString("DefaultConnection"))
	.AddRedis(builder.Configuration["Redis:ConnectionString"]);

var app = builder.Build();

app.UseHealthChecks("/health");

app.Run();
```


---

## 📈 PHASE 9: Marketing & Growth

**Duration**: Ongoing | **Priority**: Medium | **Team**: Marketing + Community Manager

### 9.1 Launch Strategy

**Pre-Launch (2 months before)**:
1. Create landing page with email signup
2. Build Discord community
3. Create social media accounts (Twitter, YouTube, TikTok)
4. Reach out to programming YouTubers
5. Beta testing program (invite 100 users)

**Launch Week**:
1. Product Hunt launch
2. Post on r/programming, r/learnprogramming, r/gamedev
3. Email beta testers
4. Press release to tech blogs
5. Launch video on YouTube

**Post-Launch (First 3 months)**:
1. Weekly dev blogs
2. User spotlight features
3. Monthly competitions
4. Partnerships with coding bootcamps
5. Sponsor programming YouTubers

### 9.2 Content Marketing

```markdown
**Blog Topics**:
- "5 Ways LediBug Makes Learning to Code Fun"
- "From Zero to Hero: Complete Python Tutorial with LediBug"
- "Challenge Spotlight: This Week's Hardest Puzzle"
- "User Story: How LediBug Helped Me Land a Job"
- "Behind the Scenes: Building LediBug's Game Engine"

**Video Series**:
- Tutorial videos for each concept
- Speedrun challenges
- Developer commentary
- User-created content highlights
- Weekly challenge walkthroughs

**Social Media Strategy**:
- Daily coding tips on Twitter
- Short challenge videos on TikTok
- Community highlights on Instagram
- Live coding sessions on Twitch
```

### 9.3 Community Building

```gdscript
# community_manager.gd
extends Node

func schedule_weekly_event():
    var events = [
		{"type": "challenge", "day": "Monday", "title": "Monday Mayhem"},
		{"type": "tournament", "day": "Friday", "title": "Friday Showdown"},
		{"type": "stream", "day": "Wednesday", "title": "Dev Q&A Stream"},
    ]
    
    for event in events:
        _create_event_notification(event)

func feature_level_of_the_week():
    # Pick best community level from past week
    var top_level = await APIClient.get_top_community_level()
    await APIClient.feature_level(top_level.id)
    
    # Notify creator
    await APIClient.send_notification(
        top_level.creator_id,
		"Your level '%s' was featured as Level of the Week!" % top_level.title
    )

func send_newsletter():
    var subscribers = await APIClient.get_newsletter_subscribers()
    
    var content = {
		"top_levels": await APIClient.get_top_levels_this_week(5),
		"top_players": await APIClient.get_top_players_this_week(10),
		"new_features": _get_latest_updates(),
		"upcoming_events": _get_upcoming_events(),
    }
    
	await EmailService.send_bulk(subscribers, "weekly_newsletter", content)
```


---

## 📅 Implementation Timeline

### Overview (12-18 months total)

```
Month 1-2:   Phase 1 (Web Deployment & Backend)
Month 3-4:   Phase 2 (Core Gameplay Enhancements)
Month 5-7:   Phase 3 (Competitive Features)
Month 8-10:  Phase 4 (Community Features)
Month 11-12: Phase 5 (Educational Enhancement)
Month 13-14: Phase 6 (Polish & UX)
Month 15:    Phase 7 (Monetization)
Month 1-18:  Phase 8 (Infrastructure - Ongoing)
Month 1-18:  Phase 9 (Marketing - Ongoing)
```

### Detailed Timeline

**Month 1-2: Foundation**
- Week 1-2: Azure setup, .NET backend structure
- Week 3-4: Database migration, API endpoints
- Week 5-6: Godot web export, HTTP client
- Week 7-8: Testing, bug fixes, deployment

**Month 3-4: Enhanced Gameplay**
- Week 9-10: Arrays, math library, string functions
- Week 11-12: New cell types implementation
- Week 13-14: Tutorial system redesign
- Week 15-16: Achievement system, daily challenges

**Month 5-7: Competition**
- Week 17-19: Leaderboard system (global & level)
- Week 20-22: Challenge & contest system
- Week 23-25: Rating & ranking system
- Week 26-28: Tournament infrastructure

**Month 8-10: Community**
- Week 29-31: Level sharing & discovery
- Week 32-34: Comments, ratings, moderation
- Week 35-37: Follow system, activity feed
- Week 38-40: User profiles, stats dashboard

**Month 11-12: Education**
- Week 41-43: Concept library, interactive explanations
- Week 44-45: Adaptive difficulty system
- Week 46-47: Video tutorials, documentation
- Week 48: Learning path visualizations

**Month 13-14: Polish**
- Week 49-50: Animations, particle effects
- Week 51-52: Sound effects, music
- Week 53-54: Internationalization (5+ languages)
- Week 55-56: Accessibility features

**Month 15: Monetization**
- Week 57-58: Premium membership system
- Week 59: Virtual currency & shop
- Week 60: Ad integration (non-intrusive)

**Ongoing: Infrastructure & Marketing**
- Continuous deployment improvements
- Monitoring and performance optimization
- Content marketing (blogs, videos, social media)
- Community management and events


---

## 📊 Success Metrics & KPIs

### User Acquisition
- **Target**: 10,000 users in first 6 months
- **Metrics**:
  - Daily active users (DAU)
  - Monthly active users (MAU)
  - DAU/MAU ratio (stickiness)
  - Registration conversion rate

### Engagement
- **Target**: 40%+ DAU/MAU ratio
- **Metrics**:
  - Average session duration (target: 20+ minutes)
  - Levels completed per user (target: 10+ per month)
  - Return rate (7-day, 30-day)
  - Features usage rate

### Monetization
- **Target**: $5,000 MRR by month 12
- **Metrics**:
  - Premium conversion rate (target: 5%)
  - Average revenue per user (ARPU)
  - Lifetime value (LTV)
  - Churn rate (target: <5% monthly)

### Community
- **Target**: 1,000+ community-created levels by month 6
- **Metrics**:
  - Levels created per user
  - Levels played ratio
  - Comments per level
  - Follow network density

### Education
- **Target**: 70%+ tutorial completion rate
- **Metrics**:
  - Tutorial completion rate
  - Concept mastery rate
  - Average stars per level
  - Time to complete learning path


---

## ⚠️ Risks & Mitigation

### Technical Risks

**1. Scalability Issues**
- **Risk**: Backend can't handle traffic spikes
- **Mitigation**: 
  - Load testing before launch
  - Auto-scaling on Azure
  - Redis caching for hot data
  - CDN for static assets

**2. Web Export Performance**
- **Risk**: Godot HTML5 export runs slowly
- **Mitigation**:
  - Optimize assets and code
  - Progressive enhancement
  - Provide desktop downloads
  - Monitor Web Vitals

**3. Security Vulnerabilities**
- **Risk**: SQL injection, XSS, authentication bypass
- **Mitigation**:
  - Regular security audits
  - Penetration testing
  - OWASP best practices
  - Dependency updates

### Business Risks

**1. Low User Retention**
- **Risk**: Users try once and don't return
- **Mitigation**:
  - Compelling onboarding
  - Daily challenges
  - Social features
  - Email re-engagement campaigns

**2. Insufficient Monetization**
- **Risk**: Can't sustain hosting costs
- **Mitigation**:
  - Multiple revenue streams
  - Cost optimization
  - Gradual scaling
  - Community donations option

**3. Competition**
- **Risk**: Similar platforms steal market share
- **Mitigation**:
  - Unique positioning (visual + social)
  - Community-first approach
  - Rapid feature development
  - Strong brand identity

### Legal Risks

**1. Copyright Infringement**
- **Risk**: User-generated content violates copyrights
- **Mitigation**:
  - Terms of service
  - DMCA takedown process
  - Content moderation tools
  - Report system

**2. Privacy Compliance**
- **Risk**: GDPR, CCPA violations
- **Mitigation**:
  - Privacy policy
  - Data export/deletion tools
  - Consent management
  - Regular compliance audits


---

## �� Team & Resources Needed

### Core Team (Minimum Viable)

**1. Full-Stack Developer** (Lead)
- .NET backend development
- Godot engine integration
- DevOps & deployment
- **Commitment**: Full-time
- **Skills**: C#, GDScript, SQL, Azure

**2. Frontend/Game Developer**
- Godot UI/UX
- Game mechanics
- Animation & polish
- **Commitment**: Full-time
- **Skills**: GDScript, UI design, animation

**3. Part-Time Roles**:
- **Designer** (20 hrs/week): UI/UX, graphics, branding
- **Content Creator** (10 hrs/week): Tutorials, documentation, videos
- **Community Manager** (10 hrs/week): Discord, social media, moderation

### Extended Team (After Launch)

**4. Backend Developer**
- Scale backend infrastructure
- Optimize performance
- New API features

**5. Marketing Manager**
- Growth strategies
- Partnerships
- Content marketing

**6. Level Designer**
- Create official levels
- Curate community levels
- Design challenges

### Budget Estimate

**Development Phase (Months 1-12)**:
- 2 Full-time developers: $120,000 - $180,000/year
- Part-time roles: $30,000 - $50,000/year
- Infrastructure (Azure): $200 - $500/month
- Tools & licenses: $2,000/year
- **Total Year 1**: $150,000 - $235,000

**Post-Launch (Months 13-24)**:
- Team expansion: +$50,000 - $100,000/year
- Marketing budget: $20,000 - $50,000/year
- Infrastructure scaling: $1,000 - $3,000/month
- **Total Year 2**: $220,000 - $385,000

### Tools & Services

**Development**:
- Visual Studio / Rider
- Godot Engine
- GitHub (version control)
- Azure DevOps (project management)

**Infrastructure**:
- Azure (hosting)
- Cloudflare (CDN, DDoS protection)
- Stripe (payments)
- SendGrid (emails)

**Monitoring**:
- Application Insights
- Google Analytics
- Sentry (error tracking)
- Hotjar (user behavior)

**Marketing**:
- Mailchimp (email marketing)
- Buffer (social media)
- Discord (community)
- YouTube, TikTok (content)


---

## 🎯 Final Recommendations

### Priorities for Success

**1. Start Small, Iterate Fast**
- Launch with core features (Phase 1-2)
- Get real user feedback early
- Iterate based on data, not assumptions

**2. Community First**
- Build Discord community from day 1
- Feature user-created content prominently
- Listen to feedback, implement quickly

**3. Quality Over Quantity**
- 10 amazing levels > 100 mediocre levels
- Polish matters for retention
- Test thoroughly before each release

**4. Data-Driven Decisions**
- Instrument everything
- A/B test major changes
- Monitor metrics weekly
- Pivot when data shows problems

### Development Approach

**Agile Methodology**:
- 2-week sprints
- Daily standups (even for small team)
- Retrospectives after each phase
- Continuous deployment

**Testing Strategy**:
- Unit tests for backend (80%+ coverage)
- Integration tests for API
- Manual testing for Godot game logic
- Beta testing with 50-100 users before launch

**Documentation**:
- API documentation (Swagger)
- Code comments for complex logic
- User documentation (wiki style)
- Video tutorials for features

### Launch Checklist

**Pre-Launch**:
- [ ] All Phase 1 features complete
- [ ] 10+ tutorial levels
- [ ] 20+ practice levels
- [ ] Backend deployed and tested
- [ ] Security audit passed
- [ ] Privacy policy & ToS published
- [ ] Landing page live
- [ ] Discord server setup
- [ ] Social media accounts created
- [ ] Beta testers recruited

**Launch Day**:
- [ ] Product Hunt post
- [ ] Reddit posts (3-5 subreddits)
- [ ] Email beta testers
- [ ] Social media announcements
- [ ] Press release sent
- [ ] Monitoring dashboards watching

**Post-Launch** (First Week):
- [ ] Daily bug fixes
- [ ] User support response <24hrs
- [ ] Collect feedback systematically
- [ ] Monitor server performance
- [ ] Publish first blog post
- [ ] Schedule first community event

### Long-Term Vision

**Year 1**: Establish as **best visual programming game**
- 10,000+ registered users
- 500+ community levels
- Positive word-of-mouth
- Core feature complete

**Year 2**: Become **go-to platform for learning coding**
- 50,000+ registered users
- Partnerships with schools
- Mobile app launch
- Profitable with premium

**Year 3+**: **Global programming education platform**
- 500,000+ users worldwide
- Multiple programming languages supported
- Enterprise/education licensing
- API for integration with other platforms

---

## 📝 Conclusion

LediBug has incredible potential to **revolutionize how people learn programming** by combining:
- ✅ **Visual gameplay** (immediate feedback, satisfying progression)
- ✅ **Real programming concepts** (not just pseudo-code, actual skills)
- ✅ **Social features** (community, competition, sharing)
- ✅ **Modern tech stack** (.NET backend, scalable architecture)

### Key Success Factors

1. **Execute Phase 1-2 flawlessly** - The foundation must be solid
2. **Build community early** - Users are your best marketers
3. **Iterate based on feedback** - Stay flexible, pivot when needed
4. **Focus on retention** - MAU > total registered users
5. **Monetize responsibly** - Premium should feel worth it, ads non-intrusive

### Next Immediate Steps

1. **This Week**: Complete Phase 1.1-1.3 (Azure setup, DB migration)
2. **Next Week**: Phase 1.4-1.5 (API endpoints, testing)
3. **Week 3**: Phase 1.6-1.8 (Godot integration)
4. **Week 4**: Deploy to staging, invite 10 alpha testers
5. **Month 2**: Complete Phase 1, start Phase 2

---

**Good luck building LediBug! 🐞✨**

If you execute this plan systematically, track metrics, listen to users, and iterate quickly, LediBug will succeed.

**Remember**: Every successful platform started small. Focus on delighting your first 100 users, and they'll bring the next 10,000.

---

*Roadmap Version 2.0 | Last Updated: February 2026*
*For questions or updates, contact the development team.*
