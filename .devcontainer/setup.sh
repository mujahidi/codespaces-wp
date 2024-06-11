#! /bin/bash
#
# Inspired by https://github.com/helen/wcus-2021/tree/trunk/.devcontainer
#

# Load environment variables from .devcontainer/.env
set -o allexport
source "${BASH_SOURCE%/*}/.env"
set +o allexport

if [[ ! -z "$CODESPACE_NAME" ]]; then
	SITE_HOST="https://${CODESPACE_NAME}-8080.preview.app.github.dev"
else
	SITE_HOST="http://localhost:8080"
fi

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>setup.log 2>&1

source ~/.bashrc

# Install WordPress
cd /var/www/html/
echo "Setting up WordPress at $SITE_HOST"
wp db reset --yes
wp core install --url="$SITE_HOST" --title="$SITE_TITLE" --admin_user="$ADMIN_USER" --admin_email="$ADMIN_EMAIL" --admin_password="$ADMIN_PASS" --skip-email

sudo chown www-data:www-data /var/www/html/xdebug.log
sudo chmod 664 /var/www/html/xdebug.log