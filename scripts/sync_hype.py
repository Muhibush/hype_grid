import os
import requests
import re
import json
from datetime import datetime, timedelta, timezone
from supabase import create_client, Client
from dotenv import load_dotenv
from icalendar import Calendar
from playwright.sync_api import sync_playwright

# Load environment variables
load_dotenv()

# Configuration
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SECRET_KEY") or os.getenv("SUPABASE_SERVICE_ROLE_KEY")
PANDASCORE_API_KEY = os.getenv("PANDASCORE_API_KEY")

if not SUPABASE_URL or not SUPABASE_KEY:
    print("❌ Error: SUPABASE_URL or SUPABASE_SECRET_KEY/SERVICE_ROLE_KEY missing.")
    exit(1)

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# Broadcaster Mapping (WIB / Local Indonesia)
BROADCAST_MAP = {
    "Football": "Vidio / beIN Sports",
    "NBA": "Vidio",
    "Basketball": "Vidio",
    "F1": "beIN Sports",
    "MotoGP": "Trans7 / SPOTV",
    "MMA": "Mola TV / Vidio",
    "UFC": "Mola TV / Vidio",
    "LoL": "YouTube / Twitch",
    "CSGO": "YouTube / Twitch",
    "Dota 2": "YouTube / Twitch",
    "Valorant": "YouTube / Twitch",
    "MLBB": "YouTube / TikTok / Vidio"
}

# --- HYPE ENGINE ---

def calculate_hype_score(sport, is_featured=True, tier=None):
    """
    Standardized Hype Score Calculation
    """
    base_scores = {
        "Football": 80,
        "NBA": 85,
        "Basketball": 70,
        "F1": 90,
        "MotoGP": 90,
        "MMA": 85,
        "MLBB": 85,
        "LoL": 75,
        "CSGO": 75,
        "Dota 2": 75,
        "Valorant": 80
    }
    
    score = base_scores.get(sport, 60)
    
    if tier == "S": score += 15
    elif tier == "A": score += 10
    
    if is_featured: score += 5
    
    return min(100, score)

# --- DATA ENGINES (Fetchers) ---

def engine_espn(sport_slug, league_slug, display_name):
    """
    Data Engine for ESPN Scoreboard Radar
    """
    url = f"https://site.api.espn.com/apis/site/v2/sports/{sport_slug}/{league_slug}/scoreboard"
    try:
        response = requests.get(url, timeout=10)
        data = response.json()
        events = []
        for event in data.get("events", []):
            try:
                competitions = event.get("competitions", [{}])[0]
                competitors = competitions.get("competitors", [])
                home_team = next((c for c in competitors if c.get("homeAway") == "home"), {})
                away_team = next((c for c in competitors if c.get("homeAway") == "away"), {})
                
                events.append({
                    "event_id": f"espn_{event['id']}",
                    "title": event.get("name", "").replace(" at ", " vs "),
                    "sport": display_name,
                    "data_source": "ESPN",
                    "start_time": event.get("date"),
                    "duration_minutes": 150 if display_name == "NBA" else 110,
                    "hype_score": calculate_hype_score(display_name),
                    "broadcast_channel": BROADCAST_MAP.get(display_name, "Local TV"),
                    "metadata": {
                        "league": event.get("season", {}).get("slug", league_slug).upper(),
                        "home_logo": home_team.get("team", {}).get("logo"),
                        "away_logo": away_team.get("team", {}).get("logo")
                    }
                })
            except Exception: continue
        return events
    except Exception as e:
        print(f"   ⚠️ ESPN Engine Error ({display_name}): {e}")
        return []

def engine_pandascore(game_slug, display_name):
    """
    Data Engine for PandaScore API
    """
    if not PANDASCORE_API_KEY:
        return []
    
    url = f"https://api.pandascore.co/{game_slug}/matches/upcoming"
    headers = {"Authorization": f"Bearer {PANDASCORE_API_KEY}"}
    try:
        response = requests.get(url, headers=headers, timeout=10)
        data = response.json()
        events = []
        for match in data:
            try:
                name = match.get("name")
                start_time = match.get("begin_at")
                if not start_time: continue
                
                opponents = match.get("opponents", [])
                home = opponents[0]["opponent"] if len(opponents) > 0 else {"name": "TBA", "image_url": None}
                away = opponents[1]["opponent"] if len(opponents) > 1 else {"name": "TBA", "image_url": None}
                
                events.append({
                    "event_id": f"ps_{match['id']}",
                    "title": name,
                    "sport": display_name,
                    "data_source": "PandaScore",
                    "start_time": start_time,
                    "duration_minutes": 120,
                    "hype_score": calculate_hype_score(display_name),
                    "broadcast_channel": BROADCAST_MAP.get(display_name, "Twitch / YouTube"),
                    "metadata": {
                        "league": match.get("league", {}).get("name"),
                        "home_logo": home.get("image_url"),
                        "away_logo": away.get("image_url")
                    }
                })
            except Exception: continue
        return events
    except Exception as e:
        print(f"   ⚠️ PandaScore Engine Error ({display_name}): {e}")
        return []

