#!/bin/bash
source $(dirname "${BASH_SOURCE}")/common.sh

kube::grow::provision

sudo -E kubeadm init master --api-advertise-addr ${IP_ADDRESS} --cluster-cidr 10.3.0.0/16
