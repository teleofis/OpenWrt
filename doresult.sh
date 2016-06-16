mkdir result
sudo cp rootfs.img ./result/rootfs.img
sudo cp ./bin/mxs/openwrt-mxs-uImage ./result/openwrt-mxs-uImage
sudo cp ./build_dir/target-arm_arm926ej-s_uClibc-0.9.33.2_eabi/linux-mxs/linux-3.18.29/arch/arm/boot/dts/imx28-duckbill.dtb ./result/fdt.dtb
cd result
sudo rm sysupgrade_RTU968.tar
tar -cf sysupgrade_RTU968.tar *
cd ..