#!/bin/bash

# This script sets up prerequisites for the *arr media stack using Docker and Docker Compose with ufw on Debian.
# Replace placeholders with your own information.

set -euo pipefail  # Exit on error and unset variables

# Ensure the .env file is present
if [[ ! -f .env ]]; then
    echo ".env file not found!"
    exit 1
fi

# Load environment variables
source .env

# Ensure necessary environment variables are set
required_vars=(DATADIR USB_PARTITION USERNAME DOCKERDIR ADMIN_IP)
for var in "${required_vars[@]}"; do
    if [[ -z "${!var:-}" ]]; then
        echo "Environment variable $var is not set!"
        exit 1
    fi
done

# Update and install necessary packages
sudo apt update && sudo apt -y install \
    apt-transport-https ca-certificates curl gnupg2 software-properties-common \
    docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Docker GPG and repository setup
if ! sudo gpg --list-keys | grep -q "Docker Release"; then
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive-keyring.gpg
fi
if [[ ! -f /etc/apt/sources.list.d/docker.list ]]; then
    echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
fi

# Enable Docker service
sudo systemctl enable --now docker

# Setup USB drive with permissions
if ! mount | grep -q "$USB_PARTITION"; then
    sudo mkdir -p "${DATADIR}"
    sudo mkfs.ext4 -F "$USB_PARTITION"  # Force creating filesystem without prompt
    sudo mount "$USB_PARTITION" "${DATADIR}"
    echo "$USB_PARTITION ${DATADIR} ext4 defaults 0 0" | sudo tee -a /etc/fstab
fi

echo "Setting ownership to ${USERNAME}:${USERNAME}"
sudo chown -R "${USERNAME}:${USERNAME}" "${DATADIR}"
echo "Setting permissions to 775"
sudo chmod -R 775 "${DATADIR}"

# Create and adjust permissions for the new media directories
directories=(
    "data"
    "media"
    "data/usenet"
    "data/usenet/downloads"
    "data/usenet/downloads/complete"
    "data/usenet/downloads/incomplete"
    "media/movies"
    "media/tv"
)

for dir in "${directories[@]}"; do
    full_path="${DATADIR}/${dir}"
    if [[ ! -d "$full_path" ]]; then
        mkdir -p "${full_path}"
        echo "Created ${full_path}"
    fi
    echo "Setting ownership for ${full_path} to ${USERNAME}:${USERNAME}"
    sudo chown -R "${USERNAME}:${USERNAME}" "${full_path}"
    echo "Setting permissions for ${full_path} to 775"
    sudo chmod -R 775 "${full_path}"
done

# Ensure Grafana datasource file exists and set correct permissions
sudo mkdir -p "${DOCKERDIR}/appdata/grafana"
sudo touch ${DOCKERDIR}/appdata/grafana/datasources.yml
sudo chown 472:472 ${DOCKERDIR}/appdata/grafana/datasources.yml
sudo chmod 644 ${DOCKERDIR}/appdata/grafana/datasources.yml

# UFW configuration
ports=(81 3005 5800 6881 8080 8082 8084 9000)
for port in "${ports[@]}"; do
    sudo ufw allow "${port}/tcp"
done
sudo ufw allow from "$ADMIN_IP" to any port 22
echo "y" | sudo ufw enable

# Add user to the Docker group
if ! getent group docker > /dev/null; then
    sudo groupadd docker
fi
sudo usermod -aG docker "$USERNAME"

# Set up cron job for Docker image pruning
prune_script="/etc/cron.daily/docker-prune"
if [[ ! -f $prune_script ]]; then
    echo -e '#!/bin/bash\ndocker system prune -af --filter "until=$((30*24))h"' | sudo tee "$prune_script"
    sudo chmod +x "$prune_script"
fi

echo "Setup completed successfully."
echo "Please log out and log back in to apply group changes."
