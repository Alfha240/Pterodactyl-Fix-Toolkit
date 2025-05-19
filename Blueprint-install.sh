#!/bin/bash

# Blueprint Installer Script for Pterodactyl Panel
# Always uses /var/www/pterodactyl as the panel path

set -e

echo "Starting Blueprint installation..."

echo "Current directory:"
pwd

# Update and setup Node.js 20.x repository
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# Update package list and install nodejs
apt-get update
apt-get install -y nodejs zip unzip git curl wget



# Go to fixed panel path
cd /var/www/pterodactyl || { echo "Error: /var/www/pterodactyl not found!"; exit 1; }

echo "Changed directory to $(pwd)"

# Install dependencies with yarn
npm install -g yarn

yarn

# Download latest Blueprint release zip
latest_release_url=$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4)
echo "Downloading Blueprint from $latest_release_url"
wget "$latest_release_url" -O release.zip

# Unzip release
unzip -o release.zip

# Make blueprint.sh executable
chmod +x blueprint.sh

# Run blueprint.sh to complete install
bash blueprint.sh

echo "✅ Blueprint installation completed!"
