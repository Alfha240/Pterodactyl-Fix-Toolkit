#!/bin/bash

# LordCloud Fix Tool - India's Leading High-Performance Game Cloud

# Root check
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root!"
    exit 1
fi

# Banner
echo "###############################################"
echo "#       Welcome to the LordCloud Fix Tool      #"
echo "#  India's Leading High-Performance Game Cloud #"
echo "#   Optimized for Minecraft & AI Workloads!    #"
echo "#          Visit: https://lordcloud.in         #"
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
        cd /var/www/pterodactyl || exit
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

    else
        echo "❌ Invalid choice."
    fi

### WINGS ###
elif [[ "$issue_type" == "2" ]]; then
    echo "Wings fixes coming soon."

### DATABASE ###
elif [[ "$issue_type" == "3" ]]; then
    echo "1) Create Database for Node"
    read -p "Enter your choice: " db_issue

    if [[ "$db_issue" == "1" ]]; then
        read -p "Enter DB Username [default: lorduser]: " db_user
        db_user=${db_user:-lorduser}
        read -p "Enter DB Password [default: lordpass]: " db_pass
        db_pass=${db_pass:-lordpass}

        curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | bash
        apt update
        apt -y install mariadb-server

        mysql -e "CREATE USER '$db_user'@'%' IDENTIFIED BY '$db_pass';"
        mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$db_user'@'%' WITH GRANT OPTION;"
        mysql -e "FLUSH PRIVILEGES;"

        echo "Edit /etc/mysql/my.cnf and set bind-address=0.0.0.0"
        echo "Then run: systemctl enable --now mariadb"
        read -p "Press Enter when ready..."
    else
        echo "❌ Invalid choice."
    fi

### THEMES ###
elif [[ "$issue_type" == "4" ]]; then
    echo "1) Standalone (Coming Soon)"
    echo "2) Blueprint"
    echo "3) Free Theme Install"
    read -p "Enter your choice: " theme_choice

    if [[ "$theme_choice" == "1" ]]; then
        echo "Standalone theme installation coming soon."

    elif [[ "$theme_choice" == "2" ]]; then
        echo "⚠️ Blueprint replaces core files. Backup recommended."
        read -p "Backup /var/www/pterodactyl? (Y/N): " backup_choice
        if [[ "$backup_choice" =~ ^[Yy]$ ]]; then
            tar -czvf /var/www/pterodactyl/backup_$(date +%F).tar.gz /var/www/pterodactyl
        fi

        echo "1) Install Blueprint"
        echo "2) Install Nebula"
        echo "3) Install Blueprint Addon"
        read -p "Enter your choice: " blueprint_choice

        if [[ "$blueprint_choice" == "1" ]]; then
            echo "Installing Blueprint..."
            bash <(curl -s https://raw.githubusercontent.com/Alfha240/Pterodactyl-Fix-Toolkit/main/Blueprint-install.sh)

        elif [[ "$blueprint_choice" == "2" ]]; then
            echo "Installing Nebula..."
            read -p "Enter panel path [default: /var/www/pterodactyl]: " panel_path
            panel_path=${panel_path:-/var/www/pterodactyl}
            wget -O "$panel_path/nebula.blueprint" "https://storage.xitewebservices.cloud/nebula.blueprint"
            cd "$panel_path" || { echo "Panel path not found!"; exit 1; }
            blueprint -install nebula

        elif [[ "$blueprint_choice" == "3" ]]; then
            echo "Installing Blueprint Addon directly into panel directory (/var/www/pterodactyl)..."
            read -p "Proceed? (Y/N) [Y]: " proceed_choice
            proceed_choice=${proceed_choice:-Y}
            if [[ ! "$proceed_choice" =~ ^[Yy]$ ]]; then
                echo "Aborted by user."
            else
                PANEL_DIR="/var/www/pterodactyl"
                if [[ ! -d "$PANEL_DIR" ]]; then
                    echo "❌ Panel directory $PANEL_DIR not found!"
                    exit 1
                fi

                # ensure tools
                apt update -y
                apt install -y wget unzip

                cd "$PANEL_DIR" || { echo "Cannot cd to $PANEL_DIR"; exit 1; }

                # download and extract only .blueprint files directly into panel
                ZIP_URL="https://github.com/Alfha240/Blueprint-Addon/archive/refs/heads/main.zip"
                wget -q "$ZIP_URL" -O blueprint-addon.zip || { echo "❌ Download failed"; rm -f blueprint-addon.zip; exit 1; }
                unzip -jo blueprint-addon.zip "Blueprint-Addon-main/*.blueprint" -d . >/dev/null 2>&1 || true
                rm -f blueprint-addon.zip

                echo "✅ .blueprint files are now in $PANEL_DIR (if present)."

                # Attempt to install each blueprint using absolute path
                if command -v blueprint >/dev/null 2>&1; then
                    shopt -s nullglob
                    for addon in "$PANEL_DIR"/*.blueprint; do
                        if [[ -f "$addon" ]]; then
                            echo "⚙️ Installing: $(basename "$addon")"
                            blueprint -i "$addon" || blueprint -install "$addon" || echo "⚠️ Manual install may be required for $addon"
                        fi
                    done
                    shopt -u nullglob
                else
                    echo "⚠️ blueprint CLI not found. To install it run:"
                    echo "bash <(curl -s https://raw.githubusercontent.com/Alfha240/Pterodactyl-Fix-Toolkit/main/Blueprint-install.sh)"
                    echo "Or install the official blueprint CLI and then run:"
                    echo "  cd $PANEL_DIR && blueprint -i <addon>.blueprint"
                fi
            fi

        else
            echo "❌ Invalid choice."
        fi

    elif [[ "$theme_choice" == "3" ]]; then
        echo "Free Themes Available:"
        echo "1) Nook-theme"
        echo "2) Ice Minecraft-theme"
        echo "3) Minecraft Purple-theme"
        read -p "Enter your choice: " free_theme_choice

        if [[ "$free_theme_choice" == "1" ]]; then
            curl -O https://raw.githubusercontent.com/Alfha240/Petrpdactyl-fix/main/nook-theme.sh
            chmod +x nook-theme.sh
            bash nook-theme.sh

        elif [[ "$free_theme_choice" == "2" ]]; then
            bash <(curl -s https://raw.githubusercontent.com/Angelillo15/IceMinecraftTheme/main/install.sh)

        elif [[ "$free_theme_choice" == "3" ]]; then
            bash <(curl -s https://raw.githubusercontent.com/Angelillo15/MinecraftPurpleTheme/main/install.sh)

        else
            echo "❌ Invalid theme choice."
        fi

    else
        echo "❌ Invalid theme choice."
    fi

else
    echo "❌ Invalid main menu choice."
fi
