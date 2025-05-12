#!/bin/bash

# Define variables
PANEL_DIR="/var/www/pterodactyl"
PANEL_VERSION=$(curl -s https://api.github.com/repos/pterodactyl/panel/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
TEMP_DIR="/tmp/pterodactyl_reinstall"

# Stop panel services
echo "Stopping Pterodactyl services..."
systemctl stop pteroq.service
systemctl stop pterodactyl.service

# Backup configuration files
echo "Backing up configuration files..."
mkdir -p "$TEMP_DIR/backup"
cp "$PANEL_DIR/.env" "$TEMP_DIR/backup/.env"
cp -r "$PANEL_DIR/storage" "$TEMP_DIR/backup/storage"

# Remove existing panel files
echo "Removing existing Pterodactyl panel files..."
rm -rf "$PANEL_DIR"/*

# Download and extract default Pterodactyl panel
echo "Downloading Pterodactyl panel version $PANEL_VERSION..."
mkdir -p "$TEMP_DIR/download"
curl -L "https://github.com/pterodactyl/panel/releases/download/$PANEL_VERSION/panel.tar.gz" -o "$TEMP_DIR/download/panel.tar.gz"

echo "Extracting files..."
tar -xvzf "$TEMP_DIR/download/panel.tar.gz" -C "$PANEL_DIR"

# Restore configuration and storage files
echo "Restoring configuration files..."
mv "$TEMP_DIR/backup/.env" "$PANEL_DIR/.env"

# Install dependencies
echo "Installing dependencies..."
cd "$PANEL_DIR"
composer install --no-dev --optimize-autoloader
chmod -R 755 storage/* bootstrap/cache && chown -R www-data:www-data /var/www/pterodactyl/*
php artisan optimize:clear && php artisan view:clear

# Set correct permissions
echo "Setting permissions..."
chown -R www-data:www-data "$PANEL_DIR"
chmod -R 755 "$PANEL_DIR"

# Run migrations
echo "Running database migrations..."
php artisan migrate --force

# Start panel services
echo "Starting Pterodactyl services..."
echo "codex mogachoda khankir chele"

# Cleanup temporary files
echo "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

echo "Pterodactyl panel has been reset to its default state."
