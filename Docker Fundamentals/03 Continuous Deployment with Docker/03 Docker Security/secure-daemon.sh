#!/bin/bash

# Restrict Docker socket permissions
echo "Securing Docker socket..."
sudo chmod 660 /var/run/docker.sock
sudo chown root:docker /var/run/docker.sock

# Enable Docker daemon TLS
echo "Configuring Docker daemon for TLS..."
sudo mkdir -p /etc/docker/tls

# Generate certificates (for demo purposes; in production, use proper CA certificates)
openssl genrsa -out /etc/docker/tls/server-key.pem 4096
openssl req -new -x509 -days 365 -key /etc/docker/tls/server-key.pem -out /etc/docker/tls/server-cert.pem -subj "/CN=$(hostname)"
openssl genrsa -out /etc/docker/tls/client-key.pem 4096
openssl req -new -x509 -days 365 -key /etc/docker/tls/client-key.pem -out /etc/docker/tls/client-cert.pem -subj "/CN=client"

# Configure Docker daemon to use TLS
sudo bash -c 'cat > /etc/docker/daemon.json <<EOF
{
  "tls": true,
  "tlscert": "/etc/docker/tls/server-cert.pem",
  "tlskey": "/etc/docker/tls/server-key.pem",
  "hosts": ["tcp://0.0.0.0:2376", "unix:///var/run/docker.sock"]
}
EOF'

# Restart Docker daemon
echo "Restarting Docker daemon..."
sudo systemctl restart docker

# Verify Docker daemon is running with TLS
echo "Verifying Docker daemon configuration..."
docker --tls info