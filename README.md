# PXE-bootable Raspberry PI docker rootfs and kernel

This is a buildroot config to build a 4.9 linux kernel for a Raspberry PI 3.
Currently it only works with the buildroot master branch, commit 61fcd08247ddfd262123c3a4afad0cd376184811, as only this branch has the current rpi-firmware and docker-engine packages.

## Why I build this & What you can do with this

My goal is to build a docker swarm cluster on three Raspberry PIs. The PIs are automatically PXE provisioned, immutable and automatically configured. I also wanted to learn and use a MaaS Tool (like foreman, ubuntu MAAS, rachkHD or whatever) to provision bare-metal nodes.
Here is my plan:
- Use one RPI as the bare-metal orchestration node (host for the MaaS Tool)
- This RPI will also host DHCP, DNS and TFTP services for my network. These services are managed by the MaaS Tool.
- The MaaS Tool will provide a way to generate user-data scripts for automatic configuration of hardware nodes.
- Connect three Raspberry PIs to the first RPI, PXE boot and configure them via the MaaS Tool
- The three PIs will start a docker swarm cluster
- For a configuration change I just need to change the user-data script on the MaaS Tool and reboot the corresponding PI. All data will be wiped from the PI and I have a fresh installation.

Result: A fully automated, zero-touch docker swarm cluster on three RPIs.

To achieve my goal I decided to compile my own small kernel and rootfs (for fun and profit) which I can customize to my needs. Buildroot is a simple way to do that.

My first thought was: Put everything in RAM, kernel + rootfs should fit. I plan to only run one container on the cluster, so ~512MB of RAM should still be enough.
On second thought: I also need space for the docker images. Maybe they are larger than 512MB. Or i want to use more then just one container... Also i bought all those SD cards and now i wouldn't use them?
(Also i couldn't get the network boot without SD card on my RPIs to work, so i compiled uboot and put it on the sdcards to do this)

So my boot sequence is now this:
- RPI boots to uboot kernel/image
- uboot does the pxe boot, detects my pxe config and downloads the real kernel from TFTP Server
- My kernel boots, unpacks included rootfs to RAM and executes my custom /init
- My /init mounts second partition (/mnt/newroot) of sd card and wipes it. 
- My /init copies current / to /mnt/newroot
- My /init does switch_root with /mnt/newroot and executes /sbin/init aka busybox init system
- busybox executes all scripts in /etc/init.d
- docker daemon starts
- /etc/init.d script fetches the foreman user_data script (set by kernel cmdline foreman_user_data_url) and executes it

## How to use this

- Clone this repo
- Clone or download the above mentioned buildroot version into a sibling directory 
- Change into the buildroot directory
- `make BR2_EXTERNAL=<absolute path to where you cloned this repository> fledermausland_pi_defconfig`
- `make`

The build fails at the last step while building the first partition for the sd card. As I only want to use the Kernel and rootfs to pxe boot the rpi, i don't care. It complains about "disk size full". Maybe someone else wants to look into that.

The kernel (zImage) and rootfs (rootfs.cpio.gz) are stored in "<buildroot>/output/images". I uploaded them to AWS S3 to use them in my foreman setup.

I also just learned, that in my current configuration the rootfs is directly linked into the kernel image (zImage), which makes the kernel pretty large, but you don't need the `initrd=<path to rootfs.cpio.gz>` any more.
