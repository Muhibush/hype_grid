#!/bin/bash

# Exit on any error
set -e

ENV=$1

if [ "$ENV" != "dev" ] && [ "$ENV" != "prod" ]; then
  echo "Usage: ./scripts/run.sh [dev|prod]"
  echo "Defaulting to 'dev'..."
  ENV="dev"
fi

echo "🚀 Running in $ENV mode..."

# Run the app with the APP_ENV flag
flutter run --dart-define=APP_ENV=$ENV
