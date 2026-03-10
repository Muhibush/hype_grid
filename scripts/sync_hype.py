import os
import requests
from datetime import datetime, timedelta, timezone
from supabase import create_client, Client
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configuration
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

if not SUPABASE_URL or not SUPABASE_KEY:
    print("❌ Error: SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY missing.")
    exit(1)

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# Broadcaster Mapping (WIB / Local Indonesia)
BROADCAST_MAP = {
    "Football": "Vidio / beIN Sports",
    "NBA": "Vidio",
    "Basketball": "Vidio",
    "F1": "beIN Sports",
    "MMA": "Mola TV / Vidio",
    "UFC": "Mola TV / Vidio"
}

def calculate_hype_score(sport, is_featured=True):
    """
    Simultated Hype logic for ESPN events. 
    """
    base_scores = {
        "Football": 80,
        "NBA": 85,
        "Basketball": 70,
        "F1": 90,
        "MMA": 85
    }
    score = base_scores.get(sport, 60)
    if is_featured:
        score += 10
    return min(100, score)

def fetch_espn_events(sport_slug, league_slug, display_name):
    """
    Primary fetcher using ESPN's hidden API scoreboard.
    """
    print(f"📡 Fetching {display_name} from ESPN Radar...")
    url = f"https://site.api.espn.com/apis/site/v2/sports/{sport_slug}/{league_slug}/scoreboard"
    
    try:
        response = requests.get(url, timeout=15)
        data = response.json()
        events = []
        
        for event in data.get("events", []):
            try:
                # Basic Info
                event_id = f"espn_{event['id']}"
                title = event.get("name")
                start_time = event.get("date")
                
                # Metadata extraction
                competitions = event.get("competitions", [{}])[0]
                competitors = competitions.get("competitors", [])
                home_team = next((c for c in competitors if c.get("homeAway") == "home"), {})
                away_team = next((c for c in competitors if c.get("homeAway") == "away"), {})
                
                # Standardize Sport Name
                sport_name = display_name
                
                # Duration logic (Standardized)
                duration = 110 # Default
                if sport_name == "NBA": duration = 150
                elif sport_name == "F1": duration = 120
                
                events.append({
                    "event_id": event_id,
                    "title": title,
                    "sport": sport_name,
                    "start_time": start_time,
                    "duration_minutes": duration,
                    "hype_score": calculate_hype_score(sport_name),
                    "broadcast_channel": BROADCAST_MAP.get(sport_name, "Local TV"),
                    "metadata": {
                        "league": event.get("season", {}).get("slug", league_slug).upper(),
                        "home_logo": home_team.get("team", {}).get("logo"),
                        "away_logo": away_team.get("team", {}).get("logo"),
                        "short_name": event.get("shortName"),
                        "source": "ESPN"
                    }
                })
            except Exception as e:
                print(f"   ⚠️ Skipping event in {display_name}: {e}")
                continue
                
        print(f"   ✅ Found {len(events)} {display_name} events.")
        return events
        
    except Exception as e:
        print(f"❌ Error fetching {display_name} from ESPN: {e}")
        return []

def sync_all():
    print("🚀 Starting Exclusive ESPN Global Sync...")
    all_events = []
    stats = {}
    
    # Define ESPN Targets (Removed MotoGP and Volleyball)
    targets = [
        ("soccer", "all", "Football"),
        ("basketball", "nba", "NBA"),
        ("basketball", "mens-college-basketball", "Basketball"),
        ("racing", "f1", "F1"),
        ("mma", "ufc", "MMA"),
    ]
    
    for sport_slug, league_slug, display_name in targets:
        events = fetch_espn_events(sport_slug, league_slug, display_name)
        all_events.extend(events)
        stats[display_name] = stats.get(display_name, 0) + len(events)
    
    print(f"\n📊 Total Unique Events Collected: {len(all_events)}")
    
    # Upsert to Supabase
    success_count = 0
    fail_count = 0
    print("📤 Upserting to Supabase...")
    for event in all_events:
        try:
            supabase.table("hype_grid_events").upsert(event).execute()
            success_count += 1
        except Exception as e:
            if fail_count < 5:
                print(f"   ❌ Failed to upsert event {event['event_id']}: {e}")
            fail_count += 1
            
    # Prune old events
    try:
        cutoff = (datetime.now(timezone.utc) - timedelta(days=7)).isoformat()
        supabase.table("hype_grid_events").delete().lt("start_time", cutoff).execute()
        print("🧹 Old events pruned.")
    except Exception as e:
        print(f"❌ Pruning failed: {e}")

    # Final Summary Report
    print("\n" + "="*40)
    print("🏁 ESPN EXCLUSIVE SYNC COMPLETE")
    print("="*40)
    for sport, count in stats.items():
        print(f"{sport.ljust(15)}: {count} events")
    print("-" * 40)
    print(f"Total Upserted  : {success_count}")
    print(f"Total Failed    : {fail_count}")
    print("="*40 + "\n")

if __name__ == "__main__":
    sync_all()
