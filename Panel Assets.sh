#!/bin/bash

# Automatic Pterodactyl Dependency Installer
# Author: ChatGPT
# Description: Installs Node.js, Yarn, and updates system packages.

echo "🚀 Starting Pterodactyl Dependency Installation..."

# Step 1: Install Node.js 16.x
echo "🔹 Installing Node.js 16.x..."
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs

# Step 2: Install Yarn
echo "🔹 Installing Yarn..."
npm i -g yarn

# Step 3: Install Dependencies in Pterodactyl Directory
echo "🔹 Installing Pterodactyl dependencies..."
cd /var/www/pterodactyl || exit
yarn install --network-timeout 600000

# Step 4: Update & Upgrade System
echo "🔹 Updating and upgrading system packages..."
apt update && apt upgrade -y

echo "✅ Pterodactyl Dependencies Installed Successfully!"
