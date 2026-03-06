---
trigger: always_on
---

# 🚀 UI & Navigation Rules

## 📌 Overview

HypeGrid follows a sleek, immersive navigation pattern. Transition from a high-impact branded `SplashScreen` to a rich `HomeScreen` grid. Navigation should feel snappy and native.

---

## 🛠 1. Navigation Scoping

### Main Entry (Branding)
- `SplashScreen` — The entry point. Handles initialization logic and branding.

### Core Screens (Main Destinations)
- `HomeScreen` — The primary interface showing the grid content.

### Future Scopes
- `DetailScreen` — Likely pushed when a grid item is tapped.
- `SettingsScreen` — For user preferences.

---

## 🏗 2. Header & Navigation Logic

### Main Tabs (Master Pages)
- **Header:** Sticky headers using `SliverAppBar` or a custom `AppBar`.
- **Branding:** Consistent "HYPE GRID" logo positioning.

### Sub-Pages
- **Back Button:** Mandatory back button for any screen that isn't `HomeScreen`. 
- **Transitions:** Use `MaterialPageRoute` for standard platform-specific transitions.

---

## 📐 3. Screen Layout Template

Every main screen should follow this consistent structure:

```dart
class FeatureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(...), // Optional
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(...) or ListView(...),
        ),
      ),
    );
  }
}
```

---

## ⚠️ 4. Enforcement Checklist

- ❌ Never use `push` without a `MaterialPageRoute` or `CupertinoPageRoute`.
- ❌ Never hardcode Padding values in every widget; use a standard layout constant if available.
- ✅ Always use `SafeArea` to avoid overlaps with notch/dynamic island.
- ✅ Always ensure the background color is explicitly set to `AppColors.background` in Scaffolds.
