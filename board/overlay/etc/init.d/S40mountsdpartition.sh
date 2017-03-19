#!/bin/sh
#
# Mount second sd card partition for docker /var/lib/docker
#

mkdir -p /var/lib/docker
mount /dev/mmcblk0p2 /var/lib/docker
