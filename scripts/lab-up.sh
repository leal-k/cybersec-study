#!/usr/bin/env bash
# Sobe o laboratório: rede libvirt -> Juice Shop (só na virbr0) -> VM Kali.
set -euo pipefail
export LC_ALL=C   # saídas do virsh/docker sempre em inglês, independente do idioma do sistema

CONN="qemu:///system"
VM="${VM:-debiantesting}"
LAB_IP="192.168.122.1"

echo "[1/3] Rede libvirt 'default'"
redes_ativas=$(virsh -c "$CONN" net-list --name)
if ! grep -qx default <<<"$redes_ativas"; then
  virsh -c "$CONN" net-start default
fi

echo "[2/3] Juice Shop em ${LAB_IP}:3000"
containers=$(docker ps -a --format '{{.Names}}')
if grep -qx juice-shop <<<"$containers"; then
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
