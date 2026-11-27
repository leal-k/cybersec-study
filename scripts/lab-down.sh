#!/usr/bin/env bash
# Derruba o laboratório: desliga a VM e para o Juice Shop.
set -euo pipefail

CONN="qemu:///system"
VM="${VM:-kali}"

if [ "$(virsh -c "$CONN" domstate "$VM")" = "running" ]; then
  virsh -c "$CONN" shutdown "$VM"
fi
docker stop juice-shop >/dev/null 2>&1 || true
echo "Lab desligado."
