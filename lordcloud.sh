#!/bin/bash

# LordCloud Fix Tool - India's Leading High-Performance Game Cloud

# Root check
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root!"
    exit 1
fi

# Check if Pterodactyl is installed
if [[ ! -d "/etc/pterodactyl" && ! -d "/var/www/pterodactyl" ]]; then
    echo "❌ Pterodactyl installation not found!"
    exit 1
fi

# Banner
echo "###############################################"
echo "#       Welcome to the LordCloud Fix Tool      #"
echo "#  India's Leading High-Performance Game Cloud #"
echo "#   Optimized for Minecraft & AI Workloads!    #"
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

### PANEL ###
if [[ "$issue_type" == "1" ]]; then
    echo "Panel Issue Type?"
    echo "1) Panel-install"
    echo "2) SSL"
    echo "3) env"
    echo "4) Upgrade"
    echo "5) Build Panel Assets"
    echo "6) Panel Reset (without data loss)"
    read -p "Enter your choice: " panel_issue

    if [[ "$panel_issue" == "1" ]]; then
        bash <(curl -s https://pterodactyl-installer.se)

    elif [[ "$panel_issue" == "2" ]]; then
        read -p "Enter FQDN (e.g., panel.example.com): " fqdn
        apt update
        apt install -y certbot python3-certbot-nginx
        certbot certonly --nginx -d "$fqdn"

    elif [[ "$panel_issue" == "3" ]]; then
        echo "⚠️ Too risky to automate env edit. Exiting."
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

    elif [[ "$panel_issue" == "5" ]]; then
        curl -sL https://deb.nodesource.com/setup_16.x | bash -
        apt install -y nodejs
        npm i -g yarn
        cd /var/www/pterodactyl || exit
        yarn install --network-timeout 600000
        apt update && apt upgrade -y

    elif [[ "$panel_issue" == "6" ]]; then
        curl -o panel-reset.sh https://raw.githubusercontent.com/Alfha240/Petrpdactyl-fix/main/panel-reset.sh
        chmod +x panel-reset.sh
        bash panel-reset.sh
    fi

### DATABASE ###
elif [[ "$issue_type" == "3" ]]; then
    echo "1) Create Database for Node"
    read -p "Enter your choice: " db_issue

    if [[ "$db_issue" == "1" ]]; then
        read -p "Enter DB Username [default: lorduser]: " db_user
        db_user=${db_user:-lorduser}
        read -p "Enter DB Password [default: lordpass]: " db_pass
        db_pass=${db_pass:-lordpass}

        curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash
        apt update
        apt -y install mariadb-server

        mysql -e "CREATE USER '$db_user'@'%' IDENTIFIED BY '$db_pass';"
        mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$db_user'@'%' WITH GRANT OPTION;"
        mysql -e "FLUSH PRIVILEGES;"

        echo "Edit /etc/mysql/my.cnf and set bind-address=0.0.0.0"
        echo "Then run: systemctl enable --now mariadb"
        read -p "Press Enter when ready..."
    fi

### THEMES ###
elif [[ "$issue_type" == "4" ]]; then
    echo "Theme Options:"
    echo "1) Standalone [WIP]"
    echo "2) Blueprint"
    echo "3) Free Theme Install"
    read -p "Enter your choice: " theme_choice

    if [[ "$theme_choice" == "1" ]]; then
        echo "Standalone theme installation coming soon."

    elif [[ "$theme_choice" == "2" ]]; then
        echo "⚠️ Blueprint replaces core files. Backup recommended."
        read -p "Backup /var/www/pterodactyl? (Y/N): " backup_choice
        if [[ "$backup_choice" == "Y" || "$backup_choice" == "y" ]]; then
            tar -czvf /var/www/pterodactyl/backup_$(date +%F).tar.gz /var/www/pterodactyl
        fi

        echo "1) Install Blueprint"
        echo "2) Install Nebula"
        read -p "Enter your choice: " blueprint_choice

        if [[ "$blueprint_choice" == "1" ]]; then
            read -p "Enter panel path [default: /var/www/pterodactyl]: " panel_path
            panel_path=${panel_path:-/var/www/pterodactyl}
            apt install -y ca-certificates curl gnupg
            mkdir -p /etc/apt/keyrings
            curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
            echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list
            apt update
            apt install -y nodejs yarn zip unzip git curl wget
            cd "$panel_path"
            wget "$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4)" -O release.zip
            unzip release.zip
            echo -e 'WEBUSER="www-data";\nOWNERSHIP="www-data:www-data";\nUSERSHELL="/bin/bash";' > "$panel_path/.blueprintrc"
            chmod +x blueprint.sh
            bash blueprint.sh

        elif [[ "$blueprint_choice" == "2" ]]; then
            read -p "Enter panel path [default: /var/www/pterodactyl]: " panel_path
            panel_path=${panel_path:-/var/www/pterodactyl}
            wget -O "$panel_path/nebula.blueprint" "https://storage.xitewebservices.cloud/nebula.blueprint"
            cd "$panel_path"
            blueprint -install nebula
        fi

    elif [[ "$theme_choice" == "3" ]]; then
        echo "Free Themes Available:"
        echo "1) Nook-theme"
        echo "2) Ice Minecraft-theme"
        echo "3) Minecraft Purple-theme"
        read -p "Enter your choice: " Free_Theme_Install

        if [[ "$Free_Theme_Install" == "1" ]]; then
            curl -O https://raw.githubusercontent.com/Alfha240/Petrpdactyl-fix/main/nook-theme.sh
            chmod +x nook-theme.sh
            bash nook-theme.sh

        elif [[ "$Free_Theme_Install" == "2" ]]; then
            bash <(curl -s https://raw.githubusercontent.com/Angelillo15/IceMinecraftTheme/main/install.sh)

        elif [[ "$Free_Theme_Install" == "3" ]]; then
            bash <(curl -s https://raw.githubusercontent.com/Angelillo15/MinecraftPurpleTheme/main/install.sh)

        else
            echo "❌ Invalid theme choice."
        fi
    fi
fi
