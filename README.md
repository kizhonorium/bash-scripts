# Bash Scripts

## Setup a Domain with Nginx & SSL

This script installs **Nginx** and **Certbot**, configures a reverse proxy for a given domain and port, and automatically sets up HTTPS with free Let's Encrypt SSL.

### Requirements
- Ubuntu/Debian-based system
- `sudo` privileges
- A domain name pointing to your server's IP

### Usage

1. **Clone this repository**  
   ```bash
   git clone https://github.com/kizhonorium/bash-scripts.git
   cd bash-scripts
   ```

2. **Make the script executable**  
   ```bash
   chmod +x setup-domain.sh
   ```

3. **Run the script**  
   ```bash
   ./setup-domain.sh <your-domain> <port>
   ```
   Example:
   ```bash
   ./setup-domain.sh example.com 9000
   ```

### Notes
- Ensure your domain's DNS A record points to your server before running.
- The script appends a certbot renewal job to root’s crontab:  
  ```
  0 0 * * * /usr/bin/certbot renew --quiet
  ```
- To manually renew certificates:
  ```bash
  sudo certbot renew
  ```
