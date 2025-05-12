#!/bin/bash

# LordCloud Fix Tool - India's Leading High-Performance Game Cloud
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root!"
    exit 1
fi

if [[ ! -d "/etc/pterodactyl" && ! -d "/var/www/pterodactyl" ]]; then
    echo "Pterodactyl installation not found!"
    exit 1
fi

echo "###############################################"
echo "#       Welcome to the LordCloud Fix Tool      #"
echo "#  India's Leading High-Performance Game Cloud #"
echo "#   Optimized for Minecraft & AI Workloads!   #"
echo "#          Visit: https://lordcloud.tech       #"
echo "###############################################"
sleep 5

# Main Menu
echo "What issue are you facing?"
echo "1) Panel"
echo "2) Wings"
echo "3) Database"
echo "4) Themes"
read -p "Enter your choice: " issue_type

if [[ "$issue_type" == "1" ]]; then
    echo "Panel Issue Type?"
echo "Panel Issue Type?"
echo "1) Panel-install"
echo "2) SSL"
echo "3) env"
echo "4) Upgrade"
read -p "Enter your choice: " panel_issue

if [[ "$panel_issue" == "1" ]]; then
    bash <(curl -s https://pterodactyl-installer.se)

elif [[ "$panel_issue" == "2" ]]; then
    read -p "Enter FQDN for Panel (e.g., panel.lordcloud.tech): " fqdn
    apt update
    apt install -y certbot python3-certbot-nginx
    certbot certonly --nginx -d "$fqdn"

elif [[ "$panel_issue" == "3" ]]; then
    echo "Too risky to edit via script. Exiting."
    exit 1

elif [[ "$panel_issue" == "4" ]]; then
    cd /var/www/pterodactyl
    php artisan down
    curl -L https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz | tar -xzv
    chmod -R 755 storage/* bootstrap/cache
    composer install --no-dev --optimize-autoloader
    php artisan view:clear
    php artisan config:clear
    php artisan migrate --seed --force
    chown -R www-data:www-data /var/www/pterodactyl/*
    php artisan queue:restart
    php artisan up
fi
elif [[ "$issue_type" == "2" ]]; then
    echo "Wings Issue Type?"
    echo "1) SSL"
    read -p "Enter your choice: " wings_issue

    if [[ "$wings_issue" == "1" ]]; then
        read -p "Enter FQDN for Wings: " fqdn_wings
        certbot certonly --standalone -d "$fqdn_wings"
    fi

elif [[ "$issue_type" == "3" ]]; then
    echo "Database Issue Type?"
    echo "1) Create Database for Node"
    read -p "Enter your choice: " db_issue

    if [[ "$db_issue" == "1" ]]; then
        read -p "Enter Database Username (default: lorduser): " db_user
        db_user=${db_user:-lorduser}
        read -p "Enter Database Password (default: lordpass): " db_pass
        db_pass=${db_pass:-lordpass}

        curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash
        apt update
        apt -y install mariadb-server

        mysql -e "CREATE USER '$db_user'@'%' IDENTIFIED BY '$db_pass';"
        mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$db_user'@'%' WITH GRANT OPTION;"
        mysql -e "FLUSH PRIVILEGES;"

        echo "Now manually edit /etc/mysql/my.cnf and set bind-address=0.0.0.0"
        echo "Then run: sudo systemctl enable --now mariadb"
        read -p "Press Enter after completing the steps..."
        echo "Exiting."
        exit 0
    fi

elif [[ "$issue_type" == "4" ]]; then
    echo "Theme Selection:"
    echo "1) Standalone [WIP]"
    echo "2) Blueprint"
    read -p "Enter your choice: " theme_choice

    if [[ "$theme_choice" == "2" ]]; then
        echo "Warning: If you select Blueprint, you won't be able to install standalone themes without resetting panel files."
        read -p "Do you want to take a backup of /var/www/pterodactyl? (Y/N): " backup_choice
        if [[ "$backup_choice" == "Y" || "$backup_choice" == "y" ]]; then
            tar -czvf /var/www/pterodactyl/backup_$(date +%F).tar.gz /var/www/pterodactyl
            echo "Backup created."
        else
            echo "You have not taken a backup. Proceeding in 3 seconds..."
            sleep 3
        fi

        echo "1) Install Blueprint (First time only)"
        echo "2) Install Nebula"
        read -p "Enter your choice: " blueprint_choice

        if [[ "$blueprint_choice" == "1" ]]; then
            read -p "Enter Panel Installation Path (default: /var/www/pterodactyl): " panel_path
            panel_path=${panel_path:-/var/www/pterodactyl}

            sudo apt-get install -y ca-certificates curl gnupg
            sudo mkdir -p /etc/apt/keyrings
            curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
            echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
            apt-get update
            apt-get install -y nodejs yarn zip unzip git curl wget

            cd "$panel_path"
            wget "$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4)" -O release.zip
            unzip release.zip
            touch "$panel_path/.blueprintrc"
            echo -e 'WEBUSER="www-data";\nOWNERSHIP="www-data:www-data";\nUSERSHELL="/bin/bash";' > "$panel_path/.blueprintrc"
            chmod +x blueprint.sh
            bash blueprint.sh

        elif [[ "$blueprint_choice" == "2" ]]; then
            read -p "Enter Panel Installation Path (default: /var/www/pterodactyl): " panel_path
            panel_path=${panel_path:-/var/www/pterodactyl}
            wget -O "$panel_path/nebula.blueprint" "https://storage.xitewebservices.cloud/nebula.blueprint"
            cd "$panel_path"
            blueprint -install nebula
        fi
    fi
fi
