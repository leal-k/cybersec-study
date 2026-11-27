#!/usr/bin/env bash
# Sobe o laboratório: rede libvirt -> Juice Shop (só na virbr0) -> VM Kali.
set -euo pipefail

CONN="qemu:///system"
VM="${VM:-kali}"
LAB_IP="192.168.122.1"

echo "[1/3] Rede libvirt 'default'"
if ! virsh -c "$CONN" net-info default | grep -Eq 'Active:\s+yes'; then
  virsh -c "$CONN" net-start default
fi

echo "[2/3] Juice Shop em ${LAB_IP}:3000"
if docker ps -a --format '{{.Names}}' | grep -qx juice-shop; then
  docker start juice-shop >/dev/null
else
  docker run -d --name juice-shop -p "${LAB_IP}:3000:3000" bkimminich/juice-shop >/dev/null
fi

echo "[3/3] VM ${VM}"
if [ "$(virsh -c "$CONN" domstate "$VM")" != "running" ]; then
  virsh -c "$CONN" start "$VM"
fi

echo
echo "Lab no ar. Juice Shop: http://${LAB_IP}:3000"
echo "Console: virt-manager --connect ${CONN} --show-domain-console ${VM}"
