# source ----> https://github.com/justmeandopensource/kubernetes/blob/master/vagrant-provisioning/bootstrap.sh
#!/bin/bash

# Update hosts file
echo "Update /etc/hosts file"
cat >>/etc/hosts<<EOF
172.42.42.100 master
172.42.42.101 worker1
172.42.42.102 worker2
EOF

# Install docker from Docker-ce repository
echo "[TASK 2] Install docker container engine"
yum install -y -q yum-utils device-mapper-persistent-data lvm2 > /dev/null 2>&1
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo > /dev/null 2>&1
yum install -y -q docker-ce >/dev/null 2>&1

# Enable docker service
echo "Enable and start docker service"
systemctl enable docker >/dev/null 2>&1
systemctl start docker

# Disable SELinux
echo " Disable SELinux"
setenforce 0
sed -i --follow-symlinks 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux

# Stop and disable firewalld
echo "Stop and Disable firewalld"
systemctl disable firewalld >/dev/null 2>&1
systemctl stop firewalld

# Disable swap
echo "Disable and turn off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a

# Enable ssh password authentication
echo " Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo " Set root password"
echo "kubeadmin" | passwd --stdin root >/dev/null 2>&1

# Update vagrant user's bashrc file
echo "export TERM=xterm" >> /etc/bashrc
