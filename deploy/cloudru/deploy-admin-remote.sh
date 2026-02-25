#!/bin/bash
set -e

ADMIN_DIR=/opt/audiogid/admin

# Backup current version
if [ -d "$ADMIN_DIR/.next" ]; then
    sudo mv $ADMIN_DIR/.next $ADMIN_DIR/.next.backup 2>/dev/null || true
fi

# Extract new version
sudo mkdir -p $ADMIN_DIR
cd $ADMIN_DIR
sudo tar -xzf /tmp/admin-build.tar.gz
sudo chown -R user1:user1 $ADMIN_DIR

# Install production dependencies
cd $ADMIN_DIR
pnpm install --prod

# Restart service
sudo systemctl restart audiogid-admin || echo "Service not configured yet"

# Cleanup
rm /tmp/admin-build.tar.gz
sudo rm -rf $ADMIN_DIR/.next.backup 2>/dev/null || true

echo ""
echo "=== Admin deployed successfully ==="
echo "URL: http://82.202.159.64:3080"
