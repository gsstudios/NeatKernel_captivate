#!/bin/bash

# location

export KERNELDIR=`readlink -f .`;

export PARENT_DIR=`readlink -f ${KERNELDIR}/..`;

case "${1}" in
        galaxys)
            VARIANT="galaxys"
cp initramfs/recovery/default.prop.galaxys initramfs/recovery/default.prop
            ;;

        captivate)
            VARIANT="captivate"
cp initramfs/recovery/default.prop.captivate initramfs/recovery/default.prop
            ;;

        vibrant)
            VARIANT="vibrant"
cp initramfs/recovery/default.prop.vibrant initramfs/recovery/default.prop
            ;;
        galaxys_swapsd)
            VARIANT="galaxys_swapsd"
cp initramfs-swapsd/recovery/default.prop.galaxys initramfs-swapsd/recovery/default.prop
            ;;

        captivate_swapsd)
            VARIANT="captivate_swapsd"
cp initramfs-swapsd/recovery/default.prop.captivate initramfs-swapsd/recovery/default.prop
            ;;

        vibrant_swapsd)
            VARIANT="vibrant_swapsd"
cp initramfs-swapsd/recovery/default.prop.vibrant initramfs-swapsd/recovery/default.prop
            ;;

 *)
            VARIANT="captivate"
cp initramfs/recovery/default.prop.captivate initramfs/recovery/default.prop
esac
            
NEAT_VER="NeatKernel_${VARIANT}"

# create symbolic source link
rm source;
ln -s ${KERNELDIR} source;

# check if parallel installed, if not install
if [ ! -e /usr/bin/parallel ]; then
	echo "You must install 'parallel' by this script to continue.";
	sudo dpkg -i ${KERNELDIR}/utilities/parallel_20120422-1_all.deb
fi

# check if ccache installed, if not install
if [ ! -e /usr/bin/ccache ]; then
	echo "You must install 'ccache' to continue.";
	sudo apt-get install ccache
fi

#name
export KBUILD_BUILD_USER=mohammad.afaneh
export KBUILD_BUILD_HOST=ubuntu

# kernel
export ARCH=arm;
export USE_SEC_FIPS_MODE=true;
export KERNEL_CONFIG="${VARIANT}_defconfig";


# build script
export USER=`whoami`
export TMPFILE=`mktemp -t`;

# system compiler
export CROSS_COMPILE=$PARENT_DIR/arm-cortex_a8-linux-gnueabi-linaro_4.9.1-2014.04/bin/arm-cortex_a8-linux-gnueabi-;
#export CROSS_COMPILE=$PARENT_DIR/linaro-toolchain-4.7-2013.8/bin/arm-eabi-;

export NUMBEROFCPUS=`grep 'processor' /proc/cpuinfo | wc -l`;

# Colorize and add text parameters
export red=$(tput setaf 1)             #  red
export grn=$(tput setaf 2)             #  green
export blu=$(tput setaf 4)             #  blue
export cya=$(tput setaf 6)             #  cyan
export txtbld=$(tput bold)             #  Bold
export bldred=${txtbld}$(tput setaf 1) #  red
export bldgrn=${txtbld}$(tput setaf 2) #  green
export bldblu=${txtbld}$(tput setaf 4) #  blue
export bldcya=${txtbld}$(tput setaf 6) #  cyan
export txtrst=$(tput sgr0)             #  Reset

