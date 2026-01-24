#!/bin/bash
set -e

# Generator wrapper
# Usage: ./scripts/generate-client.sh

echo "Generating API Client..."
cd packages/api_client
npm install
npm run generate
echo "Done."
