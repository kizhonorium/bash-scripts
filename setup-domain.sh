#!/bin/bash

set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <domain> <port>"
    exit 1
fi

DOMAIN="$1"
PORT="$2"

echo "=== Installing Nginx and Certbot ==="
sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx

echo "=== Creating Nginx config for $DOMAIN ==="
NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"

sudo tee "$NGINX_CONF" > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:$PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

echo "=== Enabling site and testing config ==="
sudo ln -sf "$NGINX_CONF" "/etc/nginx/sites-enabled/$DOMAIN"
sudo nginx -t
sudo systemctl reload nginx

echo "=== Obtaining SSL certificate for $DOMAIN ==="
sudo certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m admin@$DOMAIN

echo "=== Setting up automatic certificate renewal ==="
( sudo crontab -l 2>/dev/null; echo "0 0 * * * /usr/bin/certbot renew --quiet" ) | sudo crontab -

echo "=== Done! Testing proxy ==="
curl -v "http://localhost:$PORT" || echo "Warning: backend at port $PORT not reachable."
