#!/usr/bin/env bash
set -e

# install packages
sudo apt-get update -y
sudo apt-get install -y curl unzip

# download Vault
curl -L "${download_url}" > /tmp/vault.zip

# unzip Vault
cd /tmp
sudo unzip vault.zip
sudo mv vault /usr/local/bin

# unzip and set permissions and ownership
sudo chmod 0755 /usr/local/bin/vault
sudo chown root:root /usr/local/bin/vault

sudo mkdir /usr/share/vault

# create pre-start script
cat <<EOF >/tmp/pre-start
${pre_start_script}
EOF
sudo mv /tmp/pre-start /usr/share/vault/pre-start.sh

# create post-start script
cat <<EOF >/tmp/post-start
${post_start_script}
EOF
sudo mv /tmp/post-start /usr/share/vault/post-start.sh

# create Vault server config
cat <<EOF >/tmp/vault-config
${config}
EOF
sudo mv /tmp/vault-config /etc/vault.conf

# create Systemd settings for the Vault server
cat <<EOF >/tmp/systemd-settings
${systemd_settings}
EOF
sudo mv /tmp/systemd-settings /usr/lib/systemd/system/vault.service

# create init script for user sessions
cat <<EOF >/tmp/session-init
${user_session_script}
EOF
sudo mv /tmp/session-init /etc/profile.d/vault.sh

# run any additional commands
${additional_cmds}

# add vault to system startup
systemctl daemon-reload
systemctl enable vault

# start Vault
systemctl start vault
