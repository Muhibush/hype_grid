# 🚀 Project: HypeGrid (MVP)

**Objective:** A "Mind Refresh" app that shows a curated, high-hype list of Football, F1, and MotoGP events for the next 7 days, localized for broadcasting in Indonesia (WIB).

## 🛠️ 1. The Tech Stack (100% Free Tier)

* **Database:** **Supabase** (PostgreSQL) – Handles user data and the event "Grid."
* **Backend/Automation:** **GitHub Actions** (Python) – Runs the "Global Sync" once daily.
* **Frontend:** **Flutter** – For the cross-platform list UI.
* **APIs:**
* **Football:** API-Football (RapidAPI).
* **F1:** OpenF1 (Free/No Key).
* **MotoGP:** TheSportsDB (API Key: 123).

---

## 📊 2. Database Schema (Supabase)

Create a table named `hype_grid_events` with the following columns:

* `event_id` (Text, Primary Key, Unique) – Format: `sport_apiID` (e.g., `f1_2026_01`).
* `title` (Text) – e.g., "Liverpool vs Arsenal" or "Australian GP - Qualifying."
* `sport` (Text) – "Football", "F1", or "MotoGP".
* `start_time` (Timestamp with Timezone).
* `duration_minutes` (Integer) – Standardize: Football (110), F1 Race (120), F1 Qualy (60).
* `hype_score` (Integer) – 0 to 100.
* `broadcast_channel` (Text) – e.g., "Vidio", "beIN Sports", "Trans7".
* `metadata` (JSONB) – For team logos, league names, or driver standings.

---

## ⚙️ 3. The Backend: "The Global Sync" (Python)

**Frequency:** Once daily at 05:00 AM WIB (22:00 UTC).
**Script Logic:**

1. **Date Window:** Set `range_start` = Yesterday; `range_end` = Today + 6 Days.
2. **Fetch & Clean:** Pull data from all 3 APIs.
3. **Hype Calculation:** Apply the Hype Engine logic (see Section 4).
4. **Indonesian Localization:** Map leagues to local broadcasters (e.g., Premier League ➡️ Vidio).
5. **Upsert:** Use the `event_id` to update existing records or insert new ones.
6. **Prune:** Delete any records where `start_time` < (Current Time - 7 Days).

---

## 🧠 4. The Hype Engine Logic

Use this formula to calculate the `hype_score`:

Hype = (Importance x 0.5) + (Competitiveness x 0.3) + (Context x 0.2)

* **Importance:** * F1/MotoGP Race = 90; Qualifying = 60; Practice = 30.
* Football: Champions League = 90; Premier League = 80; Friendly = 20.


* **Competitiveness:** * If Team A Rank and Team B Rank are both in Top 5 = +20.
* **Context:** * If "Derby" in title = +10.
* If "Season Opener" = +15.

---

## 📱 5. Frontend Features (The UI)

* **The "Mind Refresh" Slider:** A filter at the top. Users select "I have 1 hour" or "I have 2+ hours." The list filters by `duration_minutes`.
* **The Grid List:** Sorted by `start_time`.
* **Visuals:** High `hype_score` events (80+) get a "🔥" icon and a bold border.
* **Broadcast Info:** Large, clear text showing the channel name.


* **Timezone Auto-Detection:** Display all times in the user's local phone time.

---

## 🛠️ 6. Implementation Steps (Order of Operations)

### Phase 1: Database Setup

1. Initialize a Supabase project.
2. Run the SQL to create the `hype_grid_events` table with an "Upsert" policy.

### Phase 2: The Sync Script (Python)

1. Create `sync_hype.py`.
2. Integrate the **API-Football** and **OpenF1** fetchers.
3. Write the `calculate_hype()` function.
4. Test the script locally to ensure it pushes data to Supabase.

### Phase 3: Automation

1. Set up a GitHub Repository.
2. Add `SUPABASE_URL`, `SUPABASE_KEY`, and `API_KEY` to GitHub Secrets.
3. Create `.github/workflows/sync.yml` with the cron schedule `0 22 * * *`.

### Phase 4: The App UI

1. Connect Flutter to the Supabase client.
2. Build the "Hype Cards" displaying: `Title`, `Start Time`, `Hype Score`, and `Broadcast`.
3. Add the time-duration filter.
