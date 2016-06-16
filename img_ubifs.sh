mkdir rootfs
sudo cp ./bin/mxs/openwrt-mxs-root.ext4 openwrt-mxs-root.ext4
sudo umount ./rootfs
sudo mount -t ext4 -o loop openwrt-mxs-root.ext4 ./rootfs
mkfs.ubifs -e 126976 -m 2048 -c 2000 -x zlib -r ./rootfs -o rootfs.img