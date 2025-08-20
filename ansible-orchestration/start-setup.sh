#!/bin/bash
# ansible-orchestration/start-setup.sh

set -e

echo "Starting Ansible Setup..."

ls

ansible-playbook ./ansible-orchestration/ansible-playbook.yml

echo "Ansible Setup Complete."

# Important : This script should exit after the ansible playbook is done
# because the ansible-setup service is designed to be a setup step.
# If you wanted it to remain running, you would add a command here
# like 'tail -f /dev/null' to keep it running indefinitely so you can debug the container.