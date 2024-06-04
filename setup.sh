#!/bin/bash

# This script sets up prerequisites for the *arr media stack using Docker and Docker Compose with ufw on Debian.
# Replace placeholders with your own information.

set -euo pipefail  # Exit on error and unset variables

# Load environment variables
source .env

# Update and install necessary packages
sudo apt update && sudo apt -y install \
    apt-transport-https ca-certificates curl gnupg2 software-properties-common \
    docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Docker GPG and repository setup
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive-keyring.gpg
echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Enable Docker service
sudo systemctl enable --now docker

# Setup USB drive with permissions
sudo mkdir -p "${DATADIR}"
sudo mkfs.ext4 -F "$USB_PARTITION"  # Force creating filesystem without prompt
sudo mount "$USB_PARTITION" "${DATADIR}"
echo "$USB_PARTITION ${DATADIR} ext4 defaults 0 0" | sudo tee -a /etc/fstab

echo "Setting ownership to ${USERNAME}:${USERNAME}"
sudo chown -R "${USERNAME}:${USERNAME}" "${DATADIR}"
echo "Setting permissions to 775"
sudo chmod -R 775 "${DATADIR}"

# Create and adjust permissions for the new media directories
for category in downloads; do
    for type in movies music books tv torrents incomplete complete; do
        dir="${DATADIR}/data/${category}/${type}"
        mkdir -p "${dir}"
        echo "Setting ownership for ${dir} to ${USERNAME}:${USERNAME}"
        sudo chown -R "${USERNAME}:${USERNAME}" "${dir}"
        echo "Setting permissions for ${dir} to 775"
        sudo chmod -R 775 "${dir}"
    done
done

# UFW configuration
sudo ufw allow 81/tcp 3005/tcp 5800/tcp 6881/tcp 8080/tcp 8082/tcp 8084/tcp 9000/tcp
sudo ufw allow from $ADMIN_IP to any port 22
echo "y" | sudo ufw enable

# Add user to the Docker group
sudo groupadd docker || true  # Ignore if group already exists
sudo usermod -aG docker "$USERNAME"

# Set up cron job for Docker image pruning
echo -e '#!/bin/bash\ndocker system prune -af --filter "until=$((30*24))h"' | sudo tee /etc/cron.daily/docker-prune
sudo chmod +x /etc/cron.daily/docker-prune

echo "Setup completed successfully."
echo "Please log out and log back in to apply group changes."
