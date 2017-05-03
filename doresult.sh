mkdir result
sudo cp rootfs.img ./result/rootfs.img
sudo cp ./bin/mxs/openwrt-mxs-uImage ./result/openwrt-mxs-uImage
sudo cp ./build_dir/target-arm_arm926ej-s_uClibc-0.9.33.2_eabi/linux-mxs/linux-3.18.29/arch/arm/boot/dts/imx28-teleofis.dtb ./result/fdt.dtb
cd result
md5sum fdt.dtb > check.md5
md5sum openwrt-mxs-uImage >> check.md5
md5sum rootfs.img >> check.md5
sudo rm sysupgrade_RTU968.tar
tar -cf sysupgrade_RTU968.tar *
cd ..
