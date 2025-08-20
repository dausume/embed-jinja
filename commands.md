# Setup Command

    sudo docker-compose -f docker-compose.setup.yml up --build --abort-on-container-exit --exit-code-from ansible-setup

# build uses repo root context; compose file for final build is the generated one

docker compose -f jinja-build/docker-compose.yml up --build
