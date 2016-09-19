#!/bin/bash
# Source common.sh
source $(dirname "${BASH_SOURCE}")/util.sh

kube::grow::provision() {
  init
  copy_admin_apps
  start_kubelet
}

init() {
  # Require root
  if [[ "$(id -u)" != "0" ]]; then
    kube::log::fatal "Please run as root"
  fi

  # Make sure docker daemon is running
  if [[ $(docker ps 2>&1 1>/dev/null; echo $?) != 0 ]]; then
    kube::log::fatal "Docker is not running on this machine!"
  fi
}

# Start kubelet
start_kubelet() {
  kube::log::status "Launching kubelet in a container ..."

  # Define flags
  RESTART_POLICY="unless-stopped"
  IP_ADDRESS=$(ip -o -4 addr list $(ip -o -4 route show to default | awk '{print $5}' | head -1) | awk '{print $4}' | cut -d/ -f1 | head -1)

  make_shared_kubelet_dir

  docker run \
    -d \
    --net=host \
    --pid=host \
    --privileged \
    --restart=${RESTART_POLICY} \
    --name kube_kubelet_$(kube::util::small_sha) \
    -v /etc/kubernetes:/hostfs/etc/kubernetes:rw \
    -v /etc/cni:/hostfs/etc/cni \
    -v /sys:/sys:rw \
    -v /var/run:/var/run:rw \
    -v /run:/run:rw \
    -v /var/lib/docker:/var/lib/docker:rw \
    -v /var/lib/kubelet:/var/lib/kubelet:shared \
    -v /var/log/containers:/var/log/containers:rw \
    gcr.io/google_containers/hyperkube-amd64:v1.4.0-beta.6 \
    /hyperkube kubelet \
    --allow-privileged \
    --network-plugin=cni \
    --network-plugin-dir=/hostfs/etc/cni/net.d \
    --kubeconfig=/hostfs/etc/kubernetes/kubelet.conf \
    --require-kubeconfig=true \
    --pod-manifest-path=/hostfs/etc/kubernetes/manifests \
    --hostname-override=${IP_ADDRESS}
}

# Copy utilities
copy_admin_apps() {
  kube::log::status "Copying kubectl and kubeadm to /usr/bin."
  cp kubeadm /usr/bin
  cp kubectl /usr/bin
}

make_shared_kubelet_dir() {
  if ! kube::util::command_exists systemctl; then
    mkdir -p /var/lib/kubelet
    mount --bind /var/lib/kubelet /var/lib/kubelet
    mount --make-shared /var/lib/kubelet
    kube::log::status "Mounted /var/lib/kubelet with shared propagnation"
  fi
}
