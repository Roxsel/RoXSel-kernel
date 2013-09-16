#!/bin/bash

BASEDIR="/home/robert/Roxsel/"
OUTDIR="$BASEDIR/out"
INITRAMFSDIR="/home/robert/Ramdisk/Stock/touch"
TOOLCHAIN="/home/robert/toolchain/arm-eabi-4.7/bin/arm-eabi-"

STARTTIME=$SECONDS

case "$1" in
	clean)
		echo -e "\n\n Cleaning Kernel Sources...\n\n"
		make mrproper ARCH=arm CROSS_COMPILE=$TOOLCHAIN
		rm -rf ${INITRAMFSDIR}/lib
		rm -rf ${OUTDIR}
		ENDTIME=$SECONDS
		echo -e "\n\n Finished in $((ENDTIME-STARTTIME)) Seconds\n\n"
		;;
	*)
		echo -e "\n\n Configuring I8160 Kernel...\n\n"
		make RoXSel_Stock_defconfig ARCH=arm CROSS_COMPILE=$TOOLCHAIN

		echo -e "\n\n Compiling I8160 Kernel and Modules... \n\n"
		make -j4 ARCH=arm CROSS_COMPILE=$TOOLCHAIN CONFIG_INITRAMFS_SOURCE=$INITRAMFSDIR

		echo -e "\n\n Copying Modules to InitRamFS Folder...\n\n"
		mkdir -p $INITRAMFSDIR/lib/modules/

		cp fs/cifs/cifs.ko $INITRAMFSDIR/lib/modules/cifs.ko
		cp fs/exfat $INITRAMFSDIR/lib/modules/exfat.ko
		cp drivers/scsi/scsi_wait_scan.ko $INITRAMFSDIR/lib/modules/scsi_wait_scan.ko
		cp drivers/samsung/j4fs/j4fs.ko $INITRAMFSDIR/lib/modules/j4fs.ko
		cp drivers/bluetooth/bthid/bthid.ko $INITRAMFSDIR/lib/modules/bthid.ko
		cp drivers/char/hwreg/hwreg.ko $INITRAMFSDIR/lib/modules/hwreg.ko
		cp drivers/samsung/param/param.ko $INITRAMFSDIR/lib/modules/param.ko
		cp drivers/staging/android/logger.ko $INITRAMFSDIR/lib/modules/logger.ko
		cp drivers/char/frandom/frandom.ko $INITRAMFSDIR/lib/modules/frandom.ko
		cp drivers/char/hw_random/rng-core.ko $INITRAMFSDIR/lib/modules/rng-core.ko
		cp drivers/net/wireless/bcm4330/dhd.ko $INITRAMFSDIR/lib/modules/dhd.ko


		echo -e "\n\n Creating zImage...\n\n"
		make ARCH=arm CROSS_COMPILE=$TOOLCHAIN CONFIG_INITRAMFS_SOURCE=$INITRAMFSDIR zImage

		mkdir -p ${OUTDIR}
		cp arch/arm/boot/zImage ${OUTDIR}/kernel.bin

		echo -e "\n\n Pushing Kernel to OUT folder...\n\n"
		pushd ${OUTDIR}
		md5sum -t kernel.bin >> kernel.bin
		mv kernel.bin kernel.bin.md5

		echo -e "\n\n Making flashable zip...\n\n"
		cp -avr flashable/stock/META-INF $OUTDIR
		cp flashable/stock/flash_roxsel.sh $OUTDIR
		cd $OUTDIR
		zip -r RoXSel_$VERSION.zip .
		cd $BASEDIR

		echo -e "\n\n Cleaning Output Folder...\n\n"
		rm -rf $OUTDIR/META-INF
		rm -rf $OUTDIR/system
		rm $OUTDIR/kernel.bin.md5

                ENDTIME=$SECONDS
                echo -e "\n\n = Finished in $((ENDTIME-STARTTIME)) Seconds =\n\n"
		;;
esac

