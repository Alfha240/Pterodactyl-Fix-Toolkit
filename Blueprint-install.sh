#!/bin/bash

# Automatic Pterodactyl Dependency Installer
# Author: ChatGPT
# Description: Installs Node.js, Yarn, and updates system packages.

curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Step 2: Install Yarn
echo "🔹 Installing Yarn..."
npm i -g yarn
apt-get update
apt-get install -y nodejs


echo "✅ Pterodactyl Dependencies Installed Successfully!"
cd /var/www/pterodactyl
npm i -g yarn
yarn
apt update && apt upgrade -y
apt install -y zip unzip git curl wget

# now install blueprint zip
wget "$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4)" -O release.zip
mv release.zip /var/www/pterodactyl/release.zip
unzip release.zip
chmod +x blueprint.sh
bash blueprint.sh
