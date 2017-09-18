#!/usr/bin/env bash
set -e

# install packages
sudo apt-get update -y
sudo apt-get install -y curl unzip

# download vault into a tmp dir
curl -L "${download_url}" > /tmp/vault.zip

# unzip and set permissions and ownership
cd /tmp
sudo unzip vault.zip
sudo mv vault /usr/local/bin
sudo chmod 0755 /usr/local/bin/vault
sudo chown root:root /usr/local/bin/vault

# create the Vault config
cat <<EOF >/tmp/vault-config
${config}
EOF
sudo mv /tmp/vault-config /usr/local/etc/vault-config.hcl

# create the Vault init script
cat <<EOF >/tmp/vault-init
${init_script}
EOF
sudo mv /tmp/vault-init /etc/init/vault.conf

# run additional commands if any
${additional_cmds}

# start Vault
sudo start vault
