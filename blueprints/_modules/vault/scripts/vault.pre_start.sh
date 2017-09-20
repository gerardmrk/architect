#!/usr/bin/env bash

echo "Running pre-start script for the Vault service.."

# Make sure to use all our CPUs, because Vault can block a scheduler thread
export GOMAXPROCS=`nproc`
