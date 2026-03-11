import os
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SECRET_KEY") or os.getenv("SUPABASE_SERVICE_ROLE_KEY")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def test_upsert():
    test_id = "test_event_123"
    
    # 1. Ensure event exists with some community_hype
    print("Step 1: Creating/Resetting test event...")
    supabase.table("hype_grid_events").upsert({
        "event_id": test_id,
        "title": "Initial Title",
        "sport": "Football",
        "start_time": "2026-03-20T10:00:00Z",
        "community_hype": 50
    }).execute()
    
    # 2. Perform upsert without community_hype but WITH data_source
    print("Step 2: Performing upsert without community_hype but WITH data_source...")
    supabase.table("hype_grid_events").upsert({
        "event_id": test_id,
        "title": "Updated Title",
        "sport": "Football",
        "data_source": "Test Source",
        "start_time": "2026-03-20T10:00:00Z"
    }).execute()
    
    # 3. Check if community_hype is still 50 and data_source is 'Test Source'
    print("Step 3: Checking results...")
    res = supabase.table("hype_grid_events").select("community_hype", "title", "data_source").eq("event_id", test_id).execute()
    if res.data:
        data = res.data[0]
        print(f"Result: title='{data['title']}', community_hype={data.get('community_hype')}, data_source={data.get('data_source')}")
        if data.get('community_hype') == 50 and data.get('data_source') == "Test Source":
            print("✅ community_hype was PRESERVED and data_source was UPDATED.")
        else:
            print("❌ community_hype was OVERWRITTEN or RESET.")
    else:
        print("❌ Could not find test event.")

if __name__ == "__main__":
    test_upsert()
