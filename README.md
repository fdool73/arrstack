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

## Info

- To run portainer password reset: from appdata/portainer/data: docker run --rm -v $(pwd):/data portainer/helper-reset-password

## Maintainer

[fdool](https://github.com/fdool73). For any queries or contributions, please reach out through GitHub
