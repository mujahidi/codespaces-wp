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

# Prepare a nice name from project name for the site title.
function getTitleFromSlug() {
	local _slug=${SLUG//-/ }
	local __slug=${_slug//_/ }
	local ___slug=($__slug)
	echo "${___slug[@]^}"
}

source ~/.bashrc

# Install dependencies
cd /var/www/html/wp-content/${PROJECT_TYPE}s/${SLUG}/
npm i && npm run build

if [[ $PROJECT_TYPE == "plugin" ]]; then
# Install WordPress and activate the plugin
	cd /var/www/html/
	echo "Setting up WordPress at $SITE_HOST"
	wp db reset --yes
	wp core install --url="$SITE_HOST" --title="$(getTitleFromSlug) Development" --admin_user="admin" --admin_email="admin@example.com" --admin_password="password" --skip-email

	echo "Activate $SLUG"
	wp $PROJECT_TYPE activate $SLUG $WPARG
fi

sudo chown www-data:www-data /var/www/html/xdebug.log
sudo chmod 664 /var/www/html/xdebug.log