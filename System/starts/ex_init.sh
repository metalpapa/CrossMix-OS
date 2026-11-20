#!/bin/sh

source /mnt/SDCARD/System/etc/ex_config

mkdir -p ~/.config/

/mnt/SDCARD/System/bin/ex_update.sh

SSH_enabled=$(/mnt/SDCARD/System/bin/jq -r '.["SSH"]//0' "$EX_CONFIG_PATH/crossmix.json")
if [ "$SSH_enabled" -eq 1 ]; then
    mkdir -p /etc/dropbear
    nice -2 dropbear -R
fi

if [[ "$NETWORK_SFTPGO" == "Y" ]]; then
    mkdir -p /opt/sftpgo

    nice -2 /mnt/SDCARD/System/sftpgo/sftpgo serve -c /mnt/SDCARD/System/sftpgo/ --log-level error --log-file-path="" > /dev/null &
fi
