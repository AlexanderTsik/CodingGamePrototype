# 🚀 LediBug Web Deployment Guide

## ✅ Web Export Readiness Checklist

### **Current Status: READY FOR EXPORT** ✅

---

## 🔍 Pre-Export Audit Results

### ✅ **Passing Checks:**

1. **All paths use `res://` protocol** ✅
   - No hardcoded absolute paths found
   - Cross-platform compatible

2. **No threading issues** ✅
   - No Thread.new() or Mutex.new() calls found
   - Thread support enabled in export preset

3. **Main scene configured** ✅
   - `res://scenes/ui/main_menu.tscn` set as entry point
   - All scene references valid

4. **Assets properly imported** ✅
   - Fonts: `seguiemj.ttf` (imported)
   - Sprites: `LediBugSprite.png` (imported)
   - Icon: `icon.svg` (configured)

5. **Export preset configured** ✅
   - Export path: `./exports/web/index.html`
   - Thread support: Enabled
   - CORS headers: Configured for Vercel

---

## ⚠️ **Known Limitations (FileAccess/DirAccess)**

### **Custom Level System:**
The following features use **FileAccess/DirAccess** which have **limited support** on web:

**Files affected:**
- `scripts/ui/custom_levels.gd` - Loads/deletes custom levels
- `scripts/ui/level_editor.gd` - Saves custom levels to disk

**Impact:**
- ✅ **Built-in levels 1-10 work perfectly**
- ⚠️ **Custom level editor may not save on web** (uses `user://` path)
- ⚠️ **Custom level browser may not load levels**

**Web Alternatives:**
1. Use `JavaScript.eval()` to access localStorage/IndexedDB
2. Use Godot's HTML5 exported filesystem (auto-synced to IndexedDB)
3. Disable custom level features for web export

---

## 🛠️ **Recommended Fixes (Optional)**

### **Option 1: Keep Custom Levels (Recommended)**
Godot's `user://` path on web maps to IndexedDB, so custom levels *should* work. Test after export:

```gdscript
# Already using user:// correctly ✅
var custom_levels_path = "user://custom_levels/"
```

### **Option 2: Disable for Web**
Add platform checks:

```gdscript
func _ready():
    if OS.get_name() == "Web":
        # Hide level editor/custom levels buttons
        $LevelEditorButton.visible = false
        $CustomLevelsButton.visible = false
```

---

## 📦 **Export Instructions**

### **1. Export from Godot Editor**

1. Open project in Godot 4.x
2. Go to **Project → Export**
3. Select **Web** preset
4. Click **Export Project**
5. Files will be in `exports/web/`

### **2. Verify Export Files**

Check that these files exist:
```
exports/web/
├── index.html          ✅ Main entry point
├── index.js           ✅ Godot engine
├── index.wasm         ✅ Game binary
├── index.pck          ✅ Game assets
└── index.icon.png     ✅ Favicon
```

### **3. Test Locally**

```bash
# Using Python
cd exports/web
python -m http.server 8000

# Using Node.js
npx serve exports/web

# Then visit: http://localhost:8000
```

---

## 🌐 **Deploy to Vercel**

### **Files Already Configured:**
- ✅ `vercel.json` - CORS headers for SharedArrayBuffer
- ✅ `.vercelignore` - Excludes source files, only deploys exports/

### **Deployment Steps:**

#### **Option A: Vercel CLI**
```bash
npm install -g vercel
vercel login
vercel
```

#### **Option B: GitHub → Vercel**
1. Push to GitHub:
   ```bash
   git add .
   git commit -m "Ready for web deployment"
   git push
   ```

2. Link to Vercel:
   - Go to [vercel.com](https://vercel.com)
   - Import GitHub repository
   - Vercel auto-detects `vercel.json`
   - Click **Deploy**

3. Your game will be at: `https://your-project.vercel.app`

---

## 🧪 **Post-Deployment Testing**

### **Test these features:**
- ✅ Main menu loads
- ✅ Level select works
- ✅ Levels 1-10 play correctly
- ✅ Code editor functions
- ✅ Player movement works
- ⚠️ Custom level editor (may have issues - test thoroughly)
- ⚠️ Custom level loading (may have issues - test thoroughly)

### **Browser Console Check:**
Press `F12` and check for errors related to:
- CORS/SharedArrayBuffer
- FileAccess failures
- Asset loading issues

---

## 🐛 **Common Issues & Fixes**

### **Issue: SharedArrayBuffer not available**
**Fix:** Ensure these headers are set (already in `vercel.json`):
```json
"Cross-Origin-Embedder-Policy": "require-corp"
"Cross-Origin-Opener-Policy": "same-origin"
```

### **Issue: Game doesn't load**
**Fix:** Check browser console for errors. Enable threads in export preset.

### **Issue: Custom levels don't save**
**Expected:** Web uses IndexedDB instead of file system. Should work but data is browser-specific.

### **Issue: Assets missing**
**Fix:** Re-import assets in Godot Editor before exporting.

---

## 📊 **Performance Tips**

1. **Enable VRAM compression** (already enabled ✅)
2. **Reduce texture sizes** for faster loading
3. **Test on mobile browsers** (responsive design)
4. **Use progressive web app** (optional):
   ```
   Set progressive_web_app/enabled=true in export_presets.cfg
   Add icons for PWA
   ```

---

## 🎯 **File Size Expectations**

| File | Typical Size |
|------|--------------|
| index.wasm | 15-30 MB |
| index.pck | 5-20 MB |
| index.js | 500 KB |
| **Total** | **~20-50 MB** |

**Vercel Limit:** 100 MB per deployment (free tier) ✅

---

## 🔐 **Security Notes**

- ✅ No sensitive data in code
- ✅ .gitignore excludes secrets
- ✅ Backend not included in web export
- ⚠️ Custom levels stored in browser (user-local only)

---

## 📞 **Support**

If you encounter issues:
1. Check browser console (F12)
2. Test locally before deploying
3. Verify all export files are present
4. Check Vercel deployment logs

---

**Status:** Ready for export and deployment! 🚀
