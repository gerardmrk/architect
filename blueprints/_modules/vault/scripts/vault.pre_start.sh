#!/usr/bin/env bash

echo "Running Vault server pre-start script.."

# Make sure to use all our CPUs, because Vault can block a scheduler thread
export GOMAXPROCS=`nproc`
