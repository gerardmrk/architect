#!/usr/bin/env bash
set -e

# install packages
sudo apt-get update -y
sudo apt-get install -y curl unzip

# download Vault
curl -L "${download_url}" > /tmp/vault.zip

# unzip Vault and set permissions + ownership
cd /tmp
sudo unzip vault.zip
sudo mv vault /usr/local/bin
sudo chmod 0755 /usr/local/bin/vault
sudo chown root:root /usr/local/bin/vault

# write pre-start script
cat <<EOF >/tmp/pre-start
${pre_start_script}
EOF

# write post-start script
cat <<EOF >/tmp/post-start
${post_start_script}
EOF

# write init script for user sessions
cat <<EOF >/tmp/session-init
${user_session_script}
EOF

# write Vault server config
cat <<EOF >/tmp/vault-config
${vault_config}
EOF

# write Systemd settings for the Vault server
cat <<EOF >/tmp/systemd-settings
${systemd_settings}
EOF

# create directory for our custom pre/post/session scripts
sudo mkdir /usr/share/vault

# create directory for our vault daemon service
sudo mkdir /usr/lib/systemd/system

# create the scripts
sudo mv /tmp/pre-start /usr/share/vault/pre-start.sh
sudo mv /tmp/post-start /usr/share/vault/post-start.sh
sudo mv /tmp/session-init /etc/profile.d/vault.sh
sudo mv /tmp/vault-config /etc/vault.conf
sudo mv /tmp/systemd-settings /etc/systemd/system/vault.service

# set permissions
sudo chmod 0755 /usr/share/vault/pre-start.sh
sudo chmod 0755 /usr/share/vault/post-start.sh
sudo chmod 0755 /etc/profile.d/vault.sh

# add vault to system startup
sudo systemctl daemon-reload
sudo systemctl enable vault

# start Vault
sudo systemctl start vault
