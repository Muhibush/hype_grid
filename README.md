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
Create a `.env` file in the root directory:
```bash
cp .env.example .env
```
Fill in your `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SECRET_KEY`.

### 2. Database (Supabase)
Run the SQL setup from `supabase_setup_guide.md` in your Supabase SQL Editor. This includes:
- Creating `public.hype_grid_events` table.
- Creating the `increment_community_hype` RPC function.

### 3. Sync Script (Python)
```bash
pip install -r scripts/requirements.txt
playwright install chromium
python3 scripts/sync_hype.py
```

### 4. Flutter App
```bash
flutter pub get
flutter run
```

---

## 🚀 GitHub Actions
The project is configured to sync automatically via GitHub Actions daily at 05:00 AM WIB.
Ensure you have the following Secrets in your Repository:
- `SUPABASE_URL`
- `SUPABASE_SECRET_KEY` (Service Role Key)
- `PANDASCORE_API_KEY`

---

## 🎨 Design System
- **Background**: `#0D0D0D`
- **Primary**: `#E94560` (Vibrant Red)
- **Typography**: Outfit (Headings), Inter (Body)
- **Aesthetic**: Cyber-Premium Dark Mode
