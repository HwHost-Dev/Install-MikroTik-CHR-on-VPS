#!/bin/bash -e
export PATH=$PATH:/usr/bin:/bin

echo
echo "=== hwhost.fr ==="
echo "=== MikroTik Installer ==="
echo

sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get -y install gzip

# Retrieve the latest version dynamically
latest_version=$(curl -s https://mikrotik.com/download | grep -oP 'chr-\K[0-9]+\.[0-9]+\.[0-9]+(?=\.img\.zip)' | sort -V | tail -n 1)

# Construct the download URL for the latest version
download_url="https://download.mikrotik.com/routeros/$latest_version/chr-$latest_version.img.zip"

# Download and extract the image file
wget "$download_url" -O chr.img.zip
gunzip -c chr.img.zip > chr.img && \

kpartx -av chr.img
mount /dev/mapper/loop3p2 /mnt/ && \

# Find the primary network interface with an IP address
interface=$(ip -o -4 addr show up primary scope global | awk '{print $2}' | head -n 1)

# Retrieve network information
ADDRESS=$(ip addr show $interface | grep global | cut -d' ' -f 6 | head -n 1)
GATEWAY=$(ip route list | grep default | cut -d' ' -f 3)
HOSTNAME=$(hostname)


# Create autorun script
echo "/ip address add address=$ADDRESS interface=[/interface ethernet find where name=ether1]
/ip route add gateway=$GATEWAY
/ip service disable telnet
/system identity set name=$HOSTNAME
/user add name=root password=123456789 group=full
/user remove 0
" > /mnt/rw/autorun.scr && \

# Unmount and clean up
sudo umount /mnt/ && \

# Sync and write image to disk
echo u > /proc/sysrq-trigger && \
sudo dd if=chr.img bs=1024 of=/dev/sda && \
echo "sync disk" && \
echo s > /proc/sysrq-trigger && \
echo "Waiting 5 seconds..." && \
#Waiting
end_time=$((SECONDS + 5))
while [ $SECONDS -lt $end_time ]; do
    :
done && \

echo "Reboot OS" && \
echo b > /proc/sysrq-trigger
