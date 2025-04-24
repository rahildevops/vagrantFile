# Create a shutdown service file
sudo tee /etc/systemd/system/docker-shutdown.service > /dev/null <<'EOF'
[Unit]
Description=Stop Docker containers on shutdown
DefaultDependencies=no
Before=shutdown.target reboot.target halt.target

[Service]
Type=oneshot
ExecStart=/bin/true
ExecStop=/usr/bin/docker stop $(/usr/bin/docker ps -aq)
TimeoutStopSec=30
KillMode=none

[Install]
WantedBy=halt.target reboot.target shutdown.target
EOF

# Enable the service
sudo systemctl enable docker-shutdown.service