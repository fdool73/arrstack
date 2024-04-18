# arrstack

Home media server solution built on the *arr app stack, tailored for Debian systems.

## Getting Started

These instructions will guide you on how to deploy `arrstack` on your system.

### Prerequisites

Ensure you have Git installed on your system. This is required to clone the repository.

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/fdool73/arrstack.git

2. Run the setup script:
   ```bash
   ./setup.sh

3. Deploy the services using Docker:
   docker compose up -d

## TODO

- Create app config default `.conf` and cron backups for appdata (API keys, settings, etc.).
- Add Docker labels.
- Create Nginx/Traefik reverse proxy for internal network only (no internet exposure).
- Document images and ports.

## Maintainer

[fdool](https://github.com/fdool73). For any queries or contributions, please reach out through GitHub
