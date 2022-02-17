#!/usr/bin/env bash
set -x

USER="${1}"
COMMENT="Hashicorp ${1} user"
GROUP="${1}"
HOME="/home/${1}"
USER_ID=${2}
GID=${3}

echo "Setting up user ${USER}"
sudo /usr/sbin/groupadd --force --system ${GROUP} --gid ${GID}

if ! getent passwd ${USER} >/dev/null ; then
  sudo /usr/sbin/adduser \
    --system \
    --uid ${USER_ID} \
    --gid ${GID} \
    --home ${HOME} \
    --comment "${COMMENT}" \
    --shell /bin/bash \
    ${USER}  >/dev/null
fi


