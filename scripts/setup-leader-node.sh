#!/bin/bash

set -x

SHARED_DIR=$1

# Delay
sleep 10

INITIALIZED=$(vault status -format=json | jq -r '.initialized')

if [[ "${INITIALIZED}" == "false" ]]; then
  # Initialize the second node and capture its recovery keys and root token
  INIT_RESPONSE=$(vault operator init -format=json -recovery-shares 1 -recovery-threshold 1)

  RECOVERY_KEY=$(echo "$INIT_RESPONSE" | jq -r .recovery_keys_b64[0])
  VAULT_TOKEN=$(echo "$INIT_RESPONSE" | jq -r .root_token)

  echo "$RECOVERY_KEY" > ${SHARED_DIR}/recovery_key-vault
  echo "$VAULT_TOKEN" > ${SHARED_DIR}/root_token-vault

  printf "\n%s" \
    "[vault] Recovery key: $RECOVERY_KEY" \
    "[vault] Root token: $VAULT_TOKEN" \
    ""

  printf "\n%s" \
    "[vault] waiting to finish post-unseal setup (15 seconds)" \
    ""

  sleep 15s
else
  echo "Skipping vault init, Vault has been initialized"
fi

