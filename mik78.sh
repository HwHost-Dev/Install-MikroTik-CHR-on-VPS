#!/bin/bash -e

echo
echo "=== hwhost.fr ==="
echo "=== MikroTik Installer ==="
echo
sleep 3
wget https://download.mikrotik.com/routeros/7.16/chr-7.16.img.zip -O chr.img.zip  && \
gunzip -c chr.img.zip > chr.img  && \

mount -o loop,offset=512 chr.img /mnt && \
ADDRESS=`ip addr show eth0 | grep global | cut -d' ' -f 6 | head -n 1` && \
GATEWAY=`ip route list | grep default | cut -d' ' -f 3` && \
echo "/ip address add address=$ADDRESS interface=[/interface ethernet find where name=ether1]
/ip route add gateway=$GATEWAY
/ip service disable telnet
/user set 0 name=root password=123456789
 " > /mnt/rw/autorun.scr && \
umount /mnt && \
STORAGE=`lsblk | grep disk | cut -d ' ' -f 1 | head -n 1` && \
echo STORAGE is $STORAGE && \
ETH=`ip route show default | sed -n 's/.* dev \([^\ ]*\) .*/\1/p'` && \
echo ETH is $ETH && \
echo ADDRESS is $ADDRESS && \
echo GATEWAY is $GATEWAY && \
sleep 5 && \
dd if=chr.img of=/dev/$STORAGE bs=4M oflag=sync && \
echo "Ok, reboot" && \
echo 1 > /proc/sys/kernel/sysrq && \
echo b > /proc/sysrq-trigger && \
