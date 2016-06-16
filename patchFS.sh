#cp FSpatch/myinit.sh 	rootfs/usr/sbin/myinit.sh

#cp FSpatch/inittab 	rootfs/etc/inittab
#cp FSpatch/rc.local 	rootfs/etc/rc.local
#cp FSpatch/banner 	rootfs/etc/banner
#cp FSpatch/shadow 	rootfs/etc/shadow

#cp FSpatch/network 	rootfs/etc/config/network
#cp FSpatch/system 	rootfs/etc/config/system
#cp FSpatch/ntpclient 	rootfs/etc/config/ntpclient
#cp FSpatch/firewall 	rootfs/etc/config/firewall
#cp FSpatch/dhcp 	rootfs/etc/config/dhcp

cp -R FSpatch/etc rootfs/
cp -R FSpatch/usr rootfs/
cp -R FSpatch/www rootfs/
cp -R FSpatch/sbin rootfs/