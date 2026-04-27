#!/bin/bash

# 1. Create a workspace directory
mkdir -p ansible-lab && cd ansible-lab

# 2. Generate Lab-Specific SSH Keys
if [ ! -f ./id_rsa ]; then
    echo "Generating SSH keys for the lab..."
    ssh-keygen -t rsa -b 4096 -f ./id_rsa -N "" -q
fi

# 3. Dockerfile for Managed Nodes (The targets)
cat <<EOF > Dockerfile.node
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y openssh-server python3 iputils-ping sudo
RUN mkdir /var/run/sshd
RUN mkdir -p /root/.ssh
COPY id_rsa.pub /root/.ssh/authorized_keys
RUN chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
CMD ["/usr/sbin/sshd", "-D"]
EOF

# 4. Dockerfile for Control Node (The brain)
cat <<EOF > Dockerfile.control
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y \
    ansible \
    openssh-client \
    iputils-ping \
    vim \
    curl
WORKDIR /lab
EOF

# 5. Create Docker Compose with static IPs
cat <<EOF > docker-compose.yml
services:
  node1:
    build: 
      context: .
      dockerfile: Dockerfile.node
    networks:
      ansible_net:
        ipv4_address: 172.20.0.11
  node2:
    build: 
      context: .
      dockerfile: Dockerfile.node
    networks:
      ansible_net:
        ipv4_address: 172.20.0.12

  control:
    build:
      context: .
      dockerfile: Dockerfile.control
    volumes:
      - .:/lab
    stdin_open: true 
    tty: true
    networks:
      ansible_net:
        ipv4_address: 172.20.0.10
EOF

# 6. Create the Inventory file
cat <<EOF > hosts.ini
[managed_nodes]
172.20.0.11
172.20.0.12

[managed_nodes:vars]
ansible_user=root
ansible_ssh_private_key_file=/lab/id_rsa
ansible_ssh_extra_args='-o StrictHostKeyChecking=no'
EOF

# 7. Spin up the environment
docker-compose up -d --build

echo "------------------------------------------------"
echo "Lab is ready!"
echo "To jump straight into Ansible, run:"
echo "  docker exec -it ansible-lab-control-1 bash"
echo ""
echo "Then test with:"
echo "  ansible managed_nodes -i hosts.ini -m ping"