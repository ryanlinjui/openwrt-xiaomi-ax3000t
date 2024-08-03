#!/bin/bash

DEFAULT_OPENWRT_ROUTER_IP="192.168.1.1"
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r ./backup/ubi.bin root@${DEFAULT_OPENWRT_ROUTER_IP}:/tmp/.
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${DEFAULT_OPENWRT_ROUTER_IP} << 'EOF'
  clear
  ubiformat /dev/mtd8 -y -f /tmp/ubi.bin
  echo "Ready to reboot and recover to xiaomi system in 3 seconds......"
  sleep 3
  reboot
EOF