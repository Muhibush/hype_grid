#!/bin/bash

# Exit on any error
set -e

ENV=$1

if [ "$ENV" != "dev" ] && [ "$ENV" != "prod" ]; then
  echo "Usage: ./scripts/deploy.sh [dev|prod]"
  exit 1
fi

PROJECT_ID=""
if [ "$ENV" == "dev" ]; then
  PROJECT_ID="hypegrid-dev"
else
  PROJECT_ID="hypegrid-prod"
fi

echo "🚀 Deploying to $ENV environment (Project: $PROJECT_ID)..."

# Build the web app with the APP_ENV flag
echo "📦 Building Flutter Web..."
flutter build web --dart-define=APP_ENV=$ENV

# Deploy to Firebase Hosting
echo "☁️ Deploying to Firebase Hosting..."
firebase deploy --only hosting -P $PROJECT_ID

echo "✅ Successfully deployed to $ENV!"
