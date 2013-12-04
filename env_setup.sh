#!/bin/bash

# location
if [ "${1}" != "" ]; then
	export KERNELDIR=`readlink -f ${1}`;
else
	export KERNELDIR=`readlink -f .`;
fi;

export PARENT_DIR=`readlink -f ${KERNELDIR}/..`;
export INITRAMFS_SOURCE=`readlink -f ${KERNELDIR}/../Neat_cappy_initramfs`;
export INITRAMFS_TMP=${KERNELDIR}/tmp/initramfs_source;

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
#export KERNEL_CONFIG="fluid_vibrantmtd_defconfig";
export KERNEL_CONFIG="Neat_captivatemtd_defconfig";


# build script
export USER=`whoami`
export TMPFILE=`mktemp -t`;

# system compiler
# export CROSS_COMPILE=$PARENT_DIR/linaro-toolchain-4.8-2013.10/bin/arm-eabi-;
export CROSS_COMPILE=$PARENT_DIR/linaro-toolchain-4.7-2013.10/bin/arm-eabi-;

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

