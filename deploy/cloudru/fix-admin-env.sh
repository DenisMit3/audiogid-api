#!/bin/bash
# Fix admin panel API URL configuration
# Run on server: ssh user1@82.202.159.64

set -e

ADMIN_DIR=/opt/audiogid/admin

echo "=== Fixing Admin Panel API URL ==="

# Update .env file - API is behind nginx on port 80
cat > $ADMIN_DIR/.env << 'EOF'
NEXT_PUBLIC_API_URL=http://82.202.159.64/v1
BACKEND_URL=http://82.202.159.64/v1
DEPLOY_ENV=production
EOF

echo "Updated $ADMIN_DIR/.env"
cat $ADMIN_DIR/.env

# Restart admin service
echo ""
echo "Restarting admin service..."
sudo systemctl restart audiogid-admin

echo ""
echo "=== Done ==="
echo "Admin panel: http://82.202.159.64:3080"
echo ""
echo "Check status: sudo systemctl status audiogid-admin"
