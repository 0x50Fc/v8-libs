#!/bin/sh

apt update
apt install git
apt install software-properties-common
add-apt-repository ppa:deadsnakes/ppa
apt install python3.8
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH=$PATH:`pwd`/depot_tools

gclient sync

cd v8
./build/linux/sysroot_scripts/install-sysroot.py --all