def engine_liquipedia(wiki_name, display_name):
    """
    Unified Scraper Engine for Liquipedia:Matches (Captures all tiers via Playwright + Local Storage filtering)
    """
    print(f"🔍 [Liquipedia] Starting Playwright engine for {wiki_name}...")
    url = f"https://liquipedia.net/{wiki_name}/Liquipedia:Matches"
    events = []
    
    # User-defined Local Storage filter injection for Liquipedia:Matches
    ls_buttons = {
        "filterbuttons-liquipediatier": {
            "filterStates": { "1": True, "2": True, "3": True, "4": True, "5": True, "-1": True },
            "curated": False
        },
        "tournaments-list-dropdown-liquipediatiertype": {
            "filterStates": { "dropdown-liquipediatiertype": True },
            "curated": False
        },
        "filterbuttons-liquipediatiertype": {
            "filterStates": { "monthly": True, "weekly": True, "qualifier": True, "misc": True, "showmatch": True, "national": True },
            "curated": False
        }
    }
    
    try:
        with sync_playwright() as p:
            # Configure browser
            browser = p.chromium.launch(headless=True)
            context = browser.new_context(
                user_agent='HypeGridSync/1.0 (contact@hypegrid.app)'
            )
            
            page = context.new_page()
            
            # Inject local storage exactly on the site origin before load
            page.add_init_script(f"""
                window.localStorage.setItem('LiquipediaFilterButtonsV2-mobilelegends-Liquipedia:Matches', JSON.stringify({json.dumps(ls_buttons)}));
                window.localStorage.setItem('LiquipediaSwitchButtons-mobilelegends-Liquipedia:Matches_countdown', 'false');
                window.localStorage.setItem('LiquipediaSwitchButtons-mobilelegends-Liquipedia:Matches_matchFiler', 'upcoming');
            """)
            
            # Navigate to page
            page.goto(url, wait_until="networkidle", timeout=30000)
            
            # Wait for match ticker to be rendered
            page.wait_for_selector(".new-match-style", timeout=15000)
            
            # Get only visible matches (those not filtered out by display:none)
            match_boxes = page.locator('.new-match-style').all()
            print(f"   📊 [Log] Found {len(match_boxes)} total 'new-match-style' containers.")
            
            for box in match_boxes:
                # Playwright specific: Check if the element is visible
                style = box.evaluate("el => window.getComputedStyle(el).display")
                if style == "none":
                    continue # Filtered out by User's Local Storage settings
                
                infos = box.locator('.match-info').all()
                for info in infos:
                    try:
                        # Ensure this individual match info is also visible
                        if info.evaluate("el => window.getComputedStyle(el).display") == "none":
                            continue
                            
                        # Teams
                        team_names = []
                        team_divs = info.locator('.block-team').all()
                        if not team_divs:
                            team_divs = info.locator('.team-template-text').all()
                            
                        if len(team_divs) < 2: continue
                        
                        for t in team_divs:
                            name_span = t.locator('.name').all()
                            if name_span:
                                team_names.append(name_span[0].inner_text().strip())
                            else:
                                team_names.append(t.inner_text().strip())
                                
                        if len(team_names) < 2: continue
                        
                        title = f"{team_names[0]} vs {team_names[1]}"
                        
                        # Time
                        time_span = info.locator('.timer-object').all()
                        if not time_span: continue
                        
                        start_timestamp = time_span[0].get_attribute('data-timestamp')
                        if not start_timestamp: continue
                        
                        # Exclude finished officially
                        score_holder = info.locator('.match-info-header-scoreholder-upper').all()
                        if score_holder and score_holder[0].inner_text().strip() != 'vs':
                            continue
                            
                        now_ts = int(datetime.now(timezone.utc).timestamp())
                        if int(start_timestamp) < now_ts - 3600:
                            continue
                            
                        start_time = datetime.fromtimestamp(int(start_timestamp), tz=timezone.utc).isoformat()
                        
                        # League
                        league_div = info.locator('.match-info-tournament').all()
                        league_name = league_div[0].inner_text().strip() if league_div else "MLBB Tournament"
                        
                        event_id = f"lq_{wiki_name}_{start_timestamp}_{team_names[0][:3]}"
                        
                        events.append({
                            "event_id": event_id,
                            "title": title,
                            "sport": display_name,
                            "data_source": "Liquipedia",
                            "start_time": start_time,
                            "duration_minutes": 90,
                            "hype_score": calculate_hype_score(display_name, is_featured=True),
                            "broadcast_channel": BROADCAST_MAP.get(display_name, "YouTube / TikTok / Vidio"),
                            "metadata": {
                                "league": league_name
                            }
                        })
                    except Exception: continue
                    
            browser.close()
            
        print(f"   ✅ [Log] Successfully parsed {len(events)} visible upcoming matches.")
        return events
    except Exception as e:
        print(f"   ⚠️ Liquipedia Scraper Error: {e}")
        return []

