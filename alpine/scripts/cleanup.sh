set -eux

setup-proxy -q "none" || true
rm -f /etc/resolv.conf
