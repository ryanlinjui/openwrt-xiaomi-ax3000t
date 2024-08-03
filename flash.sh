#!/bin/bash

DEFAULT_XIAOMI_ROUTER_IP="192.168.31.1"
DEFAULT_OPENWRT_ROUTER_IP="192.168.1.1"

if [ "$1" = "" ]; then
  echo "Usage: $0 [stok]"
  echo "e.g. $0 e6ea114ba2cddb0c70fbbc417bb2706c"
  echo "Copy the stok-string from a browser's URL-line, while being logged in to the router from http://${DEFAULT_XIAOMI_ROUTER_IP}."
  exit 1
fi

# Get ssh access. Supported stock firmware 1.0.47
response=$(curl -s -X POST "http://${DEFAULT_XIAOMI_ROUTER_IP}/cgi-bin/luci/;stok=${1}/api/misystem/arn_switch" -d "open=1&model=1&level=%0Anvram%20set%20ssh_en%3D1%0A")
if [ "$response" != '{"code":0}' ]; then
  echo "Error: Your stok string is invalid. Go http://${DEFAULT_XIAOMI_ROUTER_IP} to check stok string again."
  exit 1
fi
sleep 1
curl -X POST "http://${DEFAULT_XIAOMI_ROUTER_IP}/cgi-bin/luci/;stok=${1}/api/misystem/arn_switch" -d "open=1&model=1&level=%0Anvram%20commit%0A"
sleep 1
curl -X POST "http://${DEFAULT_XIAOMI_ROUTER_IP}/cgi-bin/luci/;stok=${1}/api/misystem/arn_switch" -d "open=1&model=1&level=%0Ased%20-i%20's%2Fchannel%3D.*%2Fchannel%3D%22debug%22%2Fg'%20%2Fetc%2Finit.d%2Fdropbear%0A"
sleep 1
curl -X POST "http://${DEFAULT_XIAOMI_ROUTER_IP}/cgi-bin/luci/;stok=${1}/api/misystem/arn_switch" -d "open=1&model=1&level=%0A%2Fetc%2Finit.d%2Fdropbear%20start%0A"
sleep 1
curl -X POST "http://${DEFAULT_XIAOMI_ROUTER_IP}/cgi-bin/luci/;stok=${1}/api/misystem/arn_switch" -d "open=1&model=1&level=%0Apasswd%20-d%20root%0A"
sleep 5

# Backup stock partitions
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${DEFAULT_XIAOMI_ROUTER_IP} << 'EOF'
  clear
  nanddump -f /tmp/tmp/BL2.bin /dev/mtd1
  nanddump -f /tmp/tmp/Nvram.bin /dev/mtd2
  nanddump -f /tmp/tmp/Bdata.bin /dev/mtd3
  nanddump -f /tmp/tmp/Factory.bin /dev/mtd4
  nanddump -f /tmp/tmp/FIP.bin /dev/mtd5
  nanddump -f /tmp/tmp/ubi.bin /dev/mtd8
  nanddump -f /tmp/tmp/KF.bin /dev/mtd12
  exit 0
EOF
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r root@${DEFAULT_XIAOMI_ROUTER_IP}:/tmp/tmp/*.bin ./backup/.

# Get firmware information
# Copy openwrt-mediatek-filogic-xiaomi_mi-router-ax3000t-initramfs-factory.ubi to /tmp and flash
# Then reboot your router, it should boot to the OpenWrt initramfs system now.
# To be sure to use one of OpenWrt's LAN ports (not WAN port), plug the ethernet cable into one of the middle ports, if the cable is not already plugged there (original FW dynamically assigns LAN/WAN).
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ./bin/openwrt-mediatek-filogic-xiaomi_mi-router-ax3000t-initramfs-factory.ubi root@${DEFAULT_XIAOMI_ROUTER_IP}:/tmp/.
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${DEFAULT_XIAOMI_ROUTER_IP} << 'EOF'
  clear
  firmware=$(echo $(cat /proc/cmdline) | sed -n 's/.*firmware=\([0-1]\+\).*/\1/p')
  if [ "$firmware" == "0" ] || [ "$firmware" == "1" ]; then
      firmware=$((1 - firmware))
      ubiformat /dev/mtd9 -y -f /tmp/openwrt-mediatek-filogic-xiaomi_mi-router-ax3000t-initramfs-factory.ubi
      nvram set boot_wait=on
      nvram set uart_en=1
      nvram set flag_boot_rootfs=$firmware
      nvram set flag_last_success=$firmware
      nvram set flag_boot_success=1
      nvram set flag_try_sys1_failed=0
      nvram set flag_try_sys2_failed=0
      nvram commit
      clear
      echo "Ready to reboot and flash to OpenWrt in 3 seconds......"
      sleep 3
      reboot
  else
      echo "Error: Invalid firmware value"
      exit 1
  fi
EOF

# Flash openwrt-mediatek-filogic-xiaomi_mi-router-ax3000t-squashfs-sysupgrade.bin
while ! curl -s --connect-timeout 5 -m 5 "$DEFAULT_OPENWRT_ROUTER_IP" &> /dev/null
do
  echo "Wait for OpenWrt router response......"
  sleep 1
done
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ./bin/openwrt-mediatek-filogic-xiaomi_mi-router-ax3000t-squashfs-sysupgrade.bin root@${DEFAULT_OPENWRT_ROUTER_IP}:/tmp/.
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${DEFAULT_OPENWRT_ROUTER_IP} << 'EOF'
  clear
  echo "Openwrt boot complete!. Start upgrade system in 3 seconds......"
  sleep 3
  sysupgrade -n /tmp/openwrt-mediatek-filogic-xiaomi_mi-router-ax3000t-squashfs-sysupgrade.bin
EOF
clear
echo "All of operations have been completely done. Wait for rebooting about a minute and you can go http://${DEFAULT_OPENWRT_ROUTER_IP} and login OpenWrt"