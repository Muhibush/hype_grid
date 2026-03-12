import os
import json
from datetime import datetime, timedelta, timezone
from supabase import create_client, Client
from dotenv import load_dotenv
import firebase_admin
from firebase_admin import credentials, messaging

# Load environment variables
env = os.getenv("APP_ENV", "dev")
env_file = f".env.{env}"
if os.path.exists(env_file):
    print(f"Loading environment from {env_file}")
    load_dotenv(env_file)
else:
    print(f"Loading default environment from .env")
    load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SECRET_KEY") or os.getenv("SUPABASE_SERVICE_ROLE_KEY")
FIREBASE_SERVICE_ACCOUNT_PATH = os.getenv("FIREBASE_SERVICE_ACCOUNT_JSON", "scripts/firebase-service-account.json")

if not SUPABASE_URL or not SUPABASE_KEY:
    print("❌ Error: SUPABASE_URL or SUPABASE_SECRET_KEY/SERVICE_ROLE_KEY missing.")
    exit(1)

# Initialize Supabase
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# Initialize Firebase Admin
def init_firebase():
    if not os.path.exists(FIREBASE_SERVICE_ACCOUNT_PATH):
        print(f"⚠️ Warning: Firebase service account file not found at {FIREBASE_SERVICE_ACCOUNT_PATH}")
        print("   Please provide the JSON file to enable notifications.")
        return False
    
    try:
        cred = credentials.Certificate(FIREBASE_SERVICE_ACCOUNT_PATH)
        firebase_admin.initialize_app(cred)
        return True
    except Exception as e:
        print(f"❌ Error initializing Firebase: {e}")
        return False

def get_high_hype_events():
    """Fetch events starting in the next 24 hours with hype_score >= 80"""
    now = datetime.now(timezone.utc)
    tomorrow = now + timedelta(hours=24)
    
    try:
        response = supabase.table("hype_grid_events") \
            .select("*") \
            .gte("hype_score", 80) \
            .gte("start_time", now.isoformat()) \
            .lte("start_time", tomorrow.isoformat()) \
            .order("hype_score", desc=True) \
            .execute()
        
        return response.data
    except Exception as e:
        print(f"❌ Error fetching high hype events: {e}")
        return []

def send_notification(event):
    """Send FCM notification for a specific event to the high_hype topic"""
    title = f"🔥 HIGH HYPE: {event['title']}"
    body = f"Starts at {event['start_time']} WIB on {event['broadcast_channel']}. Don't miss out!"
    
    # Topic name matching Flutter subscription
    topic = "high_hype"
    
    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        data={
            "event_id": str(event['event_id']),
            "click_action": "FLUTTER_NOTIFICATION_CLICK", # For some older plugins, but we'll handle it in Dart anyway
        },
        topic=topic,
    )

    try:
        response = messaging.send(message)
        print(f"✅ Successfully sent notification: {response}")
    except Exception as e:
        print(f"❌ Error sending notification for event {event['event_id']}: {e}")

def main():
    if not init_firebase():
        return

    events = get_high_hype_events()
    if not events:
        print("ℹ️ No high hype events found for the next 24 hours.")
        return

    print(f"🚀 Found {len(events)} high hype events. Sending summary notification for the top one...")
    
    # Send only for the top event to avoid spamming
    # We could also aggregate them if needed
    top_event = events[0]
    send_notification(top_event)

if __name__ == "__main__":
    main()
