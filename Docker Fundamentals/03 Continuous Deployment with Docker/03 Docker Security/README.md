# 🔒 Docker Security

This section covers essential Docker security practices to protect your containers and host system. You’ll learn how to manage secrets securely, run containers as non-root users, scan images for vulnerabilities, and secure the Docker daemon. These practices are critical for running Docker in production environments safely. Let’s dive into each topic with a practical example using a Node.js app!

## 🏗️ Sub-Topics

### 1. Managing Secrets in Docker
Secrets (e.g., API keys, database passwords) should not be hardcoded in Dockerfiles or environment variables, as they can be exposed. Docker provides a secrets management feature to handle sensitive data securely.

#### Hands-On Example: Using Docker Secrets with Docker Compose
We’ll use Docker Compose to manage secrets for a Node.js app.

##### Supporting Files
**app.js**
```javascript
const express = require('express');
const fs = require('fs');
const app = express();

app.get('/', (req, res) => {
    const secret = fs.readFileSync('/run/secrets/app_secret', 'utf8');
    res.send(`Hello from the Docker Security Demo! Secret: ${secret}`);
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
```

**package.json**
```json
{
    "name": "docker-security-demo",
    "version": "1.0.0",
    "main": "app.js",
    "dependencies": {
        "express": "^4.18.2"
    }
}
```

**Dockerfile**
```dockerfile
# Dockerfile for a Node.js app with security best practices
FROM node:18

# Create a non-root user
RUN useradd -m appuser

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

EXPOSE 3000

CMD ["node", "app.js"]
```

**secrets.txt**
```
my-secret-password
```

**docker-compose.yml**
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    secrets:
      - app_secret
    networks:
      - app-network

secrets:
  app_secret:
    file: ./secrets.txt

networks:
  app-network:
    driver: bridge
```

#### Steps to Run with Secrets
1. Start the services:
   ```bash
   docker-compose -f docker-compose.yml up -d
   ```
   Output:
   ```
   Creating network "docker-security-demo_app-network" with driver "bridge"
   Creating docker-security-demo_app_1 ... done
   ```
2. Access the app at `http://localhost:3000`. You should see:
   ```
   Hello from the Docker Security Demo! Secret: my-secret-password
   ```
3. Verify the secret is mounted:
   ```bash
   docker exec -it docker-security-demo_app_1 cat /run/secrets/app_secret
   ```
   Output:
   ```
   my-secret-password
   ```
4. Stop the services:
   ```bash
   docker-compose -f docker-compose.yml down
   ```

#### Notes on Secrets
- Secrets are mounted as files in `/run/secrets/` inside the container.
- Docker Compose secrets are suitable for local development. In production (e.g., Docker Swarm), use `docker secret` commands for better security.

### 2. Running Containers as Non-Root
Running containers as the root user can be dangerous—if the container is compromised, an attacker could gain root access to the host. Running as a non-root user minimizes this risk.

#### Using the Example Above
The `Dockerfile` includes steps to create and use a non-root user:
- `RUN useradd -m appuser`: Creates a non-root user named `appuser`.
- `RUN chown -R appuser:appuser /app`: Changes ownership of the app directory to `appuser`.
- `USER appuser`: Switches to the `appuser` for running the container.

#### Verify Non-Root User
1. Start the services (if not already running):
   ```bash
   docker-compose -f docker-compose.yml up -d
   ```
2. Check the user inside the container:
   ```bash
   docker exec -it docker-security-demo_app_1 whoami
   ```
   Output:
   ```
   appuser
   ```
3. Try to perform a root-level operation:
   ```bash
   docker exec -it docker-security-demo_app_1 apt-get update
   ```
   Output:
   ```
   E: Could not open lock file /var/lib/apt/lists/lock - open (13: Permission denied)
   ```
   - The operation fails because `appuser` lacks root privileges, confirming the container is running securely.

### 3. Scanning Images for Vulnerabilities
Docker images can contain vulnerabilities in their base images or dependencies. Scanning images helps identify and fix these issues before deployment.

#### Example: Scanning with Docker Scout
We’ll use Docker Scout, a built-in tool for vulnerability scanning, and also create a script for automation.

**scan-image.sh**
```bash
#!/bin/bash

# Build the image
docker build -t docker-security-demo:latest .

# Scan the image with Docker Scout
docker scout cves docker-security-demo:latest
```

#### Steps to Scan the Image
1. Make the script executable:
   ```bash
   chmod +x scan-image.sh
   ```
2. Run the script:
   ```bash
   ./scan-image.sh
   ```
   Example Output:
   ```
   ✓ Image built: docker-security-demo:latest
   ✓ Scanned image: docker-security-demo:latest
   10 vulnerabilities found (2 critical, 3 high, 5 medium)
   - CVE-2023-1234 (Critical): Update base image to node:18.20.4
   - CVE-2023-5678 (High): Patch express to 4.18.3
   ...
   ```
   - The output will vary depending on the image and its dependencies.
3. Fix vulnerabilities:
   - Update the base image in the `Dockerfile` (e.g., `FROM node:18.20.4` if available).
   - Update dependencies in `package.json` (e.g., `"express": "^4.18.3"`).
   - Rebuild and rescan the image.

#### Alternative: Using Trivy
You can also use Trivy, an open-source vulnerability scanner:
1. Install Trivy:
   ```bash
   curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
   ```
2. Scan the image:
   ```bash
   trivy image docker-security-demo:latest
   ```

### 4. Securing Docker Daemon
The Docker daemon runs with root privileges and listens on a socket that, if unsecured, can allow unauthorized access to the host. Securing the daemon involves restricting access and enabling secure communication.

#### Example: Securing the Docker Daemon
**secure-daemon.sh**
```bash
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
```

#### Steps to Secure the Daemon
1. Make the script executable:
   ```bash
   chmod +x secure-daemon.sh
   ```
2. Run the script (requires root privileges):
   ```bash
   sudo ./secure-daemon.sh
   ```
   Output:
   ```
   Securing Docker socket...
   Configuring Docker daemon for TLS...
   Restarting Docker daemon...
   Verifying Docker daemon configuration...
   ... (Docker info output)
   ```
3. Test the client connection with TLS:
   ```bash
   docker --tls --tlscert=/etc/docker/tls/client-cert.pem --tlskey=/etc/docker/tls/client-key.pem -H tcp://127.0.0.1:2376 info
   ```
   - This confirms the Docker daemon is secured with TLS.

#### Additional Security Tips
- Limit the `docker` group to trusted users (`sudo usermod -aG docker <user>`).
- Use a firewall to restrict access to the Docker daemon port (`2376`).
- Enable user namespaces to isolate containers further (`dockerd --userns-remap=default`).

## 🚀 Getting Started

To secure your Docker setup:
1. Add `app.js`, `package.json`, `Dockerfile`, `docker-compose.yml`, `secrets.txt`, `scan-image.sh`, and `secure-daemon.sh` to your project.
2. Use `docker-compose.yml` to manage secrets securely and test the app at `http://localhost:3000`.
3. Verify the container runs as a non-root user using the `Dockerfile` configuration.
4. Scan the image for vulnerabilities using `scan-image.sh` and fix any issues.
5. Secure the Docker daemon with `secure-daemon.sh` and test the TLS configuration.
6. Monitor the setup to ensure it meets security best practices.

These security practices will help you protect your Dockerized applications in production. Move on to the next sections of the roadmap to explore advanced Docker concepts, Kubernetes, and more!