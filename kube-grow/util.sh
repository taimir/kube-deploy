# Check if a command is valid
kube::util::command_exists() {
  command -v "$@" > /dev/null 2>&1
}

# Returns five "random" chars
kube::util::small_sha() {
  date | md5sum | cut -c-5
}

# Delete the iface for a bridge
kube::util::delete_bridge() {
  if [[ ! -z $(ip link | grep "$1") ]]; then
    ip link set $1 down
    ip link del $1
  fi
}

kube::util:clean_iptables() {
  docker run \
  -d \
  --privileged \
  -v /home/mirchev/workspace/ubuntu-sandbox/kubelet.conf:/run/kubeconfig:rw \
  -v /var/run/dbus:/var/run/dbus:rw \
  gcr.io/google_containers/kube-proxy-amd64:v1.4.0-beta.6 \
  /usr/local/bin/kube-proxy \
  --cleanup-iptables
}

# Print a status line. Formatted to show up in a stream of output.
kube::log::status() {
  timestamp=$(date +"[%m%d %H:%M:%S]")
  echo "+++ $timestamp $1"
  shift
  for message; do
    echo "    $message"
  done
}

# Log an error and exit
kube::log::fatal() {
  timestamp=$(date +"[%m%d %H:%M:%S]")
  echo "!!! $timestamp ${1-}" >&2
  shift
  for message; do
    echo "    $message" >&2
  done
  exit 1
}
