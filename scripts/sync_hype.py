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
FOOTBALL_API_KEY = os.getenv("FOOTBALL_API_KEY")
THE_SPORTS_DB_KEY = "123"  # Free tier key from spec

if not SUPABASE_URL or not SUPABASE_KEY:
    print("❌ Error: SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY missing.")
    exit(1)

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# Broadcaster Mapping
BROADCAST_MAP = {
    "Premier League": "Vidio",
    "Champions League": "Vidio",
    "La Liga": "beIN Sports",
    "Serie A": "beIN Sports",
    "F1": "beIN Sports",
    "MotoGP": "Trans7"
}

def calculate_hype_score(sport, importance_base, team_a_rank=None, team_b_rank=None, is_derby=False, is_opener=False):
    """
    Hype = (Importance x 0.5) + (Competitiveness x 0.3) + (Context x 0.2)
    """
    importance = importance_base * 0.5
    
    competitiveness = 0
    if team_a_rank is not None and team_b_rank is not None:
        if team_a_rank <= 5 and team_b_rank <= 5:
            competitiveness = 20
    competitiveness *= 0.3
    
    context = 0
    if is_derby:
        context += 10
    if is_opener:
        context += 15
    context *= 0.2
    
    return int(importance + competitiveness + context)

def fetch_football_events():
    print("⚽ Fetching Football events...")
    if not FOOTBALL_API_KEY:
        print("⚠️ FOOTBALL_API_KEY not found. Skipping Football.")
        return []
    
    # Range: Yesterday to Today + 6 Days
    date_start = (datetime.now(timezone.utc) - timedelta(days=1)).strftime('%Y-%m-%d')
    date_end = (datetime.now(timezone.utc) + timedelta(days=6)).strftime('%Y-%m-%d')
    
    # Leagues of interest (e.g., PL, CL, etc.)
    # 39 = Premier League, 2 = Champions League
    leagues = [39, 2]
    events = []
    
    for league_id in leagues:
        url = f"https://v3.football.api-sports.io/fixtures?league={league_id}&from={date_start}&to={date_end}"
        headers = {
            "x-apisports-key": FOOTBALL_API_KEY
        }
        
        try:
            response = requests.get(url, headers=headers)
            data = response.json()
            
            for fixture in data.get("response", []):
                league_name = fixture["league"]["name"]
                importance_base = 90 if league_id == 2 else 80
                
                # Simplified rank check for demo (would normally fetch standings)
                hype = calculate_hype_score("Football", importance_base)
                
                event = {
                    "event_id": f"fb_{fixture['fixture']['id']}",
                    "title": f"{fixture['teams']['home']['name']} vs {fixture['teams']['away']['name']}",
                    "sport": "Football",
                    "start_time": fixture["fixture"]["date"],
                    "duration_minutes": 110,
                    "hype_score": hype,
                    "broadcast_channel": BROADCAST_MAP.get(league_name, "Local TV"),
                    "metadata": {
                        "league": league_name,
                        "home_logo": fixture["teams"]["home"]["logo"],
                        "away_logo": fixture["teams"]["away"]["logo"]
                    }
                }
                events.append(event)
        except Exception as e:
            print(f"❌ Error fetching Football league {league_id}: {e}")
            
    return events

def fetch_f1_events():
    print("🏎️ Fetching F1 events...")
    # OpenF1 for schedule
    url = "https://api.openf1.org/v1/sessions"
    # Note: OpenF1 provides historical data mostly, but for MVP we might need a specific season
    # Let's assume we fetch for current year
    year = datetime.now().year
    
    try:
        # In a real scenario, we'd filter for upcoming
        # Mocking for now as OpenF1 sesssions API can be heavy/limited for future
        return []
    except Exception as e:
        print(f"❌ Error fetching F1: {e}")
        return []

def fetch_motogp_events():
    print("🏍️ Fetching MotoGP events...")
    url = f"https://www.thesportsdb.com/api/v1/json/{THE_SPORTS_DB_KEY}/eventsnextleague.php?id=4521"
    
    try:
        response = requests.get(url)
        data = response.json()
        events = []
        
        for e in data.get("events", []):
            hype = calculate_hype_score("MotoGP", 90) # Assume race
            
            event = {
                "event_id": f"moto_{e['idEvent']}",
                "title": e["strEvent"],
                "sport": "MotoGP",
                "start_time": f"{e['dateEvent']}T{e['strTime']}",
                "duration_minutes": 120,
                "hype_score": hype,
                "broadcast_channel": "Trans7",
                "metadata": {
                    "league": "MotoGP",
                    "thumb": e.get("strThumb")
                }
            }
            events.append(event)
        return events
    except Exception as e:
        print(f"❌ Error fetching MotoGP: {e}")
        return []

def sync_all():
    all_events = []
    all_events.extend(fetch_football_events())
    all_events.extend(fetch_f1_events())
    all_events.extend(fetch_motogp_events())
    
    print(f"📊 Found {len(all_events)} total events.")
    
    # Upsert to Supabase
    for event in all_events:
        try:
            supabase.table("hype_grid_events").upsert(event).execute()
        except Exception as e:
            print(f"❌ Failed to upsert event {event['event_id']}: {e}")
            
    # Prune old events
    try:
        cutoff = (datetime.now(timezone.utc) - timedelta(days=7)).isoformat()
        supabase.table("hype_grid_events").delete().lt("start_time", cutoff).execute()
        print("🧹 Old events pruned.")
    except Exception as e:
        print(f"❌ Pruning failed: {e}")

if __name__ == "__main__":
    sync_all()
