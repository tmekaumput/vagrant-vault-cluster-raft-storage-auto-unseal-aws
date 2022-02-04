#!/usr/bin/env bash
set -x

NODE_ID="$1"
ADDRESS="$2"
KMS_KEY_ID="$3"
LEADER_NODE_ID="$4"
LEADER_API_ADDRESS="$5"

AWS_REGION="$6"
AWS_ACCESS_KEY="$7"
AWS_SECRET_KEY="$8"
DATA_DIR="/var/shared/data/raft-vault"

export NODE_ID DATA_DIR ADDRESS LEADER_NODE_ID LEADER_API_ADDRESS

function config_cluster_leader_node {

  rm -f vault.hcl

  sudo cp /tmp/license.txt /etc/vault.d/license.txt

  cat <<-EOF > vault.hcl

  license_path = "/etc/vault.d/license.txt"
  storage "raft" {
    path    = "${DATA_DIR}${NODE_ID}"
    node_id = "vault_${NODE_ID}"
  }
  listener "tcp" {
    address     = "0.0.0.0:8200"
    cluster_address = "${ADDRESS}:8201"
    tls_disable = 1
  }
  seal "awskms" {
    region     = "${AWS_REGION}"
    access_key = "${AWS_ACCESS_KEY}"
    secret_key = "${AWS_SECRET_KEY}"
    kms_key_id = "${KMS_KEY_ID}"
  }
  ui=true
  disable_mlock = true
  api_addr = "http://${ADDRESS}:8200"
  cluster_addr = "http://${ADDRESS}:8201"
EOF

  sudo mkdir -p "${DATA_DIR}${NODE_ID}"
  sudo chown -R vault:vault "${DATA_DIR}${NODE_ID}"
}

function config_cluster_follower_node {

  rm -f vault.hcl

  sudo cp /tmp/license.txt /etc/vault.d/license.txt

  cat <<-EOF > vault.hcl

  license_path = "/etc/vault.d/license.txt"
  storage "raft" {
    path    = "${DATA_DIR}${NODE_ID}"
    node_id = "vault_${NODE_ID}"
    retry_join {
      leader_api_addr = "${LEADER_API_ADDRESS}"
    }
  }
  listener "tcp" {
    address     = "0.0.0.0:8200"
    cluster_address = "${ADDRESS}:8201"
    tls_disable = 1
  }
  seal "awskms" {
    region     = "${AWS_REGION}"
    access_key = "${AWS_ACCESS_KEY}"
    secret_key = "${AWS_SECRET_KEY}"
    kms_key_id = "${KMS_KEY_ID}"
  }
  ui=true
  disable_mlock = true
  api_addr = "http://${ADDRESS}:8200"
  cluster_addr = "http://${ADDRESS}:8201"
EOF

  sudo mkdir -p "${DATA_DIR}${NODE_ID}"
  sudo chown -R vault:vault "${DATA_DIR}${NODE_ID}"

}



sudo mkdir -p /etc/vault.d

if [[ "${NODE_ID}" == "${LEADER_NODE_ID}" ]]; then
    config_cluster_leader_node
else
    config_cluster_follower_node
fi

sudo mv vault.hcl /etc/vault.d/
sudo chown -R vault:vault /etc/vault.d /etc/ssl/vault
sudo chmod -R 0644 /etc/vault.d/*
