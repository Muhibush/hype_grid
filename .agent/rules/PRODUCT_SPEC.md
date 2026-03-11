---
trigger: always_on
---

# 🚀 PRODUCT SPECIFICATION: HypeGrid (MVP)

## **Objective**
A "Mind Refresh" app that shows a curated, high-hype list of Football, F1, Basketball, NBA, and MMA events for the next 7 days, localized for broadcasting in Indonesia (WIB).

---

## 🛠️ 1. Tech Stack (100% Free Tier)

* **Database:** **Supabase** (PostgreSQL) – Handles user data and the event "Grid."
* **Backend/Automation:** **GitHub Actions** (Python) – Runs the "Global Sync" once daily.
* **Frontend:** **Flutter** – For the cross-platform list UI.
* **APIs & Data Engines (Sport-First Modular):**
    *   **ESPN Radar**: Primary for Football, NBA, F1, and MMA.
    *   **PandaScore**: Dedicated for PC Esports (LoL, CS:GO, Dota 2, Valorant).
    *   **Liquipedia (Scraper)**: Specialized for Mobile Legends (MLBB).
    *   **ICS Feeds**: Dedicated for MotoGP (nixxo.github.io).

---

## 📊 2. Database Schema (Supabase)

Table: `hype_grid_events`
* `event_id` (Text, Primary Key, Unique) – Format: `sport_apiID` (e.g., `f1_2026_01`).
* `title` (Text) – e.g., "Liverpool vs Arsenal" or "Australian GP - Qualifying."
* `sport` (Text) – "Football", "F1", "MotoGP", "NBA", or "Volleyball".
* `start_time` (Timestamp with Timezone).
* `duration_minutes` (Integer) – Standardize: Football (110), F1 Race (120), NBA (150), Volleyball (90).
* `hype_score` (Integer) – 0 to 100.
* `broadcast_channel` (Text) – e.g., "Vidio", "beIN Sports", "Trans7".
* `metadata` (JSONB) – For team logos, league names, or driver standings.

---

## ⚙️ 3. Backend: "The Global Sync" (Python)

**Frequency:** Once daily at 05:00 AM WIB (22:00 UTC).
**Script Logic:**
1. **Date Window:** `range_start` = Yesterday; `range_end` = Today + 6 Days.
2. **Fetch & Clean:** Data from API-Football, OpenF1, and TheSportsDB.
3. **Hype Calculation:** Applies Hype Engine logic.
4. **Localization:** Maps leagues to local Indonesian broadcasters (e.g., Premier League ➡️ Vidio).
5. **Upsert:** Updates or inserts records using `event_id`.
6. **Prune:** Deletes records where `start_time` < (Current Time - 7 Days).

---

## 🧠 4. Hype Engine Logic

**Formula:** `Hype = (Importance x 0.5) + (Competitiveness x 0.3) + (Context x 0.2)`

### **Importance:**
* F1/MotoGP: Race = 90; Qualifying = 60; Practice = 30.
* Football: Champions League = 90; Premier League = 80; Friendly = 20.
* NBA: Playoffs = 90; Regular Season = 70.
* Volleyball: Nations League = 80; Domestic League = 60.

### **Competitiveness:**
* Both Team A & B in Top 5 = +20.

### **Context:**
* "Derby" in title = +10.
* "Season Opener" = +15.

---

## 📱 5. Frontend Features (The UI)

* **Mind Refresh Slider:** Filter by `duration_minutes` ("I have 1 hour" vs "I have 2+ hours").
* **The Grid List:** Sorted by `start_time`.
* **Visuals:** High `hype_score` (80+) get "🔥" icon and bold border.
* **Broadcast Info:** Clear display of channel name.
* **Timezone:** Auto-detect and display in local phone time.

---

## 🛠️ 6. Implementation Phases

1. **Phase 1: Database Setup** - Supabase project & `hype_grid_events` table.
2. **Phase 2: Sync Script (Python)** - `sync_hype.py` with fetchers and hype logic.
3. **Phase 3: Automation** - GitHub Actions workflow with cron job.
4. **Phase 4: Flutter App UI** - Connect to Supabase and build Hype Cards with filters.