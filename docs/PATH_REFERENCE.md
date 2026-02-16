# Script Path Reference

**Last Updated**: February 2026

This document provides a quick reference for all script paths after the project reorganization.

---

## 🗺️ Path Mappings

### Core Module
```
OLD: res://scripts/player.gd
NEW: res://scripts/core/player.gd

OLD: res://scripts/grid_manager.gd
NEW: res://scripts/core/grid_manager.gd

OLD: res://scripts/cell_types.gd
NEW: res://scripts/core/cell_types.gd
```

### Language Module
```
OLD: res://scripts/lexer.gd
NEW: res://scripts/language/lexer.gd

OLD: res://scripts/parser.gd
NEW: res://scripts/language/parser.gd

OLD: res://scripts/interpreter.gd
NEW: res://scripts/language/interpreter.gd

OLD: res://scripts/ast_nodes.gd
NEW: res://scripts/language/ast_nodes.gd

OLD: res://scripts/token.gd
NEW: res://scripts/language/token.gd

OLD: res://scripts/code_executor.gd
NEW: res://scripts/language/code_executor.gd
```

### Debug Module
```
OLD: res://scripts/debug_manager.gd
NEW: res://scripts/debug/debug_manager.gd

OLD: res://scripts/watch_manager.gd
NEW: res://scripts/debug/watch_manager.gd
```

### UI Module
```
OLD: res://scripts/main.gd
NEW: res://scripts/ui/main.gd

OLD: res://scripts/main_menu.gd
NEW: res://scripts/ui/main_menu.gd

OLD: res://scripts/level_select.gd
NEW: res://scripts/ui/level_select.gd

OLD: res://scripts/level_editor.gd
NEW: res://scripts/ui/level_editor.gd

OLD: res://scripts/custom_levels.gd
NEW: res://scripts/ui/custom_levels.gd
```

### Levels Module
```
OLD: res://scripts/level_definitions.gd
NEW: res://scripts/levels/level_definitions.gd

OLD: res://scripts/simple_grid.gd
NEW: res://scripts/levels/simple_grid.gd
```

---

## 📁 Scene Path Mappings

```
OLD: res://scenes/main_menu.tscn
NEW: res://scenes/ui/main_menu.tscn

OLD: res://scenes/level_select.tscn
NEW: res://scenes/ui/level_select.tscn

OLD: res://scenes/custom_levels.tscn
NEW: res://scenes/ui/custom_levels.tscn

OLD: res://scenes/level_editor.tscn
NEW: res://scenes/ui/level_editor.tscn

OLD: res://scenes/main.tscn
NEW: res://scenes/game/main.tscn

OLD: res://scenes/player.tscn
NEW: res://scenes/game/player.tscn
```

---

## 🔧 Quick Fix Guide

If you add a new script and need to reference it:

### In Scene Files (.tscn)
Use the full modular path:
```gdscript
[ext_resource type="Script" path="res://scripts/MODULE/filename.gd" id="1"]
```

### In Script Files (.gd)
Use the full modular path:
```gdscript
# Preload (compile-time)
const MyScript = preload("res://scripts/MODULE/filename.gd")

# Load (runtime)
var my_script = load("res://scripts/MODULE/filename.gd")
```

### Module Names
- `core/` - Game systems (player, grid, cells)
- `language/` - Programming language components
- `debug/` - Debug tools
- `ui/` - User interface controllers
- `levels/` - Level data and definitions
- `tests/` - Unit tests

---

## ⚠️ Common Mistakes

❌ **Don't use:**
```gdscript
preload("res://scripts/player.gd")  # Missing module folder
```

✅ **Use:**
```gdscript
preload("res://scripts/core/player.gd")  # Correct modular path
```

---

## 🔄 Auto-Fix Script Paths

If you accidentally create references with old paths, run this command in PowerShell from project root:

```powershell
# Check for old paths
Get-ChildItem -Recurse -Include *.tscn,*.gd | Select-String 'res://scripts/[^/]+\.gd"' | Select-Object Path, LineNumber

# This will show any files with direct script/ references (missing module folder)
```

---

*This reference was created during the February 2026 project reorganization.*
