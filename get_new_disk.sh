#!/bin/bash -x

DISKS_OFFLINE_SP=$(grep ^#/dev /opt/mapr/conf/disktab | tr -d "#" | awk '{print $1}')

for hdd in $DISKS_OFFLINE_SP; do
        if [[ !  -r "$hdd" ]]; then
                echo "$hdd does not exist"
                MISSING_DISK=$hdd
        fi
done

echo ""

DISK_IN_DISKTAB=$(grep /dev /opt/mapr/conf/disktab | tr -d "#" | awk '{print $1}')


DISKS_ON_SERVER=$(lsblk -d -o NAME,SIZE | grep sd | awk '{print $1}')

for hdd in $DISKS_ON_SERVER ; do
         DISK_BY_ID=$(ls -l /dev/disk/by-id/ | grep $hdd$ | grep -v wwn| awk '{print $9}')
         if ! grep -q $DISK_BY_ID /opt/mapr/conf/disktab ; then
                echo "NEW DISK"
                echo $DISK_BY_ID
                lsblk -d -o NAME,SIZE /dev/disk/by-id/$DISK_BY_ID
                echo ""
        fi
done
