# Embedded-jinja/sample-falcon-app/Dockerfile
# However : this runs from the context -> /embed-jinja
# Due to the need to copy shell files from /embed-jinja/ansible-orchestration at build time.
FROM python:3.9-slim-buster

# Copy application code, requirements are an included file with this
COPY /sample-falcon-app /app/

# Enable running the scripts for embed-jinja
# 4) Add entrypoint + helper scripts
COPY sample-falcon-app/sfa-entrypoint.sh /usr/local/bin/sfa-entrypoint.sh
COPY ansible-orchestration/copy-jinja-build-to-container.sh /usr/local/bin/copy-jinja-build-to-container.sh
COPY ansible-orchestration/clear-jinja-build.sh /usr/local/bin/clear-jinja-build.sh

RUN pip install -r /app/requirements.txt

RUN chmod +x /usr/local/bin/sfa-entrypoint.sh \
             /usr/local/bin/copy-jinja-build-to-container.sh \
             /usr/local/bin/clear-jinja-build.sh

# Set the working directory

WORKDIR /app

# The main.py will be run from the entrypoint shell,
# the entrypoint shell will be specified in the docker-compose.yml
ENTRYPOINT ["/usr/local/bin/sfa-entrypoint.sh"]