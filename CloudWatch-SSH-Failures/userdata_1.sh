#!/bin/bash

sudo snap install amazon-ssm-agent --classic
sudo snap start amazon-ssm-agent

curl -sL https://gitlab.com/-/snippets/2565205/raw/main/install_docker.sh | bash
sleep 1

sudo apt install -y nginx
sudo systemctl enable nginx;sudo systemctl start nginx

# Create and Start Docker Compose
sudo mkdir -p /opt/app
cat << EOF > /opt/app/docker-compose.yml
version: "3"
services:
  whoami:
    image: traefik/whoami:v1.10
    restart: always
    environment:
      - WHOAMI_PORT_NUMBER=8080
    ports:
    # incorrcect port mapping
    # It has to be '80:8080'
      - 80:9090
EOF

# Start docker-compose
sudo docker-compose -f /opt/app/docker-compose.yml up -d