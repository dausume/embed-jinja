# Manual Two-Phase Setup

## Phase 1: Run Ansible Setup (generates templates)

    sudo docker-compose -f docker-compose.setup.yml up --build --abort-on-container-exit --exit-code-from ansible-setup

## Phase 2: Build and run generated compose file

    docker compose -f jinja-build/docker-compose.yml up --build

---

# Automated Single-Command Setup

Runs both setup and application launch automatically:

    docker compose -f docker-compose.auto.yml up --build

This will:
1. Run ansible-setup to generate jinja-build/docker-compose.yml
2. Automatically start the services defined in the generated compose file
3. Keep the auto-launcher running to monitor status

## Managing Auto-Launched Services

View logs of application services:

    docker compose -f jinja-build/docker-compose.yml logs -f

Stop application services:

    docker compose -f jinja-build/docker-compose.yml down

Stop everything (including auto-launcher):

    docker compose -f docker-compose.auto.yml down
