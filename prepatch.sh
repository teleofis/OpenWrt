#!/bin/bash
cd DLpatch/
tar cf - linux-3.18.29 | pixz > linux-3.18.29.tar.xz
mv linux-3.18.29.tar.xz ../dl
cd ..