# HypeGrid

A "Mind Refresh" app that shows curated high-hype sports events.

## 🛠️ Local Development Setup

### 1. Sync Script (Python)
To run the data synchronization script locally:

1.  **Environment Variables**: Create a `.env` file in the root directory and copy the contents from `.env.example`. Fill in your Supabase and API-Football credentials.
    ```bash
    cp .env.example .env
    ```
2.  **Install Dependencies**:
    ```bash
    pip3 install -r scripts/requirements.txt
    ```
3.  **Run the Script**:
    ```bash
    python3 scripts/sync_hype.py
    ```

### 2. Flutter App
Standard Flutter setup:
```bash
flutter pub get
flutter run
```

---

## 🚀 GitHub Actions
The project is configured to sync automatically via GitHub Actions. See [github_actions_setup_guide.md](.agent/artifacts/github_actions_setup_guide.md) for detailed instructions on setting up repository secrets.
