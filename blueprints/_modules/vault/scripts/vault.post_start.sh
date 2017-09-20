#!/usr/bin/env bash

echo "Running post-start script for the Vault service.."

# [TEMP] set this for development
export VAULT_ADDR='http://127.0.0.1:8200'
