#!/bin/sh
# /embed-jinja/sample-falcon-app/sfa-entrypoint.sh
# Entrypoint script for the Falcon app container using embed-jinja.

set -e

PORT="${BACKEND_PORT:-8080}"

# Clear the build artifacts since the compilation is done and we do not want to occupy extra space in the container.
/usr/local/bin/copy-jinja-build-to-container.sh
#/usr/local/bin/clear-jinja-build.sh

# Run the equivalent of 'python main.py' from the /app directory.
python -m gunicorn main:app --bind 0.0.0.0:"${PORT}" --workers 2