#!/bin/bash -x
echo ""

DISKS_OFFLINE_SP=$(grep ^#/dev /opt/mapr/conf/disktab | tr -d "#" | awk '{print $1}')

for hdd in $DISKS_OFFLINE_SP; do
        if [[ !  -r "$hdd" ]]; then
                echo "Missing disk:"
                echo "$hdd"
                MISSING_DISK=$hdd
        fi
done

echo ""

DISK_IN_DISKTAB=$(grep /dev /opt/mapr/conf/disktab | tr -d "#" | awk '{print $1}')


DISKS_ON_SERVER=$(lsblk -b -d -o NAME,SIZE | grep sd | awk '{if ($2 > 299966445568) print $1}')

for hdd in $DISKS_ON_SERVER ; do
         DISK_BY_ID=$(ls -l /dev/disk/by-id/ | grep $hdd$ | grep -v wwn| awk '{print $9}')
         if ! grep -q $DISK_BY_ID /opt/mapr/conf/disktab ; then
                echo "Newly found disk info:"
                echo $DISK_BY_ID
                lsblk -b -d -o NAME,SIZE /dev/disk/by-id/$DISK_BY_ID
                echo ""
                NEW_DISK_PATH=/dev/disk/by-id/$DISK_BY_ID
        fi
done

echo "Disks list"

echo -n "$NEW_DISK_PATH "

for hdd in $DISKS_OFFLINE_SP; do
        if [[ "hdd" != "MISSING_DISK" ]]; then
                echo -n "$hdd "
                DISK_LIST_OFFLINE+="${hdd} "
        fi
done
echo ""
echo ""
echo "maprcli disk add -host $(hostname -f) -disks "$NEW_DISK_PATH $DISK_LIST_OFFLINE "-stripeWidth 6"
echo ""
