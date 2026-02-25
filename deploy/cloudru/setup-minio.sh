#!/bin/bash
# Run this script ON THE SERVER (82.202.159.64) to open MinIO port

echo "=== Opening MinIO port 9000 ==="

# 1. Check if MinIO is running
echo "[1/4] Checking MinIO status..."
if systemctl is-active --quiet minio 2>/dev/null; then
    echo "MinIO is running"
else
    echo "MinIO is NOT running. Starting..."
    sudo systemctl start minio || {
        echo "MinIO service not found. Installing..."
        # Download and install MinIO
        wget https://dl.min.io/server/minio/release/linux-amd64/minio -O /tmp/minio
        chmod +x /tmp/minio
        sudo mv /tmp/minio /usr/local/bin/
        
        # Create MinIO service
        sudo tee /etc/systemd/system/minio.service > /dev/null << 'EOF'
[Unit]
Description=MinIO Object Storage
After=network.target

[Service]
Type=simple
User=user1
Group=user1
Environment="MINIO_ROOT_USER=minioadmin"
Environment="MINIO_ROOT_PASSWORD=minioadmin"
ExecStart=/usr/local/bin/minio server /data/minio --console-address ":9001"
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
        
        # Create data directory
        sudo mkdir -p /data/minio
        sudo chown user1:user1 /data/minio
        
        # Start MinIO
        sudo systemctl daemon-reload
        sudo systemctl enable minio
        sudo systemctl start minio
    }
fi

# 2. Open port in UFW firewall
echo "[2/4] Opening port 9000 in UFW..."
sudo ufw allow 9000/tcp
sudo ufw allow 9001/tcp
sudo ufw status | grep 9000

# 3. Check if iptables is blocking
echo "[3/4] Checking iptables..."
sudo iptables -L INPUT -n | grep 9000 || {
    echo "Adding iptables rule..."
    sudo iptables -A INPUT -p tcp --dport 9000 -j ACCEPT
    sudo iptables -A INPUT -p tcp --dport 9001 -j ACCEPT
}

# 4. Create bucket if not exists
echo "[4/4] Creating audiogid bucket..."
# Wait for MinIO to start
sleep 3

# Install mc (MinIO client) if not present
if ! command -v mc &> /dev/null; then
    wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /tmp/mc
    chmod +x /tmp/mc
    sudo mv /tmp/mc /usr/local/bin/
fi

# Configure mc
mc alias set local http://localhost:9000 minioadmin minioadmin 2>/dev/null || true

# Create bucket
mc mb local/audiogid 2>/dev/null || echo "Bucket already exists"

# Set bucket policy to public
mc anonymous set download local/audiogid

echo ""
echo "=== MinIO Setup Complete ==="
echo "API endpoint: http://localhost:9000"
echo "Console: http://82.202.159.64:9001"
echo "Public URL: http://82.202.159.64:9000/audiogid"
echo ""
echo "Test from outside:"
echo "  curl http://82.202.159.64:9000/minio/health/live"
