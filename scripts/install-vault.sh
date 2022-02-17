#!/usr/bin/env bash
set -x

HOST_ADDRESS=$1

RELEASE_SERVER="releases.hashicorp.com"
VAULT_LATEST_VERSION="$(curl -s https://releases.hashicorp.com/vault/index.json | jq -r '.versions[].version' | grep -v 'beta\|rc' | tail -n 1)"
VAULT_FILENAME="vault_${VAULT_LATEST_VERSION}_linux_amd64.zip"
VAULT_DOWNLOAD_URL=${URL:-"https://${RELEASE_SERVER}/vault/${VAULT_LATEST_VERSION}/${VAULT_FILENAME}"}
VAULT_DEST_DIR="/usr/bin"

echo "Retrieving vault version: ${VAULT_LATEST_VERSION}"
curl --silent --output /tmp/${VAULT_FILENAME} ${VAULT_DOWNLOAD_URL}

echo "Installing vault"
sudo unzip -o /tmp/${VAULT_FILENAME} -d ${VAULT_DEST_DIR}
sudo chmod 0755 ${VAULT_DEST_DIR}/vault
sudo chown vault:vault ${VAULT_DEST_DIR}/vault
sudo mkdir -pm 0755 /etc/vault.d
sudo mkdir -pm 0755 /etc/ssl/vault

echo "${VAULT_DEST_DIR}/vault --version: $(${VAULT_DEST_DIR}/vault --version)"

sudo chown -R vault:vault /etc/vault.d /etc/ssl/vault
sudo chmod -R 0644 /etc/vault.d/*
echo "export VAULT_ADDR=http://${HOST_ADDRESS}:8200" | sudo tee /etc/profile.d/vault.sh

