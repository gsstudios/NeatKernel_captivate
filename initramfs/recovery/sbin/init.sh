#!/sbin/busyboxboot sh
set +x
_PATH="$PATH"
export PATH=/sbin

busyboxboot rm /init
busyboxboot rm /default.prop.galaxys
busyboxboot rm /default.prop.galaxysb
busyboxboot rm /default.prop.captivate
busyboxboot rm /default.prop.vibrant

# include device specific vars
source /sbin/bootrec-device

# create directories
busyboxboot mkdir -m 777 -p /cache
busyboxboot mkdir -m 755 -p /dev/block
busyboxboot mkdir -m 755 -p /dev/input
busyboxboot mkdir -m 555 -p /proc
busyboxboot mkdir -m 755 -p /sys

# create device nodes
busyboxboot mknod -m 600 /dev/block/mmcblk0 b 179 0
busyboxboot mknod -m 600 ${BOOTREC_CACHE_NODE}
busyboxboot mknod -m 600 ${BOOTREC_EVENT_NODE}
busyboxboot mknod -m 666 /dev/null c 1 3

# mount filesystems
busyboxboot mount -t proc proc /proc
busyboxboot mount -t sysfs sysfs /sys
busyboxboot mount -t yaffs2 ${BOOTREC_CACHE} /cache

# fixing CPU clocks to avoid issues in booting
busyboxboot echo 1024000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
busyboxboot echo 122880 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
busyboxboot echo 1 > /sys/devices/i2c-0/0-0040/leds/lcd-backlight/als/enable

# trigger amber LED
busyboxboot echo 255 > ${BOOTREC_LED_RED}
busyboxboot echo 0 > ${BOOTREC_LED_GREEN}
busyboxboot echo 30 > ${BOOTREC_LED_BLUE}
busyboxboot echo 50 > /sys/class/timed_output/vibrator/enable
busyboxboot echo 50 > /sys/class/misc/notification/led
busyboxboot echo 255 > /sys/class/misc/notification/bl_timeout

# keycheck
busyboxboot cat ${BOOTREC_EVENT} > /dev/keyvolume&
busyboxboot sleep 3

# android ramdisk
load_image=/sbin/ramdisk_android_cwm.cpio

# boot decision
if [ -s /dev/keyvolume -o -e /cache/recovery/boot ]
then
	busyboxboot rm -fr /cache/recovery/boot
	# trigger green led (twrp boot)
	busyboxboot echo 0 > ${BOOTREC_LED_RED}
	busyboxboot echo 190 > ${BOOTREC_LED_GREEN}
	busyboxboot echo 255 > ${BOOTREC_LED_BLUE}
	# recovery ramdisk
	load_image=/sbin/ramdisk_twrp.cpio
else
	busyboxboot touch /cache/recovery/cwm
	# poweroff LED (normal boot)
	busyboxboot echo 0 > ${BOOTREC_LED_RED}
	busyboxboot echo 0 > ${BOOTREC_LED_GREEN}
	busyboxboot echo 0 > ${BOOTREC_LED_BLUE}
fi

# kill the keycheck process
busyboxboot pkill -f "busyboxboot cat ${BOOTREC_EVENT}"

# unpack the ramdisk image
busyboxboot cpio -i < ${load_image}

# check for SwapSD
SWAPSD_CHECK_FILE="/swapsd"
SWAPSD_CHECK=`busyboxboot cat $SWAPSD_CHECK_FILE | busyboxboot grep "swapsd=1" | $BB wc -l`;
if [ "$SWAPSD_CHECK" -eq "1" ]; then
        busyboxboot rm /fstab.aries;
        busyboxboot rm /etc/recovery.fstab
        busyboxboot rm /etc/twrp.fstab
        busyboxboot cp /sbin/fstab.aries.swapsd /fstab.aries;
        busyboxboot mv /sbin/fstab.aries.swapsd /etc/recovery.fstab;
        busyboxboot mv /sbin/twrp.fstab.swapsd /etc/twrp.fstab;
fi

# Remove not needed cpio ramdisks to free ram
busyboxboot rm /sbin/ramdisk_twrp.cpio /sbin/ramdisk_android_cwm.cpio
busyboxboot rm /swapsd

busyboxboot umount /cache
busyboxboot umount /proc
busyboxboot umount /sys

busyboxboot rm -fr /dev/*

export PATH="${_PATH}"
exec /init