def engine_ics(url, display_name):
    """
    Parser Engine for ICS/iCal feeds (MotoGP Focus)
    """
    try:
        response = requests.get(url, timeout=15)
        gcal = Calendar.from_ical(response.content)
        events = []
        for component in gcal.walk():
            if component.name == "VEVENT":
                try:
                    title = str(component.get('summary'))
                    start_dt = component.get('dtstart').dt
                    
                    # Convert to UTC ISO format
                    if isinstance(start_dt, datetime):
                        if start_dt.tzinfo is None:
                            start_dt = start_dt.replace(tzinfo=timezone.utc)
                        start_time = start_dt.isoformat()
                    else: # date object
                        start_time = datetime.combine(start_dt, datetime.min.time(), tzinfo=timezone.utc).isoformat()

                    event_id = f"ics_{display_name.lower()}_{hash(title + start_time)}"
                    
                    events.append({
                        "event_id": event_id,
                        "title": title,
                        "sport": display_name,
                        "data_source": "ICS Feed",
                        "start_time": start_time,
                        "duration_minutes": 120,
                        "hype_score": calculate_hype_score(display_name),
                        "broadcast_channel": BROADCAST_MAP.get(display_name, "Local TV"),
                        "metadata": {}
                    })
                except Exception: continue
        return events
    except Exception as e:
        print(f"   ⚠️ ICS Engine Error: {e}")
        return []

# --- SPORT GETTERS (The Modular "Sport-First" Wrappers) ---

def sync_football(): return engine_espn("soccer", "all", "Football")
def sync_nba(): return engine_espn("basketball", "nba", "NBA")
def sync_mma(): return engine_espn("mma", "ufc", "MMA")
def sync_f1(): return engine_espn("racing", "f1", "F1")

def sync_lol(): return engine_pandascore("lol", "LoL")
def sync_csgo(): return engine_pandascore("csgo", "CSGO")
def sync_dota2(): return engine_pandascore("dota2", "Dota 2")
def sync_valorant(): return engine_pandascore("valorant", "Valorant")

def sync_mlbb(): return engine_liquipedia("mobilelegends", "MLBB")
def sync_motogp(): return engine_ics("https://nixxo.github.io/calendars/motogp/2026/MotoGP_qualy-and-races_2026_calendar.ics", "MotoGP")

# --- ORCHESTRATOR ---

def sync_all():
    print(f"🚀 Starting Sport-First Hub Sync... (Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')})")
    
    all_events = []
    
    # Switch on/off sports easily here
    sport_syncs = [
        ("Football", sync_football),
        ("NBA", sync_nba),
        ("MMA", sync_mma),
        ("F1", sync_f1),
        ("LoL", sync_lol),
        ("CSGO", sync_csgo),
        ("Dota 2", sync_dota2),
        ("Valorant", sync_valorant),
        ("MLBB", sync_mlbb),
        ("MotoGP", sync_motogp),
    ]
    
    stats = {}
    for name, sync_func in sport_syncs:
        try:
            print(f"📡 Syncing {name}...")
            events = sync_func()
            all_events.extend(events)
            stats[name] = len(events)
            print(f"   ✅ Done. Found {len(events)} events.")
        except Exception as e:
            print(f"   ❌ Critical error syncing {name}: {e}")
            stats[name] = "FAILED"

    print(f"\n📊 Aggregate Stats: {len(all_events)} Total Events Found.")
    
    # 📤 Upsert to Supabase
    print("\n📤 Processing Upserts...")
    
    # Track which IDs exist to distinguish between New and Updated
    try:
        existing_res = supabase.table("hype_grid_events").select("event_id").execute()
        existing_ids = {row["event_id"] for row in existing_res.data}
    except Exception as e:
        print(f"   ⚠️ Could not fetch existing IDs: {e}")
        existing_ids = set()

    new_count = 0
    updated_count = 0
    fail_count = 0
    
    for event in all_events:
        event_id = event.get("event_id")
        try:
            # Data Readiness Check: ensure we have a valid title and start_time
            if not event.get("title") or not event.get("start_time"):
                print(f"   ⚠️ Skipping event {event_id} due to missing detail data.")
                continue

            # Supabase handles upsert by event_id. 
            # community_hype is NOT in the payload, so it will be preserved by Supabase.
            supabase.table("hype_grid_events").upsert(event).execute()
            
            if event_id in existing_ids:
                updated_count += 1
            else:
                new_count += 1
        except Exception as e:
            print(f"   ❌ Upsert Error ({event_id}): {e}")
            fail_count += 1
            
    # 🧹 Prune old (older than 7 days)
    try:
        cutoff = (datetime.now(timezone.utc) - timedelta(days=7)).isoformat()
        supabase.table("hype_grid_events").delete().lt("start_time", cutoff).execute()
        print("🧹 Cleanup: Old events pruned.")
    except Exception: pass

    # Summary
    print("\n" + "="*40)
    print("🏁 FINAL HUB SYNC SUMMARY")
    print("="*40)
    for sport, val in stats.items():
        print(f"{sport.ljust(15)}: {val}")
    print("-" * 40)
    print(f"New Events      : {new_count}")
    print(f"Updated Events  : {updated_count}")
    print(f"Upserted Failed : {fail_count}")
    print("="*40 + "\n")

if __name__ == "__main__":
    sync_all()
