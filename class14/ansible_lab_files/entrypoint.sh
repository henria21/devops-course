#!/bin/bash

mkdir -p /root/.ssh
chmod 700 /root/.ssh

if [ ! -f /root/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 2048 -f /root/.ssh/id_rsa -N "" -q
fi

echo "Waiting for nodes to be ready and distributing SSH keys..."
for node in node1 node2; do
    until sshpass -p ubuntu ssh-copy-id -o StrictHostKeyChecking=no ubuntu@$node 2>/dev/null; do
        sleep 2
    done
    echo "  SSH key distributed to $node"
done

echo ""
echo "Ansible control node is ready. Run: docker compose exec ansible-control bash"
exec tail -f /dev/null
