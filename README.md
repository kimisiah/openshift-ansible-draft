# Description

- This playbook will provision a RedHat 7 Instance in AWS that using an AMI with Oracle EBS (configured by Oracle Team) and assign it a $CUSTOM_HOSTNAME using Route 53
- The installation of Oracle EBS from scratch is still a work in progress.
- Review vars.yml. You can override these attributes by adding them as additional arguments in --extra-vars (see below Ansible playbook command usage)

# Commandline Usage

Required Variables:
- export CUSTOM_HOSTNAME=oracle.private.domain # Where oracle is the Route 53 record set and private.domain is a valid Route 53 Private Hosted zone
- export ENV=uat # The environment tag you would like to assign to your EC2. This can be anything.
- export INSTANCE_NAME=uat_oracle_ebs # The instance name you would like to assign to your EC2. This can be anything.
- export PRIVATE_KEY_LOCATION=~/ec2-private-key # Your private key location that has access to EC2s
- export VAULT_PASSWORD=~/vault.key # The vault password file for "secrets.yml", Connect to Bryan for more information of this usage.

Ansible playbook command:
- ansible-playbook site.yml -e "custom_hostname=$CUSTOM_HOSTNAME env=$ENV instance_name=$INSTANCE_NAME" --private-key $PRIVATE_KEY_LOCATION --vault-pass $VAULT_PASSWORD
