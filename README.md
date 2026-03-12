# 🚀 HypeGrid

A "Mind Refresh" app that shows a curated, high-hype list of Football, F1, MotoGP, and eSports events for the next 7 days, localized for broadcasting in Indonesia (WIB).

---

## 🏗️ Tech Stack

| Layer | Technology |
| :--- | :--- |
| **Framework** | Flutter (Dart) |
| **State Management** | flutter_bloc |
| **Database** | Supabase (PostgreSQL) |
| **Automation** | GitHub Actions |
| **Backend** | Python (Sync Engine) |
| **Styling** | Custom AppTheme (Outfit & Inter fonts) |

---

## 📊 Data Architecture & Getters

HypeGrid uses a "Sport-First" modular sync engine located in `scripts/sync_hype.py`.

| Engine | Source | Target Sports |
| :--- | :--- | :--- |
| **ESPN Radar** | Site API | Football, NBA, MMA, F1 |
| **PandaScore** | Official API | LoL, CS:GO, Dota 2, Valorant |
| **Liquipedia** | Web Scraper | MLBB (using Playwright) |
| **ICS Feeds** | iCal | MotoGP |

### 🧠 Hype Engine Logic
Events are scored from 0-100 based on:
- **Importance**: Race vs Practice, Finals vs Regular Season.
- **Competitiveness**: Matchup quality (+20 for Top 5 teams).
- **Context**: "Derby" (+10) or "Season Opener" (+15).

---

## 🛠️ Local Development Setup

### 1. Environment Configuration
The project supports separate Development and Production environments via multi-env files:
- `.env.dev` - Used for local development (default).
- `.env.prod` - Used for production builds.

Create your environment files:
```bash
cp .env.example .env.dev
cp .env.example .env.prod
```
Fill in the respective keys for each environment.

### 2. Database (Supabase)
Run the SQL setup from `supabase_setup_guide.md` in your Supabase SQL Editor. This includes:
- Creating `public.hype_grid_events` table.
- Creating the `increment_community_hype` RPC function.

### 3. Sync Script (Python)
Run the sync script for a specific environment using the `APP_ENV` variable:
```bash
pip install -r scripts/requirements.txt
playwright install chromium

# Development sync
APP_ENV=dev python3 scripts/sync_hype.py

# Production sync
APP_ENV=prod python3 scripts/sync_hype.py
```

### 4. Flutter App
Run the app using environment-specific entry points:

**Development:**
```bash
flutter run -t lib/main_dev.dart
```

**Production:**
```bash
flutter run -t lib/main_prod.dart
```

---

## 🚀 GitHub Actions
The project uses separate workflows for each flavor:

- **Sync - Production**: Runs automatically every day at 05:00 AM WIB.
- **Sync - Development**: Manual trigger only (via the GitHub Actions tab).

### Required Secrets
Ensure you have the following Secrets in your Repository:

**Production:**
- `SUPABASE_URL`
- `SUPABASE_SECRET_KEY`
- `PANDASCORE_API_KEY`

**Development (Optional if different):**
- `DEV_SUPABASE_URL`
- `DEV_SUPABASE_SECRET_KEY`

---

## 🎨 Design System
- **Background**: `#0D0D0D`
- **Primary**: `#E94560` (Vibrant Red)
- **Typography**: Outfit (Headings), Inter (Body)
- **Aesthetic**: Cyber-Premium Dark Mode
