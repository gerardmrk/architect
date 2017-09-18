description "Vault server"

start on runlevel [2345]
stop on runlevel [!2345]

respawn

script
  if [ -f "/etc/service/vault" ]; then
    . /etc/service/vault
  fi

  # Make sure to use all our CPUs, because Vault can block a scheduler thread
  export GOMAXPROCS=`nproc`

  exec /usr/local/bin/vault server \
    -config="/usr/local/etc/vault-config.hcl" \
    \$${VAULT_FLAGS} \
    >>/var/log/vault.log 2>&1
end script
