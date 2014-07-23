#!/bin/bash

###############################################################################
# To all DEV around the world :)                                              #
# to build this kernel you need to be ROOT and to have bash as script loader  #
# do this:                                                                    #
# cd /bin                                                                     #
# rm -f sh                                                                    #
# ln -s bash sh                                                               #
# now go back to kernel folder and run:                                       # 
#                                                         		      #
# sh clean_kernel.sh                                                          #
#                                                                             #
# Now you can build my kernel.                                                #
# using bash will make your life easy. so it's best that way.                 #
# Have fun and update me if something nice can be added to my source.         #
###############################################################################

# Time of build startup
res1=$(date +%s.%N)

echo "${bldcya}***** Setting up Environment *****${txtrst}";

. ./env_setup.sh ${1} || exit 1;

if [ ! -f $KERNELDIR/.config ]; then
	echo "${bldcya}***** Writing Config *****${txtrst}";
	cp $KERNELDIR/arch/arm/configs/$KERNEL_CONFIG .config;
	make $KERNEL_CONFIG;
fi;

. $KERNELDIR/.config

# remove previous zImage files
if [ -e $KERNELDIR/zImage ]; then
	rm $KERNELDIR/zImage;
	rm $KERNELDIR/boot.img;
fi;
if [ -e $KERNELDIR/arch/arm/boot/zImage ]; then
	rm $KERNELDIR/arch/arm/boot/zImage;
fi;

# remove previous initramfs files
rm -rf $KERNELDIR/initramfs/res/lib/modules >> /dev/null;
rm -rf $KERNELDIR/tmp_modules >> /dev/null;
rm -rf $KERNELDIR/temp >> /dev/null;

# clean initramfs old compile data
rm -f $KERNELDIR/usr/initramfs_data.cpio >> /dev/null;
rm -f $KERNELDIR/usr/initramfs_data.o >> /dev/null;

# remove all old modules before compile
find $KERNELDIR -name "*.ko" | parallel rm -rf {};

mkdir -p $KERNELDIR/initramfs/res/lib/modules
mkdir -p $KERNELDIR/tmp_modules

# make modules and install
echo "${bldcya}***** Compiling modules *****${txtrst}"
if [ $USER != "root" ]; then
	make -j$NUMBEROFCPUS modules || exit 1
else
	nice -n -15 make -j$NUMBEROFCPUS modules || exit 1
fi;

echo "${bldcya}***** Installing modules *****${txtrst}"
if [ $USER != "root" ]; then
	make -j$NUMBEROFCPUS INSTALL_MOD_PATH=$KERNELDIR/tmp_modules modules_install || exit 1
else
	nice -n -15 make -j$NUMBEROFCPUS INSTALL_MOD_PATH=$KERNELDIR/tmp_modules modules_install || exit 1
fi;

# copy modules
echo "${bldcya}***** Copying modules *****${txtrst}"
find $KERNELDIR/tmp_modules -name '*.ko' | parallel cp -av {} $KERNELDIR/initramfs/res/lib/modules;
find $KERNELDIR/itramfs/initramfs/res/lib/modules -name '*.ko' | parallel ${CROSS_COMPILE}strip --strip-debug {};
chmod 755 $KERNELDIR/initramfs/res/lib/modules/*;

# remove temp module files generated during compile
echo "${bldcya}***** Removing temp module stage 2 files *****${txtrst}"
rm -rf $KERNELDIR/tmp_modules >> /dev/null

# make zImage
echo "${bldcya}***** Compiling kernel *****${txtrst}"
if [ $USER != "root" ]; then
	make -j$NUMBEROFCPUS zImage
else
	nice -n -15 make -j$NUMBEROFCPUS zImage
fi;

if [ -e $KERNELDIR/arch/arm/boot/zImage ]; then
	echo "${bldcya}***** Final Touch for Kernel *****${txtrst}"
	cp $KERNELDIR/arch/arm/boot/zImage $KERNELDIR/zImage;
	stat $KERNELDIR/zImage || exit 1;
	./utilities/acp -fp zImage boot.img
	# copy all needed to out kernel folder
	rm $KERNELDIR/out/boot.img >> /dev/null;
	rm $KERNELDIR/out/NeatKernel* >> /dev/null;
	GETVER=`grep 'NeatKernel_v.*' env_setup.sh | sed 's/.*_.//g' | sed 's/".*//g'`
        BUILDTIME=`date +"[%m-%d]-[%H-%M]"`
	cp $KERNELDIR/boot.img /$KERNELDIR/out/
	cd $KERNELDIR/out/
	zip -r ${NEAT_VER}_v${GETVER}-${BUILDTIME}.zip .
	cd $KERNELDIR
        tar cvf `echo ${NEAT_VER}_v${GETVER}`-${BUILDTIME}.tar zImage
        cp $KERNELDIR/${NEAT_VER}_*.tar /$KERNELDIR/out/
	echo "${bldcya}***** Ready to Roar *****${txtrst}";
	# finished? get elapsed time
	res2=$(date +%s.%N)
	echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}";	
else
	echo "${bldred}Kernel STUCK in BUILD!${txtrst}"
fi;

if [ -e $KERNELDIR/all ]
       then
       exit
       else
       ./menu 
       fi
