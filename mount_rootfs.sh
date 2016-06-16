sudo cp ./bin/mxs/openwrt-mxs-root.ext4 openwrt-mxs-root.ext4
sudo umount ./rootfs
sudo mount -t ext4 -o loop openwrt-mxs-root.ext4 ./rootfs
