---
trigger: always_on
---

# 🎨 Design System & UI Components

## 📌 Overview

A premium, high-impact dark-mode design system characterized by vibrant accents (`primary: #E94560`) and deep backgrounds (`#0D0D0D`). The aesthetic is "Cyber-Premium" with sharp typography and subtle gradients.

---

## 🏗 Core UI Configuration

### **1. AppTheme** (`lib/utils/app_theme.dart`)
- **Usage:** Centralized theme provider for the entire MaterialApp.
- **Key Features:** Dark theme base, integrated Google Fonts.

### **2. AppColors** (`lib/utils/app_colors.dart`)
- **Usage:** Static constants for all UI colors.

---

## 🎨 Design Tokens

### Colors
| Token               | Hex / Value | Usage                          |
|----------------------|------------|--------------------------------|
| `background`        | `0xFF0D0D0D` | Main scaffold background      |
| `primary`           | `0xFFE94560` | Action buttons, active states  |
| `surface`           | `0xFF141414` | Card and modal backgrounds     |
| `textPrimary`       | `0xFFFFFFFF` | Main headings and labels       |
| `textSecondary`     | `0xFFA0A0B0` | Descriptions and hints         |

### Typography
- **Headings:** `Outfit` (Bold/SemiBold) - High impact, modern.
- **Body:** `Inter` - High readability.
- **Rules:** 
    - Display Large: 28px, Bold (Outfit)
    - Title Large: 20px, SemiBold (Outfit)
    - Body Medium: 14px (Inter)

### Spacing & Borders
- **Border Radius:** Generally `24.0` for cards and bottom sheets.
- **Dividers:** `0xFF222222` thickness: 1.0.

---

## ⚠️ Implementation Guidelines

1. **Token Consistency:** Always use `AppColors` constants. 
2. **Dark Mode First:** The app is exclusively dark mode; ensure all new components maintain contrast against `#0D0D0D`.
3. **Typography:** Use `Theme.of(context).textTheme` to ensure font families and colors are applied correctly.
4. **Hype Aesthetic:** Use emojis and bold italicized "Outfit" text for branding elements to match the "Hype" vibe.
