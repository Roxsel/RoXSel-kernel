#!/bin/bash

BASEDIR="/home/robert/Roxsel/"
OUTDIR="$BASEDIR/out"
INITRAMFSDIR="$BASEDIR/usr/miui_touch.list"
#INITRAMFSDIR="$BASEDIR/usr/miui.list"
TOOLCHAIN="/home/robert/toolchain/arm-eabi-4.7/bin/arm-eabi-"
VERSION="Touch_MIUI_v3"
#VERSION="Kernel_MIUI_v3"

cd $BASEDIR
STARTTIME=$SECONDS

case "$1" in
	clean)
		echo -e "\n\n Cleaning Kernel Sources...\n\n"
		make mrproper ARCH=arm CROSS_COMPILE=$TOOLCHAIN
		rm -rf $OUTDIR
		ENDTIME=$SECONDS
		echo -e "\n\n Finished in $((ENDTIME-STARTTIME)) Seconds\n\n"
		;;
	*)
		echo -e "\n\n Configuring I8160 Kernel...\n\n"
		make RoXSel_defconfig ARCH=arm CROSS_COMPILE=$TOOLCHAIN

		echo -e "\n\n Compiling I8160 Kernel and Modules... \n\n"
		make -j4 ARCH=arm CROSS_COMPILE=$TOOLCHAIN CONFIG_INITRAMFS_SOURCE=$INITRAMFSDIR

		echo -e "\n\n Copying Modules to Output Folder...\n\n"
		mkdir -p $OUTDIR/system/lib/modules/

		cp fs/cifs/cifs.ko $OUTDIR/system/lib/modules/cifs.ko
		cp fs/exfat/exfat.ko $OUTDIR/system/lib/modules/exfat.ko
		cp drivers/scsi/scsi_wait_scan.ko $OUTDIR/system/lib/modules/scsi_wait_scan.ko
		cp drivers/samsung/j4fs/j4fs.ko $OUTDIR/system/lib/modules/j4fs.ko
		cp drivers/bluetooth/bthid/bthid.ko $OUTDIR/system/lib/modules/bthid.ko
		cp drivers/char/hwreg/hwreg.ko $OUTDIR/system/lib/modules/hwreg.ko
		cp drivers/samsung/param/param.ko $OUTDIR/system/lib/modules/param.ko
		cp drivers/staging/android/logger.ko $OUTDIR/system/lib/modules/logger.ko
		cp drivers/char/frandom/frandom.ko $OUTDIR/system/lib/modules/frandom.ko
		cp drivers/char/hw_random/rng-core.ko $OUTDIR/system/lib/modules/rng-core.ko
		cp drivers/net/wireless/bcmdhd/dhd.ko $OUTDIR/system/lib/modules/dhd.ko

		echo -e "\n\n Making flashable ZIP...\n\n"
		cp arch/arm/boot/zImage $OUTDIR/boot.img
		cp -avr flashable/META-INF $OUTDIR
		cd $OUTDIR
		zip -r RoXSel_$VERSION.zip .
		cd $BASEDIR

		echo -e "\n\n Cleaning Output Folder...\n\n"
		rm -rf $OUTDIR/META-INF
		rm -rf $OUTDIR/system
		rm $OUTDIR/boot.img

                ENDTIME=$SECONDS
                echo -e "\n\n = Finished in $((ENDTIME-STARTTIME)) Seconds =\n\n"
		;;
esac

