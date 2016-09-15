#!/bin/sh

function info
{
  echo "`date +"%Y%m%d %H:%M:%S"` [`basename $0 .sh`][INFO] $*"
}

info "Install and Enable NetworkManager"
yum -y install NetworkManager
systemctl enable NetworkManager && systemctl start NetworkManager

info "Install and Configure Ansible"
yum -y install epel-release
sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo
yum -y --enablerepo=epel install ansible pyOpenSSL

info "Fork Latest Openshift Ansible Installer"
cd ~
git clone https://github.com/openshift/openshift-ansible -b master

info "Disable Host Key Checking"
sed -i 's/#host_key_checking/host_key_checking/g' /etc/ansible/ansible.cfg

info "Configure Ansible Host Inventory"
export PUBLIC_IP=`cat ~/master.public.ip`
export HOSTNAME=`cat ~/master.hostname`
export NODE_HOSTNAME=`cat ~/node1.hostname`

export MASTER_PRIVATE_IP=`cat ~/master.private.ip`
export NODE_PRIVATE_IP=`cat ~/node.private.ip`

cat > /etc/ansible/hosts <<EOF
#Hosts where the Openshift Requirement will be installed
[openshift-master]
${MASTER_PRIVATE_IP} ansible_user=centos
${NODE_PRIVATE_IP} ansible_user=centos

# Create an OSEv3 group that contains the masters and nodes groups
[OSEv3:children]
masters
nodes

# Set variables common for all OSEv3 hosts
[OSEv3:vars]
# SSH user, this user should allow ssh based auth without requiring a password
ansible_ssh_user=centos

# If ansible_ssh_user is not root, ansible_sudo must be set to true
ansible_sudo=true

deployment_type=origin

# uncomment the following to enable htpasswd authentication; defaults to DenyAllPasswordIdentityProvider
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider', 'filename': '/etc/origin/master/htpasswd'}]

# Use something like apps.<public-ip>.xip.io if you don't have a custom domain
openshift_master_default_subdomain=apps.${PUBLIC_IP}.xip.io

[masters]
${HOSTNAME}

[nodes]
# Make the master node schedulable by default
${HOSTNAME} openshift_node_labels="{'region': 'infra', 'zone': 'us-west-2b'}" openshift_schedulable=true

# You can add some nodes below if you want!
#ip-10-0-0-65.us-west-2.compute.internal openshift_node_labels="{'region': 'primary', 'zone': 'us-west-2b'}"
${NODE_HOSTNAME} openshift_node_labels="{'region': 'primary', 'zone': 'us-west-2b'}"
EOF
