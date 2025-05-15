curl -sL https://deb.nodesource.com/setup_16.x | bash -
apt install -y nodejs
npm i -g yarn
cd /var/www/pterodactyl
yarn install --network-timeout 600000
apt update && apt upgrade -y
apt install -y zip unzip git curl wget
#now install plueprint zip
wget "$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4)" -O release.zip
mv release.zip /var/www/pterodactyl/release.zip
cd /var/www/pterodactyl
unzip release.zip
chmod +x blueprint.sh
bash blueprint.sh
