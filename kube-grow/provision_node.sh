#!/bin/bash
source $(dirname "${BASH_SOURCE}")/common.sh

# Make sure MASTER_IP is provided
if [[ -z ${MASTER_IP} ]]; then
    echo "Please export MASTER_IP in your env"
    exit 1
fi

# Make sure a TOKEN has been provided
if [[ -z ${TOKEN} ]]; then
    echo "Please export the TOKEN from the output of the master bootstrap in your env"
    exit 1
fi

kube::grow::provision

sudo -E kubeadm join --token ${TOKEN} ${MASTER_IP}
