#!/bin/bash

if [ -z "$1" ]
then
	echo "-------------------"
	echo "Usage:"
	echo "./build.sh 'ROM' 'ANDROID_VERSION' 'RECOVERY'"
	echo "Available ROM's: cm, stock, miui"
	echo "Available ANDROID_VERSION's: 4.1; 4.2.2 (only cm)"
	echo "Available RECOVERY's: cwm, touch"
	echo "if you want to build kernel for 4.2.2 CyanogenMod Based ROM (like PAC) with touch recovery"
	echo "./build.sh cm 4.2.2 touch"
	echo "if you want to build kernel for MIUI with default recovery"
	echo "./build.sh miui 4.1.2 cwm"
	echo "-------------------"
	exit 1
fi

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OUTDIR="$BASEDIR/out/$1_$2_$3"
TOOLCHAIN="/home/robert/toolchain/arm-eabi-4.7/bin/arm-eabi-"
KERNEL_VERSION="v3"

case "$4" in
	clean)
		echo -e "\n\n Cleaning Kernel Sources...\n\n"
		make mrproper ARCH=arm CROSS_COMPILE=$TOOLCHAIN
		rm -rf "$BASEDIR/out/"
		ENDTIME=$SECONDS
		echo -e "\n\n Finished in $((ENDTIME-STARTTIME)) Seconds\n\n"
 		;;
	*)
		ROM=$1
		VERSION=$2
		RECOVERY=$3

		if [ "$1" == "stock" ]
		then
		INITRAMFSDIR="$BASEDIR/Ramdisk/Stock/$3"
		else
		
		rm -rf "$OUTDIR"
		
		rm -f "$BASEDIR/usr/temp.list"
		cp "$BASEDIR/usr/basic.list" "$BASEDIR/usr/temp.list"
		sed -i 's/!ANDROID_VERSION!/'$2'/g' "$BASEDIR/usr/temp.list"		
		sed -i 's/!RECOVERY!/'$3'/g' "$BASEDIR/usr/temp.list"		

		INITRAMFSDIR="$BASEDIR/usr/temp.list"
		fi

		echo -e "\n\n Configuring I8160 Kernel...\n\n"
		make RoXSel_defconfig ARCH=arm CROSS_COMPILE=$TOOLCHAIN

		echo -e "\n\n Compiling I8160 Kernel and Modules... \n\n"
		make -j4 ARCH=arm CROSS_COMPILE=$TOOLCHAIN CONFIG_INITRAMFS_SOURCE=$INITRAMFSDIR

		if [ "$1" == "stock" ]
		then
		
		mkdir -p $INITRAMFSDIR/lib/modules/
		cp fs/cifs/cifs.ko $INITRAMFSDIR/lib/modules/cifs.ko
		cp fs/exfat/exfat.ko $INITRAMFSDIR/lib/modules/exfat.ko
		cp drivers/scsi/scsi_wait_scan.ko $INITRAMFSDIR/lib/modules/scsi_wait_scan.ko
		cp drivers/samsung/j4fs/j4fs.ko $INITRAMFSDIR/lib/modules/j4fs.ko
		cp drivers/bluetooth/bthid/bthid.ko $INITRAMFSDIR/lib/modules/bthid.ko
		cp drivers/char/hwreg/hwreg.ko $INITRAMFSDIR/lib/modules/hwreg.ko
		cp drivers/samsung/param/param.ko $INITRAMFSDIR/lib/modules/param.ko
		cp drivers/staging/android/logger.ko $INITRAMFSDIR/lib/modules/logger.ko
		cp drivers/char/frandom/frandom.ko $INITRAMFSDIR/lib/modules/frandom.ko
		cp drivers/char/hw_random/rng-core.ko $INITRAMFSDIR/lib/modules/rng-core.ko
		cp drivers/net/wireless/bcmdhd/dhd.ko $INITRAMFSDIR/lib/modules/dhd.ko


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
		zip -r RoXSel_$KERNEL_VERSION_stock_$RECOVERY.zip .
		cd $BASEDIR

		echo -e "\n\n Cleaning Output Folder...\n\n"
		rm -rf $OUTDIR/META-INF
		rm -rf $OUTDIR/system
		rm $OUTDIR/kernel.bin.md5

		else
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
		zip -r RoXSel_$KERNEL_VERSION_$1_$2_$3.zip .
		cd $BASEDIR

		echo -e "\n\n Cleaning Output Folder...\n\n"
		rm -rf $OUTDIR/META-INF
		rm -rf $OUTDIR/system
		rm $OUTDIR/boot.img
		fi

        ENDTIME=$SECONDS
        echo -e "\n\n = Finished in $((ENDTIME-STARTTIME)) Seconds =\n\n"
		;;
esac
