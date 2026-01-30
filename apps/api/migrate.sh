#!/bin/bash
set -e

# Load environment variables if .env.production exists (for local testing of logic)
if [ -f .env.production ]; then
    export $(cat .env.production | xargs)
fi

echo "Detailed usage: ./migrate.sh"
echo "Running alembic upgrade head..."

# Ensure dependencies are installed (optional if running in container)
# pip install -r requirements.txt

alembic upgrade head

echo "Migration completed successfully."
