FROM ubuntu:22.04
RUN apt-get update && apt-get install -y openssh-server python3 iputils-ping sudo
RUN mkdir /var/run/sshd
RUN mkdir -p /root/.ssh
# Copy the public key we just generated
COPY id_rsa.pub /root/.ssh/authorized_keys
RUN chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys
# Ensure SSH doesn't complain about permissions
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
CMD ["/usr/sbin/sshd", "-D"]
