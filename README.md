# PXE-bootable Raspberry PI docker rootfs and kernel

This is a buildroot config to build a 4.9 linux kernel for a Raspberry PI 3.
Currently it only works with the buildroot master branch, commit 61fcd08247ddfd262123c3a4afad0cd376184811, as only this branch has the current rpi-firmware and docker-engine packages.


## Instructions

- Clone this repo
- Clone or download the above mentioned buildroot version into a sibling directory 
- Change into the buildroot directory
- `make BR2_EXTERNAL=<absolute path to where you cloned this repository> fledermausland_pi_defconfig`
- `make`

The build fails at the last step while building the first partition for the sd card. As I only want to use the Kernel and rootfs to pxe boot the rpi, i don't care. It complains about "disk size full". Maybe someone else wants to look into that.

The kernel (zImage) and rootfs (rootfs.cpio.gz) are stored in "<buildroot>/output/images". I uploaded them to AWS S3 and used them in my foreman setup.

